"""插入测试数据到gee_tasks表"""
import psycopg2
from datetime import datetime

# 连接数据库
conn = psycopg2.connect(
    host='<REDACTED_DB_HOST>',
    port=5433,
    user='postgres',
    password='<REDACTED_DB_PASSWORD>',
    database='remote_sensing'
)

cursor = conn.cursor()

# 插入测试数据（根据实际表结构）
test_data = [
    ('test-001', 'cached_workflow', '缓存工作流测试1', '2025-09-21', 'all', '[[86.04, 44.55], [86.05, 44.54]]', '2', 100, 95.5, 'cache', '["tile_1910_988"]', '/path/to/result1.tif'),
    ('test-002', 'workflow', '普通工作流测试', '2025-09-20', 'ndvi', '[[86.04, 44.55]]', '1', 50, None, 'gee', None, None),
    ('test-003', 'cached_workflow', '失败任务测试', '2025-09-19', 'all', '[[86.04, 44.55]]', '3', 0, None, None, None, None),
]

for data in test_data:
    cursor.execute("""
        INSERT INTO gee_tasks (
            task_id, task_type, task_name, target_date, 
            model_type, aoi_coords, status, progress,
            cache_hit_rate, cache_source, tile_ids, result_path,
            created_at, create_by
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), 'system')
        ON CONFLICT (task_id) DO NOTHING
    """, data)

conn.commit()

# 查询验证
cursor.execute('SELECT COUNT(*) FROM gee_tasks')
count = cursor.fetchone()[0]
print(f'✅ 插入测试数据成功！')
print(f'总记录数: {count}')

# 查询最新3条
cursor.execute('SELECT task_id, task_name, status, progress FROM gee_tasks ORDER BY created_at DESC LIMIT 3')
rows = cursor.fetchall()
print('\n最新3条记录:')
for row in rows:
    status_map = {'0': '待处理', '1': '处理中', '2': '成功', '3': '失败', '4': '已取消'}
    print(f'  - {row[0]}: {row[1]} | {status_map.get(row[2], row[2])} ({row[3]}%)')

cursor.close()
conn.close()

