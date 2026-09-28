# import json
# import numpy as np
# from PIL import Image
# import os
#
#
# def hex_to_rgba(hex_color, alpha=255):
#     """将 #RRGGBB 格式的 hex 字符串转换为 [R, G, B, A] 列表"""
#     hex_color = hex_color.lstrip('#')
#     if len(hex_color) != 6:
#         raise ValueError("无效的 Hex 颜色代码")
#     r, g, b = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
#     return [r, g, b, alpha]
#
#
# def create_colored_map(json_path, output_png_path):
#     """
#     读取 API 预测的 JSON 文件，将其分 5 级上色，并保存为 PNG。
#     """
#
#     # --- 1. 定义调色板 (Color Palette) ---
#     PALETTE = [
#         [0, 0, 0, 0],  # 0: 背景 (完全透明)
#         hex_to_rgba("#F7FCF0"),  # 1: 低
#         hex_to_rgba("#C6E9C3"),  # 2: 较低
#         hex_to_rgba("#86D0C0"),  # 3: 正常
#         hex_to_rgba("#2E90C0"),  # 4: 较高
#         hex_to_rgba("#084081")  # 5: 高
#     ]
#
#     # --- 2. 加载 JSON 数据 ---
#     print(f"1. 正在加载预测文件: {json_path}...")
#     try:
#         with open(json_path, 'r') as f:
#             data = json.load(f)
#
#         if data.get('status') != 'success':
#             print("错误: JSON 文件状态不是 'success'。")
#             return
#
#         results = data.get('results', [])
#         if not results:
#             print("错误: JSON 中没有找到 'results' 数据。")
#             return
#
#     except FileNotFoundError:
#         print(f"错误: 找不到文件 {json_path}")
#         return
#     except Exception as e:
#         print(f"读取 JSON 时出错: {e}")
#         return
#
#     # --- 3. 重建 2D "原始预测图" (画布) ---
#     print(f"2. 正在从 {len(results)} 个点重建画布...")
#
#     max_x = 0
#     max_y = 0
#     for item in results:
#         if item['X'] > max_x: max_x = item['X']
#         if item['Y'] > max_y: max_y = item['Y']
#
#     width = max_x + 1
#     height = max_y + 1
#
#     print(f"   检测到画布尺寸: {width} x {height}")
#
#     raw_prediction_map = np.full((height, width), np.nan, dtype=np.float32)
#
#     for item in results:
#         raw_prediction_map[item['Y'], item['X']] = item['prediction']
#
#     # --- 4. 后处理与分级 (阶段 3) ---
#     print("3. 正在计算 5 级自定义分位数...")
#
#     # 提取所有有效的预测值 (非 NaN)
#     valid_predictions = raw_prediction_map[~np.isnan(raw_prediction_map)]
#     if len(valid_predictions) == 0:
#         print("错误: 预测图中没有有效数据。")
#         return
#
#     # --- !! 新增代码：输出统计数据 !! ---
#     min_val = valid_predictions.min()
#     max_val = valid_predictions.max()
#     print(f"   --- 基础统计 ---")
#     print(f"   有效像素点: {len(valid_predictions)}")
#     print(f"   最小值 (Min): {min_val:.4f}")
#     print(f"   最大值 (Max): {max_val:.4f}")
#     print(f"   ------------------")
#     # --- !! 新增代码结束 !! ---
#
#     # # 比例 [0.10, 0.25, 0.65, 0.85] 对应
#     # # 10% (1级), 15% (2级), 40% (3级), 20% (4级), 15% (5级)
#     # breaks = np.quantile(valid_predictions, [0.10, 0.25, 0.65, 0.85])
#     #
#     # # --- !! 打印语句也更新以匹配 !! ---
#     # print(f"   --- 分位数阈值 ---")  # 添加小标题以区分
#     # print(f"   - 1级 (低, 10%): < {breaks[0]:.4f}")
#     # print(f"   - 2级 (较低, 15%): {breaks[0]:.4f} - {breaks[1]:.4f}")
#     # print(f"   - 3级 (正常, 40%): {breaks[1]:.4f} - {breaks[2]:.4f}")
#     # print(f"   - 4级 (较高, 20%): {breaks[2]:.4f} - {breaks[3]:.4f}")
#     # print(f"   - 5级 (高, 15%): > {breaks[3]:.4f}")
#     # print(f"   ------------------")
#
#     # 比例 [0.10, 0.25, 0.65, 0.85] 对应
#     # 10% (1级), 15% (2级), 40% (3级), 20% (4级), 15% (5级)
#     breaks = np.quantile(valid_predictions, [0.15, 0.35, 0.65, 0.85])
#
#     # --- !! 打印语句也更新以匹配 !! ---
#     print(f"   --- 分位数阈值 ---")  # 添加小标题以区分
#     print(f"   - 1级 (低, 15%): < {breaks[0]:.4f}")
#     print(f"   - 2级 (较低, 20%): {breaks[0]:.4f} - {breaks[1]:.4f}")
#     print(f"   - 3级 (正常, 30%): {breaks[1]:.4f} - {breaks[2]:.4f}")
#     print(f"   - 4级 (较高, 20%): {breaks[2]:.4f} - {breaks[3]:.4f}")
#     print(f"   - 5级 (高, 15%): > {breaks[3]:.4f}")
#     print(f"   ------------------")
#
#
#     # (分级逻辑保持不变)
#     graded_map = np.full(raw_prediction_map.shape, 0, dtype=np.uint8)
#     valid_indices = ~np.isnan(raw_prediction_map)
#     grades = np.digitize(raw_prediction_map[valid_indices], breaks) + 1
#     graded_map[valid_indices] = grades
#
#     # --- 5. 可视化与上色 (阶段 4) ---
#     print("4. 正在上色...")
#     color_image = np.zeros((height, width, 4), dtype=np.uint8)
#     for grade_value, color in enumerate(PALETTE):
#         color_image[graded_map == grade_value] = color
#
#     # --- 6. 保存为 PNG (阶段 5) ---
#     print(f"5. 正在保存到: {output_png_path}...")
#     img = Image.fromarray(color_image, 'RGBA')
#     img.save(output_png_path)
#
#     print("=" * 30)
#     print("🎉 成功！专题地图已生成。")
#     print("=" * 30)
#
#
# # --- 执行 ---
# if __name__ == "__main__":
#     # !! 修改这里 !!
#     JSON_FILE = r"F:\gee\prediction_hsl.json"
#     OUTPUT_PNG = "prediction_hsl_map.png"
#
#     if not os.path.exists(JSON_FILE):
#         print(f"错误: 找不到输入文件 '{JSON_FILE}'")
#         print("请确保你已经运行了 call_api.py 并成功生成了 JSON 文件。")
#     else:
#         create_colored_map(JSON_FILE, OUTPUT_PNG)


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


