-- =============================================
-- GEE Configuration Simplification Script
-- =============================================

-- 1. Remove gee_accounts table (no longer used, single account strategy)
DROP TABLE IF EXISTS "public"."gee_accounts";
DROP SEQUENCE IF EXISTS "public"."gee_accounts_account_id_seq";

-- 2. Clean up gee_config table
-- Remove infrastructure configurations that should be in environment variables
DELETE FROM "public"."gee_config" 
WHERE config_group IN ('redis', 'celery', 'oss', 'database');

-- Remove any specific config keys if they are no longer needed (redundant)
DELETE FROM "public"."gee_config"
WHERE config_key IN (
    'REDIS_HOST', 'REDIS_PORT', 'REDIS_DB', 'REDIS_PASSWORD',
    '<REDACTED_REDIS_PASSWORD>', 'CELERY_RESULT_BACKEND',
    'OSS_ACCESS_KEY_ID', 'OSS_ACCESS_KEY_SECRET', 'OSS_ENDPOINT', 'OSS_BUCKET_NAME',
    'GEE_DRIVE_TOKEN_PATH', 'GEE_DRIVE_TOKEN_JSON', 'GEE_DRIVE_FOLDER_ID', 'GEE_USER_CREDENTIALS'
);

-- 3. Add indexes to gee_config for better performance
CREATE INDEX IF NOT EXISTS "idx_gee_config_key" ON "public"."gee_config" USING btree (
  "config_key" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

CREATE INDEX IF NOT EXISTS "idx3_gee_config_group" ON "public"."gee_config" USING btree (
  "config_group" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- 4. Update comments/descriptions if needed (optional)
COMMENT ON TABLE "public"."gee_config" IS 'GEE Dynamic Configuration (System params only)';
