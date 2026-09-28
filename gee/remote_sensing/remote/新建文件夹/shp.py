# import ee
# import time
# import os
# from pydrive2.auth import GoogleAuth
# from pydrive2.drive import GoogleDrive
# import geopandas as gpd  # !! 更改点: 导入 geopandas !!
#
# # --- 1. GEE 初始化 ---
# try:
#     ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
#     print("GEE 初始化成功！")
# except Exception as e:
#     print(f"GEE 初始化失败，请确保你已运行 'earthengine authenticate': {e}")
#     # 你可能需要再次运行 'earthengine authenticate'
#     # ee.Authenticate()
#     # ee.Initialize()
#
#
# # --- 2. Google Drive 认证辅助函数 ---
# def authenticate_gdrive():
#     """使用 client_secrets.json 进行 Google Drive 认证"""
#     gauth = GoogleAuth()
#     gauth.settings['access_type'] = 'offline'
#     gauth.LoadCredentialsFile("mycreds.txt")
#     if gauth.credentials is None:
#         gauth.LocalWebserverAuth()
#     elif gauth.access_token_expired:
#         gauth.Refresh()
#     else:
#         gauth.Authorize()
#     gauth.SaveCredentialsFile("mycreds.txt")
#     return GoogleDrive(gauth)
#
#
# # --- 3. GEE 导出函数 (不变) ---
# def export_image_to_drive(
#         aoi,
#         target_date,
#         window_days,
#         file_name,
#         drive_folder,
#         scale=10
# ):
#     """
#     在 GEE 中处理影像并启动导出任务到 Google Drive
#     """
#     print("开始 GEE 导出任务...")
#
#     # 1. 定义搜索日期范围
#     target = ee.Date(target_date)
#     start_search = target.advance(-window_days, 'day')
#     end_search = target.advance(window_days, 'day')
#
#     print(f"正在 {target_date} 前后 {window_days} 天内搜索云量最低的影像...")
#
#     # 2. 搜索
#     collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
#         .filterDate(start_search, end_search) \
#         .filterBounds(aoi)
#
#     # 3. 排序并选择最佳影像
#     sorted_collection = collection.sort('CLOUDY_PIXEL_PERCENTAGE')
#
#     count = sorted_collection.size().getInfo()
#     if count == 0:
#         print(f"!! 错误：在 {start_search.format().getInfo()} 到 {end_search.format().getInfo()} 范围内，")
#         print(f"   未找到任何影像。请检查你的AOI和日期范围。")
#         return False
#
#     image = ee.Image(sorted_collection.first()).clip(aoi)
#
#     found_date = ee.Date(image.get('system:time_start')).format('YYYY-MM-dd').getInfo()
#     cloud_cover = image.get('CLOUDY_PIXEL_PERCENTAGE').getInfo()
#     print(f"--> 成功找到影像！实际拍摄日期: {found_date} (云量: {cloud_cover:.2f}%)")
#
#     # --- 波段处理 (匹配 API.PY) ---
#     GEE_BANDS = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B8', 'B8A', 'B9', 'B11', 'B12']
#     API_BANDS = ['B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B08', 'B8A', 'B09', 'B11', 'B12']
#
#     image_to_export = image.select(GEE_BANDS, API_BANDS) \
#         .multiply(0.0001) \
#         .toFloat()
#
#     # 设置导出任务
#     task_config = {
#         'image': image_to_export,
#         'description': file_name,
#         'folder': drive_folder,
#         'fileNamePrefix': file_name,
#         'region': aoi,
#         'scale': scale,
#         'crs': 'EPSG:4326',
#         'fileFormat': 'GeoTIFF'
#     }
#
#     task = ee.batch.Export.image.toDrive(**task_config)
#     task.start()
#
#     # --- 自动化关键：等待任务完成 ---
#     print(f"任务 '{file_name}' (日期: {found_date}) 已启动。正在等待任务完成...")
#     while task.active():
#         status = task.status()['state']
#         print(f"任务状态: {status}")
#         if status == 'COMPLETED':
#             print("GEE 任务完成！")
#             return True
#         elif status == 'FAILED':
#             print(f"GEE 任务失败: {task.status()['error_message']}")
#             return False
#         time.sleep(30)
#
#     if task.status()['state'] == 'COMPLETED':
#         print("GEE 任务完成！")
#         return True
#     else:
#         print(f"任务未激活，最终状态: {task.status()['state']}")
#         return False
#
#
# # --- 4. Google Drive 下载函数 (不变) ---
# def download_file_from_drive(drive_folder, file_name, local_download_path):
#     """
#     从 Google Drive 下载指定的文件
#     """
#     print("正在认证 Google Drive...")
#     drive = authenticate_gdrive()
#     print("Google Drive 认证成功。")
#
#     # 1. 查找目标文件夹的 ID
#     folder_id = None
#     folder_list = drive.ListFile(
#         {'q': f"title='{drive_folder}' and mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
#     if folder_list:
#         folder_id = folder_list[0]['id']
#     else:
#         print(f"未在 Google Drive 中找到文件夹: {drive_folder}")
#         return
#
#     # 2. 在该文件夹中查找文件
#     print(f"正在文件夹 '{drive_folder}' 中搜索文件 '{file_name}.tif'...")
#     file_obj = None
#     search_attempts = 0
#     while search_attempts < 10:
#         file_list = drive.ListFile(
#             {'q': f"title='{file_name}.tif' and '{folder_id}' in parents and trashed=false"}).GetList()
#         if file_list:
#             file_obj = file_list[0]
#             print(f"找到文件: {file_obj['title']} (ID: {file_obj['id']})")
#             break
#         else:
#             print(f"未找到文件，等待 30 秒后重试...")
#             search_attempts += 1
#             time.sleep(30)
#
#     if not file_obj:
#         print(f"在 Google Drive 中找不到文件: {file_name}.tif")
#         return
#
#     # 3. 下载文件
#     print(f"正在下载文件到: {local_download_path}...")
#     file_obj.GetContentFile(local_download_path)
#     print("下载完成！")
#
#
# # --- 5. 主执行逻辑 (!! 已修改 !!) ---
# if __name__ == "__main__":
#     print(time.time())
#
#     # --- 在这里配置你的参数 ---
#
#     # 1. 定义你的地块 (AOI - Area of Interest)
#     # --- !! 更改点: 从 SHP 文件读取 !! ---
#     # 移除了硬编码的 coords_list
#     # MY_PARCEL_AOI = ee.Geometry.Polygon(coords_list)
#
#     MY_PARCEL_AOI = None
#     SHP_FILE_PATH = r"F:\gee\shp\2155186b-b3da-4c7a-9790-c4c6c7e7c1c2.shp"  # <-- !! 在这里设置你的 SHP 文件路径 !!
#
#     if not os.path.exists(SHP_FILE_PATH):
#         print(f"!! 错误：找不到 SHP 文件: {SHP_FILE_PATH}")
#         print("请确保 .shp, .shx, .dbf 等文件都在该路径，并更新 SHP_FILE_PATH 变量。")
#     else:
#         try:
#             print(f"正在从 {SHP_FILE_PATH} 读取 AOI...")
#             # 1. 使用 geopandas 读取
#             gdf = gpd.read_file(SHP_FILE_PATH)
#
#             # 2. (可选但推荐) 确保是 WGS84 (EPSG:4326)，GEE 偏好使用此坐标系
#             if gdf.crs.to_epsg() != 4326:
#                 print(f"正在将 CRS 从 {gdf.crs.to_string()} 转换为 EPSG:4326...")
#                 gdf = gdf.to_crs(epsg=4326)
#
#             # 3. 将所有地块合并 (dissolve) 为一个单一的几何形状
#             #    这可以处理 SHP 中有多个地块（features）的情况
#             combined_geometry = gdf.dissolve().geometry.iloc[0]
#
#             # 4. 将 geopandas 几何图形 转换为 GEE 几何图形
#             #    我们使用 __geo_interface__ 来获取 GeoJSON 格式
#             MY_PARCEL_AOI = ee.Geometry(combined_geometry.__geo_interface__)
#             print("AOI 加载成功！")
#
#         except Exception as e:
#             print(f"!! 错误：读取 SHP 文件失败: {e}")
#
#     # 2. 定义目标日期和搜索窗口
#     TARGET_DATE = '2025-07-31'
#     SEARCH_WINDOW_DAYS = 2
#
#     # 3. 定义文件名和路径
#     FILE_NAME_BASE = f'my_parcel_image_se_target_{TARGET_DATE}'
#     DRIVE_FOLDER_NAME = 'GEE_Exports'
#     LOCAL_DOWNLOAD_PATH = os.path.join(os.getcwd(), f"{FILE_NAME_BASE}.tif")
#
#     # -----------------------------------
#
#     # 只有在 AOI 成功加载后才继续
#     if MY_PARCEL_AOI:
#         print(f"--- 任务开始 ---")
#         print(f"地块 AOI: [从 {SHP_FILE_PATH} 加载]")
#         print(f"目标日期: {TARGET_DATE} (搜索范围: +/- {SEARCH_WINDOW_DAYS} 天)")
#         print(f"目标文件名: {FILE_NAME_BASE}.tif")
#         print(f"---------------------")
#
#         # 执行 GEE 导出
#         export_success = export_image_to_drive(
#             aoi=MY_PARCEL_AOI,
#             target_date=TARGET_DATE,
#             window_days=SEARCH_WINDOW_DAYS,
#             file_name=FILE_NAME_BASE,
#             drive_folder=DRIVE_FOLDER_NAME,
#             scale=10
#         )
#
#         # 如果 GEE 导出成功，则执行下载
#         if export_success:
#             download_file_from_drive(
#                 drive_folder=DRIVE_FOLDER_NAME,
#                 file_name=FILE_NAME_BASE,
#                 local_download_path=LOCAL_DOWNLOAD_PATH
#             )
#         else:
#             print("由于 GEE 导出失败，下载被跳过。")
#     else:
#         print("由于 AOI 未能成功加载，脚本已停止。请检查 SHP_FILE_PATH。")

