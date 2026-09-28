"""缓存服务 - 负责从缓存获取数据和瓦片下载"""
import os
import numpy as np
import rasterio
from rasterio.mask import mask
from rasterio.io import MemoryFile
from rasterio.warp import calculate_default_transform, reproject, Resampling
from shapely.geometry import Polygon, mapping
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from pathlib import Path
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from app.services.tile_manager import TileManager
from app.services.gee_service import GEEService
from app.config import settings


class CacheService:
    """缓存服务"""
    
    def __init__(self, account_info: Dict = None):
        """
        初始化缓存服务
        
        Args:
            account_info: GEE 账号信息（可选，用于从账号池选择）
        """
        self.tile_manager = TileManager()
        
        # 始终使用单账号 GEE 服务
        self.gee_service = GEEService()
        
        self.storage_path = getattr(settings, 'TILE_STORAGE_PATH', 'storage/tiles')
        
        # 确保存储目录存在
        os.makedirs(self.storage_path, exist_ok=True)
        
        print(f"[CacheService] 初始化完成,存储路径: {self.storage_path}")
    
    def get_data_from_cache(
        self,
        coords: List[List[float]],
        target_date: str,
        window_days: int = 7,
        force_refresh: bool = False
    ) -> Dict:
        """
        从缓存获取地块数据(优先策略,支持多瓦片拼接)
        
        优化点:
        1. 支持地块跨多个瓦片的情况
        2. 部分命中时优先使用缓存,只下载缺失部分
        3. 智能拼接多个瓦片
        
        Args:
            coords: 地块坐标
            target_date: 目标日期
            window_days: 搜索窗口(天)
            force_refresh: 是否强制刷新
            
        Returns:
            {
                'success': bool,
                'source': 'cache' | 'gee' | 'hybrid',
                'file_path': str,
                'is_expired': bool,
                'tile_ids': List[str],
                'cache_hit_rate': float,
                'found_date': str,
                'cloud_cover': float
            }
        """
        print(f"[CacheService] 请求数据: {target_date}, 坐标点数: {len(coords)}")
        
        # 1. 计算地块覆盖的瓦片
        tile_ids = self.tile_manager.get_tile_for_polygon(coords)
        print(f"[CacheService] 地块覆盖 {len(tile_ids)} 个瓦片: {tile_ids}")
        
        # 2. 检查每个瓦片的缓存状态
        cached_tiles = []
        missing_tiles = []
        
        if not force_refresh:
            for tile_id in tile_ids:
                tile_info = self.tile_manager.check_tile_cache(tile_id, target_date)
                if tile_info and not tile_info['is_expired']:
                    cached_tiles.append((tile_id, tile_info))
                    self.tile_manager.mark_tile_accessed(tile_id, target_date)
                else:
                    missing_tiles.append(tile_id)
        else:
            missing_tiles = tile_ids
        
        cache_hit_rate = len(cached_tiles) / len(tile_ids) if tile_ids else 0
        print(f"[CacheService] 缓存命中率: {cache_hit_rate*100:.1f}% ({len(cached_tiles)}/{len(tile_ids)})")
        
        # 3. 处理不同情况
        
        # 情况1: 完全命中
        if len(cached_tiles) == len(tile_ids):
            print(f"[CacheService] ✓ 完全缓存命中")
            
            if len(cached_tiles) == 1:
                # 单瓦片,直接切图
                tile_id, tile_info = cached_tiles[0]
                cropped_path = self._crop_from_tile(
                    tile_info['file_path'],
                    coords,
                    tile_id,
                    target_date
                )
            else:
                # 多瓦片,拼接后切图
                tile_paths = [info['file_path'] for _, info in cached_tiles]
                cropped_path = self._mosaic_and_crop(
                    tile_paths,
                    coords,
                    [tid for tid, _ in cached_tiles],
                    target_date
                )
            
            return {
                'success': True,
                'source': 'cache',
                'file_path': cropped_path,
                'is_expired': False,
                'tile_ids': [tid for tid, _ in cached_tiles],
                'cache_hit_rate': 1.0,
                'found_date': cached_tiles[0][1]['date_acquired'],
                'cloud_cover': cached_tiles[0][1]['cloud_cover']
            }
        
        # 情况2: 部分命中
        elif len(cached_tiles) > 0 and len(missing_tiles) > 0:
            print(f"[CacheService] ⚡ 部分命中,下载缺失瓦片: {missing_tiles}")
            
            # 下载缺失的瓦片
            downloaded_tiles = []
            for tile_id in missing_tiles:
                try:
                    tile_data = self._download_tile(tile_id, target_date, window_days)
                    downloaded_tiles.append((tile_id, tile_data))
                except Exception as e:
                    print(f"[CacheService] 下载瓦片失败 {tile_id}: {e}")
                    # 继续尝试其他瓦片
            
            # 合并缓存和新下载的瓦片
            all_tile_paths = []
            all_tile_ids = []
            
            for tile_id, tile_info in cached_tiles:
                all_tile_paths.append(tile_info['file_path'])
                all_tile_ids.append(tile_id)
            
            for tile_id, tile_data in downloaded_tiles:
                all_tile_paths.append(tile_data['file_path'])
                all_tile_ids.append(tile_id)
            
            # 拼接并切图
            if len(all_tile_paths) == 1:
                cropped_path = self._crop_from_tile(
                    all_tile_paths[0],
                    coords,
                    all_tile_ids[0],
                    target_date
                )
            else:
                cropped_path = self._mosaic_and_crop(
                    all_tile_paths,
                    coords,
                    all_tile_ids,
                    target_date
                )
            
            return {
                'success': True,
                'source': 'hybrid',  # 混合来源
                'file_path': cropped_path,
                'is_expired': False,
                'tile_ids': all_tile_ids,
                'cache_hit_rate': cache_hit_rate,
                'found_date': downloaded_tiles[0][1]['found_date'] if downloaded_tiles else cached_tiles[0][1]['date_acquired'],
                'cloud_cover': downloaded_tiles[0][1]['cloud_cover'] if downloaded_tiles else cached_tiles[0][1]['cloud_cover']
            }
        
        # 情况3: 完全未命中
        else:
            print(f"[CacheService] ✗ 完全未命中,下载所有瓦片")
            
            downloaded_tiles = []
            for tile_id in tile_ids:
                try:
                    tile_data = self._download_tile(tile_id, target_date, window_days)
                    downloaded_tiles.append((tile_id, tile_data))
                except Exception as e:
                    print(f"[CacheService] 下载瓦片失败 {tile_id}: {e}")
            
            if not downloaded_tiles:
                raise Exception("所有瓦片下载失败")
            
            # 切图或拼接
            if len(downloaded_tiles) == 1:
                tile_id, tile_data = downloaded_tiles[0]
                cropped_path = self._crop_from_tile(
                    tile_data['file_path'],
                    coords,
                    tile_id,
                    target_date
                )
            else:
                tile_paths = [data['file_path'] for _, data in downloaded_tiles]
                tile_ids_list = [tid for tid, _ in downloaded_tiles]
                cropped_path = self._mosaic_and_crop(
                    tile_paths,
                    coords,
                    tile_ids_list,
                    target_date
                )
            
            return {
                'success': True,
                'source': 'gee',
                'file_path': cropped_path,
                'is_expired': False,
                'tile_ids': [tid for tid, _ in downloaded_tiles],
                'cache_hit_rate': 0.0,
                'found_date': downloaded_tiles[0][1]['found_date'],
                'cloud_cover': downloaded_tiles[0][1]['cloud_cover']
            }
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=60),
        retry=retry_if_exception_type((ConnectionError, TimeoutError, Exception)),
        reraise=True
    )
    def _download_tile(
        self,
        tile_id: str,
        target_date: str,
        window_days: int = 7
    ) -> Dict:
        """
        从GEE下载瓦片(带重试机制)
        
        自动重试3次,每次等待时间指数增长(4s, 16s, 60s)
        
        Args:
            tile_id: 瓦片ID
            target_date: 目标日期
            window_days: 搜索窗口
            
        Returns:
            瓦片信息字典
        """
        print(f"[CacheService] 开始下载瓦片: {tile_id}")
        
        # 获取瓦片边界
        bounds = self.tile_manager.get_tile_bounds(tile_id)
        
        # 构建瓦片多边形坐标(GEE格式)
        tile_coords = [[
            [bounds['min_lon'], bounds['min_lat']],
            [bounds['max_lon'], bounds['min_lat']],
            [bounds['max_lon'], bounds['max_lat']],
            [bounds['min_lon'], bounds['max_lat']],
            [bounds['min_lon'], bounds['min_lat']]
        ]]
        
        # 生成文件名
        date_str = target_date.replace('-', '')
        year_month = target_date[:7]  # YYYY-MM
        file_name = f"{tile_id}_{date_str}"
        
        # 创建月份目录
        month_dir = os.path.join(self.storage_path, year_month)
        os.makedirs(month_dir, exist_ok=True)
        
        local_path = os.path.join(month_dir, f"{file_name}.tif")
        
        # 使用GEE服务下载
        export_result = self.gee_service.export_image_to_drive(
            aoi_coords=tile_coords,
            target_date=target_date,
            window_days=window_days,
            file_name=file_name,
            scale=10
        )
        
        # 从Google Drive下载到本地
        self.gee_service.download_from_drive(
            file_name=file_name,
            local_download_path=local_path
        )
        
        # 验证下载的文件完整性
        if not self._verify_tile(local_path):
            # 删除损坏的文件
            try:
                os.remove(local_path)
            except:
                pass
            raise Exception(f"下载的瓦片文件损坏或无效: {tile_id}")
        
        # 注册到瓦片管理器
        self.tile_manager.register_tile(
            tile_id=tile_id,
            file_path=local_path,
            date_acquired=export_result['found_date'],
            cloud_cover=export_result['cloud_cover']
        )
        
        print(f"[CacheService] ✓ 瓦片下载完成并验证: {local_path}")
        
        return {
            'file_path': local_path,
            'found_date': export_result['found_date'],
            'cloud_cover': export_result['cloud_cover']
        }
    
    def _crop_from_tile(
        self,
        tile_path: str,
        coords: List[List[float]],
        tile_id: str,
        date_str: str
    ) -> str:
        """
        从瓦片中切出地块数据
        
        Args:
            tile_path: 瓦片文件路径
            coords: 地块坐标
            tile_id: 瓦片ID
            date_str: 日期字符串
            
        Returns:
            切图后的文件路径
        """
        print(f"[CacheService] 从瓦片切图: {tile_path}")
        
        # 创建输出目录
        crop_dir = os.path.join(self.storage_path, 'crops')
        os.makedirs(crop_dir, exist_ok=True)
        
        # 生成输出文件名
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_name = f"crop_{tile_id}_{date_str}_{timestamp}.tif"
        output_path = os.path.join(crop_dir, output_name)
        
        # 创建多边形
        polygon = Polygon(coords)
        geom = [mapping(polygon)]
        
        # 使用rasterio裁剪
        with rasterio.open(tile_path) as src:
            # 裁剪
            out_image, out_transform = mask(src, geom, crop=True)
            out_meta = src.meta.copy()
            
            # 更新元数据
            out_meta.update({
                "driver": "GTiff",
                "height": out_image.shape[1],
                "width": out_image.shape[2],
                "transform": out_transform,
                "compress": "lzw"  # 压缩以节省空间
            })
            
            # 写入输出文件
            with rasterio.open(output_path, "w", **out_meta) as dest:
                dest.write(out_image)
        
        print(f"[CacheService] ✓ 切图完成: {output_path}")
        return output_path
    
    def _mosaic_and_crop(
        self,
        tile_paths: List[str],
        coords: List[List[float]],
        tile_ids: List[str],
        date_str: str
    ) -> str:
        """
        拼接多个瓦片并切图
        
        Args:
            tile_paths: 瓦片文件路径列表
            coords: 地块坐标
            tile_ids: 瓦片ID列表
            date_str: 日期字符串
            
        Returns:
            切图后的文件路径
        """
        print(f"[CacheService] 拼接 {len(tile_paths)} 个瓦片并切图")
        
        from rasterio.merge import merge
        
        # 打开所有瓦片
        src_files = [rasterio.open(path) for path in tile_paths]
        
        try:
            # 拼接瓦片
            mosaic, out_transform = merge(src_files)
            
            # 获取元数据
            out_meta = src_files[0].meta.copy()
            out_meta.update({
                "driver": "GTiff",
                "height": mosaic.shape[1],
                "width": mosaic.shape[2],
                "transform": out_transform
            })
            
            # 创建临时拼接文件
            mosaic_dir = os.path.join(self.storage_path, 'mosaics')
            os.makedirs(mosaic_dir, exist_ok=True)
            
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            mosaic_name = f"mosaic_{'_'.join(tile_ids)}_{timestamp}.tif"
            mosaic_path = os.path.join(mosaic_dir, mosaic_name)
            
            # 保存拼接结果
            with rasterio.open(mosaic_path, "w", **out_meta) as dest:
                dest.write(mosaic)
            
            print(f"[CacheService] ✓ 瓦片拼接完成: {mosaic_path}")
            
            # 从拼接结果中切图
            polygon = Polygon(coords)
            geom = [mapping(polygon)]
            
            with rasterio.open(mosaic_path) as src:
                out_image, out_transform = mask(src, geom, crop=True)
                out_meta = src.meta.copy()
                
                out_meta.update({
                    "driver": "GTiff",
                    "height": out_image.shape[1],
                    "width": out_image.shape[2],
                    "transform": out_transform,
                    "compress": "lzw"
                })
                
                # 保存切图结果
                crop_dir = os.path.join(self.storage_path, 'crops')
                os.makedirs(crop_dir, exist_ok=True)
                
                output_name = f"crop_mosaic_{date_str}_{timestamp}.tif"
                output_path = os.path.join(crop_dir, output_name)
                
                with rasterio.open(output_path, "w", **out_meta) as dest:
                    dest.write(out_image)
            
            # 删除临时拼接文件
            try:
                os.remove(mosaic_path)
            except:
                pass
            
            print(f"[CacheService] ✓ 拼接切图完成: {output_path}")
            return output_path
            
        finally:
            # 关闭所有文件
            for src in src_files:
                src.close()

    
    def prefetch_tiles(
        self,
        tile_ids: List[str],
        target_date: str,
        window_days: int = 7,
        skip_existing: bool = True
    ) -> Dict:
        """
        预取多个瓦片(后台任务使用,支持智能去重)
        
        优化点:
        1. 自动去重,跳过已存在的瓦片
        2. 批量检查,提高效率
        3. 容错处理,部分失败不影响整体
        
        Args:
            tile_ids: 瓦片ID列表
            target_date: 目标日期
            window_days: 搜索窗口
            skip_existing: 是否跳过已存在的瓦片
            
        Returns:
            预取结果统计
        """
        print(f"[CacheService] 开始预取 {len(tile_ids)} 个瓦片...")
        
        # 去重
        unique_tile_ids = list(set(tile_ids))
        if len(unique_tile_ids) < len(tile_ids):
            print(f"[CacheService] 去重后: {len(unique_tile_ids)} 个瓦片")
        
        success_count = 0
        skip_count = 0
        fail_count = 0
        
        # 批量检查缓存状态
        tiles_to_download = []
        
        if skip_existing:
            for tile_id in unique_tile_ids:
                tile_info = self.tile_manager.check_tile_cache(tile_id, target_date)
                
                if tile_info and not tile_info['is_expired']:
                    print(f"[CacheService] 跳过已存在的瓦片: {tile_id}")
                    skip_count += 1
                else:
                    tiles_to_download.append(tile_id)
        else:
            tiles_to_download = unique_tile_ids
        
        print(f"[CacheService] 需要下载 {len(tiles_to_download)} 个瓦片")
        
        # 下载瓦片
        for tile_id in tiles_to_download:
            try:
                self._download_tile(tile_id, target_date, window_days)
                success_count += 1
                print(f"[CacheService] ✓ 预取成功: {tile_id} ({success_count}/{len(tiles_to_download)})")
                
            except Exception as e:
                print(f"[CacheService] ✗ 预取失败 {tile_id}: {e}")
                fail_count += 1
        
        result = {
            'total': len(tile_ids),
            'unique': len(unique_tile_ids),
            'success': success_count,
            'skipped': skip_count,
            'failed': fail_count,
            'downloaded': success_count
        }
        
        print(f"[CacheService] 预取完成: {result}")
        return result
    
    def update_expired_tile(self, tile_id: str, date_acquired: str) -> bool:
        """
        更新过期瓦片
        
        Args:
            tile_id: 瓦片ID
            date_acquired: 原始日期
            
        Returns:
            是否成功
        """
        print(f"[CacheService] 更新过期瓦片: {tile_id} ({date_acquired})")
        
        try:
            # 重新下载
            self._download_tile(tile_id, date_acquired, window_days=7)
            return True
            
        except Exception as e:
            print(f"[CacheService] 更新失败: {e}")
            return False
    
    def get_cache_statistics(self) -> Dict:
        """
        获取缓存统计信息
        
        Returns:
            统计信息字典
        """
        stats = self.tile_manager.get_cache_stats()
        
        # 添加存储路径信息
        stats['storage_path'] = self.storage_path
        
        # 计算目录大小
        total_size = 0
        file_count = 0
        
        for root, dirs, files in os.walk(self.storage_path):
            for file in files:
                if file.endswith('.tif'):
                    file_path = os.path.join(root, file)
                    total_size += os.path.getsize(file_path)
                    file_count += 1
        
        stats['actual_files'] = file_count
        stats['actual_size_mb'] = total_size / (1024 * 1024)
        stats['actual_size_gb'] = total_size / (1024 * 1024 * 1024)
        
        return stats
    
    def _verify_tile(self, tile_path: str) -> bool:
        """
        验证瓦片文件完整性
        
        Args:
            tile_path: 瓦片文件路径
            
        Returns:
            是否有效
        """
        try:
            if not os.path.exists(tile_path):
                print(f"[CacheService] 文件不存在: {tile_path}")
                return False
            
            # 检查文件大小
            file_size = os.path.getsize(tile_path)
            if file_size < 1024:  # 小于1KB肯定有问题
                print(f"[CacheService] 文件太小: {file_size} bytes")
                return False
            
            # 使用rasterio验证
            with rasterio.open(tile_path) as src:
                # 检查波段数(Sentinel-2应该有11个波段)
                if src.count < 11:
                    print(f"[CacheService] 波段数不足: {src.count} < 11")
                    return False
                
                # 读取第一个波段检查数据
                data = src.read(1)
                
                # 检查是否全是无效值
                if np.all(data == 0):
                    print(f"[CacheService] 数据全为0")
                    return False
                
                if np.all(np.isnan(data)):
                    print(f"[CacheService] 数据全为NaN")
                    return False
                
                # 检查有效数据比例
                valid_ratio = np.sum(~np.isnan(data) & (data != 0)) / data.size
                if valid_ratio < 0.01:  # 有效数据少于1%
                    print(f"[CacheService] 有效数据太少: {valid_ratio*100:.2f}%")
                    return False
                
                print(f"[CacheService] ✓ 瓦片验证通过: {src.count}波段, {valid_ratio*100:.1f}%有效数据")
                return True
                
        except Exception as e:
            print(f"[CacheService] 验证失败: {e}")
            return False
