-- GEE 自定义预存区域表
CREATE TABLE IF NOT EXISTS gee_custom_regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    geometry TEXT NOT NULL,
    buffer_km DECIMAL(10,2) DEFAULT 5.00,
    priority INT DEFAULT 0,
    description TEXT,
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_custom_regions_active ON gee_custom_regions(is_active);
CREATE INDEX IF NOT EXISTS idx_custom_regions_priority ON gee_custom_regions(priority DESC);

-- 添加注释
COMMENT ON TABLE gee_custom_regions IS 'GEE自定义预存区域表';
COMMENT ON COLUMN gee_custom_regions.region_id IS '区域ID';
COMMENT ON COLUMN gee_custom_regions.region_name IS '区域名称';
COMMENT ON COLUMN gee_custom_regions.geometry IS '几何信息(GeoJSON)';
COMMENT ON COLUMN gee_custom_regions.buffer_km IS '缓冲距离(公里)';
COMMENT ON COLUMN gee_custom_regions.priority IS '优先级(数字越大优先级越高)';
COMMENT ON COLUMN gee_custom_regions.description IS '描述';
COMMENT ON COLUMN gee_custom_regions.created_by IS '创建人';
COMMENT ON COLUMN gee_custom_regions.created_at IS '创建时间';
COMMENT ON COLUMN gee_custom_regions.updated_at IS '更新时间';
COMMENT ON COLUMN gee_custom_regions.is_active IS '是否启用';
