# GEE账号管理 - Drive Token集成说明

## 概述

现在每个GEE账号可以独立配置自己的Google Drive认证和文件夹，实现：
- ✅ 一个GEE账号对应一个Drive Token
- ✅ 一个GEE账号对应一个Drive文件夹
- ✅ 支持多账号，每个账号使用不同的Drive配置
- ✅ Token以JSON格式存储在数据库中，无需文件

## 数据库迁移

### 执行迁移脚本

```bash
# 方法1: 使用psql命令行
psql -h <REDACTED_DB_HOST> -U postgres -d remote_sensing -f F:\gee\RuoYi-Vue3-FastAPI\ruoyi-fastapi-backend\module_gee\migrations\add_drive_fields_to_accounts.sql

# 方法2: 使用数据库管理工具（如DBeaver、pgAdmin）
# 直接打开并执行 add_drive_fields_to_accounts.sql
```

### 新增字段

| 字段名 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `drive_token_json` | JSONB | Google Drive 服务账号 Token（JSON格式） | NULL |
| `drive_folder_id` | VARCHAR(255) | Google Drive 文件夹 ID | NULL |

## 前端使用

### 添加/编辑GEE账号

访问：`系统管理` → `GEE账号池`

表单字段：
1. **账号名称**：自定义名称，例如"主账号"
2. **项目ID**：GEE项目ID，例如 `<REDACTED_GCP_PROJECT_ID>`
3. **GEE Credentials**：Base64编码的GEE认证信息
4. **Drive Token JSON**：完整的Drive服务账号JSON（新增）
5. **Drive 文件夹 ID**：Drive文件夹ID（新增）
6. **优先级**：0-100，数字越大优先级越高
7. **是否启用**：开关
8. **描述**：备注信息

### Drive Token JSON 格式

从 `token/token.json` 文件复制完整内容，格式如下：

```json
{
  "type": "service_account",
  "project_id": "<REDACTED_GCP_PROJECT_ID>",
  "private_key_id": "xxx",
  "private_key": "<REDACTED_PRIVATE_KEY>",
  "client_email": "<REDACTED_SA_NAME>@<REDACTED_GCP_PROJECT_ID>.iam.gserviceaccount.com",
  "client_id": "xxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/...",
  "universe_domain": "googleapis.com"
}
```

### 获取 Drive 文件夹 ID

**方法1：从Drive URL获取**
```
https://drive.google.com/drive/folders/1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV
                                          ↑
                                    这部分就是文件夹ID
```

**方法2：使用测试脚本**
```bash
cd f:\gee\remote
conda activate gee
python test_list_drive_files.py
```

## 后端API

### 创建账号

```http
POST /gee/accounts
Content-Type: application/json

{
  "account_name": "主账号",
  "project_id": "<REDACTED_GCP_PROJECT_ID>",
  "credentials_json": "base64_encoded_credentials",
  "drive_token_json": "{...}",  // JSON字符串
  "drive_folder_id": "1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV",
  "priority": 10,
  "description": "主要使用的GEE账号"
}
```

### 更新账号

```http
PUT /gee/accounts/{account_id}
Content-Type: application/json

{
  "account_name": "主账号",
  "project_id": "<REDACTED_GCP_PROJECT_ID>",
  "credentials_json": "base64_encoded_credentials",
  "drive_token_json": "{...}",
  "drive_folder_id": "1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV",
  "priority": 10,
  "is_active": true,
  "description": "更新后的描述"
}
```

## 代码集成

### 在GEE服务中使用

修改 `f:\gee\remote\app\services\gee_service_pool.py`，从账号配置读取Drive Token：

```python
def authenticate_gdrive(self, account_id: int) -> GoogleDrive:
    """Google Drive 认证（从账号配置读取）"""
    # 从数据库读取账号配置
    account = self.get_account_by_id(account_id)
    
    if not account or not account.get('drive_token_json'):
        raise Exception(f"账号 {account_id} 未配置 Drive Token")
    
    token_json = account['drive_token_json']
    
    # 创建临时文件
    import tempfile
    import json
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        temp_token_file = f.name
        json.dump(token_json, f)
    
    try:
        # 使用临时文件进行认证
        settings_dict = {
            "client_config_backend": "service",
            "service_config": {
                "client_json_file_path": temp_token_file,
            },
            "oauth_scope": ["https://www.googleapis.com/auth/drive"]
        }
        
        gauth = GoogleAuth(settings=settings_dict)
        gauth.ServiceAuth()
        
        return GoogleDrive(gauth)
    finally:
        # 清理临时文件
        if os.path.exists(temp_token_file):
            os.remove(temp_token_file)
```

