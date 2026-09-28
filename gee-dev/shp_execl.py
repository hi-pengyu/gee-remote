import geopandas as gpd
import json

# === 配置输入文件路径 ===
file_path = r'C:\Users\1\xwechat_files\wxid_bc5l2xag8ruz12_99c3\msg\file\2025-12\12.shp'

# 1. 读取 SHP 文件
gdf = gpd.read_file(file_path)

# 2. 【关键修改】智能处理坐标系
if gdf.crs is None:
    # 💥 情况 A: 缺少 .prj 文件或读取不到坐标系
    print("⚠️ 警告：未检测到原始坐标系，强制指定为 EPSG:4326")
    # 这里假设你的源数据本身就是经纬度。如果是其他坐标系，请修改下面的代码
    gdf.set_crs("EPSG:4326", inplace=True)
elif gdf.crs != "EPSG:4326":
    # 🔄 情况 B: 有坐标系，但不是 WGS84，需要转换
    print(f"检测到原始坐标系 {gdf.crs.name}，正在转换为 WGS84...")
    gdf = gdf.to_crs("EPSG:4326")

# 3. 提取坐标并格式化
all_features_coords = []

# 💡 增加一步：把 MultiPolygon "打散" 成 Polygon，防止漏掉复杂地块
gdf = gdf.explode(index_parts=False)

for index, row in gdf.iterrows():
    geom = row.geometry

    if geom.geom_type == 'Polygon':
        coords = list(geom.exterior.coords)
        formatted_list = [{"lng": round(x, 6), "lat": round(y, 6)} for x, y in coords]
        all_features_coords.append(formatted_list)

    elif geom.geom_type == 'LineString':
        coords = list(geom.coords)
        formatted_list = [{"lng": round(x, 6), "lat": round(y, 6)} for x, y in coords]
        all_features_coords.append(formatted_list)

# 4. 打印结果
if all_features_coords:
    print(f"成功提取 {len(all_features_coords)} 个地块")
    # print(json.dumps(all_features_coords[0], ensure_ascii=False))

    # 直接保存为文件，方便查看
    with open('output_coords.json', 'w', encoding='utf-8') as f:
        json.dump(all_features_coords, f, ensure_ascii=False)
    print("数据已保存到 output_coords.json")
else:
    print("未检测到支持的几何类型")