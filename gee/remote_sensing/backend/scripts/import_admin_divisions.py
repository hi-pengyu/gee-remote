"""
导入阿里云DataV行政区边界数据到数据库

使用方法：
python scripts/import_admin_divisions.py

数据来源：
- 省级：https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json
- 市级：https://geo.datav.aliyun.com/areas_v3/bound/100000_full_city.json
- 区县级：https://geo.datav.aliyun.com/areas_v3/bound/{省级adcode}_full.json
"""

import requests
import psycopg2
from psycopg2.extras import execute_batch
import json
from shapely.geometry import shape, mapping
from shapely import wkt
import time

# 数据库配置
DB_CONFIG = {
    'host': '<REDACTED_DB_HOST>',
    'port': 5433,
    'user': 'postgres',
    'password': '<REDACTED_DB_PASSWORD>',
    'database': 'remote_sensing'
}


# 阿里云DataV API基础URL
DATAV_BASE_URL = "https://geo.datav.aliyun.com/areas_v3/bound"


def get_connection():
    """获取数据库连接"""
    return psycopg2.connect(**DB_CONFIG)


def enable_postgis(conn):
    """启用PostGIS扩展"""
    try:
        cursor = conn.cursor()
        cursor.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
        conn.commit()
        cursor.close()
        print("✅ PostGIS扩展已启用")
    except Exception as e:
        print(f"⚠️  PostGIS扩展启用失败（可能已存在）: {e}")
        conn.rollback()


def fetch_geojson(url):
    """从URL获取GeoJSON数据"""
    try:
        print(f"📥 正在下载: {url}")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        data = response.json()
        print(f"✅ 下载成功，包含 {len(data.get('features', []))} 个区域")
        return data
    except Exception as e:
        print(f"❌ 下载失败: {e}")
        return None


def geometry_to_wkt(geometry):
    """将GeoJSON几何转换为WKT格式"""
    try:
        geom = shape(geometry)
        return geom.wkt
    except Exception as e:
        print(f"⚠️  几何转换失败: {e}")
        return None


def calculate_centroid(geometry):
    """计算几何中心点"""
    try:
        geom = shape(geometry)
        centroid = geom.centroid
        return centroid.x, centroid.y
    except Exception as e:
        print(f"⚠️  中心点计算失败: {e}")
        return None, None


def import_province_data(conn):
    """导入省级数据"""
    print("\n" + "="*60)
    print("📍 开始导入省级数据")
    print("="*60)
    
    url = f"{DATAV_BASE_URL}/100000_full.json"
    data = fetch_geojson(url)
    
    if not data:
        print("❌ 省级数据下载失败")
        return []
    
    cursor = conn.cursor()
    province_adcodes = []
    
    for feature in data.get('features', []):
        properties = feature.get('properties', {})
        geometry = feature.get('geometry')
        
        adcode = properties.get('adcode')
        name = properties.get('name')
        
        if not adcode or not name:
            continue
        
        # 确保 adcode 是字符串类型
        adcode = str(adcode)
        province_adcodes.append(adcode)
        
        # 转换几何
        geom_wkt = geometry_to_wkt(geometry)
        center_lon, center_lat = calculate_centroid(geometry)
        
        try:
            cursor.execute('''
                INSERT INTO china_administrative_divisions 
                (adcode, name, level, parent_adcode, center_lon, center_lat, geometry)
                VALUES (%s, %s, %s, %s, %s, %s, ST_GeomFromText(%s, 4326))
                ON CONFLICT (adcode) DO UPDATE SET
                    name = EXCLUDED.name,
                    geometry = EXCLUDED.geometry,
                    center_lon = EXCLUDED.center_lon,
                    center_lat = EXCLUDED.center_lat
            ''', (adcode, name, 'province', None, center_lon, center_lat, geom_wkt))
            
            print(f"  ✅ {name} ({adcode})")
        except Exception as e:
            print(f"  ❌ {name} ({adcode}) 导入失败: {e}")
            conn.rollback()
            continue
    
    conn.commit()
    cursor.close()
    
    print(f"\n✅ 省级数据导入完成，共 {len(province_adcodes)} 个省份")
    return province_adcodes


