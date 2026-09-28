# import ee
# import time
# import os
# from pydrive2.auth import GoogleAuth
# from pydrive2.drive import GoogleDrive
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
#     # 尝试加载已保存的凭据
#     gauth.LoadCredentialsFile("mycreds.txt")
#     if gauth.credentials is None:
#         # 如果没有凭据，则通过本地 Web 服务器进行身份验证
#         gauth.LocalWebserverAuth()
#     elif gauth.access_token_expired:
#         # 刷新凭据
#         gauth.Refresh()
#     else:
#         # 初始化授权
#         gauth.Authorize()
#     # 保存凭据供下次使用
#     gauth.SaveCredentialsFile("mycreds.txt")
#     return GoogleDrive(gauth)
#
#
# # --- 3. GEE 导出函数 (已修改以匹配 API) ---
# def export_image_to_drive(aoi, start_date, end_date, file_name, drive_folder, scale=10):
#     """
#     在 GEE 中处理影像并启动导出任务到 Google Drive
#     """
#     print("开始 GEE 导出任务...")
#
#     # --- 更改点 1: 切换到 S2_L2A ---
#     # 使用 COPERNICUS/S2_L2A (L2A级) 而不是 S2_SR
#     # S2_L2A 包含了你的 API (api.py) 中所有模型必需的波段
#     # (例如 B01, B05, B06, B09, B11, B12 等)
#     collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
#         .filterDate(start_date, end_date) \
#         .filterBounds(aoi) \
#         .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20))
#
#     # 获取中值合成
#     image = collection.median().clip(aoi)
#
#     # --- 更改点 2: 匹配 API.PY 的需求 ---
#
#     # 1. 定义 GEE S2_L2A 的原始波段名称
#     GEE_BANDS = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B8', 'B8A', 'B9', 'B11', 'B12']
#
#     # 2. 定义你的 api.py 期望的波段名称 (B01, B02...)
#     API_BANDS = ['B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B08', 'B8A', 'B09', 'B11', 'B12']
#
#     # 3. 导出处理
#     image_to_export = image.select(GEE_BANDS, API_BANDS) \
#         .multiply(0.0001) \
#         .toFloat()
#
#     # .select(GEE_BANDS, API_BANDS) 会在导出时自动重命名波段 (例如 B1 -> B01)
#     # .multiply(0.0001) 将 0-10000 的反射率缩放到 0-1.0，以通过 API 的验证
#     # .toFloat() 确保数据是浮点型，以保留小数
#
#     # 设置导出任务
#     task_config = {
#         'image': image_to_export,
#         'description': file_name,  # 这将是 Google Drive 中的文件名
#         'folder': drive_folder,  # Google Drive 中的文件夹名称
#         'fileNamePrefix': file_name,
#         'region': aoi,
#         'scale': scale,
#         'crs': 'EPSG:4326',  # 或你需要的投影
#         'fileFormat': 'GeoTIFF'  # 确保是 GeoTIFF
#     }
#
#     task = ee.batch.Export.image.toDrive(**task_config)
#     task.start()
#
#     # --- 自动化关键：等待任务完成 ---
#     print(f"任务 '{file_name}' 已启动。正在等待任务完成...")
#     while task.active():
#         status = task.status()['state']
#         print(f"任务状态: {status}")
#         if status == 'COMPLETED':
#             print("GEE 任务完成！")
#             return True
#         elif status == 'FAILED':
#             print(f"GEE 任务失败: {task.status()['error_message']}")
#             return False
#         time.sleep(30)  # 每 30 秒检查一次状态
#
#     # 最终状态检查（如果循环退出但非 active）
#     if task.status()['state'] == 'COMPLETED':
#         print("GEE 任务完成！")
#         return True
#     else:
#         print(f"任务未激活，最终状态: {task.status()['state']}")
#         return False
#
#
# # --- 4. Google Drive 下载函数 ---
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
#     # GEE 导出可能需要一点时间才会出现在 Drive API 中
#     print(f"正在文件夹 '{drive_folder}' 中搜索文件 '{file_name}.tif'...")
#     file_obj = None
#     search_attempts = 0
#     while search_attempts < 10:  # 尝试搜索 10 次（共 5 分钟）
#         # GEE 会自动添加 .tif 后缀
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
# # --- 5. 主执行逻辑 ---
# if __name__ == "__main__":
#
#     # --- 在这里配置你的参数 ---
#
#     # 1. 定义你的地块 (AOI - Area of Interest)
#     coords_list = [
#         [86.0388457571117, 44.552453045732314],
#         [86.0405231637295, 44.5488551561015],
#         [86.041776483188, 44.54909929116849],
#         [86.04386811483757, 44.54461996826588],
#         [86.04674205882675, 44.545110605417975],
#         [86.04626800158945, 44.54640573178081],
#         [86.04755328775938, 44.54663995980717],
#         [86.04429809841783, 44.5536415794847],
#         [86.0388457571117, 44.552453045732314]
#     ]
#     MY_PARCEL_AOI = ee.Geometry.Polygon(coords_list)
#
#     # 2. 定义日期范围
#     START_DATE = '2025-09-20'
#     END_DATE = '2025-9-30'
#
#     # 3. 定义文件名和路径
#     # GEE 导出时会自动添加 .tif 后缀
#     FILE_NAME_BASE = 'my_parcel_image_se'
#     DRIVE_FOLDER_NAME = 'GEE_Exports'  # 确保这个文件夹在你的 Google Drive 根目录中
#     LOCAL_DOWNLOAD_PATH = os.path.join(os.getcwd(), f"{FILE_NAME_BASE}.tif")
#
#     # -----------------------------------
#
#     # 执行 GEE 导出
#     export_success = export_image_to_drive(
#         aoi=MY_PARCEL_AOI,
#         start_date=START_DATE,
#         end_date=END_DATE,
#         file_name=FILE_NAME_BASE,
#         drive_folder=DRIVE_FOLDER_NAME,
#         scale=10  # Sentinel-2 的 10 米分辨率
#     )
#
#     # 如果 GEE 导出成功，则执行下载
#     if export_success:
#         download_file_from_drive(
#             drive_folder=DRIVE_FOLDER_NAME,
#             file_name=FILE_NAME_BASE,
#             local_download_path=LOCAL_DOWNLOAD_PATH
#         )
#     else:
#         print("由于 GEE 导出失败，下载被跳过。")


