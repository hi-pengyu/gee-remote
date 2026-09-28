"""GEE账号池服务 - 简化版（仅用户认证）"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
from config.env import DataBaseConfig


class AccountService:
    """GEE账号池服务类"""
    
    _pool = None
    
    def __init__(self):
        """初始化数据库连接池"""
        if AccountService._pool is None:
            db_config = DataBaseConfig
            AccountService._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=db_config.db_host,
                port=db_config.db_port,
                user=db_config.db_username,
                password=db_config.db_password,
                database=db_config.db_database
            )
    
    def _get_connection(self):
        """获取数据库连接"""
        return AccountService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还数据库连接"""
        AccountService._pool.putconn(conn)
    
    def get_account_list(
        self,
        page_num: int = 1,
        page_size: int = 10,
        account_name: Optional[str] = None,
        is_active: Optional[bool] = None
    ) -> Dict:
        """获取账号列表"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 构建查询条件
            conditions = []
            params = []
            
            if account_name:
                conditions.append("account_name LIKE %s")
                params.append(f"%{account_name}%")
            
            if is_active is not None:
                conditions.append("is_active = %s")
                params.append(is_active)
            
            where_clause = " AND ".join(conditions) if conditions else "1=1"
            
            # 查询总数
            count_sql = f"SELECT COUNT(*) as total FROM gee_accounts WHERE {where_clause}"
            cursor.execute(count_sql, params)
            total = cursor.fetchone()['total']
            
            # 查询列表
            offset = (page_num - 1) * page_size
            list_sql = f"""
                SELECT * FROM gee_accounts 
                WHERE {where_clause}
                ORDER BY priority DESC, account_id ASC
                LIMIT %s OFFSET %s
            """
            cursor.execute(list_sql, params + [page_size, offset])
            rows = cursor.fetchall()
            
            cursor.close()
            
            return {
                'rows': [dict(row) for row in rows],
                'total': total
            }
        finally:
            self._put_connection(conn)
    
    def get_account_by_id(self, account_id: int) -> Optional[Dict]:
        """根据ID获取账号详情"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute("SELECT * FROM gee_accounts WHERE account_id = %s", (account_id,))
            row = cursor.fetchone()
            cursor.close()
            
            return dict(row) if row else None
        finally:
            self._put_connection(conn)
    
    def create_account(
        self,
        account_name: str,
        project_id: str,
        credentials_json: str,
        drive_token_json: Optional[str] = None,
        drive_folder_id: Optional[str] = None,
        priority: int = 0,
        description: Optional[str] = None,
        **kwargs  # 忽略其他参数
    ) -> bool:
        """创建账号"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            sql = """
                INSERT INTO gee_accounts 
                (account_name, project_id, credentials_json, drive_token_json, drive_folder_id, priority, description)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                account_name, project_id, credentials_json, drive_token_json, drive_folder_id, priority, description
            ))
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            self._put_connection(conn)
    
    def update_account(
        self,
        account_id: int,
        account_name: str,
        project_id: str,
        credentials_json: Optional[str] = None,
        drive_token_json: Optional[str] = None,
        drive_folder_id: Optional[str] = None,
        priority: int = 0,
        is_active: bool = True,
        description: Optional[str] = None,
        **kwargs  # 忽略其他参数
    ) -> bool:
        """更新账号"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            sql = """
                UPDATE gee_accounts 
                SET account_name = %s, project_id = %s, credentials_json = %s,
                    drive_token_json = %s, drive_folder_id = %s,
                    priority = %s, is_active = %s, description = %s, 
                    updated_at = CURRENT_TIMESTAMP
                WHERE account_id = %s
            """
            cursor.execute(sql, (
                account_name, project_id, credentials_json, drive_token_json, drive_folder_id,
                priority, is_active, description, account_id
            ))
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            self._put_connection(conn)
    
    def delete_account(self, account_id: int) -> bool:
        """删除账号"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM gee_accounts WHERE account_id = %s", (account_id,))
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            self._put_connection(conn)
    
    def get_account_stats(self) -> Dict:
        """获取账号统计信息"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            sql = """
                SELECT 
                    COUNT(*) as total_accounts,
                    COUNT(*) FILTER (WHERE is_active = TRUE) as active_accounts
                FROM gee_accounts
            """
            cursor.execute(sql)
            stats = cursor.fetchone()
            cursor.close()
            
            return dict(stats) if stats else {}
        finally:
            self._put_connection(conn)
