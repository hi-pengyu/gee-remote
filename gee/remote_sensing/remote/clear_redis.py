"""
清理 Redis 中的残留 Celery 数据
"""
import redis
from app.config import settings

print("🧹 清理 Redis 中的 Celery 数据...")

try:
    r = redis.Redis(
        host=settings.REDIS_HOST,
        port=settings.REDIS_PORT,
        db=settings.REDIS_DB,
        password=settings.REDIS_PASSWORD
    )
    
    # 测试连接
    r.ping()
    print("✅ Redis 连接成功")
    
    # 清理 celery 相关的 key
    patterns = [
        'celery-task-meta-*',
        '_kombu.*',
        'unacked*',
        'gee_queue'
    ]
    
    deleted_count = 0
    for pattern in patterns:
        keys = r.keys(pattern)
        if keys:
            deleted = r.delete(*keys)
            deleted_count += deleted
            print(f"  删除 {deleted} 个 key (pattern: {pattern})")
    
    print(f"\n✅ 总共删除 {deleted_count} 个 key")
    print("✅ 清理完成！")
    
except Exception as e:
    print(f"❌ 错误: {e}")

