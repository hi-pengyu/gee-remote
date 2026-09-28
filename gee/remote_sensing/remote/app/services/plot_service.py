"""地块管理服务 - 负责地块数据的创建和查询"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from typing import Optional, Dict, Any
import json
from app.config import settings
from app.utils.logger import api_logger


class PlotService:
    """地块管理服务"""
    
    # 连接池
    _pool = None
    
    def __init__(self):
        """初始化服务"""
        if PlotService._pool is None:
            PlotService._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=5,
                host=settings.DB_HOST,
                port=settings.DB_PORT,
                user=settings.DB_USER,
                password=settings.DB_PASSWORD,
                database=settings.DB_DATABASE
            )
    
    def _get_connection(self):
        """从连接池获取连接"""
        return PlotService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接到连接池"""
        PlotService._pool.putconn(conn)
    
    def get_plot_by_name(self, app_id: int, plot_name: str) -> Optional[Dict[str, Any]]:
        """
        根据应用ID和地块名称查询地块
        
        Args:
            app_id: 应用ID
            plot_name: 地块名称
            
        Returns:
            地块信息字典，如果不存在则返回None
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT plot_id, app_id, plot_name, geometry, description, created_at, updated_at
                FROM gee_plots
                WHERE app_id = %s AND plot_name = %s
            ''', (app_id, plot_name))
            
            row = cursor.fetchone()
            cursor.close()
            
            if not row:
                return None
            
            return {
                'plot_id': row[0],
                'app_id': row[1],
                'plot_name': row[2],
                'geometry': row[3],
                'description': row[4],
                'created_at': row[5],
                'updated_at': row[6]
            }
            
        except Exception as e:
            api_logger.error(f"[PlotService] 查询地块失败: {e}")
            return None
        finally:
            self._put_connection(conn)
    
    def create_plot(
        self,
        app_id: int,
        plot_name: str,
        geometry: list,
        description: str = None
    ) -> Optional[int]:
        """
        创建新地块
        
        Args:
            app_id: 应用ID
            plot_name: 地块名称
            geometry: 地块几何信息（坐标列表）
            description: 地块描述
            
        Returns:
            新创建的地块ID，失败返回None
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 将坐标列表转换为JSON字符串
            geometry_json = json.dumps(geometry)
            
            cursor.execute('''
                INSERT INTO gee_plots (app_id, plot_name, geometry, description)
                VALUES (%s, %s, %s, %s)
                RETURNING plot_id
            ''', (app_id, plot_name, geometry_json, description))
            
            plot_id = cursor.fetchone()[0]
            conn.commit()
            cursor.close()
            
            api_logger.info(f"[PlotService] 创建地块成功 | Plot ID: {plot_id} | 名称: {plot_name}")
            return plot_id
            
        except Exception as e:
            conn.rollback()
            api_logger.error(f"[PlotService] 创建地块失败: {e}")
            return None
        finally:
            self._put_connection(conn)
    
    def create_or_get_plot(
        self,
        app_id: int,
        plot_name: str,
        geometry: list,
        description: str = None
    ) -> Optional[int]:
        """
        创建或获取地块
        
        如果地块已存在（相同app_id和plot_name），则返回已存在的地块ID
        否则创建新地块并返回新的地块ID
        
        Args:
            app_id: 应用ID
            plot_name: 地块名称
            geometry: 地块几何信息（坐标列表）
            description: 地块描述
            
        Returns:
            地块ID，失败返回None
        """
        # 先查询是否已存在
        existing_plot = self.get_plot_by_name(app_id, plot_name)
        
        if existing_plot:
            api_logger.info(
                f"[PlotService] 地块已存在 | Plot ID: {existing_plot['plot_id']} | "
                f"名称: {plot_name}"
            )
            
            # 可选：检查坐标是否匹配（这里简单记录日志）
            existing_geometry = json.loads(existing_plot['geometry'])
            if existing_geometry != geometry:
                api_logger.warning(
                    f"[PlotService] 地块坐标不匹配 | Plot ID: {existing_plot['plot_id']} | "
                    f"使用已存在的地块"
                )
            
            return existing_plot['plot_id']
        
        # 不存在则创建新地块
        return self.create_plot(app_id, plot_name, geometry, description)
    
    def update_plot_geometry(
        self,
        plot_id: int,
        geometry: list
    ) -> bool:
        """
        更新地块的几何信息
        
        Args:
            plot_id: 地块ID
            geometry: 新的几何信息
            
        Returns:
            是否成功
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            geometry_json = json.dumps(geometry)
            
            cursor.execute('''
                UPDATE gee_plots
                SET geometry = %s, updated_at = CURRENT_TIMESTAMP
                WHERE plot_id = %s
            ''', (geometry_json, plot_id))
            
            conn.commit()
            cursor.close()
            
            api_logger.info(f"[PlotService] 更新地块几何信息成功 | Plot ID: {plot_id}")
            return True
            
        except Exception as e:
            conn.rollback()
            api_logger.error(f"[PlotService] 更新地块几何信息失败: {e}")
            return False
        finally:
            self._put_connection(conn)
