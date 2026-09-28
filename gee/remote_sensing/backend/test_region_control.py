"""
GEE地块行政区管控功能 - 快速测试脚本

使用方法：
python test_region_control.py
"""

import requests
import json

# 配置
BASE_URL = "http://localhost:8000"  # 修改为实际的服务地址
APP_ID = 1  # 修改为实际的应用ID

def print_response(title, response):
    """打印响应结果"""
    print(f"\n{'='*60}")
    print(f"测试: {title}")
    print(f"{'='*60}")
    print(f"状态码: {response.status_code}")
    try:
        data = response.json()
        print(f"响应: {json.dumps(data, ensure_ascii=False, indent=2)}")
    except:
        print(f"响应: {response.text}")


def test_create_plot():
    """测试1: 创建地块（自动识别行政区）"""
    url = f"{BASE_URL}/gee/plot/"
    payload = {
        "appId": APP_ID,
        "plotName": "测试地块-河南郑州",
        "geometry": {
            "type": "Polygon",
            "coordinates": [
                [
                    [113.5, 34.5],
                    [113.6, 34.5],
                    [113.6, 34.6],
                    [113.5, 34.6],
                    [113.5, 34.5]
                ]
            ]
        },
        "description": "自动测试地块",
        "cropType": "corn"
    }
    
    response = requests.post(url, json=payload)
    print_response("创建地块（自动识别行政区）", response)
    
    # 返回创建的地块ID
    if response.status_code == 200:
        data = response.json()
        if data.get('isSuccess') and data.get('result'):
            return data['result'].get('plotId')
    return None


def test_get_plot_list():
    """测试2: 获取地块列表"""
    url = f"{BASE_URL}/gee/plot/list"
    params = {
        "pageNum": 1,
        "pageSize": 10,
        "appId": APP_ID
    }
    
    response = requests.get(url, params=params)
    print_response("获取地块列表", response)


def test_toggle_plot_status(plot_id):
    """测试3: 切换地块监测状态"""
    if not plot_id:
        print("\n跳过测试: 切换地块监测状态（没有地块ID）")
        return
    
    # 关闭监测
    url = f"{BASE_URL}/gee/plot/{plot_id}/toggle"
    payload = {"monitorStatus": 0}
    
    response = requests.put(url, json=payload)
    print_response(f"关闭地块 {plot_id} 的监测", response)
    
    # 重新开启监测
    payload = {"monitorStatus": 1}
    response = requests.put(url, json=payload)
    print_response(f"开启地块 {plot_id} 的监测", response)


def test_pause_region():
    """测试4: 暂停行政区监测"""
    url = f"{BASE_URL}/gee/region/pause"
    payload = {
        "adcode": "410100",  # 郑州市
        "reason": "测试暂停功能"
    }
    
    response = requests.post(url, json=payload)
    print_response("暂停郑州市（410100）的监测", response)


def test_get_paused_regions():
    """测试5: 查看暂停的行政区列表"""
    url = f"{BASE_URL}/gee/region/paused-list"
    
    response = requests.get(url)
    print_response("查看暂停的行政区列表", response)


def test_get_region_stats():
    """测试6: 查看行政区统计"""
    url = f"{BASE_URL}/gee/region/stats/410100"
    
    response = requests.get(url)
    print_response("查看郑州市（410100）的地块统计", response)


def test_resume_region():
    """测试7: 恢复行政区监测"""
    url = f"{BASE_URL}/gee/region/resume"
    payload = {
        "adcode": "410100"
    }
    
    response = requests.post(url, json=payload)
    print_response("恢复郑州市（410100）的监测", response)


def main():
    """主测试流程"""
    print("\n" + "="*60)
    print("GEE地块行政区管控功能 - 自动化测试")
    print("="*60)
    print(f"服务地址: {BASE_URL}")
    print(f"应用ID: {APP_ID}")
    
    try:
        # 测试1: 创建地块
        plot_id = test_create_plot()
        
        # 测试2: 获取地块列表
        test_get_plot_list()
        
        # 测试3: 切换地块状态
        test_toggle_plot_status(plot_id)
        
        # 测试4: 暂停行政区
        test_pause_region()
        
        # 测试5: 查看暂停列表
        test_get_paused_regions()
        
        # 测试6: 查看行政区统计
        test_get_region_stats()
        
        # 测试7: 恢复行政区
        test_resume_region()
        
        print("\n" + "="*60)
        print("✅ 所有测试完成！")
        print("="*60)
        
    except requests.exceptions.ConnectionError:
        print(f"\n❌ 错误: 无法连接到服务 {BASE_URL}")
        print("请确保FastAPI服务正在运行")
    except Exception as e:
        print(f"\n❌ 测试失败: {str(e)}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
