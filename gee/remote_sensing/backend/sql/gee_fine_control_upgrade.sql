-- =============================================
-- GEE 精细化管控功能升级脚本
-- 支持按作物类型的精细化管控
-- =============================================

-- 1. 创建作物类型字典表
CREATE TABLE IF NOT EXISTS gee_crop_types (
    crop_code VARCHAR(50) PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    monitor_start_date VARCHAR(10),  -- MM-DD格式
    monitor_end_date VARCHAR(10),    -- MM-DD格式
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    status CHAR(1) DEFAULT '0',      -- 0=正常 1=停用
    created_by VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500)
);

COMMENT ON TABLE gee_crop_types IS 'GEE作物类型字典表';
COMMENT ON COLUMN gee_crop_types.crop_code IS '作物代码';
COMMENT ON COLUMN gee_crop_types.crop_name IS '作物名称';
COMMENT ON COLUMN gee_crop_types.monitor_start_date IS '监测开始日期(MM-DD)';
COMMENT ON COLUMN gee_crop_types.monitor_end_date IS '监测结束日期(MM-DD)';
COMMENT ON COLUMN gee_crop_types.status IS '状态(0=正常 1=停用)';

-- 插入默认作物类型
INSERT INTO gee_crop_types (crop_code, crop_name, monitor_start_date, monitor_end_date, description, sort_order, status) VALUES
('corn', '玉米', '04-01', '09-30', '玉米作物，生育期4-9月', 1, '0'),
('rice', '水稻', '05-01', '10-31', '水稻作物，生育期5-10月', 2, '0'),
('wheat', '小麦', '10-01', '06-30', '小麦作物，生育期10月-次年6月', 3, '0'),
('soybean', '大豆', '05-01', '09-30', '大豆作物，生育期5-9月', 4, '0'),
('cotton', '棉花', '04-01', '10-31', '棉花作物，生育期4-10月', 5, '0'),
('peanut', '花生', '04-15', '09-15', '花生作物，生育期4-9月', 6, '0'),
('rapeseed', '油菜', '09-01', '05-31', '油菜作物，生育期9月-次年5月', 7, '0'),
('potato', '马铃薯', '03-01', '07-31', '马铃薯作物，生育期3-7月', 8, '0')
ON CONFLICT (crop_code) DO NOTHING;


-- 2. 创建精细化管控策略表
CREATE TABLE IF NOT EXISTS gee_control_policies (
    policy_id SERIAL PRIMARY KEY,
    policy_name VARCHAR(200) NOT NULL,
    policy_type VARCHAR(50) NOT NULL,  -- admin_region=行政区, custom_region=自定义区域, single_plot=单个地块
    
    -- 行政区相关
    adcode VARCHAR(20),                -- 行政区代码（支持前缀匹配）
    region_name VARCHAR(200),          -- 行政区名称
    
    -- 自定义区域相关
    custom_geometry TEXT,              -- 自定义区域几何（GeoJSON）
    
    -- 地块相关
    plot_id INTEGER,                   -- 地块ID（单个地块管控时使用）
    
    -- 作物类型控制
    crop_codes TEXT[],                 -- 作物代码数组，NULL表示所有作物
    
    -- 控制状态
    control_action VARCHAR(20) NOT NULL,  -- pause=暂停, resume=恢复
    is_active BOOLEAN DEFAULT TRUE,
    
    -- 元数据
    reason TEXT,
    priority INTEGER DEFAULT 0,        -- 优先级，数字越大优先级越高
    created_by VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500)
);

COMMENT ON TABLE gee_control_policies IS 'GEE精细化管控策略表';
COMMENT ON COLUMN gee_control_policies.policy_type IS '策略类型(admin_region/custom_region/single_plot)';
COMMENT ON COLUMN gee_control_policies.adcode IS '行政区代码';
COMMENT ON COLUMN gee_control_policies.custom_geometry IS '自定义区域几何';
COMMENT ON COLUMN gee_control_policies.plot_id IS '地块ID';
COMMENT ON COLUMN gee_control_policies.crop_codes IS '作物代码数组';
COMMENT ON COLUMN gee_control_policies.control_action IS '控制动作(pause/resume)';
COMMENT ON COLUMN gee_control_policies.priority IS '优先级';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_control_policies_type ON gee_control_policies(policy_type);
CREATE INDEX IF NOT EXISTS idx_control_policies_adcode ON gee_control_policies(adcode);
CREATE INDEX IF NOT EXISTS idx_control_policies_plot ON gee_control_policies(plot_id);
CREATE INDEX IF NOT EXISTS idx_control_policies_active ON gee_control_policies(is_active);


