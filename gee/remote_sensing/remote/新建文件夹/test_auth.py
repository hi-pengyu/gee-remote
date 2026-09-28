"""测试API Key认证功能"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os

# 数据库配置
DB_CONFIG = {
    'host': os.getenv('DB_HOST', '<REDACTED_DB_HOST>'),
    'port': int(os.getenv('DB_PORT', 5433)),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', '<REDACTED_DB_PASSWORD>'),
    'database': os.getenv('DB_DATABASE', 'remote_sensing')
}

def test_db_connection():
    """测试数据库连接"""
    print("=" * 60)
    print("1. 测试数据库连接")
    print("=" * 60)
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ 数据库连接成功")
        conn.close()
        return True
    except Exception as e:
        print(f"❌ 数据库连接失败: {e}")
        return False

def check_gee_apps_table():
    """检查 gee_apps 表是否存在"""
    print("\n" + "=" * 60)
    print("2. 检查 gee_apps 表")
    print("=" * 60)
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # 检查表是否存在
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'gee_apps'
            );
        """)
        exists = cursor.fetchone()['exists']
        
        if not exists:
            print("❌ gee_apps 表不存在！")
            print("\n需要创建表，SQL如下：")
            print("""
CREATE TABLE gee_apps (
    app_id SERIAL PRIMARY KEY,
    app_name VARCHAR(100) NOT NULL,
    app_key VARCHAR(255) UNIQUE NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入测试数据
INSERT INTO gee_apps (app_name, app_key, is_enabled) 
VALUES ('测试应用', 'test-key-123', TRUE);
            """)
            cursor.close()
            conn.close()
            return False
        
        print("✅ gee_apps 表存在")
        
        # 查看表结构
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'gee_apps'
            ORDER BY ordinal_position;
        """)
        columns = cursor.fetchall()
        print("\n表结构:")
        for col in columns:
            print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")
        
        # 查看数据
        cursor.execute("SELECT COUNT(*) as count FROM gee_apps")
        count = cursor.fetchone()['count']
        print(f"\n数据行数: {count}")
        
        if count > 0:
            cursor.execute("SELECT * FROM gee_apps LIMIT 5")
            rows = cursor.fetchall()
            print("\n前5条数据:")
            for row in rows:
                print(f"  - ID: {row['app_id']}, Name: {row['app_name']}, Key: {row['app_key'][:20]}..., Enabled: {row['is_enabled']}")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ 检查失败: {e}")
        return False

def check_gee_plots_table():
    """检查 gee_plots 表是否存在"""
    print("\n" + "=" * 60)
    print("3. 检查 gee_plots 表")
    print("=" * 60)
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # 检查表是否存在
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'gee_plots'
            );
        """)
        exists = cursor.fetchone()['exists']
        
        if not exists:
            print("❌ gee_plots 表不存在！")
            print("\n需要创建表，SQL如下：")
            print("""
CREATE TABLE gee_plots (
    plot_id SERIAL PRIMARY KEY,
    app_id INTEGER REFERENCES gee_apps(app_id),
    plot_name VARCHAR(100),
    geometry TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入测试数据
INSERT INTO gee_plots (app_id, plot_name, geometry) 
VALUES (
    1, 
    '测试地块',
    '{"type":"Polygon","coordinates":[[[116.3,39.9],[116.4,39.9],[116.4,40.0],[116.3,40.0],[116.3,39.9]]]}'
);
            """)
            cursor.close()
            conn.close()
            return False
        
        print("✅ gee_plots 表存在")
        
        # 查看表结构
        cursor.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'gee_plots'
            ORDER BY ordinal_position;
        """)
        columns = cursor.fetchall()
        print("\n表结构:")
        for col in columns:
            print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")
        
        # 查看数据
        cursor.execute("SELECT COUNT(*) as count FROM gee_plots")
        count = cursor.fetchone()['count']
        print(f"\n数据行数: {count}")
        
        if count > 0:
            cursor.execute("SELECT plot_id, app_id, plot_name FROM gee_plots LIMIT 5")
            rows = cursor.fetchall()
            print("\n前5条数据:")
            for row in rows:
                print(f"  - Plot ID: {row['plot_id']}, App ID: {row['app_id']}, Name: {row['plot_name']}")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ 检查失败: {e}")
        return False

def test_auth_service():
    """测试 AuthService"""
    print("\n" + "=" * 60)
    print("4. 测试 AuthService")
    print("=" * 60)
    
    try:
        from app.services.auth_service import AuthService
        
        auth_service = AuthService()
        print("✅ AuthService 初始化成功")
        
        # 获取一个测试 key
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT app_key FROM gee_apps WHERE is_enabled = TRUE LIMIT 1")
        row = cursor.fetchone()
        
        if not row:
            print("❌ 没有可用的测试 API Key")
            cursor.close()
            conn.close()
            return False
        
        test_key = row['app_key']
        print(f"\n使用测试 Key: {test_key}")
        
        # 测试验证
        result = auth_service.validate_app_key(test_key)
        print(f"\n验证结果: {result}")
        
        if result and 'app_id' in result:
            print("✅ API Key 验证成功")
        else:
            print("❌ API Key 验证失败")
        
        # 测试无效 key
        result = auth_service.validate_app_key("invalid-key-xxx")
        print(f"\n无效 Key 验证结果: {result}")
        
        if result is None:
            print("✅ 无效 Key 正确返回 None")
        else:
            print("❌ 无效 Key 应该返回 None")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """主函数"""
    print("\n🔍 开始检查 API Key 认证功能\n")
    
    results = []
    
    # 1. 测试数据库连接
    results.append(("数据库连接", test_db_connection()))
    
    # 2. 检查 gee_apps 表
    results.append(("gee_apps 表", check_gee_apps_table()))
    
    # 3. 检查 gee_plots 表
    results.append(("gee_plots 表", check_gee_plots_table()))
    
    # 4. 测试 AuthService
    results.append(("AuthService", test_auth_service()))
    
    # 总结
    print("\n" + "=" * 60)
    print("📊 检查总结")
    print("=" * 60)
    for name, result in results:
        status = "✅ 通过" if result else "❌ 失败"
        print(f"{name}: {status}")
    
    all_passed = all(r[1] for r in results)
    if all_passed:
        print("\n🎉 所有检查通过！API Key 认证功能正常")
    else:
        print("\n⚠️  部分检查失败，请根据上述信息修复问题")

if __name__ == "__main__":
    main()
