# GEE缓存系统 - 启动Celery Beat

## 什么是Celery Beat?

Celery Beat是定时任务调度器,自动执行:
- 每天凌晨2点: 更新过期瓦片
- 每周日凌晨3点: 清理旧瓦片  
- 每小时: 检查缓存大小
- 每天早上8点: 生成缓存报告

## 启动方式

### Windows

```bash
# 方式1: 单独启动Beat
celery -A app.celery_beat beat --loglevel=info

# 方式2: 与Worker一起启动(推荐)
celery -A app.celery_app worker --beat --loglevel=info -Q gee_queue
```

### Linux/Mac

```bash
# 后台运行Beat
celery -A app.celery_beat beat --loglevel=info --detach --pidfile=beat.pid

# 后台运行Worker
celery -A app.celery_app worker --loglevel=info -Q gee_queue --detach --pidfile=worker.pid
```

## 查看定时任务

```python
from app.celery_beat import celery_app

# 查看所有定时任务
for name, task in celery_app.conf.beat_schedule.items():
    print(f"{name}: {task['schedule']}")
```

## 手动触发任务

```python
from app.tasks.cache_tasks import check_cache_size_task, generate_cache_report_task

# 手动检查缓存大小
check_cache_size_task.delay()

# 手动生成报告
generate_cache_report_task.delay()
```

## 修改定时任务

编辑 `app/celery_beat.py`:

```python
celery_app.conf.beat_schedule = {
    'update-expired-tiles-daily': {
        'task': 'cache.update_expired',
        'schedule': crontab(hour=2, minute=0),  # 修改时间
        'args': (20,)  # 修改参数
    }
}
```

## 注意事项

1. **只运行一个Beat实例** - 多个Beat会导致任务重复执行
2. **时区设置** - 已配置为Asia/Shanghai
3. **日志位置** - 查看Celery日志了解执行情况

## 停止Beat

```bash
# Windows: Ctrl+C

# Linux/Mac: 
pkill -F beat.pid
```
