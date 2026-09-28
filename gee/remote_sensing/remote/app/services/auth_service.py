"""认证服务 - 处理API Key验证和地块信息获取"""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Dict, Optional, List
import json
from app.config import config_manager

class AuthService:
    """认证服务"""
    
    def __init__(self):
        """初始化"""
        # 复用 ConfigManager 的连接池
        self.pool = config_manager._pool
        
    def _get_connection(self):
        """获取数据库连接"""
        return self.pool.getconn()
    
    def _put_connection(self, conn):
        """归还数据库连接"""
        self.pool.putconn(conn)
        
    def validate_app_key(self, app_key: str) -> Optional[Dict]:
        """
        验证API Key
        
        Args:
            app_key: API Key
            
        Returns:
            Dict: 应用信息 {'app_id': int, 'app_name': str} 或 None (无效)
            如果应用被禁用，返回 {'error': 'App is disabled'}
        """
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
        except Exception as e:
            print(f"❌ 验证API Key失败: {e}")
            return None
        finally:
            cursor.close()
            self._put_connection(conn)

    def get_plot_geometry(self, plot_id: int, app_id: int) -> Optional[List[List[float]]]:
        """
        获取地块几何信息
        
        Args:
            plot_id: 地块ID
            app_id: 应用ID (用于验证归属权)
            
        Returns:
            List[List[float]]: 坐标列表 [[lon, lat], ...] 或 None
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT geometry, app_id
                FROM gee_plots 
                WHERE plot_id = %s
            ''', (plot_id,))
            
            row = cursor.fetchone()
            
            if not row:
                return None
            
            # 验证归属权
            if row['app_id'] != app_id:
                raise ValueError(f"地块 {plot_id} 不属于应用 {app_id}")
            
            # 解析几何信息（支持多种格式）
            try:
                geometry = json.loads(row['geometry'])
                
                # 如果是列表，直接返回（坐标数组格式）
                if isinstance(geometry, list):
                    return geometry
                
                # 如果是字典，尝试解析GeoJSON格式
                if isinstance(geometry, dict):
                    # Polygon格式
                    if geometry.get("type") == "Polygon":
                        return geometry["coordinates"][0]
                    # Feature格式
                    elif geometry.get("type") == "Feature":
                        return geometry["geometry"]["coordinates"][0]
                    # 直接包含coordinates的格式
                    else:
                        coords = geometry.get("coordinates", [])
                        if coords and isinstance(coords[0], list):
                            return coords[0]
                        return coords
                
                return None
            except Exception as e:
                print(f"❌ 解析地块几何信息失败: {e}")
                return None
                
        except Exception as e:
            print(f"❌ 获取地块信息失败: {e}")
            raise e
        finally:
            cursor.close()
            self._put_connection(conn)