-- 3. 创建管控日志表
CREATE TABLE IF NOT EXISTS gee_control_logs (
    log_id SERIAL PRIMARY KEY,
    policy_id INTEGER REFERENCES gee_control_policies(policy_id),
    action_type VARCHAR(50) NOT NULL,  -- create=创建, update=更新, delete=删除, execute=执行
    affected_plots INTEGER DEFAULT 0,  -- 受影响的地块数
    details JSONB,                     -- 详细信息
    created_by VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gee_control_logs IS 'GEE管控操作日志表';
COMMENT ON COLUMN gee_control_logs.action_type IS '操作类型';
COMMENT ON COLUMN gee_control_logs.affected_plots IS '受影响地块数';

CREATE INDEX IF NOT EXISTS idx_control_logs_policy ON gee_control_logs(policy_id);
CREATE INDEX IF NOT EXISTS idx_control_logs_created ON gee_control_logs(created_at);


-- 4. 创建地块管控状态视图
CREATE OR REPLACE VIEW v_plot_control_status AS
SELECT 
    p.plot_id,
    p.plot_name,
    p.adcode,
    p.province,
    p.city,
    p.district,
    p.crop_type,
    p.monitor_status as original_status,
    
    -- 检查是否被管控策略影响
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM gee_control_policies cp
            WHERE cp.is_active = TRUE
            AND cp.control_action = 'pause'
            AND (
                -- 行政区管控
                (cp.policy_type = 'admin_region' 
                 AND p.adcode LIKE cp.adcode || '%'
                 AND (cp.crop_codes IS NULL OR p.crop_type = ANY(cp.crop_codes)))
                OR
                -- 单个地块管控
                (cp.policy_type = 'single_plot' 
                 AND cp.plot_id = p.plot_id
                 AND (cp.crop_codes IS NULL OR p.crop_type = ANY(cp.crop_codes)))
                OR
                -- 自定义区域管控（需要空间查询）
                (cp.policy_type = 'custom_region'
                 AND ST_Intersects(
                     ST_GeomFromGeoJSON(p.geometry::text), 
                     ST_GeomFromGeoJSON(cp.custom_geometry)
                 )
                 AND (cp.crop_codes IS NULL OR p.crop_type = ANY(cp.crop_codes)))
            )
            ORDER BY cp.priority DESC, cp.created_at DESC
            LIMIT 1
        ) THEN 0
        ELSE p.monitor_status
    END as effective_status,
    
    -- 获取应用的策略信息
    (
        SELECT json_build_object(
            'policy_id', cp.policy_id,
            'policy_name', cp.policy_name,
            'policy_type', cp.policy_type,
            'reason', cp.reason,
            'crop_codes', cp.crop_codes
        )
        FROM gee_control_policies cp
        WHERE cp.is_active = TRUE
        AND cp.control_action = 'pause'
        AND (
            (cp.policy_type = 'admin_region' 
             AND p.adcode LIKE cp.adcode || '%'
             AND (cp.crop_codes IS NULL OR p.crop_type = ANY(cp.crop_codes)))
            OR
            (cp.policy_type = 'single_plot' 
             AND cp.plot_id = p.plot_id
             AND (cp.crop_codes IS NULL OR p.crop_type = ANY(cp.crop_codes)))
            OR
            (cp.policy_type = 'custom_region'
             AND ST_Intersects(
                 ST_GeomFromGeoJSON(p.geometry::text), 
                 ST_GeomFromGeoJSON(cp.custom_geometry)
             )
             AND (cp.crop_codes IS NULL OR p.crop_type = ANY(cp.crop_codes)))
        )
        ORDER BY cp.priority DESC, cp.created_at DESC
        LIMIT 1
    ) as applied_policy

FROM gee_plots p;

COMMENT ON VIEW v_plot_control_status IS '地块管控状态视图';


-- 5. 创建辅助函数：获取受影响的地块
CREATE OR REPLACE FUNCTION get_affected_plots(
    p_policy_type VARCHAR,
    p_adcode VARCHAR DEFAULT NULL,
    p_custom_geometry TEXT DEFAULT NULL,
    p_plot_id INTEGER DEFAULT NULL,
    p_crop_codes TEXT[] DEFAULT NULL
)
RETURNS TABLE (
    plot_id INTEGER,
    plot_name VARCHAR,
    crop_type VARCHAR,
    current_status INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.plot_id,
        p.plot_name,
        p.crop_type,
        p.monitor_status
    FROM gee_plots p
    WHERE 
        CASE p_policy_type
            WHEN 'admin_region' THEN
                p.adcode LIKE p_adcode || '%'
                AND (p_crop_codes IS NULL OR p.crop_type = ANY(p_crop_codes))
            WHEN 'single_plot' THEN
                p.plot_id = p_plot_id
                AND (p_crop_codes IS NULL OR p.crop_type = ANY(p_crop_codes))
            WHEN 'custom_region' THEN
                ST_Intersects(
                    ST_GeomFromGeoJSON(p.geometry::text), 
                    ST_GeomFromGeoJSON(p_custom_geometry)
                )
                AND (p_crop_codes IS NULL OR p.crop_type = ANY(p_crop_codes))
            ELSE FALSE
        END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_affected_plots IS '获取受管控策略影响的地块列表';


-- 6. 创建触发器：记录管控策略变更
CREATE OR REPLACE FUNCTION log_control_policy_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO gee_control_logs (policy_id, action_type, details)
        VALUES (NEW.policy_id, 'create', row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO gee_control_logs (policy_id, action_type, details)
        VALUES (NEW.policy_id, 'update', jsonb_build_object(
            'old', row_to_json(OLD)::jsonb,
            'new', row_to_json(NEW)::jsonb
        ));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO gee_control_logs (policy_id, action_type, details)
        VALUES (OLD.policy_id, 'delete', row_to_json(OLD)::jsonb);
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_control_policy_change ON gee_control_policies;
CREATE TRIGGER trg_control_policy_change
AFTER INSERT OR UPDATE OR DELETE ON gee_control_policies
FOR EACH ROW EXECUTE FUNCTION log_control_policy_change();


-- 7. 创建统计视图
CREATE OR REPLACE VIEW v_control_statistics AS
SELECT 
    policy_type,
    COUNT(*) as policy_count,
    COUNT(CASE WHEN is_active THEN 1 END) as active_count,
    COUNT(CASE WHEN control_action = 'pause' THEN 1 END) as pause_count,
    COUNT(CASE WHEN control_action = 'resume' THEN 1 END) as resume_count
FROM gee_control_policies
GROUP BY policy_type;

COMMENT ON VIEW v_control_statistics IS '管控策略统计视图';


-- 完成
SELECT '✅ GEE精细化管控功能升级完成！' as message;
