import json
import numpy as np
from PIL import Image
import os


def hex_to_rgba(hex_color, alpha=255):
    """将 #RRGGBB 格式的 hex 字符串转换为 [R, G, B, A] 列表"""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        raise ValueError("无效的 Hex 颜色代码")
    r, g, b = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return [r, g, b, alpha]


def create_colored_map(json_path, output_png_path, method, proportions):
    """
    读取 API 预测的 JSON 文件，将其分 5 级上色，并保存为 PNG。

    参数:
    json_path (str): 输入的 JSON 文件路径。
    output_png_path (str): 输出的 PNG 文件路径。
    method (str): 分级方法: 'quantile' (分位数) 或 'equal_interval' (等比例距离)。
    proportions (list): 4 个元素的列表，定义 5 个等级的累积分割点。
    """

    # # --- 1. 定义调色板 hsl(Color Palette) ---
    # PALETTE = [
    #     [0, 0, 0, 0],  # 0: 背景 (完全透明)
    #     hex_to_rgba("#F7FCF0"),  # 1: 低
    #     hex_to_rgba("#C6E9C3"),  # 2: 较低
    #     hex_to_rgba("#86D0C0"),  # 3: 正常
    #     hex_to_rgba("#2E90C0"),  # 4: 较高
    #     hex_to_rgba("#084081")  # 5: 高
    # ]
    # --- 1. 定义调色板 n p k(Color Palette) ---
    # PALETTE = [
    #     [0, 0, 0, 0],  # 0: 背景 (完全透明)
    #     hex_to_rgba("#DFE8C4"),  # 1: 低
    #     hex_to_rgba("#E9F153"),  # 2: 较低
    #     hex_to_rgba("#ABF597"),  # 3: 正常
    #     hex_to_rgba("#08B724"),  # 4: 较高
    #     hex_to_rgba("#026729")  # 5: 高
    # ]
    # --- 1. 定义调色板 spad(Color Palette) ---
    # PALETTE = [
    #     [0, 0, 0, 0],  # 0: 背景 (完全透明)
    #     hex_to_rgba("#A2061A"),  # 1: 低
    #     hex_to_rgba("#F47878"),  # 2: 较低
    #     hex_to_rgba("#F3EB07"),  # 3: 正常
    #     hex_to_rgba("#2AE038"),  # 4: 较高
    #     hex_to_rgba("#1D5604")  # 5: 高
    # ]
    # # --- 1. 定义调色板 agb(Color Palette) ---
    # PALETTE = [
    #     [0, 0, 0, 0],  # 0: 背景 (完全透明)
    #     hex_to_rgba("#FFFFE5"),  # 1: 低
    #     hex_to_rgba("#D2EDA0"),  # 2: 较低
    #     hex_to_rgba("#85CC7E"),  # 3: 正常
    #     hex_to_rgba("#268845"),  # 4: 较高
    #     hex_to_rgba("#004529")  # 5: 高
    # ]
    #zg
    PALETTE = [
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#FF0000"),  # 1: 低
        hex_to_rgba("#EAA1A1"),  # 2: 较低
        hex_to_rgba("#87F27C"),  # 3: 正常
        hex_to_rgba("#268845"),  # 4: 较高
        hex_to_rgba("#024D2E")  # 5: 高
    ]


    # --- 2. 加载 JSON 数据 ---
    print(f"1. 正在加载预测文件: {json_path}...")
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)

        if data.get('status') != 'success':
            print("错误: JSON 文件状态不是 'success'。")
            return

        results = data.get('results', [])
        if not results:
            print("错误: JSON 中没有找到 'results' 数据。")
            return

    except FileNotFoundError:
        print(f"错误: 找不到文件 {json_path}")
        return
    except Exception as e:
        print(f"读取 JSON 时出错: {e}")
        return

    # --- 3. 重建 2D "原始预测图" (画布) ---
    print(f"2. 正在从 {len(results)} 个点重建画布...")

    max_x = 0
    max_y = 0
    for item in results:
        if item['X'] > max_x: max_x = item['X']
        if item['Y'] > max_y: max_y = item['Y']

    width = max_x + 1
    height = max_y + 1

    print(f"   检测到画布尺寸: {width} x {height}")

    raw_prediction_map = np.full((height, width), np.nan, dtype=np.float32)

    for item in results:
        raw_prediction_map[item['Y'], item['X']] = item['prediction']

    # --- 4. 后处理与分级 (阶段 3) ---

    # 提取所有有效的预测值 (非 NaN)
    valid_predictions = raw_prediction_map[~np.isnan(raw_prediction_map)]
    if len(valid_predictions) == 0:
        print("错误: 预测图中没有有效数据。")
        return

    # --- !! 基础统计 (不变) !! ---
    min_val = valid_predictions.min()
    max_val = valid_predictions.max()
    print(f"   --- 基础统计 ---")
    print(f"   有效像素点: {len(valid_predictions)}")
    print(f"   最小值 (Min): {min_val:.4f}")
    print(f"   最大值 (Max): {max_val:.4f}")
    print(f"   ------------------")

    # --- !! 关键修改：根据 'method' 参数选择分级逻辑 !! ---

    breaks = None
    method_name = ""
    proportions_np = np.array(proportions)  # 转换为 numpy 数组

    if method == 'quantile':
        method_name = "分位数 (Quantile)"
        print(f"3. 正在使用 '{method_name}' 方法计算阈值...")
        # 方法 A: 分位数 (确保每个等级中像素 *数量* 按比例)
        breaks = np.quantile(valid_predictions, proportions_np)

    elif method == 'equal_interval':
        method_name = "等比例距离 (Equal Interval)"
        print(f"3. 正在使用 '{method_name}' 方法计算阈值...")
        # 方法 B: 等比例距离 (确保每个等级的 *值域宽度* 按比例)
        total_range = max_val - min_val
        breaks = min_val + (total_range * proportions_np)

    else:
        print(f"!! 错误: 未知的分级方法 '{method}'。请使用 'quantile' 或 'equal_interval'。")
        return

    # --- !! 动态打印语句 (适用于 5 个等级) !! ---
    # 计算每个等级的单独百分比
    p_list = [proportions_np[0]]  # 第 1 级
    p_list.extend(np.diff(proportions_np))  # 第 2, 3, 4 级
    p_list.append(1.0 - proportions_np[-1])  # 第 5 级

    print(f"   --- 阈值 ({method_name}) ---")
    print(f"   - 1级 (低, {p_list[0] * 100:.0f}%): < {breaks[0]:.4f}")
    print(f"   - 2级 (较低, {p_list[1] * 100:.0f}%): {breaks[0]:.4f} - {breaks[1]:.4f}")
    print(f"   - 3级 (正常, {p_list[2] * 100:.0f}%): {breaks[1]:.4f} - {breaks[2]:.4f}")
    print(f"   - 4级 (较高, {p_list[3] * 100:.0f}%): {breaks[2]:.4f} - {breaks[3]:.4f}")
    print(f"   - 5级 (高, {p_list[4] * 100:.0f}%): > {breaks[3]:.4f}")
    print(f"   ------------------")

    # (分级逻辑保持不变)
    graded_map = np.full(raw_prediction_map.shape, 0, dtype=np.uint8)
    valid_indices = ~np.isnan(raw_prediction_map)
    grades = np.digitize(raw_prediction_map[valid_indices], breaks) + 1
    graded_map[valid_indices] = grades

    # --- 5. 可视化与上色 (阶段 4) ---
    print("4. 正在上色...")
    color_image = np.zeros((height, width, 4), dtype=np.uint8)
    for grade_value, color in enumerate(PALETTE):
        color_image[graded_map == grade_value] = color

    # --- 6. 保存为 PNG (阶段 5) ---
    print(f"5. 正在保存到: {output_png_path}...")
    img = Image.fromarray(color_image, 'RGBA')
    img.save(output_png_path)

    print("=" * 30)
    print(f"🎉 成功！'{output_png_path}' 已生成。")
    print("=" * 30)


