"""检查服务器是否看到了DEBUG输出"""
import requests

print("发送测试请求到 /api/v1/workflow/run...")
print("请同时查看服务器终端，应该会看到 DEBUG 输出")
print("=" * 60)

response = requests.post(
    "http://localhost:8000/api/v1/workflow/run",
    json={
        "aoi_coords": [[116.3, 39.9], [116.4, 39.9], [116.4, 40.0], [116.3, 40.0], [116.3, 39.9]],
        "target_date": "2024-06-01",
        "model_type": "zg"
    }
)

print(f"\n响应状态码: {response.status_code}")
print("\n如果服务器终端没有显示:")
print("  🔍 DEBUG: run_full_workflow 被调用")
print("\n那么说明请求被其他路由处理了，或者代码没有重新加载！")
