"""GEE 遥感图下载服务"""
import ee
import time
import os
from typing import Dict, List, Optional
from pydrive2.auth import GoogleAuth
from pydrive2.drive import GoogleDrive
from app.config import settings


class GEEService:
    """GEE 服务类 - 包装原 main.py 的功能"""
    
    def __init__(self):
        """初始化 GEE"""
        try:
            # 初始化 GEE (自动寻找凭证)
            print(f"[GEE] 正在初始化 Earth Engine (Project: {settings.GEE_PROJECT_ID})...")
            
            # 使用默认初始化，它会自动读取本地凭证文件或环境变量
            ee.Initialize(project=settings.GEE_PROJECT_ID)
            
            print(f"✓ GEE 初始化成功！")
                
        except Exception as e:
            print(f"✗ GEE 初始化失败: {e}")
            print(f"  建议检查: 凭证文件是否有效，项目ID是否正确，以及网络连接（代理）")
            raise

        # 缓存 Google Drive 对象
        self._drive = None

    def authenticate_gdrive(self) -> GoogleDrive:
        """Google Drive 认证（使用本地凭证）"""
        # 如果已经认证过，直接返回缓存的对象
        if self._drive is not None:
            print("[Drive] 使用缓存的认证对象")
            return self._drive
        
        print("=" * 60)
        print("[Drive] 开始 Google Drive 认证")
        print("=" * 60)
        
        try:
            # 使用本地文件进行认证 (默认会查找 settings.yaml 或 client_secrets.json)
            # 注意：首次运行需要在有浏览器的环境中进行授权，生成 credentials.json
            print("[Drive] 正在尝试本地认证...")
            
            # 使用默认设置，它会自动处理 local_webserver_auth
            gauth = GoogleAuth()
            
            # 尝试加载已保存的凭证
            gauth.LoadCredentialsFile("credentials.json")
            
            if gauth.credentials is None:
                # 如果没有保存的凭证，尝试从 client_secrets.json 进行认证
                print("[Drive] 未找到保存的凭证，尝试进行 OAuth 认证...")
                # 在服务器上，这可能需要 CommandLineAuth 或手动复制 URL
                # 这里默认尝试 LocalWebserverAuth，如果是在服务器上跑，可能需要改为 CommandLineAuth
                # 或者更好地，提前在本地生成 credentials.json 并上传
                gauth.LocalWebserverAuth()
            elif gauth.access_token_expired:
                # 刷新凭证
                print("[Drive] 凭证已过期，正在刷新...")
                gauth.Refresh()
            else:
                # 凭证有效
                print("[Drive] 凭证有效，直接使用")
                gauth.Authorize()
            
            # 保存更新后的凭证
            gauth.SaveCredentialsFile("credentials.json")
            
            # 初始化 Drive 对象
            self._drive = GoogleDrive(gauth)
            
            print("[Drive] ✓ 认证成功")
            print("=" * 60)
            
            return self._drive
            
        except Exception as e:
            print(f"[Drive] ❌ 认证失败: {e}")
            print("=" * 60)
            raise

    
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
        error_count = 0
        while task.active():
            try:
                status = task.status()
                status_state = status['state']
                print(f"[GEE] 任务状态: {status_state}")
                
                # 重置错误计数
                error_count = 0
                
                if status_state == 'COMPLETED':
                    print("[GEE] ✓ 导出完成！")
                    return {
                        'success': True,
                        'found_date': found_date,
                        'cloud_cover': cloud_cover,
                        'image_count': count
                    }
                elif status_state == 'FAILED':
                    print(f"[GEE] 任务失败详情: {status}")
                    error_msg = status.get('error_message', '未知错误')
                    raise Exception(f"GEE 导出失败: {error_msg}")
                    
            except Exception as e:
                error_count += 1
                print(f"[GEE] 获取任务状态失败 ({error_count}/10): {e}")
                if error_count >= 10:
                    raise Exception(f"连续获取任务状态失败: {e}")
            
            time.sleep(30)
        
        # 最终状态检查
        final_status = task.status()
        final_state = final_status['state']
        if final_state == 'COMPLETED':
            return {
                'success': True,
                'found_date': found_date,
                'cloud_cover': cloud_cover,
                'image_count': count
            }
        else:
            print(f"[GEE] 任务异常结束! 详细状态: {final_status}")
            error_msg = final_status.get('error_message', '未知错误')
            raise Exception(f"任务未完成，最终状态: {final_state}, 错误: {error_msg}")
    
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
        print("\n" + "=" * 60)
        print(f"[Drive] 开始下载文件: {file_name}.tif")
        print("=" * 60)
        
        drive = self.authenticate_gdrive()
        
        # 从数据库读取文件夹ID
        print("[Drive] 从数据库读取文件夹配置...")
        folder_id = getattr(settings, 'GEE_DRIVE_FOLDER_ID', None)
        
        if folder_id:
            # 使用文件夹ID直接访问
            print(f"[Drive] ✓ 使用配置的文件夹ID")
            print(f"[Drive]   文件夹ID: {folder_id}")
            print(f"[Drive]   配置来源: 数据库 (GEE_DRIVE_FOLDER_ID)")
        else:
            # 使用文件夹名称搜索
            folder_name = getattr(settings, 'GEE_DRIVE_FOLDER', 'GEE_Exports')
            print(f"[Drive] ⚠️  未配置文件夹ID，使用名称搜索")
            print(f"[Drive]   文件夹名称: {folder_name}")
            print(f"[Drive]   建议: 运行 python import_drive_token.py 配置文件夹ID")
            
            print(f"[Drive] 搜索名为 '{folder_name}' 的文件夹...")
            folder_list = drive.ListFile({
                'q': f"title='{folder_name}' and "
                     f"mimeType='application/vnd.google-apps.folder' and trashed=false"
            }).GetList()
            
            if not folder_list:
                print(f"[Drive] ❌ 未找到文件夹: {folder_name}")
                raise Exception(f"未找到 Google Drive 文件夹: {folder_name}")
            
            # 如果有多个同名文件夹，使用最老的那个
            if len(folder_list) > 1:
                print(f"[Drive] ⚠️  找到 {len(folder_list)} 个同名文件夹")
                print(f"[Drive] 按创建时间排序，使用最老的那个...")
                for i, folder in enumerate(folder_list, 1):
                    print(f"[Drive]   #{i}: {folder['id']} (创建于: {folder.get('createdDate', 'N/A')})")
                folder_list.sort(key=lambda x: x.get('createdDate', ''))
            
            folder_id = folder_list[0]['id']
            print(f"[Drive] ✓ 选择文件夹ID: {folder_id}")
        
        # 查找文件（最多尝试 10 次）
        print(f"\n[Drive] 开始搜索文件...")
        print(f"[Drive]   目标文件: {file_name}.tif")
        print(f"[Drive]   文件夹ID: {folder_id}")
        
        file_obj = None
        for attempt in range(10):
            print(f"\n[Drive] 尝试 {attempt + 1}/10...")
            
            file_list = drive.ListFile({
                'q': f"title='{file_name}.tif' and '{folder_id}' in parents and trashed=false"
            }).GetList()
            
            if file_list:
                file_obj = file_list[0]
                print(f"[Drive] ✓ 找到文件!")
                print(f"[Drive]   文件名: {file_obj['title']}")
                print(f"[Drive]   文件ID: {file_obj['id']}")
                if 'fileSize' in file_obj:
                    size_mb = int(file_obj['fileSize']) / (1024 * 1024)
                    print(f"[Drive]   大小: {size_mb:.2f} MB")
                print(f"[Drive]   修改时间: {file_obj.get('modifiedDate', 'N/A')}")
                break
            
            # 第一次没找到时，列出文件夹的内容用于调试
            if attempt == 0:
                print(f"[Drive] ⚠️  未找到目标文件")
                print(f"[Drive] 列出文件夹中的所有文件:")
                
                all_files = drive.ListFile({
                    'q': f"'{folder_id}' in parents and trashed=false"
                }).GetList()
                
                if not all_files:
                    print(f"[Drive]   文件夹为空！")
                    print(f"[Drive]   可能原因:")
                    print(f"[Drive]     1. GEE导出任务尚未完成")
                    print(f"[Drive]     2. GEE导出到了不同的文件夹")
                    print(f"[Drive]     3. 文件夹ID配置错误")
                else:
                    print(f"[Drive]   找到 {len(all_files)} 个文件:")
                    # 按修改时间排序，最新的在前
                    all_files.sort(key=lambda x: x.get('modifiedDate', ''), reverse=True)
                    for i, f in enumerate(all_files[:10], 1):
                        size_info = ""
                        if 'fileSize' in f:
                            size_mb = int(f['fileSize']) / (1024 * 1024)
                            size_info = f" ({size_mb:.2f} MB)"
                        print(f"[Drive]     {i}. {f['title']}{size_info}")
                        print(f"[Drive]        修改时间: {f.get('modifiedDate', 'N/A')}")
                    if len(all_files) > 10:
                        print(f"[Drive]     ... 还有 {len(all_files) - 10} 个文件")
            
            print(f"[Drive] 等待30秒后重试...")
            time.sleep(30)
        
        if not file_obj:
            raise Exception(f"在 Google Drive 中找不到文件: {file_name}.tif")
        
        # 下载文件
        print(f"\n[Drive] 正在下载到: {local_download_path}")
        file_obj.GetContentFile(local_download_path)
        
        # 验证文件
        if not os.path.exists(local_download_path):
            raise Exception("文件下载失败")
        
        file_size = os.path.getsize(local_download_path)
        print(f"[Drive] ✓ 下载完成！文件大小: {file_size / 1024 / 1024:.2f} MB")
        print("=" * 60)
        
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