# --- 执行 ---
if __name__ == "__main__":
    # !! 修改这里 !!
    JSON_FILE = r"F:\gee\prediction_zg.json"

    if not os.path.exists(JSON_FILE):
        print(f"!! 严重错误: 找不到输入文件 '{JSON_FILE}'")
        print("请确保你已经运行了 call_api.py 并成功生成了 JSON 文件。")
    else:
        # --- 定义您要的三种分割比例 ---

        # 比例 A: 10%-15%-40%-20%-15%
        PROPS_A = [0.15, 0.35, 0.65, 0.85]

        # 比例 B: 15%-20%-40%-15%-10%
        PROPS_B = [0.15, 0.35, 0.75, 0.90]

        # 比例 C: 20%-20%-20%-20%-20% (五等分)
        PROPS_C = [0.20, 0.40, 0.60, 0.80]

        # --- 运行您请求的 6 个任务 (2种方法 x 3种比例) ---

        # === 方法 1: 分位数 (Quantile) ===

        # 任务 1: 分位数 - 比例 A (10-15-40-20-15)
        print("\n--- 任务 1: 分位数  ---")
        create_colored_map(
            json_path=JSON_FILE,
            output_png_path="prediction_hsl_map_1_quantile_10_40.png",
            method="quantile",
            proportions=PROPS_A
        )

        # N任务 2: 分位数 - 比例 B (15-20-30-20-15)
        print("\n--- 任务 2: 分位数 ---")
        create_colored_map(
            json_path=JSON_FILE,
            output_png_path="prediction_hsl_map_2_quantile_15_30.png",
            method="quantile",
            proportions=PROPS_B
        )

        # 任务 3: 分位数 - 比例 C (20-20-20-20-20)
        print("\n--- 任务 3: 分位数 (20-20-20-20-20) ---")
        create_colored_map(
            json_path=JSON_FILE,
            output_png_path="prediction_hsl_map_3_quantile_20_20.png",
            method="quantile",
            proportions=PROPS_C
        )

        # === 方法 2: 等比例距离 (Equal Interval) ===

        # 任务 4: 等比例距离 - 比例 A (10-15-40-20-15)
        print("\n--- 任务 4: 等比例距离 (10-15-40-20-15) ---")
        create_colored_map(
            json_path=JSON_FILE,
            output_png_path="prediction_hsl_map_4_equal_interval_10_40.png",
            method="equal_interval",
            proportions=PROPS_A
        )

        # 任务 5: 等比例距离 - 比例 B (15-20-30-20-15)
        print("\n--- 任务 5: 等比例距离 (15-20-30-20-15) ---")
        create_colored_map(
            json_path=JSON_FILE,
            output_png_path="prediction_hsl_map_5_equal_interval_15_30.png",
            method="equal_interval",
            proportions=PROPS_B
        )

        # 任务 6: 等比例距离 - 比例 C (20-20-20-20-20)
        print("\n--- 任务 6: 等比例距离 (20-20-20-20-20) ---")
        create_colored_map(
            json_path=JSON_FILE,
            output_png_path="prediction_hsl_map_6_equal_interval_20_20.png",
            method="equal_interval",
            proportions=PROPS_C
        )