"""任务记录器 - 负责将任务信息写入PostgreSQL"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from datetime import datetime
from typing import Optional, Dict, Any
import json
from app.config import settings


class TaskRecorder:
    """任务记录器 - 记录任务到gee_tasks表"""
    
    # 连接池
    _pool = None
    
    def __init__(self):
        """初始化任务记录器"""
        if TaskRecorder._pool is None:
            TaskRecorder._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=5,
                host=settings.DB_HOST,
                port=settings.DB_PORT,
                user=settings.DB_USER,
                password=settings.DB_PASSWORD,
                database=settings.DB_DATABASE
            )
    
    def _get_connection(self):
        """从连接池获取连接"""
        return TaskRecorder._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接到连接池"""
        TaskRecorder._pool.putconn(conn)
    
    def create_task(
        self,
        task_id: str,
        task_type: str,
        aoi_coords: list,
        target_date: str,
        model_type: str = 'all',
        window_days: int = 7,
        metadata: Dict[str, Any] = None,
        app_id: int = None,        # 新增
        plot_id: int = None        # 新增
    ) -> bool:
        """
        创建任务记录
        
        Args:
            task_id: 任务ID (Celery task ID)
            task_type: 任务类型 (cached_workflow, workflow等)
            aoi_coords: AOI坐标
            target_date: 目标日期
            model_type: 模型类型
            window_days: 日期窗口
            metadata: 额外元数据
            app_id: 应用ID
            plot_id: 地块ID
            
        Returns:
            是否成功
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 生成任务名称
            task_name = f"{task_type}_{target_date}_{datetime.now().strftime('%H%M%S')}"
            
            cursor.execute('''
                INSERT INTO gee_tasks (
                    task_id, task_type, task_name, target_date,
                    model_type, aoi_coords, status, progress,
                    created_at, create_by, start_time,
                    app_id, plot_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW(), 'system', NOW(), %s, %s)
                ON CONFLICT (task_id) DO UPDATE SET
                    status = EXCLUDED.status
            ''', (
                task_id,
                task_type,
                task_name,
                target_date,
                model_type,
                json.dumps(aoi_coords),
                '1',  # 1=处理中
                0,    # 初始进度
                app_id,
                plot_id
            ))
            
            conn.commit()
            print(f"[TaskRecorder] 任务已创建: {task_id}")
            return True
            
        except Exception as e:
            print(f"[TaskRecorder] 创建任务失败: {e}")
            import traceback
            traceback.print_exc()
            conn.rollback()
            return False
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def update_progress(
        self,
        task_id: str,
        progress: int,
        status: str = None,
        message: str = None
    ) -> bool:
        """
        更新任务进度
        
        Args:
            task_id: 任务ID
            progress: 进度 (0-100)
            status: 状态 ('0'=待处理, '1'=处理中, '2'=成功, '3'=失败, '4'=已取消)
            message: 状态消息（忽略，表中无此字段）
            
        Returns:
            是否成功
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            updates = ['progress = %s']
            params = [progress]
            
            if status:
                updates.append('status = %s')
                params.append(status)
            
            params.append(task_id)
            
            cursor.execute(f'''
                UPDATE gee_tasks 
                SET {', '.join(updates)}
                WHERE task_id = %s
            ''', params)
            
            conn.commit()
            return True
            
        except Exception as e:
            print(f"[TaskRecorder] 更新进度失败: {e}")
            conn.rollback()
            return False
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def complete_task(
        self,
        task_id: str,
        result_path: str = None,
        result_data: Dict[str, Any] = None,
        execution_time: float = None,
        full_result: Dict[str, Any] = None  # 新增：完整的任务结果
    ) -> bool:
        """
        标记任务完成并保存完整结果
        
        Args:
            task_id: 任务ID
            result_path: 结果文件路径
            result_data: 结果数据（包含tile_ids, cache_hit_rate等）
            execution_time: 执行时间(秒)
            full_result: 完整的任务结果（包含所有模型预测等）
            
        Returns:
            是否成功
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 提取关键信息
            tile_ids = result_data.get('tile_ids', []) if result_data else []
            cache_hit_rate = result_data.get('cache_hit_rate', 0) if result_data else 0
            cache_source = 'cache' if cache_hit_rate > 0 else 'gee'
            
            # 1. 更新gee_tasks表
            cursor.execute('''
                UPDATE gee_tasks 
                SET status = %s,
                    progress = %s,
                    result_path = %s,
                    tile_ids = %s,
                    cache_hit_rate = %s,
                    cache_source = %s,
                    end_time = NOW()
                WHERE task_id = %s
            ''', (
                '2',  # 2=成功
                100,
                result_path,
                json.dumps(tile_ids) if tile_ids else None,
                cache_hit_rate * 100 if cache_hit_rate else None,  # 转换为百分比
                cache_source,
                task_id
            ))
            
            # 2. 如果有完整结果，保存到gee_task_results表
            if full_result and full_result.get('result'):
                self._save_task_results(cursor, task_id, full_result)
            
            conn.commit()
            print(f"[TaskRecorder] 任务已完成: {task_id}")
            return True
            
        except Exception as e:
            print(f"[TaskRecorder] 完成任务失败: {e}")
            import traceback
            traceback.print_exc()
            conn.rollback()
            return False
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def _save_task_results(self, cursor, task_id: str, full_result: Dict[str, Any]):
        """
        保存任务结果到gee_task_results和gee_model_predictions表
        
        Args:
            cursor: 数据库游标
            task_id: 任务ID
            full_result: 完整的任务结果
        """
        result = full_result.get('result', {})
        cache_info = result.get('cache_info', {})
        metadata = result.get('metadata', {})
        
        # 提取地理边界
        geo_bounds = metadata.get('geo_bounds')
        geo_bounds_json = json.dumps(geo_bounds) if geo_bounds else None
        
        # 提取成功的模型列表
        successful_models = metadata.get('successful_models', [])
        successful_models_json = json.dumps(successful_models) if successful_models else None
        
        # 先删除已存在的记录（如果有）
        cursor.execute('DELETE FROM gee_task_results WHERE task_id = %s', (task_id,))
        
        # 插入新记录到gee_task_results主表
        cursor.execute('''
            INSERT INTO gee_task_results (
                task_id, file_name, tif_path,
                cache_source, cache_hit_rate, tile_count, tile_ids, is_expired,
                found_date, cloud_cover, total_pixels, valid_pixels, geo_bounds, processing_time,
                total_predictions, models_total, models_successful, models_failed, successful_models
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ''', (
            task_id,
            result.get('file_name'),
            result.get('tif_path'),
            cache_info.get('source'),
            cache_info.get('cache_hit_rate', 0) * 100,  # 转换为百分比
            cache_info.get('tile_count'),
            json.dumps(cache_info.get('tile_ids', [])),
            cache_info.get('is_expired', False),
            metadata.get('found_date'),
            float(metadata.get('cloud_cover', 0)) if metadata.get('cloud_cover') else None,
            metadata.get('total_pixels'),
            metadata.get('valid_pixels'),
            geo_bounds_json,
            metadata.get('processing_time_seconds'),
            metadata.get('total_predictions', 0),
            metadata.get('models_count', {}).get('total', 0),
            metadata.get('models_count', {}).get('successful', 0),
            metadata.get('models_count', {}).get('failed', 0),
            successful_models_json
        ))
        
        # 如果有all_models_results，保存每个模型的预测结果
        all_models_results = result.get('all_models_results', {})
        if all_models_results:
            for model_code, model_result in all_models_results.items():
                self._save_model_prediction(cursor, task_id, model_code, model_result)
        
        print(f"[TaskRecorder] 任务结果已保存: {task_id}, 模型数: {len(all_models_results)}")
    
    def _save_model_prediction(self, cursor, task_id: str, model_code: str, model_result: Dict[str, Any]):
        """
        保存单个模型的预测结果
        
        Args:
            cursor: 数据库游标
            task_id: 任务ID
            model_code: 模型代码 (zg, agb等)
            model_result: 模型预测结果
        """
        visualization = model_result.get('visualization', {})
        grade_colors = model_result.get('grade_colors', [])
        
        # 先删除已存在的记录（如果有）
        cursor.execute('''
            DELETE FROM gee_model_predictions 
            WHERE task_id = %s AND model_code = %s
        ''', (task_id, model_code))
        
        # 插入新记录
        cursor.execute('''
            INSERT INTO gee_model_predictions (
                task_id, model_code, model_name, success,
                result_path, visualization_image, visualization_tif, visualization_success,
                grade_colors
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ''', (
            task_id,
            model_code,
            model_result.get('model_name'),
            model_result.get('success', True),
            model_result.get('result_path'),
            visualization.get('image_path'),
            visualization.get('tif_path'),
            visualization.get('success', False),
            json.dumps(grade_colors) if grade_colors else None
        ))

    
    def fail_task(
        self,
        task_id: str,
        error_message: str,
        error_traceback: str = None
    ) -> bool:
        """
        标记任务失败
        
        Args:
            task_id: 任务ID
            error_message: 错误消息
            error_traceback: 错误堆栈（忽略，表中无此字段）
            
        Returns:
            是否成功
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE gee_tasks 
                SET status = %s,
                    error_msg = %s,
                    end_time = NOW()
                WHERE task_id = %s
            ''', (
                '3',  # 3=失败
                error_message[:500] if error_message else None,  # 限制长度
                task_id
            ))
            
            conn.commit()
            print(f"[TaskRecorder] 任务已标记为失败: {task_id}")
            return True
            
        except Exception as e:
            print(f"[TaskRecorder] 标记失败任务失败: {e}")
            import traceback
            traceback.print_exc()
            conn.rollback()
            return False
            
        finally:
            cursor.close()
            self._put_connection(conn)
