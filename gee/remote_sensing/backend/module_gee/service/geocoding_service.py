"""地理编码服务 - 坐标转行政区"""
import requests
from typing import Optional, Dict
from shapely.geometry import shape
from utils.log_util import logger
import json


class GeocodingService:
    """地理编码服务 - 支持高德地图API和PostGIS两种方式"""
    
    # 高德地图API配置（需要申请API Key）
    AMAP_KEY = "your_amap_api_key_here"  # TODO: 替换为实际的高德地图API Key
    AMAP_ENABLED = False  # 是否启用高德地图API
    
    @staticmethod
    def get_adcode_from_coords(lon: float, lat: float) -> Optional[Dict]:
        """
        根据经纬度获取行政区信息
        
        Args:
            lon: 经度
            lat: 纬度
            
        Returns:
            {
                'adcode': '410100',
                'province': '河南省',
                'city': '郑州市',
                'district': '中原区'
            }
        """
        # 优先使用PostGIS（如果数据库有行政区边界数据）
        result = GeocodingService._get_adcode_from_postgis(lon, lat)
        if result:
            return result
        
        # 回退到高德地图API
        if GeocodingService.AMAP_ENABLED:
            return GeocodingService._get_adcode_from_amap(lon, lat)
        
        logger.warning(f"无法获取坐标 ({lon}, {lat}) 的行政区信息")
        return None
    
    @staticmethod
    def _get_adcode_from_amap(lon: float, lat: float) -> Optional[Dict]:
        """使用高德地图API获取行政区"""
        try:
            url = "https://restapi.amap.com/v3/geocode/regeo"
            params = {
                'key': GeocodingService.AMAP_KEY,
                'location': f'{lon},{lat}',
                'extensions': 'base',
                'output': 'json'
            }
            
            response = requests.get(url, params=params, timeout=5)
            data = response.json()
            
            if data.get('status') == '1' and data.get('regeocode'):
                addr_comp = data['regeocode']['addressComponent']
                
                return {
                    'adcode': addr_comp.get('adcode'),
                    'province': addr_comp.get('province'),
                    'city': addr_comp.get('city') or addr_comp.get('province'),  # 直辖市没有city
                    'district': addr_comp.get('district'),
                    'township': addr_comp.get('township'),
                    'formatted_address': data['regeocode'].get('formatted_address')
                }
            
            logger.warning(f"高德地图API返回失败: {data.get('info')}")
            return None
            
        except Exception as e:
            logger.error(f"高德地图API调用失败: {e}")
            return None
    
    @staticmethod
    def _get_adcode_from_postgis(lon: float, lat: float) -> Optional[Dict]:
        """使用PostGIS空间查询获取行政区"""
        try:
            from config.env import DataBaseConfig
            import psycopg2
            from psycopg2.extras import RealDictCursor
            
            conn = psycopg2.connect(
                host=DataBaseConfig.db_host,
                port=DataBaseConfig.db_port,
                user=DataBaseConfig.db_username,
                password=DataBaseConfig.db_password,
                database=DataBaseConfig.db_database
            )
            
            try:
                cursor = conn.cursor(cursor_factory=RealDictCursor)
                
                # 查询区县级行政区
                query = '''
                    SELECT adcode, name, level, parent_adcode
                    FROM china_administrative_divisions
                    WHERE ST_Contains(
                        geometry, 
                        ST_SetSRID(ST_MakePoint(%s, %s), 4326)
                    )
                    AND level = 'district'
                    LIMIT 1
                '''
                
                cursor.execute(query, (lon, lat))
                district_result = cursor.fetchone()
                
                if not district_result:
                    logger.debug(f"PostGIS未找到坐标 ({lon}, {lat}) 的行政区")
                    return None
                
                # 获取完整的省市区信息
                result = {
                    'adcode': district_result['adcode'],
                    'district': district_result['name'],
                    'province': None,
                    'city': None
                }
                
                # 查询市级
                if district_result['parent_adcode']:
                    cursor.execute('''
                        SELECT name, parent_adcode FROM china_administrative_divisions
                        WHERE adcode = %s
                    ''', (district_result['parent_adcode'],))
                    city_result = cursor.fetchone()
                    if city_result:
                        result['city'] = city_result['name']
                        
                        # 查询省级
                        if city_result['parent_adcode']:
                            cursor.execute('''
                                SELECT name FROM china_administrative_divisions
                                WHERE adcode = %s
                            ''', (city_result['parent_adcode'],))
                            province_result = cursor.fetchone()
                            if province_result:
                                result['province'] = province_result['name']
                
                cursor.close()
                return result
                
            finally:
                conn.close()
                
        except Exception as e:
            logger.debug(f"PostGIS查询失败（可能未导入行政区数据）: {e}")
            return None
    
    @staticmethod
    def get_adcode_from_geometry(geometry: dict) -> Optional[Dict]:
        """
        从GeoJSON几何对象中提取中心点，然后获取行政区
        
        Args:
            geometry: GeoJSON格式的几何对象或字符串
            
        Returns:
            行政区信息字典
        """
        try:
            # 解析几何对象
            if isinstance(geometry, str):
                geometry = json.loads(geometry)
            
            # 使用 shapely 计算几何中心
            geom = shape(geometry)
            centroid = geom.centroid
            
            logger.info(f"地块中心点坐标: ({centroid.x}, {centroid.y})")
            
            return GeocodingService.get_adcode_from_coords(
                centroid.x, 
                centroid.y
            )
        except Exception as e:
            logger.error(f"几何中心计算失败: {e}")
            return None
    
    @staticmethod
    def get_crop_default_dates(crop_type: str) -> Optional[Dict]:
        """
        获取作物的默认监测时间
        
        Args:
            crop_type: 作物类型代码
            
        Returns:
            {'start_date': 'MM-DD', 'end_date': 'MM-DD'}
        """
        try:
            from config.env import DataBaseConfig
            import psycopg2
            from psycopg2.extras import RealDictCursor
            
            conn = psycopg2.connect(
                host=DataBaseConfig.db_host,
                port=DataBaseConfig.db_port,
                user=DataBaseConfig.db_username,
                password=DataBaseConfig.db_password,
                database=DataBaseConfig.db_database
            )
            
            try:
                cursor = conn.cursor(cursor_factory=RealDictCursor)
                cursor.execute('''
                    SELECT default_start_date, default_end_date
                    FROM gee_crop_types
                    WHERE crop_code = %s AND is_enabled = TRUE
                ''', (crop_type,))
                
                result = cursor.fetchone()
                cursor.close()
                
                if result:
                    return {
                        'start_date': result['default_start_date'],
                        'end_date': result['default_end_date']
                    }
                
                return None
                
            finally:
                conn.close()
                
        except Exception as e:
            logger.error(f"查询作物默认时间失败: {e}")
            return None
