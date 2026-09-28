"""缓存管理后台任务 - 大小检查和报告生成"""
import os
import sqlite3
from celery import Task
from datetime import datetime, timedelta

from app.celery_app import celery_app
from app.tasks.workflow import WorkflowTask
from app.utils.logger import celery_logger
from app.config import settings


@celery_app.task(bind=True, base=WorkflowTask, name='cache.check_size', queue='gee_queue')
def check_cache_size_task(self):
    """
    后台任务:检查并强制执行缓存大小限制
    
    自动删除最少访问的瓦片,保持缓存在限制以内
    """
    celery_logger.info(f"[Cache] 开始检查缓存大小...")
    
    try:
        from app.services.cache_service import CacheService
        from app.services.tile_manager import TileManager
        
        cache_service = CacheService()
        stats = cache_service.get_cache_statistics()
        
        current_size_gb = stats['actual_size_gb']
        max_size_gb = settings.MAX_CACHE_SIZE_GB
        
        celery_logger.info(f"[Cache] 当前大小: {current_size_gb:.2f} GB / {max_size_gb} GB")
        
        if current_size_gb <= max_size_gb:
            celery_logger.info(f"[Cache] 缓存大小正常,无需清理")
            return {
                'success': True,
                'action': 'none',
                'current_size_gb': current_size_gb,
                'max_size_gb': max_size_gb
            }
        
        # 需要清理,目标是降到80%
        target_size_gb = max_size_gb * 0.8
        need_to_free_gb = current_size_gb - target_size_gb
        
        celery_logger.info(f"[Cache] 超出限制,需要释放 {need_to_free_gb:.2f} GB")
        
        tile_manager = TileManager()
        conn = sqlite3.connect(tile_manager.db_path)
        cursor = conn.cursor()
        
        # 获取最少访问的瓦片
        cursor.execute('''
            SELECT tile_id, file_path, file_size
            FROM tiles
            WHERE status = 'active'
            ORDER BY access_count ASC, last_access ASC
        ''')
        
        deleted_count = 0
        deleted_size = 0
        
        for tile_id, file_path, file_size in cursor.fetchall():
            if deleted_size / (1024**3) >= need_to_free_gb:
                break
            
            try:
                if os.path.exists(file_path):
                    os.remove(file_path)
                
                cursor.execute(
                    'UPDATE tiles SET status = "deleted" WHERE tile_id = ?',
                    (tile_id,)
                )
                
                deleted_size += file_size if file_size else 0
                deleted_count += 1
                
            except Exception as e:
                celery_logger.warning(f"[Cache] 删除失败 {tile_id}: {e}")
        
        conn.commit()
        conn.close()
        
        freed_gb = deleted_size / (1024**3)
        celery_logger.info(f"[Cache] 清理完成: 删除 {deleted_count} 个瓦片, 释放 {freed_gb:.2f} GB")
        
        return {
            'success': True,
            'action': 'cleaned',
            'deleted_count': deleted_count,
            'freed_gb': freed_gb,
            'current_size_gb': current_size_gb - freed_gb
        }
        
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"[Cache] 检查缓存大小失败: {error_msg}")
        return {
            'success': False,
            'error': error_msg
        }


@celery_app.task(bind=True, base=WorkflowTask, name='cache.generate_report', queue='gee_queue')
def generate_cache_report_task(self):
    """
    后台任务:生成缓存使用报告
    
    统计缓存命中率、热点区域等信息
    """
    celery_logger.info(f"[Cache] 开始生成缓存报告...")
    
    try:
        from app.services.cache_service import CacheService
        from app.services.tile_manager import TileManager
        import json
        
        cache_service = CacheService()
        tile_manager = TileManager()
        
        # 获取基础统计
        stats = cache_service.get_cache_statistics()
        
        # 获取热点瓦片
        hot_tiles = tile_manager.get_hot_tiles(limit=10)
        
        # 获取过期瓦片
        expired_tiles = tile_manager.get_expired_tiles(limit=100)
        
        # 生成报告
        report = {
            'generated_at': datetime.now().isoformat(),
            'summary': {
                'total_tiles': stats['total_tiles'],
                'active_tiles': stats['active_tiles'],
                'expired_tiles': len(expired_tiles),
                'total_size_gb': stats['actual_size_gb'],
                'total_accesses': stats['total_accesses']
            },
            'hot_tiles': [
                {
                    'tile_id': t['tile_id'],
                    'access_count': t['access_count'],
                    'date_acquired': t['date_acquired']
                }
                for t in hot_tiles[:5]
            ],
            'health': {
                'cache_utilization': f"{(stats['actual_size_gb'] / settings.MAX_CACHE_SIZE_GB * 100):.1f}%",
                'expired_ratio': f"{(len(expired_tiles) / max(stats['total_tiles'], 1) * 100):.1f}%"
            }
        }
        
        # 保存报告
        report_dir = os.path.join(settings.STORAGE_LOGS_DIR, 'cache_reports')
        os.makedirs(report_dir, exist_ok=True)
        
        report_file = os.path.join(
            report_dir,
            f"cache_report_{datetime.now().strftime('%Y%m%d')}.json"
        )
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        celery_logger.info(f"[Cache] 报告已生成: {report_file}")
        celery_logger.info(f"[Cache] 总瓦片: {report['summary']['total_tiles']}, "
                          f"总大小: {report['summary']['total_size_gb']:.2f} GB")
        
        return {
            'success': True,
            'report_file': report_file,
            'summary': report['summary']
        }
        
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"[Cache] 生成报告失败: {error_msg}")
        return {
            'success': False,
            'error': error_msg
        }
