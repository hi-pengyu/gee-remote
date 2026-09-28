-- ============================================
-- GEE系统配置表 - 完整创建脚本
-- ============================================

-- 删除已存在的表（如果存在）
DROP TABLE IF EXISTS gee_config CASCADE;

-- 创建配置表
CREATE TABLE gee_config (
    config_id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'string',
    config_group VARCHAR(50) DEFAULT 'system',
    description VARCHAR(500),
    is_encrypted BOOLEAN DEFAULT FALSE,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(64),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    remark VARCHAR(500)
);

-- 添加表和列注释
COMMENT ON TABLE gee_config IS 'GEE系统配置表';
COMMENT ON COLUMN gee_config.config_id IS '配置ID';
COMMENT ON COLUMN gee_config.config_key IS '配置键（唯一）';
COMMENT ON COLUMN gee_config.config_value IS '配置值';
COMMENT ON COLUMN gee_config.config_type IS '配置类型: string/int/float/bool/json';
COMMENT ON COLUMN gee_config.config_group IS '配置分组: gee/storage/api/oss/redis/celery/tile';
COMMENT ON COLUMN gee_config.description IS '配置说明';
COMMENT ON COLUMN gee_config.is_encrypted IS '是否加密存储（敏感信息）';
COMMENT ON COLUMN gee_config.is_enabled IS '是否启用';
COMMENT ON COLUMN gee_config.created_at IS '创建时间';
COMMENT ON COLUMN gee_config.created_by IS '创建人';
COMMENT ON COLUMN gee_config.updated_at IS '更新时间';
COMMENT ON COLUMN gee_config.updated_by IS '更新人';
COMMENT ON COLUMN gee_config.remark IS '备注';

-- 创建索引
CREATE INDEX idx_gee_config_group ON gee_config(config_group);
CREATE INDEX idx_gee_config_enabled ON gee_config(is_enabled);

-- 插入默认配置数据
INSERT INTO gee_config (config_key, config_value, config_type, config_group, description, created_by) VALUES
-- GEE配置
('GEE_PROJECT_ID', '<REDACTED_GCP_PROJECT_ID>', 'string', 'gee', 'GEE项目ID', 'system'),
('GEE_SCALE', '10', 'int', 'gee', 'Sentinel-2的分辨率', 'system'),
('GEE_DRIVE_FOLDER', 'GEE_Exports', 'string', 'gee', 'Google Drive文件夹名称', 'system'),
('GEE_SEARCH_WINDOW_DAYS', '2', 'int', 'gee', '目标日期前后搜索天数', 'system'),
('DEFAULT_AOI_COORDS', '[[86.0388457571117, 44.552453045732314], [86.0405231637295, 44.5488551561015], [86.041776483188, 44.54909929116849], [86.04386811483757, 44.54461996826588], [86.04674205882675, 44.545110605417975], [86.04626800158945, 44.54640573178081], [86.04755328775938, 44.54663995980717], [86.04429809841783, 44.5536415794847], [86.0388457571117, 44.552453045732314]]', 'string', 'gee', '默认AOI坐标', 'system'),
('GOOGLE_CLIENT_SECRETS_PATH', 'client_secrets.json', 'string', 'gee', 'Google客户端密钥文件路径', 'system'),
('GOOGLE_CREDS_PATH', 'mycreds.txt', 'string', 'gee', 'Google凭证文件路径', 'system'),
('GEE_BANDS', '["B1", "B2", "B3", "B4", "B5", "B6", "B8", "B8A", "B9", "B11", "B12"]', 'json', 'gee', 'GEE波段配置', 'system'),
('API_BANDS', '["B01", "B02", "B03", "B04", "B05", "B06", "B08", "B8A", "B09", "B11", "B12"]', 'json', 'gee', 'API波段配置', 'system'),