def import_city_data(conn):
    """导入市级数据（全国城市）"""
    print("\n" + "="*60)
    print("📍 开始导入市级数据")
    print("="*60)
    
    url = f"{DATAV_BASE_URL}/100000_full_city.json"
    data = fetch_geojson(url)
    
    if not data:
        print("❌ 市级数据下载失败")
        return []
    
    cursor = conn.cursor()
    city_adcodes = []
    
    for feature in data.get('features', []):
        properties = feature.get('properties', {})
        geometry = feature.get('geometry')
        
        adcode = properties.get('adcode')
        name = properties.get('name')
        parent = properties.get('parent', {})
        parent_adcode = parent.get('adcode') if parent else None
        
        if not adcode or not name:
            continue
        
        # 确保 adcode 是字符串类型
        adcode = str(adcode)
        if parent_adcode:
            parent_adcode = str(parent_adcode)
        
        city_adcodes.append(adcode)
        
        # 转换几何
        geom_wkt = geometry_to_wkt(geometry)
        center_lon, center_lat = calculate_centroid(geometry)
        
        try:
            cursor.execute('''
                INSERT INTO china_administrative_divisions 
                (adcode, name, level, parent_adcode, center_lon, center_lat, geometry)
                VALUES (%s, %s, %s, %s, %s, %s, ST_GeomFromText(%s, 4326))
                ON CONFLICT (adcode) DO UPDATE SET
                    name = EXCLUDED.name,
                    parent_adcode = EXCLUDED.parent_adcode,
                    geometry = EXCLUDED.geometry,
                    center_lon = EXCLUDED.center_lon,
                    center_lat = EXCLUDED.center_lat
            ''', (adcode, name, 'city', parent_adcode, center_lon, center_lat, geom_wkt))
            
            if len(city_adcodes) % 10 == 0:
                print(f"  ✅ 已导入 {len(city_adcodes)} 个城市...")
        except Exception as e:
            print(f"  ❌ {name} ({adcode}) 导入失败: {e}")
            conn.rollback()
            continue
    
    conn.commit()
    cursor.close()
    
    print(f"\n✅ 市级数据导入完成，共 {len(city_adcodes)} 个城市")
    return city_adcodes


def import_district_data(conn, province_adcodes):
    """导入区县级数据"""
    print("\n" + "="*60)
    print("📍 开始导入区县级数据")
    print("="*60)
    
    cursor = conn.cursor()
    total_districts = 0
    
    for province_adcode in province_adcodes:
        # 确保 adcode 是字符串类型
        province_adcode_str = str(province_adcode)
        
        # 获取省份名称
        cursor.execute('SELECT name FROM china_administrative_divisions WHERE adcode = %s', (province_adcode_str,))
        result = cursor.fetchone()
        province_name = result[0] if result else province_adcode_str
        
        print(f"\n📍 正在导入 {province_name} 的区县数据...")
        
        # 正确的区县数据 URL
        url = f"{DATAV_BASE_URL}/{province_adcode_str}_full_district.json"
        data = fetch_geojson(url)
        
        if not data:
            print(f"  ⚠️  {province_name} 区县数据下载失败，跳过")
            continue
        
        district_count = 0
        for feature in data.get('features', []):
            properties = feature.get('properties', {})
            geometry = feature.get('geometry')
            
            adcode = properties.get('adcode')
            name = properties.get('name')
            parent = properties.get('parent', {})
            parent_adcode = parent.get('adcode') if parent else None
            
            if not adcode or not name:
                continue
            
            # 确保 adcode 是字符串类型
            adcode = str(adcode)
            if parent_adcode:
                parent_adcode = str(parent_adcode)
            
            # 判断行政区级别（中国行政区划代码都是6位）
            # 省级: 后4位是00 (如 110000)
            # 市级: 后2位是00但后4位不是00 (如 110100)  
            # 区县级: 后2位不是00 (如 110101)
            
            if adcode.endswith('0000'):
                # 省级，跳过（已经导入过了）
                continue
            elif adcode.endswith('00'):
                # 市级，跳过（已经导入过了）
                continue
            
            # 只导入区县级数据
            # 转换几何
            geom_wkt = geometry_to_wkt(geometry)
            center_lon, center_lat = calculate_centroid(geometry)
            
            try:
                cursor.execute('''
                    INSERT INTO china_administrative_divisions 
                    (adcode, name, level, parent_adcode, center_lon, center_lat, geometry)
                    VALUES (%s, %s, %s, %s, %s, %s, ST_GeomFromText(%s, 4326))
                    ON CONFLICT (adcode) DO UPDATE SET
                        name = EXCLUDED.name,
                        parent_adcode = EXCLUDED.parent_adcode,
                        geometry = EXCLUDED.geometry,
                        center_lon = EXCLUDED.center_lon,
                        center_lat = EXCLUDED.center_lat
                ''', (adcode, name, 'district', parent_adcode, center_lon, center_lat, geom_wkt))
                
                district_count += 1
                total_districts += 1
            except Exception as e:
                print(f"  ❌ {name} ({adcode}) 导入失败: {e}")
                conn.rollback()
                continue
        
        conn.commit()
        print(f"  ✅ {province_name} 完成，导入 {district_count} 个区县")
        
        # 避免请求过快
        time.sleep(0.5)
    
    cursor.close()
    print(f"\n✅ 区县级数据导入完成，共 {total_districts} 个区县")


