-- 为 gee_accounts 表添加 Drive Token 和 Folder ID 字段
-- 执行时间: 2025-11-30

-- 1. 添加 drive_token_json 字段（JSON类型）
ALTER TABLE gee_accounts 
ADD COLUMN IF NOT EXISTS drive_token_json JSONB DEFAULT NULL;

-- 2. 添加 drive_folder_id 字段（字符串类型）
ALTER TABLE gee_accounts 
ADD COLUMN IF NOT EXISTS drive_folder_id VARCHAR(255) DEFAULT NULL;

-- 3. 添加字段注释
COMMENT ON COLUMN gee_accounts.drive_token_json IS 'Google Drive 服务账号认证 Token（JSON格式）';
COMMENT ON COLUMN gee_accounts.drive_folder_id IS 'Google Drive 文件夹 ID';

-- 4. 创建索引（可选，如果需要按文件夹ID查询）
CREATE INDEX IF NOT EXISTS idx_gee_accounts_drive_folder_id 
ON gee_accounts(drive_folder_id);

-- 5. 查看表结构
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    column_default,
    is_nullable,
    col_description((table_schema||'.'||table_name)::regclass::oid, ordinal_position) as column_comment
FROM information_schema.columns
WHERE table_name = 'gee_accounts'
ORDER BY ordinal_position;

-- 说明:
-- 1. drive_token_json 使用 JSONB 类型，支持 JSON 查询和索引
-- 2. drive_folder_id 使用 VARCHAR(255)，存储 Drive 文件夹 ID
-- 3. 两个字段都允许 NULL，兼容旧数据
-- 4. 如果字段已存在，ALTER TABLE 会跳过（使用 IF NOT EXISTS）
