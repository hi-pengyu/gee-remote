"""
TIF 文件上色脚本
支持分位数和等比例两种上色方法
输出详细的日志和上色比例统计
"""
import numpy as np
from osgeo import gdal
from PIL import Image
import os
from datetime import datetime


def hex_to_rgba(hex_color, alpha=255):
    """将 #RRGGBB 格式的 hex 字符串转换为 [R, G, B, A] 列表"""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        raise ValueError(f"无效的 Hex 颜色代码: {hex_color}")
    r, g, b = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return [r, g, b, alpha]


# ==========================================
# 定义各算法的调色板
# ==========================================
ALGORITHM_PALETTES = {
    'zg': [
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#FF0000"),  # 1: 低
        hex_to_rgba("#EAA1A1"),  # 2: 较低
        hex_to_rgba("#87F27C"),  # 3: 正常
        hex_to_rgba("#268845"),  # 4: 较高
        hex_to_rgba("#024D2E")   # 5: 高
    ],
    'hsl': [
        [0, 0, 0, 0],
        hex_to_rgba("#F7FCF0"),
        hex_to_rgba("#C6E9C3"),
        hex_to_rgba("#86D0C0"),
        hex_to_rgba("#2E90C0"),
        hex_to_rgba("#084081")
    ],
    'agb': [
        [0, 0, 0, 0],
        hex_to_rgba("#FFFFE5"),
        hex_to_rgba("#D2EDA0"),
        hex_to_rgba("#85CC7E"),
        hex_to_rgba("#268845"),
        hex_to_rgba("#004529")
    ],
    'spad': [
        [0, 0, 0, 0],
        hex_to_rgba("#A2061A"),
        hex_to_rgba("#F47878"),
        hex_to_rgba("#F3EB07"),
        hex_to_rgba("#2AE038"),
        hex_to_rgba("#1D5604")
    ],
    'n': [
        [0, 0, 0, 0],
        hex_to_rgba("#DFE8C4"),
        hex_to_rgba("#E9F153"),
        hex_to_rgba("#ABF597"),
        hex_to_rgba("#08B724"),
        hex_to_rgba("#026729")
    ],
    'p': [
        [0, 0, 0, 0],
        hex_to_rgba("#DFE8C4"),
        hex_to_rgba("#E9F153"),
        hex_to_rgba("#ABF597"),
        hex_to_rgba("#08B724"),
        hex_to_rgba("#026729")
    ],
    'k': [
        [0, 0, 0, 0],
        hex_to_rgba("#DFE8C4"),
        hex_to_rgba("#E9F153"),
        hex_to_rgba("#ABF597"),
        hex_to_rgba("#08B724"),
        hex_to_rgba("#026729")
    ]
}


