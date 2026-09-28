-- ============================================
-- GEE 地块行政区管控功能升级
-- 版本: 2.0.0
-- 日期: 2026-01-26
-- 功能: 支持按行政区和生育期自动控制地块监测
-- ============================================

-- 1. 扩展地块表 (gee_plots) - 添加行政区和监测控制字段
-- ============================================
ALTER TABLE gee_plots 
ADD COLUMN IF NOT EXISTS adcode VARCHAR(20),                    -- 行政区划代码
ADD COLUMN IF NOT EXISTS province VARCHAR(50),                  -- 省份名称
ADD COLUMN IF NOT EXISTS city VARCHAR(50),                      -- 城市名称
ADD COLUMN IF NOT EXISTS district VARCHAR(50),                  -- 区县名称
ADD COLUMN IF NOT EXISTS crop_type VARCHAR(50),                 -- 作物类型
ADD COLUMN IF NOT EXISTS monitor_status SMALLINT DEFAULT 1,     -- 监测状态：1=开启，0=关闭
ADD COLUMN IF NOT EXISTS monitor_start_date VARCHAR(10),        -- 监测开始日期 MM-DD
ADD COLUMN IF NOT EXISTS monitor_end_date VARCHAR(10),          -- 监测结束日期 MM-DD
ADD COLUMN IF NOT EXISTS auto_update BOOLEAN DEFAULT TRUE,      -- 是否自动更新
ADD COLUMN IF NOT EXISTS update_frequency VARCHAR(20) DEFAULT 'daily'; -- 更新频率

-- 添加注释
COMMENT ON COLUMN gee_plots.adcode IS '行政区划代码（如：410100）';
COMMENT ON COLUMN gee_plots.province IS '省份名称';
COMMENT ON COLUMN gee_plots.city IS '城市名称';
COMMENT ON COLUMN gee_plots.district IS '区县名称';
COMMENT ON COLUMN gee_plots.crop_type IS '作物类型（如：corn, rice, wheat）';
COMMENT ON COLUMN gee_plots.monitor_status IS '监测状态：1=开启，0=关闭';
COMMENT ON COLUMN gee_plots.monitor_start_date IS '监测开始日期（格式：MM-DD，如：04-01）';
COMMENT ON COLUMN gee_plots.monitor_end_date IS '监测结束日期（格式：MM-DD，如：10-31）';
COMMENT ON COLUMN gee_plots.auto_update IS '是否启用自动更新';
COMMENT ON COLUMN gee_plots.update_frequency IS '更新频率（daily/weekly/monthly）';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_gee_plots_adcode ON gee_plots(adcode);
CREATE INDEX IF NOT EXISTS idx_gee_plots_monitor_status ON gee_plots(monitor_status);
CREATE INDEX IF NOT EXISTS idx_gee_plots_auto_update ON gee_plots(auto_update);
CREATE INDEX IF NOT EXISTS idx_gee_plots_crop_type ON gee_plots(crop_type);


