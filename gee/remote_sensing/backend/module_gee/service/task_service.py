"""任务服务 - 负责GEE任务的数据库操作"""
import psycopg2
from psycopg2.extras import RealDictCursor
from psycopg2.pool import SimpleConnectionPool
from datetime import datetime
from typing import List, Dict, Optional
from config.env import DataBaseConfig


class TaskService:
    """任务服务"""
    
    # 连接池（与TileManager共享）
    _pool = None
    
    def __init__(self):
        """初始化任务服务"""
        if TaskService._pool is None:
            TaskService._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=DataBaseConfig.db_host,
                port=DataBaseConfig.db_port,
                user=DataBaseConfig.db_username,
                password=DataBaseConfig.db_password,
                database=DataBaseConfig.db_database
            )
    
    def _get_connection(self):
        """从连接池获取连接"""
        return TaskService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接到连接池"""
        TaskService._pool.putconn(conn)
    
    def get_task_list(self, page_num: int = 1, page_size: int = 10,
                      task_id: str = None, status: str = None) -> Dict:
        """
        获取任务列表(分页)
        
        Args:
            page_num: 页码
            page_size: 每页数量
            task_id: 任务ID筛选
            status: 状态筛选
            
        Returns:
            {'rows': [...], 'total': int}
        """
        conn = self._get_connection()
        try:
            # 使用普通cursor查询总数
            cursor = conn.cursor()
            
            # 构建查询条件
            conditions = []
            params = []
            
            if task_id:
                conditions.append("task_id LIKE %s")
                params.append(f"%{task_id}%")
            
            if status is not None:
                conditions.append("status = %s")
                params.append(status)
            
            where_clause = " AND ".join(conditions) if conditions else "1=1"
            
            # 查询总数
            cursor.execute(f'SELECT COUNT(*) FROM gee_tasks WHERE {where_clause}', params)
            total = cursor.fetchone()[0]
            cursor.close()
            
            # 使用RealDictCursor查询数据
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 查询数据
            offset = (page_num - 1) * page_size
            query = f'''
                SELECT task_id, task_type, task_name, target_date, 
                       status, progress, result_path, error_msg,
                       created_at, start_time, end_time
                FROM gee_tasks 
                WHERE {where_clause}
                ORDER BY created_at DESC
                LIMIT %s OFFSET %s
            '''
            cursor.execute(query, params + [page_size, offset])
            rows = cursor.fetchall()
            
            # 转换字段名为驼峰命名（前端兼容）
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'taskId': row['task_id'],
                    'taskType': row['task_type'],
                    'taskName': row['task_name'],
                    'targetDate': str(row['target_date']) if row['target_date'] else None,
                    'status': row['status'],
                    'progress': row['progress'],
                    'resultPath': row['result_path'],
                    'errorMsg': row['error_msg'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'startTime': row['start_time'].isoformat() if row['start_time'] else None,
                    'endTime': row['end_time'].isoformat() if row['end_time'] else None
                })
            
            return {
                'rows': camel_rows,
                'total': total
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_task_stats(self) -> Dict:
        """
        获取任务统计信息
        
        Returns:
            统计信息字典
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 总任务数
            cursor.execute('SELECT COUNT(*) FROM gee_tasks')
            total_tasks = cursor.fetchone()[0]
            
            # 各状态任务数
            cursor.execute("SELECT COUNT(*) FROM gee_tasks WHERE status = %s", ('pending',))
            pending_tasks = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM gee_tasks WHERE status = %s", ('running',))
            running_tasks = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM gee_tasks WHERE status = %s", ('completed',))
            completed_tasks = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM gee_tasks WHERE status = %s", ('failed',))
            failed_tasks = cursor.fetchone()[0]
            
            return {
                'total_tasks': total_tasks,
                'pending_tasks': pending_tasks,
                'running_tasks': running_tasks,
                'completed_tasks': completed_tasks,
                'failed_tasks': failed_tasks,
                'success_rate': f"{(completed_tasks / max(total_tasks, 1) * 100):.1f}%"
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    def create_task(self, task_data: Dict, app_id: int = None, plot_id: int = None) -> str:
        """
        创建任务
        
        Args:
            task_data: 任务数据
            app_id: 应用ID
            plot_id: 地块ID
            
        Returns:
            task_id: 任务ID
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 生成任务ID
            import uuid
            task_id = str(uuid.uuid4())
            
            # 插入任务记录
            cursor.execute('''
                INSERT INTO gee_tasks (
                    task_id, task_name, task_type, target_date, 
                    status, progress, aoi_coords, 
                    app_id, plot_id, created_at
                ) VALUES (
                    %s, %s, %s, %s, 
                    %s, %s, %s, 
                    %s, %s, CURRENT_TIMESTAMP
                )
            ''', (
                task_id,
                task_data.get('task_name') or f"Task-{task_id[:8]}",
                'analysis',  # 默认为分析任务
                task_data.get('target_date'),
                'pending',
                0,
                str(task_data.get('aoi_coords')),
                app_id,
                plot_id
            ))
            
            conn.commit()
            cursor.close()
            
            # 触发Celery任务
            try:
                from app.celery_app import analyze_aoi_task
                
                # 准备任务参数
                aoi = task_data.get('aoi_coords')
                # 如果是字符串（从数据库读取），需要解析
                if isinstance(aoi, str):
                    import json
                    try:
                        aoi = json.loads(aoi)
                    except:
                        pass
                
                analyze_aoi_task.delay(
                    aoi_coords=aoi,
                    target_date=str(task_data.get('target_date')),
                    task_id=task_id,
                    window_days=task_data.get('window_days', 10),
                    model_type=task_data.get('model_type', 'all')
                )
            except Exception as e:
                print(f"❌ 触发Celery任务失败: {e}")
                # 更新状态为失败
                self.update_task_status(task_id, 'failed', error_msg=f"触发任务失败: {str(e)}")
            
            return task_id
            
        except Exception as e:
            conn.rollback()
            print(f"创建任务失败: {e}")
            raise e
        finally:
            self._put_connection(conn)

    def update_task_status(self, task_id: str, status: str, progress: int = None, error_msg: str = None):
        """更新任务状态"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            updates = ["status = %s"]
            params = [status]
            
            if progress is not None:
                updates.append("progress = %s")
                params.append(progress)
            
            if error_msg:
                updates.append("error_msg = %s")
                params.append(error_msg)
            
            params.append(task_id)
            
            cursor.execute(f'''
                UPDATE gee_tasks 
                SET {", ".join(updates)}
                WHERE task_id = %s
            ''', params)
            
            conn.commit()
            cursor.close()
        except Exception as e:
            conn.rollback()
            print(f"更新任务状态失败: {e}")
        finally:
            self._put_connection(conn)
    
    def get_task_detail(self, task_id: str) -> Optional[Dict]:
        """
        获取任务详情
        
        Args:
            task_id: 任务ID
            
        Returns:
            任务详情字典，如果不存在返回None
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            cursor.execute('''
                SELECT task_id, task_type, task_name, target_date, 
                       status, progress, result_path, error_msg,
                       aoi_coords, app_id, plot_id,
                       created_at, start_time, end_time
                FROM gee_tasks 
                WHERE task_id = %s
            ''', (task_id,))
            
            row = cursor.fetchone()
            
            if not row:
                return None
            
            # 转换为驼峰命名
            return {
                'taskId': row['task_id'],
                'taskType': row['task_type'],
                'taskName': row['task_name'],
                'targetDate': str(row['target_date']) if row['target_date'] else None,
                'status': row['status'],
                'progress': row['progress'],
                'resultPath': row['result_path'],
                'errorMsg': row['error_msg'],
                'aoiCoords': row['aoi_coords'],
                'appId': row['app_id'],
                'plotId': row['plot_id'],
                'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                'startTime': row['start_time'].isoformat() if row['start_time'] else None,
                'endTime': row['end_time'].isoformat() if row['end_time'] else None
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
