# 系统启动健康检查说明

## ✅ 功能概述

系统启动时自动检查 Redis、阿里云OSS、GEE 和存储目录的连接状态，并输出详细日志。

---

## 🚀 自动检查内容

### 1. **Redis 连接检查**
- 检查 Redis 服务器连接
- 验证认证（如果配置了密码）
- 显示连接信息

**成功输出示例：**
```
============================================================
✅ Redis 连接成功
   Host: <REDACTED_REDIS_HOST>:6379
   DB: 3
   认证: 已启用
============================================================
```

**失败输出示例：**
```
============================================================
❌ Redis 连接失败
   Host: <REDACTED_REDIS_HOST>:6379
   错误: Connection refused
   错误类型: ConnectionError
============================================================
```

---

### 2. **阿里云 OSS 连接检查**

#### 场景1: OSS 已启用且配置正确

**成功输出示例：**
```
============================================================
✅ OSS 连接成功
   Bucket: <REDACTED_OSS_BUCKET>
   Endpoint: oss-cn-beijing.aliyuncs.com
   区域: oss-cn-beijing
   创建时间: 2024-01-01 00:00:00
   存储类型: Standard
   上传后删除本地: 是
============================================================
```

#### 场景2: OSS 已启用但配置不完整

**警告输出示例：**
```
============================================================
⚠️  OSS 配置不完整
   缺少必要的配置项，请检查环境变量:
   - OSS_ACCESS_KEY_ID
   - OSS_BUCKET_NAME
============================================================
```

#### 场景3: OSS 未启用

**信息输出示例：**
```
============================================================
⚪ OSS 上传功能已禁用
   提示: 设置 OSS_ENABLE_UPLOAD=true 启用
============================================================
```

#### 场景4: OSS 配置错误

**失败输出示例：**
```
============================================================
❌ OSS Bucket 访问失败
   Bucket: <REDACTED_OSS_BUCKET>
   Endpoint: oss-cn-beijing.aliyuncs.com
   错误: The specified bucket does not exist
   错误类型: NoSuchBucket
============================================================
```

---

### 3. **GEE 认证检查**

**成功输出示例：**
```
============================================================
✅ GEE 认证成功
   项目ID: <REDACTED_GCP_PROJECT_ID>
============================================================
```

**警告输出示例：**
```
============================================================
⚠️  GEE 未认证或认证失败
   错误: Please authorize access to your Earth Engine account
   提示: 运行 earthengine authenticate 进行认证
============================================================
```

---

### 4. **存储目录检查**

**成功输出示例：**
```
============================================================
✅ 存储目录检查通过
   TIF: ./storage/tif
   CSV: ./storage/csv
   Results: ./storage/results
   Logs: ./storage/logs
============================================================
```

**警告输出示例：**
```
============================================================
⚠️  部分存储目录不存在
   缺失: TIF: ./storage/tif
   缺失: CSV: ./storage/csv
   提示: 运行应用时会自动创建
============================================================
```

---

### 5. **健康检查总结**

所有检查完成后，会显示总结：

**全部正常示例：**
```
============================================================
📊 健康检查总结
============================================================
   Redis:      ✅ 正常
   OSS:        ✅ 正常
   GEE:        ✅ 正常
   存储目录:   ✅ 正常
============================================================
✅ 所有关键服务正常，系统可以启动
============================================================
```

**部分异常示例：**
```
============================================================
📊 健康检查总结
============================================================
   Redis:      ✅ 正常
   OSS:        ❌ 异常
   GEE:        ⚠️  未认证
   存储目录:   ✅ 正常
============================================================
✅ 所有关键服务正常，系统可以启动
============================================================
```

**关键服务异常示例：**
```
============================================================
📊 健康检查总结
============================================================
   Redis:      ❌ 异常
   OSS:        ⚠️  未配置
   GEE:        ⚠️  未认证
   存储目录:   ✅ 正常
============================================================
❌ 关键服务异常，请检查配置后重新启动
============================================================
```

---

## 📝 使用方法

### 自动运行（推荐）

健康检查已集成到系统启动流程中，无需手动调用。

#### 启动 FastAPI
```bash
uvicorn app.main:app --reload
```

启动时会自动运行健康检查并输出日志。

#### 启动 Celery Worker
```bash
celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
```

