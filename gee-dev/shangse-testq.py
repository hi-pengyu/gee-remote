import json
import numpy as np
from PIL import Image
import os


def hex_to_rgba(hex_color, alpha=255):
    """将 #RRGGBB 格式的 hex 字符串转换为 [R, G, B, A] 列表"""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        raise ValueError(f"无效的 Hex 颜色代码: {hex_color}")
    r, g, b = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return [r, g, b, alpha]


# ==========================================
# 1. 定义全局调色板
# ==========================================
# 颜色顺序: [0:背景, 1:低, 2:较低, 3:正常, 4:较高, 5:高]

ALGORITHM_PALETTES = {
    'zg': [[0, 0, 0, 0], hex_to_rgba("#FF0000"), hex_to_rgba("#EAA1A1"), hex_to_rgba("#87F27C"), hex_to_rgba("#268845"),
           hex_to_rgba("#024D2E")],
    'hsl': [[0, 0, 0, 0], hex_to_rgba("#F7FCF0"), hex_to_rgba("#C6E9C3"), hex_to_rgba("#86D0C0"),
            hex_to_rgba("#2E90C0"), hex_to_rgba("#084081")],
    'agb': [[0, 0, 0, 0], hex_to_rgba("#FFFFE5"), hex_to_rgba("#D2EDA0"), hex_to_rgba("#85CC7E"),
            hex_to_rgba("#268845"), hex_to_rgba("#004529")],
    'spad': [[0, 0, 0, 0], hex_to_rgba("#A2061A"), hex_to_rgba("#F47878"), hex_to_rgba("#F3EB07"),
             hex_to_rgba("#2AE038"), hex_to_rgba("#1D5604")],
    'n': [[0, 0, 0, 0], hex_to_rgba("#DFE8C4"), hex_to_rgba("#E9F153"), hex_to_rgba("#ABF597"), hex_to_rgba("#08B724"),
          hex_to_rgba("#026729")],
    'p': [[0, 0, 0, 0], hex_to_rgba("#DFE8C4"), hex_to_rgba("#E9F153"), hex_to_rgba("#ABF597"), hex_to_rgba("#08B724"),
          hex_to_rgba("#026729")],
    'k': [[0, 0, 0, 0], hex_to_rgba("#DFE8C4"), hex_to_rgba("#E9F153"), hex_to_rgba("#ABF597"), hex_to_rgba("#08B724"),
          hex_to_rgba("#026729")],
    'zh': [[0, 0, 0, 0], hex_to_rgba("#FF0000"), hex_to_rgba("#FF7F50"), hex_to_rgba("#FFFF00"), hex_to_rgba("#00FF00"),
           hex_to_rgba("#007F00")]
}


