import ee
import sys

# --- 1. GEE 初始化 ---
try:
    ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
    print("GEE 初始化成功！")
except Exception as e:
    print(f"GEE 初始化失败: {e}")
    sys.exit()

# --- 2. 在这里配置你的参数 ---

# 1. 定义你的地块 (AOI - Area of Interest)
# (和你 main.py 中一样)
coords_list = [
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
MY_PARCEL_AOI = ee.Geometry.Polygon(coords_list)

# 2. 定义你要搜索的日期范围
# (我使用了你上一个脚本中的日期范围 '2025-09-20' to '2025-09-30')
START_DATE = '2025-09-10'
END_DATE = '2025-09-30'


# --- 3. GEE 服务器端函数 ---

# 这是一个在服务器上运行的函数，用于提取每张影像的信息
def get_image_info(image):
    date = ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')
    cloud_cover = ee.Number(image.get('CLOUDY_PIXEL_PERCENTAGE'))

    # 额外信息：获取影像的 S2 "MGRS_TILE" (瓦片编号)，以便区分同一天的不同影像
    tile_id = image.get('MGRS_TILE')

    # 返回一个 ee.Feature，这样我们可以将它作为一个列表获取
    return ee.Feature(None, {
        'date': date,
        'cloud_cover': cloud_cover,
        'tile': tile_id
    })


# --- 4. 主执行逻辑 ---

print(f"\n正在搜索 {START_DATE} 到 {END_DATE} 之间，")
print(f"覆盖你地块的所有 Sentinel-2 影像...")

try:
    # 1. 搜索影像集
    collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
        .filterDate(START_DATE, END_DATE) \
        .filterBounds(MY_PARCEL_AOI) \
        .sort('system:time_start')  # 按日期排序

    # 2. 映射函数以提取信息
    info_list_fc = collection.map(get_image_info)

    # 3. getInfo() - 从 GEE 服务器获取数据到本地
    # 这可能是个慢操作
    print("正在从 GEE 获取信息... (如果影像多，可能需要一点时间)")
    info_list = info_list_fc.getInfo()['features']

    # 4. 打印结果
    if not info_list:
        print("\n--- 结果 ---")
        print("在此时间范围和地块内未找到任何影像。")
        print("请尝试扩大日期范围。")
    else:
        print("\n--- 找到的遥感影像日期 ---")
        print("------------------------------------------")
        print(f"{'拍摄日期':<15} | {'云量 (%)':<10} | {'S2 瓦片编号':<10}")
        print("------------------------------------------")
        for feature in info_list:
            props = feature['properties']
            print(f"{props['date']:<15} | {props['cloud_cover']:.2f} {'' :<6} | {props['tile']}")

        print("\n*注: 同一天可能有多景影像，因为你的地块可能位于不同S2瓦片的交界处。")


except Exception as e:
    print(f"查询 GEE 时出错: {e}")
    print("请检查你的AOI坐标和日期格式是否正确。")