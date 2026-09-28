"""GEE配置管理服务"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
import json
from config.env import DataBaseConfig


class GeeConfigService:
    """GEE配置管理服务"""
    
    _pool = None
    
    def __init__(self):
        """初始化服务"""
        if GeeConfigService._pool is None:
            db_config = DataBaseConfig
            GeeConfigService._pool = SimpleConnectionPool(
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
        return GeeConfigService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接"""
        GeeConfigService._pool.putconn(conn)
    
    def get_config_list(
        self,
        page_num: int = 1,
        page_size: int = 10,
        config_key: str = None,
        config_group: str = None
    ) -> Dict:
        """获取配置列表"""
        conn = self._get_connection()
        try:
            conditions = ['1=1']
            params = []
            
            if config_key:
                conditions.append("config_key LIKE %s")
                params.append(f'%{config_key}%')
            
            if config_group:
                conditions.append("config_group = %s")
                params.append(config_group)
            
            where_clause = ' AND '.join(conditions)
            
            # 查询总数
            cursor = conn.cursor()
            count_query = f'SELECT COUNT(*) FROM gee_config WHERE {where_clause}'
            cursor.execute(count_query, params)
            count_result = cursor.fetchone()
            total = count_result[0] if count_result else 0
            cursor.close()
            
            # 查询数据
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            offset = (page_num - 1) * page_size
            
            query = f'''
                SELECT 
                    config_id, config_key, config_value, config_type,
                    config_group, description, is_encrypted, is_enabled,
                    created_at, created_by, updated_at, updated_by, remark
                FROM gee_config
                WHERE {where_clause}
                ORDER BY config_group, config_key
                LIMIT %s OFFSET %s
            '''
            
            cursor.execute(query, params + [page_size, offset])
            rows = cursor.fetchall()
            
            # 转换为驼峰命名
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'configId': row['config_id'],
                    'configKey': row['config_key'],
                    'configValue': row['config_value'],
                    'configType': row['config_type'],
                    'configGroup': row['config_group'],
                    'description': row['description'],
                    'isEncrypted': row['is_encrypted'],
                    'isEnabled': row['is_enabled'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'createdBy': row['created_by'],
                    'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None,
                    'updatedBy': row['updated_by'],
                    'remark': row['remark']
                })
            
            return {
                'rows': camel_rows,
                'total': total
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_config_by_key(self, config_key: str) -> Optional[Dict]:
        """根据键获取配置"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT * FROM gee_config WHERE config_key = %s
            ''', (config_key,))
            
            row = cursor.fetchone()
            if not row:
                return None
            
            return {
                'configId': row['config_id'],
                'configKey': row['config_key'],
                'configValue': row['config_value'],
                'configType': row['config_type'],
                'configGroup': row['config_group'],
                'description': row['description'],
                'isEncrypted': row['is_encrypted'],
                'isEnabled': row['is_enabled'],
                'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                'createdBy': row['created_by'],
                'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None,
                'updatedBy': row['updated_by'],
                'remark': row['remark']
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def update_config(
        self,
        config_key: str,
        config_value: str,
        updated_by: str = 'admin'
    ) -> bool:
        """更新配置"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE gee_config 
                SET config_value = %s, updated_by = %s, updated_at = CURRENT_TIMESTAMP
                WHERE config_key = %s
            ''', (config_value, updated_by, config_key))
            
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            print(f"配置更新失败: {e}")
            return False
        finally:
            self._put_connection(conn)
    
    def get_groups(self) -> List[str]:
        """获取所有配置分组"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT DISTINCT config_group 
                FROM gee_config 
                ORDER BY config_group
            ''')
            
            groups = [row[0] for row in cursor.fetchall()]
            cursor.close()
            return groups
            
        finally:
            self._put_connection(conn)
