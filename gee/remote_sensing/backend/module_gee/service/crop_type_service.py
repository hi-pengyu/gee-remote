"""
作物类型服务

提供作物类型字典管理功能
"""

from typing import List, Optional, Dict, Any
from psycopg2.pool import SimpleConnectionPool
from config.env import DataBaseConfig


class CropTypeService:
    """作物类型服务"""
    
    def __init__(self):
        """初始化数据库连接池"""
        self.pool = SimpleConnectionPool(
            1, 10,
            host=DataBaseConfig.db_host,
            port=DataBaseConfig.db_port,
            user=DataBaseConfig.db_username,
            password=DataBaseConfig.db_password,
            database=DataBaseConfig.db_database
        )
    
    def get_all_crop_types(self, status: Optional[str] = '0') -> List[Dict[str, Any]]:
        """
        获取所有作物类型
        
        Args:
            status: 状态筛选 (0=正常 1=停用 None=全部)
            
        Returns:
            作物类型列表
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            if status is not None:
                sql = """
                    SELECT crop_code, crop_name, monitor_start_date, monitor_end_date,
                           description, sort_order, status
                    FROM gee_crop_types
                    WHERE status = %s
                    ORDER BY sort_order, crop_code
                """
                cursor.execute(sql, (status,))
            else:
                sql = """
                    SELECT crop_code, crop_name, monitor_start_date, monitor_end_date,
                           description, sort_order, status
                    FROM gee_crop_types
                    ORDER BY sort_order, crop_code
                """
                cursor.execute(sql)
            
            results = []
            for row in cursor.fetchall():
                # 构建监测周期字符串
                period = None
                if row[2] and row[3]:
                    period = f"{row[2]} ~ {row[3]}"
                
                results.append({
                    'cropCode': row[0],
                    'cropName': row[1],
                    'monitorStartDate': row[2],
                    'monitorEndDate': row[3],
                    'period': period,
                    'description': row[4],
                    'sortOrder': row[5],
                    'status': row[6]
                })
            
            cursor.close()
            return results
            
        finally:
            self.pool.putconn(conn)
    
    def get_crop_type_by_code(self, crop_code: str) -> Optional[Dict[str, Any]]:
        """
        根据代码获取作物类型
        
        Args:
            crop_code: 作物代码
            
        Returns:
            作物类型信息
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            sql = """
                SELECT crop_code, crop_name, monitor_start_date, monitor_end_date,
                       description, sort_order, status
                FROM gee_crop_types
                WHERE crop_code = %s
            """
            cursor.execute(sql, (crop_code,))
            
            row = cursor.fetchone()
            cursor.close()
            
            if row:
                period = None
                if row[2] and row[3]:
                    period = f"{row[2]} ~ {row[3]}"
                
                return {
                    'cropCode': row[0],
                    'cropName': row[1],
                    'monitorStartDate': row[2],
                    'monitorEndDate': row[3],
                    'period': period,
                    'description': row[4],
                    'sortOrder': row[5],
                    'status': row[6]
                }
            return None
            
        finally:
            self.pool.putconn(conn)


# 创建全局服务实例
crop_type_service = CropTypeService()
