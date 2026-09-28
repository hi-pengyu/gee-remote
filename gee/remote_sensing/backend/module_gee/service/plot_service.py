"""GEE地块管理服务"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
from config.env import DataBaseConfig


class GeePlotService:
    """GEE地块管理服务"""
    
    _pool = None
    
    def __init__(self):
        """初始化服务"""
        if GeePlotService._pool is None:
            db_config = DataBaseConfig
            GeePlotService._pool = SimpleConnectionPool(
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
        return GeePlotService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接"""
        GeePlotService._pool.putconn(conn)
    
    def get_plot_list(
        self,
        page_num: int = 1,
        page_size: int = 10,
        plot_name: str = None,
        app_id: int = None
    ) -> Dict:
        """获取地块列表"""
        conn = self._get_connection()
        try:
            conditions = ['1=1']
            params = []
            
            if plot_name:
                conditions.append("p.plot_name LIKE %s")
                params.append(f'%{plot_name}%')
            
            if app_id:
                conditions.append("p.app_id = %s")
                params.append(app_id)
            
            where_clause = ' AND '.join(conditions)
            
            # 查询总数
            cursor = conn.cursor()
            count_query = f'SELECT COUNT(*) FROM gee_plots p WHERE {where_clause}'
            cursor.execute(count_query, params)
            count_result = cursor.fetchone()
            total = count_result[0] if count_result else 0
            cursor.close()
            
            # 查询数据
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            offset = (page_num - 1) * page_size
            
            query = f'''
                SELECT 
                    p.plot_id, p.app_id, p.plot_name, p.geometry, p.description,
                    p.created_at, p.updated_at,
                    a.app_name
                FROM gee_plots p
                LEFT JOIN gee_apps a ON p.app_id = a.app_id
                WHERE {where_clause}
                ORDER BY p.created_at DESC
                LIMIT %s OFFSET %s
            '''
            
            cursor.execute(query, params + [page_size, offset])
            rows = cursor.fetchall()
            
            # 转换为驼峰命名
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'plotId': row['plot_id'],
                    'appId': row['app_id'],
                    'appName': row['app_name'],
                    'plotName': row['plot_name'],
                    'geometry': row['geometry'],
                    'description': row['description'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None
                })
            
            return {
                'rows': camel_rows,
                'total': total
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_plot_by_id(self, plot_id: int) -> Optional[Dict]:
        """根据ID获取地块"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT p.*, a.app_name 
                FROM gee_plots p
                LEFT JOIN gee_apps a ON p.app_id = a.app_id
                WHERE p.plot_id = %s
            ''', (plot_id,))
            row = cursor.fetchone()
            
            if not row:
                return None
            
            return {
                'plotId': row['plot_id'],
                'appId': row['app_id'],
                'appName': row['app_name'],
                'plotName': row['plot_name'],
                'geometry': row['geometry'],
                'description': row['description'],
                'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None
            }
        finally:
            cursor.close()
            self._put_connection(conn)

    def create_plot(self, app_id: int, plot_name: str, geometry: str, description: str = None,
                    crop_type: str = None, adcode: str = None) -> Optional[int]:
        """
        创建地块（支持自动获取行政区信息）
        
        Args:
            app_id: 应用ID
            plot_name: 地块名称
            geometry: 几何信息（GeoJSON字符串或字典）
            description: 描述
            crop_type: 作物类型（可选）
            adcode: 行政区代码（可选，如不提供则自动获取）
            
        Returns:
            plot_id: 地块ID，失败返回None
        """
        conn = self._get_connection()
        try:
            import json
            from module_gee.service.geocoding_service import GeocodingService
            
            # 1. 解析几何信息
            geom_json = json.loads(geometry) if isinstance(geometry, str) else geometry
            
            # 2. 自动获取行政区信息（如果未提供）
            adcode_info = None
            if not adcode:
                geocoding_service = GeocodingService()
                adcode_info = geocoding_service.get_adcode_from_geometry(geom_json)
                
                if adcode_info:
                    adcode = adcode_info.get('adcode')
                    print(f"自动识别行政区: {adcode_info.get('province')}/{adcode_info.get('city')}/{adcode_info.get('district')}")
                else:
                    print("警告: 无法自动获取行政区信息")
            
            # 3. 获取作物默认监测时间（如果提供了作物类型）
            monitor_start_date = None
            monitor_end_date = None
            if crop_type:
                geocoding_service = GeocodingService()
                crop_dates = geocoding_service.get_crop_default_dates(crop_type)
                if crop_dates:
                    monitor_start_date = crop_dates.get('start_date')
                    monitor_end_date = crop_dates.get('end_date')
                    print(f"作物 {crop_type} 默认监测周期: {monitor_start_date} ~ {monitor_end_date}")
            
            # 4. 插入地块（包含行政区信息）
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO gee_plots (
                    app_id, plot_name, geometry, description,
                    adcode, province, city, district, crop_type,
                    monitor_start_date, monitor_end_date,
                    monitor_status, auto_update
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING plot_id
            ''', (
                app_id, 
                plot_name, 
                json.dumps(geom_json) if isinstance(geom_json, dict) else geometry,
                description,
                adcode,
                adcode_info.get('province') if adcode_info else None,
                adcode_info.get('city') if adcode_info else None,
                adcode_info.get('district') if adcode_info else None,
                crop_type,
                monitor_start_date,
                monitor_end_date,
                1,  # 默认开启监测
                True  # 默认启用自动更新
            ))
            
            plot_id = cursor.fetchone()[0]
            conn.commit()
            cursor.close()
            
            print(f"地块创建成功，ID: {plot_id}")
            return plot_id
            
        except Exception as e:
            conn.rollback()
            print(f"创建地块失败: {e}")
            import traceback
            traceback.print_exc()
            return None
        finally:
            self._put_connection(conn)

    def update_plot(self, plot_id: int, plot_name: str, geometry: str, description: str) -> bool:
        """更新地块"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE gee_plots 
                SET plot_name = %s, geometry = %s, description = %s, updated_at = CURRENT_TIMESTAMP
                WHERE plot_id = %s
            ''', (plot_name, geometry, description, plot_id))
            
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            print(f"更新地块失败: {e}")
            return False
        finally:
            self._put_connection(conn)

    def delete_plot(self, plot_id: int) -> bool:
        """删除地块"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('DELETE FROM gee_plots WHERE plot_id = %s', (plot_id,))
            conn.commit()
            cursor.close()
            return True
        except Exception as e:
            conn.rollback()
            print(f"删除地块失败: {e}")
            return False
        finally:
            self._put_connection(conn)

    def check_plot_belongs_to_app(self, plot_id: int, app_id: int) -> bool:
        """检查地块是否属于该应用"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('SELECT 1 FROM gee_plots WHERE plot_id = %s AND app_id = %s', (plot_id, app_id))
            return cursor.fetchone() is not None
        finally:
            cursor.close()
            self._put_connection(conn)

    def get_plot_tasks(self, plot_id: int) -> Dict:
        """获取地块关联的任务列表"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT t.task_id, t.target_date, t.model_type, t.status, t.progress, t.created_at,
                       r.found_date
                FROM gee_tasks t
                LEFT JOIN gee_task_results r ON t.task_id = r.task_id
                WHERE t.plot_id = %s
                ORDER BY t.created_at DESC
            ''', (plot_id,))
            
            rows = cursor.fetchall()
            
            # 转换为驼峰命名
            camel_rows = []
            for row in rows:
                camel_rows.append({
                    'taskId': row['task_id'],
                    'targetDate': row['target_date'].isoformat() if row['target_date'] else None,
                    'foundDate': row['found_date'].isoformat() if row['found_date'] else None,
                    'modelType': row['model_type'],
                    'status': row['status'],
                    'progress': row['progress'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None
                })
            
            return {'rows': camel_rows, 'total': len(camel_rows)}
        finally:
            cursor.close()
            self._put_connection(conn)

    def get_plot_dates(self, plot_id: int, start_date: str = None, end_date: str = None) -> List[str]:
        """获取地块已完成任务的实际遥感日期"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 构建查询条件
            conditions = ['t.plot_id = %s', "t.status = '2'"]  # 只查询成功的任务
            params = [plot_id]
            
            if start_date:
                conditions.append('r.found_date >= %s')
                params.append(start_date)
            
            if end_date:
                conditions.append('r.found_date <= %s')
                params.append(end_date)
            
            where_clause = ' AND '.join(conditions)
            
            # 查询任务结果表，获取实际日期（found_date）
            query = f'''
                SELECT DISTINCT r.found_date
                FROM gee_tasks t
                INNER JOIN gee_task_results r ON t.task_id = r.task_id
                WHERE {where_clause}
                ORDER BY r.found_date DESC
            '''
            
            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            # 提取日期列表
            dates = [row['found_date'].isoformat() if row['found_date'] else None for row in rows]
            dates = [d for d in dates if d]  # 过滤掉None
            
            return dates
            
        except Exception as e:
            print(f"查询地块日期失败: {e}")
            return []
        finally:
            cursor.close()
            self._put_connection(conn)

    def toggle_monitor_status(self, plot_id: int, monitor_status: int, operator: str = None) -> bool:
        """
        切换地块监测状态
        
        Args:
            plot_id: 地块ID
            monitor_status: 监测状态 (1=开启, 0=关闭)
            operator: 操作人
            
        Returns:
            是否成功
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE gee_plots 
                SET monitor_status = %s,
                    updated_at = CURRENT_TIMESTAMP
                WHERE plot_id = %s
            ''', (monitor_status, plot_id))
            
            conn.commit()
            cursor.close()
            
            print(f"地块 {plot_id} 监测状态已更新为: {monitor_status}")
            return True
            
        except Exception as e:
            conn.rollback()
            print(f"更新地块监测状态失败: {e}")
            return False
        finally:
            self._put_connection(conn)
    
    def get_active_plots_for_update(self, app_id: int = None) -> List[Dict]:
        """
        获取所有需要自动更新的活跃地块（已过滤行政区和生育期）
        
        Args:
            app_id: 应用ID（可选）
            
        Returns:
            活跃地块列表
        """
        conn = self._get_connection()
        try:
            from datetime import datetime
            from module_gee.service.region_policy_service import region_policy_service
            
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # 1. 查询所有开启监测且启用自动更新的地块
            conditions = ['monitor_status = 1', 'auto_update = TRUE']
            params = []
            
            if app_id:
                conditions.append('app_id = %s')
                params.append(app_id)
            
            where_clause = ' AND '.join(conditions)
            
            cursor.execute(f'''
                SELECT * FROM gee_plots
                WHERE {where_clause}
                ORDER BY plot_id
            ''', params)
            
            plots = cursor.fetchall()
            cursor.close()
            
            # 2. 获取暂停的行政区列表
            paused_adcodes = region_policy_service.get_paused_adcodes()
            
            # 3. 过滤地块
            today = datetime.now()
            active_plots = []
            
            for plot in plots:
                # 过滤器 1: 行政区检查
                if plot['adcode'] and region_policy_service.is_region_paused(plot['adcode'], paused_adcodes):
                    print(f"地块 {plot['plot_id']} 位于暂停区域 {plot['adcode']}，跳过")
                    continue
                
                # 过滤器 2: 生育期检查
                if not self._is_in_monitor_period(today, plot['monitor_start_date'], plot['monitor_end_date']):
                    print(f"地块 {plot['plot_id']} 不在监测周期内，跳过")
                    continue
                
                active_plots.append(dict(plot))
            
            print(f"共 {len(plots)} 个地块，过滤后 {len(active_plots)} 个需要更新")
            return active_plots
            
        finally:
            self._put_connection(conn)
    
    @staticmethod
    def _is_in_monitor_period(current_date, start_mmdd: str, end_mmdd: str) -> bool:
        """
        检查当前日期是否在监测周期内
        
        Args:
            current_date: 当前日期
            start_mmdd: 开始日期（格式：MM-DD，如：04-01）
            end_mmdd: 结束日期（格式：MM-DD，如：10-31）
            
        Returns:
            True if in period, False otherwise
        """
        if not start_mmdd or not end_mmdd:
            return True  # 未设置周期，默认全年监测
        
        try:
            from datetime import datetime
            
            current_year = current_date.year
            start_date = datetime.strptime(f"{current_year}-{start_mmdd}", "%Y-%m-%d")
            end_date = datetime.strptime(f"{current_year}-{end_mmdd}", "%Y-%m-%d")
            
            # 处理跨年情况（如小麦：10-01 到次年 06-30）
            if start_date > end_date:
                # 跨年：当前日期 >= 开始日期 或 当前日期 <= 结束日期
                return current_date >= start_date or current_date <= end_date
            else:
                # 同年：当前日期在开始和结束之间
                return start_date <= current_date <= end_date
                
        except Exception as e:
            print(f"生育期检查失败: {e}")
            return True  # 出错时默认允许监测
