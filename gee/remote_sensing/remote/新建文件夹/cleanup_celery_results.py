"""清理Redis中的旧任务结果"""
import redis

# Redis配置
REDIS_HOST = '<REDACTED_REDIS_HOST>'
REDIS_PORT = 6379
REDIS_PASSWORD = '<REDACTED_REDIS_PASSWORD>'
REDIS_DB = 3

print("=" * 60)
print("清理Redis中的旧任务结果")
print("=" * 60)

# 连接Redis
r = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    password=REDIS_PASSWORD,
    db=REDIS_DB,
    decode_responses=True
)

print("\n✅ Redis连接成功\n")

# 清理所有Celery任务结果
print("1. 查找Celery任务结果...")
celery_keys = r.keys('celery-task-meta-*')
print(f"   找到 {len(celery_keys)} 个任务结果")

if celery_keys:
    print("\n2. 删除任务结果...")
    deleted = 0
    for key in celery_keys:
        r.delete(key)
        deleted += 1
        if deleted % 100 == 0:
            print(f"   已删除 {deleted} 个...")
    print(f"   ✅ 总计删除: {deleted} 个")
else:
    print("   没有找到任务结果")

# 重置信号量
print("\n3. 重置并发信号量...")
r.set('gee_concurrency_semaphore', 0)
r.set('gee:concurrent_semaphore', 0)
print("   ✅ 信号量已重置为0")

# 清理任务锁
print("\n4. 清理任务锁...")
task_locks = r.keys('gee:task_lock:*')
if task_locks:
    for key in task_locks:
        r.delete(key)
    print(f"   ✅ 删除了 {len(task_locks)} 个任务锁")
else:
    print("   没有找到任务锁")

print("\n" + "=" * 60)
print("清理完成！")
print("=" * 60)
print("\n验证结果:")
print(f"  celery-task-meta-* 数量: {len(r.keys('celery-task-meta-*'))}")
print(f"  gee:concurrent_semaphore: {r.get('gee:concurrent_semaphore')}")
print(f"  任务锁数量: {len(r.keys('gee:task_lock:*'))}")
print("\n✅ 现在可以重启Celery worker了\n")
