# !/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MVT 瓦片生成脚本
从 PostgreSQL/PostGIS 数据库导出地块数据，生成静态 MVT 瓦片

使用步骤:
1. 安装依赖: pip install psycopg2-binary oss2
2. 安装 tippecanoe (Linux/Mac): 
   - Ubuntu: sudo apt-get install tippecanoe
   - Mac: brew install tippecanoe
   - Windows: 需要使用 WSL 或 Docker
3. 修改下方的数据库连接配置
4. 运行: python generate_mvt_tiles.py
"""

import os
import json
import subprocess
import tempfile
import shutil
from datetime import datetime

# ==================== 配置区域 ====================

# PostgreSQL 数据库连接配置
DB_CONFIG = {
    'host': '<REDACTED_DB_HOST>',
    'port': 5433,
    'database': 'szhy',  # 数据库名
    'user': 'postgres',
    'password': '<REDACTED_DB_PASSWORD>',  # 请修改为实际密码
}

# 数据库模式（Schema）
DB_SCHEMA = 'smart-plant'

# 输出目录
OUTPUT_DIR = './mvt_tiles'

# 瓦片配置
TILE_CONFIG = {
    'layer_name': 'default_layer',  # 图层名称，要和前端 sourceLayer 一致
    'min_zoom': 6,  # 最小缩放级别
    'max_zoom': 18,  # 最大缩放级别
}

# 阿里云 OSS 配置 (可选，如果需要上传到 CDN)
OSS_CONFIG = {
    'enabled': True,  # 是否启用 OSS 上传
    'access_key_id': '<REDACTED_OSS_ACCESS_KEY_ID>',
    'access_key_secret': '<REDACTED_OSS_ACCESS_KEY_SECRET>',
    'bucket_name': 'yxn-app',
    'endpoint': '<REDACTED_CDN_HOST>',
    'prefix': 'archive/',  # OSS 路径前缀
}


# ==================== 导出 GeoJSON ====================

def export_geojson(output_path):
    """从数据库导出地块数据为 GeoJSON 格式"""
    try:
        import psycopg2
    except ImportError:
        print("❌ 请先安装 psycopg2: pip install psycopg2-binary")
        return False

    print("📦 连接数据库...")

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # 查询地块数据，转换为 GeoJSON
        sql = f"""
        SELECT json_build_object(
            'type', 'FeatureCollection',
            'features', COALESCE(json_agg(
                json_build_object(
                    'type', 'Feature',
                    'geometry', ST_AsGeoJSON(t.geom)::json,
                    'properties', json_build_object(
                        'id', t.id,
                        'parcel_name', t.parcel_name,
                        'parcel_number', t.parcel_number,
                        'area_acre', t.area_acre,
                        'division', t.division,
                        'brigade', t.brigade,
                        'company', t.company,
                        'land_property', t.land_property
                        'crop_type', t.crop_type,
                        'east_boundary', t.east_boundary,
                        'west_boundary', t.west_boundary,
                        'north_boundary', t.north_boundary,
                        'south_boundary', t.south_boundary

                    )
                )
            ), '[]'::json)
        )
        FROM "{DB_SCHEMA}".land_parcel_info t
        WHERE t.geom IS NOT NULL;
        """

        print("📊 执行查询...")
        cursor.execute(sql)
        result = cursor.fetchone()[0]

        # 保存为文件
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(result, f, ensure_ascii=False)

        feature_count = len(result.get('features', []))
        print(f"✅ 导出成功: {feature_count} 个地块 → {output_path}")

        cursor.close()
        conn.close()
        return True

    except Exception as e:
        print(f"❌ 数据库导出失败: {e}")
        return False


# ==================== 生成 MVT 瓦片 ====================

def generate_tiles(geojson_path, output_dir):
    """使用 tippecanoe 生成 MVT 瓦片"""

    # 检查 tippecanoe 是否安装
    if shutil.which('tippecanoe') is None:
        print("❌ tippecanoe 未安装！")
        print("   Ubuntu: sudo apt-get install tippecanoe")
        print("   Mac: brew install tippecanoe")
        print("   Windows: 请使用 WSL 或 Docker")
        return False

    print("🔨 开始生成 MVT 瓦片...")

    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)

    # tippecanoe 命令
    cmd = [
        'tippecanoe',
        '-o', os.path.join(output_dir, 'parcels.mbtiles'),
        '-z', str(TILE_CONFIG['max_zoom']),  # 最大缩放级别
        '-Z', str(TILE_CONFIG['min_zoom']),  # 最小缩放级别
        '-l', TILE_CONFIG['layer_name'],  # 图层名称
        '--no-tile-size-limit',  # 不限制瓦片大小
        '--no-feature-limit',  # 不限制要素数量
        '--simplification=10',  # 简化程度
        '--detect-shared-borders',  # 检测共享边界
        '--force',  # 覆盖已存在的文件
        geojson_path
    ]

    print(f"   执行命令: {' '.join(cmd)}")

    try:
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            print("✅ MBTiles 生成成功!")
        else:
            print(f"❌ tippecanoe 执行失败: {result.stderr}")
            return False

    except Exception as e:
        print(f"❌ 执行 tippecanoe 失败: {e}")
        return False

    # 解压 MBTiles 为目录结构
    mbtiles_path = os.path.join(output_dir, 'parcels.mbtiles')
    tiles_dir = os.path.join(output_dir, 'tiles')

    print("📂 解压瓦片到目录结构...")

    # 使用 tile-join 解压
    if shutil.which('tile-join') is not None:
        cmd_extract = [
            'tile-join',
            '--output-to-directory', tiles_dir,
            '--no-tile-compression',
            '--force',
            mbtiles_path
        ]

        try:
            subprocess.run(cmd_extract, capture_output=True, text=True)
            print(f"✅ 瓦片已解压到: {tiles_dir}")
        except Exception as e:
            print(f"⚠️ 解压失败: {e}，可以手动解压 MBTiles")
    else:
        print(f"⚠️ tile-join 未安装，MBTiles 文件位于: {mbtiles_path}")
        print("   可以使用其他工具解压，或直接使用 MBTiles 服务器")

    return True


# ==================== 上传到 OSS ====================

def upload_to_oss(tiles_dir):
    """上传瓦片到阿里云 OSS"""

    if not OSS_CONFIG['enabled']:
        print("⏭️ OSS 上传已禁用，跳过")
        return True

    try:
        import oss2
    except ImportError:
        print("❌ 请先安装 oss2: pip install oss2")
        return False

    print("☁️ 开始上传到 OSS...")

    auth = oss2.Auth(OSS_CONFIG['access_key_id'], OSS_CONFIG['access_key_secret'])
    bucket = oss2.Bucket(auth, OSS_CONFIG['endpoint'], OSS_CONFIG['bucket_name'])

    uploaded_count = 0

    for root, dirs, files in os.walk(tiles_dir):
        for filename in files:
            if filename.endswith('.pbf'):
                local_path = os.path.join(root, filename)
                # 计算 OSS 路径
                relative_path = os.path.relpath(local_path, tiles_dir)
                oss_path = OSS_CONFIG['prefix'] + relative_path.replace('\\', '/')

                try:
                    bucket.put_object_from_file(oss_path, local_path)
                    uploaded_count += 1
                    if uploaded_count % 100 == 0:
                        print(f"   已上传 {uploaded_count} 个瓦片...")
                except Exception as e:
                    print(f"❌ 上传失败 {oss_path}: {e}")

    print(f"✅ 上传完成: {uploaded_count} 个瓦片")
    return True


# ==================== 主函数 ====================

def main():
    print("=" * 60)
    print("🗺️  MVT 瓦片生成工具")
    print("=" * 60)
    print(f"⏰ 开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 60)

    # 创建临时目录
    with tempfile.TemporaryDirectory() as temp_dir:
        geojson_path = os.path.join(temp_dir, 'parcels.geojson')

        # 步骤1: 导出 GeoJSON
        print("\n📍 步骤 1/3: 导出 GeoJSON")
        if not export_geojson(geojson_path):
            print("❌ 导出失败，程序终止")
            return

        # 步骤2: 生成 MVT 瓦片
        print("\n📍 步骤 2/3: 生成 MVT 瓦片")
        if not generate_tiles(geojson_path, OUTPUT_DIR):
            print("❌ 瓦片生成失败，程序终止")
            return

        # 步骤3: 上传到 OSS (可选)
        print("\n📍 步骤 3/3: 上传到 OSS")
        tiles_dir = os.path.join(OUTPUT_DIR, 'tiles')
        if os.path.exists(tiles_dir):
            upload_to_oss(tiles_dir)
        else:
            print("⏭️ 瓦片目录不存在，跳过上传")

    print("\n" + "=" * 60)
    print("✅ 全部完成!")
    print(f"⏰ 结束时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    print(f"""
📋 后续步骤:
1. 瓦片文件位于: {OUTPUT_DIR}/tiles/
2. 目录结构: {{z}}/{{x}}/{{y}}.pbf
3. 上传到您的服务器或 CDN
4. 修改前端 MVT_TILE_URL 为新地址

示例 Nginx 配置:
    location /tiles/ {{
        alias {os.path.abspath(OUTPUT_DIR)}/tiles/;
        add_header Content-Type application/vnd.mapbox-vector-tile;
        add_header Content-Encoding gzip;
        add_header Access-Control-Allow-Origin *;
    }}
""")


if __name__ == '__main__':
    main()
