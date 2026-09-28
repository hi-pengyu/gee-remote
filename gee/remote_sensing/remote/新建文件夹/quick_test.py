"""快速测试 - 发送请求并检查 DEBUG 输出"""
import requests
import json
import time

BASE_URL = "http://localhost:8000"

print("=" * 80)
print("🔍 快速测试 API Key 认证")
print("=" * 80)
print()
print("⚠️  重要：请同时查看 'FastAPI Server' 窗口")
print("   应该能看到以下 DEBUG 输出：")
print("   🔍 DEBUG: run_full_workflow 被调用")
print()
print("如果没有看到 DEBUG 输出，说明服务器还在使用旧代码！")
print("=" * 80)
print()

time.sleep(1)

# 测试 1: 无 API Key
print("[测试 1] 发送无 API Key 的请求...")
try:
    r = requests.post(
        f"{BASE_URL}/api/v1/workflow/run",
        json={
            "aoi_coords": [[116.3, 39.9], [116.4, 39.9], [116.4, 40.0], [116.3, 40.0], [116.3, 39.9]],
            "target_date": "2024-06-01",
            "model_type": "zg"
        },
        timeout=5
    )
    print(f"   状态码: {r.status_code}")
    if r.status_code == 401:
        print("   ✅ 正确返回 401 - 认证生效！")
    else:
        print(f"   ❌ 错误：应该返回 401，实际返回 {r.status_code}")
        print(f"   响应: {r.json()}")
except Exception as e:
    print(f"   ❌ 请求失败: {e}")

print()
time.sleep(1)

# 测试 2: 无效 API Key
print("[测试 2] 发送无效 API Key 的请求...")
try:
    r = requests.post(
        f"{BASE_URL}/api/v1/workflow/run",
        headers={"X-App-Key": "invalid-key-xxx"},
        json={
            "aoi_coords": [[116.3, 39.9], [116.4, 39.9], [116.4, 40.0], [116.3, 40.0], [116.3, 39.9]],
            "target_date": "2024-06-01",
            "model_type": "zg"
        },
        timeout=5
    )
    print(f"   状态码: {r.status_code}")
    if r.status_code == 401:
        print("   ✅ 正确返回 401 - 认证生效！")
    else:
        print(f"   ❌ 错误：应该返回 401，实际返回 {r.status_code}")
        print(f"   响应: {r.json()}")
except Exception as e:
    print(f"   ❌ 请求失败: {e}")

print()
time.sleep(1)

# 测试 3: 有效 API Key
print("[测试 3] 发送有效 API Key 的请求...")
try:
    r = requests.post(
        f"{BASE_URL}/api/v1/workflow/run",
        headers={"X-App-Key": "default_api_key_123456"},
        json={
            "aoi_coords": [[116.3, 39.9], [116.4, 39.9], [116.4, 40.0], [116.3, 40.0], [116.3, 39.9]],
            "target_date": "2024-06-01",
            "model_type": "zg"
        },
        timeout=5
    )
    print(f"   状态码: {r.status_code}")
    if r.status_code == 202:
        print("   ✅ 正确返回 202 - 请求被接受！")
    else:
        print(f"   ❌ 错误：应该返回 202，实际返回 {r.status_code}")
        print(f"   响应: {r.json()}")
except Exception as e:
    print(f"   ❌ 请求失败: {e}")

print()
print("=" * 80)
print("📋 总结")
print("=" * 80)
print()
print("如果测试 1 和 2 都返回 401，测试 3 返回 202，")
print("那么 API Key 认证功能正常工作！")
print()
print("如果所有测试都返回 202，说明：")
print("  1. 服务器窗口没有显示 DEBUG 输出 → 代码没有重新加载")
print("  2. 需要完全停止服务器并重新启动")
print()
