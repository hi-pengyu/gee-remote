"""
测试行政区API接口

用于调试 list index out of range 错误
"""

import requests
import json

# API基础URL
BASE_URL = "http://localhost/dev-api"

def test_admin_regions_with_stats():
    """测试行政区列表（含统计）接口"""
    
    print("=" * 60)
    print("🧪 测试行政区API接口")
    print("=" * 60)
    
    # 测试不同级别
    levels = ['province', 'city', 'district', None]
    
    for level in levels:
        print(f"\n📍 测试级别: {level or '全部'}")
        print("-" * 60)
        
        url = f"{BASE_URL}/gee/admin-regions/list-with-stats"
        params = {}
        if level:
            params['level'] = level
        params['pageNum'] = 1
        params['pageSize'] = 10
        
        try:
            response = requests.get(url, params=params, timeout=10)
            print(f"状态码: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
                
                if data.get('success'):
                    result = data.get('result', {})
                    rows = result.get('rows', [])
                    total = result.get('total', 0)
                    print(f"✅ 成功 - 总数: {total}, 返回: {len(rows)} 条")
                    
                    # 显示前3条数据
                    for i, row in enumerate(rows[:3]):
                        print(f"\n  [{i+1}] {row.get('name')} ({row.get('adcode')})")
                        print(f"      级别: {row.get('level')}")
                        print(f"      地块: 总{row.get('totalPlots', 0)} / 活跃{row.get('activePlots', 0)} / 暂停{row.get('pausedPlots', 0)}")
                else:
                    print(f"❌ 失败: {data.get('msg')}")
            else:
                print(f"❌ HTTP错误: {response.status_code}")
                print(f"响应: {response.text}")
                
        except Exception as e:
            print(f"❌ 请求异常: {e}")
            import traceback
            traceback.print_exc()


def test_admin_regions_simple():
    """测试简单行政区列表接口"""
    
    print("\n" + "=" * 60)
    print("🧪 测试简单行政区列表接口")
    print("=" * 60)
    
    url = f"{BASE_URL}/gee/admin-regions/list"
    params = {
        'level': 'province',
        'pageNum': 1,
        'pageSize': 5
    }
    
    try:
        response = requests.get(url, params=params, timeout=10)
        print(f"状态码: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
        else:
            print(f"❌ HTTP错误: {response.status_code}")
            print(f"响应: {response.text}")
            
    except Exception as e:
        print(f"❌ 请求异常: {e}")


def test_database_direct():
    """直接测试数据库查询"""
    
    print("\n" + "=" * 60)
    print("🧪 直接测试数据库")
    print("=" * 60)
    
    try:
        import psycopg2
        
        conn = psycopg2.connect(
            host='<REDACTED_DB_HOST>',
            port=5433,
            user='postgres',
            password='<REDACTED_DB_PASSWORD>',
            database='gee_monitor'
        )
        
        cursor = conn.cursor()
        
        # 测试1: 检查表是否存在
        print("\n📊 检查表结构...")
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_name IN ('china_administrative_divisions', 'gee_plots')
        """)
        tables = cursor.fetchall()
        print(f"存在的表: {[t[0] for t in tables]}")
        
        # 测试2: 统计各级别数量
        print("\n📊 统计各级别行政区数量...")
        cursor.execute("""
            SELECT level, COUNT(*) as count
            FROM china_administrative_divisions
            GROUP BY level
            ORDER BY level
        """)
        for row in cursor.fetchall():
            print(f"  {row[0]}: {row[1]} 个")
        
        # 测试3: 测试问题SQL
        print("\n📊 测试带统计的查询...")
        cursor.execute("""
            SELECT 
                r.adcode,
                r.name,
                r.level,
                r.parent_adcode,
                r.center_lon,
                r.center_lat,
                ST_AsGeoJSON(r.geometry) as geometry,
                COUNT(DISTINCT p.plot_id) as total_plots,
                COUNT(DISTINCT CASE WHEN p.monitor_status = 1 THEN p.plot_id END) as active_plots,
                COUNT(DISTINCT CASE WHEN p.monitor_status = 0 THEN p.plot_id END) as paused_plots
            FROM china_administrative_divisions r
            LEFT JOIN gee_plots p ON p.adcode LIKE r.adcode || '%'
            WHERE level = 'city'
            GROUP BY r.adcode, r.name, r.level, r.parent_adcode, r.center_lon, r.center_lat, r.geometry
            ORDER BY r.adcode
            LIMIT 3
        """)
        
        rows = cursor.fetchall()
        print(f"查询返回 {len(rows)} 行")
        
        for i, row in enumerate(rows):
            print(f"\n  行 {i+1}:")
            print(f"    列数: {len(row)}")
            print(f"    adcode: {row[0]}")
            print(f"    name: {row[1]}")
            print(f"    level: {row[2]}")
            print(f"    total_plots: {row[7] if len(row) > 7 else 'N/A'}")
        
        cursor.close()
        conn.close()
        
        print("\n✅ 数据库测试完成")
        
    except Exception as e:
        print(f"❌ 数据库测试失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    # 先测试数据库
    test_database_direct()
    
    # 再测试API
    print("\n\n")
    test_admin_regions_simple()
    
    print("\n\n")
    test_admin_regions_with_stats()
