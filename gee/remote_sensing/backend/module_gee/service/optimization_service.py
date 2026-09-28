"""瓦片下载优化服务"""
import json
import psycopg2
from psycopg2.extras import RealDictCursor
from shapely.geometry import shape, mapping, MultiPolygon, Polygon
from shapely.ops import unary_union
from typing import List, Dict, Optional
from config.env import DataBaseConfig
from utils.log_util import logger


class TileOptimizationService:
    """瓦片下载优化服务"""
    
    BUFFER_KM_TO_DEGREE = 1 / 111.0  # 1km ≈ 0.009度
    
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
    
    def fetch_all_plots(self, app_id: Optional[int] = None) -> List[Dict]:
        """获取所有地块"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            if app_id:
                logger.info(f"正在查询应用 ID={app_id} 的地块...")
                cursor.execute(
                    "SELECT plot_id, plot_name, geometry FROM gee_plots WHERE app_id = %s",
                    (app_id,)
                )
            else:
                logger.info("正在查询所有地块...")
                cursor.execute("SELECT plot_id, plot_name, geometry FROM gee_plots")
            
            results = cursor.fetchall()
            logger.info(f"查询到 {len(results)} 个地块")
            return results
        except Exception as e:
            logger.error(f"查询地块失败: {e}")
            return []
        finally:
            conn.close()
    
    def fetch_custom_regions(self) -> List[Dict]:
        """获取启用的自定义预存区域"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            logger.info("正在查询自定义区域...")
            cursor.execute("""
                SELECT region_id, region_name, geometry, buffer_km, priority
                FROM gee_custom_regions
                WHERE is_active = TRUE
                ORDER BY priority DESC
            """)
            results = cursor.fetchall()
            logger.info(f"查询到 {len(results)} 个自定义区域")
            return results
        except Exception as e:
            logger.error(f"查询自定义区域失败: {e}")
            return []
        finally:
            conn.close()
    
    def calculate_optimized_regions(
        self, 
        buffer_km: float = 5.0,
        app_id: Optional[int] = None,
        include_custom_regions: bool = True
    ) -> List[Dict]:
        """
        计算优化后的下载区域
        """
        logger.info("=" * 50)
        logger.info(f"开始计算优化区域 | Buffer: {buffer_km}km | AppID: {app_id} | IncludeCustom: {include_custom_regions}")
        
        buffer_degree = buffer_km * self.BUFFER_KM_TO_DEGREE
        all_geometries = []
        
        # 1. 获取地块并缓冲
        plots = self.fetch_all_plots(app_id)
        logger.info(f"步骤1: 处理 {len(plots)} 个地块...")
        
        for plot in plots:
            try:
                plot_name = plot.get('plot_name', 'unknown')
                plot_id = plot.get('plot_id', 'unknown')
                
                if not plot['geometry']:
                    logger.warning(f"地块 {plot_name} ({plot_id}) 几何信息为空，跳过")
                    continue
                
                # 解析几何
                raw_geom = plot['geometry']
                logger.info(f"  处理地块: {plot_name} (ID={plot_id})")
                logger.debug(f"    原始几何类型: {type(raw_geom)}")
                logger.debug(f"    原始几何内容: {str(raw_geom)[:200]}...")
                
                if isinstance(raw_geom, (dict, list)):
                    geom_json = raw_geom
                else:
                    geom_json = json.loads(raw_geom)
                
                logger.debug(f"    解析后类型: {type(geom_json)}")
                
                # 处理列表类型的几何（通常是坐标数组）
                if isinstance(geom_json, list):
                    logger.info(f"    地块 {plot_name} 几何为列表格式，尝试构建 Polygon")
                    logger.debug(f"    列表长度: {len(geom_json)}")
                    if len(geom_json) > 0:
                        logger.debug(f"    首个元素类型: {type(geom_json[0])}")
                        if isinstance(geom_json[0], list) and len(geom_json[0]) > 0:
                            logger.debug(f"    首个坐标类型: {type(geom_json[0][0])}")
                    
                    # 简单的容错处理：如果是二维数组，包装成 Polygon
                    if len(geom_json) > 0 and isinstance(geom_json[0], list):
                        if isinstance(geom_json[0][0], (int, float)):
                            # [[x,y], [x,y]] -> Polygon([[x,y], [x,y]])
                            logger.info(f"    转换格式: [[x,y],...] -> Polygon")
                            geom_json = {
                                "type": "Polygon",
                                "coordinates": [geom_json]
                            }
                        else:
                            # [[[x,y],...]] -> Polygon([[[x,y],...]])
                            logger.info(f"    转换格式: [[[x,y],...]] -> Polygon")
                            geom_json = {
                                "type": "Polygon",
                                "coordinates": geom_json
                            }
                
                logger.debug(f"    最终GeoJSON类型: {geom_json.get('type') if isinstance(geom_json, dict) else 'N/A'}")
                
                geom = shape(geom_json)
                logger.debug(f"    Shapely几何类型: {geom.geom_type}")
                logger.debug(f"    几何有效性: {geom.is_valid}")
                logger.debug(f"    几何边界: {geom.bounds}")
                
                if not geom.is_valid:
                    logger.warning(f"    地块 {plot_name} 几何无效，尝试修复")
                    geom = geom.buffer(0)
                    logger.debug(f"    修复后有效性: {geom.is_valid}")
                
                buffered = geom.buffer(buffer_degree)
                logger.debug(f"    缓冲后边界: {buffered.bounds}")
                logger.debug(f"    缓冲后面积: {buffered.area:.6f} 平方度")
                
                all_geometries.append({
                    'geometry': buffered,
                    'source': 'plot',
                    'id': plot['plot_id']
                })
                logger.info(f"    ✓ 地块 {plot_name} 处理成功")
            except Exception as e:
                logger.error(f"❌ 地块 {plot.get('plot_name', 'unknown')} 解析失败: {e}")
                logger.exception("详细错误信息:")
        
        # 2. 获取自定义区域并缓冲
        if include_custom_regions:
            custom_regions = self.fetch_custom_regions()
            logger.info(f"步骤2: 处理 {len(custom_regions)} 个自定义区域...")
            
            for region in custom_regions:
                try:
                    if not region['geometry']:
                        logger.warning(f"自定义区域 {region.get('region_name')} 几何为空，跳过")
                        continue

                    # 解析几何
                    raw_geom = region['geometry']
                    if isinstance(raw_geom, (dict, list)):
                        geom_json = raw_geom
                    else:
                        geom_json = json.loads(raw_geom)
                    
                    # 处理列表类型的几何
                    if isinstance(geom_json, list):
                        logger.warning(f"自定义区域 {region.get('region_name')} 几何为列表格式，尝试构建 Polygon")
                        if len(geom_json) > 0 and isinstance(geom_json[0], list):
                            if isinstance(geom_json[0][0], (int, float)):
                                geom_json = {
                                    "type": "Polygon",
                                    "coordinates": [geom_json]
                                }
                            else:
                                geom_json = {
                                    "type": "Polygon",
                                    "coordinates": geom_json
                                }

                    geom = shape(geom_json)
                    custom_buffer = float(region['buffer_km']) * self.BUFFER_KM_TO_DEGREE
                    buffered = geom.buffer(custom_buffer)
                    all_geometries.append({
                        'geometry': buffered,
                        'source': 'custom',
                        'id': region['region_id'],
                        'priority': region['priority']
                    })
                    logger.debug(f"  - 自定义区域 {region.get('region_name')} 处理成功")
                except Exception as e:
                    logger.error(f"自定义区域 {region.get('region_name', 'unknown')} 解析失败: {e} | 类型: {type(region.get('geometry'))}")
        
        if not all_geometries:
            logger.warning("❌ 没有有效的几何图形可供合并，返回空列表")
            return []
        
        # 3. 合并所有几何
        logger.info(f"步骤3: 正在合并 {len(all_geometries)} 个几何图形...")
        logger.debug(f"  几何来源统计: {sum(1 for g in all_geometries if g['source'] == 'plot')} 个地块, {sum(1 for g in all_geometries if g['source'] == 'custom')} 个自定义区域")
        
        try:
            geoms_to_merge = [g['geometry'] for g in all_geometries]
            logger.debug(f"  待合并几何类型: {[g.geom_type for g in geoms_to_merge[:5]]}...")
            
            merged = unary_union(geoms_to_merge)
            logger.info(f"  ✓ 合并成功，结果类型: {merged.geom_type}")
            logger.debug(f"  合并后边界: {merged.bounds}")
            logger.debug(f"  合并后面积: {merged.area:.6f} 平方度")
        except Exception as e:
            logger.error(f"❌ 几何合并失败: {e}")
            logger.exception("详细错误信息:")
            return []
        
        # 4. 转换为区域列表
        optimized_regions = []
        regions_list = []
        
        if isinstance(merged, Polygon):
            regions_list = [merged]
            logger.info("合并结果: 单个 Polygon")
        elif isinstance(merged, MultiPolygon):
            regions_list = list(merged.geoms)
            logger.info(f"合并结果: MultiPolygon (包含 {len(regions_list)} 个部分)")
        else:
            logger.warning(f"合并结果类型未知: {type(merged)}")
        
        logger.info(f"步骤4: 生成 {len(regions_list)} 个优化区域")
        
        for idx, region in enumerate(regions_list):
            try:
                minx, miny, maxx, maxy = region.bounds
                
                # 转换为 AOI 坐标（闭合多边形）
                aoi_coords = [
                    [minx, miny],
                    [maxx, miny],
                    [maxx, maxy],
                    [minx, maxy],
                    [minx, miny]
                ]
                
                # 计算面积（近似，平方公里）
                area_sq_deg = region.area
                area_sq_km = area_sq_deg * (111 * 111)  # 粗略估算
                
                optimized_regions.append({
                    'region_id': idx + 1,
                    'aoi_coords': aoi_coords,
                    'bounds': [minx, miny, maxx, maxy],
                    'area_sq_km': round(area_sq_km, 2),
                    'center': [(minx + maxx) / 2, (miny + maxy) / 2]
                })
            except Exception as e:
                logger.error(f"处理区域 {idx} 失败: {e}")
        
        logger.info(f"✅ 计算完成，返回 {len(optimized_regions)} 个区域")
        logger.info("=" * 50)
        return optimized_regions

