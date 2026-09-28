"""
测试脚本 - 测试完整工作流
"""
import requests
import time

# API 基础 URL
BASE_URL = "http://localhost:8000"

# 测试数据
test_request = {
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
    "model_type": "all",
    "window_days": 2
}


def test_health():
    """测试健康检查"""
    print("=== 测试健康检查 ===")
    response = requests.get(f"{BASE_URL}/api/v1/health")
    print(f"状态码: {response.status_code}")
    print(f"响应: {response.json()}\n")
    return response.status_code == 200


def test_workflow():
    """测试完整工作流"""
    print("=== 测试完整工作流 ===")
    
    # 1. 提交任务
    print("1. 提交任务...")

    response = requests.post(
        f"{BASE_URL}/api/v1/workflow/run",
        json=test_request
    )
    
    if response.status_code != 202:
        print(f"❌ 任务提交失败: {response.status_code}")
        print(response.text)
        return False
    
    result = response.json()
    task_id = result['task_id']
    print(f"✓ 任务已提交！Task ID: {task_id}\n")
    
    # 2. 轮询任务状态
    print("2. 监控任务进度...")
    max_attempts = 120  # 最多等待 10 分钟
    attempt = 0
    
    while attempt < max_attempts:
        response = requests.get(f"{BASE_URL}/api/v1/tasks/{task_id}")
        
        if response.status_code != 200:
            print(f"❌ 查询失败: {response.status_code}")
            return False
        
        status_data = response.json()
        status = status_data['status']
        progress = status_data['progress']
        current_step = status_data.get('current_step', '')
        
        print(f"[{progress:3d}%] {status:15s} | {current_step}")
        
        if status == 'success':
            print("\n✓ 任务完成！")
            print("\n=== 最终结果 ===")
            result = status_data.get('result', {})

            if result:
                print(f"文件名: {result.get('file_name')}")
                print(f"TIF 路径: {result.get('tif_path')}")

                # 检查是否是多模型结果
                if result.get('all_models', False):
                    print("\n=== 多模型预测结果 ===")
                    all_models_results = result.get('all_models_results', {})
                    print(f"运行的模型数: {len(all_models_results)}")

                    for model_name, model_result in all_models_results.items():
                        status_icon = "✓" if model_result.get('success') else "✗"
                        result_count = model_result.get('result_count', 0)
                        print(f"  {status_icon} {model_name.upper()}: {result_count:,} 个预测结果")
                        if model_result.get('result_path'):
                            print(f"     JSON: {model_result.get('result_path')}")
                        # 显示可视化图像路径
                        visualization = model_result.get('visualization', {})
                        if visualization.get('success'):
                            print(f"     图像: {visualization.get('image_path')}")
                            print(f"     尺寸: {visualization.get('width')}x{visualization.get('height')}")

                    # 显示元数据
                    if 'metadata' in result:
                        meta = result['metadata']
                        print("\n=== 元数据 ===")
                        print(f"影像日期: {meta.get('found_date')}")
                        print(f"云量: {meta.get('cloud_cover'):.2f}%")
                        print(f"有效像素: {meta.get('valid_pixels'):,}")
                        print(f"总预测结果数: {meta.get('total_predictions'):,}")
                        print(f"成功模型: {', '.join(meta.get('successful_models', []))}")
                        if meta.get('failed_models'):
                            print(f"失败模型: {', '.join(meta.get('failed_models', []))}")
                else:
                    # 单模型结果（原有逻辑）
                    print(f"结果路径: {result.get('result_path')}")

                    # 显示可视化图像
                    if 'visualization' in result.get('metadata', {}):
                        vis = result['metadata']['visualization']
                        if vis.get('success'):
                            print(f"可视化图像: {vis.get('image_path')}")
                            print(f"图像尺寸: {vis.get('width')}x{vis.get('height')}")

                    if 'metadata' in result:
                        meta = result['metadata']
                        print("\n=== 元数据 ===")
                        print(f"影像日期: {meta.get('found_date')}")
                        print(f"云量: {meta.get('cloud_cover'):.2f}%")
                        print(f"有效像素: {meta.get('valid_pixels'):,}")
                        print(f"预测结果数: {meta.get('result_count'):,}")
                        print(f"模型类型: {meta.get('model_type')}")

            return True
        
        elif status == 'failure':
            print(f"\n❌ 任务失败！")
            error = status_data.get('error_message', '未知错误')
            print(f"错误信息: {error}")
            return False
        
        time.sleep(5)
        attempt += 1
    
    print("\n⏱ 超时：任务执行时间过长")
    return False


