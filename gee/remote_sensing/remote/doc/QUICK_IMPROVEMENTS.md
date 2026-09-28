# GEE缓存系统 - 快速实施指南

## 🐛 Bug修复(已完成)

- ✅ 修复`cached_workflow.py`中tile_id字段不匹配
- ✅ 支持多瓦片场景
- ✅ 正确显示缓存命中率和混合来源

## 🚀 立即可实施的改进

### 1. 错误重试机制(15分钟)

**安装依赖**:
```bash
pip install tenacity
```

**修改`cache_service.py`**:
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=60),
    reraise=True
)
def _download_tile(self, tile_id, target_date, window_days):
    # 现有代码保持不变
    # 自动重试3次,每次等待时间指数增长
```

### 2. 定时任务(10分钟)

**创建`app/celery_beat.py`**:
```python
from celery.schedules import crontab
from app.celery_app import celery_app

celery_app.conf.beat_schedule = {
    # 每天凌晨2点更新过期瓦片
    'update-expired-tiles': {
        'task': 'cache.update_expired',
        'schedule': crontab(hour=2, minute=0),
        'args': (20,)
    },
    # 每周日凌晨3点清理旧瓦片
    'cleanup-old-tiles': {
        'task': 'cache.cleanup',
        'schedule': crontab(day_of_week=0, hour=3),
        'args': (30,)
    }
}
```

**启动Beat**:
```bash
celery -A app.celery_app beat --loglevel=info
```

### 3. 缓存命中率监控(20分钟)

**在`tile_manager.py`添加**:
```python
def record_cache_access(self, hit_type: str):
    """记录缓存访问"""
    conn = sqlite3.connect(self.db_path)
    cursor = conn.cursor()
    
    cursor.execute('''
        INSERT INTO cache_metrics (timestamp, hit_type)
        VALUES (?, ?)
    ''', (datetime.now(), hit_type))
    
    conn.commit()
    conn.close()

def get_cache_metrics(self, days=7):
    """获取缓存指标"""
    conn = sqlite3.connect(self.db_path)
    cursor = conn.cursor()
    
    cutoff = datetime.now() - timedelta(days=days)
    
    cursor.execute('''
        SELECT 
            hit_type,
            COUNT(*) as count
        FROM cache_metrics
        WHERE timestamp > ?
        GROUP BY hit_type
    ''', (cutoff,))
    
    results = dict(cursor.fetchall())
    conn.close()
    
    total = sum(results.values())
    return {
        'total_requests': total,
        'cache_hits': results.get('hit', 0),
        'partial_hits': results.get('partial', 0),
        'cache_misses': results.get('miss', 0),
        'hit_rate': results.get('hit', 0) / total if total > 0 else 0
    }
```

### 4. 数据完整性检查(15分钟)

**在`cache_service.py`添加**:
```python
def _verify_tile(self, tile_path: str) -> bool:
    """验证瓦片完整性"""
    try:
        with rasterio.open(tile_path) as src:
            # 检查波段数
            if src.count < 11:  # Sentinel-2至少11个波段
                return False
            
            # 读取第一个波段检查数据
            data = src.read(1)
            
            # 检查是否全是无效值
            if np.all(data == 0) or np.all(np.isnan(data)):
                return False
            
            return True
    except Exception as e:
        print(f"[CacheService] 验证失败: {e}")
        return False

# 在_download_tile最后添加验证
def _download_tile(self, ...):
    # ... 现有下载代码 ...
    
    # 验证下载的文件
    if not self._verify_tile(local_path):
        os.remove(local_path)  # 删除损坏文件
        raise Exception(f"下载的瓦片文件损坏: {tile_id}")
    
    # ... 注册到数据库 ...
```

### 5. 缓存大小限制(10分钟)

**在`config.py`添加**:
```python
CACHE_SIZE_CHECK_INTERVAL = 3600  # 每小时检查一次
```

**创建定时任务**:
```python
@celery_app.task(name='cache.check_size')
def check_cache_size_task():
    """检查并强制执行缓存大小限制"""
    from app.services.cache_service import CacheService
    
    cache_service = CacheService()
    stats = cache_service.get_cache_statistics()
    
    if stats['actual_size_gb'] > settings.MAX_CACHE_SIZE_GB:
        # 删除最少访问的瓦片直到低于80%限制
        target_size = settings.MAX_CACHE_SIZE_GB * 0.8
        
        from app.services.tile_manager import TileManager
        tile_manager = TileManager()
        
        # 获取最少访问的瓦片
        conn = sqlite3.connect(tile_manager.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT tile_id, file_path, file_size
            FROM tiles
            WHERE status = 'active'
            ORDER BY access_count ASC, last_access ASC
        ''')
        
        deleted_size = 0
        for tile_id, file_path, file_size in cursor.fetchall():
            if stats['actual_size_gb'] - deleted_size / (1024**3) <= target_size:
                break
            
            try:
                os.remove(file_path)
                cursor.execute('UPDATE tiles SET status = "deleted" WHERE tile_id = ?', (tile_id,))
                deleted_size += file_size
            except:
                pass
        
        conn.commit()
        conn.close()
        
        print(f"[Cache] 清理了 {deleted_size / (1024**3):.2f} GB")
```

## 📝 推荐的下一步

1. **添加单元测试** (1-2小时)
2. **编写API文档** (2-3小时)
3. **添加并行下载** (1小时)
4. **实现缓存预热** (2小时)
5. **添加API认证** (1小时)

## 🎯 优先级排序

**今天就做**:
- ✅ 错误重试
- ✅ 定时任务
- ✅ 数据验证

**本周完成**:
- 缓存监控
- 大小限制
- 单元测试

**本月完成**:
- API文档
- 并行下载
- 缓存预热

详细改进建议见: `PROJECT_IMPROVEMENTS.md`
