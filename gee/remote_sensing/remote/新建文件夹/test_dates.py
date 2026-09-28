"""
测试脚本 - 测试 Sentinel-2 日期查询 API
"""
import requests
import json
from datetime import datetime

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
    "start_date": "2025-01-01",
    "end_date": "2025-12-31",
    "cloud_cover_threshold": 20.0
}

def test_get_dates():
    """测试获取日期"""
    print("=== 测试 Sentinel-2 日期查询 ===")
    print(f"请求参数: {json.dumps(test_request, indent=2, ensure_ascii=False)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/v1/gee/dates",
            json=test_request
        )
        
        if response.status_code == 200:
            dates = response.json()
            print(f"\n✓ 查询成功！找到 {len(dates)} 个可用日期：")
            print(f"  {', '.join(dates)}")
            return True
        else:
            print(f"\n❌ 查询失败: {response.status_code}")
            print(response.text)
            return False
            
    except Exception as e:
        print(f"\n❌ 请求异常: {e}")
        return False

def test_future_dates():
    """测试未来日期预测"""
    print("\n=== 测试未来日期预测 ===")
    
    # 设置未来时间范围
    current_year = datetime.now().year
    future_request = test_request.copy()
    future_request['start_date'] = datetime.now().strftime('%Y-%m-%d')
    future_request['end_date'] = f"{current_year}-12-31"
    future_request['predict_future'] = True
    
    print(f"请求参数: {json.dumps(future_request, indent=2, ensure_ascii=False)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/v1/gee/dates",
            json=future_request
        )
        
        if response.status_code == 200:
            dates = response.json()
            print(f"\n✓ 预测成功！找到 {len(dates)} 个未来日期：")
            print(f"  {', '.join(dates)}")
            return True
        else:
            print(f"\n❌ 预测失败: {response.status_code}")
            print(response.text)
            return False
            
    except Exception as e:
        print(f"\n❌ 请求异常: {e}")
        return False

if __name__ == "__main__":
    test_get_dates()
    test_future_dates()
