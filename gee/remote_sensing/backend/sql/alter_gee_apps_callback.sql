-- 修改 gee_apps 表，添加回调和每日更新字段
ALTER TABLE gee_apps 
ADD COLUMN IF NOT EXISTS callback_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS enable_daily_update BOOLEAN DEFAULT FALSE;

-- 添加注释
COMMENT ON COLUMN gee_apps.callback_url IS '回调地址';
COMMENT ON COLUMN gee_apps.enable_daily_update IS '是否启用每日自动更新';
