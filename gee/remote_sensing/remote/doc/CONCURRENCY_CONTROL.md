# GEE并发控制系统说明

## 📋 概述

本系统使用**Redis信号量**实现GEE（Google Earth Engine）任务的并发控制，确保同时执行的GEE任务数不超过5个（GEE官方限制）。

## 🏗️ 架构设计

```
业务端（可同时发多个请求）
     ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
┌─────────────────────────┐
│   FastAPI (接收请求)     │ ← 立即返回task_id
│   立即返回，不阻塞       │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│   Celery任务队列         │
│   所有任务都进入队列     │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│  并发控制器 (Redis信号量) │
│  ┌───────────────────┐  │
│  │ 执行中: 任务1-5   │  │ ← 最多5个
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ 等待中: 任务6-10  │  │ ← 自动排队
│  └───────────────────┘  │
└─────────┬───────────────┘
          ↓
    GEE API (执行)
```

## 🔑 核心组件

### 1. 并发控制器 (`app/concurrency_control.py`)

```python
class GEEConcurrencyControl:
    def __init__(self, max_concurrent=5)
    def acquire(task_id, timeout=300)  # 获取执行权限
    def release(task_id)                # 释放执行权限
    def get_current_count()             # 当前并发数
    def get_available_slots()           # 可用槽位数
```

**工作原理**:
- 使用Redis的INCR/DECR原子操作实现分布式信号量
- 任务开始前调用`acquire()`，超过5个则等待
- 任务结束后调用`release()`，释放槽位
- 支持超时机制（默认5分钟）

### 2. Workflow任务 (`app/tasks/workflow.py`)

每个任务执行流程：
```python
@celery_app.task
def full_workflow_task(...):
    # 1. 获取执行权限
    concurrency_control.acquire(task_id)  # 等待直到有槽位

    try:
        # 2. 执行GEE任务
        download_image()
        process_data()
        predict()

    finally:
        # 3. 无论成功失败，都释放槽位
        concurrency_control.release(task_id)
```

### 3. 队列监控API (`/api/v1/queue/stats`)

查询当前系统状态：
```json
{
  "celery_queue": {
    "active_tasks": 8,      // Celery中执行的任务总数
    "waiting_tasks": 12     // 排队等待的任务数
  },
  "gee_concurrency": {
    "current_executing": 5, // 正在执行GEE操作的任务数
    "available_slots": 0,   // 可用的GEE槽位
    "max_concurrent": 5,    // 最大并发数
    "utilization": "100%"   // 使用率
  },
  "status": "busy",
  "message": "当前5个GEE任务执行中，12个任务等待"
}
```

## 🚀 使用示例

### 场景1：业务端发送10个请求

```python
import requests

# 业务端同时发送10个请求
task_ids = []
for i in range(10):
    response = requests.post("http://localhost:8000/api/v1/workflow/run", json={
        "aoi_coords": [[86.038, 44.552], ...],
        "target_date": "2025-09-21",
        "model_type": "agb"
    })
    task_ids.append(response.json()["task_id"])
    print(f"任务{i+1}已提交: {response.json()['task_id']}")

# 结果：
# - 前5个任务：立即获取执行权限，开始执行GEE操作
# - 后5个任务：在队列中等待，直到前面的任务完成
```

### 场景2：查询队列状态

```python
import requests

# 提交任务后查询队列状态
stats = requests.get("http://localhost:8000/api/v1/queue/stats").json()

print(f"GEE并发: {stats['gee_concurrency']['current_executing']}/5")
print(f"等待任务: {stats['celery_queue']['waiting_tasks']}")

# 如果等待任务过多，可以提示用户稍后再试
if stats['celery_queue']['waiting_tasks'] > 20:
    print("当前系统繁忙，请稍后提交")
```

## 📊 性能特点

### 优势
✅ **自动排队**: 业务端无需关心GEE限制，随时提交任务
✅ **公平调度**: 先提交的任务先执行（FIFO）
✅ **失败隔离**: 单个任务失败不影响其他任务
✅ **分布式支持**: 使用Redis，支持多Worker实例
✅ **实时监控**: 通过API随时查询队列状态

