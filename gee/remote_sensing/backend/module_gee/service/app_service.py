"""GEE应用管理服务"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
import uuid
from config.env import DataBaseConfig


class GeeAppService:
    """GEE应用管理服务"""
    
    _pool = None
    
    def __init__(self):
        """初始化服务"""
        if GeeAppService._pool is None:
            db_config = DataBaseConfig
            GeeAppService._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=db_config.db_host,
                port=db_config.db_port,
                user=db_config.db_username,
                password=db_config.db_password,
                database=db_config.db_database
            )
    
    def _get_connection(self):
        """获取连接"""
        return GeeAppService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接"""
        GeeAppService._pool.putconn(conn)
    
    def get_app_list(
        self,
        page_num: int = 1,
        page_size: int = 10,
        app_name: str = None
    ) -> Dict:
        """获取应用列表"""
        conn = self._get_connection()
        try:
            conditions = ['1=1']
            params = []
            
            if app_name:
                conditions.append("app_name LIKE %s")
                params.append(f'%{app_name}%')
            
            where_clause = ' AND '.join(conditions)
            
            # 查询总数
            cursor = conn.cursor()
            count_query = f'SELECT COUNT(*) FROM gee_apps WHERE {where_clause}'
            cursor.execute(count_query, params)
            count_result = cursor.fetchone()
            total = count_result[0] if count_result else 0
            cursor.close()
            
            # 查询数据
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            offset = (page_num - 1) * page_size
            
            query = f'''
                SELECT 
                    app_id, app_name, app_key, description, is_enabled,
                    callback_url, enable_daily_update,
                    created_at, updated_at
                FROM gee_apps
                WHERE {where_clause}
                ORDER BY created_at DESC
                LIMIT %s OFFSET %s
            '''
            
            cursor.execute(query, params + [page_size, offset])
            rows = cursor.fetchall()
            
            # 转换为驼峰命名
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'appId': row['app_id'],
                    'appName': row['app_name'],
                    'appKey': row['app_key'],
                    'description': row['description'],
                    'isEnabled': row['is_enabled'],
                    'callbackUrl': row['callback_url'],
                    'enableDailyUpdate': row['enable_daily_update'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None
                })
            
            return {
                'rows': camel_rows,
                'total': total
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_app_by_id(self, app_id: int) -> Optional[Dict]:
        """根据ID获取应用"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('SELECT * FROM gee_apps WHERE app_id = %s', (app_id,))
            row = cursor.fetchone()
            
            if not row:
                return None
            
            return {
                'appId': row['app_id'],
                'appName': row['app_name'],
                'appKey': row['app_key'],
                'description': row['description'],
                'isEnabled': row['is_enabled'],
                'callbackUrl': row['callback_url'],
                'enableDailyUpdate': row['enable_daily_update'],
                'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None
            }
        finally:
            cursor.close()
            self._put_connection(conn)

    def create_app(self, app_name: str, description: str = None, 
                   callback_url: str = None, enable_daily_update: bool = False) -> bool:
        """创建应用"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            app_key = uuid.uuid4().hex
            
            cursor.execute('''
                INSERT INTO gee_apps (app_name, app_key, description, callback_url, enable_daily_update)
                VALUES (%s, %s, %s, %s, %s)
            ''', (app_name, app_key, description, callback_url, enable_daily_update))
            
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            print(f"创建应用失败: {e}")
            return False
        finally:
            self._put_connection(conn)

    def update_app(self, app_id: int, app_name: str, description: str, is_enabled: bool, 
                   callback_url: str = None, enable_daily_update: bool = False) -> bool:
        """更新应用"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE gee_apps 
                SET app_name = %s, description = %s, is_enabled = %s, 
                    callback_url = %s, enable_daily_update = %s, updated_at = CURRENT_TIMESTAMP
                WHERE app_id = %s
            ''', (app_name, description, is_enabled, callback_url, enable_daily_update, app_id))
            
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            print(f"更新应用失败: {e}")
            return False
        finally:
            self._put_connection(conn)

    def delete_app(self, app_id: int) -> bool:
        """删除应用"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('DELETE FROM gee_apps WHERE app_id = %s', (app_id,))
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            print(f"删除应用失败: {e}")
            return False
        finally:
            self._put_connection(conn)

    def regenerate_api_key(self, app_id: int) -> Optional[str]:
        """重新生成API Key"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            new_key = uuid.uuid4().hex
            
            cursor.execute('''
                UPDATE gee_apps 
                SET app_key = %s, updated_at = CURRENT_TIMESTAMP
                WHERE app_id = %s
            ''', (new_key, app_id))
            
            conn.commit()
            cursor.close()
            return new_key
        except Exception as e:
            conn.rollback()
            print(f"重置API Key失败: {e}")
            return None
        finally:
            self._put_connection(conn)

    def validate_api_key(self, app_key: str) -> Optional[Dict]:
        """验证API Key并返回应用信息"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT app_id, app_name, is_enabled 
                FROM gee_apps 
                WHERE app_key = %s
            ''', (app_key,))
            
            row = cursor.fetchone()
            
            if not row:
                return None
            
            if not row['is_enabled']:
                return {'error': 'App is disabled'}
                
            return {
                'app_id': row['app_id'],
                'app_name': row['app_name']
            }
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_callback_by_key(self, app_key: str) -> Optional[Dict]:
        """根据API Key获取回调地址"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT app_id, app_name, callback_url, is_enabled
                FROM gee_apps 
                WHERE app_key = %s
            ''', (app_key,))
            
            row = cursor.fetchone()
            
            if not row:
                return None
            
            if not row['is_enabled']:
                return {'error': 'App is disabled'}
                
            return {
                'appId': row['app_id'],
                'appName': row['app_name'],
                'callbackUrl': row['callback_url']
            }
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_apps_with_daily_update(self) -> List[Dict]:
        """获取启用每日更新的应用列表"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT app_id, app_name, callback_url
                FROM gee_apps 
                WHERE is_enabled = TRUE AND enable_daily_update = TRUE
            ''')
            
            rows = cursor.fetchall()
            
            return [{
                'appId': row['app_id'],
                'appName': row['app_name'],
                'callbackUrl': row['callback_url']
            } for row in rows]
        finally:
            cursor.close()
            self._put_connection(conn)