-- 2. 创建行政区管控策略表 (gee_region_policies)
-- ============================================
CREATE TABLE IF NOT EXISTS gee_region_policies (
    policy_id SERIAL PRIMARY KEY,
    adcode VARCHAR(20) NOT NULL,                    -- 行政区代码（支持前缀匹配）
    policy_type VARCHAR(20) NOT NULL DEFAULT 'pause', -- 策略类型：pause=暂停监测
    reason VARCHAR(500),                            -- 暂停原因
    start_time TIMESTAMP,                           -- 策略生效开始时间
    end_time TIMESTAMP,                             -- 策略生效结束时间
    is_active BOOLEAN DEFAULT TRUE,                 -- 是否激活
    created_by VARCHAR(64),                         -- 创建人
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gee_region_policies IS '行政区域监测管控策略表';
COMMENT ON COLUMN gee_region_policies.adcode IS '行政区代码（如：410000代表河南省，支持前缀匹配）';
COMMENT ON COLUMN gee_region_policies.policy_type IS '策略类型：pause=暂停监测';
COMMENT ON COLUMN gee_region_policies.reason IS '管控原因说明';
COMMENT ON COLUMN gee_region_policies.is_active IS '策略是否激活';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_region_policies_adcode ON gee_region_policies(adcode);
CREATE INDEX IF NOT EXISTS idx_region_policies_active ON gee_region_policies(is_active);
CREATE INDEX IF NOT EXISTS idx_region_policies_type ON gee_region_policies(policy_type);


-- 3. 扩展任务表 (gee_tasks) - 添加任务来源字段
-- ============================================
ALTER TABLE gee_tasks 
ADD COLUMN IF NOT EXISTS task_source VARCHAR(20) DEFAULT 'manual';

COMMENT ON COLUMN gee_tasks.task_source IS '任务来源：manual=手动触发, auto=自动更新, batch=批量任务';

CREATE INDEX IF NOT EXISTS idx_gee_tasks_source ON gee_tasks(task_source);


-- 4. 创建作物类型配置表 (gee_crop_types) - 可选
-- ============================================
CREATE TABLE IF NOT EXISTS gee_crop_types (
    crop_id SERIAL PRIMARY KEY,
    crop_code VARCHAR(50) NOT NULL UNIQUE,          -- 作物代码
    crop_name VARCHAR(100) NOT NULL,                -- 作物名称
    default_start_date VARCHAR(10),                 -- 默认监测开始日期 MM-DD
    default_end_date VARCHAR(10),                   -- 默认监测结束日期 MM-DD
    description VARCHAR(500),
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gee_crop_types IS '作物类型配置表';
COMMENT ON COLUMN gee_crop_types.crop_code IS '作物代码（如：corn, rice, wheat）';
COMMENT ON COLUMN gee_crop_types.default_start_date IS '默认监测开始日期（格式：MM-DD）';
COMMENT ON COLUMN gee_crop_types.default_end_date IS '默认监测结束日期（格式：MM-DD）';

-- 插入默认作物类型数据
INSERT INTO gee_crop_types (crop_code, crop_name, default_start_date, default_end_date, description) VALUES
('corn', '玉米', '04-01', '09-30', '玉米生育期：4月-9月'),
('rice', '水稻', '05-01', '10-31', '水稻生育期：5月-10月'),
('wheat', '小麦', '10-01', '06-30', '小麦生育期：10月-次年6月'),
('soybean', '大豆', '05-01', '09-30', '大豆生育期：5月-9月'),
('cotton', '棉花', '04-01', '10-31', '棉花生育期：4月-10月')
ON CONFLICT (crop_code) DO NOTHING;


-- 5. 创建行政区边界表 (可选，用于PostGIS空间查询)
-- ============================================
-- 注意：需要先启用 PostGIS 扩展
-- CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS china_administrative_divisions (
    id SERIAL PRIMARY KEY,
    adcode VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    level VARCHAR(20) NOT NULL,                     -- province/city/district/township
    parent_adcode VARCHAR(20),
    center_lon DECIMAL(10,6),                       -- 中心点经度
    center_lat DECIMAL(10,6),                       -- 中心点纬度
    geometry GEOMETRY(MultiPolygon, 4326),          -- 边界几何（需要PostGIS）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE china_administrative_divisions IS '中国行政区划边界数据表';
COMMENT ON COLUMN china_administrative_divisions.adcode IS '行政区代码';
COMMENT ON COLUMN china_administrative_divisions.level IS '行政级别：province/city/district';
COMMENT ON COLUMN china_administrative_divisions.geometry IS '行政区边界几何（MultiPolygon）';

-- 创建空间索引（需要PostGIS）
-- CREATE INDEX IF NOT EXISTS idx_admin_geometry ON china_administrative_divisions USING GIST(geometry);
CREATE INDEX IF NOT EXISTS idx_admin_adcode ON china_administrative_divisions(adcode);
CREATE INDEX IF NOT EXISTS idx_admin_level ON china_administrative_divisions(level);
CREATE INDEX IF NOT EXISTS idx_admin_parent ON china_administrative_divisions(parent_adcode);


-- 6. 创建地块监测日志表 (可选，用于审计)
-- ============================================
CREATE TABLE IF NOT EXISTS gee_plot_monitor_logs (
    log_id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL,
    action VARCHAR(50) NOT NULL,                    -- 操作类型：enable/disable/pause_by_region
    reason VARCHAR(500),                            -- 操作原因
    operator VARCHAR(64),                           -- 操作人
    old_status SMALLINT,                            -- 旧状态
    new_status SMALLINT,                            -- 新状态
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_plot FOREIGN KEY (plot_id) REFERENCES gee_plots(plot_id) ON DELETE CASCADE
);

COMMENT ON TABLE gee_plot_monitor_logs IS '地块监测状态变更日志';
COMMENT ON COLUMN gee_plot_monitor_logs.action IS '操作类型：enable/disable/pause_by_region/resume_by_region';

CREATE INDEX IF NOT EXISTS idx_plot_logs_plot_id ON gee_plot_monitor_logs(plot_id);
CREATE INDEX IF NOT EXISTS idx_plot_logs_created ON gee_plot_monitor_logs(created_at);


-- 7. 创建视图：活跃地块视图
-- ============================================
CREATE OR REPLACE VIEW v_active_plots AS
SELECT 
    p.*,
    a.app_name,
    a.app_key,
    a.callback_url,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM gee_region_policies rp 
            WHERE rp.is_active = TRUE 
              AND rp.policy_type = 'pause'
              AND p.adcode LIKE rp.adcode || '%'
        ) THEN TRUE 
        ELSE FALSE 
    END as is_region_paused
FROM gee_plots p
LEFT JOIN gee_apps a ON p.app_id = a.app_id
WHERE p.monitor_status = 1 
  AND p.auto_update = TRUE;

COMMENT ON VIEW v_active_plots IS '活跃地块视图（已开启监测且未被区域暂停）';


-- 8. 数据迁移：为现有地块设置默认值
-- ============================================
UPDATE gee_plots 
SET 
    monitor_status = 1,
    auto_update = TRUE,
    update_frequency = 'daily'
WHERE monitor_status IS NULL;


-- 9. 创建触发器：记录地块状态变更
-- ============================================
CREATE OR REPLACE FUNCTION log_plot_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.monitor_status IS DISTINCT FROM NEW.monitor_status THEN
        INSERT INTO gee_plot_monitor_logs (
            plot_id, action, old_status, new_status, operator
        ) VALUES (
            NEW.plot_id,
            CASE WHEN NEW.monitor_status = 1 THEN 'enable' ELSE 'disable' END,
            OLD.monitor_status,
            NEW.monitor_status,
            current_user
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_plot_status_change ON gee_plots;
CREATE TRIGGER trigger_plot_status_change
    AFTER UPDATE ON gee_plots
    FOR EACH ROW
    EXECUTE FUNCTION log_plot_status_change();


-- 10. 创建存储过程：批量暂停/恢复区域地块
-- ============================================
CREATE OR REPLACE FUNCTION pause_region_plots(
    p_adcode VARCHAR(20),
    p_reason VARCHAR(500),
    p_operator VARCHAR(64)
)
RETURNS TABLE(affected_count INTEGER) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- 更新地块状态
    UPDATE gee_plots 
    SET monitor_status = 0,
        updated_at = CURRENT_TIMESTAMP
    WHERE adcode LIKE p_adcode || '%'
      AND monitor_status = 1;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    -- 记录日志
    INSERT INTO gee_plot_monitor_logs (plot_id, action, reason, operator, old_status, new_status)
    SELECT plot_id, 'pause_by_region', p_reason, p_operator, 1, 0
    FROM gee_plots
    WHERE adcode LIKE p_adcode || '%';
    
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION resume_region_plots(
    p_adcode VARCHAR(20),
    p_operator VARCHAR(64)
)
RETURNS TABLE(affected_count INTEGER) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- 恢复地块状态
    UPDATE gee_plots 
    SET monitor_status = 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE adcode LIKE p_adcode || '%'
      AND monitor_status = 0;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    -- 记录日志
    INSERT INTO gee_plot_monitor_logs (plot_id, action, reason, operator, old_status, new_status)
    SELECT plot_id, 'resume_by_region', '恢复区域监测', p_operator, 0, 1
    FROM gee_plots
    WHERE adcode LIKE p_adcode || '%';
    
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- 升级完成
-- ============================================
-- 验证查询示例：
-- 1. 查看所有活跃地块：SELECT * FROM v_active_plots;
-- 2. 查看暂停的区域：SELECT * FROM gee_region_policies WHERE is_active = TRUE;
-- 3. 查看地块变更日志：SELECT * FROM gee_plot_monitor_logs ORDER BY created_at DESC LIMIT 10;
