import ee
import json
import os
import time
from google.oauth2.credentials import Credentials
from google.oauth2 import service_account

# ================= 配置区域 =================
# 1. 凭证文件路径 (根据您的描述修改)
TOKEN_FILE_PATH = r"F:\gee\remote_sensing\remote\新建文件夹\token\gee.json"

# 2. GEE 项目 ID
PROJECT_ID = "<REDACTED_GCP_PROJECT_ID>"

# 3. 导出测试配置
TARGET_DATE = "2023-08-01"
DRIVE_FOLDER = "GEE_Exports"  # 请确保 Drive 根目录下有这个文件夹，或者允许 GEE 创建
# ===========================================

def load_credentials(token_path):
    """加载凭证"""
    if not os.path.exists(token_path):
        raise FileNotFoundError(f"找不到凭证文件: {token_path}")
    
    with open(token_path, 'r') as f:
        token_json = json.load(f)
        
    print(f"[-] 加载凭证文件成功")
    
    if 'private_key' in token_json:
        print("[-] 类型: 服务账号 (Service Account)")
        # 定义必要的权限范围
        SCOPES = [
            'https://www.googleapis.com/auth/earthengine',
            'https://www.googleapis.com/auth/drive',
            'https://www.googleapis.com/auth/cloud-platform'
        ]
        return service_account.Credentials.from_service_account_info(token_json, scopes=SCOPES)
    elif 'refresh_token' in token_json:
        print("[-] 类型: 个人账号 (User OAuth)")
        
        # 使用 GEE CLI 默认的 Client ID (如果文件中没有)
        client_id = token_json.get('client_id', '517222506229-vsmmajv00ul0bs7p89v5m89qs8eb9359.apps.googleusercontent.com')
        client_secret = token_json.get('client_secret', 'secret')
        
        return Credentials(
            None,
            refresh_token=token_json['refresh_token'],
            token_uri=token_json.get('token_uri', 'https://oauth2.googleapis.com/token'),
            client_id=client_id,
            client_secret=client_secret
        )
    else:
        raise ValueError("无法识别的凭证格式 (既无 private_key 也无 refresh_token)")

def test_gee_export():
    print("="*50)
    print("🚀 开始 GEE 本地导出测试")
    print("="*50)

    try:
        # 1. 初始化
        # creds = load_credentials(TOKEN_FILE_PATH)
        print("[-] 正在初始化 GEE (使用本地默认凭证)...")
        ee.Initialize(project=PROJECT_ID)
        print(f"[+] GEE 初始化成功! Project: {PROJECT_ID}")

        # 定义 AOI
        TEST_AOI = ee.Geometry.Polygon([
            [85.602, 44.502],
            [85.605, 44.502],
            [85.605, 44.505],
            [85.602, 44.505],
            [85.602, 44.502]
        ])

        # 2. 搜索影像
        print(f"\n[-] 搜索影像: {TARGET_DATE}...")
        collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
            .filterDate(ee.Date(TARGET_DATE).advance(-10, 'day'), ee.Date(TARGET_DATE).advance(10, 'day')) \
            .filterBounds(TEST_AOI) \
            .sort('CLOUDY_PIXEL_PERCENTAGE')
            
        count = collection.size().getInfo()
        if count == 0:
            print("[!] 未找到影像，测试中止")
            return
            
        print(f"[+] 找到 {count} 张影像")
        image = collection.first()
        date_str = ee.Date(image.get('system:time_start')).format('YYYY-MM-dd').getInfo()
        print(f"[-] 选择影像: {date_str}")

        # 3. 提交导出任务
        task_name = f"test_export_local_{int(time.time())}"
        print(f"\n[-] 提交导出任务: {task_name}")
        print(f"[-] 目标文件夹: {DRIVE_FOLDER}")
        
        task = ee.batch.Export.image.toDrive(
            image=image.select(['B4', 'B3', 'B2']),  # 仅导出 RGB 以减小体积
            description=task_name,
            folder=DRIVE_FOLDER,
            fileNamePrefix=task_name,
            region=TEST_AOI,
            scale=30,  # 降低分辨率以加快速度
            crs='EPSG:4326',
            fileFormat='GeoTIFF'
        )
        
        task.start()
        print(f"[+] 任务已提交! ID: {task.id}")

        # 4. 轮询状态
        print("\n[-] 开始轮询状态 (每10秒检查一次)...")
        while task.active():
            status = task.status()
            state = status['state']
            print(f"   >>> 状态: {state}")
            
            if state == 'FAILED':
                print(f"\n[X] 任务失败!")
                print(f"    错误详情: {status.get('error_message')}")
                print(f"    完整状态: {status}")
                break
            elif state == 'COMPLETED':
                print(f"\n[+] 任务成功完成!")
                print(f"    请检查 Google Drive 文件夹 '{DRIVE_FOLDER}'")
                break
                
            time.sleep(10)
            
        # 循环结束后的最终检查
        final_status = task.status()
        final_state = final_status['state']
        print(f"\n[-] 最终状态: {final_state}")
        
        if final_state == 'COMPLETED':
            print(f"[+] 任务成功完成!")
        elif final_state == 'FAILED':
            print(f"[X] 任务失败!")
            print(f"    错误详情: {final_status.get('error_message')}")
        else:
            print(f"[?] 任务结束于状态: {final_state}")
            print(f"    完整详情: {final_status}")

    except Exception as e:
        print(f"\n[X] 发生异常: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_gee_export()