def colorize_tif(tif_path, output_path, algorithm_name, method='quantile', 
                 proportions=None, log_file=None):
    """
    对TIF文件进行上色处理
    
    参数:
        tif_path: 输入TIF文件路径
        output_path: 输出PNG文件路径
        algorithm_name: 算法名称 (用于选择调色板)
        method: 分级方法 'quantile' (分位数) 或 'equal_interval' (等比例)
        proportions: 累积分割点列表，例如 [0.20, 0.40, 0.60, 0.80]
        log_file: 日志文件句柄
    """
    
    def log(msg):
        """同时输出到控制台和日志文件"""
        print(msg)
        if log_file:
            log_file.write(msg + '\n')
    
    # 默认比例: 20%-20%-20%-20%-20% (五等分)
    if proportions is None:
        proportions = [0.20, 0.40, 0.60, 0.80]
    
    proportions_np = np.array(proportions)
    
    # 获取调色板
    palette = ALGORITHM_PALETTES.get(algorithm_name)
    if palette is None:
        log(f"❌ 错误: 未知算法 '{algorithm_name}'")
        return False
    
    # 读取TIF文件
    log(f"{'='*60}")
    log(f"正在处理: {os.path.basename(tif_path)}")
    log(f"算法: {algorithm_name.upper()}")
    log(f"方法: {'分位数 (Quantile)' if method == 'quantile' else '等比例 (Equal Interval)'}")
    log(f"-"*60)
    
    try:
        dataset = gdal.Open(tif_path)
        if dataset is None:
            log(f"❌ 无法打开文件: {tif_path}")
            return False
        
        # 读取栅格数据
        band = dataset.GetRasterBand(1)
        data = band.ReadAsArray()
        nodata = band.GetNoDataValue()
        
        # 获取有效数据
        if nodata is not None:
            valid_mask = ~np.isnan(data) & (data != nodata)
        else:
            valid_mask = ~np.isnan(data)
        
        valid_data = data[valid_mask]
        
        if len(valid_data) == 0:
            log("❌ 无有效像素数据")
            dataset = None
            return False
        
        # 统计信息
        min_val = np.nanmin(valid_data)
        max_val = np.nanmax(valid_data)
        mean_val = np.nanmean(valid_data)
        std_val = np.nanstd(valid_data)
        
        log(f"📊 基础统计信息:")
        log(f"  - 有效像素点: {len(valid_data):,}")
        log(f"  - 最小值 (Min): {min_val:.4f}")
        log(f"  - 最大值 (Max): {max_val:.4f}")
        log(f"  - 平均值 (Mean): {mean_val:.4f}")
        log(f"  - 标准差 (Std): {std_val:.4f}")
        log(f"-"*60)
        
        # 计算分级阈值
        breaks = None
        if method == 'quantile':
            # 分位数方法
            breaks = np.quantile(valid_data, proportions_np)
            log(f"📐 分位数阈值计算:")
        elif method == 'equal_interval':
            # 等比例方法
            total_range = max_val - min_val
            breaks = min_val + (total_range * proportions_np)
            log(f"📐 等比例阈值计算:")
        else:
            log(f"❌ 未知方法: {method}")
            dataset = None
            return False
        
        # 计算每个等级的单独百分比
        p_list = [proportions_np[0]]  # 第 1 级
        p_list.extend(np.diff(proportions_np))  # 第 2, 3, 4 级
        p_list.append(1.0 - proportions_np[-1])  # 第 5 级
        
        # 输出阈值信息
        grade_labels = ["低", "较低", "正常", "较高", "高"]
        log(f"  - 1级 ({grade_labels[0]}, {p_list[0]*100:.0f}%): < {breaks[0]:.4f}")
        log(f"  - 2级 ({grade_labels[1]}, {p_list[1]*100:.0f}%): {breaks[0]:.4f} - {breaks[1]:.4f}")
        log(f"  - 3级 ({grade_labels[2]}, {p_list[2]*100:.0f}%): {breaks[1]:.4f} - {breaks[2]:.4f}")
        log(f"  - 4级 ({grade_labels[3]}, {p_list[3]*100:.0f}%): {breaks[2]:.4f} - {breaks[3]:.4f}")
        log(f"  - 5级 ({grade_labels[4]}, {p_list[4]*100:.0f}%): > {breaks[3]:.4f}")
        log(f"-"*60)
        
        # 分级
        grades_1d = np.digitize(valid_data, breaks) + 1
        grades_1d = np.clip(grades_1d, 1, 5)  # 确保在1-5范围内
        
        # 统计实际分布
        log(f"📈 实际数据分布统计:")
        total_pixels = len(valid_data)
        
        for i in range(1, 6):
            count = np.count_nonzero(grades_1d == i)
            percentage = (count / total_pixels) * 100
            log(f"  - {i}级 ({grade_labels[i-1]:3s}): {percentage:6.2f}% ({count:,} 个点)")
        log(f"-"*60)
        
        # 创建完整的等级图
        height, width = data.shape
        graded_map = np.full((height, width), 0, dtype=np.uint8)  # 0 为背景
        graded_map[valid_mask] = grades_1d
        
        # 上色
        log(f"🎨 正在上色...")
        color_image = np.zeros((height, width, 4), dtype=np.uint8)
        for grade_value, color in enumerate(palette):
            color_image[graded_map == grade_value] = color
        
        # 保存为PNG
        img = Image.fromarray(color_image, 'RGBA')
        img.save(output_path)
        
        log(f"✅ 成功保存: {output_path}")
        log(f"{'='*60}\n")
        
        # 关闭数据集
        dataset = None
        
        return True
        
    except Exception as e:
        log(f"❌ 处理出错: {str(e)}")
        return False


