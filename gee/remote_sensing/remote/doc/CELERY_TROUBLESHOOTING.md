# Celery Worker 启动和故障排查指南

## 问题: 任务未注册错误

### 错误信息
```
ERROR: Received unregistered task of type 'gee.cached_workflow'
```

### 原因
Celery Worker启动时没有导入任务模块,导致任务未注册。

### 解决方案

#### 方法1: 修改celery_app.py (已修复)

在`app/celery_app.py`末尾添加:
```python
# 导入所有任务模块
from app.tasks import workflow
from app.tasks import cached_workflow
from app.tasks import cache_tasks
```

#### 方法2: 重启Worker

```bash
# 停止当前Worker (Ctrl+C)
# 重新启动
celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
```

## 验证任务注册

### 查看已注册任务

```bash
celery -A app.celery_app inspect registered
```

应该看到:
```
gee.full_workflow
gee.cached_workflow
cache.prefetch_tiles
cache.update_expired
cache.cleanup
cache.check_size
cache.generate_report
```

### 测试任务

```python
from app.tasks.cached_workflow import cached_workflow_task

# 提交测试任务
task = cached_workflow_task.delay(
    aoi_coords=[[86.04, 44.55], ...],
    target_date="2024-06-15",
    model_type="zg"
)

print(f"Task ID: {task.id}")
```

## 常见问题

### 1. 任务未注册

**症状**: `KeyError: 'task_name'`

**解决**:
- 确保任务模块被导入
- 重启Worker
- 检查任务名称是否正确

### 2. 模块导入错误

**症状**: `ModuleNotFoundError`

**解决**:
- 检查文件路径
- 确保`__init__.py`存在
- 检查Python路径

### 3. Worker无法连接Redis

**症状**: `ConnectionError`

**解决**:
```bash
# 检查Redis是否运行
redis-cli ping
# 应该返回: PONG

# 如果没有运行,启动Redis
redis-server
```

## 完整启动流程

### 1. 启动Redis
```bash
redis-server
```

### 2. 启动Worker
```bash
celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
```

### 3. 启动Beat (可选)
```bash
celery -A app.celery_beat beat --loglevel=info
```

### 4. 启动FastAPI
```bash
python -m uvicorn app.main:app --reload
```

### 或使用启动脚本
```bash
.\start_all.bat
```

## 调试技巧

### 查看Worker状态
```bash
celery -A app.celery_app inspect active
celery -A app.celery_app inspect stats
```

### 查看任务队列
```bash
celery -A app.celery_app inspect active_queues
```

### 清空队列
```bash
celery -A app.celery_app purge
```

### 查看日志
```bash
# Worker日志
celery -A app.celery_app worker --loglevel=debug

# Beat日志
celery -A app.celery_beat beat --loglevel=debug
```

## 生产环境建议

### 使用Supervisor管理进程

```ini
[program:celery_worker]
command=celery -A app.celery_app worker -Q gee_queue --loglevel=info
directory=/path/to/gee
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/celery/worker.log

[program:celery_beat]
command=celery -A app.celery_beat beat --loglevel=info
directory=/path/to/gee
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/celery/beat.log
```

### 使用systemd

```ini
[Unit]
Description=Celery Worker
After=network.target

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=/path/to/gee
ExecStart=/usr/bin/celery -A app.celery_app worker -Q gee_queue --detach
Restart=always

[Install]
WantedBy=multi-user.target
```

## 总结

✅ **已修复**: celery_app.py已添加任务导入
✅ **下一步**: 重启Worker即可

重启Worker命令:
```bash
# 停止当前Worker (Ctrl+C)
# 重新启动
celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
```
