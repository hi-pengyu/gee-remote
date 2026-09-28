-- 检查并修复 gee_crop_types 表结构

-- 1. 先删除旧表（如果存在）
DROP TABLE IF EXISTS gee_crop_types CASCADE;

-- 2. 重新创建表
CREATE TABLE gee_crop_types (
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

-- 3. 插入默认数据
INSERT INTO gee_crop_types (crop_code, crop_name, monitor_start_date, monitor_end_date, description, sort_order, status) VALUES
('corn', '玉米', '04-01', '09-30', '玉米作物，生育期4-9月', 1, '0'),
('rice', '水稻', '05-01', '10-31', '水稻作物，生育期5-10月', 2, '0'),
('wheat', '小麦', '10-01', '06-30', '小麦作物，生育期10月-次年6月', 3, '0'),
('soybean', '大豆', '05-01', '09-30', '大豆作物，生育期5-9月', 4, '0'),
('cotton', '棉花', '04-01', '10-31', '棉花作物，生育期4-10月', 5, '0'),
('peanut', '花生', '04-15', '09-15', '花生作物，生育期4-9月', 6, '0'),
('rapeseed', '油菜', '09-01', '05-31', '油菜作物，生育期9月-次年5月', 7, '0'),
('potato', '马铃薯', '03-01', '07-31', '马铃薯作物，生育期3-7月', 8, '0');

SELECT '✅ gee_crop_types 表已重新创建' as message;