def batch_colorize_tifs(base_dir, methods=['quantile', 'equal_interval'], 
                        proportions_list=None):
    """
    批量处理TIF文件上色
    
    参数:
        base_dir: 基础目录
        methods: 上色方法列表
        proportions_list: 比例列表，每个元素是一个比例配置
    """
    
    # 默认比例配置
    if proportions_list is None:
        proportions_list = [
            {'name': '20-20-20-20-20', 'values': [0.20, 0.40, 0.60, 0.80]},
            {'name': '15-20-30-20-15', 'values': [0.15, 0.35, 0.65, 0.85]},
        ]
    
    # 算法映射
    algorithms = {
        'prediction_agb.tif': 'agb',
        'prediction_hsl.tif': 'hsl',
        'prediction_k.tif': 'k',
        'prediction_n.tif': 'n',
        'prediction_p.tif': 'p',
        'prediction_spad.tif': 'spad',
        'prediction_zg.tif': 'zg'
    }
    
    # 创建日志文件
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_filename = os.path.join(base_dir, f"colorize_log_{timestamp}.txt")
    
    with open(log_filename, 'w', encoding='utf-8') as log_file:
        log_file.write(f"TIF 文件上色处理日志\n")
        log_file.write(f"处理时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_file.write(f"{'='*60}\n\n")
        
        print(f"\n📝 日志文件: {log_filename}\n")
        
        total_tasks = 0
        success_tasks = 0
        
        # 遍历每个TIF文件
        for tif_name, algo_name in algorithms.items():
            tif_path = os.path.join(base_dir, tif_name)
            
            if not os.path.exists(tif_path):
                msg = f"⚠️ 跳过: 找不到文件 {tif_name}\n"
                print(msg)
                log_file.write(msg)
                continue
            
            # 遍历每种方法
            for method in methods:
                # 遍历每种比例配置
                for prop_config in proportions_list:
                    total_tasks += 1
                    
                    # 构建输出文件名
                    base_name = os.path.splitext(tif_name)[0]
                    output_name = f"{base_name}_{method}_{prop_config['name']}.png"
                    output_path = os.path.join(base_dir, output_name)
                    
                    # 处理
                    success = colorize_tif(
                        tif_path=tif_path,
                        output_path=output_path,
                        algorithm_name=algo_name,
                        method=method,
                        proportions=prop_config['values'],
                        log_file=log_file
                    )
                    
                    if success:
                        success_tasks += 1
        
        # 总结
        summary = f"\n{'='*60}\n"
        summary += f"🎉 批量处理完成！\n"
        summary += f"总任务数: {total_tasks}\n"
        summary += f"成功: {success_tasks}\n"
        summary += f"失败: {total_tasks - success_tasks}\n"
        summary += f"日志文件: {log_filename}\n"
        summary += f"{'='*60}\n"
        
        print(summary)
        log_file.write(summary)


if __name__ == "__main__":
    # 设置基础目录
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    print(f"\n🚀 开始批量上色处理...")
    print(f"📁 工作目录: {base_dir}\n")
    
    # 定义要使用的比例配置
    proportions_configs = [
        {'name': '20-20-20-20-20', 'values': [0.20, 0.40, 0.60, 0.80]},  # 五等分
        {'name': '15-20-30-20-15', 'values': [0.15, 0.35, 0.65, 0.85]},  # 中间偏重
    ]
    
    # 执行批量处理
    batch_colorize_tifs(
        base_dir=base_dir,
        methods=['quantile', 'equal_interval'],
        proportions_list=proportions_configs
    )
