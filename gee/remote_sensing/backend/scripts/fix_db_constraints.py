
import psycopg2
from config.env import DataBaseConfig

def fix_constraints():
    """修复数据库约束问题"""
    conn = psycopg2.connect(
        host=DataBaseConfig.db_host,
        port=DataBaseConfig.db_port,
        user=DataBaseConfig.db_username,
        password=DataBaseConfig.db_password,
        database=DataBaseConfig.db_database
    )
    
    try:
        cursor = conn.cursor()
        print("🔧 开始修复数据库约束...")
        
        # 1. 删除 gee_control_logs 表上的外键约束
        # 因为我们需要在日志表中记录已删除的策略ID，所以不能有外键约束
        try:
            print("正在移除 gee_control_logs 外键约束...")
            cursor.execute("ALTER TABLE gee_control_logs DROP CONSTRAINT IF EXISTS gee_control_logs_policy_id_fkey")
            conn.commit()
            print("✅ 外键约束已移除")
        except Exception as e:
            print(f"⚠️ 移除外键失败 (可能已移除): {e}")
            conn.rollback()
            
        print("\n🎉 修复完成！现在可以正常删除策略了。")
        
    except Exception as e:
        print(f"❌ 连接数据库失败: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    fix_constraints()