import ee
import time
import os
from pydrive2.auth import GoogleAuth
from pydrive2.drive import GoogleDrive

# --- 1. GEE 初始化 ---
try:
    ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
    print("GEE 初始化成功！")
except Exception as e:
    print(f"GEE 初始化失败，请确保你已运行 'earthengine authenticate': {e}")
    # 你可能需要再次运行 'earthengine authenticate'
    # ee.Authenticate()
    # ee.Initialize()


# --- 2. Google Drive 认证辅助函数 ---
def authenticate_gdrive():
    """使用 client_secrets.json 进行 Google Drive 认证"""
    gauth = GoogleAuth()
    gauth.settings['access_type'] = 'offline'
    # 尝试加载已保存的凭据
    gauth.LoadCredentialsFile("mycreds.txt")
    if gauth.credentials is None:
        # 如果没有凭据，则通过本地 Web 服务器进行身份验证
        gauth.LocalWebserverAuth()
    elif gauth.access_token_expired:
        # 刷新凭据
        gauth.Refresh()
    else:
        # 初始化授权
        gauth.Authorize()
    # 保存凭据供下次使用
    gauth.SaveCredentialsFile("mycreds.txt")
    return GoogleDrive(gauth)


# --- 3. GEE 导出函数 (!! 已修改为不过滤云量 !!) ---
def export_image_to_drive(
        aoi,
        target_date,
        window_days,
        file_name,
        drive_folder,
        scale=10
):
    """
    在 GEE 中处理影像并启动导出任务到 Google Drive
    """
    print("开始 GEE 导出任务...")

    # --- !! 关键逻辑修改 !! ---

    # 1. 定义搜索日期范围
    target = ee.Date(target_date)
    start_search = target.advance(-window_days, 'day')
    end_search = target.advance(window_days, 'day')

    print(f"正在 {target_date} 前后 {window_days} 天内搜索云量最低的影像...")

    # 2. 搜索
    collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
        .filterDate(start_search, end_search) \
        .filterBounds(aoi) \

    # --- !! 更改点: 移除了云量过滤器 !! ---
    # .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) <-- 此行已移除

    # 3. 排序并选择最佳影像
    # 按云量百分比升序排序
    sorted_collection = collection.sort('CLOUDY_PIXEL_PERCENTAGE')

    # 检查是否找到了影像
    count = sorted_collection.size().getInfo()
    if count == 0:
        print(f"!! 错误：在 {start_search.format().getInfo()} 到 {end_search.format().getInfo()} 范围内，")
        print(f"   未找到任何影像。请检查你的AOI和日期范围。")
        return False

    # 获取云量最低的那一张
    image = ee.Image(sorted_collection.first()).clip(aoi)

    # 打印出我们实际找到的影像日期和云量 (这满足了你的需求)
    found_date = ee.Date(image.get('system:time_start')).format('YYYY-MM-dd').getInfo()
    cloud_cover = image.get('CLOUDY_PIXEL_PERCENTAGE').getInfo()
    print(f"--> 成功找到影像！实际拍摄日期: {found_date} (云量: {cloud_cover:.2f}%)")

    # --- 波段处理 (匹配 API.PY) ---
    GEE_BANDS = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B8', 'B8A', 'B9', 'B11', 'B12']
    API_BANDS = ['B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B08', 'B8A', 'B09', 'B11', 'B12']

    image_to_export = image.select(GEE_BANDS, API_BANDS) \
        .multiply(0.0001) \
        .toFloat()

    # 设置导出任务
    task_config = {
        'image': image_to_export,
        'description': file_name,  # 这将是 Google Drive 中的文件名
        'folder': drive_folder,  # Google Drive 中的文件夹名称
        'fileNamePrefix': file_name,
        'region': aoi,
        'scale': scale,
        'crs': 'EPSG:4326',  # 或你需要的投影
        'fileFormat': 'GeoTIFF'  # 确保是 GeoTIFF
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
        time.sleep(30)  # 每 30 秒检查一次状态

    if task.status()['state'] == 'COMPLETED':
        print("GEE 任务完成！")
        return True
    else:
        print(f"任务未激活，最终状态: {task.status()['state']}")
        return False


# --- 4. Google Drive 下载函数 (不变) ---
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
    while search_attempts < 10:  # 尝试搜索 10 次（共 5 分钟）
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


# --- 5. 主执行逻辑 (参数不变) ---
if __name__ == "__main__":
    print(time.time())

    # --- 在这里配置你的参数 ---

    # 1. 定义你的地块 (AOI - Area of Interest)
    coords_list = [
        [86.0388457571117, 44.552453045732314],
        [86.0405231637295, 44.5488551561015],
        [86.041776483188, 44.54909929116849],
        [86.04386811483757, 44.54461996826588],
        [86.04674205882675, 44.545110605417975],
        [86.04626800158945, 44.54640573178081],
        [86.04755328775938, 44.54663995980717],
        [86.04429809841783, 44.5536415794847],
        [86.0388457571117, 44.552453045732314]
    ]
    MY_PARCEL_AOI = ee.Geometry.Polygon(coords_list)

    # 2. 定义目标日期和搜索窗口
    TARGET_DATE = '2025-09-21'  # 你想要的目标日期
    SEARCH_WINDOW_DAYS = 2  # 搜索该日期前后 5 天

    # 3. 定义文件名和路径
    # GEE 导出时会自动添加 .tif 后缀
    # 文件名现在反映了你的 "目标日期"
    FILE_NAME_BASE = f'my_parcel_image_se_target_{TARGET_DATE}'
    DRIVE_FOLDER_NAME = 'GEE_Exports'  # 确保这个文件夹在你的 Google Drive 根目录中
    LOCAL_DOWNLOAD_PATH = os.path.join(os.getcwd(), f"{FILE_NAME_BASE}.tif")

    # -----------------------------------

    print(f"--- 任务开始 ---")
    print(f"地块 AOI: [坐标已加载]")
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
        scale=10  # Sentinel-2 的 10 米分辨率
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