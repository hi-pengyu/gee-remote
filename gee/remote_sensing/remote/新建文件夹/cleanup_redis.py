"""完整修复脚本 - 清理所有GEE相关的Redis key"""
import redis

# Redis配置
REDIS_HOST = '<REDACTED_REDIS_HOST>'
REDIS_PORT = 6379
REDIS_PASSWORD = '<REDACTED_REDIS_PASSWORD>'
REDIS_DB = 3

print("=" * 60)
print("GEE Redis 完整清理脚本")
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

# 要清理的key列表
keys_to_reset = [
    ('gee_concurrency_semaphore', '0'),
    ('gee:concurrent_semaphore', '0'),  # 这个才是实际在用的
]

keys_to_delete_patterns = [
    'gee:task_lock:*',  # 所有任务锁
]

print("1. 重置信号量:")
for key, value in keys_to_reset:
    old_value = r.get(key)
    r.set(key, value)
    print(f"   {key}: {old_value} → {value}")

print("\n2. 删除任务锁:")
total_deleted = 0
for pattern in keys_to_delete_patterns:
    keys = r.keys(pattern)
    if keys:
        print(f"   找到 {len(keys)} 个匹配 '{pattern}' 的key")
        for key in keys:
            r.delete(key)
            total_deleted += 1
            print(f"   - 已删除: {key}")
    else:
        print(f"   没有找到匹配 '{pattern}' 的key")

print(f"\n   总计删除: {total_deleted} 个key")

print("\n" + "=" * 60)
print("验证清理结果:")
print("=" * 60)
print(f"gee_concurrency_semaphore: {r.get('gee_concurrency_semaphore')}")
print(f"gee:concurrent_semaphore: {r.get('gee:concurrent_semaphore')}")
print(f"任务锁数量: {len(r.keys('gee:task_lock:*'))}")
print("=" * 60)

print("\n✅ 清理完成！现在可以重启Celery worker了。\n")