### 获取文件夹ID

```python
def get_drive_folder_id(self, account_id: int) -> str:
    """获取账号的Drive文件夹ID"""
    account = self.get_account_by_id(account_id)
    
    if not account or not account.get('drive_folder_id'):
        raise Exception(f"账号 {account_id} 未配置 Drive 文件夹 ID")
    
    return account['drive_folder_id']
```

## 数据查询示例

### 查询账号的Drive配置

```sql
-- 查看所有账号的Drive配置
SELECT 
    account_id,
    account_name,
    project_id,
    drive_folder_id,
    drive_token_json->>'project_id' as drive_project_id,
    drive_token_json->>'client_email' as drive_email,
    is_active
FROM gee_accounts
ORDER BY priority DESC;

-- 查询特定账号的完整配置
SELECT 
    *,
    drive_token_json->>'client_email' as drive_service_account
FROM gee_accounts
WHERE account_id = 1;

-- 查询未配置Drive的账号
SELECT account_id, account_name
FROM gee_accounts
WHERE drive_token_json IS NULL OR drive_folder_id IS NULL;
```

## 安全建议

1. **Token安全**：
   - Drive Token包含私钥，存储在数据库中
   - 确保数据库访问权限严格控制
   - 定期轮换服务账号密钥

2. **权限管理**：
   - 每个Drive服务账号只授予必要的文件夹访问权限
   - 使用不同的服务账号隔离不同的GEE账号

3. **备份**：
   - 定期备份 `gee_accounts` 表
   - 保存原始token文件的安全副本

## 迁移现有配置

如果之前使用全局配置（`gee_config`表），现在需要迁移到账号级别：

```sql
-- 将全局Drive配置迁移到特定账号
UPDATE gee_accounts
SET 
    drive_token_json = (
        SELECT config_value::jsonb 
        FROM gee_config 
        WHERE config_key = 'GEE_DRIVE_TOKEN_JSON'
    ),
    drive_folder_id = (
        SELECT config_value 
        FROM gee_config 
        WHERE config_key = 'GEE_DRIVE_FOLDER_ID'
    )
WHERE account_id = 1;  -- 替换为你的账号ID

-- 验证迁移结果
SELECT 
    account_id,
    account_name,
    drive_folder_id,
    drive_token_json->>'client_email' as drive_email
FROM gee_accounts
WHERE account_id = 1;
```

## 故障排查

### 问题1：Drive认证失败

**检查**：
```sql
SELECT 
    account_id,
    account_name,
    drive_token_json IS NOT NULL as has_token,
    drive_folder_id IS NOT NULL as has_folder_id
FROM gee_accounts;
```

**解决**：
- 确保 `drive_token_json` 是有效的JSON
- 确保 `drive_folder_id` 不为空
- 检查服务账号是否有Drive访问权限

### 问题2：找不到文件

**检查文件夹ID**：
```bash
python test_list_drive_files.py
```

**验证配置**：
```sql
SELECT drive_folder_id FROM gee_accounts WHERE account_id = 1;
```

## 文件清单

### 修改的文件

1. **前端**：
   - `F:\gee\RuoYi-Vue3-FastAPI\ruoyi-fastapi-frontend\src\views\gee\accounts\index.vue`

2. **后端**：
   - `F:\gee\RuoYi-Vue3-FastAPI\ruoyi-fastapi-backend\module_gee\controller\accounts_controller.py`
   - `F:\gee\RuoYi-Vue3-FastAPI\ruoyi-fastapi-backend\module_gee\service\account_service.py`

3. **数据库**：
   - `F:\gee\RuoYi-Vue3-FastAPI\ruoyi-fastapi-backend\module_gee\migrations\add_drive_fields_to_accounts.sql`

### 新增的文档

- `F:\gee\RuoYi-Vue3-FastAPI\ruoyi-fastapi-backend\module_gee\migrations\GEE_ACCOUNTS_DRIVE_INTEGRATION.md`（本文档）

## 总结

通过这次修改，实现了：

✅ **账号级别的Drive配置**：每个GEE账号独立配置  
✅ **无文件依赖**：Token存储在数据库中  
✅ **灵活性**：支持多账号，每个账号使用不同的Drive  
✅ **安全性**：Token加密存储在数据库  
✅ **易用性**：前端界面直接配置，无需手动编辑文件  

现在可以在前端界面直接管理每个GEE账号的Drive配置了！
