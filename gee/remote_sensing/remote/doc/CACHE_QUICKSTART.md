# 区域网格缓存系统 - 快速开始

## 安装依赖

```bash
pip install shapely==2.0.2
```

## 启动服务

```bash
# 启动FastAPI服务
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 启动Celery Worker
celery -A app.celery_app worker --loglevel=info -Q gee_queue
```

## 使用示例

### 1. 带缓存的工作流 (推荐)

```python
import requests

# 提交任务
response = requests.post(
    "http://localhost:8000/api/v1/workflow/run-cached",
    json={
        "aoi_coords": [
            [86.038, 44.552],
            [86.040, 44.548],
            # ... 更多坐标
        ],
        "target_date": "2024-06-15",
        "model_type": "all",  # 或单个模型: zg, agb, hsl等
        "window_days": 7
    }
)

task_id = response.json()["task_id"]
print(f"Task ID: {task_id}")

# 查询任务状态
import time
while True:
    status = requests.get(f"http://localhost:8000/api/v1/tasks/{task_id}")
    data = status.json()
    
    print(f"进度: {data['progress']}% - {data['current_step']}")
    
    if data['status'] == 'success':
        result = data['result']
        print(f"✅ 完成! 数据来源: {result['cache_info']['source']}")
        print(f"处理时间: {result['metadata']['processing_time_seconds']}秒")
        break
    
    time.sleep(2)
```

### 2. 查看缓存统计

```python
stats = requests.get("http://localhost:8000/api/v1/cache/stats")
print(stats.json())
```

### 3. 列出缓存瓦片

```python
tiles = requests.get("http://localhost:8000/api/v1/cache/tiles?limit=20")
print(tiles.json())
```

### 4. 手动预取瓦片

```python
response = requests.post(
    "http://localhost:8000/api/v1/cache/prefetch",
    params={
        "tile_id": "tile_1912_990",
        "target_date": "2024-06-15",
        "window_days": 7
    }
)
print(response.json())
```

## 运行测试

```bash
python test_cache.py
```

## 配置说明

在 `.env` 文件中配置:

```env
# 瓦片缓存配置
TILE_SIZE_KM=5.0
TILE_CACHE_DAYS=14
PREFETCH_ADJACENT=true
ENABLE_TILE_CACHE=true
MAX_CACHE_SIZE_GB=50.0
```

## 性能对比

- **首次请求**: 30-60秒 (从GEE下载)
- **缓存命中**: 1-3秒 (从本地读取)
- **速度提升**: 10-20倍

## 维护命令

```bash
# 更新过期瓦片
curl -X POST http://localhost:8000/api/v1/cache/update-expired?limit=10

# 清理旧瓦片
curl -X DELETE http://localhost:8000/api/v1/cache/cleanup?keep_days=30

# 查看缓存统计
curl http://localhost:8000/api/v1/cache/stats
```

## 注意事项

1. **首次使用**: 首次访问某个区域时需要从GEE下载,耗时较长
2. **缓存预热**: 可以手动预取常用区域的瓦片
3. **存储空间**: 定期清理旧瓦片,避免占用过多空间
4. **并发控制**: 系统会自动限制GEE并发请求数

## 更多信息

查看完整文档: `walkthrough.md`
