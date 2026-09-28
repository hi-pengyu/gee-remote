-- 将 Drive Token 存入数据库
-- 注意：需要手动替换下面的 token JSON 内容

-- 1. 插入 Drive Token JSON
INSERT INTO gee_config (
    config_key, 
    config_value, 
    config_type, 
    config_group, 
    description, 
    updated_by
)
VALUES (
    'GEE_DRIVE_TOKEN_JSON',
    '{
        "type": "service_account",
        "project_id": "<REDACTED_GCP_PROJECT_ID>",
        "private_key_id": "YOUR_PRIVATE_KEY_ID",
        "private_key": "<REDACTED_PRIVATE_KEY>",
        "client_email": "<REDACTED_SA_NAME>@<REDACTED_GCP_PROJECT_ID>.iam.gserviceaccount.com",
        "client_id": "YOUR_CLIENT_ID",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/<REDACTED_SA_NAME>%40<REDACTED_GCP_PROJECT_ID>.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
    }',
    'json',
    'gee',
    'Google Drive 服务账号认证Token（JSON格式）',
    'system'
)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_type = EXCLUDED.config_type,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- 2. 插入文件夹ID配置
INSERT INTO gee_config (
    config_key, 
    config_value, 
    config_type, 
    config_group, 
    description, 
    updated_by
)
VALUES (
    'GEE_DRIVE_FOLDER_ID',
    '1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV',
    'string',
    'gee',
    'Google Drive 文件夹ID（优先使用ID而不是名称，避免同名文件夹问题）',
    'system'
)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- 3. 删除旧的 token 路径配置（如果存在）
DELETE FROM gee_config WHERE config_key = 'GEE_DRIVE_TOKEN_PATH';

-- 4. 查看配置
SELECT 
    config_key, 
    CASE 
        WHEN config_type = 'json' THEN 
            (config_value::json->>'project_id') || ' / ' || (config_value::json->>'client_email')
        ELSE config_value 
    END as config_value_display,
    config_type, 
    description, 
    updated_at 
FROM gee_config 
WHERE config_key IN ('GEE_DRIVE_FOLDER', 'GEE_DRIVE_FOLDER_ID', 'GEE_DRIVE_TOKEN_JSON')
ORDER BY config_key;

-- 说明：
-- 1. 使用 Python 脚本 import_drive_token.py 更方便，会自动读取 token/token.json
-- 2. 如果手动执行此SQL，需要替换上面的 token JSON 内容
-- 3. Token 以 JSON 格式存储，支持数据库的 JSON 查询功能
