import requests
import json
import uuid
import random
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

# ================= 配置区域 =================
API_HOST = "http://192.168.112.100:5666"
API_URL = f"{API_HOST}/api/smartplant/parcelInfo"

HEADERS = {
    "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJzeXNfdXNlcjoxIiwicm5TdHIiOiI1WXVIRnhSbmkzNVBKTEZqMGo2OGVuTWJTUFFXc1RIdSIsImNsaWVudGlkIjoiZTVjZDdlNDg5MWJmOTVkMWQxOTIwNmNlMjRhN2IzMmUiLCJ0ZW5hbnRJZCI6IjAwMDAwMCIsInVzZXJJZCI6MSwidXNlck5hbWUiOiJhZG1pbiIsImRlcHRJZCI6MTAzLCJkZXB0TmFtZSI6IiIsImRlcHRDYXRlZ29yeSI6IiJ9.icIgFfeaQYEJgXrp9iRGcMFuswasaJ1JA_XE3IVNn0M",
    "clientId": "e5cd7e4891bf95d1d19206ce24a7b32e",
    "Content-Type": "application/json"
}

# 生成数据的总数
TOTAL_RECORDS = 6000
# 并发线程数 (建议 10-50，过高可能导致服务器限流)
MAX_WORKERS = 20


# ================= 工具函数 =================

def generate_random_polygon():
    """
    生成一个随机的矩形地块坐标（闭合）
    中心点设定在某个大概的经纬度范围内（例如：经度113-114，纬度23-24）
    """
    # 随机基准点
    base_lng = 113.0 + random.uniform(0, 1)
    base_lat = 23.0 + random.uniform(0, 1)

    # 随机大小 (约 100米 - 500米范围)
    width = random.uniform(0.001, 0.005)
    height = random.uniform(0.001, 0.005)

    # 构造矩形坐标 (左下 -> 右下 -> 右上 -> 左上 -> 左下)
    # 注意：必须闭合（首尾坐标一致）
    coords = [
        {"lng": round(base_lng, 6), "lat": round(base_lat, 6)},
        {"lng": round(base_lng + width, 6), "lat": round(base_lat, 6)},
        {"lng": round(base_lng + width, 6), "lat": round(base_lat + height, 6)},
        {"lng": round(base_lng, 6), "lat": round(base_lat + height, 6)},
        {"lng": round(base_lng, 6), "lat": round(base_lat, 6)}  # 闭合点
    ]
    return coords


def upload_task(index):
    """
    单个上传任务
    """
    # 生成随机名称
    random_suffix = uuid.uuid4().hex[:8]
    parcel_name = f"压力测试_{index}_{random_suffix}"

    # 生成随机坐标
    coords_list = generate_random_polygon()
    coords_str = json.dumps(coords_list, ensure_ascii=False)

    payload = {
        "parcelName": parcel_name,
        "boundaryCoordinates": coords_str
    }

    try:
        response = requests.post(API_URL, headers=HEADERS, json=payload, timeout=10)
        if response.status_code == 200:
            return True, f"ID {index}: 成功"
        else:
            return False, f"ID {index}: 失败 [{response.status_code}] {response.text}"
    except Exception as e:
        return False, f"ID {index}: 异常 {str(e)}"


# ================= 主程序 =================

def run_batch_upload():
    print(f"=== 开始生成并上传 {TOTAL_RECORDS} 条数据 ===")
    print(f"=== 目标接口: {API_URL} ===")
    print(f"=== 并发线程: {MAX_WORKERS} ===\n")

    start_time = time.time()
    success_count = 0
    fail_count = 0

    # 使用线程池进行并发请求
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        # 提交所有任务
        futures = [executor.submit(upload_task, i) for i in range(1, TOTAL_RECORDS + 1)]

        # 处理结果
        for future in as_completed(futures):
            is_success, msg = future.result()
            if is_success:
                success_count += 1
                # 为了不刷屏，每100条打印一次进度，或者只打印失败的
                if success_count % 100 == 0:
                    print(f"[{success_count}/{TOTAL_RECORDS}] 进度... ({msg})")
            else:
                fail_count += 1
                print(f"[!] {msg}")

    end_time = time.time()
    duration = end_time - start_time

    print("\n" + "=" * 30)
    print("=== 任务完成 ===")
    print(f"总耗时: {duration:.2f} 秒")
    print(f"成功: {success_count}")
    print(f"失败: {fail_count}")
    print("=" * 30)


if __name__ == "__main__":
    run_batch_upload()