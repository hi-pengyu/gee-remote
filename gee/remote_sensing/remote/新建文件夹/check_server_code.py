"""检查当前运行的服务器是否使用了最新代码"""
import requests
import json

BASE_URL = "http://localhost:8000"

# 发送一个不带 API Key 的请求，并查看详细错误
response = requests.post(
    f"{BASE_URL}/api/v1/workflow/run",
    json={
        "aoi_coords": [[116.3, 39.9], [116.4, 39.9], [116.4, 40.0], [116.3, 40.0], [116.3, 39.9]],
        "target_date": "2024-06-01",
        "model_type": "zg"
    }
)

print("=" * 60)
print("测试请求（无 API Key）")
print("=" * 60)
print(f"状态码: {response.status_code}")
print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
print()

if response.status_code == 202:
    print("❌ 问题确认：验证代码没有执行！")
    print()
    print("可能的原因：")
    print("1. 服务器使用了缓存的旧代码（__pycache__）")
    print("2. 服务器没有自动重载")
    print("3. 代码文件没有保存")
    print()
    print("解决方案：")
    print("1. 停止服务器（Ctrl+C）")
    print("2. 删除 __pycache__ 文件夹")
    print("3. 重新启动服务器")
    print()
    print("命令:")
    print("  # 删除缓存")
    print("  Remove-Item -Recurse -Force app\\__pycache__")
    print("  Remove-Item -Recurse -Force app\\api\\__pycache__")
    print()
    print("  # 重启服务器")
    print("  conda activate gee")
    print("  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
elif response.status_code == 401:
    print("✅ 验证代码正常工作！")
