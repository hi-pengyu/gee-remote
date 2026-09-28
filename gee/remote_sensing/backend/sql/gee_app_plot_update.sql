-- ============================================
-- GEE 应用与地块管理表结构更新
-- ============================================

-- 1. 创建应用表 (gee_apps)
CREATE TABLE IF NOT EXISTS gee_apps (
    app_id SERIAL PRIMARY KEY,
    app_name VARCHAR(100) NOT NULL,
    app_key VARCHAR(64) NOT NULL UNIQUE,
    description VARCHAR(500),
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gee_apps IS 'GEE应用管理表';
COMMENT ON COLUMN gee_apps.app_id IS '应用ID';
COMMENT ON COLUMN gee_apps.app_name IS '应用名称';
COMMENT ON COLUMN gee_apps.app_key IS 'API密钥';
COMMENT ON COLUMN gee_apps.description IS '应用描述';
COMMENT ON COLUMN gee_apps.is_enabled IS '是否启用';

-- 2. 创建地块表 (gee_plots)
CREATE TABLE IF NOT EXISTS gee_plots (
    plot_id SERIAL PRIMARY KEY,
    app_id INTEGER NOT NULL,
    plot_name VARCHAR(100) NOT NULL,
    geometry TEXT NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_plot_app FOREIGN KEY (app_id) REFERENCES gee_apps(app_id) ON DELETE CASCADE
);

COMMENT ON TABLE gee_plots IS 'GEE地块管理表';
COMMENT ON COLUMN gee_plots.plot_id IS '地块ID';
COMMENT ON COLUMN gee_plots.app_id IS '关联应用ID';
COMMENT ON COLUMN gee_plots.plot_name IS '地块名称';
COMMENT ON COLUMN gee_plots.geometry IS '地块几何信息(GeoJSON)';
COMMENT ON COLUMN gee_plots.description IS '地块描述';

-- 创建索引
CREATE INDEX idx_gee_plots_app_id ON gee_plots(app_id);

-- 3. 更新任务表 (gee_tasks)
-- 添加 app_id 和 plot_id 字段
ALTER TABLE gee_tasks ADD COLUMN IF NOT EXISTS app_id INTEGER;
ALTER TABLE gee_tasks ADD COLUMN IF NOT EXISTS plot_id INTEGER;

-- 添加外键约束
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_task_app') THEN
        ALTER TABLE gee_tasks ADD CONSTRAINT fk_task_app FOREIGN KEY (app_id) REFERENCES gee_apps(app_id) ON DELETE SET NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_task_plot') THEN
        ALTER TABLE gee_tasks ADD CONSTRAINT fk_task_plot FOREIGN KEY (plot_id) REFERENCES gee_plots(plot_id) ON DELETE SET NULL;
    END IF;
END $$;

COMMENT ON COLUMN gee_tasks.app_id IS '关联应用ID';
COMMENT ON COLUMN gee_tasks.plot_id IS '关联地块ID';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_gee_tasks_app_id ON gee_tasks(app_id);
CREATE INDEX IF NOT EXISTS idx_gee_tasks_plot_id ON gee_tasks(plot_id);

-- 4. 插入默认应用 (可选，方便测试)
INSERT INTO gee_apps (app_name, app_key, description) 
VALUES ('Default App', 'default_api_key_123456', '系统默认应用')
ON CONFLICT (app_key) DO NOTHING;