def create_spatial_index(conn):
    """创建空间索引"""
    print("\n" + "="*60)
    print("📍 创建空间索引")
    print("="*60)
    
    try:
        cursor = conn.cursor()
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_admin_geometry 
            ON china_administrative_divisions USING GIST(geometry)
        ''')
        conn.commit()
        cursor.close()
        print("✅ 空间索引创建成功")
    except Exception as e:
        print(f"❌ 空间索引创建失败: {e}")
        conn.rollback()


def show_statistics(conn):
    """显示导入统计"""
    print("\n" + "="*60)
    print("📊 导入统计")
    print("="*60)
    
    cursor = conn.cursor()
    
    # 按级别统计
    cursor.execute('''
        SELECT level, COUNT(*) as count
        FROM china_administrative_divisions
        GROUP BY level
        ORDER BY 
            CASE level
                WHEN 'province' THEN 1
                WHEN 'city' THEN 2
                WHEN 'district' THEN 3
                ELSE 4
            END
    ''')
    
    results = cursor.fetchall()
    
    level_names = {
        'province': '省级',
        'city': '市级',
        'district': '区县级'
    }
    
    total = 0
    for level, count in results:
        level_name = level_names.get(level, level)
        print(f"  {level_name}: {count} 个")
        total += count
    
    print(f"\n  总计: {total} 个行政区")
    
    cursor.close()


def main():
    """主函数"""
    print("\n" + "="*60)
    print("🚀 开始导入阿里云DataV行政区边界数据")
    print("="*60)
    print(f"数据库: {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}")
    print("="*60)
    
    try:
        # 连接数据库
        conn = get_connection()
        print("✅ 数据库连接成功")
        
        # 启用PostGIS
        enable_postgis(conn)
        
        # 导入省级数据
        province_adcodes = import_province_data(conn)
        
        # 导入市级数据
        city_adcodes = import_city_data(conn)
        
        # 导入区县级数据（可选，数据量大，耗时较长）
        import_districts = input("\n是否导入区县级数据？(y/n，数据量大约2800+个区县，耗时约5-10分钟): ").lower()
        if import_districts == 'y':
            import_district_data(conn, province_adcodes)
        else:
            print("⏭️  跳过区县级数据导入")
        
        # 创建空间索引
        create_spatial_index(conn)
        
        # 显示统计
        show_statistics(conn)
        
        conn.close()
        
        print("\n" + "="*60)
        print("🎉 导入完成！")
        print("="*60)
        
    except Exception as e:
        print(f"\n❌ 导入失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
