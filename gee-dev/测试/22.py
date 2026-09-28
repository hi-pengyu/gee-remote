import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

# ================= 高级配置区域 =================
SHP_FOLDER_PATH = r"E:\123shp图"
OUTPUT_IMAGE_NAME = "hd_overlay.png"

# 【关键配置】目标图片宽度（像素）
# 设置为 6000~10000 可以保证极高的清晰度
# 如果你的地块非常多且密集，建议设置 8000 以上
TARGET_WIDTH_PIXELS = 8000

# 线条粗细 (因为图片像素很大，线条必须相应变粗，否则看不见)
LINE_WIDTH = 1.0

# 边框颜色方案
# 选项: 'distinct' (每个地块不同颜色), 'red', 'yellow', 'cyan' (统一亮色)
COLOR_MODE = 'distinct'


# ===========================================

def generate_high_res_overlay(folder_path, output_image):
    print(f"正在扫描文件夹: {folder_path} ...")
    shp_files = [f for f in os.listdir(folder_path) if f.endswith('.shp')]

    if not shp_files:
        print("❌ 未找到 .shp 文件。")
        return

    gdfs_to_merge = []

    # 1. 读取并转换坐标
    for file_name in shp_files:
        file_path = os.path.join(folder_path, file_name)
        try:
            gdf = gpd.read_file(file_path)
            if gdf.crs and gdf.crs.to_string() != "EPSG:4326":
                gdf = gdf.to_crs("EPSG:4326")
            gdfs_to_merge.append(gdf)
        except Exception as e:
            print(f"⚠️ 跳过坏文件 {file_name}: {e}")

    if not gdfs_to_merge:
        return

    print("正在合并数据...")
    merged_gdf = pd.concat(gdfs_to_merge, ignore_index=True)

    # 2. 计算边界
    minx, miny, maxx, maxy = merged_gdf.total_bounds

    # 3. 计算画布尺寸以匹配目标像素
    # 这里的逻辑是：为了保证输出图片有 TARGET_WIDTH_PIXELS 那么宽，我们需要倒推 figsize 和 dpi
    geo_width = maxx - minx
    geo_height = maxy - miny
    aspect_ratio = geo_height / geo_width

    # 设定 DPI 为 300 (打印级清晰度)
    dpi = 300

    # 根据目标像素计算物理尺寸 (英寸)
    # 宽度 (英寸) = 目标像素 / DPI
    figsize_width = TARGET_WIDTH_PIXELS / dpi
    figsize_height = figsize_width * aspect_ratio

    print(f"准备渲染高清图: 目标宽 {TARGET_WIDTH_PIXELS}px | 估算高 {int(TARGET_WIDTH_PIXELS * aspect_ratio)}px")
    print(f"画布物理尺寸: {figsize_width:.2f} x {figsize_height:.2f} 英寸 | DPI: {dpi}")

    # 4. 创建绘图
    # 增加这个约束是为了防止超大图片导致内存溢出，Matplotlib默认有限制
    plt.rcParams['agg.path.chunksize'] = 10000

    fig, ax = plt.subplots(figsize=(figsize_width, figsize_height), dpi=dpi)

    # 设置全透明背景
    fig.patch.set_facecolor('none')
    ax.patch.set_facecolor('none')

    # 5. 设置颜色逻辑
    if COLOR_MODE == 'distinct':
        # 生成一个随机颜色列，利用 cmap 映射
        # 'hsv' 或 'jet' 色谱能保证颜色差异明显
        merged_gdf['color_id'] = np.arange(len(merged_gdf))
        plot_kwargs = {
            'column': 'color_id',
            'cmap': 'hsv',  # 彩虹色谱，确保颜色差异大
            'categorical': False
        }
    else:
        # 统一单色
        plot_kwargs = {
            'edgecolor': COLOR_MODE
        }

    # 6. 绘图核心
    print("正在绘制矢量图形 (这可能需要几秒钟)...")
    merged_gdf.plot(
        ax=ax,
        facecolor='none',  # 【关键】内部完全透明
        linewidth=LINE_WIDTH,  # 【关键】高像素下线条要粗
        **plot_kwargs
    )

    # 如果是 'distinct' 模式，plot默认可能不会设置edgecolor为cmap，需要特殊处理
    # 上面的 column+cmap 只有在 geometry 是多边形且没有设置 facecolor='none' 时才自动填充颜色
    # 为了让 *边框* (edge) 变色而内部透明，我们需要手动处理一下：
    if COLOR_MODE == 'distinct':
        # 清除上面的绘制，重新用高级方式绘制边框
        ax.clear()
        # 按照索引循环绘制，或者使用边界着色技巧
        # 更高效的方法：直接应用 colormap 到 color 参数，不填 facecolor
        merged_gdf.plot(
            ax=ax,
            facecolor='none',  # 内部透明
            edgecolor=plt.cm.hsv(np.linspace(0, 1, len(merged_gdf))),  # 为每个要素生成不同边框色
            linewidth=LINE_WIDTH
        )

    # 7. 移除坐标轴和多余留白
    ax.set_axis_off()
    ax.set_xlim(minx, maxx)
    ax.set_ylim(miny, maxy)

    print("正在保存高清 PNG (文件较大，请稍候)...")
    plt.savefig(
        output_image,
        transparent=True,
        bbox_inches='tight',
        pad_inches=0,
        dpi=dpi
    )
    plt.close(fig)

    print(f"\n✅ 高清渲染完成: {output_image}")
    print("=" * 50)
    print("【前端定位坐标 (WGS84)】")
    print(f"Top-Left (左上):     [{maxy:.8f}, {minx:.8f}]")
    print(f"Bottom-Right (右下): [{miny:.8f}, {maxx:.8f}]")
    print("=" * 50)


if __name__ == "__main__":
    generate_high_res_overlay(SHP_FOLDER_PATH, OUTPUT_IMAGE_NAME)