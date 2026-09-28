"""
快速导入行政区数据（仅省市级）

使用方法：
python scripts/import_admin_quick.py

说明：
- 仅导入省级和市级数据（约400个）
- 导入速度快，约1-2分钟
- 适合快速测试和开发环境
"""

import requests
import psycopg2
import json
from shapely.geometry import shape

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 5433,
    'user': 'postgres',
    'password': '<REDACTED_DB_PASSWORD>',
    'database': 'gee_monitor'
}

# 阿里云DataV API
PROVINCE_URL = "https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json"
CITY_URL = "https://geo.datav.aliyun.com/areas_v3/bound/100000_full_city.json"


def get_connection():
    """获取数据库连接"""
    return psycopg2.connect(**DB_CONFIG)


def enable_postgis(conn):
    """启用PostGIS扩展"""
    cursor = conn.cursor()
    try:
        cursor.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
        conn.commit()
        print("✅ PostGIS扩展已启用")
    except:
        conn.rollback()
        print("⚠️  PostGIS扩展已存在")
    cursor.close()


def fetch_and_import(conn, url, level, parent_key='parent'):
    """下载并导入数据"""
    print(f"\n📥 正在下载 {level} 数据...")
    
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        data = response.json()
        
        features = data.get('features', [])
        print(f"✅ 下载成功，共 {len(features)} 个区域")
        
        cursor = conn.cursor()
        success_count = 0
        
        for feature in features:
            properties = feature.get('properties', {})
            geometry = feature.get('geometry')
            
            adcode = properties.get('adcode')
            name = properties.get('name')
            parent = properties.get(parent_key, {})
            parent_adcode = parent.get('adcode') if isinstance(parent, dict) else None
            
            if not adcode or not name:
                continue
            
            # 计算中心点
            try:
                geom = shape(geometry)
                centroid = geom.centroid
                center_lon, center_lat = centroid.x, centroid.y
                geom_wkt = geom.wkt
            except:
                center_lon, center_lat = None, None
                geom_wkt = None
            
            # 插入数据
            try:
                cursor.execute('''
                    INSERT INTO china_administrative_divisions 
                    (adcode, name, level, parent_adcode, center_lon, center_lat, geometry)
                    VALUES (%s, %s, %s, %s, %s, %s, ST_GeomFromText(%s, 4326))
                    ON CONFLICT (adcode) DO UPDATE SET
                        name = EXCLUDED.name,
                        parent_adcode = EXCLUDED.parent_adcode,
                        center_lon = EXCLUDED.center_lon,
                        center_lat = EXCLUDED.center_lat,
                        geometry = EXCLUDED.geometry
                ''', (adcode, name, level, parent_adcode, center_lon, center_lat, geom_wkt))
                
                success_count += 1
                
                if success_count % 10 == 0:
                    print(f"  ✅ 已导入 {success_count}/{len(features)}...")
                    
            except Exception as e:
                print(f"  ❌ {name} ({adcode}) 失败: {e}")
                conn.rollback()
                continue
        
        conn.commit()
        cursor.close()
        
        print(f"✅ {level} 数据导入完成，成功 {success_count}/{len(features)}")
        return success_count
        
    except Exception as e:
        print(f"❌ {level} 数据导入失败: {e}")
        return 0


def create_indexes(conn):
    """创建索引"""
    print("\n📍 创建索引...")
    
    cursor = conn.cursor()
    
    try:
        # 空间索引
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_admin_geometry 
            ON china_administrative_divisions USING GIST(geometry)
        ''')
        
        # 普通索引
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_admin_adcode 
            ON china_administrative_divisions(adcode)
        ''')
        
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_admin_level 
            ON china_administrative_divisions(level)
        ''')
        
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_admin_parent 
            ON china_administrative_divisions(parent_adcode)
        ''')
        
        conn.commit()
        print("✅ 索引创建成功")
        
    except Exception as e:
        print(f"⚠️  索引创建失败: {e}")
        conn.rollback()
    
    cursor.close()


def show_statistics(conn):
    """显示统计"""
    print("\n" + "="*60)
    print("📊 导入统计")
    print("="*60)
    
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT level, COUNT(*) as count
        FROM china_administrative_divisions
        GROUP BY level
        ORDER BY 
            CASE level
                WHEN 'province' THEN 1
                WHEN 'city' THEN 2
                WHEN 'district' THEN 3
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
    print("="*60)
    
    cursor.close()


def main():
    """主函数"""
    print("\n" + "="*60)
    print("🚀 快速导入行政区数据（省市级）")
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
        province_count = fetch_and_import(conn, PROVINCE_URL, 'province')
        
        # 导入市级数据
        city_count = fetch_and_import(conn, CITY_URL, 'city')
        
        # 创建索引
        create_indexes(conn)
        
        # 显示统计
        show_statistics(conn)
        
        conn.close()
        
        print("\n🎉 导入完成！")
        print(f"   省级: {province_count} 个")
        print(f"   市级: {city_count} 个")
        print(f"   总计: {province_count + city_count} 个")
        print("\n💡 提示：如需导入区县级数据，请运行 import_admin_divisions.py")
        
    except Exception as e:
        print(f"\n❌ 导入失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
