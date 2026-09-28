-- =============================================
-- RuoYi后台数据库 - GEE模块表 (PostgreSQL)
-- 数据库名: ruoyi_db (或你的RuoYi数据库名)
-- 版本: 1.0.0
-- 日期: 2025-11-28
-- =============================================

-- 这些表放在RuoYi后台数据库中,用于权限控制和任务记录

-- ----------------------------
-- 1. GEE任务记录表 (轻量级,只记录任务元数据)
-- ----------------------------
DROP TABLE IF EXISTS gee_tasks;
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

CREATE INDEX idx_gee_tasks_status ON gee_tasks(status);
CREATE INDEX idx_gee_tasks_date ON gee_tasks(target_date);
CREATE INDEX idx_gee_tasks_user ON gee_tasks(create_by);
CREATE INDEX idx_gee_tasks_dept ON gee_tasks(dept_id);
CREATE INDEX idx_gee_tasks_created ON gee_tasks(created_at);

-- ----------------------------
-- 2. 菜单SQL
-- ----------------------------
-- 一级菜单: GEE管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
VALUES (2000, 'GEE管理', 0, 5, 'gee', NULL, NULL, 1, 0, 'M', '0', '0', '', 'chart', 'admin', NOW(), '', NULL, 'GEE缓存系统管理');

-- 二级菜单: 缓存管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2001, '缓存管理', 2000, 1, 'cache', 'gee/cache/index', NULL, 1, 0, 'C', '0', '0', 'gee:cache:list', 'database', 'admin', NOW(), '', NULL, '瓦片缓存管理');

-- 二级菜单: 任务管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2002, '任务管理', 2000, 2, 'task', 'gee/task/index', NULL, 1, 0, 'C', '0', '0', 'gee:task:list', 'job', 'admin', NOW(), '', NULL, 'GEE任务管理');

-- 二级菜单: 数据统计
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2003, '数据统计', 2000, 3, 'stats', 'gee/stats/index', NULL, 1, 0, 'C', '0', '0', 'gee:stats:view', 'chart', 'admin', NOW(), '', NULL, '数据统计分析');

-- 二级菜单: 系统监控
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2004, '系统监控', 2000, 4, 'monitor', 'gee/monitor/index', NULL, 1, 0, 'C', '0', '0', 'gee:monitor:view', 'monitor', 'admin', NOW(), '', NULL, '系统监控');

-- 缓存管理按钮
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2011, '缓存查询', 2001, 1, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:query', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2012, '缓存删除', 2001, 2, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:remove', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2013, '缓存预取', 2001, 3, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:prefetch', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2014, '缓存导出', 2001, 4, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:cache:export', '#', 'admin', NOW(), '', NULL, '');

-- 任务管理按钮
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2021, '任务查询', 2002, 1, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:query', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2022, '任务新增', 2002, 2, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:add', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2023, '任务取消', 2002, 3, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:cancel', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2024, '任务详情', 2002, 4, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:detail', '#', 'admin', NOW(), '', NULL, '');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2025, '任务导出', 2002, 5, '', NULL, NULL, 1, 0, 'F', '0', '0', 'gee:task:export', '#', 'admin', NOW(), '', NULL, '');
