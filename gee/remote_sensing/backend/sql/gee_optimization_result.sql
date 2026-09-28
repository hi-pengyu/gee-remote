-- 优化结果表
CREATE TABLE IF NOT EXISTS gee_optimization_result (
    id BIGSERIAL PRIMARY KEY,
    calculation_date DATE NOT NULL,
    buffer_km DECIMAL(5,2) NOT NULL DEFAULT 5.0,
    include_custom_regions BOOLEAN DEFAULT TRUE,
    total_regions INTEGER DEFAULT 0,
    original_plot_count INTEGER DEFAULT 0,
    optimized_region_count INTEGER DEFAULT 0,
    custom_region_count INTEGER DEFAULT 0,
    optimization_rate DECIMAL(5,2) DEFAULT 0,
    regions_data JSONB,
    status VARCHAR(20) DEFAULT 'calculated',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(64),
    remark TEXT,
    CONSTRAINT uk_date_buffer UNIQUE (calculation_date, buffer_km)
);

-- 创建索引
CREATE INDEX idx_calculation_date ON gee_optimization_result(calculation_date DESC);
CREATE INDEX idx_status ON gee_optimization_result(status);
CREATE INDEX idx_created_at ON gee_optimization_result(created_at DESC);

-- 添加注释
COMMENT ON TABLE gee_optimization_result IS 'GEE优化结果历史记录表';
COMMENT ON COLUMN gee_optimization_result.id IS '主键ID';
COMMENT ON COLUMN gee_optimization_result.calculation_date IS '计算日期';
COMMENT ON COLUMN gee_optimization_result.buffer_km IS '缓冲区大小(km)';
COMMENT ON COLUMN gee_optimization_result.include_custom_regions IS '是否包含自定义区域';
COMMENT ON COLUMN gee_optimization_result.total_regions IS '总区域数';
COMMENT ON COLUMN gee_optimization_result.original_plot_count IS '原始地块数';
COMMENT ON COLUMN gee_optimization_result.optimized_region_count IS '优化后区域数';
COMMENT ON COLUMN gee_optimization_result.custom_region_count IS '自定义区域数';
COMMENT ON COLUMN gee_optimization_result.optimization_rate IS '优化率(%)';
COMMENT ON COLUMN gee_optimization_result.regions_data IS '区域详细数据(JSON格式)';
COMMENT ON COLUMN gee_optimization_result.status IS '状态: calculated-已计算, downloading-下载中, downloaded-已下载, failed-失败';
COMMENT ON COLUMN gee_optimization_result.created_at IS '创建时间';
COMMENT ON COLUMN gee_optimization_result.updated_at IS '更新时间';
COMMENT ON COLUMN gee_optimization_result.created_by IS '创建人';
COMMENT ON COLUMN gee_optimization_result.remark IS '备注';

-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_gee_optimization_result_updated_at
    BEFORE UPDATE ON gee_optimization_result
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
