import geopandas as gpd
import json

# === 配置输入文件路径 ===
file_path = r'C:\Users\1\xwechat_files\wxid_bc5l2xag8ruz12_99c3\msg\file\2025-12\12.shp'

# 1. 读取 SHP 文件
gdf = gpd.read_file(file_path)

# 2. 【核心修改】设置原始坐标系为 CGCS2000 投影
if gdf.crs is None:
    # 这里使用 EPSG:4546 (中央经线 87度)，适用于石河子、玛纳斯、沙湾、乌鲁木齐
    # 如果转换后的位置偏了，请尝试改成 EPSG:4545 (中央经线 84度)
    print("⚠️ 正在应用 CGCS2000 高斯-克吕格投影 (EPSG:4546)...")
    gdf.set_crs("EPSG:4546", inplace=True)

# 3. 转换为经纬度 (WGS84)
# 虽然 CGCS2000 的经纬度和 WGS84 几乎一样，但为了通用性还是转一下
if gdf.crs != "EPSG:4326":
    gdf = gdf.to_crs("EPSG:4326")

# 4. 提取坐标并格式化
all_features_coords = []
gdf = gdf.explode(index_parts=False)  # 处理多部件几何体

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

# 5. 验证结果
if all_features_coords:
    # 打印第一个点的坐标，帮你肉眼验证
    first_point = all_features_coords[0][0]
    print(f"\n转换成功！第一点坐标: 经度 {first_point['lng']}, 纬度 {first_point['lat']}")

    if 73 < first_point['lng'] < 97 and 34 < first_point['lat'] < 50:
        print("✅ 坐标范围看起来在新疆境内，转换正确。")
    else:
        print("❌ 警告：坐标看起来不在新疆，请尝试更改 EPSG 代码 (如 4545 或 4547)。")

    # 保存
    with open('output_coords.json', 'w', encoding='utf-8') as f:
        json.dump(all_features_coords, f, ensure_ascii=False)