import ee
import time
import os
from pydrive2.auth import GoogleAuth
from pydrive2.drive import GoogleDrive
import geopandas as gpd

# --- 1. GEE 初始化 ---
try:
    ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
    print("GEE 初始化成功！")
except Exception as e:
    print(f"GEE 初始化失败，请确保你已运行 'earthengine authenticate': {e}")


# --- 2. Google Drive 认证辅助函数 ---
def authenticate_gdrive():
    """使用 client_secrets.json 进行 Google Drive 认证"""
    gauth = GoogleAuth()
    gauth.settings['access_type'] = 'offline'
    gauth.LoadCredentialsFile("mycreds.txt")
    if gauth.credentials is None:
        gauth.LocalWebserverAuth()
    elif gauth.access_token_expired:
        gauth.Refresh()
    else:
        gauth.Authorize()
    gauth.SaveCredentialsFile("mycreds.txt")
    return GoogleDrive(gauth)


# --- 3. 云掩膜函数 (不变) ---
def mask_s2_clouds(image):
    """
    使用 QA60 波段掩膜 Sentinel-2 影像中的云和卷云
    并在此处统一进行归一化处理
    """
    qa = image.select('QA60')
    cloud_bit_mask = 1 << 10
    cirrus_bit_mask = 1 << 11
    mask = qa.bitwiseAnd(cloud_bit_mask).eq(0) \
        .And(qa.bitwiseAnd(cirrus_bit_mask).eq(0))

    # .updateMask() 会移除云像素
    # .multiply(0.0001) 进行归一化
    return image.updateMask(mask).multiply(0.0001).toFloat()


