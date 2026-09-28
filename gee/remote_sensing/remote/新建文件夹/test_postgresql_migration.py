"""测试PostgreSQL迁移 - 验证TileManager和数据库连接"""
import sys
from datetime import datetime

def test_database_connection():
    """测试数据库连接"""
    print("=" * 80)
    print("测试 1: PostgreSQL数据库连接")
    print("=" * 80)
    
    try:
        from app.config import settings
        import psycopg2
        
        print(f"数据库配置:")
        print(f"  主机: {settings.DB_HOST}")
        print(f"  端口: {settings.DB_PORT}")
        print(f"  数据库: {settings.DB_DATABASE}")
        print(f"  用户: {settings.DB_USER}")
        
        conn = psycopg2.connect(
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            database=settings.DB_DATABASE
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"\n✅ 数据库连接成功!")
        print(f"PostgreSQL版本: {version[:50]}...")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"\n❌ 数据库连接失败: {e}")
        return False


def test_tile_manager_init():
    """测试TileManager初始化"""
    print("\n" + "=" * 80)
    print("测试 2: TileManager初始化")
    print("=" * 80)
    
    try:
        from app.services.tile_manager import TileManager
        
        tile_manager = TileManager()
        print(f"✅ TileManager初始化成功!")
        print(f"  瓦片大小: {tile_manager.tile_size_km} km")
        print(f"  缓存天数: {tile_manager.cache_days} 天")
        
        return tile_manager
        
    except Exception as e:
        print(f"❌ TileManager初始化失败: {e}")
        import traceback
        traceback.print_exc()
        return None


def test_tile_operations(tile_manager):
    """测试瓦片操作"""
    print("\n" + "=" * 80)
    print("测试 3: 瓦片基本操作")
    print("=" * 80)
    
    try:
        # 测试瓦片ID计算
        lon, lat = 86.0388, 44.5524
        tile_id = tile_manager.get_tile_id(lon, lat)
        print(f"✅ 瓦片ID计算: ({lon}, {lat}) -> {tile_id}")
        
        # 测试瓦片边界
        bounds = tile_manager.get_tile_bounds(tile_id)
        print(f"✅ 瓦片边界: {bounds}")
        
        # 测试多边形覆盖
        coords = [
            [86.0388, 44.5524],
            [86.0405, 44.5488],
            [86.0417, 44.5491],
            [86.0388, 44.5524]
        ]
        tile_ids = tile_manager.get_tile_for_polygon(coords)
        print(f"✅ 多边形覆盖瓦片: {tile_ids}")
        
        # 测试相邻瓦片
        adjacent = tile_manager.get_adjacent_tiles(tile_id)
        print(f"✅ 相邻瓦片数量: {len(adjacent)}")
        
        return True
        
    except Exception as e:
        print(f"❌ 瓦片操作失败: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_database_operations(tile_manager):
    """测试数据库操作"""
    print("\n" + "=" * 80)
    print("测试 4: 数据库读写操作")
    print("=" * 80)
    
    try:
        # 测试注册瓦片
        test_tile_id = "tile_test_001"
        test_file_path = "storage/tiles/test/test_tile.tif"
        test_date = "2025-09-21"
        
        success = tile_manager.register_tile(
            tile_id=test_tile_id,
            file_path=test_file_path,
            date_acquired=test_date,
            cloud_cover=15.5,
            file_size=1024000
        )
        
        if success:
            print(f"✅ 瓦片注册成功: {test_tile_id}")
        else:
            print(f"❌ 瓦片注册失败")
            return False
        
        # 测试查询瓦片
        tile_info = tile_manager.check_tile_cache(test_tile_id, test_date)
        if tile_info:
            print(f"✅ 瓦片查询成功:")
            print(f"   文件路径: {tile_info['file_path']}")
            print(f"   日期: {tile_info['date_acquired']}")
            print(f"   云量: {tile_info['cloud_cover']}%")
            print(f"   访问次数: {tile_info['access_count']}")
        else:
            print(f"❌ 瓦片查询失败")
            return False
        
        # 测试标记访问
        tile_manager.mark_tile_accessed(test_tile_id, test_date)
        print(f"✅ 标记访问成功")
        
        # 测试缓存统计
        stats = tile_manager.get_cache_stats()
        print(f"✅ 缓存统计:")
        print(f"   总瓦片数: {stats['total_tiles']}")
        print(f"   活跃瓦片: {stats['active_tiles']}")
        print(f"   过期瓦片: {stats['expired_tiles']}")
        print(f"   总大小: {stats['total_size_mb']:.2f} MB")
        print(f"   总访问次数: {stats['total_accesses']}")
        
        return True
        
    except Exception as e:
        print(f"❌ 数据库操作失败: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_table_exists():
    """检查gee_tiles表是否存在"""
    print("\n" + "=" * 80)
    print("测试 5: 检查数据库表")
    print("=" * 80)
    
    try:
        from app.config import settings
        import psycopg2
        
        conn = psycopg2.connect(
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            database=settings.DB_DATABASE
        )
        
        cursor = conn.cursor()
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'gee_tiles'
        """)
        
        result = cursor.fetchone()
        if result:
            print(f"✅ 表 'gee_tiles' 存在")
            
            # 查询表结构
            cursor.execute("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'gee_tiles'
                ORDER BY ordinal_position
            """)
            
            columns = cursor.fetchall()
            print(f"\n表结构 ({len(columns)} 列):")
            for col_name, col_type in columns:
                print(f"  - {col_name}: {col_type}")
            
            # 查询记录数
            cursor.execute("SELECT COUNT(*) FROM gee_tiles")
            count = cursor.fetchone()[0]
            print(f"\n当前记录数: {count}")
            
        else:
            print(f"❌ 表 'gee_tiles' 不存在")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ 检查表失败: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """主测试函数"""
    print("\n" + "=" * 80)
    print("🚀 PostgreSQL迁移测试")
    print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    
    results = []
    
    # 测试1: 数据库连接
    results.append(("数据库连接", test_database_connection()))
    
    if not results[-1][1]:
        print("\n❌ 数据库连接失败,停止测试")
        return
    
    # 测试2: TileManager初始化
    tile_manager = test_tile_manager_init()
    results.append(("TileManager初始化", tile_manager is not None))
    
    if tile_manager is None:
        print("\n❌ TileManager初始化失败,停止测试")
        return
    
    # 测试3: 瓦片操作
    results.append(("瓦片基本操作", test_tile_operations(tile_manager)))
    
    # 测试4: 数据库操作
    results.append(("数据库读写操作", test_database_operations(tile_manager)))
    
    # 测试5: 表检查
    results.append(("数据库表检查", test_table_exists()))
    
    # 汇总结果
    print("\n" + "=" * 80)
    print("📊 测试结果汇总")
    print("=" * 80)
    
    for test_name, success in results:
        status = "✅ 通过" if success else "❌ 失败"
        print(f"{status} - {test_name}")
    
    total = len(results)
    passed = sum(1 for _, success in results if success)
    
    print(f"\n总计: {passed}/{total} 测试通过")
    
    if passed == total:
        print("\n🎉 所有测试通过! PostgreSQL迁移成功!")
        print("\n📝 下一步:")
        print("  1. 启动Celery Worker测试任务执行")
        print("  2. 运行业务API测试")
        print("  3. 检查RuoYi后台是否能看到数据")
    else:
        print(f"\n⚠️  {total - passed} 个测试失败,请检查错误信息")


if __name__ == "__main__":
    main()