def create_colored_map_fixed(json_path, output_png_path, algorithm_name, breaks):
    """根据算法名称选择调色板，按固定阈值分级上色，并输出分布比例"""

    # 1. 获取调色板
    palette = ALGORITHM_PALETTES.get(algorithm_name)
    if palette is None:
        print(f"❌ 错误: 未知算法 '{algorithm_name}'")
        return

    # 2. 加载数据
    print(f"正在处理: {os.path.basename(json_path)} (算法: {algorithm_name})")
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
        if data.get('status') != 'success':
            print(f"  ❌ JSON 状态异常")
            return
        results = data.get('results', [])
        if not results:
            print(f"  ❌ 无 results 数据")
            return
    except Exception as e:
        print(f"  ❌ 读取出错: {e}")
        return

    # 3. 构建矩阵
    max_x = max(item['X'] for item in results)
    max_y = max(item['Y'] for item in results)
    width, height = max_x + 1, max_y + 1

    raw_map = np.full((height, width), np.nan, dtype=np.float32)
    for item in results:
        raw_map[item['Y'], item['X']] = item['prediction']

    # 4. 分级 (固定数值)
    valid_mask = ~np.isnan(raw_map)
    if not np.any(valid_mask):
        print("  ❌ 无有效像素")
        return

    # 获取有效数据
    valid_data = raw_map[valid_mask]
    total_pixels = len(valid_data)

    print(f"  阈值: {breaks}")

    # digitize 返回 0~4, +1 变成 1~5 (对应 palette 索引 1~5)
    grades = np.digitize(valid_data, breaks) + 1
    grades = np.clip(grades, 1, 5)  # 确保不越界

    # ==========================================
    # 🔥 新增功能：统计并打印分布百分比
    # ==========================================
    print(f"  📊 数据分布统计 (总点数: {total_pixels}):")
    labels = ["1级(低)", "2级(较低)", "3级(正常)", "4级(较高)", "5级(高)"]

    for i in range(1, 6):
        # 计算该等级的数量
        count = np.count_nonzero(grades == i)
        # 计算百分比
        percentage = (count / total_pixels) * 100
        print(f"    - {labels[i - 1]}: {percentage:6.2f}% ({count} 个点)")
    print("  ----------------------------------")

    # 5. 上色与保存
    # 重建完整的等级图
    graded_map = np.full(raw_map.shape, 0, dtype=np.uint8)  # 0 为背景
    graded_map[valid_mask] = grades

    img_data = np.zeros((height, width, 4), dtype=np.uint8)
    for g, color in enumerate(palette):
        img_data[graded_map == g] = color

    Image.fromarray(img_data, 'RGBA').save(output_png_path)
    print(f"  ✅ 已生成: {output_png_path}\n")


# ==========================================
# 主程序
# ==========================================
if __name__ == "__main__":

    # 基础路径
    BASE_DIR = r"F:\gee-简单版"

    # --- 1. 定义各算法的阈值 ---
    # 格式 [A, B, C, D]

    # 株高 (ZG) 阈值
    BREAKS_ZG = [59.2283, 62.2556, 64.1007, 64.7995]

    # ⚠️ 注意: 你原本的代码中，所有任务都使用了 BREAKS_ZG。
    # 如果你需要为其他算法(如 n, p, k)使用不同的阈值，请在这里定义并修改 tasks 列表中的引用。
    # 例如: BREAKS_NPK = [0.5, 1.0, 1.5, 2.0]

    # --- 2. 任务列表 ---
    tasks = [
        {"json": "prediction_zg.json", "out": "map_zg.png", "algo": "zg", "breaks": BREAKS_ZG},
        {"json": "prediction_hsl.json", "out": "map_hsl.png", "algo": "hsl", "breaks": BREAKS_ZG},
        {"json": "prediction_agb.json", "out": "map_agb.png", "algo": "agb", "breaks": BREAKS_ZG},
        {"json": "prediction_spad.json", "out": "map_spad.png", "algo": "spad", "breaks": BREAKS_ZG},
        {"json": "prediction_n.json", "out": "map_n.png", "algo": "n", "breaks": BREAKS_ZG},
        {"json": "prediction_p.json", "out": "map_p.png", "algo": "p", "breaks": BREAKS_ZG},
        {"json": "prediction_k.json", "out": "map_k.png", "algo": "k", "breaks": BREAKS_ZG},
        {"json": "prediction_zh.json", "out": "map_zh.png", "algo": "zh", "breaks": BREAKS_ZG},
    ]

    print(f"--- 开始批量处理 {len(tasks)} 个任务 ---\n")

    for task in tasks:
        json_full_path = os.path.join(BASE_DIR, task["json"])

        if os.path.exists(json_full_path):
            create_colored_map_fixed(
                json_path=json_full_path,
                output_png_path=task["out"],
                algorithm_name=task["algo"],
                breaks=task["breaks"]
            )
        else:
            print(f"⚠️ 跳过: 找不到文件 {task['json']}")

    print("\n" + "=" * 30)
    print("🎉 所有处理结束")