# --- 4. GEE 导出函数 (!! 关键修改 !!) ---
def export_image_to_drive(
        aoi,
        target_date,
        window_days,
        file_name,
        drive_folder,
        scale=10
):
    """
    在 GEE 中处理影像（去云、选择最佳）并启动导出任务
    """
    print("开始 GEE 导出任务...")

    # 1. 定义搜索日期范围
    target = ee.Date(target_date)
    start_search = target.advance(-window_days, 'day')
    end_search = target.advance(window_days, 'day')

    print(f"正在 {target_date} 前后 {window_days} 天内搜索 AOI 覆盖率最高的影像...")

    # 2. 搜索并立即应用云掩膜
    collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
        .filterDate(start_search, end_search) \
        .filterBounds(aoi) \
        .map(mask_s2_clouds)  # <-- 关键: 先对所有影像去云

    # 3. !! 更改点: 计算每张影像在 AOI 内的有效覆盖率 !!

    def calculate_valid_coverage(image):
        """计算 AOI 内的有效像素百分比"""
        # .unmask(0) 将透明像素（掩膜外）变为 0
        # .neq(0) 将所有有效像素变为 1
        valid_pixels = image.select('B2').unmask(0).neq(0)

        # .reduceRegion 计算 AOI 内的均值
        # mean 为 1 意味着 100% 覆盖，0.5 意味着 50% 覆盖
        stats = valid_pixels.reduceRegion(
            reducer=ee.Reducer.mean(),
            geometry=aoi,
            scale=scale,
            maxPixels=1e9
        )
        # 将结果 (例如 0.85) 设为影像的一个新属性
        return image.set('valid_coverage', stats.get('B2'))

    # 将计算覆盖率的函数应用到集合中的每张影像
    coverage_collection = collection.map(calculate_valid_coverage)

    # 4. !! 更改点: 按 AOI 覆盖率降序排序 !!
    #    (False) 表示降序，我们想要覆盖率最高的
    sorted_collection = coverage_collection.sort('valid_coverage', False)

    # 检查是否找到了影像
    count = sorted_collection.size().getInfo()
    if count == 0:
        print(f"!! 错误：在 {start_search.format().getInfo()} 到 {end_search.format().getInfo()} 范围内，")
        print(f"   未找到任何影像。请检查你的AOI和日期范围。")
        return False

    # 5. !! 更改点: 选择最佳影像 (不再是 median) !!
    #    .first() 现在是 AOI 覆盖率最高的那一张
    image = ee.Image(sorted_collection.first()).clip(aoi)

    # 打印出我们实际找到的影像信息
    found_date = ee.Date(image.get('system:time_start')).format('YYYY-MM-dd').getInfo()
    valid_coverage = image.get('valid_coverage').getInfo() * 100
    print(f"--> 成功找到最佳影像！")
    print(f"    实际拍摄日期: {found_date}")
    print(f"    地块 (AOI) 有效像素覆盖率: {valid_coverage:.2f}%")

    if valid_coverage < 50:
        print(f"!! 警告: 最佳影像的有效像素覆盖率低于 50% ({valid_coverage:.2f}%)。")
        print(f"   这可能是由于云、阴影或搜索窗口太小导致的。")

    # --- 波段处理 (匹配 API.PY) ---
    GEE_BANDS = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B8', 'B8A', 'B9', 'B11', 'B12']
    API_BANDS = ['B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B08', 'B8A', 'B09', 'B11', 'B12']

    # .multiply(0.0001).toFloat() 已在 mask_s2_clouds 中完成
    image_to_export = image.select(GEE_BANDS, API_BANDS)

    # 设置导出任务
    task_config = {
        'image': image_to_export,
        'description': file_name,
        'folder': drive_folder,
        'fileNamePrefix': file_name,
        'region': aoi,
        'scale': scale,
        'crs': 'EPSG:4326',
        'fileFormat': 'GeoTIFF'
    }

    task = ee.batch.Export.image.toDrive(**task_config)
    task.start()

    # --- 自动化关键：等待任务完成 ---
    print(f"任务 '{file_name}' (日期: {found_date}) 已启动。正在等待任务完成...")
    while task.active():
        status = task.status()['state']
        print(f"任务状态: {status}")
        if status == 'COMPLETED':
            print("GEE 任务完成！")
            return True
        elif status == 'FAILED':
            print(f"GEE 任务失败: {task.status()['error_message']}")
            return False
        time.sleep(30)

    if task.status()['state'] == 'COMPLETED':
        print("GEE 任务完成！")
        return True
    else:
        print(f"任务未激活，最终状态: {task.status()['state']}")
        return False


