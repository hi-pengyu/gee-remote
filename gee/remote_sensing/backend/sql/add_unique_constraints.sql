-- ============================================
-- 为GEE结果表添加唯一约束
-- ============================================

-- 1. 为 gee_task_results 表添加唯一约束
-- 确保每个任务只有一条结果记录
ALTER TABLE gee_task_results 
ADD CONSTRAINT uq_task_results_task_id UNIQUE (task_id);

COMMENT ON CONSTRAINT uq_task_results_task_id ON gee_task_results 
IS '确保每个任务只有一条结果记录';

-- 2. 为 gee_model_predictions 表添加唯一约束
-- 确保同一任务的同一模型只有一条预测记录
ALTER TABLE gee_model_predictions 
ADD CONSTRAINT uq_model_predictions_task_model UNIQUE (task_id, model_code);

COMMENT ON CONSTRAINT uq_model_predictions_task_model ON gee_model_predictions 
IS '确保同一任务的同一模型只有一条预测记录';

-- 验证约束是否添加成功
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'gee_task_results'::regclass
   OR conrelid = 'gee_model_predictions'::regclass
ORDER BY conrelid, conname;
