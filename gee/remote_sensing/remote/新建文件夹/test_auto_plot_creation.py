"""
测试自动地块创建功能

测试场景：
1. 创建新地块 - 提供 plot_name + aoi_coords
2. 使用已存在地块 - 相同的 plot_name 再次创建任务
3. 验证地块与任务的关联
"""
import requests
import json

# 配置
BASE_URL = "http://localhost:8000/api/v1"
API_KEY = "default_api_key_123456"  # 替换为实际的 API Key

# 测试数据
test_coords = [
    [86.0388457571117, 44.552453045732314],
    [86.0405231637295, 44.5488551561015],
    [86.041776483188, 44.54909929116849],
    [86.0388457571117, 44.552453045732314]
]

def test_create_new_plot():
    """测试场景1: 创建新地块"""
    print("=" * 60)
    print("测试场景1: 创建新地块")
    print("=" * 60)
    
    payload = {
        "target_date": "2023-09-21",
        "model_type": "zg",
        "plot_name": "测试地块A",
        "aoi_coords": test_coords,
        "window_days": 2
    }
    
    headers = {
        "X-App-Key": API_KEY,
        "Content-Type": "application/json"
    }
    
    response = requests.post(
        f"{BASE_URL}/workflow/run",
        json=payload,
        headers=headers
    )
    
    print(f"状态码: {response.status_code}")
    print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
    
    if response.status_code == 202:
        print("✅ 任务提交成功")
        return response.json()["task_id"]
    else:
        print("❌ 任务提交失败")
        return None


def test_use_existing_plot():
    """测试场景2: 使用已存在的地块"""
    print("\n" + "=" * 60)
    print("测试场景2: 使用已存在的地块（相同plot_name）")
    print("=" * 60)
    
    payload = {
        "target_date": "2023-09-22",  # 不同日期
        "model_type": "agb",
        "plot_name": "测试地块A",  # 相同的地块名称
        "aoi_coords": test_coords,
        "window_days": 2
    }
    
    headers = {
        "X-App-Key": API_KEY,
        "Content-Type": "application/json"
    }
    
    response = requests.post(
        f"{BASE_URL}/workflow/run",
        json=payload,
        headers=headers
    )
    
    print(f"状态码: {response.status_code}")
    print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
    
    if response.status_code == 202:
        print("✅ 任务提交成功")
        return response.json()["task_id"]
    else:
        print("❌ 任务提交失败")
        return None


def test_without_plot_name():
    """测试场景3: 不提供plot_name（兼容性测试）"""
    print("\n" + "=" * 60)
    print("测试场景3: 不提供plot_name（兼容性测试）")
    print("=" * 60)
    
    payload = {
        "target_date": "2023-09-23",
        "model_type": "hsl",
        "aoi_coords": test_coords,
        "window_days": 2
    }
    
    headers = {
        "X-App-Key": API_KEY,
        "Content-Type": "application/json"
    }
    
    response = requests.post(
        f"{BASE_URL}/workflow/run",
        json=payload,
        headers=headers
    )
    
    print(f"状态码: {response.status_code}")
    print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
    
    if response.status_code == 202:
        print("✅ 任务提交成功（不创建地块）")
        return response.json()["task_id"]
    else:
        print("❌ 任务提交失败")
        return None


def verify_database():
    """验证数据库中的数据"""
    print("\n" + "=" * 60)
    print("数据库验证")
    print("=" * 60)
    print("请手动执行以下SQL查询验证：")
    print()
    print("-- 查询地块表")
    print("SELECT plot_id, app_id, plot_name, created_at FROM gee_plots ORDER BY created_at DESC LIMIT 5;")
    print()
    print("-- 查询任务表（关联地块）")
    print("SELECT task_id, plot_id, target_date, model_type, created_at FROM gee_tasks WHERE plot_id IS NOT NULL ORDER BY created_at DESC LIMIT 5;")
    print()
    print("-- 查询一个地块对应的所有任务")
    print("SELECT t.task_id, t.target_date, t.model_type, p.plot_name")
    print("FROM gee_tasks t")
    print("JOIN gee_plots p ON t.plot_id = p.plot_id")
    print("WHERE p.plot_name = '测试地块A'")
    print("ORDER BY t.created_at DESC;")


if __name__ == "__main__":
    print("开始测试自动地块创建功能\n")
    
    # 测试1: 创建新地块
    task_id_1 = test_create_new_plot()
    
    # 测试2: 使用已存在地块
    task_id_2 = test_use_existing_plot()
    
    # 测试3: 不提供plot_name
    task_id_3 = test_without_plot_name()
    
    # 数据库验证提示
    verify_database()
    
    print("\n" + "=" * 60)
    print("测试完成！")
    print("=" * 60)
    print("\n预期结果：")
    print("1. 测试1和测试2应该关联到同一个地块（plot_id相同）")
    print("2. 测试3不应该创建地块（plot_id为NULL）")
    print("3. 在gee_plots表中应该只有1条记录（测试地块A）")
    print("4. 在gee_tasks表中应该有3条记录，其中2条有plot_id")
