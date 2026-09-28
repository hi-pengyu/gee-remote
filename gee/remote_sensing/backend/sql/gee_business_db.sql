-- =============================================
-- GEE业务数据库 (PostgreSQL)
-- 数据库名: gee_db
-- 版本: 1.0.0
-- 日期: 2025-11-28
-- =============================================

-- 创建数据库 (需要超级用户权限)
-- CREATE DATABASE gee_db WITH ENCODING='UTF8' LC_COLLATE='zh_CN.UTF-8' LC_CTYPE='zh_CN.UTF-8' TEMPLATE=template0;

-- 切换到gee_db数据库
-- \c gee_db

-- ----------------------------
-- 1. GEE瓦片缓存表
-- ----------------------------
DROP TABLE IF EXISTS gee_tiles;
CREATE TABLE gee_tiles (
    tile_id VARCHAR(50) PRIMARY KEY,
    tile_x INTEGER NOT NULL,
    tile_y INTEGER NOT NULL,
    center_lon DECIMAL(10,6) NOT NULL,
    center_lat DECIMAL(10,6) NOT NULL,
    min_lon DECIMAL(10,6) NOT NULL,
    min_lat DECIMAL(10,6) NOT NULL,
    max_lon DECIMAL(10,6) NOT NULL,
    max_lat DECIMAL(10,6) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    date_acquired DATE NOT NULL,
    cloud_cover DECIMAL(5,2),
    file_size BIGINT,
    access_count INTEGER DEFAULT 0,
    last_access TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    status CHAR(1) DEFAULT '0',
    create_by VARCHAR(64) DEFAULT '',
    update_by VARCHAR(64) DEFAULT '',
    remark VARCHAR(500)
);

COMMENT ON TABLE gee_tiles IS 'GEE瓦片缓存表';
COMMENT ON COLUMN gee_tiles.tile_id IS '瓦片ID';
COMMENT ON COLUMN gee_tiles.tile_x IS '瓦片X坐标';
COMMENT ON COLUMN gee_tiles.tile_y IS '瓦片Y坐标';
COMMENT ON COLUMN gee_tiles.status IS '状态(0正常 1删除)';

-- 创建索引
CREATE INDEX idx_tiles_expires ON gee_tiles(expires_at);
CREATE INDEX idx_tiles_access ON gee_tiles(access_count DESC, last_access DESC);
CREATE INDEX idx_tiles_status ON gee_tiles(status);
CREATE INDEX idx_tiles_spatial ON gee_tiles(tile_x, tile_y);
CREATE INDEX idx_tiles_date ON gee_tiles(date_acquired);

-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_gee_tiles_updated_at BEFORE UPDATE ON gee_tiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------
-- 2. GEE缓存统计表 (可选,用于性能优化)
-- ----------------------------
DROP TABLE IF EXISTS gee_cache_stats;
CREATE TABLE gee_cache_stats (
    stat_id SERIAL PRIMARY KEY,
    stat_date DATE NOT NULL,
    total_tiles INTEGER DEFAULT 0,
    active_tiles INTEGER DEFAULT 0,
    expired_tiles INTEGER DEFAULT 0,
    total_size_bytes BIGINT DEFAULT 0,
    total_accesses INTEGER DEFAULT 0,
    cache_hit_count INTEGER DEFAULT 0,
    cache_miss_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stat_date)
);

COMMENT ON TABLE gee_cache_stats IS 'GEE缓存统计表';

-- ----------------------------
-- 3. GEE系统配置表
-- ----------------------------
DROP TABLE IF EXISTS gee_config;
CREATE TABLE gee_config (
    config_id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(50),
    config_desc VARCHAR(500),
    remark VARCHAR(500),
    create_by VARCHAR(64) DEFAULT '',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_by VARCHAR(64) DEFAULT '',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gee_config IS 'GEE系统配置表';

CREATE TRIGGER update_gee_config_updated_at BEFORE UPDATE ON gee_config
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 初始化配置数据
INSERT INTO gee_config (config_key, config_value, config_type, config_desc, create_by) VALUES 
('tile_size_km', '5.0', 'number', '瓦片大小(公里)', 'admin'),
('tile_cache_days', '14', 'number', '瓦片缓存有效期(天)', 'admin'),
('max_cache_size_gb', '50.0', 'number', '最大缓存大小(GB)', 'admin'),
('prefetch_adjacent', 'true', 'boolean', '是否自动预取相邻瓦片', 'admin'),
('gee_project_id', '<REDACTED_GCP_PROJECT_ID>', 'string', 'GEE项目ID', 'admin'),
('gee_scale', '10', 'number', 'Sentinel-2分辨率', 'admin');

-- ----------------------------
-- 4. 创建分区表 (可选,用于大数据量优化)
-- ----------------------------
-- 按月份分区存储瓦片数据
-- CREATE TABLE gee_tiles_2024_11 PARTITION OF gee_tiles
-- FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');

-- ----------------------------
-- 5. 创建视图
-- ----------------------------
-- 活跃瓦片视图
CREATE OR REPLACE VIEW v_active_tiles AS
SELECT * FROM gee_tiles 
WHERE status = '0' AND expires_at > CURRENT_TIMESTAMP;

-- 过期瓦片视图
CREATE OR REPLACE VIEW v_expired_tiles AS
SELECT * FROM gee_tiles 
WHERE status = '0' AND expires_at <= CURRENT_TIMESTAMP;

-- 热点瓦片视图
CREATE OR REPLACE VIEW v_hot_tiles AS
SELECT * FROM gee_tiles 
WHERE status = '0' 
ORDER BY access_count DESC, last_access DESC 
LIMIT 100;

-- ----------------------------
-- 6. 创建函数
-- ----------------------------
-- 获取缓存统计
CREATE OR REPLACE FUNCTION get_cache_statistics()
RETURNS TABLE (
    total_tiles BIGINT,
    active_tiles BIGINT,
    expired_tiles BIGINT,
    total_size_gb NUMERIC,
    avg_access_count NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT,
        COUNT(*) FILTER (WHERE status = '0' AND expires_at > CURRENT_TIMESTAMP)::BIGINT,
        COUNT(*) FILTER (WHERE status = '0' AND expires_at <= CURRENT_TIMESTAMP)::BIGINT,
        ROUND((SUM(file_size) / 1024.0 / 1024.0 / 1024.0)::NUMERIC, 2),
        ROUND(AVG(access_count)::NUMERIC, 2)
    FROM gee_tiles
    WHERE status = '0';
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 7. 权限设置
-- ----------------------------
-- 创建GEE专用用户 (可选)
-- CREATE USER gee_user WITH PASSWORD 'your_password';
-- GRANT CONNECT ON DATABASE gee_db TO gee_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gee_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO gee_user;
