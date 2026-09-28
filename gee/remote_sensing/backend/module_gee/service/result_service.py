"""任务结果服务 - 查询任务执行结果和模型预测"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
import json
from config.env import DataBaseConfig


class ResultService:
    """任务结果查询服务"""
    
    # 连接池
    _pool = None
    
    def __init__(self):
        """初始化服务"""
        if ResultService._pool is None:
            db_config = DataBaseConfig  # DataBaseConfig已经是实例，不需要调用
            ResultService._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=db_config.db_host,
                port=db_config.db_port,
                user=db_config.db_username,
                password=db_config.db_password,
                database=db_config.db_database
            )
    
    def _get_connection(self):
        """从连接池获取连接"""
        return ResultService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接到连接池"""
        ResultService._pool.putconn(conn)
    
    def get_result_list(
        self,
        page_num: int = 1,
        page_size: int = 10,
        task_name: str = None,
        cache_source: str = None,
        start_date: str = None,
        end_date: str = None
    ) -> Dict:
        """
        获取任务结果列表（分页）
        
        Args:
            page_num: 页码
            page_size: 每页数量
            task_name: 任务名称（模糊查询）
            cache_source: 缓存来源（cache/gee）
            start_date: 开始日期
            end_date: 结束日期
            
        Returns:
            {'rows': [...], 'total': int}
        """
        conn = self._get_connection()
        try:
            # 构建查询条件
            conditions = ['1=1']
            params = []
            
            if task_name:
                conditions.append("t.task_name LIKE %s")
                params.append(f'%{task_name}%')
            
            if cache_source:
                conditions.append("r.cache_source = %s")
                params.append(cache_source)
            
            if start_date:
                conditions.append("r.found_date >= %s")
                params.append(start_date)
            
            if end_date:
                conditions.append("r.found_date <= %s")
                params.append(end_date)
            
            where_clause = ' AND '.join(conditions)
            
            # 查询总数
            cursor = conn.cursor()
            count_query = f'''
                SELECT COUNT(*) 
                FROM gee_task_results r
                JOIN gee_tasks t ON r.task_id = t.task_id
                WHERE {where_clause}
            '''
            cursor.execute(count_query, params)
            count_result = cursor.fetchone()
            total = count_result[0] if count_result else 0
            cursor.close()
            
            # 查询数据
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            offset = (page_num - 1) * page_size
            
            query = f'''
                SELECT 
                    r.result_id,
                    r.task_id,
                    t.task_name,
                    t.task_type,
                    t.target_date,
                    t.status as task_status,
                    r.file_name,
                    r.cache_source,
                    r.cache_hit_rate,
                    r.tile_count,
                    r.found_date,
                    r.cloud_cover,
                    r.processing_time,
                    r.models_total,
                    r.models_successful,
                    r.models_failed,
                    r.created_at,
                    t.created_at as task_created_at
                FROM gee_task_results r
                JOIN gee_tasks t ON r.task_id = t.task_id
                WHERE {where_clause}
                ORDER BY r.created_at DESC
                LIMIT %s OFFSET %s
            '''
            
            cursor.execute(query, params + [page_size, offset])
            rows = cursor.fetchall()
            
            # 转换字段名为驼峰命名
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'resultId': row['result_id'],
                    'taskId': row['task_id'],
                    'taskName': row['task_name'],
                    'taskType': row['task_type'],
                    'targetDate': str(row['target_date']) if row['target_date'] else None,
                    'taskStatus': row['task_status'],
                    'fileName': row['file_name'],
                    'cacheSource': row['cache_source'],
                    'cacheHitRate': float(row['cache_hit_rate']) if row['cache_hit_rate'] else 0,
                    'tileCount': row['tile_count'],
                    'foundDate': str(row['found_date']) if row['found_date'] else None,
                    'cloudCover': float(row['cloud_cover']) if row['cloud_cover'] else 0,
                    'processingTime': float(row['processing_time']) if row['processing_time'] else 0,
                    'modelsTotal': row['models_total'],
                    'modelsSuccessful': row['models_successful'],
                    'modelsFailed': row['models_failed'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'taskCreatedAt': row['task_created_at'].isoformat() if row['task_created_at'] else None
                })
            
            return {
                'rows': camel_rows,
                'total': total
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_result_detail(self, task_id: str) -> Optional[Dict]:
        """
        获取任务结果详情
        
        Args:
            task_id: 任务ID
            
        Returns:
            任务结果详情字典
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 查询任务结果主表
            cursor.execute('''
                SELECT 
                    r.*,
                    t.task_name,
                    t.task_type,
                    t.target_date,
                    t.model_type,
                    t.status as task_status,
                    t.progress,
                    t.created_at as task_created_at
                FROM gee_task_results r
                JOIN gee_tasks t ON r.task_id = t.task_id
                WHERE r.task_id = %s
            ''', (task_id,))
            
            result = cursor.fetchone()
            if not result:
                return None
            
            # 转换为驼峰命名
            detail = {
                'resultId': result['result_id'],
                'taskId': result['task_id'],
                'taskName': result['task_name'],
                'taskType': result['task_type'],
                'targetDate': str(result['target_date']) if result['target_date'] else None,
                'modelType': result['model_type'],
                'taskStatus': result['task_status'],
                'progress': result['progress'],
                'fileName': result['file_name'],
                'tifPath': result['tif_path'],
                'cacheSource': result['cache_source'],
                'cacheHitRate': float(result['cache_hit_rate']) if result['cache_hit_rate'] else 0,
                'tileCount': result['tile_count'],
                'tileIds': json.loads(result['tile_ids']) if result['tile_ids'] else [],
                'isExpired': result['is_expired'],
                'foundDate': str(result['found_date']) if result['found_date'] else None,
                'cloudCover': float(result['cloud_cover']) if result['cloud_cover'] else 0,
                'totalPixels': result['total_pixels'],
                'validPixels': result['valid_pixels'],
                'geoBounds': json.loads(result['geo_bounds']) if result['geo_bounds'] else None,
                'processingTime': float(result['processing_time']) if result['processing_time'] else 0,
                'totalPredictions': result['total_predictions'],
                'modelsTotal': result['models_total'],
                'modelsSuccessful': result['models_successful'],
                'modelsFailed': result['models_failed'],
                'successfulModels': json.loads(result['successful_models']) if result['successful_models'] else [],
                'createdAt': result['created_at'].isoformat() if result['created_at'] else None,
                'taskCreatedAt': result['task_created_at'].isoformat() if result['task_created_at'] else None
            }
            
            # 查询模型预测列表
            cursor.execute('''
                SELECT *
                FROM gee_model_predictions
                WHERE task_id = %s
                ORDER BY model_code
            ''', (task_id,))
            
            predictions = cursor.fetchall()
            detail['predictions'] = []
            
            for pred in predictions:
                detail['predictions'].append({
                    'predictionId': pred['prediction_id'],
                    'modelCode': pred['model_code'],
                    'modelName': pred['model_name'],
                    'success': pred['success'],
                    'resultPath': pred['result_path'],
                    'visualizationImage': pred['visualization_image'],
                    'visualizationTif': pred['visualization_tif'],
                    'visualizationSuccess': pred['visualization_success'],
                    'gradeColors': json.loads(pred['grade_colors']) if pred['grade_colors'] else [],
                    'createdAt': pred['created_at'].isoformat() if pred['created_at'] else None
                })
            
            return detail
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_model_predictions(self, task_id: str) -> List[Dict]:
        """
        获取任务的所有模型预测结果
        
        Args:
            task_id: 任务ID
            
        Returns:
            模型预测列表
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            cursor.execute('''
                SELECT *
                FROM gee_model_predictions
                WHERE task_id = %s
                ORDER BY model_code
            ''', (task_id,))
            
            predictions = cursor.fetchall()
            result = []
            
            for pred in predictions:
                result.append({
                    'predictionId': pred['prediction_id'],
                    'taskId': pred['task_id'],
                    'modelCode': pred['model_code'],
                    'modelName': pred['model_name'],
                    'success': pred['success'],
                    'resultPath': pred['result_path'],
                    'visualizationImage': pred['visualization_image'],
                    'visualizationTif': pred['visualization_tif'],
                    'visualizationSuccess': pred['visualization_success'],
                    'gradeColors': json.loads(pred['grade_colors']) if pred['grade_colors'] else [],
                    'createdAt': pred['created_at'].isoformat() if pred['created_at'] else None
                })
            
            return result
            
        finally:
            cursor.close()
            self._put_connection(conn)
