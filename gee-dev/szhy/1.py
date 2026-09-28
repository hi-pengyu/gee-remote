import geopandas as gpd
import matplotlib.pyplot as plt

# 读取 SHP 文件
file_path = r"F:\gee-简单版\szhy\1连_全要素.dbf"
gdf = gpd.read_file(file_path)

# --- 设置绘图风格 ---

# 创建画布，figsize 控制图片比例 (宽, 高)
fig, ax = plt.subplots(figsize=(10, 10))

# 绘制
# column: 如果你想根据某列属性填色（例如 'type' 或 'population'）
# cmap: 颜色映射表 (例如 'Set2', 'viridis', 'Reds')
# edgecolor: 边界线颜色
# linewidth: 边界线宽度
gdf.plot(
    ax=ax,
    color='lightblue',      # 填充颜色 (如果不用 column 分类)
    edgecolor='black',      # 边框颜色
    linewidth=0.5,          # 边框粗细
    alpha=0.8               # 透明度 (0-1)
)

# --- 调整布局 ---

# 设置标题 (支持中文需配置字体，这里用英文演示)
ax.set_title("My Map Visualization", fontsize=15)

# 去除坐标轴 (通常地图不需要显示经纬度轴)
ax.set_axis_off()

# --- 保存图片 ---

# dpi: 分辨率，300 为打印级清晰度
# bbox_inches='tight': 去除周围多余的白边
# transparent=True: 背景透明
plt.savefig("output_high_res.png", dpi=300, bbox_inches='tight', transparent=True)

print("图片已保存！")