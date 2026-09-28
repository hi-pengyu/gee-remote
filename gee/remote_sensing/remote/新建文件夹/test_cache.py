"""
测试瓦片缓存系统

运行此脚本测试缓存功能
"""
import requests
import time
import json

BASE_URL = "http://localhost:8000/api/v1"

# 测试地块坐标
TEST_COORDS = [
    [86.0388457571117, 44.552453045732314],
    [86.0405231637295, 44.5488551561015],
    [86.041776483188, 44.54909929116849],
    [86.04386811483757, 44.54461996826588],
    [86.04674205882675, 44.545110605417975],
    [86.04626800158945, 44.54640573178081],
    [86.04755328775938, 44.54663995980717],
    [86.04429809841783, 44.5536415794847],
    [86.0388457571117, 44.552453045732314]
]

def test_cache_stats():
    """测试缓存统计接口"""
    print("\n" + "="*60)
    print("测试1: 获取缓存统计")
    print("="*60)
    
    response = requests.get(f"{BASE_URL}/cache/stats")
    data = response.json()
    
    print(f"缓存启用: {data['cache_enabled']}")
    print(f"总瓦片数: {data['statistics']['total_tiles']}")
    print(f"活跃瓦片: {data['statistics']['active_tiles']}")
    print(f"缓存大小: {data['statistics']['total_size_mb']:.2f} MB")
    print(f"总访问次数: {data['statistics']['total_accesses']}")
    
    return data


def test_cached_workflow(coords, target_date="2024-06-15"):
    """测试带缓存的工作流"""
    print("\n" + "="*60)
    print("测试2: 带缓存的工作流")
    print("="*60)
    
    # 提交任务
    payload = {
        "aoi_coords": coords,
        "target_date": target_date,
        "model_type": "zg",
        "window_days": 7
    }
    
    print(f"提交任务: {target_date}")
    start_time = time.time()
    
    response = requests.post(f"{BASE_URL}/workflow/run-cached", json=payload)
    task_data = response.json()
    task_id = task_data['task_id']
    
    print(f"Task ID: {task_id}")
    print("等待任务完成...")
    
    # 轮询任务状态
    while True:
        status_response = requests.get(f"{BASE_URL}/tasks/{task_id}")
        status_data = status_response.json()
        
        print(f"进度: {status_data['progress']}% - {status_data['current_step']}")
        
        if status_data['status'] == 'success':
            elapsed = time.time() - start_time
            print(f"\n✅ 任务完成! 耗时: {elapsed:.2f}秒")
            
            result = status_data['result']
            if 'cache_info' in result:
                print(f"数据来源: {result['cache_info']['source']}")
                print(f"瓦片ID: {result['cache_info']['tile_id']}")
            
            print(f"影像日期: {result['metadata']['found_date']}")
            print(f"云量: {result['metadata']['cloud_cover']:.2f}%")
            print(f"有效像素: {result['metadata']['valid_pixels']:,}")
            
            return result, elapsed
            
        elif status_data['status'] == 'failure':
            print(f"\n❌ 任务失败: {status_data.get('error_message')}")
            return None, None
        
        time.sleep(2)


def test_cache_hit():
    """测试缓存命中"""
    print("\n" + "="*60)
    print("测试3: 缓存命中测试")
    print("="*60)
    
    target_date = "2024-06-15"
    
    # 第一次请求(可能缓存未命中)
    print("\n第一次请求(建立缓存)...")
    result1, time1 = test_cached_workflow(TEST_COORDS, target_date)
    
    if not result1:
        print("第一次请求失败,跳过缓存测试")
        return
    
    # 等待几秒
    print("\n等待5秒...")
    time.sleep(5)
    
    # 第二次请求(应该缓存命中)
    print("\n第二次请求(测试缓存命中)...")
    result2, time2 = test_cached_workflow(TEST_COORDS, target_date)
    
    if result2:
        print("\n" + "="*60)
        print("缓存性能对比")
        print("="*60)
        print(f"第一次请求: {time1:.2f}秒 (来源: {result1['cache_info']['source']})")
        print(f"第二次请求: {time2:.2f}秒 (来源: {result2['cache_info']['source']})")
        
        if time2 < time1:
            speedup = time1 / time2
            print(f"✅ 速度提升: {speedup:.1f}倍")
        else:
            print("⚠️ 第二次请求未使用缓存")


def test_manual_prefetch():
    """测试手动预取"""
    print("\n" + "="*60)
    print("测试4: 手动预取瓦片")
    print("="*60)
    
    # 假设瓦片ID
    tile_id = "tile_1912_990"
    target_date = "2024-06-15"
    
    response = requests.post(
        f"{BASE_URL}/cache/prefetch",
        params={
            "tile_id": tile_id,
            "target_date": target_date,
            "window_days": 7
        }
    )
    
    data = response.json()
    print(f"预取任务已提交: {data['task_id']}")
    print(f"瓦片ID: {data['tile_id']}")


def test_list_tiles():
    """测试列出瓦片"""
    print("\n" + "="*60)
    print("测试5: 列出缓存瓦片")
    print("="*60)
    
    response = requests.get(f"{BASE_URL}/cache/tiles?limit=10")
    data = response.json()
    
    print(f"总瓦片数: {data['total']}")
    
    if data['tiles']:
        print("\n热点瓦片:")
        for tile in data['tiles'][:5]:
            print(f"  - {tile['tile_id']}: 访问{tile['access_count']}次, "
                  f"日期{tile['date_acquired']}")


if __name__ == "__main__":
    print("🚀 开始测试瓦片缓存系统")
    print("确保服务已启动: http://localhost:8000")
    
    try:
        # 测试1: 缓存统计
        test_cache_stats()
        
        # 测试2: 带缓存的工作流
        test_cached_workflow(TEST_COORDS)
        
        # 测试3: 缓存命中
        # test_cache_hit()  # 取消注释以测试缓存命中
        
        # 测试4: 列出瓦片
        test_list_tiles()
        
        # 测试5: 手动预取
        # test_manual_prefetch()  # 取消注释以测试手动预取
        
        print("\n" + "="*60)
        print("✅ 所有测试完成!")
        print("="*60)
        
    except requests.exceptions.ConnectionError:
        print("\n❌ 无法连接到服务器")
        print("请确保服务已启动: python -m uvicorn app.main:app --reload")
    except Exception as e:
        print(f"\n❌ 测试失败: {e}")
        import traceback
        traceback.print_exc()
