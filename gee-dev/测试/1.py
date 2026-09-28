import geopandas as gpd
import os
import json
import uuid
import hashlib
import psycopg2
from shapely.geometry import Polygon, MultiPolygon

# ================= 配置区域 =================

# 数据库连接配置
DB_CONFIG = {
    "host": "<REDACTED_DB_HOST>",
    "port": "5433",
    "user": "postgres",
    "password": "<REDACTED_DB_PASSWORD>",
    "database": "szhy"
}

# 【新增】数据库模式 (Schema)
# 如果你的模式叫 smart-plant，直接填 smart-plant 即可，代码会自动加双引号处理特殊字符
DB_SCHEMA = "smart-plant"

# 目标表名
TABLE_NAME = "land_parcel_info"

# 本地去重记录文件路径
HISTORY_FILE = "uploaded_history.txt"


# ===========================================

def load_history():
    if not os.path.exists(HISTORY_FILE):
        return set()
    with open(HISTORY_FILE, 'r', encoding='utf-8') as f:
        return set(line.strip() for line in f if line.strip())


def append_history(coord_hash):
    with open(HISTORY_FILE, 'a', encoding='utf-8') as f:
        f.write(f"{coord_hash}\n")


def generate_hash(coords_list):
    coords_str = json.dumps(coords_list, sort_keys=True)
    return hashlib.md5(coords_str.encode('utf-8')).hexdigest()


def write_to_db(cursor, name, coords_list, wkt, coord_hash, history_set):
    """直接写入 PostgreSQL 数据库 (指定 Schema)"""
    try:
        coords_str = json.dumps(coords_list, ensure_ascii=False)

        # 【关键修改】
        # 1. ST_Force2D(...): 强制去掉 Z 轴高度信息，把 3D 转为 2D
        # 2. ST_Multi(...): 强制转为 MultiPolygon
        sql = f"""
            INSERT INTO "{DB_SCHEMA}".{TABLE_NAME} (parcel_name, boundary_coordinates, geom)
            VALUES (%s, %s, ST_Multi(ST_Force2D(ST_GeomFromText(%s, 4326))))
        """

        cursor.execute(sql, (name, coords_str, wkt))

        print(f"    [成功] 写入数据库: {name}")
        history_set.add(coord_hash)
        append_history(coord_hash)

    except Exception as e:
        print(f"    [失败] 写入数据库失败: {name} | 错误: {e}")
        cursor.connection.rollback()

def convert_and_upload(folder_path):
    # 1. 连接数据库
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        print(f"✅ 数据库连接成功 (目标模式: {DB_SCHEMA})")
    except Exception as e:
        print(f"❌ 数据库连接失败: {e}")
        return

    # 2. 加载历史
    history_set = load_history()
    print(f"已加载 {len(history_set)} 条历史记录。")

    shp_files = [f for f in os.listdir(folder_path) if f.endswith('.shp')]
    if not shp_files:
        print(f"在 {folder_path} 下未找到 .shp 文件")
        return

    print(f"找到 {len(shp_files)} 个 SHP 文件，准备开始处理...")

    for file_name in shp_files:
        file_path = os.path.join(folder_path, file_name)
        print(f"\n正在读取文件: {file_name}")

        try:
            gdf = gpd.read_file(file_path)

            if gdf.crs and gdf.crs.to_string() != "EPSG:4326":
                gdf = gdf.to_crs("EPSG:4326")

            for index, row in gdf.iterrows():
                geom = row.geometry

                def extract_coords(exterior_coords):
                    return [{"lng": round(p[0], 6), "lat": round(p[1], 6)} for p in exterior_coords]

                def process_single_part(shapely_geom, p_name):
                    # A. 提取坐标
                    formatted_coords = extract_coords(shapely_geom.exterior.coords)
                    # B. 计算 Hash
                    c_hash = generate_hash(formatted_coords)
                    if c_hash in history_set:
                        print(f"    [跳过] 地块重复 (Hash: {c_hash[:8]}...)")
                        return
                    # C. WKT
                    wkt_str = shapely_geom.wkt
                    # D. 写入
                    write_to_db(cursor, p_name, formatted_coords, wkt_str, c_hash, history_set)

                if geom.geom_type == 'Polygon':
                    random_suffix = uuid.uuid4().hex[:6]
                    parcel_name = f"{file_name[0:3]}_{random_suffix}"
                    process_single_part(geom, parcel_name)

                elif geom.geom_type == 'MultiPolygon':
                    for idx, part in enumerate(geom.geoms):
                        random_suffix = uuid.uuid4().hex[:6]
                        parcel_name = f"自动_{random_suffix}_p{idx}"
                        process_single_part(part, parcel_name)
                else:
                    print(f"  跳过不支持的类型: {geom.geom_type}")

        except Exception as e:
            print(f"处理文件 {file_name} 时出错: {e}")

    if conn:
        cursor.close()
        conn.close()
        print("\n所有操作完成，数据库连接已关闭。")


if __name__ == "__main__":
    folder_path = r"F:\123shp图"
    convert_and_upload(folder_path)