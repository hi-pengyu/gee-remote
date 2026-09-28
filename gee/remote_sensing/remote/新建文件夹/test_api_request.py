"""测试实际的 API 请求"""
import requests
import json

# API 配置
BASE_URL = "http://localhost:8000"
API_KEY = "default_api_key_123456"  # 从数据库中获取的测试 key

# 闭合多边形坐标（首尾相同）
VALID_COORDS = [[116.3, 39.9], [116.4, 39.9], [116.4, 40.0], [116.3, 40.0], [116.3, 39.9]]

def test_workflow_without_key():
    """测试不带 API Key 的请求"""
    print("=" * 60)
    print("1. 测试不带 API Key 的请求（应该失败）")
    print("=" * 60)
    
    url = f"{BASE_URL}/api/v1/workflow/run"
    payload = {
        "aoi_coords": VALID_COORDS,
        "target_date": "2024-06-01",
        "model_type": "zg"
    }
    
    try:
        response = requests.post(url, json=payload, timeout=5)
        print(f"状态码: {response.status_code}")
        print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        
        if response.status_code == 401:
            print("✅ 正确拒绝了无 API Key 的请求")
            return True
        else:
            print(f"❌ 应该返回 401 状态码，实际返回 {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 请求失败: {e}")
        return False

def test_workflow_with_invalid_key():
    """测试使用无效 API Key 的请求"""
    print("\n" + "=" * 60)
    print("2. 测试使用无效 API Key 的请求（应该失败）")
    print("=" * 60)
    
    url = f"{BASE_URL}/api/v1/workflow/run"
    headers = {"X-App-Key": "invalid-key-xxx"}
    payload = {
        "aoi_coords": VALID_COORDS,
        "target_date": "2024-06-01",
        "model_type": "zg"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=5)
        print(f"状态码: {response.status_code}")
        print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        
        if response.status_code == 401:
            print("✅ 正确拒绝了无效的 API Key")
            return True
        else:
            print(f"❌ 应该返回 401 状态码，实际返回 {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 请求失败: {e}")
        return False

def test_workflow_with_valid_key():
    """测试使用有效 API Key 的请求"""
    print("\n" + "=" * 60)
    print("3. 测试使用有效 API Key 的请求（应该成功）")
    print("=" * 60)
    
    url = f"{BASE_URL}/api/v1/workflow/run"
    headers = {"X-App-Key": API_KEY}
    payload = {
        "aoi_coords": VALID_COORDS,
        "target_date": "2024-06-01",
        "model_type": "zg"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=5)
        print(f"状态码: {response.status_code}")
        print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        
        if response.status_code == 202:
            print("✅ 请求成功接受")
            return True
        else:
            print(f"❌ 应该返回 202 状态码，实际返回 {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 请求失败: {e}")
        return False

def test_cached_workflow_with_valid_key():
    """测试缓存工作流接口"""
    print("\n" + "=" * 60)
    print("4. 测试缓存工作流接口（应该成功）")
    print("=" * 60)
    
    url = f"{BASE_URL}/api/v1/workflow/run-cached"
    headers = {"X-App-Key": API_KEY}
    payload = {
        "aoi_coords": VALID_COORDS,
        "target_date": "2024-06-01",
        "model_type": "zg"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=5)
        print(f"状态码: {response.status_code}")
        print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        
        if response.status_code == 202:
            print("✅ 请求成功接受")
            return True
        else:
            print(f"❌ 应该返回 202 状态码，实际返回 {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 请求失败: {e}")
        return False

def check_api_server():
    """检查 API 服务器是否运行"""
    print("=" * 60)
    print("检查 API 服务器状态")
    print("=" * 60)
    
    try:
        response = requests.get(f"{BASE_URL}/api/v1/health", timeout=5)
        print(f"✅ API 服务器正在运行")
        print(f"健康状态: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        return True
    except requests.exceptions.ConnectionError:
        print(f"❌ API 服务器未运行，请先启动服务器")
        print(f"\n启动命令:")
        print(f"  conda activate gee")
        print(f"  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
        return False
    except Exception as e:
        print(f"❌ 检查失败: {e}")
        return False

def main():
    """主函数"""
    print("\n🔍 开始测试 API Key 认证的实际请求\n")
    
    # 检查服务器
    if not check_api_server():
        return
    
    # 运行测试
    results = []
    results.append(("无 API Key", test_workflow_without_key()))
    results.append(("无效 API Key", test_workflow_with_invalid_key()))
    results.append(("有效 API Key", test_workflow_with_valid_key()))
    results.append(("缓存工作流", test_cached_workflow_with_valid_key()))
    
    print("\n" + "=" * 60)
    print("📊 测试总结")
    print("=" * 60)
    for name, result in results:
        status = "✅ 通过" if result else "❌ 失败"
        print(f"{name}: {status}")
    
    all_passed = all(r[1] for r in results)
    if all_passed:
        print("\n🎉 所有测试通过！API Key 认证功能正常工作")
    else:
        print("\n⚠️  部分测试失败，请检查上述详细信息")

if __name__ == "__main__":
    main()
