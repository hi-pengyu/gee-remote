"""瓦片管理器 - 负责瓦片网格计算和缓存管理 (PostgreSQL版本)"""
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from psycopg2.pool import SimpleConnectionPool
from datetime import datetime, timedelta
from typing import List, Tuple, Optional, Dict
from pathlib import Path
import math
from shapely.geometry import Polygon, box
from app.config import settings


class TileManager:
    """瓦片管理器 - 使用PostgreSQL"""
    
    # 连接池
    _pool = None
    
    def __init__(self):
        """
        初始化瓦片管理器
        """
        self.tile_size_km = getattr(settings, 'TILE_SIZE_KM', 5)  # 默认5km
        self.tile_size_deg = self.tile_size_km / 111.0  # 粗略转换为度数
        self.cache_days = getattr(settings, 'TILE_CACHE_DAYS', 14)  # 默认14天
        
        # 初始化连接池
        if TileManager._pool is None:
            TileManager._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=settings.DB_HOST,
                port=settings.DB_PORT,
                user=settings.DB_USER,
                password=settings.DB_PASSWORD,
                database=settings.DB_DATABASE
            )
        
        # 初始化数据库表
        self._init_database()
    
    def _get_connection(self):
        """从连接池获取连接"""
        return TileManager._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接到连接池"""
        TileManager._pool.putconn(conn)
    
    def _init_database(self):
        """初始化PostgreSQL数据库表 (表已通过SQL文件创建,这里仅验证)"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 验证表是否存在
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = 'gee_tiles'
                )
            """)
            
            exists = cursor.fetchone()[0]
            if exists:
                print(f"[TileManager] 表 gee_tiles 已存在,使用现有表结构")
            else:
                print(f"[TileManager] ⚠️  表 gee_tiles 不存在,请先运行 sql/gee_tables.sql")
            
        except Exception as e:
            print(f"[TileManager] 数据库验证失败: {e}")
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_tile_id(self, lon: float, lat: float) -> str:
        """
        根据经纬度计算瓦片ID
        
        Args:
            lon: 经度
            lat: 纬度
            
        Returns:
            瓦片ID (格式: "tile_x_y")
        """
        tile_x = math.floor(lon / self.tile_size_deg)
        tile_y = math.floor(lat / self.tile_size_deg)
        return f"tile_{tile_x}_{tile_y}"
    
    def get_tile_coords(self, tile_id: str) -> Tuple[int, int]:
        """
        从瓦片ID解析瓦片坐标
        
        Args:
            tile_id: 瓦片ID
            
        Returns:
            (tile_x, tile_y)
        """
        parts = tile_id.split('_')
        return int(parts[1]), int(parts[2])
    
    def get_tile_bounds(self, tile_id: str) -> Dict[str, float]:
        """
        获取瓦片的地理边界
        
        Args:
            tile_id: 瓦片ID
            
        Returns:
            {'min_lon', 'min_lat', 'max_lon', 'max_lat', 'center_lon', 'center_lat'}
        """
        tile_x, tile_y = self.get_tile_coords(tile_id)
        
        min_lon = tile_x * self.tile_size_deg
        min_lat = tile_y * self.tile_size_deg
        max_lon = (tile_x + 1) * self.tile_size_deg
        max_lat = (tile_y + 1) * self.tile_size_deg
        
        center_lon = (min_lon + max_lon) / 2
        center_lat = (min_lat + max_lat) / 2
        
        return {
            'min_lon': min_lon,
            'min_lat': min_lat,
            'max_lon': max_lon,
            'max_lat': max_lat,
            'center_lon': center_lon,
            'center_lat': center_lat
        }
    
    def get_tile_for_polygon(self, coords: List[List[float]]) -> List[str]:
        """
        计算多边形覆盖的所有瓦片
        
        Args:
            coords: 多边形坐标 [[lon, lat], ...]
            
        Returns:
            瓦片ID列表
        """
        # 计算多边形边界
        lons = [coord[0] for coord in coords]
        lats = [coord[1] for coord in coords]
        
        min_lon, max_lon = min(lons), max(lons)
        min_lat, max_lat = min(lats), max(lats)
        
        # 计算覆盖的瓦片范围
        min_tile_x = math.floor(min_lon / self.tile_size_deg)
        max_tile_x = math.floor(max_lon / self.tile_size_deg)
        min_tile_y = math.floor(min_lat / self.tile_size_deg)
        max_tile_y = math.floor(max_lat / self.tile_size_deg)
        
        # 生成所有瓦片ID
        tile_ids = []
        for tx in range(min_tile_x, max_tile_x + 1):
            for ty in range(min_tile_y, max_tile_y + 1):
                tile_ids.append(f"tile_{tx}_{ty}")
        
        return tile_ids
    
    def get_adjacent_tiles(self, tile_id: str, include_diagonals: bool = True) -> List[str]:
        """
        获取相邻瓦片
        
        Args:
            tile_id: 中心瓦片ID
            include_diagonals: 是否包含对角线瓦片(8邻域 vs 4邻域)
            
        Returns:
            相邻瓦片ID列表
        """
        tile_x, tile_y = self.get_tile_coords(tile_id)
        
        adjacent = []
        
        if include_diagonals:
            # 8邻域
            for dx in [-1, 0, 1]:
                for dy in [-1, 0, 1]:
                    if dx == 0 and dy == 0:
                        continue
                    adjacent.append(f"tile_{tile_x + dx}_{tile_y + dy}")
        else:
            # 4邻域
            adjacent = [
                f"tile_{tile_x - 1}_{tile_y}",
                f"tile_{tile_x + 1}_{tile_y}",
                f"tile_{tile_x}_{tile_y - 1}",
                f"tile_{tile_x}_{tile_y + 1}"
            ]
        
        return adjacent
    
    def check_tile_cache(
        self, 
        tile_id: str, 
        target_date: str,
        max_age_days: Optional[int] = None,
        window_days: int = 10
    ) -> Optional[Dict]:
        """
        检查瓦片缓存状态
        
        Args:
            tile_id: 瓦片ID
            target_date: 目标日期 (YYYY-MM-DD)
            max_age_days: 最大缓存天数(None使用默认值)
            window_days: 日期搜索窗口(天)
            
        Returns:
            瓦片信息字典,如果不存在或已过期返回None
        """
        if max_age_days is None:
            max_age_days = self.cache_days
        
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 首先尝试精确匹配 (status='0'表示正常)
            cursor.execute('''
                SELECT * FROM gee_tiles 
                WHERE tile_id = %s 
                AND date_acquired = %s
                AND status = '0'
                AND expires_at > %s
            ''', (tile_id, target_date, datetime.now()))
            
            row = cursor.fetchone()
            
            # 如果精确匹配失败,查找日期窗口内最接近的瓦片
            if not row:
                from datetime import datetime as dt
                target_dt = dt.strptime(target_date, '%Y-%m-%d')
                min_date = (target_dt - timedelta(days=window_days)).strftime('%Y-%m-%d')
                max_date = (target_dt + timedelta(days=window_days)).strftime('%Y-%m-%d')
                
                cursor.execute('''
                    SELECT * FROM gee_tiles 
                    WHERE tile_id = %s 
                    AND date_acquired BETWEEN %s AND %s
                    AND status = '0'
                    AND expires_at > %s
                    ORDER BY ABS(date_acquired - %s::date)
                    LIMIT 1
                ''', (tile_id, min_date, max_date, datetime.now(), target_date))
                
                row = cursor.fetchone()
            
            if not row:
                return None
            
            # 转换为字典
            tile_info = dict(row)
            
            # 检查是否过期
            expires_at = tile_info['expires_at']
            if datetime.now() > expires_at:
                tile_info['is_expired'] = True
                return None  # 过期的瓦片视为不存在
            else:
                tile_info['is_expired'] = False
            
            return tile_info
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def register_tile(
        self,
        tile_id: str,
        file_path: str,
        date_acquired: str,
        cloud_cover: float = 0.0,
        file_size: Optional[int] = None
    ) -> bool:
        """
        注册新瓦片到数据库
        
        Args:
            tile_id: 瓦片ID
            file_path: 文件路径
            date_acquired: 影像获取日期
            cloud_cover: 云量
            file_size: 文件大小(字节)
            
        Returns:
            是否成功
        """
        bounds = self.get_tile_bounds(tile_id)
        tile_x, tile_y = self.get_tile_coords(tile_id)
        
        now = datetime.now()
        expires_at = now + timedelta(days=self.cache_days)
        
        # 如果未提供文件大小,尝试获取
        if file_size is None and os.path.exists(file_path):
            file_size = os.path.getsize(file_path)
        
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO gee_tiles (
                    tile_id, tile_x, tile_y,
                    center_lon, center_lat,
                    min_lon, min_lat, max_lon, max_lat,
                    file_path, created_at, updated_at, expires_at,
                    date_acquired, cloud_cover, file_size, status,
                    create_by, update_by
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (tile_id) DO UPDATE SET
                    file_path = EXCLUDED.file_path,
                    updated_at = EXCLUDED.updated_at,
                    expires_at = EXCLUDED.expires_at,
                    date_acquired = EXCLUDED.date_acquired,
                    cloud_cover = EXCLUDED.cloud_cover,
                    file_size = EXCLUDED.file_size,
                    status = EXCLUDED.status,
                    update_by = EXCLUDED.update_by
            ''', (
                tile_id, tile_x, tile_y,
                bounds['center_lon'], bounds['center_lat'],
                bounds['min_lon'], bounds['min_lat'],
                bounds['max_lon'], bounds['max_lat'],
                file_path, now, now, expires_at,
                date_acquired, cloud_cover, file_size, '0',  # status='0'表示正常
                'system', 'system'  # create_by, update_by
            ))
            
            conn.commit()
            print(f"[TileManager] 瓦片已注册: {tile_id} ({date_acquired})")
            return True
            
        except Exception as e:
            print(f"[TileManager] 注册瓦片失败: {e}")
            conn.rollback()
            return False
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def mark_tile_accessed(self, tile_id: str, date_acquired: str):
        """
        标记瓦片被访问,更新统计信息
        
        Args:
            tile_id: 瓦片ID
            date_acquired: 影像日期
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE gee_tiles 
                SET access_count = access_count + 1,
                    last_access = %s
                WHERE tile_id = %s AND date_acquired = %s
            ''', (datetime.now(), tile_id, date_acquired))
            
            conn.commit()
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_expired_tiles(self, limit: int = 100) -> List[Dict]:
        """
        获取已过期的瓦片列表
        
        Args:
            limit: 最大返回数量
            
        Returns:
            过期瓦片列表
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            cursor.execute('''
                SELECT * FROM gee_tiles 
                WHERE expires_at < %s AND status = '0'
                ORDER BY access_count DESC, last_access DESC
                LIMIT %s
            ''', (datetime.now(), limit))
            
            rows = cursor.fetchall()
            return [dict(row) for row in rows]
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_hot_tiles(self, limit: int = 50) -> List[Dict]:
        """
        获取热点瓦片(高频访问)
        
        Args:
            limit: 最大返回数量
            
        Returns:
            热点瓦片列表
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            cursor.execute('''
                SELECT * FROM gee_tiles 
                WHERE status = '0'
                ORDER BY access_count DESC, last_access DESC
                LIMIT %s
            ''', (limit,))
            
            rows = cursor.fetchall()
            return [dict(row) for row in rows]
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_cache_stats(self) -> Dict:
        """
        获取缓存统计信息
        
        Returns:
            统计信息字典
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 总瓦片数 (status='0'表示正常)
            cursor.execute('SELECT COUNT(*) FROM gee_tiles WHERE status = %s', ('0',))
            total_tiles = cursor.fetchone()[0]
            
            # 过期瓦片数
            cursor.execute('SELECT COUNT(*) FROM gee_tiles WHERE expires_at < %s AND status = %s', 
                          (datetime.now(), '0'))
            expired_tiles = cursor.fetchone()[0]
            
            # 总文件大小
            cursor.execute('SELECT COALESCE(SUM(file_size), 0) FROM gee_tiles WHERE status = %s', ('0',))
            total_size = cursor.fetchone()[0]
            
            # 总访问次数
            cursor.execute('SELECT COALESCE(SUM(access_count), 0) FROM gee_tiles WHERE status = %s', ('0',))
            total_accesses = cursor.fetchone()[0]
            
            return {
                'total_tiles': total_tiles,
                'active_tiles': total_tiles - expired_tiles,
                'expired_tiles': expired_tiles,
                'total_size_mb': total_size / (1024 * 1024),
                'total_accesses': total_accesses,
                'cache_hit_potential': f"{((total_tiles - expired_tiles) / max(total_tiles, 1) * 100):.1f}%"
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def cleanup_old_tiles(self, keep_days: int = 30) -> int:
        """
        清理旧瓦片
        
        Args:
            keep_days: 保留最近N天的瓦片
            
        Returns:
            清理的瓦片数量
        """
        cutoff_date = datetime.now() - timedelta(days=keep_days)
        
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 查找要删除的瓦片
            cursor.execute('''
                SELECT file_path FROM gee_tiles 
                WHERE updated_at < %s AND status = '0'
            ''', (cutoff_date,))
            
            files_to_delete = [row[0] for row in cursor.fetchall()]
            
            # 标记为已删除 (status='1'表示删除)
            cursor.execute('''
                UPDATE gee_tiles 
                SET status = '1', update_by = 'system', updated_at = %s
                WHERE updated_at < %s AND status = '0'
            ''', (datetime.now(), cutoff_date))
            
            conn.commit()
            deleted_count = cursor.rowcount
            
            # 删除物理文件
            for file_path in files_to_delete:
                try:
                    if os.path.exists(file_path):
                        os.remove(file_path)
                        print(f"[TileManager] 已删除文件: {file_path}")
                except Exception as e:
                    print(f"[TileManager] 删除文件失败 {file_path}: {e}")
            
            print(f"[TileManager] 清理完成,删除 {deleted_count} 个瓦片")
            return deleted_count
            
        finally:
            cursor.close()
            self._put_connection(conn)
