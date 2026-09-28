"""
简单示例 - 演示如何调用 API
"""
import requests
import time
import json

# API 地址
API_BASE = "http://localhost:8000"


def example_1_full_workflow():
    """
    示例1：完整工作流
    提交坐标 -> 下载遥感图 -> 处理数据 -> 预测
    """
    print("=" * 60)
    print("示例1：完整工作流")
    print("=" * 60)
    
    # 准备请求数据
    request_data = {
        "aoi_coords": [
            [86.0388457571117, 44.552453045732314],
            [86.0405231637295, 44.5488551561015],
            [86.041776483188, 44.54909929116849],
            [86.04386811483757, 44.54461996826588],
            [86.04674205882675, 44.545110605417975],
            [86.04626800158945, 44.54640573178081],
            [86.04755328775938, 44.54663995980717],
            [86.04429809841783, 44.5536415794847],
            [86.0388457571117, 44.552453045732314]
        ],
        "target_date": "2025-09-21",
        "model_type": "agb",
    }
    
    # 1. 提交任务
    print("\n1. 提交任务...")
    response = requests.post(
        f"{API_BASE}/api/v1/workflow/run",
        json=request_data
    )
    
    if response.status_code != 202:
        print(f"❌ 失败: {response.status_code}")
        print(response.text)
        return
    
    task_id = response.json()["task_id"]
    print(f"✓ 任务已提交！")
    print(f"  Task ID: {task_id}")
    
    # 2. 轮询任务状态
    print("\n2. 监控进度...")
    while True:
        response = requests.get(f"{API_BASE}/api/v1/tasks/{task_id}")
        status_data = response.json()
        
        status = status_data["status"]
        progress = status_data["progress"]
        step = status_data.get("current_step", "")
        
        print(f"  [{progress:3d}%] {step}")
        
        if status == "success":
            print("\n✅ 任务完成！")
            print("\n结果:")
            print(json.dumps(status_data["result"], indent=2, ensure_ascii=False))
            break
        
        elif status == "failure":
            print(f"\n❌ 任务失败: {status_data.get('error_message')}")
            break
        
        time.sleep(5)


def example_2_download_only():
    """
    示例2：仅下载遥感图
    只执行第一步
    """
    print("=" * 60)
    print("示例2：仅下载遥感图")
    print("=" * 60)
    
    request_data = {
        "aoi_coords": [
            [86.0388457571117, 44.552453045732314],
            [86.0405231637295, 44.5488551561015],
            [86.041776483188, 44.54909929116849],
            [86.0388457571117, 44.552453045732314]
        ],
        "target_date": "2025-09-21",
        "window_days": 2
    }
    
    response = requests.post(
        f"{API_BASE}/api/v1/gee/download",
        json=request_data
    )
    
    if response.status_code == 202:
        task_id = response.json()["task_id"]
        print(f"✓ 下载任务已提交！Task ID: {task_id}")
        print(f"  使用以下命令查询进度:")
        print(f"  curl {API_BASE}/api/v1/tasks/{task_id}")
    else:
        print(f"❌ 失败: {response.status_code}")


def example_3_check_health():
    """
    示例3：健康检查
    """
    print("=" * 60)
    print("示例3：健康检查")
    print("=" * 60)
    
    response = requests.get(f"{API_BASE}/api/v1/health")
    health = response.json()
    
    print(f"\n服务状态: {health['status']}")
    print(f"版本: {health['version']}")
    print(f"Redis 连接: {'✓' if health['redis_connected'] else '✗'}")
    print(f"Celery Workers: {health['celery_workers']}")
    print(f"存储可用: {'✓' if health['storage_available'] else '✗'}")


def example_4_list_files():
    """
    示例4：列出所有文件
    """
    print("=" * 60)
    print("示例4：列出所有文件")
    print("=" * 60)
    
    response = requests.get(f"{API_BASE}/api/v1/files/list")
    files = response.json()
    
    if not files:
        print("\n暂无文件")
        return
    
    print(f"\n找到 {len(files)} 个文件:\n")
    
    for f in files:
        size_mb = f['file_size'] / 1024 / 1024
        print(f"  [{f['file_type']:4s}] {f['file_name']:40s} ({size_mb:8.2f} MB)")


def example_5_custom_aoi():
    """
    示例5：使用自定义坐标
    演示如何使用你自己的 AOI
    """
    print("=" * 60)
    print("示例5：自定义坐标")
    print("=" * 60)
    
    # 你的自定义坐标（必须是闭合多边形）
    my_coords = [
        [116.4074, 39.9042],  # 北京天安门附近
        [116.4084, 39.9042],
        [116.4084, 39.9032],
        [116.4074, 39.9032],
        [116.4074, 39.9042]   # 首尾相同（闭合）
    ]
    
    request_data = {
        "aoi_coords": my_coords,
        "target_date": "2025-08-15",  # 你想要的日期
        "model_type": "agb",
        "window_days": 5
    }
    
    print("\n自定义 AOI 坐标:")
    print(json.dumps(my_coords, indent=2))
    
    print("\n提交任务...")
    response = requests.post(
        f"{API_BASE}/api/v1/workflow/run",
        json=request_data
    )
    
    if response.status_code == 202:
        task_id = response.json()["task_id"]
        print(f"✓ 任务已提交！Task ID: {task_id}")
    else:
        print(f"❌ 失败: {response.status_code}")
        print(response.text)


if __name__ == "__main__":
    print("\n🌍 GEE FastAPI 使用示例\n")
    
    # 先检查服务是否正常
    try:
        example_3_check_health()
    except Exception as e:
        print(f"\n❌ 服务未启动或连接失败: {e}")
        print("\n请先启动服务:")
        print("  Windows: start.bat")
        print("  Linux/Mac: ./start.sh")
        exit(1)
    
    print("\n" + "=" * 60)
    print("选择要运行的示例:")
    print("=" * 60)
    print("1. 完整工作流（下载 + 处理 + 预测）")
    print("2. 仅下载遥感图")
    print("3. 列出所有文件")
    print("4. 使用自定义坐标")
    print()
    
    choice = input("请输入选项 (1/2/3/4): ").strip()
    print()
    
    if choice == "1":
        example_1_full_workflow()
    elif choice == "2":
        example_2_download_only()
    elif choice == "3":
        example_4_list_files()
    elif choice == "4":
        example_5_custom_aoi()
    else:
        print("无效选项")

