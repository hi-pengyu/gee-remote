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
from config.env import DataBaseConfig


class TileManager:
    """瓦片管理器 - 使用PostgreSQL"""
    
    # 连接池
    _pool = None
    
    def __init__(self):
        """
        初始化瓦片管理器
        """
        self.tile_size_km = 5  # 默认5km
        self.tile_size_deg = self.tile_size_km / 111.0  # 粗略转换为度数
        self.cache_days = 14  # 默认14天
        
        # 初始化连接池
        if TileManager._pool is None:
            TileManager._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=DataBaseConfig.db_host,
                port=DataBaseConfig.db_port,
                user=DataBaseConfig.db_username,
                password=DataBaseConfig.db_password,
                database=DataBaseConfig.db_database
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
                'actual_size_gb': float(total_size) / (1024 * 1024 * 1024),
                'total_accesses': total_accesses,
                'cache_hit_potential': f"{((total_tiles - expired_tiles) / max(total_tiles, 1) * 100):.1f}%"
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_tile_list(self, page_num: int = 1, page_size: int = 10, 
                      tile_id: str = None, date_acquired: str = None, status: str = None) -> Dict:
        """
        获取瓦片列表(分页)
        
        Args:
            page_num: 页码
            page_size: 每页数量
            tile_id: 瓦片ID筛选
            date_acquired: 日期筛选
            status: 状态筛选
            
        Returns:
            {'rows': [...], 'total': int}
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 构建查询条件
            conditions = []
            params = []
            
            if tile_id:
                conditions.append("tile_id LIKE %s")
                params.append(f"%{tile_id}%")
            
            if date_acquired:
                conditions.append("date_acquired = %s")
                params.append(date_acquired)
            
            if status is not None:
                conditions.append("status = %s")
                params.append(status)
            
            where_clause = " AND ".join(conditions) if conditions else "1=1"
            
            # 查询总数
            cursor.execute(f'SELECT COUNT(*) FROM gee_tiles WHERE {where_clause}', params)
            total = cursor.fetchone()[0]
            
            # 查询数据
            offset = (page_num - 1) * page_size
            query = f'''
                SELECT tile_id, tile_x, tile_y, center_lon, center_lat, 
                       date_acquired, cloud_cover, file_size, access_count, 
                       last_access, expires_at, status, created_at, updated_at
                FROM gee_tiles 
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
                    'tileId': row['tile_id'],
                    'tileX': row['tile_x'],
                    'tileY': row['tile_y'],
                    'centerLon': float(row['center_lon']) if row['center_lon'] else None,
                    'centerLat': float(row['center_lat']) if row['center_lat'] else None,
                    'dateAcquired': str(row['date_acquired']) if row['date_acquired'] else None,
                    'cloudCover': float(row['cloud_cover']) if row['cloud_cover'] else None,
                    'fileSize': row['file_size'],
                    'accessCount': row['access_count'],
                    'lastAccess': row['last_access'].isoformat() if row['last_access'] else None,
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'expiresAt': row['expires_at'].isoformat() if row['expires_at'] else None,
                    'status': row['status']
                })
            
            return {
                'rows': camel_rows,
                'total': total
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