def create_colored_map(json_path, output_png_path):
    """
    读取 API 预测的 JSON 文件，将其分 5 级上色，并保存为 PNG。
    """

    # --- 1. 定义调色板 (Color Palette) ---
    PALETTE = [
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#F7FCF0"),  # 1: 低
        hex_to_rgba("#C6E9C3"),  # 2: 较低
        hex_to_rgba("#86D0C0"),  # 3: 正常
        hex_to_rgba("#2E90C0"),  # 4: 较高
        hex_to_rgba("#084081")  # 5: 高
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
    # !! 更改点 !!
    print("3. 正在计算 5 级 '等比例距离' 分割 (15%-20%-30%-20%-15%)...")

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

    # --- !! 关键修改：从 '分位数' 改为 '等比例距离' !! ---

    # 计算总的值域范围
    total_range = max_val - min_val

    # 1. 之前 '分位数' 的方法 (已注释掉)
    # breaks = np.quantile(valid_predictions, [0.15, 0.35, 0.65, 0.85])

    # 2. 新的 '等比例距离' 方法 (根据您的计算)
    # 我们将 15%-20%-30%-20%-15% 的比例应用到 *值域范围* 上
    cumulative_proportions = np.array([0.20, 0.40, 0.60, 0.80])

    # 计算分割点：Min + (Range * Proportion)
    breaks = min_val + (total_range * cumulative_proportions)

    # --- !! 关键修改结束 !! ---

    # --- !! 打印语句也更新以匹配 !! ---
    print(f"   --- 等比例距离阈值 ---")  # 添加小标题以区分
    print(f"   - 1级 (低, 15%): < {breaks[0]:.4f}")
    print(f"   - 2级 (较低, 20%): {breaks[0]:.4f} - {breaks[1]:.4f}")
    print(f"   - 3级 (正常, 30%): {breaks[1]:.4f} - {breaks[2]:.4f}")
    print(f"   - 4级 (较高, 20%): {breaks[2]:.4f} - {breaks[3]:.4f}")
    print(f"   - 5级 (高, 15%): > {breaks[3]:.4f}")
    print(f"   ------------------")

    # (分级逻辑保持不变, np.digitize 会正确处理新的 breaks)
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
    print("🎉 成功！专题地图已生成。")
    print("=" * 30)


# --- 执行 ---
if __name__ == "__main__":
    # !! 修改这里 !!
    JSON_FILE = r"F:\gee\prediction_hsl.json"
    OUTPUT_PNG = "prediction_hsl_map_proportional.png"  # <--- 建议改名以区分

    if not os.path.exists(JSON_FILE):
        print(f"错误: 找不到输入文件 '{JSON_FILE}'")
        print("请确保你已经运行了 call_api.py 并成功生成了 JSON 文件。")
    else:
        create_colored_map(JSON_FILE, OUTPUT_PNG)