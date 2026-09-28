-- 添加 GEE Drive 相关配置
-- 1. 文件夹ID：避免同名文件夹问题
-- 2. Token路径：支持多个GEE账户使用不同的Drive认证

-- 插入文件夹ID配置
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
    '1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV',  -- 这是测试脚本找到的有文件的那个文件夹ID
    'string',
    'gee',
    'Google Drive 文件夹ID（优先使用ID而不是名称，避免同名文件夹问题）',
    'system'
)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- 插入Token路径配置
INSERT INTO gee_config (
    config_key, 
    config_value, 
    config_type, 
    config_group, 
    description, 
    updated_by
)
VALUES (
    'GEE_DRIVE_TOKEN_PATH',
    'token/token.json',  -- Drive 服务账号认证文件路径（相对于项目根目录）
    'string',
    'gee',
    'Google Drive 服务账号认证文件路径（相对于项目根目录）',
    'system'
)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- 查看配置
SELECT config_key, config_value, config_type, description, updated_at 
FROM gee_config 
WHERE config_key IN ('GEE_DRIVE_FOLDER', 'GEE_DRIVE_FOLDER_ID', 'GEE_DRIVE_TOKEN_PATH')
ORDER BY config_key;
