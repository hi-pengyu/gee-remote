-- 任务超时配置
INSERT INTO gee_config (config_key, config_value, config_type, config_group, description, updated_by)
VALUES 
('CELERY_TASK_TIME_LIMIT', '3600', 'int', 'celery', '任务硬超时时间(秒) - 1小时后强制终止', 'system'),
('CELERY_TASK_SOFT_TIME_LIMIT', '3000', 'int', 'celery', '任务软超时时间(秒) - 50分钟后抛出异常', 'system')
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;