Worker 启动完成后会自动运行健康检查。

---

### 手动运行

如果需要手动检查系统状态：

```python
from app.startup_check import run_startup_checks

# 运行所有检查
results = run_startup_checks()

# 查看结果
print(f"Redis: {results['redis']}")
print(f"OSS: {results['oss']}")
print(f"GEE: {results['gee']}")
print(f"Storage: {results['storage']}")
```

---

## 🔧 单独检查

你也可以单独运行某个检查：

### 检查 Redis
```python
from app.startup_check import check_redis_connection

if check_redis_connection():
    print("Redis 连接正常")
else:
    print("Redis 连接失败")
```

### 检查 OSS
```python
from app.startup_check import check_oss_connection

if check_oss_connection():
    print("OSS 连接正常")
else:
    print("OSS 连接失败")
```

### 检查 GEE
```python
from app.startup_check import check_gee_authentication

if check_gee_authentication():
    print("GEE 认证成功")
else:
    print("GEE 认证失败")
```

### 检查存储目录
```python
from app.startup_check import check_storage_directories

if check_storage_directories():
    print("存储目录正常")
else:
    print("部分目录缺失")
```

---

## ⚠️ 常见问题

### 问题1: Redis 连接失败

**错误**: `Connection refused` 或 `Authentication required`

**解决方法**:
1. 检查 Redis 服务是否运行
   ```bash
   redis-cli ping
   ```
2. 检查配置文件中的 Redis 连接信息
   ```bash
   REDIS_HOST=<REDACTED_REDIS_HOST>
   REDIS_PORT=6379
   REDIS_PASSWORD=123456
   REDIS_DB=3
   ```
3. 检查防火墙是否阻止连接

---

### 问题2: OSS 配置不完整

**错误**: `⚠️  OSS 配置不完整`

**解决方法**:
检查 `.env` 文件中的 OSS 配置：
```bash
OSS_ACCESS_KEY_ID=your-key-id
OSS_ACCESS_KEY_SECRET=your-key-secret
OSS_ENDPOINT=oss-cn-beijing.aliyuncs.com
OSS_BUCKET_NAME=your-bucket-name
OSS_ENABLE_UPLOAD=true
```

---

### 问题3: OSS Bucket 不存在

**错误**: `The specified bucket does not exist`

**解决方法**:
1. 检查 Bucket 名称是否正确
2. 检查 Endpoint 是否与 Bucket 所在区域匹配
3. 登录阿里云控制台确认 Bucket 是否存在

---

### 问题4: GEE 认证失败

**错误**: `Please authorize access to your Earth Engine account`

**解决方法**:
运行 GEE 认证命令：
```bash
earthengine authenticate
```

然后按照提示完成认证。

---

### 问题5: 存储目录不存在

**警告**: `⚠️  部分存储目录不存在`

**解决方法**:
这是正常情况，应用启动时会自动创建缺失的目录。如果需要手动创建：
```bash
mkdir -p storage/tif storage/csv storage/results storage/logs
```

---

## 📊 关键服务说明

### 什么是关键服务？

当前系统中，只有 **Redis** 被认为是关键服务。

- **Redis**: 必须正常，否则系统无法启动
  - Celery 任务队列依赖 Redis
  - GEE 并发控制依赖 Redis

### 非关键服务

以下服务检查失败不会阻止系统启动：

- **OSS**: 可选功能，失败时仍可使用本地存储
- **GEE**: 认证失败时仍可启动，但无法执行 GEE 任务
- **存储目录**: 启动时会自动创建

---

## 🛠️ 修改关键服务列表

如果你希望将 OSS 或 GEE 也设为关键服务，可以修改 `app/startup_check.py`：

```python
# 关键服务检查
critical_services = ['redis', 'oss', 'gee']  # 添加 oss 和 gee
critical_ok = all(results[service] for service in critical_services)
```

---

## 📚 相关文件

- **`app/startup_check.py`** - 健康检查核心逻辑
- **`app/celery_app.py`** - Celery Worker 启动检查集成
- **`app/main.py`** - FastAPI 启动检查集成
- **`app/concurrency_control.py`** - Redis 并发控制（已修复密码问题）

---

**实施日期**: 2025-11-11
**版本**: 2.8.0
**状态**: ✅ 已完成
