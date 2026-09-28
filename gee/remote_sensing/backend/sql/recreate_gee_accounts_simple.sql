-- 简化 gee_accounts 表，只保留用户认证方式

DROP TABLE IF EXISTS gee_accounts CASCADE;

CREATE TABLE gee_accounts (
    account_id SERIAL PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL UNIQUE,
    project_id VARCHAR(100) NOT NULL,
    credentials_json TEXT NOT NULL,  -- Base64 编码的用户认证 credentials
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'system',
    updated_by VARCHAR(50) DEFAULT 'system'
);

COMMENT ON TABLE gee_accounts IS 'GEE 用户认证账号池';
COMMENT ON COLUMN gee_accounts.credentials_json IS '用户认证 credentials（Base64 编码）';

CREATE INDEX idx_gee_accounts_active ON gee_accounts(is_active);
CREATE INDEX idx_gee_accounts_priority ON gee_accounts(priority DESC);

SELECT 'gee_accounts 表已重建（仅用户认证）' AS status;
