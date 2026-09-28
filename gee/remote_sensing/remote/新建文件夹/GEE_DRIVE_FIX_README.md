# GEE Drive 下载问题修复总结

## 问题分析

### 根本原因
1. **多个同名文件夹**：Google Drive中有10个同名的 `GEE_Exports` 文件夹
2. **服务账号视角不同**：服务账号看到的Drive空间与个人账号不同
3. **搜索逻辑错误**：
   - GEE导出任务将文件放到了最老的文件夹（2025-11-06创建，ID: `1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV`）
   - 下载代码只搜索第一个找到的文件夹（通常是最新的空文件夹）
   - 结果：文件存在但在错误的文件夹中搜索

### 发现的文件
在文件夹 `1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV` 中找到5个TIF文件：
- `workflow_2024-09-21_20251130_185623.tif` (0.02 MB)
- `workflow_2024-09-21_20251130_184731.tif` (0.02 MB)
- `workflow_2024-09-21_20251130_184322.tif` (0.02 MB)
- `workflow_2024-09-21_20251130_183830.tif` (0.02 MB)
- `tile_1910_989_20240921.tif` (8.05 MB)

## 解决方案

### 1. 修复GEE任务状态检查 ✅

**问题**：代码使用 `task.active()` 检查任务状态，但无法正确处理 `READY` 状态

**修复**：改为显式检查所有任务状态
```python
# GEE 任务状态: UNSUBMITTED -> READY -> RUNNING -> COMPLETED/FAILED/CANCELLED
while True:
    status = task.status()
    status_state = status['state']
    
    if status_state == 'COMPLETED':
        # 成功
    elif status_state in ['READY', 'RUNNING', 'UNSUBMITTED']:
        # 继续等待
    elif status_state in ['FAILED', 'CANCELLED']:
        # 失败
```

**文件**：`f:\gee\remote\app\services\gee_service_pool.py` (第133-165行)

### 2. 使用文件夹ID而非名称 ✅

**问题**：按名称搜索会找到多个同名文件夹，且无法确定使用哪一个

**修复**：优先使用文件夹ID直接访问
```python
# 优先使用文件夹ID
folder_id = getattr(settings, 'GEE_DRIVE_FOLDER_ID', None)

if folder_id:
    # 直接使用ID
    print(f"[Drive] 使用文件夹ID: {folder_id}")
else:
    # 降级到名称搜索，并使用最老的文件夹
    folder_list = drive.ListFile({...}).GetList()
    folder_list.sort(key=lambda x: x.get('createdDate', ''))
    folder_id = folder_list[0]['id']
```

**文件**：`f:\gee\remote\app\services\gee_service_pool.py` (第179-212行)

### 3. 从数据库读取Drive Token路径 ✅

**问题**：Token路径硬编码，无法支持多个GEE账户

**修复**：从数据库配置读取
```python
# 从配置读取token文件路径
token_path = getattr(settings, 'GEE_DRIVE_TOKEN_PATH', 'token/token.json')
print(f"[Drive] 使用认证文件: {token_path}")

# 检查文件是否存在
if not os.path.exists(token_path):
    raise Exception(f"Drive 认证文件不存在: {token_path}")
```

**文件**：`f:\gee\remote\app\services\gee_service_pool.py` (第35-41行)

## 数据库配置

已添加以下配置到 `gee_config` 表：

| 配置键 | 配置值 | 说明 |
|--------|--------|------|
| `GEE_DRIVE_FOLDER_ID` | `1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV` | Drive文件夹ID（避免同名问题） |
| `GEE_DRIVE_TOKEN_PATH` | `token/token.json` | Drive认证文件路径 |

### 添加配置的方法

**方法1：使用Python脚本**
```bash
conda activate gee
cd f:\gee\remote
python add_folder_id_config.py
```

**方法2：使用SQL脚本**
```bash
psql -h <REDACTED_DB_HOST> -U postgres -d remote_sensing -f add_folder_id_config.sql
```

## 工作流程

### 修复后的流程

1. **GEE导出**：
   ```
   GEE任务 → READY → RUNNING → COMPLETED
   文件导出到 Drive 文件夹 (ID: 1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV)
   ```

2. **Drive下载**：
   ```
   读取配置 GEE_DRIVE_FOLDER_ID
   → 直接使用文件夹ID搜索
   → 找到文件
   → 下载到本地
   ```

3. **配置热重载**：
   - 所有GEE服务实例通过Redis订阅配置更新
   - 配置修改后自动重载，无需重启服务

## 多账户支持

如果需要支持多个GEE账户，可以为每个账户配置：

```sql
-- 账户1
INSERT INTO gee_config (config_key, config_value, ...) 
VALUES ('GEE_DRIVE_FOLDER_ID', '文件夹ID1', ...);

INSERT INTO gee_config (config_key, config_value, ...) 
VALUES ('GEE_DRIVE_TOKEN_PATH', 'token/account1.json', ...);

-- 账户2
-- 需要扩展配置系统支持多账户前缀，例如：
-- ACCOUNT2_GEE_DRIVE_FOLDER_ID
-- ACCOUNT2_GEE_DRIVE_TOKEN_PATH
```

## 测试工具

### 列出Drive文件夹内容
```bash
conda activate gee
cd f:\gee\remote
python test_list_drive_files.py
```

功能：
- 列出所有Drive文件夹
- 显示所有同名 `GEE_Exports` 文件夹
- 列出每个文件夹中的文件
- 支持按关键词搜索文件

## 文件清单

### 修改的文件
- `f:\gee\remote\app\services\gee_service_pool.py` - 核心修复

### 新增的文件
- `f:\gee\remote\test_list_drive_files.py` - Drive文件列表测试工具
- `f:\gee\remote\add_folder_id_config.py` - 配置添加脚本（Python）
- `f:\gee\remote\add_folder_id_config.sql` - 配置添加脚本（SQL）

## 验证步骤

1. **确认配置已添加**：
   ```sql
   SELECT * FROM gee_config 
   WHERE config_key IN ('GEE_DRIVE_FOLDER_ID', 'GEE_DRIVE_TOKEN_PATH');
   ```

2. **重启GEE服务**（如果配置热重载未生效）

3. **运行一个测试任务**，观察日志：
   ```
   [Drive] 使用文件夹ID: 1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV
   [Drive] 使用认证文件: token/token.json
   [Drive] 正在搜索文件: xxx.tif
   [Drive] ✓ 找到文件: xxx.tif
   ```

## 建议

1. **清理重复文件夹**：
   - 删除那9个空的 `GEE_Exports` 文件夹
   - 或者在GEE导出时使用文件夹ID而不是名称

2. **监控文件夹**：
   - 定期检查是否有新的重复文件夹创建
   - 考虑添加告警机制

3. **备份认证文件**：
   - `token/token.json` 是关键文件
   - 建议备份并设置适当的文件权限

## 问题排查

如果下载仍然失败，检查：

1. **配置是否生效**：
   ```python
   from app.config import settings
   print(settings.GEE_DRIVE_FOLDER_ID)
   print(settings.GEE_DRIVE_TOKEN_PATH)
   ```

2. **文件夹ID是否正确**：
   ```bash
   python test_list_drive_files.py
   ```

3. **认证文件是否存在**：
   ```bash
   ls -l token/token.json
   ```

4. **查看详细日志**：
   - 日志会显示使用的文件夹ID
   - 日志会列出文件夹中的所有文件
