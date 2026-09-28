import requests
import json
import time

BASE_URL = "http://<REDACTED_API_HOST>:8000/api/v1"

def print_result(title, result):
    print(f"\n{'='*20} {title} {'='*20}")
    print(json.dumps(result, indent=2, ensure_ascii=False))

def test_health():
    """测试健康检查"""
    try:
        response = requests.get(f"{BASE_URL}/health")
        print_result("健康检查", response.json())
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")

def test_config():
    """测试获取配置"""
    try:
        response = requests.get(f"{BASE_URL}/config")
        print_result("系统配置", response.json())
    except Exception as e:
        print(f"❌ 获取配置失败: {e}")

def test_workflow():
    """测试工作流提交"""
    payload = {
        "aoi_coords": [
            [85.602, 44.502],
            [85.605, 44.502],
            [85.605, 44.505],
            [85.602, 44.505],
            [85.602, 44.502]
        ],
        "target_date": "2023-08-01",
        "model_type": "zg",
        "window_days": 15,
        "file_name": "test_script_run",
        "scale": 10
    }
    
    headers = {
        "X-App-Key": "default_api_key_123456"
    }

    try:
        # 注意：这里调用的是普通 run 还是 run-cached 取决于您的需求，默认用 cache
        response = requests.post(f"{BASE_URL}/workflow/run-cached", json=payload, headers=headers)
        if response.status_code == 202:
            result = response.json()
            print_result("提交工作流任务", result)
            return result.get("task_id")
        else:
            print(f"❌ 提交任务失败: Status {response.status_code}, {response.text}")
    except Exception as e:
        print(f"❌ 提交任务异常: {e}")
    return None

def check_task_status(task_id):
    """轮询任务状态"""
    if not task_id:
        return
        
    print(f"\n🔍 开始轮询任务状态: {task_id}")
    for i in range(20):  # 最多轮询20次
        try:
            response = requests.get(f"{BASE_URL}/tasks/{task_id}")
            data = response.json()
            status = data.get("status")
            progress = data.get("progress", 0)
            step = data.get("current_step", "")
            
            print(f"   [{i+1}/20] Status: {status} | Progress: {progress}% | Step: {step}")
            
            if status in ["success", "failure"]:
                print_result("最终任务结果", data)
                break
            
            time.sleep(3)
        except Exception as e:
            print(f"❌ 查询状态失败: {e}")
            break

if __name__ == "__main__":
    print("🚀 开始 API 测试脚本...")
    
    test_health()
    test_config()
    
    # 注意：需要确认 AuthService 是否会拦截 "test_app_key"
    # 如果数据库中没有这个 key，您可能需要在数据库添加一行，或者临时修改代码绕过验证
    task_id = test_workflow()
    
    if task_id:
        check_task_status(task_id)
