-- 删除并重建 gee_accounts 表，添加 account_type 字段

-- 1. 删除旧表
DROP TABLE IF EXISTS gee_accounts CASCADE;

-- 2. 重新创建表
CREATE TABLE gee_accounts (
    account_id SERIAL PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL UNIQUE,
    account_type VARCHAR(20) DEFAULT 'service_account' NOT NULL,  -- 新增：账号类型
    project_id VARCHAR(100) NOT NULL,
    service_account_email VARCHAR(255),
    credentials_path VARCHAR(500),
    credentials_json TEXT,
    max_concurrent_tasks INTEGER DEFAULT 3000,
    max_requests_per_second INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    is_healthy BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    total_tasks_executed INTEGER DEFAULT 0,
    current_tasks_running INTEGER DEFAULT 0,
    last_used_at TIMESTAMP,
    last_error_at TIMESTAMP,
    last_error_message TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'system',
    updated_by VARCHAR(50) DEFAULT 'system'
);

-- 3. 添加注释
COMMENT ON TABLE gee_accounts IS 'GEE 账号池';
COMMENT ON COLUMN gee_accounts.account_type IS '账号类型: service_account(服务账号) 或 user_auth(用户认证)';
COMMENT ON COLUMN gee_accounts.credentials_json IS '服务账号JSON密钥 或 用户认证credentials(Base64编码)';

-- 4. 创建索引
CREATE INDEX idx_gee_accounts_active ON gee_accounts(is_active);
CREATE INDEX idx_gee_accounts_healthy ON gee_accounts(is_healthy);
CREATE INDEX idx_gee_accounts_priority ON gee_accounts(priority DESC);
CREATE INDEX idx_gee_accounts_type ON gee_accounts(account_type);

-- 5. 插入示例数据（可选）
INSERT INTO gee_accounts (
    account_name, 
    account_type,
    project_id, 
    service_account_email, 
    credentials_path,
    is_active, 
    is_healthy, 
    priority, 
    description
) VALUES 
(
    'account-1',
    'service_account',
    'ee-project-1',
    'sa-1@ee-project-1.iam.gserviceaccount.com',
    '/credentials/account-1.json',
    true,
    false,
    10,
    '主账号'
),
(
    'account-2',
    'service_account',
    'ee-project-2',
    'sa-2@ee-project-2.iam.gserviceaccount.com',
    '/credentials/account-2.json',
    true,
    true,
    5,
    '备用账号1'
),
(
    'account-3',
    'service_account',
    'ee-project-3',
    'sa-3@ee-project-3.iam.gserviceaccount.com',
    '/credentials/account-3.json',
    true,
    true,
    5,
    '备用账号2'
);

-- 6. 打印完成信息
SELECT 'gee_accounts 表已重建，包含 account_type 字段' AS status;
