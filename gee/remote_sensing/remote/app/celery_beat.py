"""Celery Beat 定时任务配置"""
from celery.schedules import crontab
from app.celery_app import celery_app

# 配置定时任务
celery_app.conf.beat_schedule = {
    # 每天凌晨2点更新过期瓦片(最多20个)
    'update-expired-tiles-daily': {
        'task': 'cache.update_expired',
        'schedule': crontab(hour=2, minute=0),
        'args': (20,),
        'options': {'queue': 'gee_queue'}
    },
    
    # 每周日凌晨3点清理旧瓦片(保留30天)
    'cleanup-old-tiles-weekly': {
        'task': 'cache.cleanup',
        'schedule': crontab(day_of_week=0, hour=3, minute=0),
        'args': (30,),
        'options': {'queue': 'gee_queue'}
    },
    
    # 每小时检查缓存大小
    'check-cache-size-hourly': {
        'task': 'cache.check_size',
        'schedule': crontab(minute=0),  # 每小时整点
        'options': {'queue': 'gee_queue'}
    },
    
    # 每天早上8点生成缓存报告
    'generate-cache-report-daily': {
        'task': 'cache.generate_report',
        'schedule': crontab(hour=8, minute=0),
        'options': {'queue': 'gee_queue'}
    },
    
    # 新增：每15分钟清理一次 Redis 锁
    'cleanup-redis-locks': {
        'task': 'maintenance.cleanup_redis_locks',
        'schedule': 900.0,  # 15分钟
        'options': {'queue': 'gee_queue'}
    },
    
    # 新增：每天凌晨4点清理僵尸任务
    'cleanup-zombie-tasks': {
        'task': 'maintenance.cleanup_zombie_tasks',
        'schedule': crontab(hour=4, minute=0),
        'args': (24,),  # 清理24小时前的任务
        'options': {'queue': 'gee_queue'}
    },
}

# Beat配置
celery_app.conf.timezone = 'Asia/Shanghai'
celery_app.conf.enable_utc = False

print("✅ Celery Beat 定时任务已配置")
print("   - 每天2点: 更新过期瓦片")
print("   - 每周日3点: 清理旧瓦片")
print("   - 每小时: 检查缓存大小")
print("   - 每天8点: 生成缓存报告")