### 性能指标
- **并发限制**: 5个GEE任务（GEE官方限制）
- **排队超时**: 10分钟（可配置）
- **响应时间**: < 100ms（提交任务）
- **单任务时长**: 1-2分钟（取决于影像大小）

## 🔧 配置说明

### 修改最大并发数

如果未来GEE提高限制，修改 `app/concurrency_control.py`:

```python
class GEEConcurrencyControl:
    def __init__(self, max_concurrent=10):  # 改为10
        self.max_concurrent = max_concurrent
```

### 修改等待超时

修改 `app/tasks/workflow.py`:

```python
if not concurrency_control.acquire(self.request.id, timeout=1200):  # 改为20分钟
    ...
```

## 🐛 故障处理

### 问题1：信号量卡死（所有任务都在等待）

**原因**: Worker异常退出，未释放信号量

**解决**:
```python
import requests

# 调用重置API（需要添加管理员权限）
requests.post("http://localhost:8000/api/v1/admin/reset-semaphore")
```

或手动重置Redis：
```bash
redis-cli
> SET gee:concurrent_semaphore 0
> exit
```

### 问题2：等待时间过长

**检查**:
```python
stats = requests.get("http://localhost:8000/api/v1/queue/stats").json()
print(f"当前执行: {stats['gee_concurrency']['current_executing']}")
print(f"等待任务: {stats['celery_queue']['waiting_tasks']}")
```

**可能原因**:
- GEE响应慢（影像太大）
- 前面的任务失败但未释放信号量
- Worker数量不足

**解决**:
- 增加Worker实例数
- 检查失败任务日志
- 重置信号量

## 📝 日志示例

```
[并发控制] 尝试获取GEE执行权限...
[并发控制] ✓ 任务 abc12345... 获取执行权限 (当前: 3/5)

... (执行GEE任务) ...

[并发控制] ✓ 任务 abc12345... 释放执行权限 (当前: 2/5)
```

等待中的任务：
```
[并发控制] ⏳ 任务 def67890... 等待执行权限 (当前: 5/5)
... (等待5秒) ...
[并发控制] ✓ 任务 def67890... 获取执行权限 (当前: 5/5)
```

## 🔄 与业务端集成

### 推荐架构

```
业务端职责:
1. 控制请求频率（可选，推荐每批5个）
2. 监控队列状态（避免过度提交）
3. 处理结果回调
4. 存储数据库

GEE服务职责:
1. 接收请求并立即返回task_id
2. 自动排队和并发控制
3. 执行GEE任务
4. 回调通知业务端
```

### 集成示例

```javascript
// 业务端代码示例
async function submitGEETasks(coordinates) {
    // 1. 先查询队列状态
    const stats = await fetch('http://gee-service/api/v1/queue/stats').then(r => r.json());

    // 2. 如果等待任务太多，提示用户
    if (stats.celery_queue.waiting_tasks > 30) {
        return { error: '系统繁忙，请稍后再试' };
    }

    // 3. 分批提交（每批5个，避免一次提交太多）
    const batchSize = 5;
    const taskIds = [];

    for (let i = 0; i < coordinates.length; i += batchSize) {
        const batch = coordinates.slice(i, i + batchSize);

        // 并发提交5个请求
        const promises = batch.map(coord =>
            fetch('http://gee-service/api/v1/workflow/run', {
                method: 'POST',
                body: JSON.stringify({
                    aoi_coords: coord,
                    target_date: '2025-09-21',
                    model_type: 'agb'
                })
            }).then(r => r.json())
        );

        const results = await Promise.all(promises);
        taskIds.push(...results.map(r => r.task_id));

        // 等待一会儿再提交下一批（可选）
        if (i + batchSize < coordinates.length) {
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
    }

    return { task_ids: taskIds };
}
```

---

**版本**: 2.5.0
**更新日期**: 2025-11-11
