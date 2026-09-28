"""
数据迁移脚本: SQLite → PostgreSQL

将旧的SQLite瓦片数据迁移到PostgreSQL数据库
"""
import sqlite3
import psycopg2
from datetime import datetime
from app.config import settings

def migrate_tiles():
    """迁移瓦片数据"""
    
    sqlite_db = "storage/tiles.db"
    
    # 检查SQLite数据库是否存在
    import os
    if not os.path.exists(sqlite_db):
        print(f"❌ SQLite数据库不存在: {sqlite_db}")
        print("✅ 无需迁移,直接使用PostgreSQL")
        return
    
    print(f"开始迁移数据...")
    print(f"源: SQLite ({sqlite_db})")
    print(f"目标: PostgreSQL ({settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_DATABASE})")
    
    # 连接SQLite
    sqlite_conn = sqlite3.connect(sqlite_db)
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cursor = sqlite_conn.cursor()
    
    # 连接PostgreSQL
    pg_conn = psycopg2.connect(
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_DATABASE
    )
    pg_cursor = pg_conn.cursor()
    
    try:
        # 查询SQLite中的所有瓦片
        sqlite_cursor.execute("SELECT * FROM tiles WHERE status = 'active'")
        rows = sqlite_cursor.fetchall()
        
        print(f"\n找到 {len(rows)} 条活跃瓦片记录")
        
        if len(rows) == 0:
            print("✅ 无数据需要迁移")
            return
        
        # 迁移数据
        migrated = 0
        skipped = 0
        
        for row in rows:
            tile_data = dict(row)
            
            # 转换status: 'active' -> '0', 'deleted' -> '1'
            status = '0' if tile_data['status'] == 'active' else '1'
            
            try:
                # 插入到PostgreSQL
                pg_cursor.execute('''
                    INSERT INTO gee_tiles (
                        tile_id, tile_x, tile_y,
                        center_lon, center_lat,
                        min_lon, min_lat, max_lon, max_lat,
                        file_path, created_at, updated_at, expires_at,
                        date_acquired, cloud_cover, file_size, status,
                        access_count, last_access,
                        create_by, update_by
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (tile_id) DO NOTHING
                ''', (
                    tile_data['tile_id'],
                    tile_data['tile_x'],
                    tile_data['tile_y'],
                    tile_data['center_lon'],
                    tile_data['center_lat'],
                    tile_data['min_lon'],
                    tile_data['min_lat'],
                    tile_data['max_lon'],
                    tile_data['max_lat'],
                    tile_data['file_path'],
                    tile_data['created_at'],
                    tile_data['updated_at'],
                    tile_data['expires_at'],
                    tile_data['date_acquired'],
                    tile_data.get('cloud_cover', 0),
                    tile_data.get('file_size', 0),
                    status,
                    tile_data.get('access_count', 0),
                    tile_data.get('last_access'),
                    'migration',  # create_by
                    'migration'   # update_by
                ))
                
                if pg_cursor.rowcount > 0:
                    migrated += 1
                    print(f"✓ 迁移: {tile_data['tile_id']}")
                else:
                    skipped += 1
                    print(f"- 跳过(已存在): {tile_data['tile_id']}")
                    
            except Exception as e:
                print(f"✗ 失败: {tile_data['tile_id']} - {e}")
        
        # 提交事务
        pg_conn.commit()
        
        print(f"\n" + "="*60)
        print(f"迁移完成!")
        print(f"  成功迁移: {migrated}")
        print(f"  跳过重复: {skipped}")
        print(f"  总计: {len(rows)}")
        print("="*60)
        
        # 询问是否删除SQLite数据库
        print(f"\n是否删除SQLite数据库? ({sqlite_db})")
        print("建议: 先验证PostgreSQL数据正确后再删除")
        
    except Exception as e:
        print(f"\n❌ 迁移失败: {e}")
        pg_conn.rollback()
        raise
        
    finally:
        sqlite_cursor.close()
        sqlite_conn.close()
        pg_cursor.close()
        pg_conn.close()


if __name__ == "__main__":
    migrate_tiles()
