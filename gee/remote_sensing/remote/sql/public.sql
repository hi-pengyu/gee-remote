/*
 Navicat Premium Dump SQL

 Source Server         : 遥感postgresql
 Source Server Type    : PostgreSQL
 Source Server Version : 160011 (160011)
 Source Host           : 192.168.112.101:5432
 Source Catalog        : remote_sensing
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 160011 (160011)
 File Encoding         : 65001

 Date: 13/02/2026 09:52:51
*/


-- ----------------------------
-- Type structure for box2d
-- ----------------------------
DROP TYPE IF EXISTS "public"."box2d";
CREATE TYPE "public"."box2d" (
  INPUT = "public"."box2d_in",
  OUTPUT = "public"."box2d_out",
  INTERNALLENGTH = 65,
  CATEGORY = U,
  DELIMITER = ','
);
COMMENT ON TYPE "public"."box2d" IS 'postgis type: The type representing a 2-dimensional bounding box.';

-- ----------------------------
-- Type structure for box2df
-- ----------------------------
DROP TYPE IF EXISTS "public"."box2df";
CREATE TYPE "public"."box2df" (
  INPUT = "public"."box2df_in",
  OUTPUT = "public"."box2df_out",
  INTERNALLENGTH = 16,
  ALIGNMENT = double,
  CATEGORY = U,
  DELIMITER = ','
);

-- ----------------------------
-- Type structure for box3d
-- ----------------------------
DROP TYPE IF EXISTS "public"."box3d";
CREATE TYPE "public"."box3d" (
  INPUT = "public"."box3d_in",
  OUTPUT = "public"."box3d_out",
  INTERNALLENGTH = 52,
  ALIGNMENT = double,
  CATEGORY = U,
  DELIMITER = ','
);
COMMENT ON TYPE "public"."box3d" IS 'postgis type: The type representing a 3-dimensional bounding box.';

-- ----------------------------
-- Type structure for geography
-- ----------------------------
DROP TYPE IF EXISTS "public"."geography";
CREATE TYPE "public"."geography" (
  INPUT = "public"."geography_in",
  OUTPUT = "public"."geography_out",
  RECEIVE = "public"."geography_recv",
  SEND = "public"."geography_send",
  TYPMOD_IN = "public"."geography_typmod_in",
  TYPMOD_OUT = "public"."geography_typmod_out",
  ANALYZE = "public"."geography_analyze",
  INTERNALLENGTH = VARIABLE,
  ALIGNMENT = double,
  STORAGE = main,
  CATEGORY = U,
  DELIMITER = ':'
);
COMMENT ON TYPE "public"."geography" IS 'postgis type: The type representing spatial features with geodetic (ellipsoidal) coordinate systems.';

-- ----------------------------
-- Type structure for geometry
-- ----------------------------
DROP TYPE IF EXISTS "public"."geometry";
CREATE TYPE "public"."geometry" (
  INPUT = "public"."geometry_in",
  OUTPUT = "public"."geometry_out",
  RECEIVE = "public"."geometry_recv",
  SEND = "public"."geometry_send",
  TYPMOD_IN = "public"."geometry_typmod_in",
  TYPMOD_OUT = "public"."geometry_typmod_out",
  ANALYZE = "public"."geometry_analyze",
  INTERNALLENGTH = VARIABLE,
  ALIGNMENT = double,
  STORAGE = main,
  CATEGORY = U,
  DELIMITER = ':'
);
COMMENT ON TYPE "public"."geometry" IS 'postgis type: The type representing spatial features with planar coordinate systems.';

-- ----------------------------
-- Type structure for geometry_dump
-- ----------------------------
DROP TYPE IF EXISTS "public"."geometry_dump";
CREATE TYPE "public"."geometry_dump" AS (
  "path" int4[],
  "geom" "public"."geometry"
);
COMMENT ON TYPE "public"."geometry_dump" IS 'postgis type: A composite type used to describe the parts of complex geometry.';

-- ----------------------------
-- Type structure for gidx
-- ----------------------------
DROP TYPE IF EXISTS "public"."gidx";
CREATE TYPE "public"."gidx" (
  INPUT = "public"."gidx_in",
  OUTPUT = "public"."gidx_out",
  INTERNALLENGTH = VARIABLE,
  ALIGNMENT = double,
  CATEGORY = U,
  DELIMITER = ','
);

-- ----------------------------
-- Type structure for spheroid
-- ----------------------------
DROP TYPE IF EXISTS "public"."spheroid";
CREATE TYPE "public"."spheroid" (
  INPUT = "public"."spheroid_in",
  OUTPUT = "public"."spheroid_out",
  INTERNALLENGTH = 65,
  ALIGNMENT = double,
  CATEGORY = U,
  DELIMITER = ','
);

-- ----------------------------
-- Type structure for valid_detail
-- ----------------------------
DROP TYPE IF EXISTS "public"."valid_detail";
CREATE TYPE "public"."valid_detail" AS (
  "valid" bool,
  "reason" varchar COLLATE "pg_catalog"."default",
  "location" "public"."geometry"
);


-- ----------------------------
-- Sequence structure for gee_apps_app_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_apps_app_id_seq";
CREATE SEQUENCE "public"."gee_apps_app_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_cache_stats_stat_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_cache_stats_stat_id_seq";
CREATE SEQUENCE "public"."gee_cache_stats_stat_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_config_config_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_config_config_id_seq";
CREATE SEQUENCE "public"."gee_config_config_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_crop_types_crop_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_crop_types_crop_id_seq";
CREATE SEQUENCE "public"."gee_crop_types_crop_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_custom_regions_region_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_custom_regions_region_id_seq";
CREATE SEQUENCE "public"."gee_custom_regions_region_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_grade_statistics_stat_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_grade_statistics_stat_id_seq";
CREATE SEQUENCE "public"."gee_grade_statistics_stat_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_model_predictions_prediction_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_model_predictions_prediction_id_seq";
CREATE SEQUENCE "public"."gee_model_predictions_prediction_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_optimization_result_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_optimization_result_id_seq";
CREATE SEQUENCE "public"."gee_optimization_result_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_plot_monitor_logs_log_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_plot_monitor_logs_log_id_seq";
CREATE SEQUENCE "public"."gee_plot_monitor_logs_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_plots_plot_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_plots_plot_id_seq";
CREATE SEQUENCE "public"."gee_plots_plot_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_prefetch_regions_region_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_prefetch_regions_region_id_seq";
CREATE SEQUENCE "public"."gee_prefetch_regions_region_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_region_policies_policy_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_region_policies_policy_id_seq";
CREATE SEQUENCE "public"."gee_region_policies_policy_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gee_task_results_result_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gee_task_results_result_id_seq";
CREATE SEQUENCE "public"."gee_task_results_result_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gen_table_column_column_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gen_table_column_column_id_seq";
CREATE SEQUENCE "public"."gen_table_column_column_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gen_table_table_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gen_table_table_id_seq";
CREATE SEQUENCE "public"."gen_table_table_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for lease_transfer_item_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."lease_transfer_item_id_seq";
CREATE SEQUENCE "public"."lease_transfer_item_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_config_config_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_config_config_id_seq";
CREATE SEQUENCE "public"."sys_config_config_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dept_dept_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dept_dept_id_seq";
CREATE SEQUENCE "public"."sys_dept_dept_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dict_data_dict_code_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dict_data_dict_code_seq";
CREATE SEQUENCE "public"."sys_dict_data_dict_code_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dict_type_dict_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dict_type_dict_id_seq";
CREATE SEQUENCE "public"."sys_dict_type_dict_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_job_job_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_job_job_id_seq";
CREATE SEQUENCE "public"."sys_job_job_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_job_log_job_log_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_job_log_job_log_id_seq";
CREATE SEQUENCE "public"."sys_job_log_job_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_logininfor_info_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_logininfor_info_id_seq";
CREATE SEQUENCE "public"."sys_logininfor_info_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_menu_menu_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_menu_menu_id_seq";
CREATE SEQUENCE "public"."sys_menu_menu_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_notice_notice_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_notice_notice_id_seq";
CREATE SEQUENCE "public"."sys_notice_notice_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_oper_log_oper_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_oper_log_oper_id_seq";
CREATE SEQUENCE "public"."sys_oper_log_oper_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_post_post_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_post_post_id_seq";
CREATE SEQUENCE "public"."sys_post_post_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_role_role_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_role_role_id_seq";
CREATE SEQUENCE "public"."sys_role_role_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_user_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_user_id_seq";
CREATE SEQUENCE "public"."sys_user_user_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for training_videos_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."training_videos_id_seq";
CREATE SEQUENCE "public"."training_videos_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for apscheduler_jobs
-- ----------------------------
DROP TABLE IF EXISTS "public"."apscheduler_jobs";
CREATE TABLE "public"."apscheduler_jobs" (
  "id" varchar(191) COLLATE "pg_catalog"."default" NOT NULL,
  "next_run_time" float8,
  "job_state" bytea NOT NULL
)
;


-- ----------------------------
-- Table structure for gee_apps
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_apps";
CREATE TABLE "public"."gee_apps" (
  "app_id" int4 NOT NULL DEFAULT nextval('gee_apps_app_id_seq'::regclass),
  "app_name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "app_key" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "description" varchar(500) COLLATE "pg_catalog"."default",
  "is_enabled" bool DEFAULT true,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "callback_url" varchar(500) COLLATE "pg_catalog"."default",
  "enable_daily_update" bool DEFAULT false
)
;
COMMENT ON COLUMN "public"."gee_apps"."app_id" IS '应用ID';
COMMENT ON COLUMN "public"."gee_apps"."app_name" IS '应用名称';
COMMENT ON COLUMN "public"."gee_apps"."app_key" IS 'API密钥';
COMMENT ON COLUMN "public"."gee_apps"."description" IS '应用描述';
COMMENT ON COLUMN "public"."gee_apps"."is_enabled" IS '是否启用';
COMMENT ON COLUMN "public"."gee_apps"."callback_url" IS '回调地址';
COMMENT ON COLUMN "public"."gee_apps"."enable_daily_update" IS '是否启用每日自动更新';
COMMENT ON TABLE "public"."gee_apps" IS 'GEE应用管理表';

-- ----------------------------
-- Table structure for gee_cache_stats
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_cache_stats";
CREATE TABLE "public"."gee_cache_stats" (
  "stat_id" int4 NOT NULL DEFAULT nextval('gee_cache_stats_stat_id_seq'::regclass),
  "stat_date" date NOT NULL,
  "total_tiles" int4 DEFAULT 0,
  "active_tiles" int4 DEFAULT 0,
  "expired_tiles" int4 DEFAULT 0,
  "total_size_bytes" int8 DEFAULT 0,
  "total_accesses" int4 DEFAULT 0,
  "cache_hit_count" int4 DEFAULT 0,
  "cache_miss_count" int4 DEFAULT 0,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON TABLE "public"."gee_cache_stats" IS 'GEE缓存统计表';

-- ----------------------------
-- Table structure for gee_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_config";
CREATE TABLE "public"."gee_config" (
  "config_id" int4 NOT NULL DEFAULT nextval('gee_config_config_id_seq'::regclass),
  "config_key" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "config_value" text COLLATE "pg_catalog"."default",
  "config_type" varchar(20) COLLATE "pg_catalog"."default" DEFAULT 'string'::character varying,
  "config_group" varchar(50) COLLATE "pg_catalog"."default" DEFAULT 'system'::character varying,
  "description" varchar(500) COLLATE "pg_catalog"."default",
  "is_encrypted" bool DEFAULT false,
  "is_enabled" bool DEFAULT true,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" varchar(64) COLLATE "pg_catalog"."default",
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by" varchar(64) COLLATE "pg_catalog"."default",
  "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."gee_config"."config_id" IS '配置ID';
COMMENT ON COLUMN "public"."gee_config"."config_key" IS '配置键（唯一）';
COMMENT ON COLUMN "public"."gee_config"."config_value" IS '配置值';
COMMENT ON COLUMN "public"."gee_config"."config_type" IS '配置类型: string/int/float/bool/json';
COMMENT ON COLUMN "public"."gee_config"."config_group" IS '配置分组: gee/storage/api/tile';
COMMENT ON COLUMN "public"."gee_config"."description" IS '配置说明';
COMMENT ON COLUMN "public"."gee_config"."is_encrypted" IS '是否加密存储（敏感信息）';
COMMENT ON COLUMN "public"."gee_config"."is_enabled" IS '是否启用';
COMMENT ON COLUMN "public"."gee_config"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."gee_config"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."gee_config"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."gee_config"."updated_by" IS '更新人';
COMMENT ON COLUMN "public"."gee_config"."remark" IS '备注';
COMMENT ON TABLE "public"."gee_config" IS 'GEE系统配置表';

-- ----------------------------
-- Table structure for gee_crop_types
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_crop_types";
CREATE TABLE "public"."gee_crop_types" (
  "crop_id" int4 NOT NULL DEFAULT nextval('gee_crop_types_crop_id_seq'::regclass),
  "crop_code" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "crop_name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "default_start_date" varchar(10) COLLATE "pg_catalog"."default",
  "default_end_date" varchar(10) COLLATE "pg_catalog"."default",
  "description" varchar(500) COLLATE "pg_catalog"."default",
  "is_enabled" bool DEFAULT true,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."gee_crop_types"."crop_code" IS '作物代码（如：corn, rice, wheat）';
COMMENT ON COLUMN "public"."gee_crop_types"."default_start_date" IS '默认监测开始日期（格式：MM-DD）';
COMMENT ON COLUMN "public"."gee_crop_types"."default_end_date" IS '默认监测结束日期（格式：MM-DD）';
COMMENT ON TABLE "public"."gee_crop_types" IS '作物类型配置表';

-- ----------------------------
-- Table structure for gee_custom_regions
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_custom_regions";
CREATE TABLE "public"."gee_custom_regions" (
  "region_id" int4 NOT NULL DEFAULT nextval('gee_custom_regions_region_id_seq'::regclass),
  "region_name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "geometry" text COLLATE "pg_catalog"."default" NOT NULL,
  "buffer_km" numeric(10,2) DEFAULT 5.00,
  "priority" int4 DEFAULT 0,
  "description" text COLLATE "pg_catalog"."default",
  "created_by" varchar(50) COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "is_active" bool DEFAULT true
)
;
COMMENT ON COLUMN "public"."gee_custom_regions"."region_id" IS '区域ID';
COMMENT ON COLUMN "public"."gee_custom_regions"."region_name" IS '区域名称';
COMMENT ON COLUMN "public"."gee_custom_regions"."geometry" IS '几何信息(GeoJSON)';
COMMENT ON COLUMN "public"."gee_custom_regions"."buffer_km" IS '缓冲距离(公里)';
COMMENT ON COLUMN "public"."gee_custom_regions"."priority" IS '优先级(数字越大优先级越高)';
COMMENT ON COLUMN "public"."gee_custom_regions"."description" IS '描述';
COMMENT ON COLUMN "public"."gee_custom_regions"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."gee_custom_regions"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."gee_custom_regions"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."gee_custom_regions"."is_active" IS '是否启用';
COMMENT ON TABLE "public"."gee_custom_regions" IS 'GEE自定义预存区域表';

-- ----------------------------
-- Table structure for gee_grade_statistics
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_grade_statistics";
CREATE TABLE "public"."gee_grade_statistics" (
  "stat_id" int4 NOT NULL DEFAULT nextval('gee_grade_statistics_stat_id_seq'::regclass),
  "prediction_id" int4 NOT NULL,
  "task_id" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "model_code" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "grade_level" int4 NOT NULL,
  "grade_label" varchar(50) COLLATE "pg_catalog"."default",
  "grade_color" varchar(20) COLLATE "pg_catalog"."default",
  "proportion" numeric(5,4),
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON TABLE "public"."gee_grade_statistics" IS 'GEE模型分级统计表';

-- ----------------------------
-- Table structure for gee_model_predictions
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_model_predictions";
CREATE TABLE "public"."gee_model_predictions" (
  "prediction_id" int4 NOT NULL DEFAULT nextval('gee_model_predictions_prediction_id_seq'::regclass),
  "task_id" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "model_code" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "model_name" varchar(100) COLLATE "pg_catalog"."default",
  "success" bool DEFAULT true,
  "result_path" varchar(500) COLLATE "pg_catalog"."default",
  "visualization_image" varchar(500) COLLATE "pg_catalog"."default",
  "visualization_tif" varchar(500) COLLATE "pg_catalog"."default",
  "visualization_success" bool,
  "grade_colors" text COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."gee_model_predictions"."grade_colors" IS '分级颜色统计(JSON格式)';
COMMENT ON TABLE "public"."gee_model_predictions" IS 'GEE模型预测详情表';

-- ----------------------------
-- Table structure for gee_optimization_result
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_optimization_result";
CREATE TABLE "public"."gee_optimization_result" (
  "id" int8 NOT NULL DEFAULT nextval('gee_optimization_result_id_seq'::regclass),
  "calculation_date" date NOT NULL,
  "buffer_km" numeric(5,2) NOT NULL DEFAULT 5.0,
  "include_custom_regions" bool DEFAULT true,
  "total_regions" int4 DEFAULT 0,
  "original_plot_count" int4 DEFAULT 0,
  "optimized_region_count" int4 DEFAULT 0,
  "custom_region_count" int4 DEFAULT 0,
  "optimization_rate" numeric(5,2) DEFAULT 0,
  "regions_data" jsonb,
  "status" varchar(20) COLLATE "pg_catalog"."default" DEFAULT 'calculated'::character varying,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" varchar(64) COLLATE "pg_catalog"."default",
  "remark" text COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."gee_optimization_result"."id" IS '主键ID';
COMMENT ON COLUMN "public"."gee_optimization_result"."calculation_date" IS '计算日期';
COMMENT ON COLUMN "public"."gee_optimization_result"."buffer_km" IS '缓冲区大小(km)';
COMMENT ON COLUMN "public"."gee_optimization_result"."include_custom_regions" IS '是否包含自定义区域';
COMMENT ON COLUMN "public"."gee_optimization_result"."total_regions" IS '总区域数';
COMMENT ON COLUMN "public"."gee_optimization_result"."original_plot_count" IS '原始地块数';
COMMENT ON COLUMN "public"."gee_optimization_result"."optimized_region_count" IS '优化后区域数';
COMMENT ON COLUMN "public"."gee_optimization_result"."custom_region_count" IS '自定义区域数';
COMMENT ON COLUMN "public"."gee_optimization_result"."optimization_rate" IS '优化率(%)';
COMMENT ON COLUMN "public"."gee_optimization_result"."regions_data" IS '区域详细数据(JSON格式)';
COMMENT ON COLUMN "public"."gee_optimization_result"."status" IS '状态: calculated-已计算, downloading-下载中, downloaded-已下载, failed-失败';
COMMENT ON COLUMN "public"."gee_optimization_result"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."gee_optimization_result"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."gee_optimization_result"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."gee_optimization_result"."remark" IS '备注';
COMMENT ON TABLE "public"."gee_optimization_result" IS 'GEE优化结果历史记录表';

-- ----------------------------
-- Table structure for gee_plot_monitor_logs
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_plot_monitor_logs";
CREATE TABLE "public"."gee_plot_monitor_logs" (
  "log_id" int4 NOT NULL DEFAULT nextval('gee_plot_monitor_logs_log_id_seq'::regclass),
  "plot_id" int4 NOT NULL,
  "action" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "reason" varchar(500) COLLATE "pg_catalog"."default",
  "operator" varchar(64) COLLATE "pg_catalog"."default",
  "old_status" int2,
  "new_status" int2,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."gee_plot_monitor_logs"."action" IS '操作类型：enable/disable/pause_by_region/resume_by_region';
COMMENT ON TABLE "public"."gee_plot_monitor_logs" IS '地块监测状态变更日志';

-- ----------------------------
-- Table structure for gee_plots
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_plots";
CREATE TABLE "public"."gee_plots" (
  "plot_id" int4 NOT NULL DEFAULT nextval('gee_plots_plot_id_seq'::regclass),
  "app_id" int4 NOT NULL,
  "plot_name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "geometry" text COLLATE "pg_catalog"."default" NOT NULL,
  "description" varchar(500) COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "adcode" varchar(20) COLLATE "pg_catalog"."default",
  "province" varchar(50) COLLATE "pg_catalog"."default",
  "city" varchar(50) COLLATE "pg_catalog"."default",
  "district" varchar(50) COLLATE "pg_catalog"."default",
  "crop_type" varchar(50) COLLATE "pg_catalog"."default",
  "monitor_status" int2 DEFAULT 1,
  "monitor_start_date" varchar(10) COLLATE "pg_catalog"."default",
  "monitor_end_date" varchar(10) COLLATE "pg_catalog"."default",
  "auto_update" bool DEFAULT true,
  "update_frequency" varchar(20) COLLATE "pg_catalog"."default" DEFAULT 'daily'::character varying
)
;
COMMENT ON COLUMN "public"."gee_plots"."plot_id" IS '地块ID';
COMMENT ON COLUMN "public"."gee_plots"."app_id" IS '关联应用ID';
COMMENT ON COLUMN "public"."gee_plots"."plot_name" IS '地块名称';
COMMENT ON COLUMN "public"."gee_plots"."geometry" IS '地块几何信息(GeoJSON)';
COMMENT ON COLUMN "public"."gee_plots"."description" IS '地块描述';
COMMENT ON COLUMN "public"."gee_plots"."adcode" IS '行政区划代码（如：410100）';
COMMENT ON COLUMN "public"."gee_plots"."province" IS '省份名称';
COMMENT ON COLUMN "public"."gee_plots"."city" IS '城市名称';
COMMENT ON COLUMN "public"."gee_plots"."district" IS '区县名称';
COMMENT ON COLUMN "public"."gee_plots"."crop_type" IS '作物类型（如：corn, rice, wheat）';
COMMENT ON COLUMN "public"."gee_plots"."monitor_status" IS '监测状态：1=开启，0=关闭';
COMMENT ON COLUMN "public"."gee_plots"."monitor_start_date" IS '监测开始日期（格式：MM-DD，如：04-01）';
COMMENT ON COLUMN "public"."gee_plots"."monitor_end_date" IS '监测结束日期（格式：MM-DD，如：10-31）';
COMMENT ON COLUMN "public"."gee_plots"."auto_update" IS '是否启用自动更新';
COMMENT ON COLUMN "public"."gee_plots"."update_frequency" IS '更新频率（daily/weekly/monthly）';
COMMENT ON TABLE "public"."gee_plots" IS 'GEE地块管理表';

-- ----------------------------
-- Table structure for gee_prefetch_regions
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_prefetch_regions";
CREATE TABLE "public"."gee_prefetch_regions" (
  "region_id" int4 NOT NULL DEFAULT nextval('gee_prefetch_regions_region_id_seq'::regclass),
  "region_name" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "geometry" text COLLATE "pg_catalog"."default" NOT NULL,
  "description" text COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;

-- ----------------------------
-- Table structure for gee_region_policies
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_region_policies";
CREATE TABLE "public"."gee_region_policies" (
  "policy_id" int4 NOT NULL DEFAULT nextval('gee_region_policies_policy_id_seq'::regclass),
  "adcode" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "policy_type" varchar(20) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'pause'::character varying,
  "reason" varchar(500) COLLATE "pg_catalog"."default",
  "start_time" timestamp(6),
  "end_time" timestamp(6),
  "is_active" bool DEFAULT true,
  "created_by" varchar(64) COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."gee_region_policies"."adcode" IS '行政区代码（如：410000代表河南省，支持前缀匹配）';
COMMENT ON COLUMN "public"."gee_region_policies"."policy_type" IS '策略类型：pause=暂停监测';
COMMENT ON COLUMN "public"."gee_region_policies"."reason" IS '管控原因说明';
COMMENT ON COLUMN "public"."gee_region_policies"."is_active" IS '策略是否激活';
COMMENT ON TABLE "public"."gee_region_policies" IS '行政区域监测管控策略表';

-- ----------------------------
-- Table structure for gee_task_results
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_task_results";
CREATE TABLE "public"."gee_task_results" (
  "result_id" int4 NOT NULL DEFAULT nextval('gee_task_results_result_id_seq'::regclass),
  "task_id" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "file_name" varchar(200) COLLATE "pg_catalog"."default",
  "tif_path" varchar(500) COLLATE "pg_catalog"."default",
  "cache_source" varchar(20) COLLATE "pg_catalog"."default",
  "cache_hit_rate" numeric(5,2),
  "tile_count" int4,
  "tile_ids" text COLLATE "pg_catalog"."default",
  "is_expired" bool DEFAULT false,
  "found_date" date,
  "cloud_cover" numeric(5,2),
  "total_pixels" int4,
  "valid_pixels" int4,
  "geo_bounds" text COLLATE "pg_catalog"."default",
  "processing_time" numeric(10,2),
  "total_predictions" int4,
  "models_total" int4,
  "models_successful" int4,
  "models_failed" int4,
  "successful_models" text COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."gee_task_results"."cache_hit_rate" IS '缓存命中率(0-100)';
COMMENT ON COLUMN "public"."gee_task_results"."processing_time" IS '处理时间(秒)';
COMMENT ON TABLE "public"."gee_task_results" IS 'GEE任务执行结果主表';

-- ----------------------------
-- Table structure for gee_tasks
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_tasks";
CREATE TABLE "public"."gee_tasks" (
  "task_id" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "task_type" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "task_name" varchar(200) COLLATE "pg_catalog"."default",
  "target_date" date NOT NULL,
  "model_type" varchar(50) COLLATE "pg_catalog"."default",
  "aoi_coords" text COLLATE "pg_catalog"."default",
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "progress" int4 DEFAULT 0,
  "cache_hit_rate" numeric(5,2),
  "cache_source" varchar(20) COLLATE "pg_catalog"."default",
  "tile_ids" text COLLATE "pg_catalog"."default",
  "result_path" varchar(500) COLLATE "pg_catalog"."default",
  "error_msg" text COLLATE "pg_catalog"."default",
  "start_time" timestamp(6),
  "end_time" timestamp(6),
  "duration" int4,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dept_id" int8,
  "remark" varchar(500) COLLATE "pg_catalog"."default",
  "app_id" int4,
  "plot_id" int4,
  "task_source" varchar(20) COLLATE "pg_catalog"."default" DEFAULT 'manual'::character varying
)
;
COMMENT ON COLUMN "public"."gee_tasks"."status" IS '状态(0待处理 1处理中 2成功 3失败 4已取消)';
COMMENT ON COLUMN "public"."gee_tasks"."app_id" IS '关联应用ID';
COMMENT ON COLUMN "public"."gee_tasks"."plot_id" IS '关联地块ID';
COMMENT ON COLUMN "public"."gee_tasks"."task_source" IS '任务来源：manual=手动触发, auto=自动更新, batch=批量任务';
COMMENT ON TABLE "public"."gee_tasks" IS 'GEE任务记录表';

-- ----------------------------
-- Table structure for gee_tiles
-- ----------------------------
DROP TABLE IF EXISTS "public"."gee_tiles";
CREATE TABLE "public"."gee_tiles" (
  "tile_id" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "tile_x" int4 NOT NULL,
  "tile_y" int4 NOT NULL,
  "center_lon" numeric(10,6) NOT NULL,
  "center_lat" numeric(10,6) NOT NULL,
  "min_lon" numeric(10,6) NOT NULL,
  "min_lat" numeric(10,6) NOT NULL,
  "max_lon" numeric(10,6) NOT NULL,
  "max_lat" numeric(10,6) NOT NULL,
  "file_path" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "date_acquired" date NOT NULL,
  "cloud_cover" numeric(5,2),
  "file_size" int8,
  "access_count" int4 DEFAULT 0,
  "last_access" timestamp(6),
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "expires_at" timestamp(6) NOT NULL,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."gee_tiles"."tile_id" IS '瓦片ID';
COMMENT ON COLUMN "public"."gee_tiles"."status" IS '状态(0正常 1删除)';
COMMENT ON TABLE "public"."gee_tiles" IS 'GEE瓦片缓存表';

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS "public"."gen_table";
CREATE TABLE "public"."gen_table" (
  "table_id" int8 NOT NULL DEFAULT nextval('gen_table_table_id_seq'::regclass),
  "table_name" varchar(200) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "table_comment" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sub_table_name" varchar(64) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "sub_table_fk_name" varchar(64) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "class_name" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "tpl_category" varchar(200) COLLATE "pg_catalog"."default" DEFAULT 'crud'::character varying,
  "tpl_web_type" varchar(30) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "package_name" varchar(100) COLLATE "pg_catalog"."default",
  "module_name" varchar(30) COLLATE "pg_catalog"."default",
  "business_name" varchar(30) COLLATE "pg_catalog"."default",
  "function_name" varchar(50) COLLATE "pg_catalog"."default",
  "function_author" varchar(50) COLLATE "pg_catalog"."default",
  "gen_type" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "gen_path" varchar(200) COLLATE "pg_catalog"."default" DEFAULT '/'::character varying,
  "options" varchar(1000) COLLATE "pg_catalog"."default",
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."gen_table"."table_id" IS '编号';
COMMENT ON COLUMN "public"."gen_table"."table_name" IS '表名称';
COMMENT ON COLUMN "public"."gen_table"."table_comment" IS '表描述';
COMMENT ON COLUMN "public"."gen_table"."sub_table_name" IS '关联子表的表名';
COMMENT ON COLUMN "public"."gen_table"."sub_table_fk_name" IS '子表关联的外键名';
COMMENT ON COLUMN "public"."gen_table"."class_name" IS '实体类名称';
COMMENT ON COLUMN "public"."gen_table"."tpl_category" IS '使用的模板（crud单表操作 tree树表操作）';
COMMENT ON COLUMN "public"."gen_table"."tpl_web_type" IS '前端模板类型（element-ui模版 element-plus模版）';
COMMENT ON COLUMN "public"."gen_table"."package_name" IS '生成包路径';
COMMENT ON COLUMN "public"."gen_table"."module_name" IS '生成模块名';
COMMENT ON COLUMN "public"."gen_table"."business_name" IS '生成业务名';
COMMENT ON COLUMN "public"."gen_table"."function_name" IS '生成功能名';
COMMENT ON COLUMN "public"."gen_table"."function_author" IS '生成功能作者';
COMMENT ON COLUMN "public"."gen_table"."gen_type" IS '生成代码方式（0zip压缩包 1自定义路径）';
COMMENT ON COLUMN "public"."gen_table"."gen_path" IS '生成路径（不填默认项目路径）';
COMMENT ON COLUMN "public"."gen_table"."options" IS '其它生成选项';
COMMENT ON COLUMN "public"."gen_table"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."gen_table"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."gen_table"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."gen_table"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."gen_table"."remark" IS '备注';
COMMENT ON TABLE "public"."gen_table" IS '代码生成业务表';

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS "public"."gen_table_column";
CREATE TABLE "public"."gen_table_column" (
  "column_id" int8 NOT NULL DEFAULT nextval('gen_table_column_column_id_seq'::regclass),
  "table_id" int8,
  "column_name" varchar(200) COLLATE "pg_catalog"."default",
  "column_comment" varchar(500) COLLATE "pg_catalog"."default",
  "column_type" varchar(100) COLLATE "pg_catalog"."default",
  "python_type" varchar(500) COLLATE "pg_catalog"."default",
  "python_field" varchar(200) COLLATE "pg_catalog"."default",
  "is_pk" char(1) COLLATE "pg_catalog"."default",
  "is_increment" char(1) COLLATE "pg_catalog"."default",
  "is_required" char(1) COLLATE "pg_catalog"."default",
  "is_unique" char(1) COLLATE "pg_catalog"."default",
  "is_insert" char(1) COLLATE "pg_catalog"."default",
  "is_edit" char(1) COLLATE "pg_catalog"."default",
  "is_list" char(1) COLLATE "pg_catalog"."default",
  "is_query" char(1) COLLATE "pg_catalog"."default",
  "query_type" varchar(200) COLLATE "pg_catalog"."default" DEFAULT 'EQ'::character varying,
  "html_type" varchar(200) COLLATE "pg_catalog"."default",
  "dict_type" varchar(200) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sort" int4,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."gen_table_column"."column_id" IS '编号';
COMMENT ON COLUMN "public"."gen_table_column"."table_id" IS '归属表编号';
COMMENT ON COLUMN "public"."gen_table_column"."column_name" IS '列名称';
COMMENT ON COLUMN "public"."gen_table_column"."column_comment" IS '列描述';
COMMENT ON COLUMN "public"."gen_table_column"."column_type" IS '列类型';
COMMENT ON COLUMN "public"."gen_table_column"."python_type" IS 'PYTHON类型';
COMMENT ON COLUMN "public"."gen_table_column"."python_field" IS 'PYTHON字段名';
COMMENT ON COLUMN "public"."gen_table_column"."is_pk" IS '是否主键（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_increment" IS '是否自增（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_required" IS '是否必填（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_unique" IS '是否唯一（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_insert" IS '是否为插入字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_edit" IS '是否编辑字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_list" IS '是否列表字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_query" IS '是否查询字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."query_type" IS '查询方式（等于、不等于、大于、小于、范围）';
COMMENT ON COLUMN "public"."gen_table_column"."html_type" IS '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）';
COMMENT ON COLUMN "public"."gen_table_column"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."gen_table_column"."sort" IS '排序';
COMMENT ON COLUMN "public"."gen_table_column"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."gen_table_column"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."gen_table_column"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."gen_table_column"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."gen_table_column" IS '代码生成业务表字段';

-- ----------------------------
-- Table structure for lease_transfer_item
-- ----------------------------
DROP TABLE IF EXISTS "public"."lease_transfer_item";
CREATE TABLE "public"."lease_transfer_item" (
  "id" int8 NOT NULL DEFAULT nextval('lease_transfer_item_id_seq'::regclass),
  "transfer_lease_id" int8 NOT NULL,
  "bid_number" varchar(50) COLLATE "pg_catalog"."default",
  "item_name" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "starting_price" numeric(15,2) NOT NULL,
  "price_increment" numeric(15,2) NOT NULL,
  "item_images" text COLLATE "pg_catalog"."default",
  "current_price" numeric(15,2),
  "original_price" numeric(15,2),
  "plot_id" varchar(50) COLLATE "pg_catalog"."default",
  "plot_area" numeric(10,2),
  "deposit" numeric(15,2),
  "applicants_count" int4 DEFAULT 0,
  "deposit_paid_count" int4 DEFAULT 0,
  "lease_term" int2 NOT NULL,
  "auction_start_time" timestamp(6) NOT NULL,
  "auction_end_time" timestamp(6) NOT NULL,
  "application_start_time" timestamp(6) NOT NULL,
  "application_end_time" timestamp(6) NOT NULL,
  "item_status" varchar(20) COLLATE "pg_catalog"."default",
  "business_status" varchar(20) COLLATE "pg_catalog"."default",
  "division" varchar(50) COLLATE "pg_catalog"."default",
  "regiment" varchar(50) COLLATE "pg_catalog"."default",
  "company" varchar(50) COLLATE "pg_catalog"."default",
  "item_type" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "create_by" int8 NOT NULL,
  "create_dept" int8 NOT NULL,
  "create_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "update_by" int8,
  "update_time" timestamp(6),
  "tenant_id" varchar(20) COLLATE "pg_catalog"."default",
  "notice_type" varchar(20) COLLATE "pg_catalog"."default",
  "string1" varchar(255) COLLATE "pg_catalog"."default",
  "string2" varchar(255) COLLATE "pg_catalog"."default",
  "string3" varchar(255) COLLATE "pg_catalog"."default",
  "string4" varchar(255) COLLATE "pg_catalog"."default",
  "string5" varchar(255) COLLATE "pg_catalog"."default",
  "string6" varchar(255) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."lease_transfer_item"."id" IS '主键ID';
COMMENT ON COLUMN "public"."lease_transfer_item"."transfer_lease_id" IS '关联转让租赁公告ID';
COMMENT ON COLUMN "public"."lease_transfer_item"."bid_number" IS '招标编号';
COMMENT ON COLUMN "public"."lease_transfer_item"."item_name" IS '拍品名称';
COMMENT ON COLUMN "public"."lease_transfer_item"."starting_price" IS '起拍价';
COMMENT ON COLUMN "public"."lease_transfer_item"."price_increment" IS '加价幅度';
COMMENT ON COLUMN "public"."lease_transfer_item"."item_images" IS '拍品图片URL数组';
COMMENT ON COLUMN "public"."lease_transfer_item"."current_price" IS '当前价格';
COMMENT ON COLUMN "public"."lease_transfer_item"."original_price" IS '原始价格';
COMMENT ON COLUMN "public"."lease_transfer_item"."plot_id" IS '地块ID';
COMMENT ON COLUMN "public"."lease_transfer_item"."plot_area" IS '地块面积(亩)';
COMMENT ON COLUMN "public"."lease_transfer_item"."deposit" IS '保证金';
COMMENT ON COLUMN "public"."lease_transfer_item"."applicants_count" IS '报名人数';
COMMENT ON COLUMN "public"."lease_transfer_item"."deposit_paid_count" IS '保证金缴纳人数';
COMMENT ON COLUMN "public"."lease_transfer_item"."lease_term" IS '租赁年限(年)';
COMMENT ON COLUMN "public"."lease_transfer_item"."auction_start_time" IS '竞拍开始时间';
COMMENT ON COLUMN "public"."lease_transfer_item"."auction_end_time" IS '竞拍结束时间';
COMMENT ON COLUMN "public"."lease_transfer_item"."application_start_time" IS '报名开始时间';
COMMENT ON COLUMN "public"."lease_transfer_item"."application_end_time" IS '报名结束时间';
COMMENT ON COLUMN "public"."lease_transfer_item"."item_status" IS '拍品状态';
COMMENT ON COLUMN "public"."lease_transfer_item"."business_status" IS '业务状态';
COMMENT ON COLUMN "public"."lease_transfer_item"."division" IS '师';
COMMENT ON COLUMN "public"."lease_transfer_item"."regiment" IS '团';
COMMENT ON COLUMN "public"."lease_transfer_item"."company" IS '连';
COMMENT ON COLUMN "public"."lease_transfer_item"."item_type" IS '拍品类型';
COMMENT ON COLUMN "public"."lease_transfer_item"."create_by" IS '创建者ID';
COMMENT ON COLUMN "public"."lease_transfer_item"."create_dept" IS '创建部门ID';
COMMENT ON COLUMN "public"."lease_transfer_item"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."lease_transfer_item"."update_by" IS '更新者ID';
COMMENT ON COLUMN "public"."lease_transfer_item"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."lease_transfer_item"."tenant_id" IS '租户ID';
COMMENT ON TABLE "public"."lease_transfer_item" IS '租赁转让物品表';

-- ----------------------------
-- Table structure for spatial_ref_sys
-- ----------------------------
DROP TABLE IF EXISTS "public"."spatial_ref_sys";
CREATE TABLE "public"."spatial_ref_sys" (
  "srid" int4 NOT NULL,
  "auth_name" varchar(256) COLLATE "pg_catalog"."default",
  "auth_srid" int4,
  "srtext" varchar(2048) COLLATE "pg_catalog"."default",
  "proj4text" varchar(2048) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_config";
CREATE TABLE "public"."sys_config" (
  "config_id" int4 NOT NULL DEFAULT nextval('sys_config_config_id_seq'::regclass),
  "config_name" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "config_key" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "config_value" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "config_type" char(1) COLLATE "pg_catalog"."default" DEFAULT 'N'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_config"."config_id" IS '参数主键';
COMMENT ON COLUMN "public"."sys_config"."config_name" IS '参数名称';
COMMENT ON COLUMN "public"."sys_config"."config_key" IS '参数键名';
COMMENT ON COLUMN "public"."sys_config"."config_value" IS '参数键值';
COMMENT ON COLUMN "public"."sys_config"."config_type" IS '系统内置（Y是 N否）';
COMMENT ON COLUMN "public"."sys_config"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_config"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_config"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_config"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_config"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_config" IS '参数配置表';

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dept";
CREATE TABLE "public"."sys_dept" (
  "dept_id" int8 NOT NULL DEFAULT nextval('sys_dept_dept_id_seq'::regclass),
  "parent_id" int8 DEFAULT 0,
  "ancestors" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dept_name" varchar(30) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "order_num" int4 DEFAULT 0,
  "leader" varchar(20) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "phone" varchar(11) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "email" varchar(50) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."sys_dept"."dept_id" IS '部门id';
COMMENT ON COLUMN "public"."sys_dept"."parent_id" IS '父部门id';
COMMENT ON COLUMN "public"."sys_dept"."ancestors" IS '祖级列表';
COMMENT ON COLUMN "public"."sys_dept"."dept_name" IS '部门名称';
COMMENT ON COLUMN "public"."sys_dept"."order_num" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_dept"."leader" IS '负责人';
COMMENT ON COLUMN "public"."sys_dept"."phone" IS '联系电话';
COMMENT ON COLUMN "public"."sys_dept"."email" IS '邮箱';
COMMENT ON COLUMN "public"."sys_dept"."status" IS '部门状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dept"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_dept"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dept"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dept"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dept"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."sys_dept" IS '部门表';

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_data";
CREATE TABLE "public"."sys_dict_data" (
  "dict_code" int8 NOT NULL DEFAULT nextval('sys_dict_data_dict_code_seq'::regclass),
  "dict_sort" int4 DEFAULT 0,
  "dict_label" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dict_value" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dict_type" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "css_class" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "list_class" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "is_default" char(1) COLLATE "pg_catalog"."default" DEFAULT 'N'::bpchar,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_dict_data"."dict_code" IS '字典编码';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_sort" IS '字典排序';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_label" IS '字典标签';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_value" IS '字典键值';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."sys_dict_data"."css_class" IS '样式属性（其他样式扩展）';
COMMENT ON COLUMN "public"."sys_dict_data"."list_class" IS '表格回显样式';
COMMENT ON COLUMN "public"."sys_dict_data"."is_default" IS '是否默认（Y是 N否）';
COMMENT ON COLUMN "public"."sys_dict_data"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dict_data"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dict_data"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_data"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dict_data"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_data"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_dict_data" IS '字典数据表';

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_type";
CREATE TABLE "public"."sys_dict_type" (
  "dict_id" int8 NOT NULL DEFAULT nextval('sys_dict_type_dict_id_seq'::regclass),
  "dict_name" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dict_type" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_dict_type"."dict_id" IS '字典主键';
COMMENT ON COLUMN "public"."sys_dict_type"."dict_name" IS '字典名称';
COMMENT ON COLUMN "public"."sys_dict_type"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."sys_dict_type"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dict_type"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dict_type"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_type"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dict_type"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_type"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_dict_type" IS '字典类型表';

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_job";
CREATE TABLE "public"."sys_job" (
  "job_id" int8 NOT NULL DEFAULT nextval('sys_job_job_id_seq'::regclass),
  "job_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying,
  "job_group" varchar(64) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'default'::character varying,
  "job_executor" varchar(64) COLLATE "pg_catalog"."default" DEFAULT 'default'::character varying,
  "invoke_target" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "job_args" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_kwargs" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "cron_expression" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "misfire_policy" varchar(20) COLLATE "pg_catalog"."default" DEFAULT '3'::character varying,
  "concurrent" char(1) COLLATE "pg_catalog"."default" DEFAULT '1'::bpchar,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying
)
;
COMMENT ON COLUMN "public"."sys_job"."job_id" IS '任务ID';
COMMENT ON COLUMN "public"."sys_job"."job_name" IS '任务名称';
COMMENT ON COLUMN "public"."sys_job"."job_group" IS '任务组名';
COMMENT ON COLUMN "public"."sys_job"."job_executor" IS '任务执行器';
COMMENT ON COLUMN "public"."sys_job"."invoke_target" IS '调用目标字符串';
COMMENT ON COLUMN "public"."sys_job"."job_args" IS '位置参数';
COMMENT ON COLUMN "public"."sys_job"."job_kwargs" IS '关键字参数';
COMMENT ON COLUMN "public"."sys_job"."cron_expression" IS 'cron执行表达式';
COMMENT ON COLUMN "public"."sys_job"."misfire_policy" IS '计划执行错误策略（1立即执行 2执行一次 3放弃执行）';
COMMENT ON COLUMN "public"."sys_job"."concurrent" IS '是否并发执行（0允许 1禁止）';
COMMENT ON COLUMN "public"."sys_job"."status" IS '状态（0正常 1暂停）';
COMMENT ON COLUMN "public"."sys_job"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_job"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_job"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_job"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_job"."remark" IS '备注信息';
COMMENT ON TABLE "public"."sys_job" IS '定时任务调度表';

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_job_log";
CREATE TABLE "public"."sys_job_log" (
  "job_log_id" int8 NOT NULL DEFAULT nextval('sys_job_log_job_log_id_seq'::regclass),
  "job_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "job_group" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "job_executor" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "invoke_target" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "job_args" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_kwargs" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_trigger" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_message" varchar(500) COLLATE "pg_catalog"."default",
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "exception_info" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."sys_job_log"."job_log_id" IS '任务日志ID';
COMMENT ON COLUMN "public"."sys_job_log"."job_name" IS '任务名称';
COMMENT ON COLUMN "public"."sys_job_log"."job_group" IS '任务组名';
COMMENT ON COLUMN "public"."sys_job_log"."job_executor" IS '任务执行器';
COMMENT ON COLUMN "public"."sys_job_log"."invoke_target" IS '调用目标字符串';
COMMENT ON COLUMN "public"."sys_job_log"."job_args" IS '位置参数';
COMMENT ON COLUMN "public"."sys_job_log"."job_kwargs" IS '关键字参数';
COMMENT ON COLUMN "public"."sys_job_log"."job_trigger" IS '任务触发器';
COMMENT ON COLUMN "public"."sys_job_log"."job_message" IS '日志信息';
COMMENT ON COLUMN "public"."sys_job_log"."status" IS '执行状态（0正常 1失败）';
COMMENT ON COLUMN "public"."sys_job_log"."exception_info" IS '异常信息';
COMMENT ON COLUMN "public"."sys_job_log"."create_time" IS '创建时间';
COMMENT ON TABLE "public"."sys_job_log" IS '定时任务调度日志表';

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_logininfor";
CREATE TABLE "public"."sys_logininfor" (
  "info_id" int8 NOT NULL DEFAULT nextval('sys_logininfor_info_id_seq'::regclass),
  "user_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "ipaddr" varchar(128) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "login_location" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "browser" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "os" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "msg" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "login_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."sys_logininfor"."info_id" IS '访问ID';
COMMENT ON COLUMN "public"."sys_logininfor"."user_name" IS '用户账号';
COMMENT ON COLUMN "public"."sys_logininfor"."ipaddr" IS '登录IP地址';
COMMENT ON COLUMN "public"."sys_logininfor"."login_location" IS '登录地点';
COMMENT ON COLUMN "public"."sys_logininfor"."browser" IS '浏览器类型';
COMMENT ON COLUMN "public"."sys_logininfor"."os" IS '操作系统';
COMMENT ON COLUMN "public"."sys_logininfor"."status" IS '登录状态（0成功 1失败）';
COMMENT ON COLUMN "public"."sys_logininfor"."msg" IS '提示消息';
COMMENT ON COLUMN "public"."sys_logininfor"."login_time" IS '访问时间';
COMMENT ON TABLE "public"."sys_logininfor" IS '系统访问记录';

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_menu";
CREATE TABLE "public"."sys_menu" (
  "menu_id" int8 NOT NULL DEFAULT nextval('sys_menu_menu_id_seq'::regclass),
  "menu_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "parent_id" int8 DEFAULT 0,
  "order_num" int4 DEFAULT 0,
  "path" varchar(200) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "component" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "query" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "route_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "is_frame" int4 DEFAULT 1,
  "is_cache" int4 DEFAULT 0,
  "menu_type" char(1) COLLATE "pg_catalog"."default" DEFAULT ''::bpchar,
  "visible" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "perms" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "icon" varchar(100) COLLATE "pg_catalog"."default" DEFAULT '#'::character varying,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying
)
;
COMMENT ON COLUMN "public"."sys_menu"."menu_id" IS '菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."menu_name" IS '菜单名称';
COMMENT ON COLUMN "public"."sys_menu"."parent_id" IS '父菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."order_num" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_menu"."path" IS '路由地址';
COMMENT ON COLUMN "public"."sys_menu"."component" IS '组件路径';
COMMENT ON COLUMN "public"."sys_menu"."query" IS '路由参数';
COMMENT ON COLUMN "public"."sys_menu"."route_name" IS '路由名称';
COMMENT ON COLUMN "public"."sys_menu"."is_frame" IS '是否为外链（0是 1否）';
COMMENT ON COLUMN "public"."sys_menu"."is_cache" IS '是否缓存（0缓存 1不缓存）';
COMMENT ON COLUMN "public"."sys_menu"."menu_type" IS '菜单类型（M目录 C菜单 F按钮）';
COMMENT ON COLUMN "public"."sys_menu"."visible" IS '菜单状态（0显示 1隐藏）';
COMMENT ON COLUMN "public"."sys_menu"."status" IS '菜单状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_menu"."perms" IS '权限标识';
COMMENT ON COLUMN "public"."sys_menu"."icon" IS '菜单图标';
COMMENT ON COLUMN "public"."sys_menu"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_menu"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_menu"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_menu"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_menu"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_menu" IS '菜单权限表';

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_notice";
CREATE TABLE "public"."sys_notice" (
  "notice_id" int4 NOT NULL DEFAULT nextval('sys_notice_notice_id_seq'::regclass),
  "notice_title" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "notice_type" char(1) COLLATE "pg_catalog"."default" NOT NULL,
  "notice_content" bytea,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_notice"."notice_id" IS '公告ID';
COMMENT ON COLUMN "public"."sys_notice"."notice_title" IS '公告标题';
COMMENT ON COLUMN "public"."sys_notice"."notice_type" IS '公告类型（1通知 2公告）';
COMMENT ON COLUMN "public"."sys_notice"."notice_content" IS '公告内容';
COMMENT ON COLUMN "public"."sys_notice"."status" IS '公告状态（0正常 1关闭）';
COMMENT ON COLUMN "public"."sys_notice"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_notice"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_notice"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_notice"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_notice"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_notice" IS '通知公告表';

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_oper_log";
CREATE TABLE "public"."sys_oper_log" (
  "oper_id" int8 NOT NULL DEFAULT nextval('sys_oper_log_oper_id_seq'::regclass),
  "title" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "business_type" int4 DEFAULT 0,
  "method" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "request_method" varchar(10) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "operator_type" int4 DEFAULT 0,
  "oper_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dept_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_url" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_ip" varchar(128) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_location" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_param" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "json_result" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" int4 DEFAULT 0,
  "error_msg" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_time" timestamp(0),
  "cost_time" int8 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_oper_log"."oper_id" IS '日志主键';
COMMENT ON COLUMN "public"."sys_oper_log"."title" IS '模块标题';
COMMENT ON COLUMN "public"."sys_oper_log"."business_type" IS '业务类型（0其它 1新增 2修改 3删除）';
COMMENT ON COLUMN "public"."sys_oper_log"."method" IS '方法名称';
COMMENT ON COLUMN "public"."sys_oper_log"."request_method" IS '请求方式';
COMMENT ON COLUMN "public"."sys_oper_log"."operator_type" IS '操作类别（0其它 1后台用户 2手机端用户）';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_name" IS '操作人员';
COMMENT ON COLUMN "public"."sys_oper_log"."dept_name" IS '部门名称';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_url" IS '请求URL';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_ip" IS '主机地址';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_location" IS '操作地点';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_param" IS '请求参数';
COMMENT ON COLUMN "public"."sys_oper_log"."json_result" IS '返回参数';
COMMENT ON COLUMN "public"."sys_oper_log"."status" IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN "public"."sys_oper_log"."error_msg" IS '错误消息';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_time" IS '操作时间';
COMMENT ON COLUMN "public"."sys_oper_log"."cost_time" IS '消耗时间';
COMMENT ON TABLE "public"."sys_oper_log" IS '操作日志记录';

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_post";
CREATE TABLE "public"."sys_post" (
  "post_id" int8 NOT NULL DEFAULT nextval('sys_post_post_id_seq'::regclass),
  "post_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "post_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "post_sort" int4 NOT NULL,
  "status" char(1) COLLATE "pg_catalog"."default" NOT NULL,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_post"."post_id" IS '岗位ID';
COMMENT ON COLUMN "public"."sys_post"."post_code" IS '岗位编码';
COMMENT ON COLUMN "public"."sys_post"."post_name" IS '岗位名称';
COMMENT ON COLUMN "public"."sys_post"."post_sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_post"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_post"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_post"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_post"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_post"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_post"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_post" IS '岗位信息表';

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role";
CREATE TABLE "public"."sys_role" (
  "role_id" int8 NOT NULL DEFAULT nextval('sys_role_role_id_seq'::regclass),
  "role_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "role_key" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "role_sort" int4 NOT NULL,
  "data_scope" char(1) COLLATE "pg_catalog"."default" DEFAULT '1'::bpchar,
  "menu_check_strictly" int2 DEFAULT 1,
  "dept_check_strictly" int2 DEFAULT 1,
  "status" char(1) COLLATE "pg_catalog"."default" NOT NULL,
  "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_role"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role"."role_name" IS '角色名称';
COMMENT ON COLUMN "public"."sys_role"."role_key" IS '角色权限字符串';
COMMENT ON COLUMN "public"."sys_role"."role_sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_role"."data_scope" IS '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）';
COMMENT ON COLUMN "public"."sys_role"."menu_check_strictly" IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN "public"."sys_role"."dept_check_strictly" IS '部门树选择项是否关联显示';
COMMENT ON COLUMN "public"."sys_role"."status" IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_role"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_role"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_role"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_role"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_role"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_role"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_role" IS '角色信息表';

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_dept";
CREATE TABLE "public"."sys_role_dept" (
  "role_id" int8 NOT NULL,
  "dept_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_dept"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_dept"."dept_id" IS '部门ID';
COMMENT ON TABLE "public"."sys_role_dept" IS '角色和部门关联表';

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_menu";
CREATE TABLE "public"."sys_role_menu" (
  "role_id" int8 NOT NULL,
  "menu_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_menu"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_menu"."menu_id" IS '菜单ID';
COMMENT ON TABLE "public"."sys_role_menu" IS '角色和菜单关联表';

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user";
CREATE TABLE "public"."sys_user" (
  "user_id" int8 NOT NULL DEFAULT nextval('sys_user_user_id_seq'::regclass),
  "dept_id" int8,
  "user_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "nick_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "user_type" varchar(2) COLLATE "pg_catalog"."default" DEFAULT '00'::character varying,
  "email" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "phonenumber" varchar(11) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sex" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "avatar" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "password" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "login_ip" varchar(128) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "login_date" timestamp(0),
  "pwd_update_date" timestamp(0),
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_user"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user"."dept_id" IS '部门ID';
COMMENT ON COLUMN "public"."sys_user"."user_name" IS '用户账号';
COMMENT ON COLUMN "public"."sys_user"."nick_name" IS '用户昵称';
COMMENT ON COLUMN "public"."sys_user"."user_type" IS '用户类型（00系统用户）';
COMMENT ON COLUMN "public"."sys_user"."email" IS '用户邮箱';
COMMENT ON COLUMN "public"."sys_user"."phonenumber" IS '手机号码';
COMMENT ON COLUMN "public"."sys_user"."sex" IS '用户性别（0男 1女 2未知）';
COMMENT ON COLUMN "public"."sys_user"."avatar" IS '头像地址';
COMMENT ON COLUMN "public"."sys_user"."password" IS '密码';
COMMENT ON COLUMN "public"."sys_user"."status" IS '帐号状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_user"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_user"."login_ip" IS '最后登录IP';
COMMENT ON COLUMN "public"."sys_user"."login_date" IS '最后登录时间';
COMMENT ON COLUMN "public"."sys_user"."pwd_update_date" IS '密码最后更新时间';
COMMENT ON COLUMN "public"."sys_user"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_user"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_user"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_user"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_user"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_user" IS '用户信息表';

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_post";
CREATE TABLE "public"."sys_user_post" (
  "user_id" int8 NOT NULL,
  "post_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_post"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_post"."post_id" IS '岗位ID';
COMMENT ON TABLE "public"."sys_user_post" IS '用户与岗位关联表';

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_role";
CREATE TABLE "public"."sys_user_role" (
  "user_id" int8 NOT NULL,
  "role_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_role"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_role"."role_id" IS '角色ID';
COMMENT ON TABLE "public"."sys_user_role" IS '用户和角色关联表';

-- ----------------------------
-- Table structure for training_videos
-- ----------------------------
DROP TABLE IF EXISTS "public"."training_videos";
CREATE TABLE "public"."training_videos" (
  "id" int4 NOT NULL DEFAULT nextval('training_videos_id_seq'::regclass),
  "title" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "file_path" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "crops" varchar(500) COLLATE "pg_catalog"."default",
  "mime_type" varchar(100) COLLATE "pg_catalog"."default",
  "create_dept" int8,
  "create_by" int8,
  "create_time" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
  "update_by" int8,
  "update_time" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
  "tenant_id" varchar(50) COLLATE "pg_catalog"."default",
  "view_count" int8 NOT NULL DEFAULT 0
)
;
COMMENT ON COLUMN "public"."training_videos"."id" IS '主键ID，自增唯一标识';
COMMENT ON COLUMN "public"."training_videos"."title" IS '视频标题';
COMMENT ON COLUMN "public"."training_videos"."file_path" IS '视频文件在服务器上的存储路径';
COMMENT ON COLUMN "public"."training_videos"."crops" IS '关联的作物信息（逗号分隔）';
COMMENT ON COLUMN "public"."training_videos"."mime_type" IS '视频文件MIME类型';
COMMENT ON COLUMN "public"."training_videos"."create_dept" IS '创建部门ID';
COMMENT ON COLUMN "public"."training_videos"."create_by" IS '创建者用户ID';
COMMENT ON COLUMN "public"."training_videos"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."training_videos"."update_by" IS '最后更新者用户ID';
COMMENT ON COLUMN "public"."training_videos"."update_time" IS '最后更新时间';
COMMENT ON COLUMN "public"."training_videos"."tenant_id" IS '租户ID（多租户系统使用）';
COMMENT ON COLUMN "public"."training_videos"."view_count" IS '视频播放次数统计';
COMMENT ON TABLE "public"."training_videos" IS '培训视频信息存储表';

-- ----------------------------
-- Function structure for _postgis_deprecate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_deprecate"("oldname" text, "newname" text, "version" text);
CREATE FUNCTION "public"."_postgis_deprecate"("oldname" text, "newname" text, "version" text)
  RETURNS "pg_catalog"."void" AS $BODY$
DECLARE
  curver_text text;
BEGIN
  --
  -- Raises a NOTICE if it was deprecated in this version,
  -- a WARNING if in a previous version (only up to minor version checked)
  --
	curver_text := '3.4.2';
	IF pg_catalog.split_part(curver_text,'.',1)::int > pg_catalog.split_part(version,'.',1)::int OR
	   ( pg_catalog.split_part(curver_text,'.',1) = pg_catalog.split_part(version,'.',1) AND
		 pg_catalog.split_part(curver_text,'.',2) != split_part(version,'.',2) )
	THEN
	  RAISE WARNING '% signature was deprecated in %. Please use %', oldname, version, newname;
	ELSE
	  RAISE DEBUG '% signature was deprecated in %. Please use %', oldname, version, newname;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for _postgis_index_extent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_index_extent"("tbl" regclass, "col" text);
CREATE FUNCTION "public"."_postgis_index_extent"("tbl" regclass, "col" text)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', '_postgis_gserialized_index_extent'
  LANGUAGE c STABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for _postgis_join_selectivity
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_join_selectivity"(regclass, text, regclass, text, text);
CREATE FUNCTION "public"."_postgis_join_selectivity"(regclass, text, regclass, text, text='2'::text)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', '_postgis_gserialized_joinsel'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for _postgis_pgsql_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_pgsql_version"();
CREATE FUNCTION "public"."_postgis_pgsql_version"()
  RETURNS "pg_catalog"."text" AS $BODY$
	SELECT CASE WHEN pg_catalog.split_part(s,'.',1)::integer > 9 THEN pg_catalog.split_part(s,'.',1) || '0'
	ELSE pg_catalog.split_part(s,'.', 1) || pg_catalog.split_part(s,'.', 2) END AS v
	FROM pg_catalog.substring(version(), E'PostgreSQL ([0-9\\.]+)') AS s;
$BODY$
  LANGUAGE sql STABLE
  COST 100;

-- ----------------------------
-- Function structure for _postgis_scripts_pgsql_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_scripts_pgsql_version"();
CREATE FUNCTION "public"."_postgis_scripts_pgsql_version"()
  RETURNS "pg_catalog"."text" AS $BODY$SELECT '160'::text AS version$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for _postgis_selectivity
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_selectivity"("tbl" regclass, "att_name" text, "geom" "public"."geometry", "mode" text);
CREATE FUNCTION "public"."_postgis_selectivity"("tbl" regclass, "att_name" text, "geom" "public"."geometry", "mode" text='2'::text)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', '_postgis_gserialized_sel'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for _postgis_stats
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_postgis_stats"("tbl" regclass, "att_name" text, text);
CREATE FUNCTION "public"."_postgis_stats"("tbl" regclass, "att_name" text, text='2'::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', '_postgis_gserialized_stats'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for _st_3ddfullywithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dfullywithin3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_3ddwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dwithin3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_3dintersects
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_3DIntersects'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_asgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_asgml"(int4, "public"."geometry", int4, int4, text, text);
CREATE FUNCTION "public"."_st_asgml"(int4, "public"."geometry", int4, int4, text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asGML'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for _st_asx3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_asx3d"(int4, "public"."geometry", int4, int4, text);
CREATE FUNCTION "public"."_st_asx3d"(int4, "public"."geometry", int4, int4, text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asX3D'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for _st_bestsrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_bestsrid"("public"."geography");
CREATE FUNCTION "public"."_st_bestsrid"("public"."geography")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'geography_bestsrid'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for _st_bestsrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_bestsrid"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'geography_bestsrid'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for _st_contains
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'contains'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_containsproperly
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'containsproperly'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_coveredby
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'coveredby'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_coveredby
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography");
CREATE FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_coveredby'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_covers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography");
CREATE FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_covers'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_covers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'covers'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_crosses
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'crosses'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_dfullywithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dfullywithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_distancetree
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_distancetree"("public"."geography", "public"."geography", float8, bool);
CREATE FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", float8, bool)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_distance_tree'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_distancetree
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_distancetree"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."float8" AS $BODY$SELECT public._ST_DistanceTree($1, $2, 0.0, true)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for _st_distanceuncached
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_distanceuncached"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."float8" AS $BODY$SELECT public._ST_DistanceUnCached($1, $2, 0.0, true)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for _st_distanceuncached
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_distanceuncached"("public"."geography", "public"."geography", float8, bool);
CREATE FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", float8, bool)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_distance_uncached'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_distanceuncached
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_distanceuncached"("public"."geography", "public"."geography", bool);
CREATE FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", bool)
  RETURNS "pg_catalog"."float8" AS $BODY$SELECT public._ST_DistanceUnCached($1, $2, 0.0, $3)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for _st_dwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" float8, "use_spheroid" bool);
CREATE FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" float8, "use_spheroid" bool=true)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_dwithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_dwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dwithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_dwithinuncached
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_dwithinuncached"("public"."geography", "public"."geography", float8);
CREATE FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", float8)
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT $1 OPERATOR(public.&&) public._ST_Expand($2,$3) AND $2 OPERATOR(public.&&) public._ST_Expand($1,$3) AND public._ST_DWithinUnCached($1, $2, $3, true)$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for _st_dwithinuncached
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_dwithinuncached"("public"."geography", "public"."geography", float8, bool);
CREATE FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", float8, bool)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_dwithin_uncached'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_equals
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_Equals'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_expand"("public"."geography", float8);
CREATE FUNCTION "public"."_st_expand"("public"."geography", float8)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for _st_geomfromgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_geomfromgml"(text, int4);
CREATE FUNCTION "public"."_st_geomfromgml"(text, int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geom_from_gml'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for _st_intersects
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_Intersects'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_linecrossingdirection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry");
CREATE FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'ST_LineCrossingDirection'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_longestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_longestline2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for _st_maxdistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_maxdistance2d_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for _st_orderingequals
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_same'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_overlaps
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_pointoutside
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_pointoutside"("public"."geography");
CREATE FUNCTION "public"."_st_pointoutside"("public"."geography")
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_point_outside'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for _st_sortablehash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_sortablehash"("geom" "public"."geometry");
CREATE FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry")
  RETURNS "pg_catalog"."int8" AS '$libdir/postgis-3', '_ST_SortableHash'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for _st_touches
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'touches'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for _st_voronoi
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" float8, "return_polygons" bool);
CREATE FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry"=NULL::geometry, "tolerance" float8=0.0, "return_polygons" bool=true)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Voronoi'
  LANGUAGE c IMMUTABLE
  COST 5000;

-- ----------------------------
-- Function structure for _st_within
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT public._ST_Contains($2,$1)$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for addauth
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."addauth"(text);
CREATE FUNCTION "public"."addauth"(text)
  RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
	lockid alias for $1;
	okay boolean;
	myrec record;
BEGIN
	-- check to see if table exists
	--  if not, CREATE TEMP TABLE mylock (transid xid, lockcode text)
	okay := 'f';
	FOR myrec IN SELECT * FROM pg_class WHERE relname = 'temp_lock_have_table' LOOP
		okay := 't';
	END LOOP;
	IF (okay <> 't') THEN
		CREATE TEMP TABLE temp_lock_have_table (transid xid, lockcode text);
			-- this will only work from pgsql7.4 up
			-- ON COMMIT DELETE ROWS;
	END IF;

	--  INSERT INTO mylock VALUES ( $1)
--	EXECUTE 'INSERT INTO temp_lock_have_table VALUES ( '||
--		quote_literal(getTransactionID()) || ',' ||
--		quote_literal(lockid) ||')';

	INSERT INTO temp_lock_have_table VALUES (getTransactionID(), lockid);

	RETURN true::boolean;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."addauth"(text) IS 'args: auth_token - Adds an authorization token to be used in the current transaction.';

-- ----------------------------
-- Function structure for addgeometrycolumn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."addgeometrycolumn"("schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool);
CREATE FUNCTION "public"."addgeometrycolumn"("schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool=true)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	ret  text;
BEGIN
	SELECT public.AddGeometryColumn('',$1,$2,$3,$4,$5,$6,$7) into ret;
	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."addgeometrycolumn"("schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool) IS 'args: schema_name, table_name, column_name, srid, type, dimension, use_typmod=true - Adds a geometry column to an existing table.';

-- ----------------------------
-- Function structure for addgeometrycolumn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."addgeometrycolumn"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid_in" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool);
CREATE FUNCTION "public"."addgeometrycolumn"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid_in" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool=true)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	rec RECORD;
	sr varchar;
	real_schema name;
	sql text;
	new_srid integer;

BEGIN

	-- Verify geometry type
	IF (postgis_type_name(new_type,new_dim) IS NULL )
	THEN
		RAISE EXCEPTION 'Invalid type name "%(%)" - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM, TRIANGLE, TRIANGLEM,
	POLYHEDRALSURFACE, POLYHEDRALSURFACEM, TIN, TINM
	or GEOMETRYCOLLECTIONM', new_type, new_dim;
		RETURN 'fail';
	END IF;

	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <2) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;

	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;

	-- Verify SRID
	IF ( new_srid_in > 0 ) THEN
		IF new_srid_in > 998999 THEN
			RAISE EXCEPTION 'AddGeometryColumn() - SRID must be <= %', 998999;
		END IF;
		new_srid := new_srid_in;
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumn() - invalid SRID';
			RETURN 'fail';
		END IF;
	ELSE
		new_srid := public.ST_SRID('POINT EMPTY'::public.geometry);
		IF ( new_srid_in != new_srid ) THEN
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
		END IF;
	END IF;

	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;

	-- Add geometry column to table
	IF use_typmod THEN
		 sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD COLUMN ' || quote_ident(column_name) ||
			' geometry(' || public.postgis_type_name(new_type, new_dim) || ', ' || new_srid::text || ')';
		RAISE DEBUG '%', sql;
	ELSE
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD COLUMN ' || quote_ident(column_name) ||
			' geometry ';
		RAISE DEBUG '%', sql;
	END IF;
	EXECUTE sql;

	IF NOT use_typmod THEN
		-- Add table CHECKs
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD CONSTRAINT '
			|| quote_ident('enforce_srid_' || column_name)
			|| ' CHECK (st_srid(' || quote_ident(column_name) ||
			') = ' || new_srid::text || ')' ;
		RAISE DEBUG '%', sql;
		EXECUTE sql;

		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD CONSTRAINT '
			|| quote_ident('enforce_dims_' || column_name)
			|| ' CHECK (st_ndims(' || quote_ident(column_name) ||
			') = ' || new_dim::text || ')' ;
		RAISE DEBUG '%', sql;
		EXECUTE sql;

		IF ( NOT (new_type = 'GEOMETRY')) THEN
			sql := 'ALTER TABLE ' ||
				quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
				quote_ident('enforce_geotype_' || column_name) ||
				' CHECK (GeometryType(' ||
				quote_ident(column_name) || ')=' ||
				quote_literal(new_type) || ' OR (' ||
				quote_ident(column_name) || ') is null)';
			RAISE DEBUG '%', sql;
			EXECUTE sql;
		END IF;
	END IF;

	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."addgeometrycolumn"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid_in" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool) IS 'args: catalog_name, schema_name, table_name, column_name, srid, type, dimension, use_typmod=true - Adds a geometry column to an existing table.';

-- ----------------------------
-- Function structure for addgeometrycolumn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."addgeometrycolumn"("table_name" varchar, "column_name" varchar, "new_srid" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool);
CREATE FUNCTION "public"."addgeometrycolumn"("table_name" varchar, "column_name" varchar, "new_srid" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool=true)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	ret  text;
BEGIN
	SELECT public.AddGeometryColumn('','',$1,$2,$3,$4,$5, $6) into ret;
	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."addgeometrycolumn"("table_name" varchar, "column_name" varchar, "new_srid" int4, "new_type" varchar, "new_dim" int4, "use_typmod" bool) IS 'args: table_name, column_name, srid, type, dimension, use_typmod=true - Adds a geometry column to an existing table.';

-- ----------------------------
-- Function structure for box
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box"("public"."box3d");
CREATE FUNCTION "public"."box"("public"."box3d")
  RETURNS "pg_catalog"."box" AS '$libdir/postgis-3', 'BOX3D_to_BOX'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for box
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box"("public"."geometry");
CREATE FUNCTION "public"."box"("public"."geometry")
  RETURNS "pg_catalog"."box" AS '$libdir/postgis-3', 'LWGEOM_to_BOX'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for box2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box2d"("public"."box3d");
CREATE FUNCTION "public"."box2d"("public"."box3d")
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'BOX3D_to_BOX2D'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for box2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box2d"("public"."geometry");
CREATE FUNCTION "public"."box2d"("public"."geometry")
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'LWGEOM_to_BOX2D'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."box2d"("public"."geometry") IS 'args: geom - Returns a BOX2D representing the 2D extent of a geometry.';

-- ----------------------------
-- Function structure for box2d_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box2d_in"(cstring);
CREATE FUNCTION "public"."box2d_in"(cstring)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'BOX2D_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for box2d_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box2d_out"("public"."box2d");
CREATE FUNCTION "public"."box2d_out"("public"."box2d")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'BOX2D_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for box2df_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box2df_in"(cstring);
CREATE FUNCTION "public"."box2df_in"(cstring)
  RETURNS "public"."box2df" AS '$libdir/postgis-3', 'box2df_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for box2df_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box2df_out"("public"."box2df");
CREATE FUNCTION "public"."box2df_out"("public"."box2df")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'box2df_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for box3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box3d"("public"."geometry");
CREATE FUNCTION "public"."box3d"("public"."geometry")
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'LWGEOM_to_BOX3D'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."box3d"("public"."geometry") IS 'args: geom - Returns a BOX3D representing the 3D extent of a geometry.';

-- ----------------------------
-- Function structure for box3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box3d"("public"."box2d");
CREATE FUNCTION "public"."box3d"("public"."box2d")
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX2D_to_BOX3D'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for box3d_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box3d_in"(cstring);
CREATE FUNCTION "public"."box3d_in"(cstring)
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX3D_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for box3d_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box3d_out"("public"."box3d");
CREATE FUNCTION "public"."box3d_out"("public"."box3d")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'BOX3D_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for box3dtobox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."box3dtobox"("public"."box3d");
CREATE FUNCTION "public"."box3dtobox"("public"."box3d")
  RETURNS "pg_catalog"."box" AS '$libdir/postgis-3', 'BOX3D_to_BOX'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."bytea"("public"."geography");
CREATE FUNCTION "public"."bytea"("public"."geography")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_to_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."bytea"("public"."geometry");
CREATE FUNCTION "public"."bytea"("public"."geometry")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_to_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for checkauth
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."checkauth"(text, text);
CREATE FUNCTION "public"."checkauth"(text, text)
  RETURNS "pg_catalog"."int4" AS $BODY$ SELECT CheckAuth('', $1, $2) $BODY$
  LANGUAGE sql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."checkauth"(text, text) IS 'args: a_table_name, a_key_column_name - Creates a trigger on a table to prevent/allow updates and deletes of rows based on authorization token.';

-- ----------------------------
-- Function structure for checkauth
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."checkauth"(text, text, text);
CREATE FUNCTION "public"."checkauth"(text, text, text)
  RETURNS "pg_catalog"."int4" AS $BODY$
DECLARE
	schema text;
BEGIN
	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;

	if ( $1 != '' ) THEN
		schema = $1;
	ELSE
		SELECT current_schema() into schema;
	END IF;

	-- TODO: check for an already existing trigger ?

	EXECUTE 'CREATE TRIGGER check_auth BEFORE UPDATE OR DELETE ON '
		|| quote_ident(schema) || '.' || quote_ident($2)
		||' FOR EACH ROW EXECUTE PROCEDURE CheckAuthTrigger('
		|| quote_literal($3) || ')';

	RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."checkauth"(text, text, text) IS 'args: a_schema_name, a_table_name, a_key_column_name - Creates a trigger on a table to prevent/allow updates and deletes of rows based on authorization token.';

-- ----------------------------
-- Function structure for checkauthtrigger
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."checkauthtrigger"();
CREATE FUNCTION "public"."checkauthtrigger"()
  RETURNS "pg_catalog"."trigger" AS '$libdir/postgis-3', 'check_authorization'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for contains_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."contains_2d"("public"."box2df", "public"."box2df");
CREATE FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains_box2df_box2df_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for contains_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."contains_2d"("public"."box2df", "public"."geometry");
CREATE FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains_box2df_geom_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for contains_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."contains_2d"("public"."geometry", "public"."box2df");
CREATE FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df")
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT $2 OPERATOR(public.@) $1;$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for disablelongtransactions
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."disablelongtransactions"();
CREATE FUNCTION "public"."disablelongtransactions"()
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	rec RECORD;

BEGIN

	--
	-- Drop all triggers applied by CheckAuth()
	--
	FOR rec IN
		SELECT c.relname, t.tgname, t.tgargs FROM pg_trigger t, pg_class c, pg_proc p
		WHERE p.proname = 'checkauthtrigger' and t.tgfoid = p.oid and t.tgrelid = c.oid
	LOOP
		EXECUTE 'DROP TRIGGER ' || quote_ident(rec.tgname) ||
			' ON ' || quote_ident(rec.relname);
	END LOOP;

	--
	-- Drop the authorization_table table
	--
	FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorization_table' LOOP
		DROP TABLE authorization_table;
	END LOOP;

	--
	-- Drop the authorized_tables view
	--
	FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorized_tables' LOOP
		DROP VIEW authorized_tables;
	END LOOP;

	RETURN 'Long transactions support disabled';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."disablelongtransactions"() IS 'Disables long transaction support.';

-- ----------------------------
-- Function structure for dropgeometrycolumn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dropgeometrycolumn"("table_name" varchar, "column_name" varchar);
CREATE FUNCTION "public"."dropgeometrycolumn"("table_name" varchar, "column_name" varchar)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	ret text;
BEGIN
	SELECT public.DropGeometryColumn('','',$1,$2) into ret;
	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."dropgeometrycolumn"("table_name" varchar, "column_name" varchar) IS 'args: table_name, column_name - Removes a geometry column from a spatial table.';

-- ----------------------------
-- Function structure for dropgeometrycolumn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dropgeometrycolumn"("schema_name" varchar, "table_name" varchar, "column_name" varchar);
CREATE FUNCTION "public"."dropgeometrycolumn"("schema_name" varchar, "table_name" varchar, "column_name" varchar)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	ret text;
BEGIN
	SELECT public.DropGeometryColumn('',$1,$2,$3) into ret;
	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."dropgeometrycolumn"("schema_name" varchar, "table_name" varchar, "column_name" varchar) IS 'args: schema_name, table_name, column_name - Removes a geometry column from a spatial table.';

-- ----------------------------
-- Function structure for dropgeometrycolumn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dropgeometrycolumn"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar);
CREATE FUNCTION "public"."dropgeometrycolumn"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	myrec RECORD;
	okay boolean;
	real_schema name;

BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;

		FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
		END LOOP;

		IF ( okay <>  true ) THEN
			RAISE NOTICE 'Invalid schema name - using current_schema()';
			SELECT current_schema() into real_schema;
		ELSE
			real_schema = schema_name;
		END IF;
	ELSE
		SELECT current_schema() into real_schema;
	END IF;

	-- Find out if the column is in the geometry_columns table
	okay = false;
	FOR myrec IN SELECT * from public.geometry_columns where f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
	END LOOP;
	IF (okay <> true) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
		RETURN false;
	END IF;

	-- Remove table column
	EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' ||
		quote_ident(table_name) || ' DROP COLUMN ' ||
		quote_ident(column_name);

	RETURN real_schema || '.' || table_name || '.' || column_name ||' effectively removed.';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar) IS 'args: catalog_name, schema_name, table_name, column_name - Removes a geometry column from a spatial table.';

-- ----------------------------
-- Function structure for dropgeometrytable
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dropgeometrytable"("table_name" varchar);
CREATE FUNCTION "public"."dropgeometrytable"("table_name" varchar)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.DropGeometryTable('','',$1) $BODY$
  LANGUAGE sql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."dropgeometrytable"("table_name" varchar) IS 'args: table_name - Drops a table and all its references in geometry_columns.';

-- ----------------------------
-- Function structure for dropgeometrytable
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dropgeometrytable"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar);
CREATE FUNCTION "public"."dropgeometrytable"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	real_schema name;

BEGIN

	IF ( schema_name = '' ) THEN
		SELECT current_schema() into real_schema;
	ELSE
		real_schema = schema_name;
	END IF;

	-- TODO: Should we warn if table doesn't exist probably instead just saying dropped
	-- Remove table
	EXECUTE 'DROP TABLE IF EXISTS '
		|| quote_ident(real_schema) || '.' ||
		quote_ident(table_name) || ' RESTRICT';

	RETURN
		real_schema || '.' ||
		table_name ||' dropped.';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."dropgeometrytable"("catalog_name" varchar, "schema_name" varchar, "table_name" varchar) IS 'args: catalog_name, schema_name, table_name - Drops a table and all its references in geometry_columns.';

-- ----------------------------
-- Function structure for dropgeometrytable
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dropgeometrytable"("schema_name" varchar, "table_name" varchar);
CREATE FUNCTION "public"."dropgeometrytable"("schema_name" varchar, "table_name" varchar)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.DropGeometryTable('',$1,$2) $BODY$
  LANGUAGE sql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."dropgeometrytable"("schema_name" varchar, "table_name" varchar) IS 'args: schema_name, table_name - Drops a table and all its references in geometry_columns.';

-- ----------------------------
-- Function structure for enablelongtransactions
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."enablelongtransactions"();
CREATE FUNCTION "public"."enablelongtransactions"()
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	"query" text;
	exists bool;
	rec RECORD;

BEGIN

	exists = 'f';
	FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorization_table'
	LOOP
		exists = 't';
	END LOOP;

	IF NOT exists
	THEN
		"query" = 'CREATE TABLE authorization_table (
			toid oid, -- table oid
			rid text, -- row id
			expires timestamp,
			authid text
		)';
		EXECUTE "query";
	END IF;

	exists = 'f';
	FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorized_tables'
	LOOP
		exists = 't';
	END LOOP;

	IF NOT exists THEN
		"query" = 'CREATE VIEW authorized_tables AS ' ||
			'SELECT ' ||
			'n.nspname as schema, ' ||
			'c.relname as table, trim(' ||
			quote_literal(chr(92) || '000') ||
			' from t.tgargs) as id_column ' ||
			'FROM pg_trigger t, pg_class c, pg_proc p ' ||
			', pg_namespace n ' ||
			'WHERE p.proname = ' || quote_literal('checkauthtrigger') ||
			' AND c.relnamespace = n.oid' ||
			' AND t.tgfoid = p.oid and t.tgrelid = c.oid';
		EXECUTE "query";
	END IF;

	RETURN 'Long transactions support enabled';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."enablelongtransactions"() IS 'Enables long transaction support.';

-- ----------------------------
-- Function structure for equals
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_Equals'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for find_in_set
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."find_in_set"(int8, varchar);
CREATE FUNCTION "public"."find_in_set"(int8, varchar)
  RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
    STR ALIAS FOR $1;
    STRS ALIAS FOR $2;
    POS INTEGER;
    STATUS BOOLEAN;
BEGIN
    SELECT POSITION( ','||STR||',' IN ','||STRS||',') INTO POS;
    IF POS > 0 THEN
        STATUS = TRUE;
    ELSE
        STATUS = FALSE;
    END IF;
    RETURN STATUS;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for find_srid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."find_srid"(varchar, varchar, varchar);
CREATE FUNCTION "public"."find_srid"(varchar, varchar, varchar)
  RETURNS "pg_catalog"."int4" AS $BODY$
DECLARE
	schem varchar =  $1;
	tabl varchar = $2;
	sr int4;
BEGIN
-- if the table contains a . and the schema is empty
-- split the table into a schema and a table
-- otherwise drop through to default behavior
	IF ( schem = '' and strpos(tabl,'.') > 0 ) THEN
	 schem = substr(tabl,1,strpos(tabl,'.')-1);
	 tabl = substr(tabl,length(schem)+2);
	END IF;

	select SRID into sr from public.geometry_columns where (f_table_schema = schem or schem = '') and f_table_name = tabl and f_geometry_column = $3;
	IF NOT FOUND THEN
	   RAISE EXCEPTION 'find_srid() - could not find the corresponding SRID - is the geometry registered in the GEOMETRY_COLUMNS table?  Is there an uppercase/lowercase mismatch?';
	END IF;
	return sr;
END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."find_srid"(varchar, varchar, varchar) IS 'args: a_schema_name, a_table_name, a_geomfield_name - Returns the SRID defined for a geometry column.';

-- ----------------------------
-- Function structure for geog_brin_inclusion_add_value
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geog_brin_inclusion_add_value"(internal, internal, internal, internal);
CREATE FUNCTION "public"."geog_brin_inclusion_add_value"(internal, internal, internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geog_brin_inclusion_add_value'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography"("public"."geometry");
CREATE FUNCTION "public"."geography"("public"."geometry")
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_from_geometry'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography"("public"."geography", int4, bool);
CREATE FUNCTION "public"."geography"("public"."geography", int4, bool)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_enforce_typmod'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography"(bytea);
CREATE FUNCTION "public"."geography"(bytea)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_from_binary'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_analyze
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_analyze"(internal);
CREATE FUNCTION "public"."geography_analyze"(internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_analyze_nd'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_cmp
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_cmp"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'geography_cmp'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_distance_knn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_distance_knn"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_distance_knn'
  LANGUAGE c IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for geography_eq
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_eq"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_eq"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_eq'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_ge
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_ge"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_ge"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_ge'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_compress
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_compress"(internal);
CREATE FUNCTION "public"."geography_gist_compress"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_compress'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_consistent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_consistent"(internal, "public"."geography", int4);
CREATE FUNCTION "public"."geography_gist_consistent"(internal, "public"."geography", int4)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gist_consistent'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_decompress
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_decompress"(internal);
CREATE FUNCTION "public"."geography_gist_decompress"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_decompress'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_distance"(internal, "public"."geography", int4);
CREATE FUNCTION "public"."geography_gist_distance"(internal, "public"."geography", int4)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_geog_distance'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_penalty
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_penalty"(internal, internal, internal);
CREATE FUNCTION "public"."geography_gist_penalty"(internal, internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_penalty'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_picksplit
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_picksplit"(internal, internal);
CREATE FUNCTION "public"."geography_gist_picksplit"(internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_picksplit'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_same
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_same"("public"."box2d", "public"."box2d", internal);
CREATE FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_same'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gist_union
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gist_union"(bytea, internal);
CREATE FUNCTION "public"."geography_gist_union"(bytea, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_union'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geography_gt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_gt"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_gt"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_gt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_in"(cstring, oid, int4);
CREATE FUNCTION "public"."geography_in"(cstring, oid, int4)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_le
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_le"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_le"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_le'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_lt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_lt"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_lt"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_lt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_out"("public"."geography");
CREATE FUNCTION "public"."geography_out"("public"."geography")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'geography_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_overlaps
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_overlaps"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_recv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_recv"(internal, oid, int4);
CREATE FUNCTION "public"."geography_recv"(internal, oid, int4)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_recv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_send
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_send"("public"."geography");
CREATE FUNCTION "public"."geography_send"("public"."geography")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'geography_send'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_spgist_choose_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_spgist_choose_nd"(internal, internal);
CREATE FUNCTION "public"."geography_spgist_choose_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_choose_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_spgist_compress_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_spgist_compress_nd"(internal);
CREATE FUNCTION "public"."geography_spgist_compress_nd"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_spgist_compress_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_spgist_config_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_spgist_config_nd"(internal, internal);
CREATE FUNCTION "public"."geography_spgist_config_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_config_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_spgist_inner_consistent_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_spgist_inner_consistent_nd"(internal, internal);
CREATE FUNCTION "public"."geography_spgist_inner_consistent_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_inner_consistent_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_spgist_leaf_consistent_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_spgist_leaf_consistent_nd"(internal, internal);
CREATE FUNCTION "public"."geography_spgist_leaf_consistent_nd"(internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_spgist_leaf_consistent_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_spgist_picksplit_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_spgist_picksplit_nd"(internal, internal);
CREATE FUNCTION "public"."geography_spgist_picksplit_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_picksplit_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_typmod_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_typmod_in"(_cstring);
CREATE FUNCTION "public"."geography_typmod_in"(_cstring)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'geography_typmod_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geography_typmod_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geography_typmod_out"(int4);
CREATE FUNCTION "public"."geography_typmod_out"(int4)
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'postgis_typmod_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geom2d_brin_inclusion_add_value
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geom2d_brin_inclusion_add_value"(internal, internal, internal, internal);
CREATE FUNCTION "public"."geom2d_brin_inclusion_add_value"(internal, internal, internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geom2d_brin_inclusion_add_value'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geom3d_brin_inclusion_add_value
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geom3d_brin_inclusion_add_value"(internal, internal, internal, internal);
CREATE FUNCTION "public"."geom3d_brin_inclusion_add_value"(internal, internal, internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geom3d_brin_inclusion_add_value'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geom4d_brin_inclusion_add_value
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geom4d_brin_inclusion_add_value"(internal, internal, internal, internal);
CREATE FUNCTION "public"."geom4d_brin_inclusion_add_value"(internal, internal, internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geom4d_brin_inclusion_add_value'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"("public"."box2d");
CREATE FUNCTION "public"."geometry"("public"."box2d")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'BOX2D_to_LWGEOM'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"("public"."geometry", int4, bool);
CREATE FUNCTION "public"."geometry"("public"."geometry", int4, bool)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geometry_enforce_typmod'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"(point);
CREATE FUNCTION "public"."geometry"(point)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'point_to_geometry'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"(path);
CREATE FUNCTION "public"."geometry"(path)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'path_to_geometry'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"(polygon);
CREATE FUNCTION "public"."geometry"(polygon)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'polygon_to_geometry'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"(bytea);
CREATE FUNCTION "public"."geometry"(bytea)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"(text);
CREATE FUNCTION "public"."geometry"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'parse_WKT_lwgeom'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"("public"."box3d");
CREATE FUNCTION "public"."geometry"("public"."box3d")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'BOX3D_to_LWGEOM'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry"("public"."geography");
CREATE FUNCTION "public"."geometry"("public"."geography")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geometry_from_geography'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_above
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_above_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_analyze
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_analyze"(internal);
CREATE FUNCTION "public"."geometry_analyze"(internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_analyze_nd'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_below
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_below_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_cmp
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'lwgeom_cmp'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_contained_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contained_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_contains
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_contains_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_contains_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_contains_nd"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_distance_box
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_distance_box_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_distance_centroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_Distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for geometry_distance_centroid_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_distance_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_distance_cpa
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_DistanceCPA'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for geometry_eq
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'lwgeom_eq'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_ge
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'lwgeom_ge'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_compress_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_compress_2d"(internal);
CREATE FUNCTION "public"."geometry_gist_compress_2d"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_compress_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_compress_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_compress_nd"(internal);
CREATE FUNCTION "public"."geometry_gist_compress_nd"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_compress'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_consistent_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_consistent_2d"(internal, "public"."geometry", int4);
CREATE FUNCTION "public"."geometry_gist_consistent_2d"(internal, "public"."geometry", int4)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gist_consistent_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_consistent_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_consistent_nd"(internal, "public"."geometry", int4);
CREATE FUNCTION "public"."geometry_gist_consistent_nd"(internal, "public"."geometry", int4)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gist_consistent'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_decompress_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_decompress_2d"(internal);
CREATE FUNCTION "public"."geometry_gist_decompress_2d"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_decompress_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_decompress_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_decompress_nd"(internal);
CREATE FUNCTION "public"."geometry_gist_decompress_nd"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_decompress'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_distance_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_distance_2d"(internal, "public"."geometry", int4);
CREATE FUNCTION "public"."geometry_gist_distance_2d"(internal, "public"."geometry", int4)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_distance_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_distance_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_distance_nd"(internal, "public"."geometry", int4);
CREATE FUNCTION "public"."geometry_gist_distance_nd"(internal, "public"."geometry", int4)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_distance'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_penalty_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_penalty_2d"(internal, internal, internal);
CREATE FUNCTION "public"."geometry_gist_penalty_2d"(internal, internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_penalty_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_penalty_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_penalty_nd"(internal, internal, internal);
CREATE FUNCTION "public"."geometry_gist_penalty_nd"(internal, internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_penalty'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_picksplit_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_picksplit_2d"(internal, internal);
CREATE FUNCTION "public"."geometry_gist_picksplit_2d"(internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_picksplit_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_picksplit_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_picksplit_nd"(internal, internal);
CREATE FUNCTION "public"."geometry_gist_picksplit_nd"(internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_picksplit'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_same_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", internal);
CREATE FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_same_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_same_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", internal);
CREATE FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_same'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_sortsupport_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_sortsupport_2d"(internal);
CREATE FUNCTION "public"."geometry_gist_sortsupport_2d"(internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_gist_sortsupport_2d'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_union_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_union_2d"(bytea, internal);
CREATE FUNCTION "public"."geometry_gist_union_2d"(bytea, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_union_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gist_union_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gist_union_nd"(bytea, internal);
CREATE FUNCTION "public"."geometry_gist_union_nd"(bytea, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_gist_union'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for geometry_gt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'lwgeom_gt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_hash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_hash"("public"."geometry");
CREATE FUNCTION "public"."geometry_hash"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'lwgeom_hash'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_in"(cstring);
CREATE FUNCTION "public"."geometry_in"(cstring)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_le
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'lwgeom_le'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_left
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_left_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_lt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'lwgeom_lt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_out"("public"."geometry");
CREATE FUNCTION "public"."geometry_out"("public"."geometry")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'LWGEOM_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overabove
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overabove_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overbelow
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overbelow_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overlaps
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overlaps_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overlaps_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overlaps_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overlaps_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overleft
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overleft_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_overright
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overright_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_recv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_recv"(internal);
CREATE FUNCTION "public"."geometry_recv"(internal)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_recv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_right
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_right_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_same
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_same_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_same_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_same_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_same_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_same_nd"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_same'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_send
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_send"("public"."geometry");
CREATE FUNCTION "public"."geometry_send"("public"."geometry")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_send'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_sortsupport
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_sortsupport"(internal);
CREATE FUNCTION "public"."geometry_sortsupport"(internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'lwgeom_sortsupport'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_choose_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_choose_2d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_choose_2d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_choose_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_choose_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_choose_3d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_choose_3d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_choose_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_choose_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_choose_nd"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_choose_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_choose_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_compress_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_compress_2d"(internal);
CREATE FUNCTION "public"."geometry_spgist_compress_2d"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_spgist_compress_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_compress_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_compress_3d"(internal);
CREATE FUNCTION "public"."geometry_spgist_compress_3d"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_spgist_compress_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_compress_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_compress_nd"(internal);
CREATE FUNCTION "public"."geometry_spgist_compress_nd"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'gserialized_spgist_compress_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_config_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_config_2d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_config_2d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_config_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_config_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_config_3d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_config_3d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_config_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_config_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_config_nd"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_config_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_config_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_inner_consistent_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_inner_consistent_2d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_inner_consistent_2d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_inner_consistent_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_inner_consistent_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_inner_consistent_3d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_inner_consistent_3d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_inner_consistent_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_inner_consistent_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_inner_consistent_nd"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_inner_consistent_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_inner_consistent_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_leaf_consistent_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_leaf_consistent_2d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_leaf_consistent_2d"(internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_spgist_leaf_consistent_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_leaf_consistent_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_leaf_consistent_3d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_leaf_consistent_3d"(internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_spgist_leaf_consistent_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_leaf_consistent_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_leaf_consistent_nd"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_leaf_consistent_nd"(internal, internal)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_spgist_leaf_consistent_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_picksplit_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_picksplit_2d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_picksplit_2d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_picksplit_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_picksplit_3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_picksplit_3d"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_picksplit_3d"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_picksplit_3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_spgist_picksplit_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_spgist_picksplit_nd"(internal, internal);
CREATE FUNCTION "public"."geometry_spgist_picksplit_nd"(internal, internal)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'gserialized_spgist_picksplit_nd'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_typmod_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_typmod_in"(_cstring);
CREATE FUNCTION "public"."geometry_typmod_in"(_cstring)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'geometry_typmod_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_typmod_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_typmod_out"(int4);
CREATE FUNCTION "public"."geometry_typmod_out"(int4)
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'postgis_typmod_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_within
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_within_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometry_within_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometry_within_nd"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_within'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geometrytype
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometrytype"("public"."geometry");
CREATE FUNCTION "public"."geometrytype"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_getTYPE'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."geometrytype"("public"."geometry") IS 'args: geomA - Returns the type of a geometry as text.';

-- ----------------------------
-- Function structure for geometrytype
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geometrytype"("public"."geography");
CREATE FUNCTION "public"."geometrytype"("public"."geography")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_getTYPE'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for geomfromewkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geomfromewkb"(bytea);
CREATE FUNCTION "public"."geomfromewkb"(bytea)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOMFromEWKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for geomfromewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."geomfromewkt"(text);
CREATE FUNCTION "public"."geomfromewkt"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'parse_WKT_lwgeom'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for get_cache_statistics
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_cache_statistics"();
CREATE FUNCTION "public"."get_cache_statistics"()
  RETURNS TABLE("total_tiles" int8, "active_tiles" int8, "expired_tiles" int8, "total_size_gb" numeric, "avg_access_count" numeric) AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT,
        COUNT(*) FILTER (WHERE status = '0' AND expires_at > CURRENT_TIMESTAMP)::BIGINT,
        COUNT(*) FILTER (WHERE status = '0' AND expires_at <= CURRENT_TIMESTAMP)::BIGINT,
        ROUND((SUM(file_size) / 1024.0 / 1024.0 / 1024.0)::NUMERIC, 2),
        ROUND(AVG(access_count)::NUMERIC, 2)
    FROM gee_tiles
    WHERE status = '0';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

-- ----------------------------
-- Function structure for get_proj4_from_srid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_proj4_from_srid"(int4);
CREATE FUNCTION "public"."get_proj4_from_srid"(int4)
  RETURNS "pg_catalog"."text" AS $BODY$
	BEGIN
	RETURN proj4text::text FROM public.spatial_ref_sys WHERE srid= $1;
	END;
	$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for gettransactionid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gettransactionid"();
CREATE FUNCTION "public"."gettransactionid"()
  RETURNS "pg_catalog"."xid" AS '$libdir/postgis-3', 'getTransactionID'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for gidx_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gidx_in"(cstring);
CREATE FUNCTION "public"."gidx_in"(cstring)
  RETURNS "public"."gidx" AS '$libdir/postgis-3', 'gidx_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for gidx_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gidx_out"("public"."gidx");
CREATE FUNCTION "public"."gidx_out"("public"."gidx")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'gidx_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for gserialized_gist_joinsel_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gserialized_gist_joinsel_2d"(internal, oid, internal, int2);
CREATE FUNCTION "public"."gserialized_gist_joinsel_2d"(internal, oid, internal, int2)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_joinsel_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for gserialized_gist_joinsel_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gserialized_gist_joinsel_nd"(internal, oid, internal, int2);
CREATE FUNCTION "public"."gserialized_gist_joinsel_nd"(internal, oid, internal, int2)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_joinsel_nd'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for gserialized_gist_sel_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gserialized_gist_sel_2d"(internal, oid, internal, int4);
CREATE FUNCTION "public"."gserialized_gist_sel_2d"(internal, oid, internal, int4)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_sel_2d'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for gserialized_gist_sel_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gserialized_gist_sel_nd"(internal, oid, internal, int4);
CREATE FUNCTION "public"."gserialized_gist_sel_nd"(internal, oid, internal, int4)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'gserialized_gist_sel_nd'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for is_contained_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."is_contained_2d"("public"."geometry", "public"."box2df");
CREATE FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df")
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT $2 OPERATOR(public.~) $1;$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for is_contained_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."is_contained_2d"("public"."box2df", "public"."geometry");
CREATE FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_within_box2df_geom_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for is_contained_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."is_contained_2d"("public"."box2df", "public"."box2df");
CREATE FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains_box2df_box2df_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for json
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."json"("public"."geometry");
CREATE FUNCTION "public"."json"("public"."geometry")
  RETURNS "pg_catalog"."json" AS '$libdir/postgis-3', 'geometry_to_json'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for jsonb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."jsonb"("public"."geometry");
CREATE FUNCTION "public"."jsonb"("public"."geometry")
  RETURNS "pg_catalog"."jsonb" AS '$libdir/postgis-3', 'geometry_to_jsonb'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for lockrow
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."lockrow"(text, text, text, text, timestamp);
CREATE FUNCTION "public"."lockrow"(text, text, text, text, timestamp)
  RETURNS "pg_catalog"."int4" AS $BODY$
DECLARE
	myschema alias for $1;
	mytable alias for $2;
	myrid   alias for $3;
	authid alias for $4;
	expires alias for $5;
	ret int;
	mytoid oid;
	myrec RECORD;

BEGIN

	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;

	EXECUTE 'DELETE FROM authorization_table WHERE expires < now()';

	SELECT c.oid INTO mytoid FROM pg_class c, pg_namespace n
		WHERE c.relname = mytable
		AND c.relnamespace = n.oid
		AND n.nspname = myschema;

	-- RAISE NOTICE 'toid: %', mytoid;

	FOR myrec IN SELECT * FROM authorization_table WHERE
		toid = mytoid AND rid = myrid
	LOOP
		IF myrec.authid != authid THEN
			RETURN 0;
		ELSE
			RETURN 1;
		END IF;
	END LOOP;

	EXECUTE 'INSERT INTO authorization_table VALUES ('||
		quote_literal(mytoid::text)||','||quote_literal(myrid)||
		','||quote_literal(expires::text)||
		','||quote_literal(authid) ||')';

	GET DIAGNOSTICS ret = ROW_COUNT;

	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."lockrow"(text, text, text, text, timestamp) IS 'args: a_schema_name, a_table_name, a_row_key, an_auth_token, expire_dt - Sets lock/authorization for a row in a table.';

-- ----------------------------
-- Function structure for lockrow
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."lockrow"(text, text, text, text);
CREATE FUNCTION "public"."lockrow"(text, text, text, text)
  RETURNS "pg_catalog"."int4" AS $BODY$ SELECT LockRow($1, $2, $3, $4, now()::timestamp+'1:00'); $BODY$
  LANGUAGE sql VOLATILE STRICT
  COST 100;

-- ----------------------------
-- Function structure for lockrow
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."lockrow"(text, text, text);
CREATE FUNCTION "public"."lockrow"(text, text, text)
  RETURNS "pg_catalog"."int4" AS $BODY$ SELECT LockRow(current_schema(), $1, $2, $3, now()::timestamp+'1:00'); $BODY$
  LANGUAGE sql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."lockrow"(text, text, text) IS 'args: a_table_name, a_row_key, an_auth_token - Sets lock/authorization for a row in a table.';

-- ----------------------------
-- Function structure for lockrow
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."lockrow"(text, text, text, timestamp);
CREATE FUNCTION "public"."lockrow"(text, text, text, timestamp)
  RETURNS "pg_catalog"."int4" AS $BODY$ SELECT LockRow(current_schema(), $1, $2, $3, $4); $BODY$
  LANGUAGE sql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."lockrow"(text, text, text, timestamp) IS 'args: a_table_name, a_row_key, an_auth_token, expire_dt - Sets lock/authorization for a row in a table.';

-- ----------------------------
-- Function structure for log_plot_status_change
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."log_plot_status_change"();
CREATE FUNCTION "public"."log_plot_status_change"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for longtransactionsenabled
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."longtransactionsenabled"();
CREATE FUNCTION "public"."longtransactionsenabled"()
  RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
	rec RECORD;
BEGIN
	FOR rec IN SELECT oid FROM pg_class WHERE relname = 'authorized_tables'
	LOOP
		return 't';
	END LOOP;
	return 'f';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for overlaps_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_2d"("public"."box2df", "public"."box2df");
CREATE FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_contains_box2df_box2df_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_2d"("public"."geometry", "public"."box2df");
CREATE FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df")
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT $2 OPERATOR(public.&&) $1;$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_2d"("public"."box2df", "public"."geometry");
CREATE FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_overlaps_box2df_geom_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_geog
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_geog"("public"."gidx", "public"."gidx");
CREATE FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gidx_gidx_overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_geog
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_geog"("public"."gidx", "public"."geography");
CREATE FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gidx_geog_overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_geog
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_geog"("public"."geography", "public"."gidx");
CREATE FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx")
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT $2 OPERATOR(public.&&) $1;$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for overlaps_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_nd"("public"."gidx", "public"."geometry");
CREATE FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gidx_geom_overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_nd"("public"."gidx", "public"."gidx");
CREATE FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'gserialized_gidx_gidx_overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for overlaps_nd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."overlaps_nd"("public"."geometry", "public"."gidx");
CREATE FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx")
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT $2 OPERATOR(public.&&&) $1;$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for path
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."path"("public"."geometry");
CREATE FUNCTION "public"."path"("public"."geometry")
  RETURNS "pg_catalog"."path" AS '$libdir/postgis-3', 'geometry_to_path'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for pause_region_plots
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pause_region_plots"("p_adcode" varchar, "p_reason" varchar, "p_operator" varchar);
CREATE FUNCTION "public"."pause_region_plots"("p_adcode" varchar, "p_reason" varchar, "p_operator" varchar)
  RETURNS TABLE("affected_count" int4) AS $BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

-- ----------------------------
-- Function structure for pgis_asflatgeobuf_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asflatgeobuf_finalfn"(internal);
CREATE FUNCTION "public"."pgis_asflatgeobuf_finalfn"(internal)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'pgis_asflatgeobuf_finalfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asflatgeobuf_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asflatgeobuf_transfn"(internal, anyelement, bool, text);
CREATE FUNCTION "public"."pgis_asflatgeobuf_transfn"(internal, anyelement, bool, text)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asflatgeobuf_transfn'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for pgis_asflatgeobuf_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asflatgeobuf_transfn"(internal, anyelement, bool);
CREATE FUNCTION "public"."pgis_asflatgeobuf_transfn"(internal, anyelement, bool)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asflatgeobuf_transfn'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for pgis_asflatgeobuf_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asflatgeobuf_transfn"(internal, anyelement);
CREATE FUNCTION "public"."pgis_asflatgeobuf_transfn"(internal, anyelement)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asflatgeobuf_transfn'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for pgis_asgeobuf_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asgeobuf_finalfn"(internal);
CREATE FUNCTION "public"."pgis_asgeobuf_finalfn"(internal)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'pgis_asgeobuf_finalfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asgeobuf_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asgeobuf_transfn"(internal, anyelement);
CREATE FUNCTION "public"."pgis_asgeobuf_transfn"(internal, anyelement)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asgeobuf_transfn'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for pgis_asgeobuf_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asgeobuf_transfn"(internal, anyelement, text);
CREATE FUNCTION "public"."pgis_asgeobuf_transfn"(internal, anyelement, text)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asgeobuf_transfn'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for pgis_asmvt_combinefn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_combinefn"(internal, internal);
CREATE FUNCTION "public"."pgis_asmvt_combinefn"(internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_combinefn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_deserialfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_deserialfn"(bytea, internal);
CREATE FUNCTION "public"."pgis_asmvt_deserialfn"(bytea, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_deserialfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_finalfn"(internal);
CREATE FUNCTION "public"."pgis_asmvt_finalfn"(internal)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'pgis_asmvt_finalfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_serialfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_serialfn"(internal);
CREATE FUNCTION "public"."pgis_asmvt_serialfn"(internal)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'pgis_asmvt_serialfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_transfn"(internal, anyelement);
CREATE FUNCTION "public"."pgis_asmvt_transfn"(internal, anyelement)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_transfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_transfn"(internal, anyelement, text, int4, text, text);
CREATE FUNCTION "public"."pgis_asmvt_transfn"(internal, anyelement, text, int4, text, text)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_transfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_transfn"(internal, anyelement, text, int4);
CREATE FUNCTION "public"."pgis_asmvt_transfn"(internal, anyelement, text, int4)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_transfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_transfn"(internal, anyelement, text);
CREATE FUNCTION "public"."pgis_asmvt_transfn"(internal, anyelement, text)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_transfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_asmvt_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_asmvt_transfn"(internal, anyelement, text, int4, text);
CREATE FUNCTION "public"."pgis_asmvt_transfn"(internal, anyelement, text, int4, text)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_asmvt_transfn'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_accum_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_accum_transfn"(internal, "public"."geometry");
CREATE FUNCTION "public"."pgis_geometry_accum_transfn"(internal, "public"."geometry")
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_accum_transfn'
  LANGUAGE c VOLATILE
  COST 50;

-- ----------------------------
-- Function structure for pgis_geometry_accum_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_accum_transfn"(internal, "public"."geometry", float8);
CREATE FUNCTION "public"."pgis_geometry_accum_transfn"(internal, "public"."geometry", float8)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_accum_transfn'
  LANGUAGE c VOLATILE
  COST 50;

-- ----------------------------
-- Function structure for pgis_geometry_accum_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_accum_transfn"(internal, "public"."geometry", float8, int4);
CREATE FUNCTION "public"."pgis_geometry_accum_transfn"(internal, "public"."geometry", float8, int4)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_accum_transfn'
  LANGUAGE c VOLATILE
  COST 50;

-- ----------------------------
-- Function structure for pgis_geometry_clusterintersecting_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_clusterintersecting_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"(internal)
  RETURNS "public"."_geometry" AS '$libdir/postgis-3', 'pgis_geometry_clusterintersecting_finalfn'
  LANGUAGE c VOLATILE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_clusterwithin_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_clusterwithin_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"(internal)
  RETURNS "public"."_geometry" AS '$libdir/postgis-3', 'pgis_geometry_clusterwithin_finalfn'
  LANGUAGE c VOLATILE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_collect_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_collect_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_collect_finalfn"(internal)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pgis_geometry_collect_finalfn'
  LANGUAGE c VOLATILE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_coverageunion_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_coverageunion_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_coverageunion_finalfn"(internal)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pgis_geometry_coverageunion_finalfn'
  LANGUAGE c VOLATILE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_makeline_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_makeline_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_makeline_finalfn"(internal)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pgis_geometry_makeline_finalfn'
  LANGUAGE c VOLATILE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_polygonize_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_polygonize_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_polygonize_finalfn"(internal)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pgis_geometry_polygonize_finalfn'
  LANGUAGE c VOLATILE
  COST 250;

-- ----------------------------
-- Function structure for pgis_geometry_union_parallel_combinefn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_union_parallel_combinefn"(internal, internal);
CREATE FUNCTION "public"."pgis_geometry_union_parallel_combinefn"(internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_union_parallel_combinefn'
  LANGUAGE c IMMUTABLE
  COST 1;

-- ----------------------------
-- Function structure for pgis_geometry_union_parallel_deserialfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_union_parallel_deserialfn"(bytea, internal);
CREATE FUNCTION "public"."pgis_geometry_union_parallel_deserialfn"(bytea, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_union_parallel_deserialfn'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for pgis_geometry_union_parallel_finalfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_union_parallel_finalfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_union_parallel_finalfn"(internal)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pgis_geometry_union_parallel_finalfn'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for pgis_geometry_union_parallel_serialfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_union_parallel_serialfn"(internal);
CREATE FUNCTION "public"."pgis_geometry_union_parallel_serialfn"(internal)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'pgis_geometry_union_parallel_serialfn'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for pgis_geometry_union_parallel_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_union_parallel_transfn"(internal, "public"."geometry", float8);
CREATE FUNCTION "public"."pgis_geometry_union_parallel_transfn"(internal, "public"."geometry", float8)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_union_parallel_transfn'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for pgis_geometry_union_parallel_transfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgis_geometry_union_parallel_transfn"(internal, "public"."geometry");
CREATE FUNCTION "public"."pgis_geometry_union_parallel_transfn"(internal, "public"."geometry")
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'pgis_geometry_union_parallel_transfn'
  LANGUAGE c IMMUTABLE
  COST 1;

-- ----------------------------
-- Function structure for point
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."point"("public"."geometry");
CREATE FUNCTION "public"."point"("public"."geometry")
  RETURNS "pg_catalog"."point" AS '$libdir/postgis-3', 'geometry_to_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for polygon
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."polygon"("public"."geometry");
CREATE FUNCTION "public"."polygon"("public"."geometry")
  RETURNS "pg_catalog"."polygon" AS '$libdir/postgis-3', 'geometry_to_polygon'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for populate_geometry_columns
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."populate_geometry_columns"("tbl_oid" oid, "use_typmod" bool);
CREATE FUNCTION "public"."populate_geometry_columns"("tbl_oid" oid, "use_typmod" bool=true)
  RETURNS "pg_catalog"."int4" AS $BODY$
DECLARE
	gcs		 RECORD;
	gc		  RECORD;
	gc_old	  RECORD;
	gsrid	   integer;
	gndims	  integer;
	gtype	   text;
	query	   text;
	gc_is_valid boolean;
	inserted	integer;
	constraint_successful boolean := false;

BEGIN
	inserted := 0;

	-- Iterate through all geometry columns in this table
	FOR gcs IN
	SELECT n.nspname, c.relname, a.attname, c.relkind
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind IN('r', 'f', 'p')
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%'
		AND c.oid = tbl_oid
	LOOP

		RAISE DEBUG 'Processing column %.%.%', gcs.nspname, gcs.relname, gcs.attname;

		gc_is_valid := true;
		-- Find the srid, coord_dimension, and type of current geometry
		-- in geometry_columns -- which is now a view

		SELECT type, srid, coord_dimension, gcs.relkind INTO gc_old
			FROM geometry_columns
			WHERE f_table_schema = gcs.nspname AND f_table_name = gcs.relname AND f_geometry_column = gcs.attname;

		IF upper(gc_old.type) = 'GEOMETRY' THEN
		-- This is an unconstrained geometry we need to do something
		-- We need to figure out what to set the type by inspecting the data
			EXECUTE 'SELECT public.ST_srid(' || quote_ident(gcs.attname) || ') As srid, public.GeometryType(' || quote_ident(gcs.attname) || ') As type, public.ST_NDims(' || quote_ident(gcs.attname) || ') As dims ' ||
					 ' FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) ||
					 ' WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1;'
				INTO gc;
			IF gc IS NULL THEN -- there is no data so we can not determine geometry type
				RAISE WARNING 'No data in table %.%, so no information to determine geometry type and srid', gcs.nspname, gcs.relname;
				RETURN 0;
			END IF;
			gsrid := gc.srid; gtype := gc.type; gndims := gc.dims;

			IF use_typmod THEN
				BEGIN
					EXECUTE 'ALTER TABLE ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' ALTER COLUMN ' || quote_ident(gcs.attname) ||
						' TYPE geometry(' || postgis_type_name(gtype, gndims, true) || ', ' || gsrid::text  || ') ';
					inserted := inserted + 1;
				EXCEPTION
						WHEN invalid_parameter_value OR feature_not_supported THEN
						RAISE WARNING 'Could not convert ''%'' in ''%.%'' to use typmod with srid %, type %: %', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), gsrid, postgis_type_name(gtype, gndims, true), SQLERRM;
							gc_is_valid := false;
				END;

			ELSE
				-- Try to apply srid check to column
				constraint_successful = false;
				IF (gsrid > 0 AND postgis_constraint_srid(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
					BEGIN
						EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) ||
								 ' ADD CONSTRAINT ' || quote_ident('enforce_srid_' || gcs.attname) ||
								 ' CHECK (ST_srid(' || quote_ident(gcs.attname) || ') = ' || gsrid || ')';
						constraint_successful := true;
					EXCEPTION
						WHEN check_violation THEN
							RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_srid(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gsrid;
							gc_is_valid := false;
					END;
				END IF;

				-- Try to apply ndims check to column
				IF (gndims IS NOT NULL AND postgis_constraint_dims(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
					BEGIN
						EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
								 ADD CONSTRAINT ' || quote_ident('enforce_dims_' || gcs.attname) || '
								 CHECK (st_ndims(' || quote_ident(gcs.attname) || ') = '||gndims||')';
						constraint_successful := true;
					EXCEPTION
						WHEN check_violation THEN
							RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_ndims(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gndims;
							gc_is_valid := false;
					END;
				END IF;

				-- Try to apply geometrytype check to column
				IF (gtype IS NOT NULL AND postgis_constraint_type(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
					BEGIN
						EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
						ADD CONSTRAINT ' || quote_ident('enforce_geotype_' || gcs.attname) || '
						CHECK (geometrytype(' || quote_ident(gcs.attname) || ') = ' || quote_literal(gtype) || ')';
						constraint_successful := true;
					EXCEPTION
						WHEN check_violation THEN
							-- No geometry check can be applied. This column contains a number of geometry types.
							RAISE WARNING 'Could not add geometry type check (%) to table column: %.%.%', gtype, quote_ident(gcs.nspname),quote_ident(gcs.relname),quote_ident(gcs.attname);
					END;
				END IF;
				 --only count if we were successful in applying at least one constraint
				IF constraint_successful THEN
					inserted := inserted + 1;
				END IF;
			END IF;
		END IF;

	END LOOP;

	RETURN inserted;
END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" oid, "use_typmod" bool) IS 'args: relation_oid, use_typmod=true - Ensures geometry columns are defined with type modifiers or have appropriate spatial constraints.';

-- ----------------------------
-- Function structure for populate_geometry_columns
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."populate_geometry_columns"("use_typmod" bool);
CREATE FUNCTION "public"."populate_geometry_columns"("use_typmod" bool=true)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	inserted	integer;
	oldcount	integer;
	probed	  integer;
	stale	   integer;
	gcs		 RECORD;
	gc		  RECORD;
	gsrid	   integer;
	gndims	  integer;
	gtype	   text;
	query	   text;
	gc_is_valid boolean;

BEGIN
	SELECT count(*) INTO oldcount FROM public.geometry_columns;
	inserted := 0;

	-- Count the number of geometry columns in all tables and views
	SELECT count(DISTINCT c.oid) INTO probed
	FROM pg_class c,
		 pg_attribute a,
		 pg_type t,
		 pg_namespace n
	WHERE c.relkind IN('r','v','f', 'p')
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns' ;

	-- Iterate through all non-dropped geometry columns
	RAISE DEBUG 'Processing Tables.....';

	FOR gcs IN
	SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind IN( 'r', 'f', 'p')
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns'
	LOOP

		inserted := inserted + public.populate_geometry_columns(gcs.oid, use_typmod);
	END LOOP;

	IF oldcount > inserted THEN
		stale = oldcount-inserted;
	ELSE
		stale = 0;
	END IF;

	RETURN 'probed:' ||probed|| ' inserted:'||inserted;
END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."populate_geometry_columns"("use_typmod" bool) IS 'args: use_typmod=true - Ensures geometry columns are defined with type modifiers or have appropriate spatial constraints.';

-- ----------------------------
-- Function structure for postgis_addbbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_addbbox"("public"."geometry");
CREATE FUNCTION "public"."postgis_addbbox"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_addBBOX'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."postgis_addbbox"("public"."geometry") IS 'args: geomA - Add bounding box to the geometry.';

-- ----------------------------
-- Function structure for postgis_cache_bbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_cache_bbox"();
CREATE FUNCTION "public"."postgis_cache_bbox"()
  RETURNS "pg_catalog"."trigger" AS '$libdir/postgis-3', 'cache_bbox'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for postgis_constraint_dims
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_constraint_dims"("geomschema" text, "geomtable" text, "geomcolumn" text);
CREATE FUNCTION "public"."postgis_constraint_dims"("geomschema" text, "geomtable" text, "geomcolumn" text)
  RETURNS "pg_catalog"."int4" AS $BODY$
SELECT  replace(split_part(s.consrc, ' = ', 2), ')', '')::integer
		 FROM pg_class c, pg_namespace n, pg_attribute a
		 , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc
			FROM pg_constraint) AS s
		 WHERE n.nspname = $1
		 AND c.relname = $2
		 AND a.attname = $3
		 AND a.attrelid = c.oid
		 AND s.connamespace = n.oid
		 AND s.conrelid = c.oid
		 AND a.attnum = ANY (s.conkey)
		 AND s.consrc LIKE '%ndims(% = %';
$BODY$
  LANGUAGE sql STABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for postgis_constraint_srid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_constraint_srid"("geomschema" text, "geomtable" text, "geomcolumn" text);
CREATE FUNCTION "public"."postgis_constraint_srid"("geomschema" text, "geomtable" text, "geomcolumn" text)
  RETURNS "pg_catalog"."int4" AS $BODY$
SELECT replace(replace(split_part(s.consrc, ' = ', 2), ')', ''), '(', '')::integer
		 FROM pg_class c, pg_namespace n, pg_attribute a
		 , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc
			FROM pg_constraint) AS s
		 WHERE n.nspname = $1
		 AND c.relname = $2
		 AND a.attname = $3
		 AND a.attrelid = c.oid
		 AND s.connamespace = n.oid
		 AND s.conrelid = c.oid
		 AND a.attnum = ANY (s.conkey)
		 AND s.consrc LIKE '%srid(% = %';
$BODY$
  LANGUAGE sql STABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for postgis_constraint_type
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_constraint_type"("geomschema" text, "geomtable" text, "geomcolumn" text);
CREATE FUNCTION "public"."postgis_constraint_type"("geomschema" text, "geomtable" text, "geomcolumn" text)
  RETURNS "pg_catalog"."varchar" AS $BODY$
SELECT  replace(split_part(s.consrc, '''', 2), ')', '')::varchar
		 FROM pg_class c, pg_namespace n, pg_attribute a
		 , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc
			FROM pg_constraint) AS s
		 WHERE n.nspname = $1
		 AND c.relname = $2
		 AND a.attname = $3
		 AND a.attrelid = c.oid
		 AND s.connamespace = n.oid
		 AND s.conrelid = c.oid
		 AND a.attnum = ANY (s.conkey)
		 AND s.consrc LIKE '%geometrytype(% = %';
$BODY$
  LANGUAGE sql STABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for postgis_dropbbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_dropbbox"("public"."geometry");
CREATE FUNCTION "public"."postgis_dropbbox"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_dropBBOX'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") IS 'args: geomA - Drop the bounding box cache from the geometry.';

-- ----------------------------
-- Function structure for postgis_extensions_upgrade
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_extensions_upgrade"("target_version" text);
CREATE FUNCTION "public"."postgis_extensions_upgrade"("target_version" text=NULL::text)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	rec record;
	sql text;
	var_schema text;
BEGIN

	FOR rec IN
		SELECT name, default_version, installed_version
		FROM pg_catalog.pg_available_extensions
		WHERE name IN (
			'postgis',
			'postgis_raster',
			'postgis_sfcgal',
			'postgis_topology',
			'postgis_tiger_geocoder'
		)
		ORDER BY length(name) -- this is to make sure 'postgis' is first !
	LOOP --{

		IF target_version IS NULL THEN
			target_version := rec.default_version;
		END IF;

		IF rec.installed_version IS NULL THEN --{
			-- If the support installed by available extension
			-- is found unpackaged, we package it
			IF --{
				 -- PostGIS is always available (this function is part of it)
				 rec.name = 'postgis'

				 -- PostGIS raster is available if type 'raster' exists
				 OR ( rec.name = 'postgis_raster' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_type
							WHERE typname = 'raster' ) )

				 -- PostGIS SFCGAL is availble if
				 -- 'postgis_sfcgal_version' function exists
				 OR ( rec.name = 'postgis_sfcgal' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_proc
							WHERE proname = 'postgis_sfcgal_version' ) )

				 -- PostGIS Topology is available if
				 -- 'topology.topology' table exists
				 -- NOTE: watch out for https://trac.osgeo.org/postgis/ticket/2503
				 OR ( rec.name = 'postgis_topology' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_class c
							JOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid )
							WHERE n.nspname = 'topology' AND c.relname = 'topology') )

				 OR ( rec.name = 'postgis_tiger_geocoder' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_class c
							JOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid )
							WHERE n.nspname = 'tiger' AND c.relname = 'geocode_settings') )
			THEN --}{ -- the code is unpackaged
				-- Force install in same schema as postgis
				SELECT INTO var_schema n.nspname
				  FROM pg_namespace n, pg_proc p
				  WHERE p.proname = 'postgis_full_version'
					AND n.oid = p.pronamespace
				  LIMIT 1;
				IF rec.name NOT IN('postgis_topology', 'postgis_tiger_geocoder')
				THEN
					sql := format(
							  'CREATE EXTENSION %1$I SCHEMA %2$I VERSION unpackaged;'
							  'ALTER EXTENSION %1$I UPDATE TO %3$I',
							  rec.name, var_schema, target_version);
				ELSE
					sql := format(
							 'CREATE EXTENSION %1$I VERSION unpackaged;'
							 'ALTER EXTENSION %1$I UPDATE TO %2$I',
							 rec.name, target_version);
				END IF;
				RAISE NOTICE 'Packaging and updating %', rec.name;
				RAISE DEBUG '%', sql;
				EXECUTE sql;
			ELSE
				RAISE DEBUG 'Skipping % (not in use)', rec.name;
			END IF; --}
		ELSE -- The code is already packaged, upgrade it --}{
			sql = format(
				'ALTER EXTENSION %1$I UPDATE TO "ANY";'
				'ALTER EXTENSION %1$I UPDATE TO %2$I',
				rec.name, target_version
				);
			RAISE NOTICE 'Updating extension % %', rec.name, rec.installed_version;
			RAISE DEBUG '%', sql;
			EXECUTE sql;
		END IF; --}

	END LOOP; --}

	RETURN format(
		'Upgrade to version %s completed, run SELECT postgis_full_version(); for details',
		target_version
	);


END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "public"."postgis_extensions_upgrade"("target_version" text) IS 'args: target_version=null - Packages and upgrades PostGIS extensions (e.g. postgis_raster,postgis_topology, postgis_sfcgal) to given or latest version.';

-- ----------------------------
-- Function structure for postgis_full_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_full_version"();
CREATE FUNCTION "public"."postgis_full_version"()
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	libver text;
	librev text;
	projver text;
	geosver text;
	geosver_compiled text;
	sfcgalver text;
	gdalver text := NULL;
	libxmlver text;
	liblwgeomver text;
	dbproc text;
	relproc text;
	fullver text;
	rast_lib_ver text := NULL;
	rast_scr_ver text := NULL;
	topo_scr_ver text := NULL;
	json_lib_ver text;
	protobuf_lib_ver text;
	wagyu_lib_ver text;
	sfcgal_lib_ver text;
	sfcgal_scr_ver text;
	pgsql_scr_ver text;
	pgsql_ver text;
	core_is_extension bool;
BEGIN
	SELECT public.postgis_lib_version() INTO libver;
	SELECT public.postgis_proj_version() INTO projver;
	SELECT public.postgis_geos_version() INTO geosver;
	SELECT public.postgis_geos_compiled_version() INTO geosver_compiled;
	SELECT public.postgis_libjson_version() INTO json_lib_ver;
	SELECT public.postgis_libprotobuf_version() INTO protobuf_lib_ver;
	SELECT public.postgis_wagyu_version() INTO wagyu_lib_ver;
	SELECT public._postgis_scripts_pgsql_version() INTO pgsql_scr_ver;
	SELECT public._postgis_pgsql_version() INTO pgsql_ver;
	BEGIN
		SELECT public.postgis_gdal_version() INTO gdalver;
	EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_gdal_version() not found.  Is raster support enabled and rtpostgis.sql installed?';
	END;
	BEGIN
		SELECT public.postgis_sfcgal_full_version() INTO sfcgalver;
		BEGIN
			SELECT public.postgis_sfcgal_scripts_installed() INTO sfcgal_scr_ver;
		EXCEPTION
			WHEN undefined_function THEN
				sfcgal_scr_ver := 'missing';
		END;
	EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_sfcgal_scripts_installed() not found. Is sfcgal support enabled and sfcgal.sql installed?';
	END;
	SELECT public.postgis_liblwgeom_version() INTO liblwgeomver;
	SELECT public.postgis_libxml_version() INTO libxmlver;
	SELECT public.postgis_scripts_installed() INTO dbproc;
	SELECT public.postgis_scripts_released() INTO relproc;
	SELECT public.postgis_lib_revision() INTO librev;
	BEGIN
		SELECT topology.postgis_topology_scripts_installed() INTO topo_scr_ver;
	EXCEPTION
		WHEN undefined_function OR invalid_schema_name THEN
			RAISE DEBUG 'Function postgis_topology_scripts_installed() not found. Is topology support enabled and topology.sql installed?';
		WHEN insufficient_privilege THEN
			RAISE NOTICE 'Topology support cannot be inspected. Is current user granted USAGE on schema "topology" ?';
		WHEN OTHERS THEN
			RAISE NOTICE 'Function postgis_topology_scripts_installed() could not be called: % (%)', SQLERRM, SQLSTATE;
	END;

	BEGIN
		SELECT postgis_raster_scripts_installed() INTO rast_scr_ver;
	EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_raster_scripts_installed() not found. Is raster support enabled and rtpostgis.sql installed?';
		WHEN OTHERS THEN
			RAISE NOTICE 'Function postgis_raster_scripts_installed() could not be called: % (%)', SQLERRM, SQLSTATE;
	END;

	BEGIN
		SELECT public.postgis_raster_lib_version() INTO rast_lib_ver;
	EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_raster_lib_version() not found. Is raster support enabled and rtpostgis.sql installed?';
		WHEN OTHERS THEN
			RAISE NOTICE 'Function postgis_raster_lib_version() could not be called: % (%)', SQLERRM, SQLSTATE;
	END;

	fullver = 'POSTGIS="' || libver;

	IF  librev IS NOT NULL THEN
		fullver = fullver || ' ' || librev;
	END IF;

	fullver = fullver || '"';

	IF EXISTS (
		SELECT * FROM pg_catalog.pg_extension
		WHERE extname = 'postgis')
	THEN
			fullver = fullver || ' [EXTENSION]';
			core_is_extension := true;
	ELSE
			core_is_extension := false;
	END IF;

	IF liblwgeomver != relproc THEN
		fullver = fullver || ' (liblwgeom version mismatch: "' || liblwgeomver || '")';
	END IF;

	fullver = fullver || ' PGSQL="' || pgsql_scr_ver || '"';
	IF pgsql_scr_ver != pgsql_ver THEN
		fullver = fullver || ' (procs need upgrade for use with PostgreSQL "' || pgsql_ver || '")';
	END IF;

	IF  geosver IS NOT NULL THEN
		fullver = fullver || ' GEOS="' || geosver || '"';
		IF (string_to_array(geosver, '.'))[1:2] != (string_to_array(geosver_compiled, '.'))[1:2]
		THEN
			fullver = format('%s (compiled against GEOS %s)', fullver, geosver_compiled);
		END IF;
	END IF;

	IF  sfcgalver IS NOT NULL THEN
		fullver = fullver || ' SFCGAL="' || sfcgalver || '"';
	END IF;

	IF  projver IS NOT NULL THEN
		fullver = fullver || ' PROJ="' || projver || '"';
	END IF;

	IF  gdalver IS NOT NULL THEN
		fullver = fullver || ' GDAL="' || gdalver || '"';
	END IF;

	IF  libxmlver IS NOT NULL THEN
		fullver = fullver || ' LIBXML="' || libxmlver || '"';
	END IF;

	IF json_lib_ver IS NOT NULL THEN
		fullver = fullver || ' LIBJSON="' || json_lib_ver || '"';
	END IF;

	IF protobuf_lib_ver IS NOT NULL THEN
		fullver = fullver || ' LIBPROTOBUF="' || protobuf_lib_ver || '"';
	END IF;

	IF wagyu_lib_ver IS NOT NULL THEN
		fullver = fullver || ' WAGYU="' || wagyu_lib_ver || '"';
	END IF;

	IF dbproc != relproc THEN
		fullver = fullver || ' (core procs from "' || dbproc || '" need upgrade)';
	END IF;

	IF topo_scr_ver IS NOT NULL THEN
		fullver = fullver || ' TOPOLOGY';
		IF topo_scr_ver != relproc THEN
			fullver = fullver || ' (topology procs from "' || topo_scr_ver || '" need upgrade)';
		END IF;
		IF core_is_extension AND NOT EXISTS (
			SELECT * FROM pg_catalog.pg_extension
			WHERE extname = 'postgis_topology')
		THEN
				fullver = fullver || ' [UNPACKAGED!]';
		END IF;
	END IF;

	IF rast_lib_ver IS NOT NULL THEN
		fullver = fullver || ' RASTER';
		IF rast_lib_ver != relproc THEN
			fullver = fullver || ' (raster lib from "' || rast_lib_ver || '" need upgrade)';
		END IF;
		IF core_is_extension AND NOT EXISTS (
			SELECT * FROM pg_catalog.pg_extension
			WHERE extname = 'postgis_raster')
		THEN
				fullver = fullver || ' [UNPACKAGED!]';
		END IF;
	END IF;

	IF rast_scr_ver IS NOT NULL AND rast_scr_ver != relproc THEN
		fullver = fullver || ' (raster procs from "' || rast_scr_ver || '" need upgrade)';
	END IF;

	IF sfcgal_scr_ver IS NOT NULL AND sfcgal_scr_ver != relproc THEN
		fullver = fullver || ' (sfcgal procs from "' || sfcgal_scr_ver || '" need upgrade)';
	END IF;

	-- Check for the presence of deprecated functions
	IF EXISTS ( SELECT oid FROM pg_catalog.pg_proc WHERE proname LIKE '%_deprecated_by_postgis_%' )
	THEN
		fullver = fullver || ' (deprecated functions exist, upgrade is not complete)';
	END IF;

	RETURN fullver;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
COMMENT ON FUNCTION "public"."postgis_full_version"() IS 'Reports full PostGIS version and build configuration infos.';

-- ----------------------------
-- Function structure for postgis_geos_compiled_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_geos_compiled_version"();
CREATE FUNCTION "public"."postgis_geos_compiled_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_geos_compiled_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_geos_compiled_version"() IS 'Returns the version number of the GEOS library against which PostGIS was built.';

-- ----------------------------
-- Function structure for postgis_geos_noop
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_geos_noop"("public"."geometry");
CREATE FUNCTION "public"."postgis_geos_noop"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'GEOSnoop'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_geos_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_geos_version"();
CREATE FUNCTION "public"."postgis_geos_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_geos_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_geos_version"() IS 'Returns the version number of the GEOS library.';

-- ----------------------------
-- Function structure for postgis_getbbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_getbbox"("public"."geometry");
CREATE FUNCTION "public"."postgis_getbbox"("public"."geometry")
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'LWGEOM_to_BOX2DF'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_hasbbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_hasbbox"("public"."geometry");
CREATE FUNCTION "public"."postgis_hasbbox"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_hasBBOX'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") IS 'args: geomA - Returns TRUE if the bbox of this geometry is cached, FALSE otherwise.';

-- ----------------------------
-- Function structure for postgis_index_supportfn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_index_supportfn"(internal);
CREATE FUNCTION "public"."postgis_index_supportfn"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/postgis-3', 'postgis_index_supportfn'
  LANGUAGE c VOLATILE
  COST 1;

-- ----------------------------
-- Function structure for postgis_lib_build_date
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_lib_build_date"();
CREATE FUNCTION "public"."postgis_lib_build_date"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_lib_build_date'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_lib_build_date"() IS 'Returns build date of the PostGIS library.';

-- ----------------------------
-- Function structure for postgis_lib_revision
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_lib_revision"();
CREATE FUNCTION "public"."postgis_lib_revision"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_lib_revision'
  LANGUAGE c IMMUTABLE
  COST 1;

-- ----------------------------
-- Function structure for postgis_lib_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_lib_version"();
CREATE FUNCTION "public"."postgis_lib_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_lib_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_lib_version"() IS 'Returns the version number of the PostGIS library.';

-- ----------------------------
-- Function structure for postgis_libjson_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_libjson_version"();
CREATE FUNCTION "public"."postgis_libjson_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_libjson_version'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_liblwgeom_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_liblwgeom_version"();
CREATE FUNCTION "public"."postgis_liblwgeom_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_liblwgeom_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_liblwgeom_version"() IS 'Returns the version number of the liblwgeom library. This should match the version of PostGIS.';

-- ----------------------------
-- Function structure for postgis_libprotobuf_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_libprotobuf_version"();
CREATE FUNCTION "public"."postgis_libprotobuf_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_libprotobuf_version'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_libxml_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_libxml_version"();
CREATE FUNCTION "public"."postgis_libxml_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_libxml_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_libxml_version"() IS 'Returns the version number of the libxml2 library.';

-- ----------------------------
-- Function structure for postgis_noop
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_noop"("public"."geometry");
CREATE FUNCTION "public"."postgis_noop"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_noop'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_proj_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_proj_version"();
CREATE FUNCTION "public"."postgis_proj_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_proj_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_proj_version"() IS 'Returns the version number of the PROJ4 library.';

-- ----------------------------
-- Function structure for postgis_scripts_build_date
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_scripts_build_date"();
CREATE FUNCTION "public"."postgis_scripts_build_date"()
  RETURNS "pg_catalog"."text" AS $BODY$SELECT '2024-04-01 07:18:37'::text AS version$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
COMMENT ON FUNCTION "public"."postgis_scripts_build_date"() IS 'Returns build date of the PostGIS scripts.';

-- ----------------------------
-- Function structure for postgis_scripts_installed
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_scripts_installed"();
CREATE FUNCTION "public"."postgis_scripts_installed"()
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT trim('3.4.2'::text || $rev$ c19ce56 $rev$) AS version $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
COMMENT ON FUNCTION "public"."postgis_scripts_installed"() IS 'Returns version of the PostGIS scripts installed in this database.';

-- ----------------------------
-- Function structure for postgis_scripts_released
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_scripts_released"();
CREATE FUNCTION "public"."postgis_scripts_released"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_scripts_released'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_scripts_released"() IS 'Returns the version number of the postgis.sql script released with the installed PostGIS lib.';

-- ----------------------------
-- Function structure for postgis_srs
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_srs"("auth_name" text, "auth_srid" text);
CREATE FUNCTION "public"."postgis_srs"("auth_name" text, "auth_srid" text)
  RETURNS TABLE("auth_name" text, "auth_srid" text, "srname" text, "srtext" text, "proj4text" text, "point_sw" "public"."geometry", "point_ne" "public"."geometry") AS '$libdir/postgis-3', 'postgis_srs_entry'
  LANGUAGE c IMMUTABLE STRICT
  COST 250
  ROWS 1000;
COMMENT ON FUNCTION "public"."postgis_srs"("auth_name" text, "auth_srid" text) IS 'args: auth_name, auth_srid - Return a metadata record for the requested authority and srid.';

-- ----------------------------
-- Function structure for postgis_srs_all
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_srs_all"();
CREATE FUNCTION "public"."postgis_srs_all"()
  RETURNS TABLE("auth_name" text, "auth_srid" text, "srname" text, "srtext" text, "proj4text" text, "point_sw" "public"."geometry", "point_ne" "public"."geometry") AS '$libdir/postgis-3', 'postgis_srs_entry_all'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000
  ROWS 1000;
COMMENT ON FUNCTION "public"."postgis_srs_all"() IS 'Return metadata records for every spatial reference system in the underlying Proj database.';

-- ----------------------------
-- Function structure for postgis_srs_codes
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_srs_codes"("auth_name" text);
CREATE FUNCTION "public"."postgis_srs_codes"("auth_name" text)
  RETURNS SETOF "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_srs_codes'
  LANGUAGE c IMMUTABLE STRICT
  COST 250
  ROWS 1000;
COMMENT ON FUNCTION "public"."postgis_srs_codes"("auth_name" text) IS 'args: auth_name - Return the list of SRS codes associated with the given authority.';

-- ----------------------------
-- Function structure for postgis_srs_search
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_srs_search"("bounds" "public"."geometry", "authname" text);
CREATE FUNCTION "public"."postgis_srs_search"("bounds" "public"."geometry", "authname" text='EPSG'::text)
  RETURNS TABLE("auth_name" text, "auth_srid" text, "srname" text, "srtext" text, "proj4text" text, "point_sw" "public"."geometry", "point_ne" "public"."geometry") AS '$libdir/postgis-3', 'postgis_srs_search'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000
  ROWS 1000;
COMMENT ON FUNCTION "public"."postgis_srs_search"("bounds" "public"."geometry", "authname" text) IS 'args: bounds, auth_name=EPSG - Return metadata records for projected coordinate systems that have areas of useage that fully contain the bounds parameter.';

-- ----------------------------
-- Function structure for postgis_svn_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_svn_version"();
CREATE FUNCTION "public"."postgis_svn_version"()
  RETURNS "pg_catalog"."text" AS $BODY$
	SELECT public._postgis_deprecate(
		'postgis_svn_version', 'postgis_lib_revision', '3.1.0');
	SELECT public.postgis_lib_revision();
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for postgis_transform_geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_transform_geometry"("geom" "public"."geometry", text, text, int4);
CREATE FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", text, text, int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'transform_geom'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for postgis_transform_pipeline_geometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_transform_pipeline_geometry"("geom" "public"."geometry", "pipeline" text, "forward" bool, "to_srid" int4);
CREATE FUNCTION "public"."postgis_transform_pipeline_geometry"("geom" "public"."geometry", "pipeline" text, "forward" bool, "to_srid" int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'transform_pipeline_geom'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for postgis_type_name
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_type_name"("geomname" varchar, "coord_dimension" int4, "use_new_name" bool);
CREATE FUNCTION "public"."postgis_type_name"("geomname" varchar, "coord_dimension" int4, "use_new_name" bool=true)
  RETURNS "pg_catalog"."varchar" AS $BODY$
	SELECT CASE WHEN $3 THEN new_name ELSE old_name END As geomname
	FROM
	( VALUES
			('GEOMETRY', 'Geometry', 2),
			('GEOMETRY', 'GeometryZ', 3),
			('GEOMETRYM', 'GeometryM', 3),
			('GEOMETRY', 'GeometryZM', 4),

			('GEOMETRYCOLLECTION', 'GeometryCollection', 2),
			('GEOMETRYCOLLECTION', 'GeometryCollectionZ', 3),
			('GEOMETRYCOLLECTIONM', 'GeometryCollectionM', 3),
			('GEOMETRYCOLLECTION', 'GeometryCollectionZM', 4),

			('POINT', 'Point', 2),
			('POINT', 'PointZ', 3),
			('POINTM','PointM', 3),
			('POINT', 'PointZM', 4),

			('MULTIPOINT','MultiPoint', 2),
			('MULTIPOINT','MultiPointZ', 3),
			('MULTIPOINTM','MultiPointM', 3),
			('MULTIPOINT','MultiPointZM', 4),

			('POLYGON', 'Polygon', 2),
			('POLYGON', 'PolygonZ', 3),
			('POLYGONM', 'PolygonM', 3),
			('POLYGON', 'PolygonZM', 4),

			('MULTIPOLYGON', 'MultiPolygon', 2),
			('MULTIPOLYGON', 'MultiPolygonZ', 3),
			('MULTIPOLYGONM', 'MultiPolygonM', 3),
			('MULTIPOLYGON', 'MultiPolygonZM', 4),

			('MULTILINESTRING', 'MultiLineString', 2),
			('MULTILINESTRING', 'MultiLineStringZ', 3),
			('MULTILINESTRINGM', 'MultiLineStringM', 3),
			('MULTILINESTRING', 'MultiLineStringZM', 4),

			('LINESTRING', 'LineString', 2),
			('LINESTRING', 'LineStringZ', 3),
			('LINESTRINGM', 'LineStringM', 3),
			('LINESTRING', 'LineStringZM', 4),

			('CIRCULARSTRING', 'CircularString', 2),
			('CIRCULARSTRING', 'CircularStringZ', 3),
			('CIRCULARSTRINGM', 'CircularStringM' ,3),
			('CIRCULARSTRING', 'CircularStringZM', 4),

			('COMPOUNDCURVE', 'CompoundCurve', 2),
			('COMPOUNDCURVE', 'CompoundCurveZ', 3),
			('COMPOUNDCURVEM', 'CompoundCurveM', 3),
			('COMPOUNDCURVE', 'CompoundCurveZM', 4),

			('CURVEPOLYGON', 'CurvePolygon', 2),
			('CURVEPOLYGON', 'CurvePolygonZ', 3),
			('CURVEPOLYGONM', 'CurvePolygonM', 3),
			('CURVEPOLYGON', 'CurvePolygonZM', 4),

			('MULTICURVE', 'MultiCurve', 2),
			('MULTICURVE', 'MultiCurveZ', 3),
			('MULTICURVEM', 'MultiCurveM', 3),
			('MULTICURVE', 'MultiCurveZM', 4),

			('MULTISURFACE', 'MultiSurface', 2),
			('MULTISURFACE', 'MultiSurfaceZ', 3),
			('MULTISURFACEM', 'MultiSurfaceM', 3),
			('MULTISURFACE', 'MultiSurfaceZM', 4),

			('POLYHEDRALSURFACE', 'PolyhedralSurface', 2),
			('POLYHEDRALSURFACE', 'PolyhedralSurfaceZ', 3),
			('POLYHEDRALSURFACEM', 'PolyhedralSurfaceM', 3),
			('POLYHEDRALSURFACE', 'PolyhedralSurfaceZM', 4),

			('TRIANGLE', 'Triangle', 2),
			('TRIANGLE', 'TriangleZ', 3),
			('TRIANGLEM', 'TriangleM', 3),
			('TRIANGLE', 'TriangleZM', 4),

			('TIN', 'Tin', 2),
			('TIN', 'TinZ', 3),
			('TINM', 'TinM', 3),
			('TIN', 'TinZM', 4) )
			 As g(old_name, new_name, coord_dimension)
	WHERE (upper(old_name) = upper($1) OR upper(new_name) = upper($1))
		AND coord_dimension = $2;
$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for postgis_typmod_dims
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_typmod_dims"(int4);
CREATE FUNCTION "public"."postgis_typmod_dims"(int4)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'postgis_typmod_dims'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_typmod_srid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_typmod_srid"(int4);
CREATE FUNCTION "public"."postgis_typmod_srid"(int4)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'postgis_typmod_srid'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_typmod_type
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_typmod_type"(int4);
CREATE FUNCTION "public"."postgis_typmod_type"(int4)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_typmod_type'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for postgis_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_version"();
CREATE FUNCTION "public"."postgis_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_version"() IS 'Returns PostGIS version number and compile-time options.';

-- ----------------------------
-- Function structure for postgis_wagyu_version
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."postgis_wagyu_version"();
CREATE FUNCTION "public"."postgis_wagyu_version"()
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'postgis_wagyu_version'
  LANGUAGE c IMMUTABLE
  COST 1;
COMMENT ON FUNCTION "public"."postgis_wagyu_version"() IS 'Returns the version number of the internal Wagyu library.';

-- ----------------------------
-- Function structure for resume_region_plots
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."resume_region_plots"("p_adcode" varchar, "p_operator" varchar);
CREATE FUNCTION "public"."resume_region_plots"("p_adcode" varchar, "p_operator" varchar)
  RETURNS TABLE("affected_count" int4) AS $BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

-- ----------------------------
-- Function structure for spheroid_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."spheroid_in"(cstring);
CREATE FUNCTION "public"."spheroid_in"(cstring)
  RETURNS "public"."spheroid" AS '$libdir/postgis-3', 'ellipsoid_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for spheroid_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."spheroid_out"("public"."spheroid");
CREATE FUNCTION "public"."spheroid_out"("public"."spheroid")
  RETURNS "pg_catalog"."cstring" AS '$libdir/postgis-3', 'ellipsoid_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for st_3dclosestpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_closestpoint3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 3D point on g1 that is closest to g2. This is the first point of the 3D shortest line.';

-- ----------------------------
-- Function structure for st_3ddfullywithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dfullywithin3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_3ddistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_3DDistance'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 3D cartesian minimum distance (based on spatial ref) between two geometries in projected units.';

-- ----------------------------
-- Function structure for st_3ddwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dwithin3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_3dintersects
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_3DIntersects'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_3dlength
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dlength"("public"."geometry");
CREATE FUNCTION "public"."st_3dlength"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_length_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_3dlength"("public"."geometry") IS 'args: a_3dlinestring - Returns the 3D length of a linear geometry.';

-- ----------------------------
-- Function structure for st_3dlineinterpolatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dlineinterpolatepoint"("public"."geometry", float8);
CREATE FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_3DLineInterpolatePoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", float8) IS 'args: a_linestring, a_fraction - Returns a point interpolated along a 3D line at a fractional location.';

-- ----------------------------
-- Function structure for st_3dlongestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_longestline3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 3D longest line between two geometries';

-- ----------------------------
-- Function structure for st_3dmakebox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX3D_construct'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: point3DLowLeftBottom, point3DUpRightTop - Creates a BOX3D defined by two 3D point geometries.';

-- ----------------------------
-- Function structure for st_3dmaxdistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_maxdistance3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 3D cartesian maximum distance (based on spatial ref) between two geometries in projected units.';

-- ----------------------------
-- Function structure for st_3dperimeter
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dperimeter"("public"."geometry");
CREATE FUNCTION "public"."st_3dperimeter"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_perimeter_poly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_3dperimeter"("public"."geometry") IS 'args: geomA - Returns the 3D perimeter of a polygonal geometry.';

-- ----------------------------
-- Function structure for st_3dshortestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_shortestline3d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 3D shortest line between two geometries';

-- ----------------------------
-- Function structure for st_addmeasure
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_addmeasure"("public"."geometry", float8, float8);
CREATE FUNCTION "public"."st_addmeasure"("public"."geometry", float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_AddMeasure'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_addmeasure"("public"."geometry", float8, float8) IS 'args: geom_mline, measure_start, measure_end - Interpolates measures along a linear geometry.';

-- ----------------------------
-- Function structure for st_addpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_addpoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: linestring, point - Add a point to a LineString.';

-- ----------------------------
-- Function structure for st_addpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", int4);
CREATE FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_addpoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", int4) IS 'args: linestring, point, position = -1 - Add a point to a LineString.';

-- ----------------------------
-- Function structure for st_affine
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_affine"("public"."geometry", float8, float8, float8, float8, float8, float8, float8, float8, float8, float8, float8, float8);
CREATE FUNCTION "public"."st_affine"("public"."geometry", float8, float8, float8, float8, float8, float8, float8, float8, float8, float8, float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_affine'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_affine"("public"."geometry", float8, float8, float8, float8, float8, float8, float8, float8, float8, float8, float8, float8) IS 'args: geomA, a, b, c, d, e, f, g, h, i, xoff, yoff, zoff - Apply a 3D affine transformation to a geometry.';

-- ----------------------------
-- Function structure for st_affine
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_affine"("public"."geometry", float8, float8, float8, float8, float8, float8);
CREATE FUNCTION "public"."st_affine"("public"."geometry", float8, float8, float8, float8, float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_affine"("public"."geometry", float8, float8, float8, float8, float8, float8) IS 'args: geomA, a, b, d, e, xoff, yoff - Apply a 3D affine transformation to a geometry.';

-- ----------------------------
-- Function structure for st_angle
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry");
CREATE FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry"='0101000000000000000000F87F000000000000F87F'::geometry)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_angle'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") IS 'args: point1, point2, point3, point4 - Returns the angle between two vectors defined by 3 or 4 points, or 2 lines.';

-- ----------------------------
-- Function structure for st_angle
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry");
CREATE FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS $BODY$SELECT ST_Angle(St_StartPoint($1), ST_EndPoint($1), St_StartPoint($2), ST_EndPoint($2))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") IS 'args: line1, line2 - Returns the angle between two vectors defined by 3 or 4 points, or 2 lines.';

-- ----------------------------
-- Function structure for st_area
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_area"("public"."geometry");
CREATE FUNCTION "public"."st_area"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_Area'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_area"("public"."geometry") IS 'args: g1 - Returns the area of a polygonal geometry.';

-- ----------------------------
-- Function structure for st_area
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_area"("geog" "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" bool=true)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_area'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" bool) IS 'args: geog, use_spheroid = true - Returns the area of a polygonal geometry.';

-- ----------------------------
-- Function structure for st_area
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_area"(text);
CREATE FUNCTION "public"."st_area"(text)
  RETURNS "pg_catalog"."float8" AS $BODY$ SELECT public.ST_Area($1::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_area2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_area2d"("public"."geometry");
CREATE FUNCTION "public"."st_area2d"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_Area'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asbinary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asbinary"("public"."geography");
CREATE FUNCTION "public"."st_asbinary"("public"."geography")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_asBinary'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asbinary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asbinary"("public"."geometry", text);
CREATE FUNCTION "public"."st_asbinary"("public"."geometry", text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_asBinary'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asbinary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asbinary"("public"."geography", text);
CREATE FUNCTION "public"."st_asbinary"("public"."geography", text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_asBinary'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_asbinary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asbinary"("public"."geometry");
CREATE FUNCTION "public"."st_asbinary"("public"."geometry")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'LWGEOM_asBinary'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asencodedpolyline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" int4);
CREATE FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" int4=5)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asEncodedPolyline'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asewkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkb"("public"."geometry");
CREATE FUNCTION "public"."st_asewkb"("public"."geometry")
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'WKBFromLWGEOM'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asewkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkb"("public"."geometry", text);
CREATE FUNCTION "public"."st_asewkb"("public"."geometry", text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'WKBFromLWGEOM'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkt"("public"."geography", int4);
CREATE FUNCTION "public"."st_asewkt"("public"."geography", int4)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asEWKT'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkt"(text);
CREATE FUNCTION "public"."st_asewkt"(text)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.ST_AsEWKT($1::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkt"("public"."geography");
CREATE FUNCTION "public"."st_asewkt"("public"."geography")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asEWKT'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkt"("public"."geometry");
CREATE FUNCTION "public"."st_asewkt"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asEWKT'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asewkt"("public"."geometry", int4);
CREATE FUNCTION "public"."st_asewkt"("public"."geometry", int4)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asEWKT'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgeojson"("r" record, "geom_column" text, "maxdecimaldigits" int4, "pretty_bool" bool);
CREATE FUNCTION "public"."st_asgeojson"("r" record, "geom_column" text=''::text, "maxdecimaldigits" int4=9, "pretty_bool" bool=false)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'ST_AsGeoJsonRow'
  LANGUAGE c STABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" int4, "options" int4);
CREATE FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" int4=9, "options" int4=0)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'geography_as_geojson'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgeojson"(text);
CREATE FUNCTION "public"."st_asgeojson"(text)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.ST_AsGeoJson($1::public.geometry, 9, 0);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" int4, "options" int4);
CREATE FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" int4=9, "options" int4=8)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asGeoJson'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgml"("version" int4, "geom" "public"."geometry", "maxdecimaldigits" int4, "options" int4, "nprefix" text, "id" text);
CREATE FUNCTION "public"."st_asgml"("version" int4, "geom" "public"."geometry", "maxdecimaldigits" int4=15, "options" int4=0, "nprefix" text=NULL::text, "id" text=NULL::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asGML'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for st_asgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" int4, "options" int4);
CREATE FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" int4=15, "options" int4=0)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asGML'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for st_asgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgml"("version" int4, "geog" "public"."geography", "maxdecimaldigits" int4, "options" int4, "nprefix" text, "id" text);
CREATE FUNCTION "public"."st_asgml"("version" int4, "geog" "public"."geography", "maxdecimaldigits" int4=15, "options" int4=0, "nprefix" text='gml'::text, "id" text=''::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'geography_as_gml'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgml"(text);
CREATE FUNCTION "public"."st_asgml"(text)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public._ST_AsGML(2,$1::public.geometry,15,0, NULL, NULL);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" int4, "options" int4, "nprefix" text, "id" text);
CREATE FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" int4=15, "options" int4=0, "nprefix" text='gml'::text, "id" text=''::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'geography_as_gml'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_ashexewkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ashexewkb"("public"."geometry");
CREATE FUNCTION "public"."st_ashexewkb"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asHEXEWKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_ashexewkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ashexewkb"("public"."geometry", text);
CREATE FUNCTION "public"."st_ashexewkb"("public"."geometry", text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asHEXEWKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_askml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" int4, "nprefix" text);
CREATE FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" int4=15, "nprefix" text=''::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asKML'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_askml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_askml"(text);
CREATE FUNCTION "public"."st_askml"(text)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.ST_AsKML($1::public.geometry, 15);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_askml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" int4, "nprefix" text);
CREATE FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" int4=15, "nprefix" text=''::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'geography_as_kml'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_aslatlontext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" text);
CREATE FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" text=''::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_to_latlon'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_asmarc21
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asmarc21"("geom" "public"."geometry", "format" text);
CREATE FUNCTION "public"."st_asmarc21"("geom" "public"."geometry", "format" text='hdddmmss'::text)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'ST_AsMARC21'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_asmvtgeom
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" int4, "buffer" int4, "clip_geom" bool);
CREATE FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" int4=4096, "buffer" int4=256, "clip_geom" bool=true)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_AsMVTGeom'
  LANGUAGE c IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for st_assvg
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_assvg"(text);
CREATE FUNCTION "public"."st_assvg"(text)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.ST_AsSVG($1::public.geometry,0,15);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_assvg
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_assvg"("geog" "public"."geography", "rel" int4, "maxdecimaldigits" int4);
CREATE FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" int4=0, "maxdecimaldigits" int4=15)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'geography_as_svg'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_assvg
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_assvg"("geom" "public"."geometry", "rel" int4, "maxdecimaldigits" int4);
CREATE FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" int4=0, "maxdecimaldigits" int4=15)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asSVG'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_astext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astext"("public"."geography", int4);
CREATE FUNCTION "public"."st_astext"("public"."geography", int4)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asText'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_astext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astext"("public"."geometry");
CREATE FUNCTION "public"."st_astext"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asText'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_astext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astext"("public"."geometry", int4);
CREATE FUNCTION "public"."st_astext"("public"."geometry", int4)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asText'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_astext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astext"("public"."geography");
CREATE FUNCTION "public"."st_astext"("public"."geography")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_asText'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_astext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astext"(text);
CREATE FUNCTION "public"."st_astext"(text)
  RETURNS "pg_catalog"."text" AS $BODY$ SELECT public.ST_AsText($1::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_astwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astwkb"("geom" "public"."geometry", "prec" int4, "prec_z" int4, "prec_m" int4, "with_sizes" bool, "with_boxes" bool);
CREATE FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" int4=NULL::integer, "prec_z" int4=NULL::integer, "prec_m" int4=NULL::integer, "with_sizes" bool=NULL::boolean, "with_boxes" bool=NULL::boolean)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'TWKBFromLWGEOM'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_astwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_astwkb"("geom" "public"."_geometry", "ids" _int8, "prec" int4, "prec_z" int4, "prec_m" int4, "with_sizes" bool, "with_boxes" bool);
CREATE FUNCTION "public"."st_astwkb"("geom" "public"."_geometry", "ids" _int8, "prec" int4=NULL::integer, "prec_z" int4=NULL::integer, "prec_m" int4=NULL::integer, "with_sizes" bool=NULL::boolean, "with_boxes" bool=NULL::boolean)
  RETURNS "pg_catalog"."bytea" AS '$libdir/postgis-3', 'TWKBFromLWGEOMArray'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_asx3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" int4, "options" int4);
CREATE FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" int4=15, "options" int4=0)
  RETURNS "pg_catalog"."text" AS $BODY$SELECT public._ST_AsX3D(3,$1,$2,$3,'');$BODY$
  LANGUAGE sql IMMUTABLE
  COST 250;

-- ----------------------------
-- Function structure for st_azimuth
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography");
CREATE FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_azimuth'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") IS 'args: origin, target - Returns the north-based azimuth of a line between two points.';

-- ----------------------------
-- Function structure for st_azimuth
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_azimuth'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: origin, target - Returns the north-based azimuth of a line between two points.';

-- ----------------------------
-- Function structure for st_bdmpolyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_bdmpolyfromtext"(text, int4);
CREATE FUNCTION "public"."st_bdmpolyfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline public.geometry;
	geom public.geometry;
BEGIN
	mline := public.ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := public.ST_Multi(public.ST_BuildArea(mline));

	RETURN geom;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_bdpolyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_bdpolyfromtext"(text, int4);
CREATE FUNCTION "public"."st_bdpolyfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline public.geometry;
	geom public.geometry;
BEGIN
	mline := public.ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := public.ST_BuildArea(mline);

	IF public.GeometryType(geom) != 'POLYGON'
	THEN
		RAISE EXCEPTION 'Input returns more then a single polygon, try using BdMPolyFromText instead';
	END IF;

	RETURN geom;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_boundary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_boundary"("public"."geometry");
CREATE FUNCTION "public"."st_boundary"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'boundary'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_boundary"("public"."geometry") IS 'args: geomA - Returns the boundary of a geometry.';

-- ----------------------------
-- Function structure for st_boundingdiagonal
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" bool);
CREATE FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" bool=false)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_BoundingDiagonal'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" bool) IS 'args: geom, fits=false - Returns the diagonal of a geometrys bounding box.';

-- ----------------------------
-- Function structure for st_box2dfromgeohash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_box2dfromgeohash"(text, int4);
CREATE FUNCTION "public"."st_box2dfromgeohash"(text, int4=NULL::integer)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'box2d_from_geohash'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"(text, float8, int4);
CREATE FUNCTION "public"."st_buffer"(text, float8, int4)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Buffer($1::public.geometry, $2, $3);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"(text, float8, text);
CREATE FUNCTION "public"."st_buffer"(text, float8, text)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Buffer($1::public.geometry, $2, $3);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"("geom" "public"."geometry", "radius" float8, "options" text);
CREATE FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" float8, "options" text=''::text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'buffer'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" float8, "options" text) IS 'args: g1, radius_of_buffer, buffer_style_parameters = '' - Computes a geometry covering all points within a given distance from a geometry.';

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"("geom" "public"."geometry", "radius" float8, "quadsegs" int4);
CREATE FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" float8, "quadsegs" int4)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Buffer($1, $2, CAST('quad_segs='||CAST($3 AS text) as text)) $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" float8, "quadsegs" int4) IS 'args: g1, radius_of_buffer, num_seg_quarter_circle - Computes a geometry covering all points within a given distance from a geometry.';

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"("public"."geography", float8, int4);
CREATE FUNCTION "public"."st_buffer"("public"."geography", float8, int4)
  RETURNS "public"."geography" AS $BODY$SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2, $3), public.ST_SRID($1)))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."st_buffer"("public"."geography", float8, int4) IS 'args: g1, radius_of_buffer, num_seg_quarter_circle - Computes a geometry covering all points within a given distance from a geometry.';

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"("public"."geography", float8, text);
CREATE FUNCTION "public"."st_buffer"("public"."geography", float8, text)
  RETURNS "public"."geography" AS $BODY$SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2, $3), public.ST_SRID($1)))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."st_buffer"("public"."geography", float8, text) IS 'args: g1, radius_of_buffer, buffer_style_parameters - Computes a geometry covering all points within a given distance from a geometry.';

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"(text, float8);
CREATE FUNCTION "public"."st_buffer"(text, float8)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Buffer($1::public.geometry, $2);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_buffer
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buffer"("public"."geography", float8);
CREATE FUNCTION "public"."st_buffer"("public"."geography", float8)
  RETURNS "public"."geography" AS $BODY$SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2), public.ST_SRID($1)))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_buildarea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_buildarea"("public"."geometry");
CREATE FUNCTION "public"."st_buildarea"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_BuildArea'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_buildarea"("public"."geometry") IS 'args: geom - Creates a polygonal geometry formed by the linework of a geometry.';

-- ----------------------------
-- Function structure for st_centroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_centroid"("public"."geometry");
CREATE FUNCTION "public"."st_centroid"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'centroid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_centroid"("public"."geometry") IS 'args: g1 - Returns the geometric center of a geometry.';

-- ----------------------------
-- Function structure for st_centroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_centroid"(text);
CREATE FUNCTION "public"."st_centroid"(text)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Centroid($1::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_centroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_centroid"("public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" bool=true)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_centroid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" bool) IS 'args: g1, use_spheroid = true - Returns the geometric center of a geometry.';

-- ----------------------------
-- Function structure for st_chaikinsmoothing
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_chaikinsmoothing"("public"."geometry", int4, bool);
CREATE FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", int4=1, bool=false)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_ChaikinSmoothing'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", int4, bool) IS 'args: geom, nIterations = 1, preserveEndPoints = false - Returns a smoothed version of a geometry, using the Chaikin algorithm';

-- ----------------------------
-- Function structure for st_cleangeometry
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_cleangeometry"("public"."geometry");
CREATE FUNCTION "public"."st_cleangeometry"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CleanGeometry'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_clipbybox2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d");
CREATE FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_ClipByBox2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") IS 'args: geom, box - Computes the portion of a geometry falling within a rectangle.';

-- ----------------------------
-- Function structure for st_closestpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_closestpoint"("public"."geography", "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_closestpoint"("public"."geography", "public"."geography", "use_spheroid" bool=true)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_closestpoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_closestpoint"("public"."geography", "public"."geography", "use_spheroid" bool) IS 'args: geom1, geom2, use_spheroid = true - Returns the 2D point on g1 that is closest to g2. This is the first point of the shortest line from one geometry to the other.';

-- ----------------------------
-- Function structure for st_closestpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_closestpoint"(text, text);
CREATE FUNCTION "public"."st_closestpoint"(text, text)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_ClosestPoint($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_closestpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_closestpoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: geom1, geom2 - Returns the 2D point on g1 that is closest to g2. This is the first point of the shortest line from one geometry to the other.';

-- ----------------------------
-- Function structure for st_closestpointofapproach
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_ClosestPointOfApproach'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") IS 'args: track1, track2 - Returns a measure at the closest point of approach of two trajectories.';

-- ----------------------------
-- Function structure for st_clusterdbscan
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clusterdbscan"("public"."geometry", "eps" float8, "minpoints" int4);
CREATE FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" float8, "minpoints" int4)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'ST_ClusterDBSCAN'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" float8, "minpoints" int4) IS 'args: geom, eps, minpoints - Window function that returns a cluster id for each input geometry using the DBSCAN algorithm.';

-- ----------------------------
-- Function structure for st_clusterintersecting
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clusterintersecting"("public"."_geometry");
CREATE FUNCTION "public"."st_clusterintersecting"("public"."_geometry")
  RETURNS "public"."_geometry" AS '$libdir/postgis-3', 'clusterintersecting_garray'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_clusterintersectingwin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clusterintersectingwin"("public"."geometry");
CREATE FUNCTION "public"."st_clusterintersectingwin"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'ST_ClusterIntersectingWin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_clusterintersectingwin"("public"."geometry") IS 'args: geom - Window function that returns a cluster id for each input geometry, clustering input geometries into connected sets.';

-- ----------------------------
-- Function structure for st_clusterkmeans
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clusterkmeans"("geom" "public"."geometry", "k" int4, "max_radius" float8);
CREATE FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" int4, "max_radius" float8=NULL::double precision)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'ST_ClusterKMeans'
  LANGUAGE c VOLATILE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" int4, "max_radius" float8) IS 'args: geom, number_of_clusters, max_radius - Window function that returns a cluster id for each input geometry using the K-means algorithm.';

-- ----------------------------
-- Function structure for st_clusterwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clusterwithin"("public"."_geometry", float8);
CREATE FUNCTION "public"."st_clusterwithin"("public"."_geometry", float8)
  RETURNS "public"."_geometry" AS '$libdir/postgis-3', 'cluster_within_distance_garray'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_clusterwithinwin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_clusterwithinwin"("public"."geometry", "distance" float8);
CREATE FUNCTION "public"."st_clusterwithinwin"("public"."geometry", "distance" float8)
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'ST_ClusterWithinWin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_clusterwithinwin"("public"."geometry", "distance" float8) IS 'args: geom, distance - Window function that returns a cluster id for each input geometry, clustering using separation distance.';

-- ----------------------------
-- Function structure for st_collect
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_collect'
  LANGUAGE c IMMUTABLE
  COST 50;
COMMENT ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Creates a GeometryCollection or Multi* geometry from a set of geometries.';

-- ----------------------------
-- Function structure for st_collect
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_collect"("public"."_geometry");
CREATE FUNCTION "public"."st_collect"("public"."_geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_collect_garray'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_collect"("public"."_geometry") IS 'args: g1_array - Creates a GeometryCollection or Multi* geometry from a set of geometries.';

-- ----------------------------
-- Function structure for st_collectionextract
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_collectionextract"("public"."geometry");
CREATE FUNCTION "public"."st_collectionextract"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CollectionExtract'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_collectionextract"("public"."geometry") IS 'args: collection - Given a geometry collection, returns a multi-geometry containing only elements of a specified type.';

-- ----------------------------
-- Function structure for st_collectionextract
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_collectionextract"("public"."geometry", int4);
CREATE FUNCTION "public"."st_collectionextract"("public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CollectionExtract'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_collectionextract"("public"."geometry", int4) IS 'args: collection, type - Given a geometry collection, returns a multi-geometry containing only elements of a specified type.';

-- ----------------------------
-- Function structure for st_collectionhomogenize
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_collectionhomogenize"("public"."geometry");
CREATE FUNCTION "public"."st_collectionhomogenize"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CollectionHomogenize'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") IS 'args: collection - Returns the simplest representation of a geometry collection.';

-- ----------------------------
-- Function structure for st_combinebbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_combinebbox"("public"."box3d", "public"."geometry");
CREATE FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry")
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX3D_combine'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_combinebbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_combinebbox"("public"."box2d", "public"."geometry");
CREATE FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry")
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'BOX2D_combine'
  LANGUAGE c IMMUTABLE
  COST 1;

-- ----------------------------
-- Function structure for st_combinebbox
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_combinebbox"("public"."box3d", "public"."box3d");
CREATE FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d")
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX3D_combine_BOX3D'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_concavehull
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" float8, "param_allow_holes" bool);
CREATE FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" float8, "param_allow_holes" bool=false)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_ConcaveHull'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" float8, "param_allow_holes" bool) IS 'args: param_geom, param_pctconvex, param_allow_holes = false - Computes a possibly concave geometry that contains all input geometry vertices';

-- ----------------------------
-- Function structure for st_contains
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'contains'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_containsproperly
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'containsproperly'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_convexhull
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_convexhull"("public"."geometry");
CREATE FUNCTION "public"."st_convexhull"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'convexhull'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_convexhull"("public"."geometry") IS 'args: geomA - Computes the convex hull of a geometry.';

-- ----------------------------
-- Function structure for st_coorddim
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coorddim"("geometry" "public"."geometry");
CREATE FUNCTION "public"."st_coorddim"("geometry" "public"."geometry")
  RETURNS "pg_catalog"."int2" AS '$libdir/postgis-3', 'LWGEOM_ndims'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") IS 'args: geomA - Return the coordinate dimension of a geometry.';

-- ----------------------------
-- Function structure for st_coverageinvalidedges
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coverageinvalidedges"("geom" "public"."geometry", "tolerance" float8);
CREATE FUNCTION "public"."st_coverageinvalidedges"("geom" "public"."geometry", "tolerance" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CoverageInvalidEdges'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_coverageinvalidedges"("geom" "public"."geometry", "tolerance" float8) IS 'args: geom, tolerance = 0 - Window function that finds locations where polygons fail to form a valid coverage.';

-- ----------------------------
-- Function structure for st_coveragesimplify
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coveragesimplify"("geom" "public"."geometry", "tolerance" float8, "simplifyboundary" bool);
CREATE FUNCTION "public"."st_coveragesimplify"("geom" "public"."geometry", "tolerance" float8, "simplifyboundary" bool=true)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CoverageSimplify'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_coveragesimplify"("geom" "public"."geometry", "tolerance" float8, "simplifyboundary" bool) IS 'args: geom, tolerance, simplifyBoundary = true - Window function that simplifies the edges of a polygonal coverage.';

-- ----------------------------
-- Function structure for st_coverageunion
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coverageunion"("public"."_geometry");
CREATE FUNCTION "public"."st_coverageunion"("public"."_geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CoverageUnion'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_coveredby
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coveredby"(text, text);
CREATE FUNCTION "public"."st_coveredby"(text, text)
  RETURNS "pg_catalog"."bool" AS $BODY$ SELECT public.ST_CoveredBy($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_coveredby
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'coveredby'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_coveredby
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography");
CREATE FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_coveredby'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_covers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'covers'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_covers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography");
CREATE FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_covers'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_covers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_covers"(text, text);
CREATE FUNCTION "public"."st_covers"(text, text)
  RETURNS "pg_catalog"."bool" AS $BODY$ SELECT public.ST_Covers($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_cpawithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_cpawithin"("public"."geometry", "public"."geometry", float8);
CREATE FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_CPAWithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", float8) IS 'args: track1, track2, dist - Tests if the closest point of approach of two trajectoriesis within the specified distance.';

-- ----------------------------
-- Function structure for st_crosses
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'crosses'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_curvetoline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_curvetoline"("geom" "public"."geometry", "tol" float8, "toltype" int4, "flags" int4);
CREATE FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" float8=32, "toltype" int4=0, "flags" int4=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_CurveToLine'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" float8, "toltype" int4, "flags" int4) IS 'args: curveGeom, tolerance, tolerance_type, flags - Converts a geometry containing curves to a linear geometry.';

-- ----------------------------
-- Function structure for st_delaunaytriangles
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" float8, "flags" int4);
CREATE FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" float8=0.0, "flags" int4=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_DelaunayTriangles'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" float8, "flags" int4) IS 'args: g1, tolerance = 0.0, flags = 0 - Returns the Delaunay triangulation of the vertices of a geometry.';

-- ----------------------------
-- Function structure for st_dfullywithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dfullywithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_difference
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8);
CREATE FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8='-1.0'::numeric)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Difference'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8) IS 'args: geomA, geomB, gridSize = -1 - Computes a geometry representing the part of geometry A that does not intersect geometry B.';

-- ----------------------------
-- Function structure for st_dimension
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dimension"("public"."geometry");
CREATE FUNCTION "public"."st_dimension"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_dimension'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_dimension"("public"."geometry") IS 'args: g - Returns the topological dimension of a geometry.';

-- ----------------------------
-- Function structure for st_disjoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'disjoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distance"(text, text);
CREATE FUNCTION "public"."st_distance"(text, text)
  RETURNS "pg_catalog"."float8" AS $BODY$ SELECT public.ST_Distance($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" bool=true)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" bool) IS 'args: geog1, geog2, use_spheroid = true - Returns the distance between two geometry or geography values.';

-- ----------------------------
-- Function structure for st_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_Distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the distance between two geometry or geography values.';

-- ----------------------------
-- Function structure for st_distancecpa
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distancecpa"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_DistanceCPA'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") IS 'args: track1, track2 - Returns the distance between the closest point of approach of two trajectories.';

-- ----------------------------
-- Function structure for st_distancesphere
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" float8);
CREATE FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" float8)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_distance_sphere'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" float8) IS 'args: geomlonlatA, geomlonlatB, radius=6371008 - Returns minimum distance in meters between two lon/lat geometries using a spherical earth model.';

-- ----------------------------
-- Function structure for st_distancesphere
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS $BODY$select public.ST_distance( public.geography($1), public.geography($2),false)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_distancespheroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid");
CREATE FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_distance_ellipsoid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") IS 'args: geomlonlatA, geomlonlatB, measurement_spheroid=WGS84 - Returns the minimum distance between two lon/lat geometries using a spheroidal earth model.';

-- ----------------------------
-- Function structure for st_distancespheroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_distance_ellipsoid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_dump
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dump"("public"."geometry");
CREATE FUNCTION "public"."st_dump"("public"."geometry")
  RETURNS SETOF "public"."geometry_dump" AS '$libdir/postgis-3', 'LWGEOM_dump'
  LANGUAGE c IMMUTABLE STRICT
  COST 250
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_dump"("public"."geometry") IS 'args: g1 - Returns a set of geometry_dump rows for the components of a geometry.';

-- ----------------------------
-- Function structure for st_dumppoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dumppoints"("public"."geometry");
CREATE FUNCTION "public"."st_dumppoints"("public"."geometry")
  RETURNS SETOF "public"."geometry_dump" AS '$libdir/postgis-3', 'LWGEOM_dumppoints'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_dumppoints"("public"."geometry") IS 'args: geom - Returns a set of geometry_dump rows for the coordinates in a geometry.';

-- ----------------------------
-- Function structure for st_dumprings
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dumprings"("public"."geometry");
CREATE FUNCTION "public"."st_dumprings"("public"."geometry")
  RETURNS SETOF "public"."geometry_dump" AS '$libdir/postgis-3', 'LWGEOM_dump_rings'
  LANGUAGE c IMMUTABLE STRICT
  COST 250
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_dumprings"("public"."geometry") IS 'args: a_polygon - Returns a set of geometry_dump rows for the exterior and interior rings of a Polygon.';

-- ----------------------------
-- Function structure for st_dumpsegments
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dumpsegments"("public"."geometry");
CREATE FUNCTION "public"."st_dumpsegments"("public"."geometry")
  RETURNS SETOF "public"."geometry_dump" AS '$libdir/postgis-3', 'LWGEOM_dumpsegments'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_dumpsegments"("public"."geometry") IS 'args: geom - Returns a set of geometry_dump rows for the segments in a geometry.';

-- ----------------------------
-- Function structure for st_dwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" float8, "use_spheroid" bool);
CREATE FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" float8, "use_spheroid" bool=true)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_dwithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_dwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dwithin"(text, text, float8);
CREATE FUNCTION "public"."st_dwithin"(text, text, float8)
  RETURNS "pg_catalog"."bool" AS $BODY$ SELECT public.ST_DWithin($1::public.geometry, $2::public.geometry, $3);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_dwithin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_dwithin'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_endpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_endpoint"("public"."geometry");
CREATE FUNCTION "public"."st_endpoint"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_endpoint_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_endpoint"("public"."geometry") IS 'args: g - Returns the last point of a LineString or CircularLineString.';

-- ----------------------------
-- Function structure for st_envelope
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_envelope"("public"."geometry");
CREATE FUNCTION "public"."st_envelope"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_envelope'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_envelope"("public"."geometry") IS 'args: g1 - Returns a geometry representing the bounding box of a geometry.';

-- ----------------------------
-- Function structure for st_equals
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_Equals'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_estimatedextent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_estimatedextent"(text, text);
CREATE FUNCTION "public"."st_estimatedextent"(text, text)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'gserialized_estimated_extent'
  LANGUAGE c STABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_estimatedextent"(text, text) IS 'args: table_name, geocolumn_name - Returns the estimated extent of a spatial table.';

-- ----------------------------
-- Function structure for st_estimatedextent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_estimatedextent"(text, text, text, bool);
CREATE FUNCTION "public"."st_estimatedextent"(text, text, text, bool)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'gserialized_estimated_extent'
  LANGUAGE c STABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_estimatedextent"(text, text, text, bool) IS 'args: schema_name, table_name, geocolumn_name, parent_only - Returns the estimated extent of a spatial table.';

-- ----------------------------
-- Function structure for st_estimatedextent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_estimatedextent"(text, text, text);
CREATE FUNCTION "public"."st_estimatedextent"(text, text, text)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'gserialized_estimated_extent'
  LANGUAGE c STABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_estimatedextent"(text, text, text) IS 'args: schema_name, table_name, geocolumn_name - Returns the estimated extent of a spatial table.';

-- ----------------------------
-- Function structure for st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_expand"("box" "public"."box2d", "dx" float8, "dy" float8);
CREATE FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" float8, "dy" float8)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'BOX2D_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" float8, "dy" float8) IS 'args: box, dx, dy - Returns a bounding box expanded from another bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_expand"("geom" "public"."geometry", "dx" float8, "dy" float8, "dz" float8, "dm" float8);
CREATE FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" float8, "dy" float8, "dz" float8=0, "dm" float8=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" float8, "dy" float8, "dz" float8, "dm" float8) IS 'args: geom, dx, dy, dz=0, dm=0 - Returns a bounding box expanded from another bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_expand"("public"."geometry", float8);
CREATE FUNCTION "public"."st_expand"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_expand"("public"."geometry", float8) IS 'args: geom, units_to_expand - Returns a bounding box expanded from another bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_expand"("box" "public"."box3d", "dx" float8, "dy" float8, "dz" float8);
CREATE FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" float8, "dy" float8, "dz" float8=0)
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX3D_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" float8, "dy" float8, "dz" float8) IS 'args: box, dx, dy, dz=0 - Returns a bounding box expanded from another bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_expand"("public"."box3d", float8);
CREATE FUNCTION "public"."st_expand"("public"."box3d", float8)
  RETURNS "public"."box3d" AS '$libdir/postgis-3', 'BOX3D_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_expand"("public"."box3d", float8) IS 'args: box, units_to_expand - Returns a bounding box expanded from another bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_expand
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_expand"("public"."box2d", float8);
CREATE FUNCTION "public"."st_expand"("public"."box2d", float8)
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'BOX2D_expand'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_expand"("public"."box2d", float8) IS 'args: box, units_to_expand - Returns a bounding box expanded from another bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_exteriorring
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_exteriorring"("public"."geometry");
CREATE FUNCTION "public"."st_exteriorring"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_exteriorring_polygon'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_exteriorring"("public"."geometry") IS 'args: a_polygon - Returns a LineString representing the exterior ring of a Polygon.';

-- ----------------------------
-- Function structure for st_filterbym
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_filterbym"("public"."geometry", float8, float8, bool);
CREATE FUNCTION "public"."st_filterbym"("public"."geometry", float8, float8=NULL::double precision, bool=false)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_FilterByM'
  LANGUAGE c IMMUTABLE
  COST 50;
COMMENT ON FUNCTION "public"."st_filterbym"("public"."geometry", float8, float8, bool) IS 'args: geom, min, max = null, returnM = false - Removes vertices based on their M value';

-- ----------------------------
-- Function structure for st_findextent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_findextent"(text, text);
CREATE FUNCTION "public"."st_findextent"(text, text)
  RETURNS "public"."box2d" AS $BODY$
DECLARE
	tablename alias for $1;
	columnname alias for $2;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT public.ST_Extent("' || columnname || '") As extent FROM "' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_findextent
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_findextent"(text, text, text);
CREATE FUNCTION "public"."st_findextent"(text, text, text)
  RETURNS "public"."box2d" AS $BODY$
DECLARE
	schemaname alias for $1;
	tablename alias for $2;
	columnname alias for $3;
	myrec RECORD;
BEGIN
	FOR myrec IN EXECUTE 'SELECT public.ST_Extent("' || columnname || '") As extent FROM "' || schemaname || '"."' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_flipcoordinates
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_flipcoordinates"("public"."geometry");
CREATE FUNCTION "public"."st_flipcoordinates"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_FlipCoordinates'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") IS 'args: geom - Returns a version of a geometry with X and Y axis flipped.';

-- ----------------------------
-- Function structure for st_force2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_force2d"("public"."geometry");
CREATE FUNCTION "public"."st_force2d"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_force2d"("public"."geometry") IS 'args: geomA - Force the geometries into a "2-dimensional mode".';

-- ----------------------------
-- Function structure for st_force3d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_force3d"("geom" "public"."geometry", "zvalue" float8);
CREATE FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" float8=0.0)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Force3DZ($1, $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" float8) IS 'args: geomA, Zvalue = 0.0 - Force the geometries into XYZ mode. This is an alias for ST_Force3DZ.';

-- ----------------------------
-- Function structure for st_force3dm
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_force3dm"("geom" "public"."geometry", "mvalue" float8);
CREATE FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_3dm'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" float8) IS 'args: geomA, Mvalue = 0.0 - Force the geometries into XYM mode.';

-- ----------------------------
-- Function structure for st_force3dz
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_force3dz"("geom" "public"."geometry", "zvalue" float8);
CREATE FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_3dz'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" float8) IS 'args: geomA, Zvalue = 0.0 - Force the geometries into XYZ mode.';

-- ----------------------------
-- Function structure for st_force4d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_force4d"("geom" "public"."geometry", "zvalue" float8, "mvalue" float8);
CREATE FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" float8=0.0, "mvalue" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_4d'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" float8, "mvalue" float8) IS 'args: geomA, Zvalue = 0.0, Mvalue = 0.0 - Force the geometries into XYZM mode.';

-- ----------------------------
-- Function structure for st_forcecollection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcecollection"("public"."geometry");
CREATE FUNCTION "public"."st_forcecollection"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_collection'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_forcecollection"("public"."geometry") IS 'args: geomA - Convert the geometry into a GEOMETRYCOLLECTION.';

-- ----------------------------
-- Function structure for st_forcecurve
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcecurve"("public"."geometry");
CREATE FUNCTION "public"."st_forcecurve"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_curve'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_forcecurve"("public"."geometry") IS 'args: g - Upcast a geometry into its curved type, if applicable.';

-- ----------------------------
-- Function structure for st_forcepolygonccw
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcepolygonccw"("public"."geometry");
CREATE FUNCTION "public"."st_forcepolygonccw"("public"."geometry")
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Reverse(public.ST_ForcePolygonCW($1)) $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") IS 'args: geom - Orients all exterior rings counter-clockwise and all interior rings clockwise.';

-- ----------------------------
-- Function structure for st_forcepolygoncw
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcepolygoncw"("public"."geometry");
CREATE FUNCTION "public"."st_forcepolygoncw"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_clockwise_poly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") IS 'args: geom - Orients all exterior rings clockwise and all interior rings counter-clockwise.';

-- ----------------------------
-- Function structure for st_forcerhr
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcerhr"("public"."geometry");
CREATE FUNCTION "public"."st_forcerhr"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_clockwise_poly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_forcerhr"("public"."geometry") IS 'args: g - Force the orientation of the vertices in a polygon to follow the Right-Hand-Rule.';

-- ----------------------------
-- Function structure for st_forcesfs
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcesfs"("public"."geometry", "version" text);
CREATE FUNCTION "public"."st_forcesfs"("public"."geometry", "version" text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_sfs'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" text) IS 'args: geomA, version - Force the geometries to use SFS 1.1 geometry types only.';

-- ----------------------------
-- Function structure for st_forcesfs
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_forcesfs"("public"."geometry");
CREATE FUNCTION "public"."st_forcesfs"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_sfs'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_forcesfs"("public"."geometry") IS 'args: geomA - Force the geometries to use SFS 1.1 geometry types only.';

-- ----------------------------
-- Function structure for st_frechetdistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", float8='-1'::integer)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_FrechetDistance'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", float8) IS 'args: g1, g2, densifyFrac = -1 - Returns the Fréchet distance between two geometries.';

-- ----------------------------
-- Function structure for st_fromflatgeobuf
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_fromflatgeobuf"(anyelement, bytea);
CREATE FUNCTION "public"."st_fromflatgeobuf"(anyelement, bytea)
  RETURNS SETOF "pg_catalog"."anyelement" AS '$libdir/postgis-3', 'pgis_fromflatgeobuf'
  LANGUAGE c IMMUTABLE
  COST 250
  ROWS 1000;

-- ----------------------------
-- Function structure for st_fromflatgeobuftotable
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_fromflatgeobuftotable"(text, text, bytea);
CREATE FUNCTION "public"."st_fromflatgeobuftotable"(text, text, bytea)
  RETURNS "pg_catalog"."void" AS '$libdir/postgis-3', 'pgis_tablefromflatgeobuf'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_generatepoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_generatepoints"("area" "public"."geometry", "npoints" int4, "seed" int4);
CREATE FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" int4, "seed" int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_GeneratePoints'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" int4, "seed" int4) IS 'args: g, npoints, seed = 0 - Generates random points contained in a Polygon or MultiPolygon.';

-- ----------------------------
-- Function structure for st_generatepoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_generatepoints"("area" "public"."geometry", "npoints" int4);
CREATE FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_GeneratePoints'
  LANGUAGE c VOLATILE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" int4) IS 'args: g, npoints - Generates random points contained in a Polygon or MultiPolygon.';

-- ----------------------------
-- Function structure for st_geogfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geogfromtext"(text);
CREATE FUNCTION "public"."st_geogfromtext"(text)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geogfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geogfromwkb"(bytea);
CREATE FUNCTION "public"."st_geogfromwkb"(bytea)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_from_binary'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geographyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geographyfromtext"(text);
CREATE FUNCTION "public"."st_geographyfromtext"(text)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geohash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geohash"("geog" "public"."geography", "maxchars" int4);
CREATE FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" int4=0)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'ST_GeoHash'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geohash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geohash"("geom" "public"."geometry", "maxchars" int4);
CREATE FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" int4=0)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'ST_GeoHash'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geomcollfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomcollfromtext"(text, int4);
CREATE FUNCTION "public"."st_geomcollfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE
	WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN public.ST_GeomFromText($1,$2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomcollfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomcollfromtext"(text);
CREATE FUNCTION "public"."st_geomcollfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE
	WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'GEOMETRYCOLLECTION'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomcollfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomcollfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_geomcollfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE
	WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geomcollfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomcollfromwkb"(bytea);
CREATE FUNCTION "public"."st_geomcollfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE
	WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geometricmedian
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" float8, "max_iter" int4, "fail_if_not_converged" bool);
CREATE FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" float8=NULL::double precision, "max_iter" int4=10000, "fail_if_not_converged" bool=false)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_GeometricMedian'
  LANGUAGE c IMMUTABLE
  COST 5000;
COMMENT ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" float8, "max_iter" int4, "fail_if_not_converged" bool) IS 'args: geom, tolerance = NULL, max_iter = 10000, fail_if_not_converged = false - Returns the geometric median of a MultiPoint.';

-- ----------------------------
-- Function structure for st_geometryfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geometryfromtext"(text);
CREATE FUNCTION "public"."st_geometryfromtext"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geometryfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geometryfromtext"(text, int4);
CREATE FUNCTION "public"."st_geometryfromtext"(text, int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geometryn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geometryn"("public"."geometry", int4);
CREATE FUNCTION "public"."st_geometryn"("public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_geometryn_collection'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_geometryn"("public"."geometry", int4) IS 'args: geomA, n - Return an element of a geometry collection.';

-- ----------------------------
-- Function structure for st_geometrytype
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geometrytype"("public"."geometry");
CREATE FUNCTION "public"."st_geometrytype"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'geometry_geometrytype'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_geometrytype"("public"."geometry") IS 'args: g1 - Returns the SQL-MM type of a geometry as text.';

-- ----------------------------
-- Function structure for st_geomfromewkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromewkb"(bytea);
CREATE FUNCTION "public"."st_geomfromewkb"(bytea)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOMFromEWKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geomfromewkt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromewkt"(text);
CREATE FUNCTION "public"."st_geomfromewkt"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'parse_WKT_lwgeom'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geomfromgeohash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromgeohash"(text, int4);
CREATE FUNCTION "public"."st_geomfromgeohash"(text, int4=NULL::integer)
  RETURNS "public"."geometry" AS $BODY$ SELECT CAST(public.ST_Box2dFromGeoHash($1, $2) AS geometry); $BODY$
  LANGUAGE sql IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_geomfromgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromgeojson"(text);
CREATE FUNCTION "public"."st_geomfromgeojson"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geom_from_geojson'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromgeojson"(jsonb);
CREATE FUNCTION "public"."st_geomfromgeojson"(jsonb)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_GeomFromGeoJson($1::text)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromgeojson
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromgeojson"(json);
CREATE FUNCTION "public"."st_geomfromgeojson"(json)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_GeomFromGeoJson($1::text)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromgml"(text, int4);
CREATE FUNCTION "public"."st_geomfromgml"(text, int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geom_from_gml'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromgml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromgml"(text);
CREATE FUNCTION "public"."st_geomfromgml"(text)
  RETURNS "public"."geometry" AS $BODY$SELECT public._ST_GeomFromGML($1, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromkml
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromkml"(text);
CREATE FUNCTION "public"."st_geomfromkml"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geom_from_kml'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfrommarc21
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfrommarc21"("marc21xml" text);
CREATE FUNCTION "public"."st_geomfrommarc21"("marc21xml" text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_GeomFromMARC21'
  LANGUAGE c IMMUTABLE STRICT
  COST 500;

-- ----------------------------
-- Function structure for st_geomfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromtext"(text);
CREATE FUNCTION "public"."st_geomfromtext"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromtext"(text, int4);
CREATE FUNCTION "public"."st_geomfromtext"(text, int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_geomfromtwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromtwkb"(bytea);
CREATE FUNCTION "public"."st_geomfromtwkb"(bytea)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOMFromTWKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geomfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_geomfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_SetSRID(public.ST_GeomFromWKB($1), $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_geomfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_geomfromwkb"(bytea);
CREATE FUNCTION "public"."st_geomfromwkb"(bytea)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_WKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_gmltosql
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_gmltosql"(text);
CREATE FUNCTION "public"."st_gmltosql"(text)
  RETURNS "public"."geometry" AS $BODY$SELECT public._ST_GeomFromGML($1, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_gmltosql
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_gmltosql"(text, int4);
CREATE FUNCTION "public"."st_gmltosql"(text, int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geom_from_gml'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_hasarc
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_hasarc"("geometry" "public"."geometry");
CREATE FUNCTION "public"."st_hasarc"("geometry" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_has_arc'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") IS 'args: geomA - Tests if a geometry contains a circular arc';

-- ----------------------------
-- Function structure for st_hausdorffdistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'hausdorffdistancedensify'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", float8) IS 'args: g1, g2, densifyFrac - Returns the Hausdorff distance between two geometries.';

-- ----------------------------
-- Function structure for st_hausdorffdistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'hausdorffdistance'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the Hausdorff distance between two geometries.';

-- ----------------------------
-- Function structure for st_hexagon
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_hexagon"("size" float8, "cell_i" int4, "cell_j" int4, "origin" "public"."geometry");
CREATE FUNCTION "public"."st_hexagon"("size" float8, "cell_i" int4, "cell_j" int4, "origin" "public"."geometry"='010100000000000000000000000000000000000000'::geometry)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Hexagon'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_hexagon"("size" float8, "cell_i" int4, "cell_j" int4, "origin" "public"."geometry") IS 'args: size, cell_i, cell_j, origin - Returns a single hexagon, using the provided edge size and cell coordinate within the hexagon grid space.';

-- ----------------------------
-- Function structure for st_hexagongrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_hexagongrid"("size" float8, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" int4, OUT "j" int4);
CREATE FUNCTION "public"."st_hexagongrid"(IN "size" float8, IN "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" int4, OUT "j" int4)
  RETURNS SETOF "pg_catalog"."record" AS '$libdir/postgis-3', 'ST_ShapeGrid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_hexagongrid"("size" float8, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" int4, OUT "j" int4) IS 'args: size, bounds - Returns a set of hexagons and cell indices that completely cover the bounds of the geometry argument.';

-- ----------------------------
-- Function structure for st_interiorringn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_interiorringn"("public"."geometry", int4);
CREATE FUNCTION "public"."st_interiorringn"("public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_interiorringn_polygon'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_interiorringn"("public"."geometry", int4) IS 'args: a_polygon, n - Returns the Nth interior ring (hole) of a Polygon.';

-- ----------------------------
-- Function structure for st_interpolatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry");
CREATE FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_InterpolatePoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") IS 'args: linear_geom_with_measure, point - Returns the interpolated measure of a geometry closest to a point.';

-- ----------------------------
-- Function structure for st_intersection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8);
CREATE FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8='-1'::integer)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Intersection'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8) IS 'args: geomA, geomB, gridSize = -1 - Computes a geometry representing the shared portion of geometries A and B.';

-- ----------------------------
-- Function structure for st_intersection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_intersection"(text, text);
CREATE FUNCTION "public"."st_intersection"(text, text)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_Intersection($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_intersection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_intersection"("public"."geography", "public"."geography");
CREATE FUNCTION "public"."st_intersection"("public"."geography", "public"."geography")
  RETURNS "public"."geography" AS $BODY$SELECT public.geography(public.ST_Transform(public.ST_Intersection(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1, $2)), public.ST_Transform(public.geometry($2), public._ST_BestSRID($1, $2))), public.ST_SRID($1)))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") IS 'args: geogA, geogB - Computes a geometry representing the shared portion of geometries A and B.';

-- ----------------------------
-- Function structure for st_intersects
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography");
CREATE FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'geography_intersects'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_intersects
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_intersects"(text, text);
CREATE FUNCTION "public"."st_intersects"(text, text)
  RETURNS "pg_catalog"."bool" AS $BODY$ SELECT public.ST_Intersects($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_intersects
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_Intersects'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_inversetransformpipeline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_inversetransformpipeline"("geom" "public"."geometry", "pipeline" text, "to_srid" int4);
CREATE FUNCTION "public"."st_inversetransformpipeline"("geom" "public"."geometry", "pipeline" text, "to_srid" int4=0)
  RETURNS "public"."geometry" AS $BODY$SELECT public.postgis_transform_pipeline_geometry($1, $2, FALSE, $3)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_inversetransformpipeline"("geom" "public"."geometry", "pipeline" text, "to_srid" int4) IS 'args: geom, pipeline, to_srid - Return a new geometry with coordinates transformed to a different spatial reference system using the inverse of a defined coordinate transformation pipeline.';

-- ----------------------------
-- Function structure for st_isclosed
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isclosed"("public"."geometry");
CREATE FUNCTION "public"."st_isclosed"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_isclosed'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_isclosed"("public"."geometry") IS 'args: g - Tests if a LineStringss start and end points are coincident. For a PolyhedralSurface tests if it is closed (volumetric).';

-- ----------------------------
-- Function structure for st_iscollection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_iscollection"("public"."geometry");
CREATE FUNCTION "public"."st_iscollection"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_IsCollection'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_iscollection"("public"."geometry") IS 'args: g - Tests if a geometry is a geometry collection type.';

-- ----------------------------
-- Function structure for st_isempty
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isempty"("public"."geometry");
CREATE FUNCTION "public"."st_isempty"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_isempty'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_isempty"("public"."geometry") IS 'args: geomA - Tests if a geometry is empty.';

-- ----------------------------
-- Function structure for st_ispolygonccw
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ispolygonccw"("public"."geometry");
CREATE FUNCTION "public"."st_ispolygonccw"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_IsPolygonCCW'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") IS 'args: geom - Tests if Polygons have exterior rings oriented counter-clockwise and interior rings oriented clockwise.';

-- ----------------------------
-- Function structure for st_ispolygoncw
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ispolygoncw"("public"."geometry");
CREATE FUNCTION "public"."st_ispolygoncw"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_IsPolygonCW'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") IS 'args: geom - Tests if Polygons have exterior rings oriented clockwise and interior rings oriented counter-clockwise.';

-- ----------------------------
-- Function structure for st_isring
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isring"("public"."geometry");
CREATE FUNCTION "public"."st_isring"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'isring'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_isring"("public"."geometry") IS 'args: g - Tests if a LineString is closed and simple.';

-- ----------------------------
-- Function structure for st_issimple
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_issimple"("public"."geometry");
CREATE FUNCTION "public"."st_issimple"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'issimple'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_issimple"("public"."geometry") IS 'args: geomA - Tests if a geometry has no points of self-intersection or self-tangency.';

-- ----------------------------
-- Function structure for st_isvalid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isvalid"("public"."geometry", int4);
CREATE FUNCTION "public"."st_isvalid"("public"."geometry", int4)
  RETURNS "pg_catalog"."bool" AS $BODY$SELECT (public.ST_isValidDetail($1, $2)).valid$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_isvalid"("public"."geometry", int4) IS 'args: g, flags - Tests if a geometry is well-formed in 2D.';

-- ----------------------------
-- Function structure for st_isvalid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isvalid"("public"."geometry");
CREATE FUNCTION "public"."st_isvalid"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'isvalid'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_isvalid"("public"."geometry") IS 'args: g - Tests if a geometry is well-formed in 2D.';

-- ----------------------------
-- Function structure for st_isvaliddetail
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" int4);
CREATE FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" int4=0)
  RETURNS "public"."valid_detail" AS '$libdir/postgis-3', 'isvaliddetail'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" int4) IS 'args: geom, flags - Returns a valid_detail row stating if a geometry is valid or if not a reason and a location.';

-- ----------------------------
-- Function structure for st_isvalidreason
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isvalidreason"("public"."geometry");
CREATE FUNCTION "public"."st_isvalidreason"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'isvalidreason'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_isvalidreason"("public"."geometry") IS 'args: geomA - Returns text stating if a geometry is valid, or a reason for invalidity.';

-- ----------------------------
-- Function structure for st_isvalidreason
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isvalidreason"("public"."geometry", int4);
CREATE FUNCTION "public"."st_isvalidreason"("public"."geometry", int4)
  RETURNS "pg_catalog"."text" AS $BODY$
	SELECT CASE WHEN valid THEN 'Valid Geometry' ELSE reason END FROM (
		SELECT (public.ST_isValidDetail($1, $2)).*
	) foo
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_isvalidreason"("public"."geometry", int4) IS 'args: geomA, flags - Returns text stating if a geometry is valid, or a reason for invalidity.';

-- ----------------------------
-- Function structure for st_isvalidtrajectory
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_isvalidtrajectory"("public"."geometry");
CREATE FUNCTION "public"."st_isvalidtrajectory"("public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_IsValidTrajectory'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") IS 'args: line - Tests if the geometry is a valid trajectory.';

-- ----------------------------
-- Function structure for st_largestemptycircle
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_largestemptycircle"("geom" "public"."geometry", "tolerance" float8, "boundary" "public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" float8);
CREATE FUNCTION "public"."st_largestemptycircle"(IN "geom" "public"."geometry", IN "tolerance" float8=0.0, IN "boundary" "public"."geometry"='0101000000000000000000F87F000000000000F87F'::geometry, OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" float8)
  RETURNS "pg_catalog"."record" AS '$libdir/postgis-3', 'ST_LargestEmptyCircle'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_largestemptycircle"("geom" "public"."geometry", "tolerance" float8, "boundary" "public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" float8) IS 'args: geom, tolerance=0.0, boundary=POINT EMPTY - Computes the largest circle not overlapping a geometry.';

-- ----------------------------
-- Function structure for st_length
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_length"("geog" "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" bool=true)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_length'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" bool) IS 'args: geog, use_spheroid = true - Returns the 2D length of a linear geometry.';

-- ----------------------------
-- Function structure for st_length
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_length"("public"."geometry");
CREATE FUNCTION "public"."st_length"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_length2d_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_length"("public"."geometry") IS 'args: a_2dlinestring - Returns the 2D length of a linear geometry.';

-- ----------------------------
-- Function structure for st_length
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_length"(text);
CREATE FUNCTION "public"."st_length"(text)
  RETURNS "pg_catalog"."float8" AS $BODY$ SELECT public.ST_Length($1::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_length2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_length2d"("public"."geometry");
CREATE FUNCTION "public"."st_length2d"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_length2d_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_length2d"("public"."geometry") IS 'args: a_2dlinestring - Returns the 2D length of a linear geometry. Alias for ST_Length';

-- ----------------------------
-- Function structure for st_length2dspheroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid");
CREATE FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_length2d_ellipsoid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_lengthspheroid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid");
CREATE FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_length_ellipsoid_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") IS 'args: a_geometry, a_spheroid - Returns the 2D or 3D length/perimeter of a lon/lat geometry on a spheroid.';

-- ----------------------------
-- Function structure for st_letters
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_letters"("letters" text, "font" json);
CREATE FUNCTION "public"."st_letters"("letters" text, "font" json=NULL::json)
  RETURNS "public"."geometry" AS $BODY$
DECLARE
  letterarray text[];
  letter text;
  geom geometry;
  prevgeom geometry = NULL;
  adjustment float8 = 0.0;
  position float8 = 0.0;
  text_height float8 = 100.0;
  width float8;
  m_width float8;
  spacing float8;
  dist float8;
  wordarr geometry[];
  wordgeom geometry;
  -- geometry has been run through replace(encode(st_astwkb(geom),'base64'), E'\n', '')
  font_default_height float8 = 1000.0;
  font_default json = '{
  "!":"BgACAQhUrgsTFOQCABQAExELiwi5AgAJiggBYQmJCgAOAg4CDAIOBAoEDAYKBgoGCggICAgICAgGCgYKBgoGCgQMBAoECgQMAgoADAIKAAoADAEKAAwBCgMKAQwDCgMKAwoFCAUKBwgHBgcIBwYJBgkECwYJBAsCDQILAg0CDQANAQ0BCwELAwsDCwUJBQkFCQcHBwcHBwcFCQUJBQkFCQMLAwkDCQMLAQkACwEJAAkACwIJAAsCCQQJAgsECQQJBAkGBwYJCAcIBQgHCAUKBQoDDAUKAQwDDgEMAQ4BDg==",
  "&":"BgABAskBygP+BowEAACZAmcAANsCAw0FDwUNBQ0FDQcLBw0HCwcLCQsJCwkLCQkJCwsJCwkLCQ0HCwcNBw8HDQUPBQ8DDwMRAw8DEQERAREBEQERABcAFQIXAhUCEwQVBBMGEwYTBhEIEQgPChEKDwoPDA0MDQwNDgsOCRAJEAkQBxAHEgUSBRQFFAMUAxQBFgEWARgAigEAFAISABICEgQQAhAEEAQQBg4GEAoOCg4MDg4ODgwSDgsMCwoJDAcMBwwFDgUMAw4DDgEOARABDgEQARIBEAASAHgAIAQeBB4GHAgaChoMGA4WDhYQFBISEhISDhQQFAwWDBYKFgoYBhgIGAQYBBgCGgAaABgBGAMYAxYHFgUWCRYJFAsUCxIPEg0SERARDhMOFQwVDBcIGQYbBhsCHQIfAR+dAgAADAAKAQoBCgEIAwgFBgUGBQYHBAUEBwQHAgcCBwIHAAcABwAHAQcBBwMHAwUDBwUFBQUHBQUBBwMJAQkBCQAJAJcBAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgAKSeECAJ8BFi84HUQDQCAAmAKNAQAvExMx",
  "\"":"BgACAQUmwguEAgAAkwSDAgAAlAQBBfACAIACAACTBP8BAACUBA==",
  "''":"BgABAQUmwguEAgAAkwSDAgAAlAQ=",
  "(":"BgABAUOQBNwLDScNKw0rCysLLwsxCTEJMwc1BzcHNwM7AzsDPwE/AEEANwI1AjMEMwIzBjEGLwYvCC0ILQgrCCkKKQonCicMJbkCAAkqCSoHLAksBywFLgcuBS4FMAMwAzADMgEwATQBMgA0ADwCOgI6BDoEOAY4BjYINgg2CjQKMgoyCjIMMAwwDi7AAgA=",
  ")":"BgABAUMQ3Au6AgAOLQwvDC8KMQoxCjEKMwg1CDUGNQY3BDcEOQI5AjkAOwAzATEBMQExAy8DLwMvBS8FLQctBS0HKwktBykJKwkpswIADCYKKAooCioIKggsCC4ILgYwBjAGMgQ0AjQCNAI2ADgAQgFAAz4DPAM8BzgHOAc2CTQJMgsyCzALLg0sDSoNKg==",
  "+":"BgABAQ3IBOwGALcBuAEAANUBtwEAALcB0wEAALgBtwEAANYBuAEAALgB1AEA",
  "/":"BgABAQVCAoIDwAuyAgCFA78LrQIA",
  "4":"BgABAhDkBr4EkgEAEREApwJ/AADxARIR5QIAEhIA9AHdAwAA7ALIA9AG6gIAEREA8QYFqwIAAIIDwwH/AgABxAEA",
  "v":"BgABASDmA5AEPu4CROwBExb6AgAZFdMC0wgUFaECABIU0wLWCBcW+AIAExVE6wEEFQQXBBUEFwQVBBUEFwQVBBUEFwQVBBUEFwQXBBUEFwYA",
  ",":"BgABAWMYpAEADgIOAgwCDgQMBAoGDAYKBgoICAgICAgICAoGCgYKBAoEDAQKBAoCDAIKAgwCCgAKAAwACgEMAQoBCgMMAwoDCgUKBQgFCgUIBwYJCAcGCQYJBAsGCQQLAg0CCwINAg0AAwABAAMAAwADAQMAAwADAAMBBQAFAQcBBwEHAwcBCQMJAQsDCwMLAw0FDQMNBQ8FDwURBxMFEwkTBxcJFwkXswEAIMgBCQYJBgkGBwYJCAcIBQgHCgUKBQoFDAEMAwwBDgEOABA=",
  "-":"BgABAQUq0AMArALEBAAAqwLDBAA=",
  ".":"BgABAWFOrAEADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsDCQELAAsBCwALAAsCCQALAgkECwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4=",
  "0":"BgABAoMB+APaCxwAHAEaARoDFgMYBRYFFAcUBxIJEgkQCRALEAsOCwwNDA0MDQoPCg0IDwgPBhEGDwYRBA8EEQIRAhMCEQITABMA4QUAEQETAREBEQMRAxEFEQURBREHDwkPBw8JDwsNCw0LDQ0NDQsNCw8JEQkRCREJEwcTBxUFFQUVAxUDFwEXARkAGQAZAhcCFwQXBBUGEwYTCBMIEQoRCg8KDwoPDA0MDQ4NDgsOCQ4JEAkQBxAHEAUSBRIDEgMSAxIDEgESARQAEgDiBQASAhQCEgISBBIEEgYSBhIGEggQChAIEAoQDBAMDgwODg4ODA4MEgwQChIKEggUCBQIFgYWBBYGGAQYAhgCGgILZIcDHTZBEkMRHTUA4QUeOUITRBIePADiBQ==",
  "2":"BgABAWpUwALUA44GAAoBCAEKAQgDBgMGBQYFBgUEBwQFBAUCBwIHAgUABwAHAAUBBwMFAQcFBQMHBQUHBQcFBwMJAwkBCQELAQsAC68CAAAUAhIAFAISBBQCEgQUBBIEEgYUCBIGEAgSChAKEAoQDBAMDg4ODgwQDBIMEgoSChQIFggWCBgGGAQaAhwCHAIWABQBFgEUARQDFAMSAxQFEgUSBxIHEAkQCRALDgsODQ4NDA8KDwwRCBMKEwgTBhUGFwQXBBcEGwAbABsAHQEftwPJBdIDAACpAhIPzwYAFBIArgI=",
  "1":"BgABARCsBLALAJ0LEhERADcA2QEANwATABQSAOYIpwEAALgCERKEBAASABER",
  "3":"BgABAZ0B/gbEC/sB0QQOAwwBDAMMAwwFCgMKBQoFCgUIBwoFCAcICQgJBgkICQYLCAsECwYLBA0GDwINBA8CDwQRAhECEQITABUCFQAVAH0AEQETAREBEQETAxEDEQURBREFDwcRBw8JDwkNCQ8LDQsNDQsNCw0LDwsPCREJEQcRBxMFFQUVBRUDFwEXARkAGQAZAhkCFwQVBBUEEwYTCBEIEQgRCg0MDwoNDA0OCw4LDgkQCRAHEAkQBRAFEgUSAxIDFAMSAxYBFAEWARYAFqQCAAALAgkCCQQHAgcGBwYHBgUIBQYDCAMIAwYDCAEIAQgACAAIAAgCCAIIAgYCCAQIBAgGBgYEBgQIBAoCCgAKAAwAvAEABgEIAAYBBgMGAwQDBgMEBQQDBAUCBQQFAgUABwIFAJkBAACmAaIB3ALbAgAREQDmAhIRggYA",
  "5":"BgABAaAB0APgBxIAFAESABIBEgMSARADEgMQAxIFEAcOBRAHDgkOCQ4JDgsMCwwLCgsKDQoPCA0IDwgPBhEEEwYTAhMEFwIXABcAiQIAEwETABEBEQMTAxEDDwMRBQ8FDwUPBw8JDQcNCQ0LDQsLCwsNCw0JDwkPCREHEQcTBxMFEwMVAxcDGQEZARkAFwAVAhUCFQQTBBMGEwYRCBEIDwoPCg8KDQwNDA0MCw4LDgkOCRAJEAcOBxAHEgUQBRIDEAMSAxIBEgEUARIAFLgCAAAFAgUABQIFBAUCBQQDBAUEAwYDBgMIAwgBCAEIAQoACAAIAgYACAQGAgQEBgQEBAQGBAQCBgIGAgYCBgIIAAYA4AEABgEIAAYBBgMGAQQDBgMEAwQFBAMCBQQFAgUABwIFAPkBAG+OAQCCBRESAgAAAuYFABMRAK8CjQMAAJ8BNgA=",
  "7":"BgABAQrQBsILhQOvCxQR7wIAEhK+AvYIiwMAAKgCERKwBgA=",
  "6":"BgABAsYBnAOqBxgGFgYYBBYEFgIWABQBFgEUAxQDFAUUBRIFEAcSCRAJEAkOCw4NDgsMDQoPCg8KDwgRCBEGEQYRBBMCEwITAhUAkwIBAAERAREBEQEPAxEFEQMPBREFDwcPBw8HDwkNCQ0LDQsNCwsNCw0LDQkPCQ8JDwcRBxEHEwUTAxMFFQEXAxcBGQAVABUCEwIVBBMEEQYTBhEIEQgPChEKDQoPDA0MDQwNDgsOCxALDgkQCRAHEgcQBxIFEgUSBRIBFAMSARIBFAASAOIFABACEgIQAhIEEAQQBhIGEAYQCBAKEAgOChAMDgwMDA4ODA4MDgwODBAKEAoQChIIEggSBhQGFgYUAhYCGAIYABoAGAEYARYBFgMUBRQFEgUSBxAHEAcQCQ4LDgkMCwwNDA0KDQgPCg0GEQgPBhEEEQQRBBMEEwITAhMCFQIVABWrAgAACgEIAQoBCAEGAwYDBgUGBQQFBAUEBQQFAgUABwIFAAUABwEFAAUBBQMFAwUDBQMFBQMFAwUBBQEHAQkBBwAJAJcBDUbpBDASFi4A4AETLC8SBQAvERUrAN8BFC0yEQQA",
  "8":"BgABA9gB6gPYCxYAFAEUARYBEgMUBRQFEgUSBxIHEAcSCQ4JEAkOCw4LDgsMDQwNCg0KDQoPCg8IDwgPBhEGEQQPBBMCEQIRABMAQwAxAA8BEQEPAREDDwMRAw8FEQUPBxEJDwkPCQ8NDw0PDQ8IBwYHCAcGBwgHBgkGBwYJBgcECQYJBAkGCQQJBAsECwQLBA0CCwINAg8CDwIPAA8AaQATAREBEwERAxEFEQURBREHEQcPBw8JDwkPCw8LDQsNDQ0LCw0LDwsNCQ8JDwcPBw8HEQURAxEFEQMRARMBEwFDABEAEwIRAhEEEQQRBg8GEQgPCA8KDwoPCg0MDQwNDAsOCw4LDgkQCRAJDgkQBxIHEAcSBRADEgMUAxIBFAEUABQAagAOAhAADgIOAg4EDAIOBAwEDAQMBgwECgYMBAoGCAYKBgoGCggKBgoICgYICAoICA0MCwwLDgsOCRAHEAcQBxIFEgUSAxIDEgMSARABEgASADIARAASAhICEgQSAhIGEAYSBhAIEAgQCBAKDgoODA4MDgwMDgwODA4KEAwQCBIKEggSCBQIFAYUBBQEFgQWAhYCGAANT78EFis0EwYANBIYLgC0ARcsMRQFADERGS0AswELogHtAhcuNxA3DRkvALMBGjE6ETYSGDIAtAE=",
  "9":"BgABAsYBpASeBBcFFQUXAxUDFQEVABMCFQITBBMEEwYRBhMGDwgRCg8KDwoNDA0OCwwNDgkQCRAJEAcSBxIFEgUSAxQBFAEUARYAlAICAAISAhICEgQSAhAGEgQQBhIGEAgSCA4IEAoOChAMDAwODAwODA4MEAoOChAKEAgSCBIIFAYUBBQGFgIYBBgCGgAWABYBFAEWAxQDEgUUBRIHEgcQCRIJEAkOCw4LDgsODQwNDA0MDwoPCg8IDwgRCBEGEQYRBhEEEQITAhECEwARAOEFAA8BEQEPAREDDwMPBREFDwUPBw8JDwcNCQ8LDQsLCw0NCw0LDQsNCw8JEQkPCREHEQcTBRMFEwUTARUBFQEXABkAFwIXAhcCFQQTBhMGEQYRCA8IDwgNCg8MCwoLDAsOCQ4JDgkQBxAHEAUQBRIFEgMSAxQDFAEUAxQAFgEWABamAgAACwIJAgkCCQIHBAcEBwYFBgUGAwYDBgMGAQgBBgEIAAgABgIIAgYCBgQGBAYEBgYGBgQIBAgECAIKAgoCCgAMAJgBDUXqBC8RFS0A3wEUKzARBgAwEhYsAOABEy4xEgMA",
  ":":"BgACAWE0rAEADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsDCQELAAsBCwALAAsCCQALAgkECwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4BYQDqBAAOAg4CDgIOBAwECgYMBgoGCggICAoICAgGCgYKBgoGCgQMBAoEDAQKAgwADAIMAAwADAEKAAwBCgMMAwoDCgMKBQoFCAUKBQgHCAkGBwgJBgkGCwYJBAsCDQINAg0ADQANAQ0BDQELAw0DCQULBQkFCQcHBwkHBQcHCQUJBQkFCQMLAwkDCwEJAwsACwELAAsACwIJAAsECQILBAkECQQJBgkGBwYHCAkGBwoFCAcKBQoFDAUKAQ4DDAEOAQ4ADg==",
  "x":"BgABARHmAoAJMIMBNLUBNrYBMIQB1AIA9QG/BI4CvwTVAgA5hgFBwAFFxwE1fdUCAI4CwATzAcAE1AIA",
  ";":"BgACAWEslgYADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsBCQMLAAsBCwALAAsCCQALBAkCCwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4BYwjxBAAOAg4CDAIOBAwECgYMBgoGCggICAgICAgICgYKBgoECgQMBAoECgIMAgoCDAIKAAoADAAKAQwBCgEKAwwDCgMKBQoFCAUKBQgHBgkIBwYJBgkECwYJBAsCDQILAg0CDQADAAEAAwADAAMBAwADAAMAAwEFAAUBBwEHAQcDBwEJAwkBCwMLAwsDDQUNAw0FDwUPBREHEwUTCRMHFwkXCRezAQAgyAEJBgkGCQYHBgkIBwgFCAcKBQoFCgUMAQwDDAEOAQ4AEA==",
  "=":"BgACAQUawAUA5gHEBAAA5QHDBAABBQC5AgDsAcQEAADrAcMEAA==",
  "B":"BgABA2e2BMQLFgAUARQBFAEUAxIDEgUSBRIFEAcQBxAJDgkOCQ4LDgsMCwwNDA0KDQgNCg0IDwYPBg8GDwQRBBEEEQIRAhMAEwAHAAkABwEHAAkBCQAHAQkBCQEHAQkBCQMJAwcDCQMJAwkFBwUJAwkHCQUHBQkHCQcJBwcHBwkHBwcJBwsHCQUQBQ4FDgcOCQ4JDAkMCwoNCg0IDwgRBhMEFQQXAhcCGwDJAQEvAysFJwklDSMPHREbFRkXFRsTHw8fCyUJJwcrAy0B6wMAEhIAoAsREuYDAAiRAYEElgEAKioSSA1EOR6JAQAA0wEJkAGPBSwSEiwAzAETKikSjwEAAMUCkAEA",
  "A":"BgABAg/KBfIBqQIAN98BEhHzAgAWEuwCngsREvwCABMR8gKdCxIR8QIAFBI54AEFlwGCBk3TA6ABAE3UAwMA",
  "?":"BgACAe4BsgaYCAAZABkBFwEXBRUDEwUTBxEHEQcPCQ8JDQkNCQ0LCwsLCwsLCQsJCwcNBwsHDQcLBQsFDQULAwkFCwMLAwkDCQMBAAABAQABAAEBAQABAAEAAQABAAABAQAAAQEAEwcBAQABAAMBAwADAAUABQAFAAcABwAFAAcABwAFAgcABQAHAAUAW7cCAABcABgBFgAUAhQAFAISAhACEAIQBA4EDgQMBgwGDAYMBgoICgYKCAgKCggICAgKBgoICgYMCAwGDAgOBg4GEAYQBgIAAgIEAAICBAACAgQCBAIKBAoGCAQKBggIBgYICAYIBggGCgQIBAoECAQKAggCCgIKAAgACgAKAAgBCAEKAwgDCAMIAwgFBgMIBQYHBAUGBQQFBAcCBQQHAgcCCQIHAgkCBwAJAgkACQAJAAkBCQAJAQsACQELAQsDCwELAwsDCwMLAwsDCwULAwsFCwMLBV2YAgYECAQKBAwGDAQMBhAIEAYSBhIIEgYUBhIEFgYUBBYEFgQWAhgCFgIYABYAGAAYARgBGAMWBRYHFgcWCRYLFA0IBQYDCAUIBwYFCAcGBwgHBgcICQYJCAkGCQYJCAsGCwYLBgsGDQYNBA0GDQQNBA8EDwQPAg8EEQIRAhEAEQITAWGpBesGAA4CDgIOAg4EDAQKBgwGCgYKCAgICggICAYKBgoGCgYKBAwECgQMBAoCDAAMAgwADAAMAQoADAEKAwwDCgMKAwoFCgUIBQoFCAcICQYHCAkGCQYLBgkECwINAg0CDQANAA0BDQENAQsDDQMJBQsFCQUJBwcHCQcFBwcJBQkFCQUJAwsDCQMLAwkBCwALAQsACwALAgkACwIJBAsECQQJBAkGCQYHBgcICQYHCgUIBwoFCgUMBQoBDgMMAQ4BDgAO",
  "C":"BgABAWmmA4ADAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgDWAgAAwQLVAgATABMCEQITBBEEEQQRBhEIEQgPCA8KDwoNCg0MDQwNDAsOCw4LDgkOCxAHEAkQBxIHEgUSBRIDEgEUARIBFAAUAMIFABQCFAISBBQEEgQSBhIIEggSCBAKEAoQCg4MDgwODA4ODA4MDgwQDA4KEggQChIIEggSBhIGFAQSAhQCEgIUAMYCAADBAsUCAAUABwEFAAUBBQMDAQUDAwMDAwMFAQMDBQEFAAUBBwAFAMEF",
  "L":"BgABAQmcBhISEdkFABIQALQLwgIAAIEJ9AIAAK8C",
  "D":"BgABAkeyBMQLFAAUARIBFAESAxIDEgMSBRIFEAcQBxAHDgkOCQ4LDgsMCwwNDA0KDwoPCg8IDwgRCBEGEwQTBBMEEwIVAhUAFwDBBQAXARcBFwMTAxUDEwUTBxEHEQcPCQ8JDwkNCw0LCwsLDQsNCQ0JDQcPBw8HDwcRBREFEQMRAxEDEwERARMBEwDfAwASEgCgCxES4AMACT6BAxEuKxKLAQAAvwaMAQAsEhIsAMIF",
  "F":"BgABARGABoIJ2QIAAIECsgIAEhIA4QIRErECAACvBBIR5QIAEhIAsgucBQASEgDlAhES",
  "E":"BgABARRkxAuWBQAQEgDlAhES0QIAAP0BtgIAEhIA5wIRFLUCAAD/AfACABISAOUCERLDBQASEgCyCw==",
  "G":"BgABAZsBjgeIAgMNBQ8FDQUNBQ0HCwcNBwsHCwkLCQsJCwsJCwsLCQsJDQkLBw0HDwcNBw8FDwUPAw8DEQMPAxEBEQERARMBEQAXABUCFwIVAhMEFQQTBhMGEwYRCBEIDwoRCg8KDwwNDA0MDQ4LDgkQCRAJEAcQBxIFEgUUBRQDFAMUARYBFgEYAMoFABQCFAASBBQCEgQSBBIEEgYSBhAGEAgQCBAKDgoOCg4MDgwMDgwOChAKEAoSCBIIFAgUBhQEGAYWAhgEGAIaAOoCAAC3AukCAAcABwEFAQUBBQMFAwMFAwUDBQEFAQcBBQEFAQUABwAFAMUFAAUCBwIFAgUCBQQFBAMGBQYDBgUGAwgDBgMIAQgDCAEIAQoBCAEIAAgACgAIAAgCCAIIAggECgQGBAgECAYIBgC6AnEAAJwCmAMAAJcF",
  "H":"BgABARbSB7ILAQAAnwsSEeUCABISAOAE5QEAAN8EEhHlAgASEgCiCxEQ5gIAEREA/QPmAQAAgAQPEOYCABER",
  "I":"BgABAQmuA7ILAJ8LFBHtAgAUEgCgCxMS7gIAExE=",
  "J":"BgABAWuqB7ILALEIABEBEwERAREDEwMRAxEFEQURBw8HEQcPCQ0LDwsNCw0NDQ0LDwsPCxEJEQkTCRMJFQcVBxcFFwMZAxsBGwEbAB8AHQIbAhsEGQYXBhcGFQgTCBMKEwoRDA8KDwwNDA0OCw4LDgkQCRAJEAcQBRIFEgUSAxQDEgESARIBFAESABIAgAEREtoCABERAn8ACQIHBAcEBwYHBgUIBQoDCgMKAwoDDAEKAQwBCgEMAAwACgAMAgoCDAIKBAoECgYKBggGBgYGCAQGBAgCCgAIALIIERLmAgAREQ==",
  "M":"BgACAQRm1gsUABMAAAABE5wIAQDBCxIR5QIAEhIA6gIK5gLVAe0B1wHuAQztAgDhAhIR5QIAEhIAxAsUAPoDtwT4A7YEFgA=",
  "K":"BgABAVXMCRoLBQsDCQMLAwsDCwMLAwsBCwELAQsBCwELAQ0ACwELAAsADQALAg0ACwILAA0CCwILAgsCDQQLBAsECwYNBAsGCwYLCAsGCwgJCgsICQoJCgkMCQwJDAkOCRALEAkQCRKZAdICUQAAiwQSEecCABQSAKALExLoAgAREQC3BEIA+AG4BAEAERKCAwAREdkCzQXGAYUDCA0KDQgJCgkMBwoFDAUMAQwBDgAMAg4CDAQOBAwGDghmlQI=",
  "O":"BgABAoMBsATaCxwAHAEaARoDGgMYBRYFFgcWBxQJEgkSCRILEAsODQ4NDg0MDwoNDA8KDwgPCBEIDwYRBg8GEQQRAhMCEQITABMA0QUAEQETAREBEQMTBREFEQURBxEHDwcRCQ8LDQsPCw0NDQ0NDwsPCw8LEQkTCRMJEwkVBxUHFwUXAxkDGQEbARsAGwAZAhkCGQQXBhcGFQYVCBUIEwoRChEMEQoRDA8MDQ4NDg0OCxAJEAsQCRAHEgcSBxIFFAMSAxIDEgEUARIAEgDSBQASAhQCEgISBBIEEgYSBhIIEggQCBAKEgwODBAMEA4ODg4QDhIMEAwSChQKFAgUCBYIFgYYBBoGGgQcAh4CHgILggGLAylCWxZbFSlBANEFKklcGVwYKkwA0gU=",
  "N":"BgABAQ+YA/oEAOUEEhHVAgASEgC+CxQAwATnBQDIBRMS2AIAExEAzQsRAL8ElgU=",
  "P":"BgABAkqoB5AGABcBFQEVAxMDEwMTBREHEQcRBw8JDwkNCQ0LDQsNCwsNCw0JDQkNCQ8HDwcPBxEFEQURAxEDEQMTAREBEwETAH8AAIMDEhHlAgASEgCgCxES1AMAFAAUARIAFAESAxIDEgMSAxIFEAUQBRAHDgkOCQ4JDgsMCwwNDA0KDQoNCg8IDwgRCBEGEwQTBBUEFQIXAhkAGQCzAgnBAsoCESwrEn8AANUDgAEALBISLgDYAg==",
  "R":"BgABAj9msgsREvYDABQAFAESARQBEgESAxIDEgUSBRAFEAcQBw4JDgkOCQ4LDAsMDQwLCg0KDwoNCA8IDwgPBhEEEwYTAhMEFQIXABcAowIAEwEVARMDEwMTBRMFEQcTBxELEQsRDQ8PDREPEQ0VC8QB/QMSEfkCABQSiQGyA3EAALEDFBHnAgASEgCgCwnCAscFogEALhISLACqAhEsLRKhAQAApQM=",
  "Q":"BgABA4YBvAniAbkB8wGZAYABBQUFAwUFBQUHBQUDBwUFBQcFBQMHBQcDBwUJAwcDCQMJAwkDCQMJAQsDCwMLAQsDCwENAw0BDQEPAA8BDwAPABsAGwIZAhcEGQQXBBUGFQgVCBMIEQoTChEKDwwPDA8ODQ4NDgsQCxAJEAkQBxIHEgUSBRQFFAMUARQDFAEWABYAxgUAEgIUAhICEgQSBBIGEgYSCBIIEAgQChIMDgwQDBAODg4OEA4SDBAMEgoUChQIFAgWCBYGGAQaBhoEHAIeAh4CHAAcARoBGgMaAxgFFgUWBxYHFAkSCRIJEgsQCw4NDg0ODQwPCg0MDwoPCA8IEQgPBhEGDwYRBBECEwIRAhMAEwC7BdgBrwEImQSyAwC6AylAWxZbFSk/AP0BjAK7AQeLAoMCGEc4J0wHVBbvAaYBAEM=",
  "S":"BgABAYMC8gOEBxIFEgUQBxIFEgcSBxIJEgcSCRIJEAkQCRALEAsOCw4NDg0MDQ4PDA0KEQoPChEKEQgRCBMGFQQTBBcCFQAXABkBEwARAREBEQMPAQ8DDwMPAw0DDQUNAw0FCwULBwsFCwUJBwsFCQcHBQkHCQUHBwcHBwUHBwUFBQcHBwUHAwcFEQsRCxMJEwkTBxMFEwUVBRUDFQMVARMBFwEVABUAFQIVAhUCFQQVBBUEEwYVBhMIEwgTCBMIEwgRCBMKEQgRCmK6AgwFDgUMAw4FEAUOBRAFEAUQBRAFEAMSAw4DEAMQAxABEAEOAQ4AEAIMAg4CDgQMBAwGCggKCAoKBgwGDgYQBBACCgAMAAoBCAMKBQgFCAcIBwgJCAsGCQgLCA0IDQgNCA8IDQgPCA8IDwgPChEIDwgPCBEKDwoPDBEMDwwPDg8ODw4NEA0QCxALEgsSCRIHEgcUBRQFGAUYAxgBGgEcAR4CJAYkBiAIIAweDBwQHBAYEhgUFBYUFhQWEBoQGg4aDBwKHAoeBh4GIAQgAiACIgEiASIFIgUiBSAJIgkgCyINZ58CBwQJAgkECwQLAgsECwINBA0CDQQNAg0CDQALAg0ADQANAAsBCwELAQsDCwULBQkFCQcHBwcJBwkFCwMLAw0BDQENAAsCCwQLBAkGCQgJCAkKBwoJCgcMBQoHDAcMBQwF",
  "V":"BgABARG2BM4DXrYEbKwDERL0AgAVEesCnQsSEfsCABQS8QKeCxES8gIAExFuqwNgtQQEAA==",
  "T":"BgABAQskxAv0BgAAtQKVAgAA+wgSEeUCABISAPwImwIAALYC",
  "U":"BgABAW76B7ALAKMIABcBFwMXARUFFQUTBxMHEwkRCREJEQsPDQ0LDw0NDwsPCw8LEQkPCRMJEQcTBxMFEwUVBRUDEwMXARUBFQEXABUAEwIVAhMCFQQTBBUEEwYTBhMIEwgRChEIEQwRDA8MDw4PDg0OCxANEAsSCRIJEgcUBxQHFAMWBRYBGAEYARgApggBAREU9AIAExMAAgClCAALAgkECQQHBAcIBwgHCAUKBQoDCgMKAwwBCgEMAQwADAAMAgoCDAIKAgoECgQKBggGCAYICAYKBAgCCgIMAgwApggAARMU9AIAExM=",
  "X":"BgABARmsCBISEYkDABQSS54BWYICXYkCRZUBEhGJAwAUEtYCzgXVAtIFExKIAwATEVClAVj3AVb0AVKqAREShgMAERHXAtEF2ALNBQ==",
  "W":"BgABARuODcQLERHpAp8LFBHlAgASEnW8A2+7AxIR6wIAFBKNA6ALERKSAwATEdQB7wZigARZ8AIREugCAA8RaKsDYsMDXsoDaqYDExLqAgA=",
  "Y":"BgABARK4BcQLhgMAERHnAvMGAKsEEhHnAgAUEgCsBOkC9AYREoYDABERWOEBUJsCUqICVtwBERI=",
  "Z":"BgABAQmAB8QLnwOBCaADAADBAusGAMgDggmhAwAAwgLGBgA=",
  "`":"BgABAQfqAd4JkQHmAQAOlgJCiAGpAgALiwIA",
  "c":"BgABAW3UA84GBQAFAQUABQEFAwMBBQMDAwMDAwUBAwMFAQUABQEHAAUAnQMABQIFAAUCBQQFAgMEBQQDBAMGAwQBBgMGAQYABgEGAPABABoMAMsCGw7tAQATABMCEwARAhMEEQIPBBEEDwQPBg8IDwYNCA0KDQoNCgsMCwwLDAkOCRAHDgcQBxIFEgUUBRQDFAEWAxgBGAAYAKQDABQCFAISBBQCEgYSBhAGEggQCBAIEAoQCg4MDAwODAwODAwKDgwQCg4IEAgQCBAIEAYSBhIGEgQSAhQCFAIUAOABABwOAM0CGQzbAQA=",
  "a":"BgABApoB8AYCxwF+BwkHCQcJCQkHBwkHBwcJBQkFBwUJBQkFCQMHBQkDCQMJAwcDCQEHAQkBBwEJAQcABwAHAQcABQAHAAUBBQAFABMAEwITAhEEEwQPBBEGDwgPCA0IDwoLCg0KCwwLDAsMCQ4JDgkOBw4HEAcQBRAFEAUSAxADEgESAxIBFAESABQAFAISAhQCEgQSBBIEEgYSBhIIEAgQChAIDgwODA4MDg4MDgwODBAMEAoSCBIKEggUCBQGFgYWBBgEGAIaAhoAcgAADgEMAQoBCgEIAwgDBgUEBQQFBAcCBwIHAgkCCQAJAKsCABcPAMwCHAvCAgAUABYBEgAUARIDFAMQAxIDEAUSBQ4FEAcOCRAJDAkOCwwLDA0MCwoNCg8IDwgPCA8GEQYRBhMEEwIXAhUCFwAZAIMGFwAKmQLqA38ATxchQwgnGiMwD1AMUDYAdg==",
  "b":"BgABAkqmBIIJGAAYARYBFgEUAxQDEgUSBRIFEAcQCQ4HDgkOCw4LDAsMDQoNCg0KDQgPBg8GDwYRBBEEEQQTBBECEwIVAhMAFQD/AgAZARcBFwEXAxUDEwUTBREFEQcPBw8JDwkNCQ0LDQsLCwsNCQ0JDQcPBw8HDwURAxEDEQMTAxMBEwMVARUAFQHPAwAUEgCWCxEY5gIAERkAowKCAQAJOvECESwrEn8AAJsEgAEALBISLgCeAw==",
  "d":"BgABAkryBgDLAXAREQ8NEQ0PDREJDwkRBw8FDwURAw8DDwERAw8BEQEPACMCHwQfCB0MGw4bEhcUFxgVGhEeDSANJAkmBSgDKgEuAIADABYCFAIUAhQCFAQUBBIGEgYSBhAIEAgQCBAKDgoODAwMDAwMDgoOCg4KEAgQCBIGEgYSBhQEFgQWBBYCGAIYAHwAAKQCERrmAgARFwCnCxcADOsCugJGMgDmA3sAKxERLQCfAwolHBUmBSQKBAA=",
  "e":"BgABAqMBigP+AgAJAgkCCQQHBAcGBwYFCAUIBQgDCgMIAQoDCAEKAQoACgAKAAoCCAIKAggECgQIBAgGCAYGBgQIBAoECAIKAAyiAgAAGQEXARcBFwMVBRMFEwURBxEHDwcPCQ8LDQkNCwsNCw0LDQkNBw8JDwcPBQ8FEQURAxEDEwMTAxMBFQAVARcALwIrBCkIJwwlDiESHxQbGBkaFR4TIA0iCyQJKAMqASwAggMAFAIUABIEFAISBBIEEgQSBhIGEAgQCBAIEAoODA4MDgwODgwQDBAKEAoSChIIFAgUCBYGGAQYBhoCGgQcAh4ALgEqAygFJgkkDSANHhEaFRgXFBsSHQ4fDCUIJwQpAi0AGQEXAxcDFQcTBRMJEQkPCw8LDQ0PDQsNDQ8LEQsRCxEJEwkTCRMJEwcTBxUHFQUVBRUHFQUVBRUHFwcVBRUHCs4BkAMfOEUURxEfMwBvbBhAGBwaBiA=",
  "h":"BgABAUHYBJAGAAYBBgAGAQYDBgEEAwYDBAMEBQQDAgUEBQIFAAUCBQB1AAC5BhIT5wIAFhQAlAsRGOYCABEZAKMCeAAYABgBFgEWARQDFAMSBRIFEgUQBxAJDgcOCQ4LDgsMCwwNCg0KDQoNCA8GDwYPBhEEEQQRBBMEEQITAhUCEwAVAO0FFhPnAgAUEgD+BQ==",
  "g":"BgABArkBkAeACQCNCw8ZERkRFxEVExMVERUPFQ8XDRcLGQkZBxsFGwUdAR0BDQALAA0ADQINAAsCDQANAg0CDQILAg0EDQINBA0GDQQNBg0EDQYNCA0GDwgNCA0IDQgPCg0KDwwNDA8MDw4PDqIB7gEQDRALEAkQCQ4JEAcOBw4FDgUOAwwFDgMMAQwBDAEMAQwACgEKAAoACAIIAAgCCAIGAggCBgIGBAYCBgQEAgYEAqIBAQADAAEBAwADAAMABQADAAUAAwAFAAMABQAFAAMABQA3ABMAEwIRAhMCEQQRBBEEEQYRBg8IDwgPCA0KDQoNCg0MCwwLDgsOCQ4JDgkQBxAHEgcSBRIDFAMWAxQBFgEYABgA/gIAFgIWAhQEFgQUBBIGFAgSCBIIEAoSChAKDgwODA4MDg4MDgwODA4KEAgQCBAIEgYSBhIEEgYSBBQCEgIUAhQCOgAQABABDgEQAQ4BEAMOAw4FDgUOBQwFDgcMBQ4HDAkMB4oBUBgACbsCzQYAnAR/AC0RES0AnQMSKy4RgAEA",
  "f":"BgABAUH8A6QJBwAHAAUABwEFAQcBBQEFAwUDBQMDAwMDAwUDAwMFAQUAwQHCAQAWEgDZAhUUwQEAAOMEFhftAgAWFADKCQoSChIKEAoQCg4KDgwOCgwMDAoKDAwMCgwIDAgMCAwIDAYOCAwEDgYMBA4GDAIOBA4CDgQOAg4CDgAOAg4ADgC2AQAcDgDRAhkQowEA",
  "i":"BgACAQlQABISALoIERLqAgAREQC5CBIR6QIAAWELyAoADgIOAgwEDgIKBgwGCgYKCAoGCAgICggIBggGCgYKBAoECgQMBAoCDAIMAgwCDAAMAAwADAEMAQoBDAMKAwoDCgUKBQgFCgUIBwgHCAcICQgJBgkECwQJBA0CCwANAA0ADQELAQ0BCwMJBQsFCQUJBwkFBwcHBwcJBQcFCQUJBQkDCQMLAwkBCwELAQsACwALAAsCCwILAgkCCwIJBAkECQQJBgcGCQYHCAcIBwgHCgUKBQwFCgMMAQwBDgEMAA4=",
  "j":"BgACAWFKyAoADgIOAgwEDgIKBgwGCgYKCAoGCAgICggIBggGCgYKBAoECgQMBAoCDAIMAgwCDAAMAAwADAEMAQoBDAMKAwoDCgUKBQgFCgUIBwgHCAcICQgJBgkECwQJBA0CCwANAA0ADQELAQ0BCwMJBQsFCQUJBwkFBwcHBwcJBQcFCQUJBQkDCQMLAwkBCwELAQsACwALAAsCCwILAgkCCwIJBAkECQQJBgcGCQYHCAcIBwgHCgUKBQwFCgMMAQwBDgEMAA4BO+YCnwwJEQkRCQ8JDwsNCQ0LDQkLCwsJCQsLCQkLBwsHCwcLBwsFCwcNAwsFDQMLBQ0BDQMNAQ0DDQENAQ0ADQENAA0AVwAbDQDSAhoPQgAIAAgABgAIAgYCCAIGAgYEBgQGBAQEBAQEBgQEBAYCBgC4CRES6gIAEREAowo=",
  "k":"BgABARKoA/QFIAC0AYoD5gIAjwK5BJICwwTfAgDDAbIDFwAAnwMSEeUCABISAJILERLmAgAREQCvBQ==",
  "n":"BgABAW1yggmQAU8GBAgEBgQGBgYCCAQGBAYEBgQIAgYECAQGAggEBgIIBAgCCAQIAggCCAIIAgoACAIKAAgCCgAKAgoADAAKAgwAFgAWARQAFAEUAxQDFAMSAxIFEgUQBRIHEAkOBxAJDgsOCwwLDA0MDQoPCA8IEQgRBhEGEwYVBBUEFQIXAhkCGQDtBRQR5QIAFBAA/AUACAEIAQYBCAMGBQQFBgUEBwQFBAcCBwIHAgcCCQIHAAcACQAHAQcABwMHAQUDBwMFAwUFBQUDBQEFAwcBBwAHAPkFEhHjAgASEgDwCBAA",
  "m":"BgABAZoBfoIJigFbDAwMCg4KDggOCA4IDgYQBhAGEAQQBBAEEAISAhACEgAmASQDJAciCyANHhEcFRwXDg4QDBAKEAwQCBAKEggSBhIGEgYSBBQEEgIUAhICFAAUABQBEgEUARIDEgMSAxIFEgUQBxAHEAcQBw4JDgkOCw4LDAsMDQoNCg8KDwgPCBEIEQYRBBMEEwQTAhMCFQAVAP0FEhHlAgASEgCCBgAIAQgBBgEGAwYFBgUEBQQHBAUEBwIHAgcCBwIJAAcABwAJAAcBBwEHAQUBBwMFAwUDBQMDBQMFAwUBBQEHAQcAgQYSEeUCABISAIIGAAgBCAEGAQYDBgUGBQQFBAcEBQQHAgcCBwIHAgkABwAHAAkABwEHAQcBBQEHAwUDBQMFAwMFAwUDBQEFAQcBBwCBBhIR5QIAEhIA8AgYAA==",
  "l":"BgABAQnAAwDrAgASFgDWCxEa6gIAERkA0wsUFw==",
  "y":"BgABAZ8BogeNAg8ZERkRFxEVExMVERUPFQ8XDRcLGQkZBxsFGwUdAR0BDQALAA0ADQINAAsCDQANAg0CDQILAg0EDQINBA0GDQQNBg0EDQYNCA0GDwgNCA0IDQgPCg0KDwwNDA8MDw4PDqIB7gEQDRALEAkQCQ4JEAcOBw4FDgUOAwwFDgMMAQwBDAEMAQwACgEKAAoACAIIAAgCCAIGAggCBgIGBAYCBgQEAgYEAqIBAQADAAEBAwADAAMABQADAAUAAwAFAAMABQAFAAMABQA3ABMAEwIRABECEwQRAg8EEQQPBBEGDwgNCA8IDQgNCg0MDQwLDAkOCw4JDgcQBxAHEgUSBRQFFAMWARgDGAEaABwA9AUTEuQCABEPAP8FAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgCAAQAAvAYREuICABMPAP0K",
  "q":"BgABAmj0A4YJFgAWARQAEgESAxADEAMOAw4FDgUMBQ4HDgcOBwwJDgmeAU4A2QwWGesCABYaAN4DAwADAAMBAwADAAUAAwADAAMABQAFAAUABwAHAQcACQAVABUCFQATAhUCEwQRAhMEEQQRBhEGDwgPCA8IDQoNDA0MCwwLDgkOCRAJEAkQBxIHEgUUBRYDFgMYARoBGgAcAP4CABYCFgIWBBYEFAQSBhQIEggSCBAKEgoQDA4MDgwODg4ODBAMDgwQChIIEAoSCBIGEgYUBhQEFAQWAhYCFgIWAApbkQYSKy4ReAAAjARTEjkRHykJMwDvAg==",
  "p":"BgABAmiCBIYJFgAWARYBFAEWAxQDEgUUBRIFEgcSBxAJEAkQCQ4LDgsOCwwNDA0KDwoPCg8IEQgRCBEGEwQTBhMCFQQVAhUAFQD9AgAbARkBFwMXAxcDEwUTBxMHEQcRCQ8JDQsNCw0LCw0LDQkPCQ0JDwURBxEFEQURAxMDEQMTARUBEwEVARUBFQAJAAcABwAFAAcABQAFAAMAAwADAAUAAwIDAAMAAwIDAADdAxYZ6wIAFhoA2gyeAU0OCgwIDgoMCA4GDgYMBg4GDgQQBBAEEgQUAhQCFgIWAApcoQMJNB8qNxJVEQCLBHgALhISLADwAg==",
  "o":"BgABAoMB8gOICRYAFgEWARQBFgMUAxIDFAUSBRIHEgcQBxAJEAkOCw4LDgsMDQwNCg8KDwoPCg8IEQgRBhMGEwQTBBMCFQIVABcAiwMAFwEVARUDEwMTAxMFEwcRBxEHDwkPCQ8LDQsNCw0NCw0LDwkNCw8HEQkPBxEHEQcRBRMFEwMTAxUDFQEVABUAFQAVAhUCFQITBBMEEwYTBhEGEQgRCA8KDwoPCg0KDQwNDAsOCw4JDgkQCRAJEgcSBxIFFAUUAxQDFgEWARYAFgCMAwAYAhYCFgQUBBQEFAYUCBIIEggQChAKEAwODA4MDg4MDgwQCg4KEgoQChIIEggSBhQGEgYUBBYEFAIWAhYCFgALYv0CHTZBFEMRHTcAjwMcNUITQhIiOACQAw==",
  "r":"BgACAQRigAkQAA8AAAABShAAhAFXDAwODAwKDgoOCBAIDgYQBhAEEAQQBBAEEAISABACEAAQAA4BEAAQARADEAEQAxADEAUSBRIHFAcUCxQLFA0WDVJFsQHzAQsMDQwLCgkICwgLCAkGCQYJBAkGBwIJBAcCBwQHAAcCBwAFAgcABQAHAQUABQEFAQUBBQEDAQUBAwMDAQMDAwEAmwYSEeMCABISAO4IEAA=",
  "u":"BgABAV2KBwGPAVANCQsHDQcNBw0FCwUNBQ0FDQMPAw8DEQMTARMBFQEVABUAFQITABMEEwITBBMEEQQRBhEGDwYRCA8KDQgPCg0MDQwLDAsOCRALDgcQBxIHEgUUBRQFFAMWAxgBGAEYARoA7gUTEuYCABMPAPsFAAcCBwIFBAcCBQYDBgUGAwgDBgMIAQgBCAEIAQoBCAAIAAoACAIIAggCCAIGBAgEBgQGBgYGBAYCBgQIAggACAD6BRES5AIAEREA7wgPAA==",
  "s":"BgABAasC/gLwBQoDCgMMBQ4DDgUOBRAFEAUSBRAHEgcQCRIJEAkSCxALEAsQDRANDg0ODw4PDA8MDwoRChEIEwYTBBcCFQIXABkBGQEXAxcFFQUTBRMHEwcRCREJDwkNCQ8LDQ0LCwsNCw0JDQkPBw8HDwUPBREDEQMRAREDEQETABEBEwARABMADwIRABECEQIRBBMCEwQVBBUEFQYVBhMIFwgVChUKFQxgsAIIAwYDCAMKAQgDCAMKAQoDCgEKAwoBCgMKAQwDCgEKAwoBDAMKAQoBCgEMAQoACgEKAAoBCgAKAQgACgAIAQgABgoECAIKAgoCCgAMAQoBDAUEBwIHBAcEBwIHBAkECQQJBAkECQYLBAkGCwYJBgsGCwYJCAsGCwgJBgsICQgLCAkICwgJCgkKCQoJCgcKCQwHDAcMBwwFDAcMAw4FDAMOAw4BDgMQARAAEAESABIAEgIQAg4CDgIOBA4CDgQMBAwEDAQMBgoECgYKBgoGCgYIBggGCAgIBggGBgYIBgYGBgYGBgYGBAgGBgQIBAYECAQQChIIEggSBhIEEgQSBBQCFAISABQAEgASABIAEgESARIBEAEQAxIDDgMQAxADDgUOBQwDDAMMAwoDCAMIAQYBe6cCAwIDAgUAAwIFAgUCBwIFAgcCBQIHAgUCBwIHAAUCBwIHAgUABwIHAgcABQIHAAcCBwAFAgUABQIFAAUABQIDAAEAAQABAQEAAQEBAQEBAQEBAQEDAQEAAwEBAQMAAwEDAAMBAwADAQMAAwABAQMAAwADAAEAAwIBAAMCAQQDAgE=",
  "t":"BgABAUe8BLACWAAaEADRAhsOaQANAA0ADwINAA0CDQANAg0CDQINBA0CCwYNBA0GCwYNBgsIDQgLCAsKCwgJDAsKCQwJDAkOCQ4HEAcSBxIHEgUUAOAEawAVEQDWAhYTbAAAygIVFOYCABUXAMUCogEAFhQA1QIVEqEBAADzAwIFBAMEBQQDBAMEAwYDBgMGAwYBCAEGAQgBBgEIAAgA",
  "w":"BgABARz8BsAEINYCKNgBERLuAgARD+8B3QgSEc0CABQSW7YCV7UCFBHJAgASEpMC3AgREvACABERmAHxBDDaAVeYAxES7gIAEREo1QE81wIIAA==",
  "z":"BgABAQ6cA9AGuQIAFw8AzAIaC9QFAAAr9wKjBuACABYQAMsCGQyZBgCaA9AG"
   }';
BEGIN

  IF font IS NULL THEN
    font := font_default;
  END IF;

  -- For character spacing, use m as guide size
  geom := ST_GeomFromTWKB(decode(font->>'m', 'base64'));
  m_width := ST_XMax(geom) - ST_XMin(geom);
  spacing := m_width / 12;

  letterarray := regexp_split_to_array(replace(letters, ' ', E'\t'), E'');
  FOREACH letter IN ARRAY letterarray
  LOOP
    geom := ST_GeomFromTWKB(decode(font->>(letter), 'base64'));
    -- Chars are not already zeroed out, so do it now
    geom := ST_Translate(geom, -1 * ST_XMin(geom), 0.0);
    -- unknown characters are treated as spaces
    IF geom IS NULL THEN
      -- spaces are a "quarter m" in width
      width := m_width / 3.5;
    ELSE
      width := (ST_XMax(geom) - ST_XMin(geom));
    END IF;
    geom := ST_Translate(geom, position, 0.0);
    -- Tighten up spacing when characters have a large gap
    -- between them like Yo or To
    adjustment := 0.0;
    IF prevgeom IS NOT NULL AND geom IS NOT NULL THEN
      dist = ST_Distance(prevgeom, geom);
      IF dist > spacing THEN
        adjustment = spacing - dist;
        geom := ST_Translate(geom, adjustment, 0.0);
      END IF;
    END IF;
    prevgeom := geom;
    position := position + width + spacing + adjustment;
    wordarr := array_append(wordarr, geom);
  END LOOP;
  -- apply the start point and scaling options
  wordgeom := ST_CollectionExtract(ST_Collect(wordarr));
  wordgeom := ST_Scale(wordgeom,
                text_height/font_default_height,
                text_height/font_default_height);
  return wordgeom;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 250
  SET "standard_conforming_strings"="on";
COMMENT ON FUNCTION "public"."st_letters"("letters" text, "font" json) IS 'args:  letters,  font - Returns the input letters rendered as geometry with a default start position at the origin and default text height of 100.';

-- ----------------------------
-- Function structure for st_linecrossingdirection
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry");
CREATE FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'ST_LineCrossingDirection'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_lineextend
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineextend"("geom" "public"."geometry", "distance_forward" float8, "distance_backward" float8);
CREATE FUNCTION "public"."st_lineextend"("geom" "public"."geometry", "distance_forward" float8, "distance_backward" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geometry_line_extend'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_lineextend"("geom" "public"."geometry", "distance_forward" float8, "distance_backward" float8) IS 'args: line, distance_forward, distance_backward=0.0 - Returns a line with the last and first segments extended the specified distance(s).';

-- ----------------------------
-- Function structure for st_linefromencodedpolyline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linefromencodedpolyline"("txtin" text, "nprecision" int4);
CREATE FUNCTION "public"."st_linefromencodedpolyline"("txtin" text, "nprecision" int4=5)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'line_from_encoded_polyline'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_linefrommultipoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linefrommultipoint"("public"."geometry");
CREATE FUNCTION "public"."st_linefrommultipoint"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_line_from_mpoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") IS 'args: aMultiPoint - Creates a LineString from a MultiPoint geometry.';

-- ----------------------------
-- Function structure for st_linefromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linefromtext"(text);
CREATE FUNCTION "public"."st_linefromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'LINESTRING'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_linefromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linefromtext"(text, int4);
CREATE FUNCTION "public"."st_linefromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'LINESTRING'
	THEN public.ST_GeomFromText($1,$2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_linefromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linefromwkb"(bytea);
CREATE FUNCTION "public"."st_linefromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'LINESTRING'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_linefromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linefromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_linefromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_lineinterpolatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineinterpolatepoint"("public"."geometry", float8);
CREATE FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_line_interpolate_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", float8) IS 'args: a_linestring, a_fraction - Returns a point interpolated along a line at a fractional location.';

-- ----------------------------
-- Function structure for st_lineinterpolatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineinterpolatepoint"(text, float8);
CREATE FUNCTION "public"."st_lineinterpolatepoint"(text, float8)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_LineInterpolatePoint($1::public.geometry, $2);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_lineinterpolatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineinterpolatepoint"("public"."geography", float8, "use_spheroid" bool);
CREATE FUNCTION "public"."st_lineinterpolatepoint"("public"."geography", float8, "use_spheroid" bool=true)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_line_interpolate_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geography", float8, "use_spheroid" bool) IS 'args: a_linestring, a_fraction, use_spheroid = true - Returns a point interpolated along a line at a fractional location.';

-- ----------------------------
-- Function structure for st_lineinterpolatepoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineinterpolatepoints"("public"."geography", float8, "use_spheroid" bool, "repeat" bool);
CREATE FUNCTION "public"."st_lineinterpolatepoints"("public"."geography", float8, "use_spheroid" bool=true, "repeat" bool=true)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_line_interpolate_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geography", float8, "use_spheroid" bool, "repeat" bool) IS 'args: a_linestring, a_fraction, use_spheroid = true, repeat = true - Returns points interpolated along a line at a fractional interval.';

-- ----------------------------
-- Function structure for st_lineinterpolatepoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineinterpolatepoints"(text, float8);
CREATE FUNCTION "public"."st_lineinterpolatepoints"(text, float8)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_LineInterpolatePoints($1::public.geometry, $2);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_lineinterpolatepoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_lineinterpolatepoints"("public"."geometry", float8, "repeat" bool);
CREATE FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", float8, "repeat" bool=true)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_line_interpolate_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", float8, "repeat" bool) IS 'args: a_linestring, a_fraction, repeat - Returns points interpolated along a line at a fractional interval.';

-- ----------------------------
-- Function structure for st_linelocatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linelocatepoint"(text, text);
CREATE FUNCTION "public"."st_linelocatepoint"(text, text)
  RETURNS "pg_catalog"."float8" AS $BODY$ SELECT public.ST_LineLocatePoint($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_linelocatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_line_locate_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: a_linestring, a_point - Returns the fractional location of the closest point on a line to a point.';

-- ----------------------------
-- Function structure for st_linelocatepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linelocatepoint"("public"."geography", "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_linelocatepoint"("public"."geography", "public"."geography", "use_spheroid" bool=true)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_line_locate_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_linelocatepoint"("public"."geography", "public"."geography", "use_spheroid" bool) IS 'args: a_linestring, a_point, use_spheroid = true - Returns the fractional location of the closest point on a line to a point.';

-- ----------------------------
-- Function structure for st_linemerge
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linemerge"("public"."geometry", bool);
CREATE FUNCTION "public"."st_linemerge"("public"."geometry", bool)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'linemerge'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_linemerge"("public"."geometry", bool) IS 'args: amultilinestring, directed - Return the lines formed by sewing together a MultiLineString.';

-- ----------------------------
-- Function structure for st_linemerge
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linemerge"("public"."geometry");
CREATE FUNCTION "public"."st_linemerge"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'linemerge'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_linemerge"("public"."geometry") IS 'args: amultilinestring - Return the lines formed by sewing together a MultiLineString.';

-- ----------------------------
-- Function structure for st_linestringfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linestringfromwkb"(bytea);
CREATE FUNCTION "public"."st_linestringfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'LINESTRING'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_linestringfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linestringfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_linestringfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_linesubstring
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linesubstring"(text, float8, float8);
CREATE FUNCTION "public"."st_linesubstring"(text, float8, float8)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_LineSubstring($1::public.geometry, $2, $3);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_linesubstring
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linesubstring"("public"."geometry", float8, float8);
CREATE FUNCTION "public"."st_linesubstring"("public"."geometry", float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_line_substring'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_linesubstring"("public"."geometry", float8, float8) IS 'args: a_linestring, startfraction, endfraction - Returns the part of a line between two fractional locations.';

-- ----------------------------
-- Function structure for st_linesubstring
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linesubstring"("public"."geography", float8, float8);
CREATE FUNCTION "public"."st_linesubstring"("public"."geography", float8, float8)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_line_substring'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_linesubstring"("public"."geography", float8, float8) IS 'args: a_linestring, startfraction, endfraction - Returns the part of a line between two fractional locations.';

-- ----------------------------
-- Function structure for st_linetocurve
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_linetocurve"("geometry" "public"."geometry");
CREATE FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_line_desegmentize'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") IS 'args: geomANoncircular - Converts a linear geometry to a curved geometry.';

-- ----------------------------
-- Function structure for st_locatealong
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_locatealong"("geometry" "public"."geometry", "measure" float8, "leftrightoffset" float8);
CREATE FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" float8, "leftrightoffset" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_LocateAlong'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" float8, "leftrightoffset" float8) IS 'args: geom_with_measure, measure, offset = 0 - Returns the point(s) on a geometry that match a measure value.';

-- ----------------------------
-- Function structure for st_locatebetween
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" float8, "tomeasure" float8, "leftrightoffset" float8);
CREATE FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" float8, "tomeasure" float8, "leftrightoffset" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_LocateBetween'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" float8, "tomeasure" float8, "leftrightoffset" float8) IS 'args: geom, measure_start, measure_end, offset = 0 - Returns the portions of a geometry that match a measure range.';

-- ----------------------------
-- Function structure for st_locatebetweenelevations
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" float8, "toelevation" float8);
CREATE FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" float8, "toelevation" float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_LocateBetweenElevations'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" float8, "toelevation" float8) IS 'args: geom, elevation_start, elevation_end - Returns the portions of a geometry that lie in an elevation (Z) range.';

-- ----------------------------
-- Function structure for st_longestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$SELECT public._ST_LongestLine(public.ST_ConvexHull($1), public.ST_ConvexHull($2))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 2D longest line between two geometries.';

-- ----------------------------
-- Function structure for st_m
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_m"("public"."geometry");
CREATE FUNCTION "public"."st_m"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_m_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_m"("public"."geometry") IS 'args: a_point - Returns the M coordinate of a Point.';

-- ----------------------------
-- Function structure for st_makebox2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."box2d" AS '$libdir/postgis-3', 'BOX2D_construct'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: pointLowLeft, pointUpRight - Creates a BOX2D defined by two 2D point geometries.';

-- ----------------------------
-- Function structure for st_makeenvelope
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makeenvelope"(float8, float8, float8, float8, int4);
CREATE FUNCTION "public"."st_makeenvelope"(float8, float8, float8, float8, int4=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_MakeEnvelope'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makeenvelope"(float8, float8, float8, float8, int4) IS 'args: xmin, ymin, xmax, ymax, srid=unknown - Creates a rectangular Polygon from minimum and maximum coordinates.';

-- ----------------------------
-- Function structure for st_makeline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makeline"("public"."_geometry");
CREATE FUNCTION "public"."st_makeline"("public"."_geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makeline_garray'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makeline"("public"."_geometry") IS 'args: geoms_array - Creates a LineString from Point, MultiPoint, or LineString geometries.';

-- ----------------------------
-- Function structure for st_makeline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makeline'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: geom1, geom2 - Creates a LineString from Point, MultiPoint, or LineString geometries.';

-- ----------------------------
-- Function structure for st_makepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makepoint"(float8, float8, float8);
CREATE FUNCTION "public"."st_makepoint"(float8, float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makepoint"(float8, float8, float8) IS 'args: x, y, z - Creates a 2D, 3DZ or 4D Point.';

-- ----------------------------
-- Function structure for st_makepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makepoint"(float8, float8, float8, float8);
CREATE FUNCTION "public"."st_makepoint"(float8, float8, float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makepoint"(float8, float8, float8, float8) IS 'args: x, y, z, m - Creates a 2D, 3DZ or 4D Point.';

-- ----------------------------
-- Function structure for st_makepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makepoint"(float8, float8);
CREATE FUNCTION "public"."st_makepoint"(float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makepoint"(float8, float8) IS 'args: x, y - Creates a 2D, 3DZ or 4D Point.';

-- ----------------------------
-- Function structure for st_makepointm
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makepointm"(float8, float8, float8);
CREATE FUNCTION "public"."st_makepointm"(float8, float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoint3dm'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makepointm"(float8, float8, float8) IS 'args: x, y, m - Creates a Point from X, Y and M values.';

-- ----------------------------
-- Function structure for st_makepolygon
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makepolygon"("public"."geometry");
CREATE FUNCTION "public"."st_makepolygon"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makepolygon"("public"."geometry") IS 'args: linestring - Creates a Polygon from a shell and optional list of holes.';

-- ----------------------------
-- Function structure for st_makepolygon
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makepolygon"("public"."geometry", "public"."_geometry");
CREATE FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."_geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."_geometry") IS 'args: outerlinestring, interiorlinestrings - Creates a Polygon from a shell and optional list of holes.';

-- ----------------------------
-- Function structure for st_makevalid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makevalid"("public"."geometry");
CREATE FUNCTION "public"."st_makevalid"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_MakeValid'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_makevalid"("public"."geometry") IS 'args: input - Attempts to make an invalid geometry valid without losing vertices.';

-- ----------------------------
-- Function structure for st_makevalid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_makevalid"("geom" "public"."geometry", "params" text);
CREATE FUNCTION "public"."st_makevalid"("geom" "public"."geometry", "params" text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_MakeValid'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_makevalid"("geom" "public"."geometry", "params" text) IS 'args: input, params - Attempts to make an invalid geometry valid without losing vertices.';

-- ----------------------------
-- Function structure for st_maxdistance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."float8" AS $BODY$SELECT public._ST_MaxDistance(public.ST_ConvexHull($1), public.ST_ConvexHull($2))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Returns the 2D largest distance between two geometries in projected units.';

-- ----------------------------
-- Function structure for st_maximuminscribedcircle
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" float8);
CREATE FUNCTION "public"."st_maximuminscribedcircle"(IN "public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" float8)
  RETURNS "pg_catalog"."record" AS '$libdir/postgis-3', 'ST_MaximumInscribedCircle'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" float8) IS 'args: geom - Computes the largest circle contained within a geometry.';

-- ----------------------------
-- Function structure for st_memsize
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_memsize"("public"."geometry");
CREATE FUNCTION "public"."st_memsize"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_mem_size'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_memsize"("public"."geometry") IS 'args: geomA - Returns the amount of memory space a geometry takes.';

-- ----------------------------
-- Function structure for st_minimumboundingcircle
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" int4);
CREATE FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" int4=48)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_MinimumBoundingCircle'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" int4) IS 'args: geomA, num_segs_per_qt_circ=48 - Returns the smallest circle polygon that contains a geometry.';

-- ----------------------------
-- Function structure for st_minimumboundingradius
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" float8);
CREATE FUNCTION "public"."st_minimumboundingradius"(IN "public"."geometry", OUT "center" "public"."geometry", OUT "radius" float8)
  RETURNS "pg_catalog"."record" AS '$libdir/postgis-3', 'ST_MinimumBoundingRadius'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" float8) IS 'args: geom - Returns the center point and radius of the smallest circle that contains a geometry.';

-- ----------------------------
-- Function structure for st_minimumclearance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_minimumclearance"("public"."geometry");
CREATE FUNCTION "public"."st_minimumclearance"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'ST_MinimumClearance'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_minimumclearance"("public"."geometry") IS 'args: g - Returns the minimum clearance of a geometry, a measure of a geometrys robustness.';

-- ----------------------------
-- Function structure for st_minimumclearanceline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_minimumclearanceline"("public"."geometry");
CREATE FUNCTION "public"."st_minimumclearanceline"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_MinimumClearanceLine'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") IS 'args: g - Returns the two-point LineString spanning a geometrys minimum clearance.';

-- ----------------------------
-- Function structure for st_mlinefromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mlinefromtext"(text, int4);
CREATE FUNCTION "public"."st_mlinefromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE
	WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTILINESTRING'
	THEN public.ST_GeomFromText($1,$2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_mlinefromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mlinefromtext"(text);
CREATE FUNCTION "public"."st_mlinefromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTILINESTRING'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_mlinefromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mlinefromwkb"(bytea);
CREATE FUNCTION "public"."st_mlinefromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_mlinefromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mlinefromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_mlinefromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_mpointfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpointfromtext"(text, int4);
CREATE FUNCTION "public"."st_mpointfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTIPOINT'
	THEN ST_GeomFromText($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_mpointfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpointfromtext"(text);
CREATE FUNCTION "public"."st_mpointfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTIPOINT'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_mpointfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpointfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_mpointfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOINT'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_mpointfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpointfromwkb"(bytea);
CREATE FUNCTION "public"."st_mpointfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOINT'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_mpolyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpolyfromtext"(text);
CREATE FUNCTION "public"."st_mpolyfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTIPOLYGON'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_mpolyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpolyfromtext"(text, int4);
CREATE FUNCTION "public"."st_mpolyfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTIPOLYGON'
	THEN public.ST_GeomFromText($1,$2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_mpolyfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpolyfromwkb"(bytea);
CREATE FUNCTION "public"."st_mpolyfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for st_mpolyfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_mpolyfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_mpolyfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_multi
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multi"("public"."geometry");
CREATE FUNCTION "public"."st_multi"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_force_multi'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_multi"("public"."geometry") IS 'args: geom - Return the geometry as a MULTI* geometry.';

-- ----------------------------
-- Function structure for st_multilinefromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multilinefromwkb"(bytea);
CREATE FUNCTION "public"."st_multilinefromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_multilinestringfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multilinestringfromtext"(text, int4);
CREATE FUNCTION "public"."st_multilinestringfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_MLineFromText($1, $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_multilinestringfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multilinestringfromtext"(text);
CREATE FUNCTION "public"."st_multilinestringfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_MLineFromText($1)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_multipointfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipointfromtext"(text);
CREATE FUNCTION "public"."st_multipointfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_MPointFromText($1)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_multipointfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipointfromwkb"(bytea);
CREATE FUNCTION "public"."st_multipointfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOINT'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_multipointfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipointfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_multipointfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_multipolyfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipolyfromwkb"(bytea);
CREATE FUNCTION "public"."st_multipolyfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_multipolyfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipolyfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_multipolyfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_multipolygonfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipolygonfromtext"(text);
CREATE FUNCTION "public"."st_multipolygonfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_MPolyFromText($1)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_multipolygonfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_multipolygonfromtext"(text, int4);
CREATE FUNCTION "public"."st_multipolygonfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_MPolyFromText($1, $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_ndims
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ndims"("public"."geometry");
CREATE FUNCTION "public"."st_ndims"("public"."geometry")
  RETURNS "pg_catalog"."int2" AS '$libdir/postgis-3', 'LWGEOM_ndims'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_ndims"("public"."geometry") IS 'args: g1 - Returns the coordinate dimension of a geometry.';

-- ----------------------------
-- Function structure for st_node
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_node"("g" "public"."geometry");
CREATE FUNCTION "public"."st_node"("g" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Node'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_node"("g" "public"."geometry") IS 'args: geom - Nodes a collection of lines.';

-- ----------------------------
-- Function structure for st_normalize
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_normalize"("geom" "public"."geometry");
CREATE FUNCTION "public"."st_normalize"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Normalize'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") IS 'args: geom - Return the geometry in its canonical form.';

-- ----------------------------
-- Function structure for st_npoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_npoints"("public"."geometry");
CREATE FUNCTION "public"."st_npoints"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_npoints'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_npoints"("public"."geometry") IS 'args: g1 - Returns the number of points (vertices) in a geometry.';

-- ----------------------------
-- Function structure for st_nrings
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_nrings"("public"."geometry");
CREATE FUNCTION "public"."st_nrings"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_nrings'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_nrings"("public"."geometry") IS 'args: geomA - Returns the number of rings in a polygonal geometry.';

-- ----------------------------
-- Function structure for st_numgeometries
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_numgeometries"("public"."geometry");
CREATE FUNCTION "public"."st_numgeometries"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_numgeometries_collection'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_numgeometries"("public"."geometry") IS 'args: geom - Returns the number of elements in a geometry collection.';

-- ----------------------------
-- Function structure for st_numinteriorring
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_numinteriorring"("public"."geometry");
CREATE FUNCTION "public"."st_numinteriorring"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_numinteriorrings_polygon'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_numinteriorring"("public"."geometry") IS 'args: a_polygon - Returns the number of interior rings (holes) of a Polygon. Aias for ST_NumInteriorRings';

-- ----------------------------
-- Function structure for st_numinteriorrings
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_numinteriorrings"("public"."geometry");
CREATE FUNCTION "public"."st_numinteriorrings"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_numinteriorrings_polygon'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") IS 'args: a_polygon - Returns the number of interior rings (holes) of a Polygon.';

-- ----------------------------
-- Function structure for st_numpatches
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_numpatches"("public"."geometry");
CREATE FUNCTION "public"."st_numpatches"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS $BODY$
	SELECT CASE WHEN public.ST_GeometryType($1) = 'ST_PolyhedralSurface'
	THEN public.ST_NumGeometries($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_numpatches"("public"."geometry") IS 'args: g1 - Return the number of faces on a Polyhedral Surface. Will return null for non-polyhedral geometries.';

-- ----------------------------
-- Function structure for st_numpoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_numpoints"("public"."geometry");
CREATE FUNCTION "public"."st_numpoints"("public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_numpoints_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_numpoints"("public"."geometry") IS 'args: g1 - Returns the number of points in a LineString or CircularString.';

-- ----------------------------
-- Function structure for st_offsetcurve
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_offsetcurve"("line" "public"."geometry", "distance" float8, "params" text);
CREATE FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" float8, "params" text=''::text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_OffsetCurve'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" float8, "params" text) IS 'args: line, signed_distance, style_parameters='' - Returns an offset line at a given distance and side from an input line.';

-- ----------------------------
-- Function structure for st_orderingequals
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_same'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_orientedenvelope
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_orientedenvelope"("public"."geometry");
CREATE FUNCTION "public"."st_orientedenvelope"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_OrientedEnvelope'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") IS 'args: geom - Returns a minimum-area rectangle containing a geometry.';

-- ----------------------------
-- Function structure for st_overlaps
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'overlaps'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_patchn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_patchn"("public"."geometry", int4);
CREATE FUNCTION "public"."st_patchn"("public"."geometry", int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.ST_GeometryType($1) = 'ST_PolyhedralSurface'
	THEN public.ST_GeometryN($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_patchn"("public"."geometry", int4) IS 'args: geomA, n - Returns the Nth geometry (face) of a PolyhedralSurface.';

-- ----------------------------
-- Function structure for st_perimeter
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_perimeter"("public"."geometry");
CREATE FUNCTION "public"."st_perimeter"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_perimeter2d_poly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_perimeter"("public"."geometry") IS 'args: g1 - Returns the length of the boundary of a polygonal geometry or geography.';

-- ----------------------------
-- Function structure for st_perimeter
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" bool=true)
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'geography_perimeter'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" bool) IS 'args: geog, use_spheroid = true - Returns the length of the boundary of a polygonal geometry or geography.';

-- ----------------------------
-- Function structure for st_perimeter2d
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_perimeter2d"("public"."geometry");
CREATE FUNCTION "public"."st_perimeter2d"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_perimeter2d_poly'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_perimeter2d"("public"."geometry") IS 'args: geomA - Returns the 2D perimeter of a polygonal geometry. Alias for ST_Perimeter.';

-- ----------------------------
-- Function structure for st_point
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_point"(float8, float8, "srid" int4);
CREATE FUNCTION "public"."st_point"(float8, float8, "srid" int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Point'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_point"(float8, float8, "srid" int4) IS 'args: x, y, srid=unknown - Creates a Point with X, Y and SRID values.';

-- ----------------------------
-- Function structure for st_point
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_point"(float8, float8);
CREATE FUNCTION "public"."st_point"(float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_makepoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_point"(float8, float8) IS 'args: x, y - Creates a Point with X, Y and SRID values.';

-- ----------------------------
-- Function structure for st_pointfromgeohash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointfromgeohash"(text, int4);
CREATE FUNCTION "public"."st_pointfromgeohash"(text, int4=NULL::integer)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'point_from_geohash'
  LANGUAGE c IMMUTABLE
  COST 50;

-- ----------------------------
-- Function structure for st_pointfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointfromtext"(text);
CREATE FUNCTION "public"."st_pointfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'POINT'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_pointfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointfromtext"(text, int4);
CREATE FUNCTION "public"."st_pointfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'POINT'
	THEN public.ST_GeomFromText($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_pointfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointfromwkb"(bytea);
CREATE FUNCTION "public"."st_pointfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POINT'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_pointfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_pointfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'POINT'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_pointinsidecircle
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointinsidecircle"("public"."geometry", float8, float8, float8);
CREATE FUNCTION "public"."st_pointinsidecircle"("public"."geometry", float8, float8, float8)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'LWGEOM_inside_circle_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_pointm
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointm"("xcoordinate" float8, "ycoordinate" float8, "mcoordinate" float8, "srid" int4);
CREATE FUNCTION "public"."st_pointm"("xcoordinate" float8, "ycoordinate" float8, "mcoordinate" float8, "srid" int4=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_PointM'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_pointm"("xcoordinate" float8, "ycoordinate" float8, "mcoordinate" float8, "srid" int4) IS 'args: x, y, m, srid=unknown - Creates a Point with X, Y, M and SRID values.';

-- ----------------------------
-- Function structure for st_pointn
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointn"("public"."geometry", int4);
CREATE FUNCTION "public"."st_pointn"("public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_pointn_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_pointn"("public"."geometry", int4) IS 'args: a_linestring, n - Returns the Nth point in the first LineString or circular LineString in a geometry.';

-- ----------------------------
-- Function structure for st_pointonsurface
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointonsurface"("public"."geometry");
CREATE FUNCTION "public"."st_pointonsurface"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pointonsurface'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_pointonsurface"("public"."geometry") IS 'args: g1 - Computes a point guaranteed to lie in a polygon, or on a geometry.';

-- ----------------------------
-- Function structure for st_points
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_points"("public"."geometry");
CREATE FUNCTION "public"."st_points"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Points'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_points"("public"."geometry") IS 'args: geom - Returns a MultiPoint containing the coordinates of a geometry.';

-- ----------------------------
-- Function structure for st_pointz
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointz"("xcoordinate" float8, "ycoordinate" float8, "zcoordinate" float8, "srid" int4);
CREATE FUNCTION "public"."st_pointz"("xcoordinate" float8, "ycoordinate" float8, "zcoordinate" float8, "srid" int4=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_PointZ'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_pointz"("xcoordinate" float8, "ycoordinate" float8, "zcoordinate" float8, "srid" int4) IS 'args: x, y, z, srid=unknown - Creates a Point with X, Y, Z and SRID values.';

-- ----------------------------
-- Function structure for st_pointzm
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_pointzm"("xcoordinate" float8, "ycoordinate" float8, "zcoordinate" float8, "mcoordinate" float8, "srid" int4);
CREATE FUNCTION "public"."st_pointzm"("xcoordinate" float8, "ycoordinate" float8, "zcoordinate" float8, "mcoordinate" float8, "srid" int4=0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_PointZM'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_pointzm"("xcoordinate" float8, "ycoordinate" float8, "zcoordinate" float8, "mcoordinate" float8, "srid" int4) IS 'args: x, y, z, m, srid=unknown - Creates a Point with X, Y, Z, M and SRID values.';

-- ----------------------------
-- Function structure for st_polyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polyfromtext"(text);
CREATE FUNCTION "public"."st_polyfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'POLYGON'
	THEN public.ST_GeomFromText($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_polyfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polyfromtext"(text, int4);
CREATE FUNCTION "public"."st_polyfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'POLYGON'
	THEN public.ST_GeomFromText($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_polyfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polyfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_polyfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'POLYGON'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_polyfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polyfromwkb"(bytea);
CREATE FUNCTION "public"."st_polyfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POLYGON'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_polygon
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polygon"("public"."geometry", int4);
CREATE FUNCTION "public"."st_polygon"("public"."geometry", int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT public.ST_SetSRID(public.ST_MakePolygon($1), $2)
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_polygon"("public"."geometry", int4) IS 'args: lineString, srid - Creates a Polygon from a LineString with a specified SRID.';

-- ----------------------------
-- Function structure for st_polygonfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polygonfromtext"(text, int4);
CREATE FUNCTION "public"."st_polygonfromtext"(text, int4)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_PolyFromText($1, $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_polygonfromtext
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polygonfromtext"(text);
CREATE FUNCTION "public"."st_polygonfromtext"(text)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_PolyFromText($1)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_polygonfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polygonfromwkb"(bytea, int4);
CREATE FUNCTION "public"."st_polygonfromwkb"(bytea, int4)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1,$2)) = 'POLYGON'
	THEN public.ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_polygonfromwkb
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polygonfromwkb"(bytea);
CREATE FUNCTION "public"."st_polygonfromwkb"(bytea)
  RETURNS "public"."geometry" AS $BODY$
	SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POLYGON'
	THEN public.ST_GeomFromWKB($1)
	ELSE NULL END
	$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_polygonize
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_polygonize"("public"."_geometry");
CREATE FUNCTION "public"."st_polygonize"("public"."_geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'polygonize_garray'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_polygonize"("public"."_geometry") IS 'args: geom_array - Computes a collection of polygons formed from the linework of a set of geometries.';

-- ----------------------------
-- Function structure for st_project
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_project"("geom1" "public"."geometry", "geom2" "public"."geometry", "distance" float8);
CREATE FUNCTION "public"."st_project"("geom1" "public"."geometry", "geom2" "public"."geometry", "distance" float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geometry_project_geometry'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_project"("geom1" "public"."geometry", "geom2" "public"."geometry", "distance" float8) IS 'args: g1, g2, distance - Returns a point projected from a start point by a distance and bearing (azimuth).';

-- ----------------------------
-- Function structure for st_project
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_project"("geog_from" "public"."geography", "geog_to" "public"."geography", "distance" float8);
CREATE FUNCTION "public"."st_project"("geog_from" "public"."geography", "geog_to" "public"."geography", "distance" float8)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_project_geography'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_project"("geog_from" "public"."geography", "geog_to" "public"."geography", "distance" float8) IS 'args: g1, g2, distance - Returns a point projected from a start point by a distance and bearing (azimuth).';

-- ----------------------------
-- Function structure for st_project
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_project"("geog" "public"."geography", "distance" float8, "azimuth" float8);
CREATE FUNCTION "public"."st_project"("geog" "public"."geography", "distance" float8, "azimuth" float8)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_project'
  LANGUAGE c IMMUTABLE
  COST 250;
COMMENT ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" float8, "azimuth" float8) IS 'args: g1, distance, azimuth - Returns a point projected from a start point by a distance and bearing (azimuth).';

-- ----------------------------
-- Function structure for st_project
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_project"("geom1" "public"."geometry", "distance" float8, "azimuth" float8);
CREATE FUNCTION "public"."st_project"("geom1" "public"."geometry", "distance" float8, "azimuth" float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'geometry_project_direction'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_project"("geom1" "public"."geometry", "distance" float8, "azimuth" float8) IS 'args: g1, distance, azimuth - Returns a point projected from a start point by a distance and bearing (azimuth).';

-- ----------------------------
-- Function structure for st_quantizecoordinates
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" int4, "prec_y" int4, "prec_z" int4, "prec_m" int4);
CREATE FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" int4, "prec_y" int4=NULL::integer, "prec_z" int4=NULL::integer, "prec_m" int4=NULL::integer)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_QuantizeCoordinates'
  LANGUAGE c IMMUTABLE
  COST 250;
COMMENT ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" int4, "prec_y" int4, "prec_z" int4, "prec_m" int4) IS 'args: g, prec_x, prec_y, prec_z, prec_m - Sets least significant bits of coordinates to zero';

-- ----------------------------
-- Function structure for st_reduceprecision
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" float8);
CREATE FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_ReducePrecision'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" float8) IS 'args: g, gridsize - Returns a valid geometry with points rounded to a grid tolerance.';

-- ----------------------------
-- Function structure for st_relate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", text);
CREATE FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", text)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'relate_pattern'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_relate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", int4);
CREATE FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", int4)
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'relate_full'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_relate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'relate_full'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_relatematch
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_relatematch"(text, text);
CREATE FUNCTION "public"."st_relatematch"(text, text)
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'ST_RelateMatch'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_removepoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_removepoint"("public"."geometry", int4);
CREATE FUNCTION "public"."st_removepoint"("public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_removepoint'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_removepoint"("public"."geometry", int4) IS 'args: linestring, offset - Remove a point from a linestring.';

-- ----------------------------
-- Function structure for st_removerepeatedpoints
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" float8);
CREATE FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_RemoveRepeatedPoints'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" float8) IS 'args: geom, tolerance - Returns a version of a geometry with duplicate points removed.';

-- ----------------------------
-- Function structure for st_reverse
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_reverse"("public"."geometry");
CREATE FUNCTION "public"."st_reverse"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_reverse'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_reverse"("public"."geometry") IS 'args: g1 - Return the geometry with vertex order reversed.';

-- ----------------------------
-- Function structure for st_rotate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_rotate"("public"."geometry", float8);
CREATE FUNCTION "public"."st_rotate"("public"."geometry", float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_rotate"("public"."geometry", float8) IS 'args: geomA, rotRadians - Rotates a geometry about an origin point.';

-- ----------------------------
-- Function structure for st_rotate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_rotate"("public"."geometry", float8, "public"."geometry");
CREATE FUNCTION "public"."st_rotate"("public"."geometry", float8, "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1, public.ST_X($3) - cos($2) * public.ST_X($3) + sin($2) * public.ST_Y($3), public.ST_Y($3) - sin($2) * public.ST_X($3) - cos($2) * public.ST_Y($3), 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_rotate"("public"."geometry", float8, "public"."geometry") IS 'args: geomA, rotRadians, pointOrigin - Rotates a geometry about an origin point.';

-- ----------------------------
-- Function structure for st_rotate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_rotate"("public"."geometry", float8, float8, float8);
CREATE FUNCTION "public"."st_rotate"("public"."geometry", float8, float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1,	$3 - cos($2) * $3 + sin($2) * $4, $4 - sin($2) * $3 - cos($2) * $4, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_rotate"("public"."geometry", float8, float8, float8) IS 'args: geomA, rotRadians, x0, y0 - Rotates a geometry about an origin point.';

-- ----------------------------
-- Function structure for st_rotatex
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_rotatex"("public"."geometry", float8);
CREATE FUNCTION "public"."st_rotatex"("public"."geometry", float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1, 1, 0, 0, 0, cos($2), -sin($2), 0, sin($2), cos($2), 0, 0, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_rotatex"("public"."geometry", float8) IS 'args: geomA, rotRadians - Rotates a geometry about the X axis.';

-- ----------------------------
-- Function structure for st_rotatey
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_rotatey"("public"."geometry", float8);
CREATE FUNCTION "public"."st_rotatey"("public"."geometry", float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1,  cos($2), 0, sin($2),  0, 1, 0,  -sin($2), 0, cos($2), 0,  0, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_rotatey"("public"."geometry", float8) IS 'args: geomA, rotRadians - Rotates a geometry about the Y axis.';

-- ----------------------------
-- Function structure for st_rotatez
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_rotatez"("public"."geometry", float8);
CREATE FUNCTION "public"."st_rotatez"("public"."geometry", float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Rotate($1, $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_rotatez"("public"."geometry", float8) IS 'args: geomA, rotRadians - Rotates a geometry about the Z axis.';

-- ----------------------------
-- Function structure for st_scale
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_scale"("public"."geometry", float8, float8, float8);
CREATE FUNCTION "public"."st_scale"("public"."geometry", float8, float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Scale($1, public.ST_MakePoint($2, $3, $4))$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_scale"("public"."geometry", float8, float8, float8) IS 'args: geomA, XFactor, YFactor, ZFactor - Scales a geometry by given factors.';

-- ----------------------------
-- Function structure for st_scale
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_scale"("public"."geometry", float8, float8);
CREATE FUNCTION "public"."st_scale"("public"."geometry", float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Scale($1, $2, $3, 1)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_scale"("public"."geometry", float8, float8) IS 'args: geomA, XFactor, YFactor - Scales a geometry by given factors.';

-- ----------------------------
-- Function structure for st_scale
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_scale"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Scale'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") IS 'args: geom, factor - Scales a geometry by given factors.';

-- ----------------------------
-- Function structure for st_scale
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry");
CREATE FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Scale'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") IS 'args: geom, factor, origin - Scales a geometry by given factors.';

-- ----------------------------
-- Function structure for st_scroll
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_scroll"("public"."geometry", "public"."geometry");
CREATE FUNCTION "public"."st_scroll"("public"."geometry", "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Scroll'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_scroll"("public"."geometry", "public"."geometry") IS 'args: linestring, point - Change start point of a closed LineString.';

-- ----------------------------
-- Function structure for st_segmentize
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" float8);
CREATE FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" float8)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_segmentize'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" float8) IS 'args: geog, max_segment_length - Returns a modified geometry/geography having no segment longer than a given distance.';

-- ----------------------------
-- Function structure for st_segmentize
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_segmentize"("public"."geometry", float8);
CREATE FUNCTION "public"."st_segmentize"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_segmentize2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_segmentize"("public"."geometry", float8) IS 'args: geom, max_segment_length - Returns a modified geometry/geography having no segment longer than a given distance.';

-- ----------------------------
-- Function structure for st_seteffectivearea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_seteffectivearea"("public"."geometry", float8, int4);
CREATE FUNCTION "public"."st_seteffectivearea"("public"."geometry", float8='-1'::integer, int4=1)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_SetEffectiveArea'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", float8, int4) IS 'args: geomA, threshold = 0, set_area = 1 - Sets the effective area for each vertex, using the Visvalingam-Whyatt algorithm.';

-- ----------------------------
-- Function structure for st_setpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_setpoint"("public"."geometry", int4, "public"."geometry");
CREATE FUNCTION "public"."st_setpoint"("public"."geometry", int4, "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_setpoint_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_setpoint"("public"."geometry", int4, "public"."geometry") IS 'args: linestring, zerobasedposition, point - Replace point of a linestring with a given point.';

-- ----------------------------
-- Function structure for st_setsrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_setsrid"("geom" "public"."geometry", "srid" int4);
CREATE FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_set_srid'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" int4) IS 'args: geom, srid - Set the SRID on a geometry.';

-- ----------------------------
-- Function structure for st_setsrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_setsrid"("geog" "public"."geography", "srid" int4);
CREATE FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" int4)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'LWGEOM_set_srid'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_sharedpaths
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_SharedPaths'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: lineal1, lineal2 - Returns a collection containing paths shared by the two input linestrings/multilinestrings.';

-- ----------------------------
-- Function structure for st_shiftlongitude
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_shiftlongitude"("public"."geometry");
CREATE FUNCTION "public"."st_shiftlongitude"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_longitude_shift'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") IS 'args: geom - Shifts the longitude coordinates of a geometry between -180..180 and 0..360.';

-- ----------------------------
-- Function structure for st_shortestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_shortestline"("public"."geography", "public"."geography", "use_spheroid" bool);
CREATE FUNCTION "public"."st_shortestline"("public"."geography", "public"."geography", "use_spheroid" bool=true)
  RETURNS "public"."geography" AS '$libdir/postgis-3', 'geography_shortestline'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_shortestline"("public"."geography", "public"."geography", "use_spheroid" bool) IS 'args: geom1, geom2, use_spheroid = true - Returns the 2D shortest line between two geometries';

-- ----------------------------
-- Function structure for st_shortestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_shortestline"(text, text);
CREATE FUNCTION "public"."st_shortestline"(text, text)
  RETURNS "public"."geometry" AS $BODY$ SELECT public.ST_ShortestLine($1::public.geometry, $2::public.geometry);  $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;

-- ----------------------------
-- Function structure for st_shortestline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_shortestline2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;
COMMENT ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: geom1, geom2 - Returns the 2D shortest line between two geometries';

-- ----------------------------
-- Function structure for st_simplify
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_simplify"("public"."geometry", float8);
CREATE FUNCTION "public"."st_simplify"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_simplify2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_simplify"("public"."geometry", float8) IS 'args: geomA, tolerance - Returns a simplified version of a geometry, using the Douglas-Peucker algorithm.';

-- ----------------------------
-- Function structure for st_simplify
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_simplify"("public"."geometry", float8, bool);
CREATE FUNCTION "public"."st_simplify"("public"."geometry", float8, bool)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_simplify2d'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_simplify"("public"."geometry", float8, bool) IS 'args: geomA, tolerance, preserveCollapsed - Returns a simplified version of a geometry, using the Douglas-Peucker algorithm.';

-- ----------------------------
-- Function structure for st_simplifypolygonhull
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" float8, "is_outer" bool);
CREATE FUNCTION "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" float8, "is_outer" bool=true)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_SimplifyPolygonHull'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" float8, "is_outer" bool) IS 'args: param_geom, vertex_fraction, is_outer = true - Computes a simplifed topology-preserving outer or inner hull of a polygonal geometry.';

-- ----------------------------
-- Function structure for st_simplifypreservetopology
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_simplifypreservetopology"("public"."geometry", float8);
CREATE FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'topologypreservesimplify'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", float8) IS 'args: geomA, tolerance - Returns a simplified and valid version of a geometry, using the Douglas-Peucker algorithm.';

-- ----------------------------
-- Function structure for st_simplifyvw
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_simplifyvw"("public"."geometry", float8);
CREATE FUNCTION "public"."st_simplifyvw"("public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_SetEffectiveArea'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_simplifyvw"("public"."geometry", float8) IS 'args: geomA, tolerance - Returns a simplified version of a geometry, using the Visvalingam-Whyatt algorithm';

-- ----------------------------
-- Function structure for st_snap
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", float8);
CREATE FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Snap'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", float8) IS 'args: input, reference, tolerance - Snap segments and vertices of input geometry to vertices of a reference geometry.';

-- ----------------------------
-- Function structure for st_snaptogrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", float8, float8, float8, float8);
CREATE FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", float8, float8, float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_snaptogrid_pointoff'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", float8, float8, float8, float8) IS 'args: geomA, pointOrigin, sizeX, sizeY, sizeZ, sizeM - Snap all points of the input geometry to a regular grid.';

-- ----------------------------
-- Function structure for st_snaptogrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_snaptogrid"("public"."geometry", float8);
CREATE FUNCTION "public"."st_snaptogrid"("public"."geometry", float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_SnapToGrid($1, 0, 0, $2, $2)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_snaptogrid"("public"."geometry", float8) IS 'args: geomA, size - Snap all points of the input geometry to a regular grid.';

-- ----------------------------
-- Function structure for st_snaptogrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_snaptogrid"("public"."geometry", float8, float8, float8, float8);
CREATE FUNCTION "public"."st_snaptogrid"("public"."geometry", float8, float8, float8, float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_snaptogrid'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_snaptogrid"("public"."geometry", float8, float8, float8, float8) IS 'args: geomA, originX, originY, sizeX, sizeY - Snap all points of the input geometry to a regular grid.';

-- ----------------------------
-- Function structure for st_snaptogrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_snaptogrid"("public"."geometry", float8, float8);
CREATE FUNCTION "public"."st_snaptogrid"("public"."geometry", float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_SnapToGrid($1, 0, 0, $2, $3)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_snaptogrid"("public"."geometry", float8, float8) IS 'args: geomA, sizeX, sizeY - Snap all points of the input geometry to a regular grid.';

-- ----------------------------
-- Function structure for st_split
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Split'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: input, blade - Returns a collection of geometries created by splitting a geometry by another geometry.';

-- ----------------------------
-- Function structure for st_square
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_square"("size" float8, "cell_i" int4, "cell_j" int4, "origin" "public"."geometry");
CREATE FUNCTION "public"."st_square"("size" float8, "cell_i" int4, "cell_j" int4, "origin" "public"."geometry"='010100000000000000000000000000000000000000'::geometry)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Square'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_square"("size" float8, "cell_i" int4, "cell_j" int4, "origin" "public"."geometry") IS 'args: size, cell_i, cell_j, origin - Returns a single square, using the provided edge size and cell coordinate within the square grid space.';

-- ----------------------------
-- Function structure for st_squaregrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_squaregrid"("size" float8, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" int4, OUT "j" int4);
CREATE FUNCTION "public"."st_squaregrid"(IN "size" float8, IN "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" int4, OUT "j" int4)
  RETURNS SETOF "pg_catalog"."record" AS '$libdir/postgis-3', 'ST_ShapeGrid'
  LANGUAGE c IMMUTABLE STRICT
  COST 250
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_squaregrid"("size" float8, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" int4, OUT "j" int4) IS 'args: size, bounds - Returns a set of grid squares and cell indices that completely cover the bounds of the geometry argument.';

-- ----------------------------
-- Function structure for st_srid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_srid"("geom" "public"."geometry");
CREATE FUNCTION "public"."st_srid"("geom" "public"."geometry")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_get_srid'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_srid"("geom" "public"."geometry") IS 'args: g1 - Returns the spatial reference identifier for a geometry.';

-- ----------------------------
-- Function structure for st_srid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_srid"("geog" "public"."geography");
CREATE FUNCTION "public"."st_srid"("geog" "public"."geography")
  RETURNS "pg_catalog"."int4" AS '$libdir/postgis-3', 'LWGEOM_get_srid'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_startpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_startpoint"("public"."geometry");
CREATE FUNCTION "public"."st_startpoint"("public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_startpoint_linestring'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_startpoint"("public"."geometry") IS 'args: geomA - Returns the first point of a LineString.';

-- ----------------------------
-- Function structure for st_subdivide
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" int4, "gridsize" float8);
CREATE FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" int4=256, "gridsize" float8='-1.0'::numeric)
  RETURNS SETOF "public"."geometry" AS '$libdir/postgis-3', 'ST_Subdivide'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000
  ROWS 1000;
COMMENT ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" int4, "gridsize" float8) IS 'args: geom, max_vertices=256, gridSize = -1 - Computes a rectilinear subdivision of a geometry.';

-- ----------------------------
-- Function structure for st_summary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_summary"("public"."geometry");
CREATE FUNCTION "public"."st_summary"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_summary'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_summary"("public"."geometry") IS 'args: g - Returns a text summary of the contents of a geometry.';

-- ----------------------------
-- Function structure for st_summary
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_summary"("public"."geography");
CREATE FUNCTION "public"."st_summary"("public"."geography")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_summary'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_summary"("public"."geography") IS 'args: g - Returns a text summary of the contents of a geometry.';

-- ----------------------------
-- Function structure for st_swapordinates
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_swapordinates"("geom" "public"."geometry", "ords" cstring);
CREATE FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" cstring)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_SwapOrdinates'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" cstring) IS 'args: geom, ords - Returns a version of the given geometry with given ordinate values swapped.';

-- ----------------------------
-- Function structure for st_symdifference
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8);
CREATE FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8='-1.0'::numeric)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_SymDifference'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8) IS 'args: geomA, geomB, gridSize = -1 - Computes a geometry representing the portions of geometries A and B that do not intersect.';

-- ----------------------------
-- Function structure for st_symmetricdifference
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$SELECT ST_SymDifference(geom1, geom2, -1.0);$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for st_tileenvelope
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_tileenvelope"("zoom" int4, "x" int4, "y" int4, "bounds" "public"."geometry", "margin" float8);
CREATE FUNCTION "public"."st_tileenvelope"("zoom" int4, "x" int4, "y" int4, "bounds" "public"."geometry"='0102000020110F00000200000093107C45F81B73C193107C45F81B73C193107C45F81B734193107C45F81B7341'::geometry, "margin" float8=0.0)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_TileEnvelope'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_tileenvelope"("zoom" int4, "x" int4, "y" int4, "bounds" "public"."geometry", "margin" float8) IS 'args: tileZoom, tileX, tileY, bounds=SRID=3857;LINESTRING(-20037508.342789 -20037508.342789,20037508.342789 20037508.342789), margin=0.0 - Creates a rectangular Polygon in Web Mercator (SRID:3857) using the XYZ tile system.';

-- ----------------------------
-- Function structure for st_touches
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'touches'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_transform
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_transform"("public"."geometry", int4);
CREATE FUNCTION "public"."st_transform"("public"."geometry", int4)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'transform'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_transform"("public"."geometry", int4) IS 'args: g1, srid - Return a new geometry with coordinates transformed to a different spatial reference system.';

-- ----------------------------
-- Function structure for st_transform
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_transform"("geom" "public"."geometry", "from_proj" text, "to_srid" int4);
CREATE FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" text, "to_srid" int4)
  RETURNS "public"."geometry" AS $BODY$SELECT public.postgis_transform_geometry($1, $2, proj4text, $3)
	FROM spatial_ref_sys WHERE srid=$3;$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" text, "to_srid" int4) IS 'args: geom, from_proj, to_srid - Return a new geometry with coordinates transformed to a different spatial reference system.';

-- ----------------------------
-- Function structure for st_transform
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_transform"("geom" "public"."geometry", "from_proj" text, "to_proj" text);
CREATE FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" text, "to_proj" text)
  RETURNS "public"."geometry" AS $BODY$SELECT public.postgis_transform_geometry($1, $2, $3, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" text, "to_proj" text) IS 'args: geom, from_proj, to_proj - Return a new geometry with coordinates transformed to a different spatial reference system.';

-- ----------------------------
-- Function structure for st_transform
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_transform"("geom" "public"."geometry", "to_proj" text);
CREATE FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" text)
  RETURNS "public"."geometry" AS $BODY$SELECT public.postgis_transform_geometry($1, proj4text, $2, 0)
	FROM spatial_ref_sys WHERE srid=public.ST_SRID($1);$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" text) IS 'args: geom, to_proj - Return a new geometry with coordinates transformed to a different spatial reference system.';

-- ----------------------------
-- Function structure for st_transformpipeline
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_transformpipeline"("geom" "public"."geometry", "pipeline" text, "to_srid" int4);
CREATE FUNCTION "public"."st_transformpipeline"("geom" "public"."geometry", "pipeline" text, "to_srid" int4=0)
  RETURNS "public"."geometry" AS $BODY$SELECT public.postgis_transform_pipeline_geometry($1, $2, TRUE, $3)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_transformpipeline"("geom" "public"."geometry", "pipeline" text, "to_srid" int4) IS 'args: g1, pipeline, to_srid - Return a new geometry with coordinates transformed to a different spatial reference system using a defined coordinate transformation pipeline.';

-- ----------------------------
-- Function structure for st_translate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_translate"("public"."geometry", float8, float8);
CREATE FUNCTION "public"."st_translate"("public"."geometry", float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Translate($1, $2, $3, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_translate"("public"."geometry", float8, float8) IS 'args: g1, deltax, deltay - Translates a geometry by given offsets.';

-- ----------------------------
-- Function structure for st_translate
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_translate"("public"."geometry", float8, float8, float8);
CREATE FUNCTION "public"."st_translate"("public"."geometry", float8, float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_translate"("public"."geometry", float8, float8, float8) IS 'args: g1, deltax, deltay, deltaz - Translates a geometry by given offsets.';

-- ----------------------------
-- Function structure for st_transscale
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_transscale"("public"."geometry", float8, float8, float8, float8);
CREATE FUNCTION "public"."st_transscale"("public"."geometry", float8, float8, float8, float8)
  RETURNS "public"."geometry" AS $BODY$SELECT public.ST_Affine($1,  $4, 0, 0,  0, $5, 0,
		0, 0, 1,  $2 * $4, $3 * $5, 0)$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_transscale"("public"."geometry", float8, float8, float8, float8) IS 'args: geomA, deltaX, deltaY, XFactor, YFactor - Translates and scales a geometry by given offsets and factors.';

-- ----------------------------
-- Function structure for st_triangulatepolygon
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_triangulatepolygon"("g1" "public"."geometry");
CREATE FUNCTION "public"."st_triangulatepolygon"("g1" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_TriangulatePolygon'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_triangulatepolygon"("g1" "public"."geometry") IS 'args: geom - Computes the constrained Delaunay triangulation of polygons';

-- ----------------------------
-- Function structure for st_unaryunion
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_unaryunion"("public"."geometry", "gridsize" float8);
CREATE FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" float8='-1.0'::numeric)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_UnaryUnion'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" float8) IS 'args: geom, gridSize = -1 - Computes the union of the components of a single geometry.';

-- ----------------------------
-- Function structure for st_union
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_union"("public"."_geometry");
CREATE FUNCTION "public"."st_union"("public"."_geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'pgis_union_geometry_array'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_union"("public"."_geometry") IS 'args: g1_array - Computes a geometry representing the point-set union of the input geometries.';

-- ----------------------------
-- Function structure for st_union
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Union'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") IS 'args: g1, g2 - Computes a geometry representing the point-set union of the input geometries.';

-- ----------------------------
-- Function structure for st_union
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8);
CREATE FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_Union'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;
COMMENT ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" float8) IS 'args: g1, g2, gridSize - Computes a geometry representing the point-set union of the input geometries.';

-- ----------------------------
-- Function structure for st_voronoilines
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" float8, "extend_to" "public"."geometry");
CREATE FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" float8=0.0, "extend_to" "public"."geometry"=NULL::geometry)
  RETURNS "public"."geometry" AS $BODY$ SELECT public._ST_Voronoi(g1, extend_to, tolerance, false) $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
COMMENT ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" float8, "extend_to" "public"."geometry") IS 'args: geom, tolerance = 0.0, extend_to = NULL - Returns the boundaries of the Voronoi diagram of the vertices of a geometry.';

-- ----------------------------
-- Function structure for st_voronoipolygons
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" float8, "extend_to" "public"."geometry");
CREATE FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" float8=0.0, "extend_to" "public"."geometry"=NULL::geometry)
  RETURNS "public"."geometry" AS $BODY$ SELECT public._ST_Voronoi(g1, extend_to, tolerance, true) $BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
COMMENT ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" float8, "extend_to" "public"."geometry") IS 'args: geom, tolerance = 0.0, extend_to = NULL - Returns the cells of the Voronoi diagram of the vertices of a geometry.';

-- ----------------------------
-- Function structure for st_within
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry");
CREATE FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry")
  RETURNS "pg_catalog"."bool" AS '$libdir/postgis-3', 'within'
  LANGUAGE c IMMUTABLE STRICT
  COST 5000;

-- ----------------------------
-- Function structure for st_wkbtosql
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_wkbtosql"("wkb" bytea);
CREATE FUNCTION "public"."st_wkbtosql"("wkb" bytea)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_WKB'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for st_wkttosql
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_wkttosql"(text);
CREATE FUNCTION "public"."st_wkttosql"(text)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'LWGEOM_from_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 250;

-- ----------------------------
-- Function structure for st_wrapx
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_wrapx"("geom" "public"."geometry", "wrap" float8, "move" float8);
CREATE FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" float8, "move" float8)
  RETURNS "public"."geometry" AS '$libdir/postgis-3', 'ST_WrapX'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;
COMMENT ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" float8, "move" float8) IS 'args: geom, wrap, move - Wrap a geometry around an X value.';

-- ----------------------------
-- Function structure for st_x
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_x"("public"."geometry");
CREATE FUNCTION "public"."st_x"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_x_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_x"("public"."geometry") IS 'args: a_point - Returns the X coordinate of a Point.';

-- ----------------------------
-- Function structure for st_xmax
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_xmax"("public"."box3d");
CREATE FUNCTION "public"."st_xmax"("public"."box3d")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'BOX3D_xmax'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_xmax"("public"."box3d") IS 'args: aGeomorBox2DorBox3D - Returns the X maxima of a 2D or 3D bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_xmin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_xmin"("public"."box3d");
CREATE FUNCTION "public"."st_xmin"("public"."box3d")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'BOX3D_xmin'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_xmin"("public"."box3d") IS 'args: aGeomorBox2DorBox3D - Returns the X minima of a 2D or 3D bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_y
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_y"("public"."geometry");
CREATE FUNCTION "public"."st_y"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_y_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_y"("public"."geometry") IS 'args: a_point - Returns the Y coordinate of a Point.';

-- ----------------------------
-- Function structure for st_ymax
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ymax"("public"."box3d");
CREATE FUNCTION "public"."st_ymax"("public"."box3d")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'BOX3D_ymax'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_ymax"("public"."box3d") IS 'args: aGeomorBox2DorBox3D - Returns the Y maxima of a 2D or 3D bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_ymin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_ymin"("public"."box3d");
CREATE FUNCTION "public"."st_ymin"("public"."box3d")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'BOX3D_ymin'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_ymin"("public"."box3d") IS 'args: aGeomorBox2DorBox3D - Returns the Y minima of a 2D or 3D bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_z
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_z"("public"."geometry");
CREATE FUNCTION "public"."st_z"("public"."geometry")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'LWGEOM_z_point'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_z"("public"."geometry") IS 'args: a_point - Returns the Z coordinate of a Point.';

-- ----------------------------
-- Function structure for st_zmax
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_zmax"("public"."box3d");
CREATE FUNCTION "public"."st_zmax"("public"."box3d")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'BOX3D_zmax'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_zmax"("public"."box3d") IS 'args: aGeomorBox2DorBox3D - Returns the Z maxima of a 2D or 3D bounding box or a geometry.';

-- ----------------------------
-- Function structure for st_zmflag
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_zmflag"("public"."geometry");
CREATE FUNCTION "public"."st_zmflag"("public"."geometry")
  RETURNS "pg_catalog"."int2" AS '$libdir/postgis-3', 'LWGEOM_zmflag'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_zmflag"("public"."geometry") IS 'args: geomA - Returns a code indicating the ZM coordinate dimension of a geometry.';

-- ----------------------------
-- Function structure for st_zmin
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."st_zmin"("public"."box3d");
CREATE FUNCTION "public"."st_zmin"("public"."box3d")
  RETURNS "pg_catalog"."float8" AS '$libdir/postgis-3', 'BOX3D_zmin'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
COMMENT ON FUNCTION "public"."st_zmin"("public"."box3d") IS 'args: aGeomorBox2DorBox3D - Returns the Z minima of a 2D or 3D bounding box or a geometry.';

-- ----------------------------
-- Function structure for substring_index
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."substring_index"(varchar, varchar, int4);
CREATE FUNCTION "public"."substring_index"(varchar, varchar, int4)
  RETURNS "pg_catalog"."varchar" AS $BODY$
DECLARE
tokens varchar[];
length integer ;
indexnum integer;
BEGIN
tokens := pg_catalog.string_to_array($1, $2);
length := pg_catalog.array_upper(tokens, 1);
indexnum := length - ($3 * -1) + 1;
IF $3 >= 0 THEN
RETURN pg_catalog.array_to_string(tokens[1:$3], $2);
ELSE
RETURN pg_catalog.array_to_string(tokens[indexnum:length], $2);
END IF;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- Function structure for text
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."text"("public"."geometry");
CREATE FUNCTION "public"."text"("public"."geometry")
  RETURNS "pg_catalog"."text" AS '$libdir/postgis-3', 'LWGEOM_to_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 50;

-- ----------------------------
-- Function structure for unlockrows
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."unlockrows"(text);
CREATE FUNCTION "public"."unlockrows"(text)
  RETURNS "pg_catalog"."int4" AS $BODY$
DECLARE
	ret int;
BEGIN

	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;

	EXECUTE 'DELETE FROM authorization_table where authid = ' ||
		quote_literal($1);

	GET DIAGNOSTICS ret = ROW_COUNT;

	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."unlockrows"(text) IS 'args: auth_token - Removes all locks held by an authorization token.';

-- ----------------------------
-- Function structure for update_updated_at_column
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."update_updated_at_column"();
CREATE FUNCTION "public"."update_updated_at_column"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for updategeometrysrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."updategeometrysrid"("catalogn_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid_in" int4);
CREATE FUNCTION "public"."updategeometrysrid"("catalogn_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid_in" int4)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	myrec RECORD;
	okay boolean;
	cname varchar;
	real_schema name;
	unknown_srid integer;
	new_srid integer := new_srid_in;

BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;

		FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
		END LOOP;

		IF ( okay <> true ) THEN
			RAISE EXCEPTION 'Invalid schema name';
		ELSE
			real_schema = schema_name;
		END IF;
	ELSE
		SELECT INTO real_schema current_schema()::text;
	END IF;

	-- Ensure that column_name is in geometry_columns
	okay = false;
	FOR myrec IN SELECT type, coord_dimension FROM public.geometry_columns WHERE f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
	END LOOP;
	IF (NOT okay) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
		RETURN false;
	END IF;

	-- Ensure that new_srid is valid
	IF ( new_srid > 0 ) THEN
		IF ( SELECT count(*) = 0 from spatial_ref_sys where srid = new_srid ) THEN
			RAISE EXCEPTION 'invalid SRID: % not found in spatial_ref_sys', new_srid;
			RETURN false;
		END IF;
	ELSE
		unknown_srid := public.ST_SRID('POINT EMPTY'::public.geometry);
		IF ( new_srid != unknown_srid ) THEN
			new_srid := unknown_srid;
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
		END IF;
	END IF;

	IF postgis_constraint_srid(real_schema, table_name, column_name) IS NOT NULL THEN
	-- srid was enforced with constraints before, keep it that way.
		-- Make up constraint name
		cname = 'enforce_srid_'  || column_name;

		-- Drop enforce_srid constraint
		EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
			'.' || quote_ident(table_name) ||
			' DROP constraint ' || quote_ident(cname);

		-- Update geometries SRID
		EXECUTE 'UPDATE ' || quote_ident(real_schema) ||
			'.' || quote_ident(table_name) ||
			' SET ' || quote_ident(column_name) ||
			' = public.ST_SetSRID(' || quote_ident(column_name) ||
			', ' || new_srid::text || ')';

		-- Reset enforce_srid constraint
		EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
			'.' || quote_ident(table_name) ||
			' ADD constraint ' || quote_ident(cname) ||
			' CHECK (st_srid(' || quote_ident(column_name) ||
			') = ' || new_srid::text || ')';
	ELSE
		-- We will use typmod to enforce if no srid constraints
		-- We are using postgis_type_name to lookup the new name
		-- (in case Paul changes his mind and flips geometry_columns to return old upper case name)
		EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' || quote_ident(table_name) ||
		' ALTER COLUMN ' || quote_ident(column_name) || ' TYPE  geometry(' || public.postgis_type_name(myrec.type, myrec.coord_dimension, true) || ', ' || new_srid::text || ') USING public.ST_SetSRID(' || quote_ident(column_name) || ',' || new_srid::text || ');' ;
	END IF;

	RETURN real_schema || '.' || table_name || '.' || column_name ||' SRID changed to ' || new_srid::text;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."updategeometrysrid"("catalogn_name" varchar, "schema_name" varchar, "table_name" varchar, "column_name" varchar, "new_srid_in" int4) IS 'args: catalog_name, schema_name, table_name, column_name, srid - Updates the SRID of all features in a geometry column, and the table metadata.';

-- ----------------------------
-- Function structure for updategeometrysrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."updategeometrysrid"(varchar, varchar, int4);
CREATE FUNCTION "public"."updategeometrysrid"(varchar, varchar, int4)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	ret  text;
BEGIN
	SELECT public.UpdateGeometrySRID('','',$1,$2,$3) into ret;
	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."updategeometrysrid"(varchar, varchar, int4) IS 'args: table_name, column_name, srid - Updates the SRID of all features in a geometry column, and the table metadata.';

-- ----------------------------
-- Function structure for updategeometrysrid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."updategeometrysrid"(varchar, varchar, varchar, int4);
CREATE FUNCTION "public"."updategeometrysrid"(varchar, varchar, varchar, int4)
  RETURNS "pg_catalog"."text" AS $BODY$
DECLARE
	ret  text;
BEGIN
	SELECT public.UpdateGeometrySRID('',$1,$2,$3,$4) into ret;
	RETURN ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "public"."updategeometrysrid"(varchar, varchar, varchar, int4) IS 'args: schema_name, table_name, column_name, srid - Updates the SRID of all features in a geometry column, and the table metadata.';

-- ----------------------------
-- View structure for geography_columns
-- ----------------------------
DROP VIEW IF EXISTS "public"."geography_columns";
CREATE VIEW "public"."geography_columns" AS  SELECT current_database() AS f_table_catalog,
    n.nspname AS f_table_schema,
    c.relname AS f_table_name,
    a.attname AS f_geography_column,
    postgis_typmod_dims(a.atttypmod) AS coord_dimension,
    postgis_typmod_srid(a.atttypmod) AS srid,
    postgis_typmod_type(a.atttypmod) AS type
   FROM pg_class c,
    pg_attribute a,
    pg_type t,
    pg_namespace n
  WHERE t.typname = 'geography'::name AND a.attisdropped = false AND a.atttypid = t.oid AND a.attrelid = c.oid AND c.relnamespace = n.oid AND (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"])) AND NOT pg_is_other_temp_schema(c.relnamespace) AND has_table_privilege(c.oid, 'SELECT'::text);

-- ----------------------------
-- View structure for geometry_columns
-- ----------------------------
DROP VIEW IF EXISTS "public"."geometry_columns";
CREATE VIEW "public"."geometry_columns" AS  SELECT current_database()::character varying(256) AS f_table_catalog,
    n.nspname AS f_table_schema,
    c.relname AS f_table_name,
    a.attname AS f_geometry_column,
    COALESCE(postgis_typmod_dims(a.atttypmod), sn.ndims, 2) AS coord_dimension,
    COALESCE(NULLIF(postgis_typmod_srid(a.atttypmod), 0), sr.srid, 0) AS srid,
    replace(replace(COALESCE(NULLIF(upper(postgis_typmod_type(a.atttypmod)), 'GEOMETRY'::text), st.type, 'GEOMETRY'::text), 'ZM'::text, ''::text), 'Z'::text, ''::text)::character varying(30) AS type
   FROM pg_class c
     JOIN pg_attribute a ON a.attrelid = c.oid AND NOT a.attisdropped
     JOIN pg_namespace n ON c.relnamespace = n.oid
     JOIN pg_type t ON a.atttypid = t.oid
     LEFT JOIN ( SELECT s.connamespace,
            s.conrelid,
            s.conkey,
            replace(split_part(s.consrc, ''''::text, 2), ')'::text, ''::text) AS type
           FROM ( SELECT pg_constraint.connamespace,
                    pg_constraint.conrelid,
                    pg_constraint.conkey,
                    pg_get_constraintdef(pg_constraint.oid) AS consrc
                   FROM pg_constraint) s
          WHERE s.consrc ~~* '%geometrytype(% = %'::text) st ON st.connamespace = n.oid AND st.conrelid = c.oid AND (a.attnum = ANY (st.conkey))
     LEFT JOIN ( SELECT s.connamespace,
            s.conrelid,
            s.conkey,
            replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text)::integer AS ndims
           FROM ( SELECT pg_constraint.connamespace,
                    pg_constraint.conrelid,
                    pg_constraint.conkey,
                    pg_get_constraintdef(pg_constraint.oid) AS consrc
                   FROM pg_constraint) s
          WHERE s.consrc ~~* '%ndims(% = %'::text) sn ON sn.connamespace = n.oid AND sn.conrelid = c.oid AND (a.attnum = ANY (sn.conkey))
     LEFT JOIN ( SELECT s.connamespace,
            s.conrelid,
            s.conkey,
            replace(replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text), '('::text, ''::text)::integer AS srid
           FROM ( SELECT pg_constraint.connamespace,
                    pg_constraint.conrelid,
                    pg_constraint.conkey,
                    pg_get_constraintdef(pg_constraint.oid) AS consrc
                   FROM pg_constraint) s
          WHERE s.consrc ~~* '%srid(% = %'::text) sr ON sr.connamespace = n.oid AND sr.conrelid = c.oid AND (a.attnum = ANY (sr.conkey))
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"])) AND NOT c.relname = 'raster_columns'::name AND t.typname = 'geometry'::name AND NOT pg_is_other_temp_schema(c.relnamespace) AND has_table_privilege(c.oid, 'SELECT'::text);
CREATE RULE "geometry_columns_insert" AS ON INSERT TO "public"."geometry_columns" DO INSTEAD NOTHING;;
CREATE RULE "geometry_columns_update" AS ON UPDATE TO "public"."geometry_columns" DO INSTEAD NOTHING;;
CREATE RULE "geometry_columns_delete" AS ON DELETE TO "public"."geometry_columns" DO INSTEAD NOTHING;;

-- ----------------------------
-- View structure for list_column
-- ----------------------------
DROP VIEW IF EXISTS "public"."list_column";
CREATE VIEW "public"."list_column" AS  SELECT c.relname AS table_name,
    a.attname AS column_name,
    d.description AS column_comment,
        CASE
            WHEN a.attnotnull AND con.conname IS NULL THEN '1'::text
            ELSE '0'::text
        END AS is_required,
        CASE
            WHEN con.conname IS NOT NULL THEN '1'::text
            ELSE '0'::text
        END AS is_pk,
    a.attnum AS sort,
        CASE
            WHEN "position"(pg_get_expr(ad.adbin, ad.adrelid), ((c.relname::text || '_'::text) || a.attname::text) || '_seq'::text) > 0 THEN '1'::text
            ELSE '0'::text
        END AS is_increment,
    btrim(
        CASE
            WHEN t.typelem <> 0::oid AND t.typlen = '-1'::integer THEN 'ARRAY'::text
            ELSE
            CASE
                WHEN t.typtype = 'd'::"char" THEN format_type(t.typbasetype, NULL::integer)
                ELSE format_type(a.atttypid, NULL::integer)
            END
        END, '"'::text) AS column_type
   FROM pg_attribute a
     JOIN (pg_class c
     JOIN pg_namespace n ON c.relnamespace = n.oid) ON a.attrelid = c.oid
     LEFT JOIN pg_description d ON d.objoid = c.oid AND a.attnum = d.objsubid
     LEFT JOIN pg_constraint con ON con.conrelid = c.oid AND (a.attnum = ANY (con.conkey))
     LEFT JOIN pg_attrdef ad ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum
     LEFT JOIN pg_type t ON a.atttypid = t.oid
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND a.attnum > 0 AND n.nspname = 'public'::name AND NOT a.attisdropped
  ORDER BY c.relname, a.attnum;

-- ----------------------------
-- View structure for list_table
-- ----------------------------
DROP VIEW IF EXISTS "public"."list_table";
CREATE VIEW "public"."list_table" AS  SELECT c.relname AS table_name,
    obj_description(c.oid) AS table_comment,
    CURRENT_TIMESTAMP AS create_time,
    CURRENT_TIMESTAMP AS update_time
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND c.relname !~~ 'spatial_%'::text AND n.nspname = 'public'::name AND n.nspname <> ''::name;

-- ----------------------------
-- View structure for v_active_plots
-- ----------------------------
DROP VIEW IF EXISTS "public"."v_active_plots";
CREATE VIEW "public"."v_active_plots" AS  SELECT p.plot_id,
    p.app_id,
    p.plot_name,
    p.geometry,
    p.description,
    p.created_at,
    p.updated_at,
    p.adcode,
    p.province,
    p.city,
    p.district,
    p.crop_type,
    p.monitor_status,
    p.monitor_start_date,
    p.monitor_end_date,
    p.auto_update,
    p.update_frequency,
    a.app_name,
    a.app_key,
    a.callback_url,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM gee_region_policies rp
              WHERE rp.is_active = true AND rp.policy_type::text = 'pause'::text AND p.adcode::text ~~ (rp.adcode::text || '%'::text))) THEN true
            ELSE false
        END AS is_region_paused
   FROM gee_plots p
     LEFT JOIN gee_apps a ON p.app_id = a.app_id
  WHERE p.monitor_status = 1 AND p.auto_update = true;
COMMENT ON VIEW "public"."v_active_plots" IS '活跃地块视图（已开启监测且未被区域暂停）';

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_accounts_account_id_seq"
OWNED BY "public"."gee_accounts"."account_id";
SELECT setval('"public"."gee_accounts_account_id_seq"', 1, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_apps_app_id_seq"
OWNED BY "public"."gee_apps"."app_id";
SELECT setval('"public"."gee_apps_app_id_seq"', 5, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_cache_stats_stat_id_seq"
OWNED BY "public"."gee_cache_stats"."stat_id";
SELECT setval('"public"."gee_cache_stats_stat_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_config_config_id_seq"
OWNED BY "public"."gee_config"."config_id";
SELECT setval('"public"."gee_config_config_id_seq"', 41, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_crop_types_crop_id_seq"
OWNED BY "public"."gee_crop_types"."crop_id";
SELECT setval('"public"."gee_crop_types_crop_id_seq"', 5, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_custom_regions_region_id_seq"
OWNED BY "public"."gee_custom_regions"."region_id";
SELECT setval('"public"."gee_custom_regions_region_id_seq"', 4, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_grade_statistics_stat_id_seq"
OWNED BY "public"."gee_grade_statistics"."stat_id";
SELECT setval('"public"."gee_grade_statistics_stat_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_model_predictions_prediction_id_seq"
OWNED BY "public"."gee_model_predictions"."prediction_id";
SELECT setval('"public"."gee_model_predictions_prediction_id_seq"', 217, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_optimization_result_id_seq"
OWNED BY "public"."gee_optimization_result"."id";
SELECT setval('"public"."gee_optimization_result_id_seq"', 1, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_plot_monitor_logs_log_id_seq"
OWNED BY "public"."gee_plot_monitor_logs"."log_id";
SELECT setval('"public"."gee_plot_monitor_logs_log_id_seq"', 2, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_plots_plot_id_seq"
OWNED BY "public"."gee_plots"."plot_id";
SELECT setval('"public"."gee_plots_plot_id_seq"', 19, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_prefetch_regions_region_id_seq"
OWNED BY "public"."gee_prefetch_regions"."region_id";
SELECT setval('"public"."gee_prefetch_regions_region_id_seq"', 2, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_region_policies_policy_id_seq"
OWNED BY "public"."gee_region_policies"."policy_id";
SELECT setval('"public"."gee_region_policies_policy_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gee_task_results_result_id_seq"
OWNED BY "public"."gee_task_results"."result_id";
SELECT setval('"public"."gee_task_results_result_id_seq"', 33, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gen_table_column_column_id_seq"
OWNED BY "public"."gen_table_column"."column_id";
SELECT setval('"public"."gen_table_column_column_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gen_table_table_id_seq"
OWNED BY "public"."gen_table"."table_id";
SELECT setval('"public"."gen_table_table_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."lease_transfer_item_id_seq"
OWNED BY "public"."lease_transfer_item"."id";
SELECT setval('"public"."lease_transfer_item_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_config_config_id_seq"
OWNED BY "public"."sys_config"."config_id";
SELECT setval('"public"."sys_config_config_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dept_dept_id_seq"
OWNED BY "public"."sys_dept"."dept_id";
SELECT setval('"public"."sys_dept_dept_id_seq"', 200, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dict_data_dict_code_seq"
OWNED BY "public"."sys_dict_data"."dict_code";
SELECT setval('"public"."sys_dict_data_dict_code_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dict_type_dict_id_seq"
OWNED BY "public"."sys_dict_type"."dict_id";
SELECT setval('"public"."sys_dict_type_dict_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_job_job_id_seq"
OWNED BY "public"."sys_job"."job_id";
SELECT setval('"public"."sys_job_job_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_job_log_job_log_id_seq"
OWNED BY "public"."sys_job_log"."job_log_id";
SELECT setval('"public"."sys_job_log_job_log_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_logininfor_info_id_seq"
OWNED BY "public"."sys_logininfor"."info_id";
SELECT setval('"public"."sys_logininfor_info_id_seq"', 185, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_menu_menu_id_seq"
OWNED BY "public"."sys_menu"."menu_id";
SELECT setval('"public"."sys_menu_menu_id_seq"', 2029, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_notice_notice_id_seq"
OWNED BY "public"."sys_notice"."notice_id";
SELECT setval('"public"."sys_notice_notice_id_seq"', 10, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_oper_log_oper_id_seq"
OWNED BY "public"."sys_oper_log"."oper_id";
SELECT setval('"public"."sys_oper_log_oper_id_seq"', 214, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_post_post_id_seq"
OWNED BY "public"."sys_post"."post_id";
SELECT setval('"public"."sys_post_post_id_seq"', 5, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_role_role_id_seq"
OWNED BY "public"."sys_role"."role_id";
SELECT setval('"public"."sys_role_role_id_seq"', 3, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_user_id_seq"
OWNED BY "public"."sys_user"."user_id";
SELECT setval('"public"."sys_user_user_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."training_videos_id_seq"
OWNED BY "public"."training_videos"."id";
SELECT setval('"public"."training_videos_id_seq"', 1, false);

-- ----------------------------
-- Indexes structure for table apscheduler_jobs
-- ----------------------------
CREATE INDEX "ix_apscheduler_jobs_next_run_time" ON "public"."apscheduler_jobs" USING btree (
  "next_run_time" "pg_catalog"."float8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table apscheduler_jobs
-- ----------------------------
ALTER TABLE "public"."apscheduler_jobs" ADD CONSTRAINT "apscheduler_jobs_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table gee_accounts
-- ----------------------------
CREATE INDEX "idx_gee_accounts_active" ON "public"."gee_accounts" USING btree (
  "is_active" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_accounts_drive_folder_id" ON "public"."gee_accounts" USING btree (
  "drive_folder_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_accounts_priority" ON "public"."gee_accounts" USING btree (
  "priority" "pg_catalog"."int4_ops" DESC NULLS FIRST
);

-- ----------------------------
-- Uniques structure for table gee_accounts
-- ----------------------------
ALTER TABLE "public"."gee_accounts" ADD CONSTRAINT "gee_accounts_account_name_key" UNIQUE ("account_name");

-- ----------------------------
-- Primary Key structure for table gee_accounts
-- ----------------------------
ALTER TABLE "public"."gee_accounts" ADD CONSTRAINT "gee_accounts_pkey" PRIMARY KEY ("account_id");

-- ----------------------------
-- Uniques structure for table gee_apps
-- ----------------------------
ALTER TABLE "public"."gee_apps" ADD CONSTRAINT "gee_apps_app_key_key" UNIQUE ("app_key");

-- ----------------------------
-- Primary Key structure for table gee_apps
-- ----------------------------
ALTER TABLE "public"."gee_apps" ADD CONSTRAINT "gee_apps_pkey" PRIMARY KEY ("app_id");

-- ----------------------------
-- Uniques structure for table gee_cache_stats
-- ----------------------------
ALTER TABLE "public"."gee_cache_stats" ADD CONSTRAINT "gee_cache_stats_stat_date_key" UNIQUE ("stat_date");

-- ----------------------------
-- Primary Key structure for table gee_cache_stats
-- ----------------------------
ALTER TABLE "public"."gee_cache_stats" ADD CONSTRAINT "gee_cache_stats_pkey" PRIMARY KEY ("stat_id");

-- ----------------------------
-- Indexes structure for table gee_config
-- ----------------------------
CREATE INDEX "idx_gee_config_enabled" ON "public"."gee_config" USING btree (
  "is_enabled" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_config_group" ON "public"."gee_config" USING btree (
  "config_group" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table gee_config
-- ----------------------------
ALTER TABLE "public"."gee_config" ADD CONSTRAINT "gee_config_config_key_key" UNIQUE ("config_key");

-- ----------------------------
-- Primary Key structure for table gee_config
-- ----------------------------
ALTER TABLE "public"."gee_config" ADD CONSTRAINT "gee_config_pkey" PRIMARY KEY ("config_id");

-- ----------------------------
-- Uniques structure for table gee_crop_types
-- ----------------------------
ALTER TABLE "public"."gee_crop_types" ADD CONSTRAINT "gee_crop_types_crop_code_key" UNIQUE ("crop_code");

-- ----------------------------
-- Primary Key structure for table gee_crop_types
-- ----------------------------
ALTER TABLE "public"."gee_crop_types" ADD CONSTRAINT "gee_crop_types_pkey" PRIMARY KEY ("crop_id");

-- ----------------------------
-- Indexes structure for table gee_custom_regions
-- ----------------------------
CREATE INDEX "idx_custom_regions_active" ON "public"."gee_custom_regions" USING btree (
  "is_active" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_custom_regions_priority" ON "public"."gee_custom_regions" USING btree (
  "priority" "pg_catalog"."int4_ops" DESC NULLS FIRST
);

-- ----------------------------
-- Primary Key structure for table gee_custom_regions
-- ----------------------------
ALTER TABLE "public"."gee_custom_regions" ADD CONSTRAINT "gee_custom_regions_pkey" PRIMARY KEY ("region_id");

-- ----------------------------
-- Indexes structure for table gee_grade_statistics
-- ----------------------------
CREATE INDEX "idx_grade_stats_level" ON "public"."gee_grade_statistics" USING btree (
  "grade_level" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_grade_stats_model" ON "public"."gee_grade_statistics" USING btree (
  "model_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_grade_stats_prediction" ON "public"."gee_grade_statistics" USING btree (
  "prediction_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_grade_stats_task" ON "public"."gee_grade_statistics" USING btree (
  "task_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table gee_grade_statistics
-- ----------------------------
ALTER TABLE "public"."gee_grade_statistics" ADD CONSTRAINT "gee_grade_statistics_pkey" PRIMARY KEY ("stat_id");

-- ----------------------------
-- Indexes structure for table gee_model_predictions
-- ----------------------------
CREATE INDEX "idx_predictions_model" ON "public"."gee_model_predictions" USING btree (
  "model_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_predictions_success" ON "public"."gee_model_predictions" USING btree (
  "success" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_predictions_task" ON "public"."gee_model_predictions" USING btree (
  "task_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table gee_model_predictions
-- ----------------------------
ALTER TABLE "public"."gee_model_predictions" ADD CONSTRAINT "uq_model_predictions_task_model" UNIQUE ("task_id", "model_code");

-- ----------------------------
-- Primary Key structure for table gee_model_predictions
-- ----------------------------
ALTER TABLE "public"."gee_model_predictions" ADD CONSTRAINT "gee_model_predictions_pkey" PRIMARY KEY ("prediction_id");

-- ----------------------------
-- Indexes structure for table gee_optimization_result
-- ----------------------------
CREATE INDEX "idx_calculation_date" ON "public"."gee_optimization_result" USING btree (
  "calculation_date" "pg_catalog"."date_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_created_at" ON "public"."gee_optimization_result" USING btree (
  "created_at" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_status" ON "public"."gee_optimization_result" USING btree (
  "status" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table gee_optimization_result
-- ----------------------------
CREATE TRIGGER "update_gee_optimization_result_updated_at" BEFORE UPDATE ON "public"."gee_optimization_result"
FOR EACH ROW
EXECUTE PROCEDURE "public"."update_updated_at_column"();

-- ----------------------------
-- Uniques structure for table gee_optimization_result
-- ----------------------------
ALTER TABLE "public"."gee_optimization_result" ADD CONSTRAINT "uk_date_buffer" UNIQUE ("calculation_date", "buffer_km");

-- ----------------------------
-- Primary Key structure for table gee_optimization_result
-- ----------------------------
ALTER TABLE "public"."gee_optimization_result" ADD CONSTRAINT "gee_optimization_result_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table gee_plot_monitor_logs
-- ----------------------------
CREATE INDEX "idx_plot_logs_created" ON "public"."gee_plot_monitor_logs" USING btree (
  "created_at" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_plot_logs_plot_id" ON "public"."gee_plot_monitor_logs" USING btree (
  "plot_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table gee_plot_monitor_logs
-- ----------------------------
ALTER TABLE "public"."gee_plot_monitor_logs" ADD CONSTRAINT "gee_plot_monitor_logs_pkey" PRIMARY KEY ("log_id");

-- ----------------------------
-- Indexes structure for table gee_plots
-- ----------------------------
CREATE INDEX "idx_gee_plots_adcode" ON "public"."gee_plots" USING btree (
  "adcode" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_plots_app_id" ON "public"."gee_plots" USING btree (
  "app_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_plots_auto_update" ON "public"."gee_plots" USING btree (
  "auto_update" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_plots_crop_type" ON "public"."gee_plots" USING btree (
  "crop_type" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_plots_monitor_status" ON "public"."gee_plots" USING btree (
  "monitor_status" "pg_catalog"."int2_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table gee_plots
-- ----------------------------
CREATE TRIGGER "trigger_plot_status_change" AFTER UPDATE ON "public"."gee_plots"
FOR EACH ROW
EXECUTE PROCEDURE "public"."log_plot_status_change"();

-- ----------------------------
-- Primary Key structure for table gee_plots
-- ----------------------------
ALTER TABLE "public"."gee_plots" ADD CONSTRAINT "gee_plots_pkey" PRIMARY KEY ("plot_id");

-- ----------------------------
-- Primary Key structure for table gee_prefetch_regions
-- ----------------------------
ALTER TABLE "public"."gee_prefetch_regions" ADD CONSTRAINT "gee_prefetch_regions_pkey" PRIMARY KEY ("region_id");

-- ----------------------------
-- Indexes structure for table gee_region_policies
-- ----------------------------
CREATE INDEX "idx_region_policies_active" ON "public"."gee_region_policies" USING btree (
  "is_active" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_region_policies_adcode" ON "public"."gee_region_policies" USING btree (
  "adcode" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_region_policies_type" ON "public"."gee_region_policies" USING btree (
  "policy_type" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table gee_region_policies
-- ----------------------------
ALTER TABLE "public"."gee_region_policies" ADD CONSTRAINT "gee_region_policies_pkey" PRIMARY KEY ("policy_id");

-- ----------------------------
-- Indexes structure for table gee_task_results
-- ----------------------------
CREATE INDEX "idx_task_results_cache" ON "public"."gee_task_results" USING btree (
  "cache_source" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_task_results_date" ON "public"."gee_task_results" USING btree (
  "found_date" "pg_catalog"."date_ops" ASC NULLS LAST
);
CREATE INDEX "idx_task_results_task" ON "public"."gee_task_results" USING btree (
  "task_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table gee_task_results
-- ----------------------------
ALTER TABLE "public"."gee_task_results" ADD CONSTRAINT "uq_task_results_task_id" UNIQUE ("task_id");

-- ----------------------------
-- Primary Key structure for table gee_task_results
-- ----------------------------
ALTER TABLE "public"."gee_task_results" ADD CONSTRAINT "gee_task_results_pkey" PRIMARY KEY ("result_id");

-- ----------------------------
-- Indexes structure for table gee_tasks
-- ----------------------------
CREATE INDEX "idx_gee_tasks_app_id" ON "public"."gee_tasks" USING btree (
  "app_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_tasks_plot_id" ON "public"."gee_tasks" USING btree (
  "plot_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_gee_tasks_source" ON "public"."gee_tasks" USING btree (
  "task_source" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tasks_created" ON "public"."gee_tasks" USING btree (
  "created_at" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tasks_date" ON "public"."gee_tasks" USING btree (
  "target_date" "pg_catalog"."date_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tasks_dept" ON "public"."gee_tasks" USING btree (
  "dept_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tasks_status" ON "public"."gee_tasks" USING btree (
  "status" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tasks_user" ON "public"."gee_tasks" USING btree (
  "create_by" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table gee_tasks
-- ----------------------------
ALTER TABLE "public"."gee_tasks" ADD CONSTRAINT "gee_tasks_pkey" PRIMARY KEY ("task_id");

-- ----------------------------
-- Indexes structure for table gee_tiles
-- ----------------------------
CREATE INDEX "idx_tiles_access" ON "public"."gee_tiles" USING btree (
  "access_count" "pg_catalog"."int4_ops" DESC NULLS FIRST,
  "last_access" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_tiles_date" ON "public"."gee_tiles" USING btree (
  "date_acquired" "pg_catalog"."date_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tiles_expires" ON "public"."gee_tiles" USING btree (
  "expires_at" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tiles_spatial" ON "public"."gee_tiles" USING btree (
  "tile_x" "pg_catalog"."int4_ops" ASC NULLS LAST,
  "tile_y" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tiles_status" ON "public"."gee_tiles" USING btree (
  "status" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table gee_tiles
-- ----------------------------
ALTER TABLE "public"."gee_tiles" ADD CONSTRAINT "gee_tiles_pkey" PRIMARY KEY ("tile_id");

-- ----------------------------
-- Primary Key structure for table gen_table
-- ----------------------------
ALTER TABLE "public"."gen_table" ADD CONSTRAINT "gen_table_pkey" PRIMARY KEY ("table_id");

-- ----------------------------
-- Primary Key structure for table gen_table_column
-- ----------------------------
ALTER TABLE "public"."gen_table_column" ADD CONSTRAINT "gen_table_column_pkey" PRIMARY KEY ("column_id");

-- ----------------------------
-- Indexes structure for table lease_transfer_item
-- ----------------------------
CREATE INDEX "idx_business_status" ON "public"."lease_transfer_item" USING btree (
  "business_status" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_item_status" ON "public"."lease_transfer_item" USING btree (
  "item_status" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_item_type" ON "public"."lease_transfer_item" USING btree (
  "item_type" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_lease_term" ON "public"."lease_transfer_item" USING btree (
  "lease_term" "pg_catalog"."int2_ops" ASC NULLS LAST
);
CREATE INDEX "idx_transfer_lease" ON "public"."lease_transfer_item" USING btree (
  "transfer_lease_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table lease_transfer_item
-- ----------------------------
ALTER TABLE "public"."lease_transfer_item" ADD CONSTRAINT "lease_transfer_item_bid_number_key" UNIQUE ("bid_number");

-- ----------------------------
-- Primary Key structure for table lease_transfer_item
-- ----------------------------
ALTER TABLE "public"."lease_transfer_item" ADD CONSTRAINT "lease_transfer_item_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Checks structure for table spatial_ref_sys
-- ----------------------------
ALTER TABLE "public"."spatial_ref_sys" ADD CONSTRAINT "spatial_ref_sys_srid_check" CHECK (srid > 0 AND srid <= 998999);

-- ----------------------------
-- Primary Key structure for table spatial_ref_sys
-- ----------------------------
ALTER TABLE "public"."spatial_ref_sys" ADD CONSTRAINT "spatial_ref_sys_pkey" PRIMARY KEY ("srid");

-- ----------------------------
-- Primary Key structure for table sys_config
-- ----------------------------
ALTER TABLE "public"."sys_config" ADD CONSTRAINT "sys_config_pkey" PRIMARY KEY ("config_id");

-- ----------------------------
-- Primary Key structure for table sys_dept
-- ----------------------------
ALTER TABLE "public"."sys_dept" ADD CONSTRAINT "sys_dept_pkey" PRIMARY KEY ("dept_id");

-- ----------------------------
-- Primary Key structure for table sys_dict_data
-- ----------------------------
ALTER TABLE "public"."sys_dict_data" ADD CONSTRAINT "sys_dict_data_pkey" PRIMARY KEY ("dict_code");

-- ----------------------------
-- Uniques structure for table sys_dict_type
-- ----------------------------
ALTER TABLE "public"."sys_dict_type" ADD CONSTRAINT "sys_dict_type_dict_type_key" UNIQUE ("dict_type");

-- ----------------------------
-- Primary Key structure for table sys_dict_type
-- ----------------------------
ALTER TABLE "public"."sys_dict_type" ADD CONSTRAINT "sys_dict_type_pkey" PRIMARY KEY ("dict_id");

-- ----------------------------
-- Primary Key structure for table sys_job
-- ----------------------------
ALTER TABLE "public"."sys_job" ADD CONSTRAINT "sys_job_pkey" PRIMARY KEY ("job_id", "job_name", "job_group");

-- ----------------------------
-- Primary Key structure for table sys_job_log
-- ----------------------------
ALTER TABLE "public"."sys_job_log" ADD CONSTRAINT "sys_job_log_pkey" PRIMARY KEY ("job_log_id");

-- ----------------------------
-- Indexes structure for table sys_logininfor
-- ----------------------------
CREATE INDEX "idx_sys_logininfor_lt" ON "public"."sys_logininfor" USING btree (
  "login_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_sys_logininfor_s" ON "public"."sys_logininfor" USING btree (
  "status" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_logininfor
-- ----------------------------
ALTER TABLE "public"."sys_logininfor" ADD CONSTRAINT "sys_logininfor_pkey" PRIMARY KEY ("info_id");

-- ----------------------------
-- Primary Key structure for table sys_menu
-- ----------------------------
ALTER TABLE "public"."sys_menu" ADD CONSTRAINT "sys_menu_pkey" PRIMARY KEY ("menu_id");

-- ----------------------------
-- Primary Key structure for table sys_notice
-- ----------------------------
ALTER TABLE "public"."sys_notice" ADD CONSTRAINT "sys_notice_pkey" PRIMARY KEY ("notice_id");

-- ----------------------------
-- Indexes structure for table sys_oper_log
-- ----------------------------
CREATE INDEX "idx_sys_oper_log_bt" ON "public"."sys_oper_log" USING btree (
  "business_type" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_sys_oper_log_ot" ON "public"."sys_oper_log" USING btree (
  "oper_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_sys_oper_log_s" ON "public"."sys_oper_log" USING btree (
  "status" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_oper_log
-- ----------------------------
ALTER TABLE "public"."sys_oper_log" ADD CONSTRAINT "sys_oper_log_pkey" PRIMARY KEY ("oper_id");

-- ----------------------------
-- Primary Key structure for table sys_post
-- ----------------------------
ALTER TABLE "public"."sys_post" ADD CONSTRAINT "sys_post_pkey" PRIMARY KEY ("post_id");

-- ----------------------------
-- Primary Key structure for table sys_role
-- ----------------------------
ALTER TABLE "public"."sys_role" ADD CONSTRAINT "sys_role_pkey" PRIMARY KEY ("role_id");

-- ----------------------------
-- Primary Key structure for table sys_role_dept
-- ----------------------------
ALTER TABLE "public"."sys_role_dept" ADD CONSTRAINT "sys_role_dept_pkey" PRIMARY KEY ("role_id", "dept_id");

-- ----------------------------
-- Primary Key structure for table sys_role_menu
-- ----------------------------
ALTER TABLE "public"."sys_role_menu" ADD CONSTRAINT "sys_role_menu_pkey" PRIMARY KEY ("role_id", "menu_id");

-- ----------------------------
-- Primary Key structure for table sys_user
-- ----------------------------
ALTER TABLE "public"."sys_user" ADD CONSTRAINT "sys_user_pkey" PRIMARY KEY ("user_id");

-- ----------------------------
-- Primary Key structure for table sys_user_post
-- ----------------------------
ALTER TABLE "public"."sys_user_post" ADD CONSTRAINT "sys_user_post_pkey" PRIMARY KEY ("user_id", "post_id");

-- ----------------------------
-- Primary Key structure for table sys_user_role
-- ----------------------------
ALTER TABLE "public"."sys_user_role" ADD CONSTRAINT "sys_user_role_pkey" PRIMARY KEY ("user_id", "role_id");

-- ----------------------------
-- Uniques structure for table training_videos
-- ----------------------------
ALTER TABLE "public"."training_videos" ADD CONSTRAINT "training_videos_file_path_key" UNIQUE ("file_path");

-- ----------------------------
-- Primary Key structure for table training_videos
-- ----------------------------
ALTER TABLE "public"."training_videos" ADD CONSTRAINT "training_videos_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table gee_grade_statistics
-- ----------------------------
ALTER TABLE "public"."gee_grade_statistics" ADD CONSTRAINT "gee_grade_statistics_prediction_id_fkey" FOREIGN KEY ("prediction_id") REFERENCES "public"."gee_model_predictions" ("prediction_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."gee_grade_statistics" ADD CONSTRAINT "gee_grade_statistics_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."gee_tasks" ("task_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table gee_model_predictions
-- ----------------------------
ALTER TABLE "public"."gee_model_predictions" ADD CONSTRAINT "gee_model_predictions_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."gee_tasks" ("task_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table gee_plot_monitor_logs
-- ----------------------------
ALTER TABLE "public"."gee_plot_monitor_logs" ADD CONSTRAINT "fk_log_plot" FOREIGN KEY ("plot_id") REFERENCES "public"."gee_plots" ("plot_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table gee_plots
-- ----------------------------
ALTER TABLE "public"."gee_plots" ADD CONSTRAINT "fk_plot_app" FOREIGN KEY ("app_id") REFERENCES "public"."gee_apps" ("app_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table gee_task_results
-- ----------------------------
ALTER TABLE "public"."gee_task_results" ADD CONSTRAINT "gee_task_results_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."gee_tasks" ("task_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table gee_tasks
-- ----------------------------
ALTER TABLE "public"."gee_tasks" ADD CONSTRAINT "fk_task_app" FOREIGN KEY ("app_id") REFERENCES "public"."gee_apps" ("app_id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."gee_tasks" ADD CONSTRAINT "fk_task_plot" FOREIGN KEY ("plot_id") REFERENCES "public"."gee_plots" ("plot_id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table gen_table_column
-- ----------------------------
ALTER TABLE "public"."gen_table_column" ADD CONSTRAINT "fk_gen_table_column_table_id" FOREIGN KEY ("table_id") REFERENCES "public"."gen_table" ("table_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
