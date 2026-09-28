-- 添加账号类型字段到 gee_accounts 表
ALTER TABLE gee_accounts ADD COLUMN IF NOT EXISTS account_type VARCHAR(20) DEFAULT 'service_account'
