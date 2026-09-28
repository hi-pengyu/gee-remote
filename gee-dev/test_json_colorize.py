"""
对比测试：使用 JSON 数据测试两种上色实现是否一致
"""
import json
import numpy as np
from PIL import Image
import os


def hex_to_rgba(hex_color, alpha=255):
    hex_color = hex_color.lstrip('#')
    r, g, b = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return [r, g, b, alpha]


def test_json_colorize():
    """使用 JSON 文件测试上色逻辑"""
    
    # 读取 JSON 文件
    json_path = r"F:\gee-简单版\prediction_agb.json"
    
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    results = data['results']
    
    # 重建画布
    max_x = max(item['X'] for item in results)
    max_y = max(item['Y'] for item in results)
    width = max_x + 1
    height = max_y + 1
    
    raw_map = np.full((height, width), np.nan, dtype=np.float32)
    for item in results:
        raw_map[item['Y'], item['X']] = item['prediction']
    
    # 获取有效数据
    valid_mask = ~np.isnan(raw_map)
    valid_data = raw_map[valid_mask]
    
    # 使用分位数方法 (20-20-20-20-20)
    proportions = np.array([0.20, 0.40, 0.60, 0.80])
    breaks = np.quantile(valid_data, proportions)
    
    print("=" * 60)
    print("测试数据: prediction_agb.json")
    print(f"有效像素点: {len(valid_data):,}")
    print(f"分割点: {breaks}")
    print()
    
    # 方法1: 使用 np.digitize + 1 (无clip)
    grades_1 = np.digitize(valid_data, breaks) + 1
    
    print("方法1: np.digitize + 1 (无clip)")
    for i in range(1, 6):
        count = np.count_nonzero(grades_1 == i)
        percentage = (count / len(valid_data)) * 100
        print(f"  等级 {i}: {percentage:6.2f}% ({count:,} 个点)")
    print()
    
    # 方法2: 使用 np.digitize + 1 + clip
    grades_2 = np.digitize(valid_data, breaks) + 1
    grades_2 = np.clip(grades_2, 1, 5)
    
    print("方法2: np.digitize + 1 + clip(1, 5)")
    for i in range(1, 6):
        count = np.count_nonzero(grades_2 == i)
        percentage = (count / len(valid_data)) * 100
        print(f"  等级 {i}: {percentage:6.2f}% ({count:,} 个点)")
    print()
    
    # 检查是否有超出范围的值
    if np.any((grades_1 < 1) | (grades_1 > 5)):
        print("⚠️ 警告: 方法1 有超出 1-5 范围的等级值!")
        print(f"   最小等级值: {grades_1.min()}")
        print(f"   最大等级值: {grades_1.max()}")
    else:
        print("✅ 方法1: 所有等级值都在 1-5 范围内")
    
    # 检查两种方法是否相同
    if np.array_equal(grades_1, grades_2):
        print("✅ 两种方法的结果完全一致")
    else:
        print("❌ 两种方法的结果不一致!")
        diff_count = np.count_nonzero(grades_1 != grades_2)
        print(f"   不同的像素数: {diff_count}")
    
    print("=" * 60)


if __name__ == "__main__":
    test_json_colorize()
