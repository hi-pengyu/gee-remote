"""带缓存的工作流任务"""
from celery import Task
from datetime import datetime
import time
import traceback

from app.celery_app import celery_app
from app.tasks.workflow import WorkflowTask
from app.utils.logger import celery_logger
from app.config import settings
from app.concurrency_control import get_gee_concurrency_control
from app.services.task_recorder import TaskRecorder


@celery_app.task(bind=True, base=WorkflowTask, name='gee.cached_workflow', queue='gee_queue')
def cached_workflow_task(
    self,
    aoi_coords: list,
    target_date: str,
    model_type: str,
    window_days: int = 7,
    file_name: str = None,
    scale: int = 10,
    callback_url: str = None,
    app_id: int = None,        # 新增：应用ID
    plot_id: int = None        # 新增：地块ID
):
    """
    带缓存的完整工作流任务
    
    优先从缓存获取数据,缓存未命中时从GEE下载
    处理完用户请求后,空闲时自动预取相邻瓦片
    """
    start_time = time.time()
    
    celery_logger.info("=" * 80)
    celery_logger.info(f"🚀 带缓存工作流任务开始")
    celery_logger.info(f"   Task ID: {self.request.id}")
    celery_logger.info(f"   日期: {target_date}")
    celery_logger.info(f"   模型: {model_type}")
    celery_logger.info(f"   缓存启用: {settings.ENABLE_TILE_CACHE}")
    if callback_url:
        celery_logger.info(f"   回调URL: {callback_url}")
    celery_logger.info("=" * 80)
    
    # 初始化任务记录器
    task_recorder = TaskRecorder()
    
    # 记录任务到数据库
    task_recorder.create_task(
        task_id=self.request.id,
        task_type='cached_workflow',
        aoi_coords=aoi_coords,
        target_date=target_date,
        model_type=model_type,
        window_days=window_days,
        metadata={'file_name': file_name, 'scale': scale},
        app_id=app_id,
        plot_id=plot_id
    )
    
    # ========== 已移除：从账号池选择 GEE 账号 (简化架构，使用单账号) ==========
    # 原逻辑：尝试加载 gee_account_pool 并选择账号
    # 现逻辑：直接使用默认配置（单账号）
    selected_account = None
    
    # 获取并发控制器
    concurrency_control = get_gee_concurrency_control()
    
    # 获取执行权限
    celery_logger.info(f"[并发控制] 尝试获取GEE执行权限...")
    if not concurrency_control.acquire(self.request.id, timeout=600):
        error_msg = "获取GEE执行权限超时,队列可能拥堵"
        celery_logger.error(f"❌ {error_msg}")
        task_recorder.fail_task(self.request.id, error_msg)
        raise Exception(error_msg)
    
    try:
        # 生成文件名
        if not file_name:
            file_name = f"cached_{target_date}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # ========== 步骤1: 从缓存获取数据 ==========
        self.update_progress(0, "步骤 1/3: 检查缓存...")
        task_recorder.update_progress(self.request.id, 0, '1', '步骤 1/3: 检查缓存...')  # status='1'表示处理中
        
        from app.services.cache_service import CacheService
        from app.services.data_service import DataProcessingService
        from app.services.prediction_service import PredictionService
        
        # 使用选中的账号初始化 CacheService
        cache_service = CacheService(account_info=selected_account)
        
        celery_logger.info("📦 尝试从缓存获取数据...")
        
        # 从缓存获取数据(优先策略)
        cache_result = cache_service.get_data_from_cache(
            coords=aoi_coords,
            target_date=target_date,
            window_days=window_days
        )
        
        # 获取瓦片信息(支持单个或多个瓦片)
        tile_ids = cache_result.get('tile_ids', [cache_result.get('tile_id', 'unknown')])
        primary_tile_id = tile_ids[0] if tile_ids else 'unknown'
        
        if cache_result['source'] == 'cache':
            celery_logger.info(f"✓ 缓存命中! 瓦片: {tile_ids}, 命中率: {cache_result.get('cache_hit_rate', 1.0)*100:.0f}%")
            self.update_progress(40, f"✓ 从缓存获取数据 (瓦片: {len(tile_ids)}个)")
        elif cache_result['source'] == 'hybrid':
            celery_logger.info(f"⚡ 部分命中! 瓦片: {tile_ids}, 命中率: {cache_result.get('cache_hit_rate', 0)*100:.0f}%")
            self.update_progress(40, f"⚡ 混合来源 (缓存+GEE, {len(tile_ids)}个瓦片)")
        else:
            celery_logger.info(f"✗ 缓存未命中,已从GEE下载 {len(tile_ids)} 个瓦片")
            self.update_progress(40, f"✓ 从GEE下载完成 (瓦片: {len(tile_ids)}个)")
        
        tif_path = cache_result['file_path']
        found_date = cache_result['found_date']
        cloud_cover = cache_result['cloud_cover']
        
        # ========== 步骤2: 提取数据 ==========
        self.update_progress(45, "步骤 2/3: 提取数据...")
        
        data_service = DataProcessingService()
        df, data_metadata = data_service.extract_dataframe_from_tif(tif_path)
        
        self.update_progress(
            60,
            f"✓ 步骤 2/3 完成! 有效像素: {data_metadata['valid_pixels']:,}"
        )
        
        # ========== 步骤3: 本地预测 ==========
        self.update_progress(65, f"步骤 3/3: 开始预测 (模型: {model_type})...")
        
        prediction_service = PredictionService()
        
        if model_type == 'all':
            predict_result = prediction_service.predict_all_models(
                df=df,
                file_name=file_name,
                tif_path=tif_path,
                geo_bounds=data_metadata.get('geo_bounds')
            )
            
            self.update_progress(
                100,
                f"✓ 步骤 3/3 完成! 运行了 {predict_result['models_count']['total']} 个模型"
            )
        else:
            predict_result = prediction_service.predict_from_dataframe(
                df=df,
                model_type=model_type,
                file_name=file_name,
                tif_path=tif_path,
                geo_bounds=data_metadata.get('geo_bounds')
            )
            
            self.update_progress(
                100,
                f"✓ 步骤 3/3 完成! 预测结果: {predict_result['result_count']:,} 个"
            )
        
        processing_time = round(time.time() - start_time, 2)
        
        # ========== 步骤4: 后台预取相邻瓦片 ==========
        if settings.PREFETCH_ADJACENT and settings.ENABLE_TILE_CACHE:
            celery_logger.info(f"[Cache] 触发后台预取任务...")
            
            from app.tasks.workflow import prefetch_adjacent_tiles_task
            
            # 为每个瓦片预取相邻瓦片(去重会在预取任务中处理)
            for tile_id in tile_ids:
                prefetch_adjacent_tiles_task.apply_async(
                    args=[tile_id, target_date, window_days],
                    countdown=5  # 5秒后执行,避免立即抢占资源
                )
            
            celery_logger.info(f"[Cache] 预取任务已提交 ({len(tile_ids)} 个中心瓦片)")
        
        # 构建返回结果
        result = {
            'success': True,
            'file_name': file_name,
            'tif_path': tif_path,
            'cache_info': {
                'source': cache_result['source'],
                'tile_ids': tile_ids,
                'tile_count': len(tile_ids),
                'cache_hit_rate': cache_result.get('cache_hit_rate', 1.0 if cache_result['source'] == 'cache' else 0.0),
                'is_expired': cache_result.get('is_expired', False)
            },
            'metadata': {
                'found_date': found_date,
                'cloud_cover': cloud_cover,
                'total_pixels': data_metadata['total_pixels'],
                'valid_pixels': data_metadata['valid_pixels'],
                'geo_bounds': data_metadata.get('geo_bounds'),
                'processing_time_seconds': processing_time
            }
        }
        
        # 添加预测结果
        if model_type == 'all':
            result['all_models'] = True
            result['all_models_results'] = predict_result['all_models_results']
            result['metadata']['total_predictions'] = predict_result['total_predictions']
            result['metadata']['models_count'] = predict_result['models_count']
            result['metadata']['successful_models'] = predict_result['successful_models']
        else:
            result['result_path'] = predict_result.get('result_path')
            result['metadata']['result_count'] = predict_result.get('result_count', 0)
            result['metadata']['model_type'] = [model_type]
            result['metadata']['prediction_success'] = predict_result['success']
        
        # 发送成功回调
        if callback_url:
            from app.services.callback_service import notify_callback_success
            notify_callback_success(callback_url, self.request.id, result)
        
        celery_logger.info(f"✅ 工作流完成! 处理时间: {processing_time}秒")
        celery_logger.info(f"   数据来源: {cache_result['source']}")
        celery_logger.info(f"   瓦片数量: {len(tile_ids)}")
        celery_logger.info(f"   瓦片ID: {tile_ids}")
        celery_logger.info(f"   缓存命中率: {cache_result.get('cache_hit_rate', 0)*100:.1f}%")
        
        # 记录任务完成
        execution_time = time.time() - start_time
        
        # 构建完整的结果对象（用于数据库存储）
        full_result_for_db = {
            'task_id': self.request.id,
            'status': 'success',
            'progress': 100,
            'result': result
        }
        
        task_recorder.complete_task(
            task_id=self.request.id,
            result_path=result.get('result_path') or result.get('tif_path'),
            result_data={
                'tile_ids': tile_ids,
                'cache_hit_rate': cache_result.get('cache_hit_rate', 0),
                'found_date': found_date,
                'cloud_cover': cloud_cover
            },
            execution_time=execution_time,
            full_result=full_result_for_db  # 传入完整结果
        )
        
        celery_logger.info("✅ 任务执行完成: gee.cached_workflow | ID: {}".format(self.request.id))
        return result
        
    except Exception as e:
        error_msg = str(e)
        error_trace = traceback.format_exc()
        celery_logger.error(f"❌ 工作流失败: {error_msg}")
        celery_logger.error(f"   错误堆栈:\n{error_trace}")
        
        # 记录任务失败
        task_recorder.fail_task(
            task_id=self.request.id,
            error_message=error_msg,
            error_traceback=error_trace
        )
        
        # 发送失败回调
        if callback_url:
            from app.services.callback_service import notify_callback_failure
            notify_callback_failure(callback_url, self.request.id, error_msg)
        
        self.update_state(
            state='FAILURE',
            meta={
                'error': error_msg,
                'error_type': type(e).__name__,
                'timestamp': datetime.now().isoformat()
            }
        )
        raise Exception(error_msg)
        
    finally:
        # 释放并发控制
        concurrency_control.release(self.request.id)

