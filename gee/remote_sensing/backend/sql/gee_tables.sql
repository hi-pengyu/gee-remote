-- =============================================
-- GEE缓存系统数据库表 (PostgreSQL)
-- 版本: 1.0.0
-- 日期: 2025-11-28
-- =============================================

-- ----------------------------
-- 1. GEE瓦片缓存表
-- ----------------------------
DROP TABLE IF EXISTS gee_tiles CASCADE;
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
COMMENT ON COLUMN gee_tiles.status IS '状态(0正常 1删除)';

CREATE INDEX idx_tiles_expires ON gee_tiles(expires_at);
CREATE INDEX idx_tiles_access ON gee_tiles(access_count DESC, last_access DESC);
CREATE INDEX idx_tiles_status ON gee_tiles(status);
CREATE INDEX idx_tiles_spatial ON gee_tiles(tile_x, tile_y);
CREATE INDEX idx_tiles_date ON gee_tiles(date_acquired);

-- ----------------------------
-- 2. GEE任务记录表
-- ----------------------------
DROP TABLE IF EXISTS gee_tasks CASCADE;
CREATE TABLE gee_tasks (
  task_id VARCHAR(100) PRIMARY KEY,
  task_type VARCHAR(50) NOT NULL,
  task_name VARCHAR(200),
  target_date DATE NOT NULL,
  model_type VARCHAR(50),
  aoi_coords TEXT,
  status CHAR(1) DEFAULT '0',
  progress INTEGER DEFAULT 0,
  cache_hit_rate DECIMAL(5,2),
  cache_source VARCHAR(20),
  tile_ids TEXT,
  result_path VARCHAR(500),
  error_msg TEXT,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  duration INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  create_by VARCHAR(64) DEFAULT '',
  dept_id BIGINT,
  remark VARCHAR(500)
);

COMMENT ON TABLE gee_tasks IS 'GEE任务记录表';
COMMENT ON COLUMN gee_tasks.status IS '状态(0待处理 1处理中 2成功 3失败 4已取消)';

CREATE INDEX idx_tasks_status ON gee_tasks(status);
CREATE INDEX idx_tasks_date ON gee_tasks(target_date);
CREATE INDEX idx_tasks_user ON gee_tasks(create_by);
CREATE INDEX idx_tasks_dept ON gee_tasks(dept_id);
CREATE INDEX idx_tasks_created ON gee_tasks(created_at);

-- ----------------------------
-- 3. GEE系统配置表
-- ----------------------------
DROP TABLE IF EXISTS gee_config CASCADE;
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

-- 初始化配置数据
INSERT INTO gee_config (config_key, config_value, config_type, config_desc, create_by) VALUES 
('tile_size_km', '5.0', 'number', '瓦片大小(公里)', 'admin'),
('tile_cache_days', '14', 'number', '瓦片缓存有效期(天)', 'admin'),
('max_cache_size_gb', '50.0', 'number', '最大缓存大小(GB)', 'admin'),
('prefetch_adjacent', 'true', 'boolean', '是否自动预取相邻瓦片', 'admin'),
('gee_project_id', '<REDACTED_GCP_PROJECT_ID>', 'string', 'GEE项目ID', 'admin'),
('gee_scale', '10', 'number', 'Sentinel-2分辨率', 'admin');

-- ----------------------------
-- 4. 菜单SQL (如果sys_menu表存在)
-- ----------------------------
-- 一级菜单: GEE管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
VALUES (2000, 'GEE管理', 0, 5, 'gee', NULL, NULL, 1, 0, 'M', '0', '0', '', 'chart', 'admin', NOW(), '', NULL, 'GEE缓存系统管理')
ON CONFLICT (menu_id) DO NOTHING;

-- 二级菜单: 缓存管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2001, '缓存管理', 2000, 1, 'cache', 'gee/cache/index', NULL, 1, 0, 'C', '0', '0', 'gee:cache:list', 'database', 'admin', NOW(), '', NULL, '瓦片缓存管理')
ON CONFLICT (menu_id) DO NOTHING;

-- 二级菜单: 任务管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2002, '任务管理', 2000, 2, 'task', 'gee/task/index', NULL, 1, 0, 'C', '0', '0', 'gee:task:list', 'job', 'admin', NOW(), '', NULL, 'GEE任务管理')
ON CONFLICT (menu_id) DO NOTHING;

-- 二级菜单: 数据统计
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2003, '数据统计', 2000, 3, 'stats', 'gee/stats/index', NULL, 1, 0, 'C', '0', '0', 'gee:stats:view', 'chart', 'admin', NOW(), '', NULL, '数据统计分析')
ON CONFLICT (menu_id) DO NOTHING;

-- 二级菜单: 系统监控
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2004, '系统监控', 2000, 4, 'monitor', 'gee/monitor/index', NULL, 1, 0, 'C', '0', '0', 'gee:monitor:view', 'monitor', 'admin', NOW(), '', NULL, '系统监控')
ON CONFLICT (menu_id) DO NOTHING;

-- 缓存管理按钮
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2011, '缓存查询', 2001, 1, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:query', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2012, '缓存删除', 2001, 2, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:remove', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2013, '缓存预取', 2001, 3, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:prefetch', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2014, '缓存导出', 2001, 4, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:export', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

-- 任务管理按钮
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2021, '任务查询', 2002, 1, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:query', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2022, '任务新增', 2002, 2, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:add', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2023, '任务取消', 2002, 3, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:cancel', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2024, '任务详情', 2002, 4, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:detail', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2025, '任务导出', 2002, 5, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:export', '#', 'admin', NOW(), '', NULL, '')
ON CONFLICT (menu_id) DO NOTHING;
