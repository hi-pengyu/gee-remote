# GEE Remote 服务紧急修复清单

## 🔴 紧急问题

### 问题1: Drive文件找不到
**原因**: Remote服务还在使用全局配置，没有从账号表读取Drive Token

**当前代码**:
```python
# f:\gee\remote\app\services\gee_service_pool.py
token_json = getattr(settings, 'GEE_DRIVE_TOKEN_JSON', None)
```

**需要改为**: 从账号表读取（但这需要账号ID）

**临时解决方案**: 
1. 先确保全局配置存在
2. 运行 `python import_drive_token.py` 导入token到数据库

### 问题2: 并发数累加不归零
**原因**: Redis信号量在服务重启后没有重置

**位置**: 并发控制逻辑

**解决方案**: 
1. 服务启动时重置信号量
2. 或者使用任务完成时的清理机制

### 问题3: GEE配置冗余
**原因**: 有多个地方配置GEE认证

**需要清理**: 
- 删除重复的配置代码
- 统一使用一个配置源

## ✅ 立即执行的修复

### 修复1: 导入Drive Token到数据库

```bash
cd f:\gee\remote
conda activate gee
python import_drive_token.py
```

**验证**:
```sql
SELECT config_key, config_type, 
       CASE WHEN config_type = 'json' THEN 
           (config_value::json->>'client_email')
       ELSE config_value END as value_preview
FROM gee_config 
WHERE config_key IN ('GEE_DRIVE_TOKEN_JSON', 'GEE_DRIVE_FOLDER_ID');
```

### 修复2: 重置Redis并发信号量

```bash
# 连接Redis
redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3

# 查看当前信号量
GET gee_concurrency_semaphore

# 重置为0
SET gee_concurrency_semaphore 0

# 或者删除
DEL gee_concurrency_semaphore

# 退出
exit
```

### 修复3: 清理zombie任务锁

```bash
# 在Redis中
redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3

# 查看所有GEE相关的key
KEYS gee:*

# 删除所有任务锁
KEYS gee:task:* | xargs redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3 DEL

# 或者手动删除特定的
DEL gee:task:72bfe078-c9ee-4836-afe4-31696b66b9b7
```

## 🔧 代码修复

### 修复并发控制累加问题

在 `f:\gee\remote\app\celery_app.py` 添加启动时重置：

```python
@app.on_after_configure.connect
def setup_startup_tasks(sender, **kwargs):
    """应用启动后的初始化任务"""
    # 重置并发信号量
    from app.utils.redis_pool import get_redis_client
    redis_client = get_redis_client()
    
    # 重置信号量为0
    redis_client.set('gee_concurrency_semaphore', 0)
    print("✅ 并发信号量已重置为0")
```

### 修复Drive Token读取

**选项A: 继续使用全局配置（临时方案）**
- 确保 `GEE_DRIVE_TOKEN_JSON` 和 `GEE_DRIVE_FOLDER_ID` 在数据库中
- 运行 `import_drive_token.py`

**选项B: 改为从账号表读取（长期方案）**
- 需要修改任务调用，传入account_id
- 从gee_accounts表读取对应账号的drive配置

## 📋 执行步骤

### 步骤1: 停止所有服务
```bash
# 停止Celery worker
Ctrl+C

# 停止FastAPI
Ctrl+C
```

### 步骤2: 清理Redis
```bash
redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3 <<EOF
SET gee_concurrency_semaphore 0
KEYS gee:task:* | xargs redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3 DEL
EOF
```

### 步骤3: 导入Drive Token
```bash
cd f:\gee\remote
conda activate gee
python import_drive_token.py
```

### 步骤4: 验证配置
```bash
python -c "from app.config import settings; print(f'Token: {bool(settings.GEE_DRIVE_TOKEN_JSON)}'); print(f'Folder: {settings.GEE_DRIVE_FOLDER_ID}')"
```

### 步骤5: 重启服务
```bash
# 启动Celery
celery -A app.celery_app worker --loglevel=info --pool=solo -Q gee_queue

# 启动FastAPI（另一个终端）
python server.py
```

## 🔍 验证

### 验证1: 检查配置
```python
from app.config import settings
print("GEE_DRIVE_TOKEN_JSON:", bool(settings.GEE_DRIVE_TOKEN_JSON))
print("GEE_DRIVE_FOLDER_ID:", settings.GEE_DRIVE_FOLDER_ID)
```

### 验证2: 检查并发数
```bash
redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3 GET gee_concurrency_semaphore
# 应该返回: "0"
```

### 验证3: 测试任务
提交一个测试任务，观察：
- [ ] 并发数从0开始
- [ ] Drive认证成功
- [ ] 文件下载成功
- [ ] 任务完成后并发数归零

## ⚠️ 注意事项

1. **不要同时运行多个worker**
   - 会导致并发控制失效
   
2. **确保Redis连接正常**
   - 检查Redis是否可访问
   - 检查密码是否正确

3. **Drive Token格式**
   - 必须是有效的JSON
   - 必须包含所有必需字段

4. **文件夹ID**
   - 使用测试脚本确认ID正确
   - `python test_list_drive_files.py`

## 🐛 如果问题仍然存在

### Debug Drive问题
```python
# 测试Drive认证
cd f:\gee\remote
python test_drive_auth.py
```

### Debug并发问题
```python
# 查看Redis中的所有GEE相关key
redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 -n 3 KEYS "gee*"
```

### Debug配置问题
```python
from app.config import config_manager
configs = config_manager.get_all()
for k, v in configs.items():
    if 'DRIVE' in k or 'GEE' in k:
        print(f"{k}: {type(v)} = {str(v)[:100]}")
```

## 📝 长期解决方案

1. **统一配置管理**
   - 所有配置从数据库读取
   - 删除硬编码的配置

2. **改进并发控制**
   - 使用Redis的原子操作
   - 添加自动清理机制
   - 服务启动时自动重置

3. **账号级别的Drive配置**
   - 修改任务接口，传入account_id
   - 从gee_accounts表读取配置
   - 支持多账号独立配置

---

**立即执行**: 步骤1-5
**预计时间**: 10分钟
**优先级**: 🔴 紧急