def test_download_only():
    """测试仅下载遥感图"""
    print("=== 测试 GEE 下载 ===")
    
    download_request = {
        "aoi_coords": test_request['aoi_coords'],
        "target_date": test_request['target_date'],
        "window_days": 2
    }
    
    response = requests.post(
        f"{BASE_URL}/api/v1/gee/download",
        json=download_request
    )
    
    if response.status_code == 202:
        result = response.json()
        print(f"✓ 下载任务已提交！Task ID: {result['task_id']}")
        return True
    else:
        print(f"❌ 下载任务提交失败: {response.status_code}")
        return False


def test_list_files():
    """测试文件列表"""
    print("=== 测试文件列表 ===")
    response = requests.get(f"{BASE_URL}/api/v1/files/list")

    if response.status_code == 200:
        files = response.json()
        print(f"✓ 找到 {len(files)} 个文件")

        for f in files[:5]:  # 显示前 5 个
            print(f"  - {f['file_name']} ({f['file_type']}, {f['file_size'] / 1024 / 1024:.2f} MB)")

        return True
    else:
        print(f"❌ 查询失败: {response.status_code}")
        return False


def test_single_model_workflow():
    """测试单个模型的工作流"""
    print("=== 测试单个模型工作流 ===")
    print("可用模型: zg, agb, hsl, spad, n, p, k")
    model = input("请输入要测试的模型类型 (默认: agb): ").strip() or "agb"

    single_model_request = test_request.copy()
    single_model_request['model_type'] = model

    print(f"\n使用模型: {model}")
    print("1. 提交任务...")

    response = requests.post(
        f"{BASE_URL}/api/v1/workflow/run",
        json=single_model_request
    )

    if response.status_code != 202:
        print(f"❌ 任务提交失败: {response.status_code}")
        print(response.text)
        return False

    result = response.json()
    task_id = result['task_id']
    print(f"✓ 任务已提交！Task ID: {task_id}\n")

    # 2. 轮询任务状态
    print("2. 监控任务进度...")
    max_attempts = 120
    attempt = 0

    while attempt < max_attempts:
        response = requests.get(f"{BASE_URL}/api/v1/tasks/{task_id}")

        if response.status_code != 200:
            print(f"❌ 查询失败: {response.status_code}")
            return False

        status_data = response.json()
        status = status_data['status']
        progress = status_data['progress']
        current_step = status_data.get('current_step', '')

        print(f"[{progress:3d}%] {status:15s} | {current_step}")

        if status == 'success':
            print(f"\n✓ 模型 {model} 任务完成！")
            result = status_data.get('result', {})
            if result and 'metadata' in result:
                meta = result['metadata']
                print(f"预测结果数: {meta.get('result_count'):,}")
            return True

        elif status == 'failure':
            print(f"\n❌ 任务失败！")
            error = status_data.get('error_message', '未知错误')
            print(f"错误信息: {error}")
            return False

        time.sleep(5)
        attempt += 1

    print("\n⏱ 超时：任务执行时间过长")
    return False


if __name__ == "__main__":
    print("=" * 60)
    print("GEE FastAPI 服务测试")
    print("=" * 60)
    print()

    # 测试健康检查
    if not test_health():
        print("⚠️  服务未正常运行，请检查：")
        print("  1. FastAPI 是否启动")
        print("  2. Redis 是否运行")
        print("  3. Celery Worker 是否启动")
        exit(1)

    # 选择测试
    print("请选择测试项：")
    print("1. 完整工作流测试 - 运行所有模型 (model_type='all'，需要较长时间)")
    print("2. 单个模型测试 (可选择具体模型)")
    print("3. 仅测试任务提交")
    print("4. 查看文件列表")
    print()

    choice = input("请输入选项 (1/2/3/4): ").strip()
    print()

    if choice == "1":
        start_time = time.time()
        test_workflow()
        end_time = time.time()
        print(f"总耗时: {end_time - start_time:.2f} 秒")
    elif choice == "2":
        start_time = time.time()
        test_single_model_workflow()
        end_time = time.time()
        print(f"总耗时: {end_time - start_time:.2f} 秒")
    elif choice == "3":
        test_download_only()
    elif choice == "4":
        test_list_files()
    else:
        print("无效选项")

