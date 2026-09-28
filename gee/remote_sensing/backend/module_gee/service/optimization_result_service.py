"""优化结果历史服务 - 使用直接SQL查询"""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import List, Optional, Dict, Any
from datetime import date, datetime
from config.env import DataBaseConfig
from utils.log_util import logger


class OptimizationResultService:
    """优化结果历史服务"""
    
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
    
    def save_result(
        self,
        calculation_date: date,
        buffer_km: float,
        include_custom_regions: bool,
        regions: List[Dict[str, Any]],
        created_by: Optional[str] = None
    ) -> Dict[str, Any]:
        """保存优化结果"""
        
        # 计算统计信息
        total_regions = len(regions)
        optimized_count = sum(1 for r in regions if r.get('type') == 'optimized')
        custom_count = sum(1 for r in regions if r.get('type') == 'custom')
        
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 检查是否已存在
            cursor.execute("""
                SELECT id FROM gee_optimization_result 
                WHERE calculation_date = %s AND buffer_km = %s
            """, (calculation_date, buffer_km))
            
            existing = cursor.fetchone()
            
            if existing:
                # 更新现有记录
                cursor.execute("""
                    UPDATE gee_optimization_result 
                    SET include_custom_regions = %s,
                        total_regions = %s,
                        optimized_region_count = %s,
                        custom_region_count = %s,
                        regions_data = %s::jsonb,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    RETURNING id
                """, (
                    include_custom_regions,
                    total_regions,
                    optimized_count,
                    custom_count,
                    psycopg2.extras.Json(regions),
                    existing['id']
                ))
                result_id = cursor.fetchone()['id']
                logger.info(f"更新优化结果: {calculation_date}, buffer={buffer_km}km")
            else:
                # 创建新记录
                cursor.execute("""
                    INSERT INTO gee_optimization_result (
                        calculation_date, buffer_km, include_custom_regions,
                        total_regions, optimized_region_count, custom_region_count,
                        regions_data, status, created_by
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s::jsonb, %s, %s)
                    RETURNING id
                """, (
                    calculation_date,
                    buffer_km,
                    include_custom_regions,
                    total_regions,
                    optimized_count,
                    custom_count,
                    psycopg2.extras.Json(regions),
                    'calculated',
                    created_by
                ))
                result_id = cursor.fetchone()['id']
                logger.info(f"保存新优化结果: {calculation_date}, buffer={buffer_km}km")
            
            conn.commit()
            return {'id': result_id}
            
        except Exception as e:
            conn.rollback()
            logger.error(f"保存优化结果失败: {e}")
            raise
        finally:
            conn.close()
    
    def get_history(
        self,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        status: Optional[str] = None,
        page_num: int = 1,
        page_size: int = 10
    ) -> tuple[List[Dict], int]:
        """获取历史记录"""
        
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 构建查询条件
            conditions = []
            params = []
            
            if start_date:
                conditions.append("calculation_date >= %s")
                params.append(start_date)
            if end_date:
                conditions.append("calculation_date <= %s")
                params.append(end_date)
            if status:
                conditions.append("status = %s")
                params.append(status)
            
            where_clause = " AND ".join(conditions) if conditions else "1=1"
            
            # 查询总数
            cursor.execute(f"""
                SELECT COUNT(*) as total 
                FROM gee_optimization_result 
                WHERE {where_clause}
            """, params)
            total = cursor.fetchone()['total']
            
            # 分页查询
            offset = (page_num - 1) * page_size
            cursor.execute(f"""
                SELECT id, calculation_date, buffer_km, include_custom_regions,
                       total_regions, optimized_region_count, custom_region_count,
                       optimization_rate, status, created_at, created_by
                FROM gee_optimization_result 
                WHERE {where_clause}
                ORDER BY calculation_date DESC
                LIMIT %s OFFSET %s
            """, params + [page_size, offset])
            
            records = cursor.fetchall()
            return records, total
            
        except Exception as e:
            logger.error(f"查询历史记录失败: {e}")
            raise
        finally:
            conn.close()
    
    def get_by_id(self, result_id: int) -> Optional[Dict]:
        """根据ID获取记录"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute("""
                SELECT * FROM gee_optimization_result WHERE id = %s
            """, (result_id,))
            return cursor.fetchone()
        except Exception as e:
            logger.error(f"查询记录失败: {e}")
            raise
        finally:
            conn.close()
    
    def update_status(self, result_id: int, status: str) -> bool:
        """更新状态"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE gee_optimization_result 
                SET status = %s, updated_at = CURRENT_TIMESTAMP
                WHERE id = %s
            """, (status, result_id))
            conn.commit()
            logger.info(f"更新优化结果状态: ID={result_id}, status={status}")
            return True
        except Exception as e:
            conn.rollback()
            logger.error(f"更新状态失败: {e}")
            return False
        finally:
            conn.close()


# 创建全局实例
optimization_result_service = OptimizationResultService()
