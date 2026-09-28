"""GEE服务 - 负责与Google Earth Engine交互"""
import ee
import os
import time
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from pydrive2.auth import GoogleAuth
from pydrive2.drive import GoogleDrive
from config.env import AppConfig


class GEEService:
    """GEE 服务类 - 包装原 main.py 的功能"""
    
    def __init__(self):
        """初始化 GEE"""
        try:
            ee.Initialize(project=getattr(AppConfig, 'GEE_PROJECT_ID', '<REDACTED_GCP_PROJECT_ID>'))
            print(f"✓ GEE 初始化成功！项目: {AppConfig.GEE_PROJECT_ID}")
        except Exception as e:
            print(f"✗ GEE 初始化失败: {e}")
            raise
        # 在构造函数中直接传入 settings
        gauth = GoogleAuth(settings=settings)

        # 显式执行服务账户认证
        gauth.ServiceAuth()
        return GoogleDrive(gauth)

    
    def export_image_to_drive(
        self,
        aoi_coords: List[List[float]],
        target_date: str,
        window_days: int,
        file_name: str,
        scale: int = 10
    ) -> Dict[str, any]:
        """
        导出影像到 Google Drive
        
        Returns:
            {
                'success': bool,
                'found_date': str,
                'cloud_cover': float,
                'image_count': int
            }
        """
        print(f"[GEE] 开始导出任务: {file_name}")
        
        # 创建 AOI 几何对象
        aoi = ee.Geometry.Polygon(aoi_coords)
        
        # 定义搜索日期范围
        target = ee.Date(target_date)
        start_search = target.advance(-window_days, 'day')
        end_search = target.advance(window_days, 'day')
        
        print(f"[GEE] 搜索范围: {target_date} 前后 {window_days} 天")
        
        # 搜索影像集合
        collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
            .filterDate(start_search, end_search) \
            .filterBounds(aoi)
        
        # 按云量排序
        sorted_collection = collection.sort('CLOUDY_PIXEL_PERCENTAGE')
        
        # 检查是否找到影像
        count = sorted_collection.size().getInfo()
        if count == 0:
            raise ValueError(f"在指定日期范围内未找到任何影像")
        
        print(f"[GEE] 找到 {count} 张影像")
        
        # 获取云量最低的影像
        image = ee.Image(sorted_collection.first()).clip(aoi)
        
        # 获取影像元数据
        found_date = ee.Date(image.get('system:time_start')).format('YYYY-MM-dd').getInfo()
        cloud_cover = image.get('CLOUDY_PIXEL_PERCENTAGE').getInfo()
        
        print(f"[GEE] 选择影像: {found_date}, 云量: {cloud_cover:.2f}%")
        
        # 波段处理
        image_to_export = image.select(settings.GEE_BANDS, settings.API_BANDS) \
            .multiply(0.0001) \
            .toFloat()
        
        # 设置导出任务
        task_config = {
            'image': image_to_export,
            'description': file_name,
            'folder': settings.GEE_DRIVE_FOLDER,
            'fileNamePrefix': file_name,
            'region': aoi,
            'scale': scale,
            'crs': 'EPSG:4326',
            'fileFormat': 'GeoTIFF'
        }
        
        task = ee.batch.Export.image.toDrive(**task_config)
        task.start()
        
        print(f"[GEE] 任务已启动，等待完成...")
        
        # 等待任务完成
        while task.active():
            status_state = task.status()['state']
            print(f"[GEE] 任务状态: {status_state}")
            
            if status_state == 'COMPLETED':
                print("[GEE] ✓ 导出完成！")
                return {
                    'success': True,
                    'found_date': found_date,
                    'cloud_cover': cloud_cover,
                    'image_count': count
                }
            elif status_state == 'FAILED':
                error_msg = task.status().get('error_message', '未知错误')
                raise Exception(f"GEE 导出失败: {error_msg}")
            
            time.sleep(30)
        
        # 最终状态检查
        final_state = task.status()['state']
        if final_state == 'COMPLETED':
            return {
                'success': True,
                'found_date': found_date,
                'cloud_cover': cloud_cover,
                'image_count': count
            }
        else:
            raise Exception(f"任务未完成，最终状态: {final_state}")
    
    def download_from_drive(
        self,
        file_name: str,
        local_download_path: str
    ) -> str:
        """
        从 Google Drive 下载文件
        
        Returns:
            本地文件路径
        """
        print(f"[Drive] 开始下载: {file_name}.tif")
        
        drive = self.authenticate_gdrive()
        
        # 查找文件夹
        folder_list = drive.ListFile({
            'q': f"title='{settings.GEE_DRIVE_FOLDER}' and "
                 f"mimeType='application/vnd.google-apps.folder' and trashed=false"
        }).GetList()
        
        if not folder_list:
            raise Exception(f"未找到 Google Drive 文件夹: {settings.GEE_DRIVE_FOLDER}")
        
        folder_id = folder_list[0]['id']
        
        # 查找文件（最多尝试 10 次）
        file_obj = None
        for attempt in range(10):
            file_list = drive.ListFile({
                'q': f"title='{file_name}.tif' and '{folder_id}' in parents and trashed=false"
            }).GetList()
            
            if file_list:
                file_obj = file_list[0]
                print(f"[Drive] ✓ 找到文件: {file_obj['title']}")
                break
            
            print(f"[Drive] 等待文件出现... ({attempt + 1}/10)")
            time.sleep(30)
        
        if not file_obj:
            raise Exception(f"在 Google Drive 中找不到文件: {file_name}.tif")
        
        # 下载文件
        print(f"[Drive] 正在下载到: {local_download_path}")
        file_obj.GetContentFile(local_download_path)
        
        # 验证文件
        if not os.path.exists(local_download_path):
            raise Exception("文件下载失败")
        
        file_size = os.path.getsize(local_download_path)
        print(f"[Drive] ✓ 下载完成！文件大小: {file_size / 1024 / 1024:.2f} MB")
        
        return local_download_path

    def get_sentinel2_dates(
        self,
        aoi_coords: List[List[float]],
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        cloud_cover_threshold: float = 20.0,
        predict_future: bool = False
    ) -> List[str]:
        """
        获取指定区域和时间范围内可用的 Sentinel-2 影像日期
        
        Args:
            aoi_coords: AOI 坐标列表
            start_date: 开始日期 (YYYY-MM-DD)
            end_date: 结束日期 (YYYY-MM-DD)
            cloud_cover_threshold: 云量阈值
            predict_future: 是否预测未来日期
            
        Returns:
            日期列表 (YYYY-MM-DD)
        """
        from datetime import datetime, timedelta
        
        current_year = datetime.now().year
        today = datetime.now().date()
        
        # 默认时间范围
        if not start_date:
            start_date = f"{current_year}-01-01"
        if not end_date:
            end_date = f"{current_year}-12-31"
            
        print(f"[GEE] 查询日期: {start_date} 至 {end_date}, 云量 < {cloud_cover_threshold}%, 预测未来: {predict_future}")
        
        # 创建 AOI
        aoi = ee.Geometry.Polygon(aoi_coords)
        
        # 1. 查询历史数据 (GEE)
        # 限制 GEE 查询范围不超过今天（因为 GEE 只有历史数据）
        gee_end_date = min(end_date, today.strftime('%Y-%m-%d'))
        
        historical_dates = []
        if start_date <= gee_end_date:
            collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
                .filterBounds(aoi) \
                .filterDate(start_date, ee.Date(gee_end_date).advance(1, 'day')) \
                .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', cloud_cover_threshold))
                
            # 获取日期列表
            dates = collection.aggregate_array('system:time_start')
            
            def format_date(timestamp):
                return ee.Date(timestamp).format('YYYY-MM-dd')
                
            formatted_dates = dates.map(format_date).distinct().sort()
            
            try:
                historical_dates = formatted_dates.getInfo()
                print(f"[GEE] 找到 {len(historical_dates)} 个历史日期")
            except Exception as e:
                print(f"[GEE] 查询历史日期失败: {e}")
                # 如果只是历史查询失败，可能不影响未来预测，但通常意味着 GEE 有问题
                raise Exception(f"查询历史日期失败: {str(e)}")
        
        # 2. 预测未来日期
        future_dates = []
        if predict_future and end_date > today.strftime('%Y-%m-%d'):
            print("[GEE] 开始预测未来日期...")
            try:
                # 获取最近的一个参考日期（不限云量，为了确定轨道周期）
                # 搜索过去 30 天
                ref_start = (today - timedelta(days=30)).strftime('%Y-%m-%d')
                ref_collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
                    .filterBounds(aoi) \
                    .filterDate(ref_start, today.strftime('%Y-%m-%d')) \
                    .sort('system:time_start', False) \
                    .limit(1)
                
                ref_image = ref_collection.first()
                ref_info = ref_image.getInfo()
                
                if ref_info:
                    ref_timestamp = ref_info['properties']['system:time_start']
                    # 转换为 datetime
                    ref_date = datetime.fromtimestamp(ref_timestamp / 1000.0).date()
                    print(f"[GEE] 参考影像日期: {ref_date}")
                    
                    # 目标结束日期
                    target_end = datetime.strptime(end_date, '%Y-%m-%d').date()
                    target_start = datetime.strptime(start_date, '%Y-%m-%d').date()
                    
                    # 从参考日期开始推算，每次加 5 天
                    next_date = ref_date + timedelta(days=5)
                    
                    while next_date <= target_end:
                        if next_date >= target_start and next_date > today:
                            future_dates.append(next_date.strftime('%Y-%m-%d'))
                        next_date += timedelta(days=5)
                        
                    print(f"[GEE] 预测了 {len(future_dates)} 个未来日期")
                else:
                    print("[GEE] ⚠️ 未找到参考影像，无法预测未来日期")
                    
            except Exception as e:
                print(f"[GEE] 预测未来日期失败: {e}")
                # 预测失败不应阻断历史数据的返回
        
        # 合并结果并去重排序
        all_dates = sorted(list(set(historical_dates + future_dates)))
        
        return all_dates


