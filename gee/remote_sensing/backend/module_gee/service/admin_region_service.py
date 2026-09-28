"""
行政区数据服务

提供行政区边界数据查询功能
"""

from typing import List, Optional, Dict, Any
from psycopg2.pool import SimpleConnectionPool
from config.env import DataBaseConfig


class AdminRegionService:
    """行政区数据服务"""
    
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
    
    def get_admin_regions(
        self, 
        level: Optional[str] = None,
        parent_adcode: Optional[str] = None,
        keyword: Optional[str] = None,
        page_num: int = 1,
        page_size: int = 100
    ) -> Dict[str, Any]:
        """
        获取行政区列表
        
        Args:
            level: 行政区级别 (province/city/district)
            parent_adcode: 父级行政区代码
            keyword: 搜索关键词
            page_num: 页码
            page_size: 每页数量
            
        Returns:
            包含行政区列表和总数的字典
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            # 构建查询条件
            conditions = []
            params = []
            
            if level:
                conditions.append("level = %s")
                params.append(level)
            
            if parent_adcode:
                conditions.append("parent_adcode = %s")
                params.append(parent_adcode)
            
            if keyword:
                conditions.append("name LIKE %s")
                params.append(f"%{keyword}%")
            
            where_clause = " AND ".join(conditions) if conditions else "1=1"
            
            # 查询总数
            count_sql = f"""
                SELECT COUNT(*) 
                FROM china_administrative_divisions 
                WHERE {where_clause}
            """
            cursor.execute(count_sql, params)
            count_result = cursor.fetchone()
            total = count_result[0] if count_result else 0
            
            # 查询数据（包含几何数据）
            offset = (page_num - 1) * page_size
            data_sql = f"""
                SELECT 
                    adcode,
                    name,
                    level,
                    parent_adcode,
                    center_lon,
                    center_lat,
                    ST_AsGeoJSON(geometry) as geometry
                FROM china_administrative_divisions
                WHERE {where_clause}
                ORDER BY adcode
                LIMIT %s OFFSET %s
            """
            cursor.execute(data_sql, params + [page_size, offset])
            
            rows = []
            for row in cursor.fetchall():
                rows.append({
                    'adcode': row[0],
                    'name': row[1],
                    'level': row[2],
                    'parentAdcode': row[3],
                    'centerLon': float(row[4]) if row[4] else None,
                    'centerLat': float(row[5]) if row[5] else None,
                    'geometry': row[6]  # GeoJSON字符串
                })
            
            cursor.close()
            
            return {
                'rows': rows,
                'total': total,
                'pageNum': page_num,
                'pageSize': page_size
            }
            
        finally:
            self.pool.putconn(conn)
    
    def get_region_with_plots_count(
        self,
        level: Optional[str] = None,
        parent_adcode: Optional[str] = None,
        page_num: int = 1,
        page_size: int = 100
    ) -> Dict[str, Any]:
        """
        获取行政区列表（包含地块统计）- 支持级联查询
        
        Args:
            level: 行政区级别（可选）
            parent_adcode: 父级行政区代码（用于查询子级）
            page_num: 页码
            page_size: 每页数量
            
        Returns:
            包含行政区和地块统计的字典
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            # 构建查询条件
            where_conditions = []
            
            if level:
                where_conditions.append(f"r.level = '{level}'")
            
            if parent_adcode:
                where_conditions.append(f"r.parent_adcode = '{parent_adcode}'")
            
            where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
            
            # 查询总数
            count_sql = f"""
                SELECT COUNT(*) 
                FROM china_administrative_divisions r
                {where_clause}
            """
            cursor.execute(count_sql)
            count_result = cursor.fetchone()
            total = count_result[0] if count_result else 0
            
            # 查询数据（关联地块统计）
            # 注意：暂时不返回 geometry 字段，因为数据量太大可能导致查询失败
            # 使用 CONCAT 而不是 ||，避免 psycopg2 参数绑定问题
            offset = (page_num - 1) * page_size
            data_sql = f"""
                SELECT 
                    r.adcode,
                    r.name,
                    r.level,
                    r.parent_adcode,
                    r.center_lon,
                    r.center_lat,
                    COUNT(DISTINCT p.plot_id) as total_plots,
                    COUNT(DISTINCT CASE WHEN p.monitor_status = 1 THEN p.plot_id END) as active_plots,
                    COUNT(DISTINCT CASE WHEN p.monitor_status = 0 THEN p.plot_id END) as paused_plots
                FROM china_administrative_divisions r
                LEFT JOIN gee_plots p ON p.adcode LIKE CONCAT(r.adcode, '%')
                {where_clause}
                GROUP BY r.adcode, r.name, r.level, r.parent_adcode, r.center_lon, r.center_lat
                ORDER BY r.adcode
                LIMIT {page_size} OFFSET {offset}
            """
            
            try:
                print(f"🔍 调试信息:")
                print(f"  level参数: {level}")
                print(f"  parent_adcode参数: {parent_adcode}")
                print(f"  page_size: {page_size}, offset: {offset}")
                print(f"  WHERE子句: {where_clause}")
                cursor.execute(data_sql)
            except Exception as e:
                print(f"❌ SQL执行错误: {e}")
                print(f"完整SQL: {data_sql}")
                raise
            
            rows = []
            for row in cursor.fetchall():
                try:
                    # 验证行数据完整性（现在期望9列，因为移除了 geometry）
                    if len(row) < 9:
                        print(f"⚠️ 警告：行数据列数不足，期望9列，实际{len(row)}列")
                        print(f"行数据: {row}")
                        continue
                    
                    rows.append({
                        'adcode': row[0],
                        'name': row[1],
                        'level': row[2],
                        'parentAdcode': row[3],
                        'centerLon': float(row[4]) if row[4] else None,
                        'centerLat': float(row[5]) if row[5] else None,
                        'geometry': None,  # 暂时不返回 geometry
                        'totalPlots': row[6] if row[6] is not None else 0,
                        'activePlots': row[7] if row[7] is not None else 0,
                        'pausedPlots': row[8] if row[8] is not None else 0
                    })
                except IndexError as e:
                    print(f"❌ 处理行数据时索引错误: {e}")
                    print(f"行数据: {row}")
                    print(f"行长度: {len(row)}")
                    continue
            
            cursor.close()
            
            return {
                'rows': rows,
                'total': total,
                'pageNum': page_num,
                'pageSize': page_size
            }
            
        finally:
            self.pool.putconn(conn)
    
    def get_region_by_adcode(self, adcode: str) -> Optional[Dict[str, Any]]:
        """
        根据行政区代码获取详情
        
        Args:
            adcode: 行政区代码
            
        Returns:
            行政区详情
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            sql = """
                SELECT 
                    adcode,
                    name,
                    level,
                    parent_adcode,
                    center_lon,
                    center_lat,
                    ST_AsGeoJSON(geometry) as geometry
                FROM china_administrative_divisions
                WHERE adcode = %s
            """
            cursor.execute(sql, (adcode,))
            
            row = cursor.fetchone()
            cursor.close()
            
            if row:
                return {
                    'adcode': row[0],
                    'name': row[1],
                    'level': row[2],
                    'parentAdcode': row[3],
                    'centerLon': float(row[4]) if row[4] else None,
                    'centerLat': float(row[5]) if row[5] else None,
                    'geometry': row[6]
                }
            return None
            
        finally:
            self.pool.putconn(conn)
    
    def search_regions(self, keyword: str, limit: int = 20) -> List[Dict[str, Any]]:
        """
        搜索行政区
        
        Args:
            keyword: 搜索关键词
            limit: 返回数量限制
            
        Returns:
            匹配的行政区列表
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            sql = """
                SELECT 
                    adcode,
                    name,
                    level,
                    parent_adcode
                FROM china_administrative_divisions
                WHERE name LIKE %s OR adcode LIKE %s
                ORDER BY 
                    CASE level
                        WHEN 'province' THEN 1
                        WHEN 'city' THEN 2
                        WHEN 'district' THEN 3
                    END,
                    name
                LIMIT %s
            """
            cursor.execute(sql, (f"%{keyword}%", f"%{keyword}%", limit))
            
            results = []
            for row in cursor.fetchall():
                results.append({
                    'adcode': row[0],
                    'name': row[1],
                    'level': row[2],
                    'parentAdcode': row[3]
                })
            
            cursor.close()
            return results
            
        finally:
            self.pool.putconn(conn)


# 创建全局服务实例
admin_region_service = AdminRegionService()
