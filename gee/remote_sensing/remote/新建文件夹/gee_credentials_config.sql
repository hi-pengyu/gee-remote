-- GEE 用户凭证配置
-- 生成时间: 2025-11-30 14:10:43

INSERT INTO gee_config (config_key, config_value, config_type, config_group, description, is_enabled)
VALUES (
    'GEE_USER_CREDENTIALS',
    'eyJyZWRpcmVjdF91cmkiOiAiaHR0cDovL2xvY2FsaG9zdDo4MDg1IiwgInJlZnJlc2hfdG9rZW4iOiAiMS8vMGdYc1pHRkR5ZkFncENnWUlBUkFBR0JBU053Ri1MOUlyOThxOVhsU3VBTVVTTlh5anVTb1Myd3JjOWhWZ0UzTFpiNG9EVDlkTUNmak1zSmotd1VwcmVpWHk0bGdLM0Nwbk1OQSIsICJzY29wZXMiOiBbImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL2F1dGgvZWFydGhlbmdpbmUiLCAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vYXV0aC9jbG91ZC1wbGF0Zm9ybSIsICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9hdXRoL2RyaXZlIiwgImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL2F1dGgvZGV2c3RvcmFnZS5mdWxsX2NvbnRyb2wiXX0=',
    'string',
    'gee',
    'GEE 用户认证凭证（Base64 编码）',
    true
)
ON CONFLICT (config_key) DO UPDATE
SET config_value = EXCLUDED.config_value,
    updated_at = CURRENT_TIMESTAMP;