-- 存储配置
('STORAGE_TIF_DIR', './storage/tif', 'string', 'storage', 'TIF文件存储目录', 'system'),
('STORAGE_CSV_DIR', './storage/csv', 'string', 'storage', 'CSV文件存储目录', 'system'),
('STORAGE_RESULTS_DIR', './storage/results', 'string', 'storage', '预测结果存储目录', 'system'),
('STORAGE_LOGS_DIR', './storage/logs', 'string', 'storage', '日志文件目录', 'system'),

-- 预测API配置
('PREDICTION_API_URL', 'http://<REDACTED_API_HOST>:32011/predict', 'string', 'api', '预测API地址', 'system'),
('PREDICTION_API_KEY', 'admin', 'string', 'api', '预测API密钥', 'system'),
('PREDICTION_API_TIMEOUT', '300', 'int', 'api', '预测API超时时间（秒）', 'system'),
('AVAILABLE_MODELS', '["zg", "agb", "hsl", "spad", "n", "p", "k"]', 'json', 'api', '可用模型列表', 'system'),

-- 阿里云OSS配置
('OSS_ACCESS_KEY_ID', '<REDACTED_OSS_ACCESS_KEY_ID>', 'string', 'oss', '阿里云AccessKey ID', 'system'),
('OSS_ACCESS_KEY_SECRET', '<REDACTED_OSS_ACCESS_KEY_SECRET>', 'string', 'oss', '阿里云AccessKey Secret', 'system'),
('OSS_ENDPOINT', 'oss-cn-beijing.aliyuncs.com', 'string', 'oss', 'OSS区域节点', 'system'),
('OSS_BUCKET_NAME', '<REDACTED_OSS_BUCKET>', 'string', 'oss', 'OSS Bucket名称', 'system'),
('OSS_ENABLE_UPLOAD', 'true', 'bool', 'oss', '是否启用OSS上传', 'system'),
('OSS_DELETE_LOCAL', 'true', 'bool', 'oss', 'OSS上传成功后是否删除本地文件', 'system'),

-- Redis配置
('REDIS_HOST', '<REDACTED_REDIS_HOST>', 'string', 'redis', 'Redis主机地址', 'system'),
('REDIS_PORT', '6379', 'int', 'redis', 'Redis端口', 'system'),
('REDIS_DB', '3', 'int', 'redis', 'Redis数据库编号', 'system'),
('REDIS_PASSWORD', '<REDACTED_REDIS_PASSWORD>', 'string', 'redis', 'Redis密码', 'system'),

-- 瓦片缓存配置
('TILE_SIZE_KM', '5.0', 'float', 'tile', '瓦片大小(公里)', 'system'),
('TILE_CACHE_DAYS', '14', 'int', 'tile', '瓦片缓存有效期(天)', 'system'),
('TILE_STORAGE_PATH', 'storage/tiles', 'string', 'tile', '瓦片存储路径', 'system'),
('PREFETCH_ADJACENT', 'true', 'bool', 'tile', '是否自动预取相邻瓦片', 'system'),
('MAX_CACHE_SIZE_GB', '50.0', 'float', 'tile', '最大缓存大小(GB)', 'system'),
('ENABLE_TILE_CACHE', 'true', 'bool', 'tile', '是否启用瓦片缓存', 'system'),

-- Celery配置
('CELERY_BROKER_URL', 'redis://:<REDACTED_REDIS_PASSWORD>@<REDACTED_REDIS_HOST>:6379/3', 'string', 'celery', 'Celery Broker URL', 'system'),
('CELERY_RESULT_BACKEND', 'redis://:<REDACTED_REDIS_PASSWORD>@<REDACTED_REDIS_HOST>:6379/3', 'string', 'celery', 'Celery Result Backend', 'system'),
('CELERY_TASK_TRACK_STARTED', 'true', 'bool', 'celery', '是否跟踪任务启动', 'system'),
('CELERY_TASK_TIME_LIMIT', '3600', 'int', 'celery', '任务最大执行时间（秒）', 'system');

-- 验证插入结果
SELECT COUNT(*) as total_configs FROM gee_config;
SELECT config_group, COUNT(*) as count FROM gee_config GROUP BY config_group ORDER BY config_group;