# --- 5. Google Drive 下载函数 (不变) ---
def download_file_from_drive(drive_folder, file_name, local_download_path):
    """
    从 Google Drive 下载指定的文件
    """
    print("正在认证 Google Drive...")
    drive = authenticate_gdrive()
    print("Google Drive 认证成功。")

    # 1. 查找目标文件夹的 ID
    folder_id = None
    folder_list = drive.ListFile(
        {'q': f"title='{drive_folder}' and mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
    if folder_list:
        folder_id = folder_list[0]['id']
    else:
        print(f"未在 Google Drive 中找到文件夹: {drive_folder}")
        return

    # 2. 在该文件夹中查找文件
    print(f"正在文件夹 '{drive_folder}' 中搜索文件 '{file_name}.tif'...")
    file_obj = None
    search_attempts = 0
    while search_attempts < 10:
        file_list = drive.ListFile(
            {'q': f"title='{file_name}.tif' and '{folder_id}' in parents and trashed=false"}).GetList()
        if file_list:
            file_obj = file_list[0]
            print(f"找到文件: {file_obj['title']} (ID: {file_obj['id']})")
            break
        else:
            print(f"未找到文件，等待 30 秒后重试...")
            search_attempts += 1
            time.sleep(30)

    if not file_obj:
        print(f"在 Google Drive 中找不到文件: {file_name}.tif")
        return

    # 3. 下载文件
    print(f"正在下载文件到: {local_download_path}...")
    file_obj.GetContentFile(local_download_path)
    print("下载完成！")


# --- 6. 主执行逻辑 (不变) ---
if __name__ == "__main__":
    print(time.time())

    # --- 在这里配置你的参数 ---

    # 1. 定义你的地块 (AOI - Area of Interest)
    MY_PARCEL_AOI = None
    SHP_FILE_PATH = r"F:\gee\shp\2155186b-b3da-4c7a-9790-c4c6c7e7c1c2.shp"

    if not os.path.exists(SHP_FILE_PATH):
        print(f"!! 错误：找不到 SHP 文件: {SHP_FILE_PATH}")
        print("请确保 .shp, .shx, .dbf 等文件都在该路径，并更新 SHP_FILE_PATH 变量。")
    else:
        try:
            print(f"正在从 {SHP_FILE_PATH} 读取 AOI...")
            gdf = gpd.read_file(SHP_FILE_PATH)

            if gdf.crs.to_epsg() != 4326:
                print(f"正在将 CRS 从 {gdf.crs.to_string()} 转换为 EPSG:4326...")
                gdf = gdf.to_crs(epsg=4326)

            combined_geometry = gdf.dissolve().geometry.iloc[0]
            MY_PARCEL_AOI = ee.Geometry(combined_geometry.__geo_interface__)
            print("AOI 加载成功！")

        except Exception as e:
            print(f"!! 错误：读取 SHP 文件失败: {e}")

    # 2. 定义目标日期和搜索窗口
    TARGET_DATE = '2025-07-31'
    SEARCH_WINDOW_DAYS = 2  # +/- 2 天 (共 5 天窗口)

    # 3. 定义文件名和路径
    # !! 更改点: 文件名改回 'target'，因为它是单一影像 !!
    FILE_NAME_BASE = f'my_parcel_image_se_target_{TARGET_DATE}'
    DRIVE_FOLDER_NAME = 'GEE_Exports'
    LOCAL_DOWNLOAD_PATH = os.path.join(os.getcwd(), f"{FILE_NAME_BASE}.tif")

    # -----------------------------------

    # 只有在 AOI 成功加载后才继续
    if MY_PARCEL_AOI:
        print(f"--- 任务开始 ---")
        print(f"地块 AOI: [从 {SHP_FILE_PATH} 加载]")
        print(f"目标日期: {TARGET_DATE} (搜索范围: +/- {SEARCH_WINDOW_DAYS} 天)")
        print(f"目标文件名: {FILE_NAME_BASE}.tif")
        print(f"---------------------")

        # 执行 GEE 导出
        export_success = export_image_to_drive(
            aoi=MY_PARCEL_AOI,
            target_date=TARGET_DATE,
            window_days=SEARCH_WINDOW_DAYS,
            file_name=FILE_NAME_BASE,
            drive_folder=DRIVE_FOLDER_NAME,
            scale=10
        )

        # 如果 GEE 导出成功，则执行下载
        if export_success:
            download_file_from_drive(
                drive_folder=DRIVE_FOLDER_NAME,
                file_name=FILE_NAME_BASE,
                local_download_path=LOCAL_DOWNLOAD_PATH
            )
        else:
            print("由于 GEE 导出失败，下载被跳过。")
    else:
        print("由于 AOI 未能成功加载，脚本已停止。请检查 SHP_FILE_PATH。")