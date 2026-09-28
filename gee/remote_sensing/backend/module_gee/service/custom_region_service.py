"""自定义预存区域服务"""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
from config.env import DataBaseConfig


class CustomRegionService:
    """自定义预存区域服务"""
    
    def __init__(self):
        self.db_config = DataBaseConfig
    
    def _get_connection(self):
        """获取数据库连接"""
        return psycopg2.connect(
            host=self.db_config.db_host,
            port=self.db_config.db_port,
            user=self.db_config.db_username,
            password=self.db_config.db_password,
            database=self.db_config.db_database
        )
    
    def get_region_list(
        self,
        page_num: int = 1,
        page_size: int = 10,
        region_name: Optional[str] = None,
        is_active: Optional[bool] = None
    ) -> Dict:
        """获取区域列表"""
        conn = self._get_connection()
        try:
            conditions = ['1=1']
            params = []
            
            if region_name:
                conditions.append("region_name LIKE %s")
                params.append(f'%{region_name}%')
            
            if is_active is not None:
                conditions.append("is_active = %s")
                params.append(is_active)
            
            where_clause = ' AND '.join(conditions)
            
            # 查询总数
            cursor = conn.cursor()
            count_query = f'SELECT COUNT(*) FROM gee_custom_regions WHERE {where_clause}'
            cursor.execute(count_query, params)
            total = cursor.fetchone()[0]
            cursor.close()
            
            # 查询数据
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            offset = (page_num - 1) * page_size
            
            query = f'''
                SELECT region_id, region_name, geometry, buffer_km, priority,
                       description, created_by, created_at, updated_at, is_active
                FROM gee_custom_regions
                WHERE {where_clause}
                ORDER BY priority DESC, created_at DESC
                LIMIT %s OFFSET %s
            '''
            
            cursor.execute(query, params + [page_size, offset])
            rows = cursor.fetchall()
            
            # 转换为驼峰命名
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'regionId': row['region_id'],
                    'regionName': row['region_name'],
                    'geometry': row['geometry'],
                    'bufferKm': float(row['buffer_km']) if row['buffer_km'] else 5.0,
                    'priority': row['priority'],
                    'description': row['description'],
                    'createdBy': row['created_by'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None,
                    'isActive': row['is_active']
                })
            
            return {'rows': camel_rows, 'total': total}
        finally:
            conn.close()
    
    def get_region_by_id(self, region_id: int) -> Optional[Dict]:
        """根据ID获取区域"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT region_id, region_name, geometry, buffer_km, priority,
                       description, created_by, created_at, updated_at, is_active
                FROM gee_custom_regions
                WHERE region_id = %s
            ''', (region_id,))
            row = cursor.fetchone()
            
            if not row:
                return None
            
            return {
                'regionId': row['region_id'],
                'regionName': row['region_name'],
                'geometry': row['geometry'],
                'bufferKm': float(row['buffer_km']) if row['buffer_km'] else 5.0,
                'priority': row['priority'],
                'description': row['description'],
                'createdBy': row['created_by'],
                'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None,
                'isActive': row['is_active']
            }
        finally:
            conn.close()
    
    def create_region(
        self,
        region_name: str,
        geometry: str,
        buffer_km: float = 5.0,
        priority: int = 0,
        description: Optional[str] = None,
        created_by: Optional[str] = None
    ) -> bool:
        """创建自定义区域"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO gee_custom_regions 
                (region_name, geometry, buffer_km, priority, description, created_by)
                VALUES (%s, %s, %s, %s, %s, %s)
            ''', (region_name, geometry, buffer_km, priority, description, created_by))
            conn.commit()
            return True
        except Exception as e:
            conn.rollback()
            print(f"创建区域失败: {e}")
            return False
        finally:
            conn.close()
    
    def update_region(
        self,
        region_id: int,
        region_name: str,
        geometry: str,
        buffer_km: float,
        priority: int,
        description: Optional[str]
    ) -> bool:
        """更新区域"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE gee_custom_regions
                SET region_name = %s, geometry = %s, buffer_km = %s,
                    priority = %s, description = %s, updated_at = CURRENT_TIMESTAMP
                WHERE region_id = %s
            ''', (region_name, geometry, buffer_km, priority, description, region_id))
            conn.commit()
            return True
        except Exception as e:
            conn.rollback()
            print(f"更新区域失败: {e}")
            return False
        finally:
            conn.close()
    
    def delete_region(self, region_id: int) -> bool:
        """删除区域（软删除）"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(
                'UPDATE gee_custom_regions SET is_active = FALSE WHERE region_id = %s',
                (region_id,)
            )
            conn.commit()
            return True
        except Exception as e:
            conn.rollback()
            print(f"删除区域失败: {e}")
            return False
        finally:
            conn.close()
