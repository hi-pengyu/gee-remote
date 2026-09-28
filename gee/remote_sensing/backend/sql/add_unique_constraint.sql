-- 为gee_model_predictions表添加唯一约束
-- 确保同一任务的同一模型只有一条记录

-- 添加唯一约束（如果不存在）
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'uq_model_predictions_task_model'
    ) THEN
        ALTER TABLE gee_model_predictions 
        ADD CONSTRAINT uq_model_predictions_task_model UNIQUE (task_id, model_code);
    END IF;
END $$;

COMMENT ON CONSTRAINT uq_model_predictions_task_model ON gee_model_predictions 
IS '确保同一任务的同一模型只有一条记录';
