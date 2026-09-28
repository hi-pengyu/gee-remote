"""启动时系统健康检查"""
from app.utils.logger import celery_logger
from app.config import settings


def check_redis_connection():
    """检查Redis连接"""
    try:
        from redis import Redis

        # 创建Redis客户端
        redis_kwargs = {
            'host': settings.REDIS_HOST,
            'port': settings.REDIS_PORT,
            'db': settings.REDIS_DB,
            'socket_connect_timeout': 5
        }
        if settings.REDIS_PASSWORD:
            redis_kwargs['password'] = settings.REDIS_PASSWORD

        redis_client = Redis(**redis_kwargs)

        # 测试连接
        redis_client.ping()

        celery_logger.info("=" * 60)
        celery_logger.info("✅ Redis 连接成功")
        celery_logger.info(f"   Host: {settings.REDIS_HOST}:{settings.REDIS_PORT}")
        celery_logger.info(f"   DB: {settings.REDIS_DB}")
        celery_logger.info(f"   认证: {'已启用' if settings.REDIS_PASSWORD else '未启用'}")
        celery_logger.info("=" * 60)

        return True

    except Exception as e:
        celery_logger.error("=" * 60)
        celery_logger.error("❌ Redis 连接失败")
        celery_logger.error(f"   Host: {settings.REDIS_HOST}:{settings.REDIS_PORT}")
        celery_logger.error(f"   错误: {str(e)}")
        celery_logger.error(f"   错误类型: {type(e).__name__}")
        celery_logger.error("=" * 60)
        return False


def check_oss_connection():
    """检查阿里云OSS连接"""
    if not settings.OSS_ENABLE_UPLOAD:
        celery_logger.info("=" * 60)
        celery_logger.info("⚪ OSS 上传功能已禁用")
        celery_logger.info("   提示: 设置 OSS_ENABLE_UPLOAD=true 启用")
        celery_logger.info("=" * 60)
        return True

    try:
        # 检查配置完整性
        if not all([
            settings.OSS_ACCESS_KEY_ID,
            settings.OSS_ACCESS_KEY_SECRET,
            settings.OSS_ENDPOINT,
            settings.OSS_BUCKET_NAME
        ]):
            celery_logger.warning("=" * 60)
            celery_logger.warning("⚠️  OSS 配置不完整")
            celery_logger.warning("   缺少必要的配置项，请检查环境变量:")
            if not settings.OSS_ACCESS_KEY_ID:
                celery_logger.warning("   - OSS_ACCESS_KEY_ID")
            if not settings.OSS_ACCESS_KEY_SECRET:
                celery_logger.warning("   - OSS_ACCESS_KEY_SECRET")
            if not settings.OSS_ENDPOINT:
                celery_logger.warning("   - OSS_ENDPOINT")
            if not settings.OSS_BUCKET_NAME:
                celery_logger.warning("   - OSS_BUCKET_NAME")
            celery_logger.warning("=" * 60)
            return False

        # 尝试连接OSS
        from app.services.oss_service import OSSService

        oss_service = OSSService()

        # 测试Bucket是否可访问（获取Bucket信息）
        try:
            bucket_info = oss_service.bucket.get_bucket_info()

            celery_logger.info("=" * 60)
            celery_logger.info("✅ OSS 连接成功")
            celery_logger.info(f"   Bucket: {settings.OSS_BUCKET_NAME}")
            celery_logger.info(f"   Endpoint: {settings.OSS_ENDPOINT}")
            celery_logger.info(f"   区域: {bucket_info.location}")
            celery_logger.info(f"   创建时间: {bucket_info.creation_date}")
            celery_logger.info(f"   存储类型: {bucket_info.storage_class}")
            celery_logger.info(f"   上传后删除本地: {'是' if settings.OSS_DELETE_LOCAL else '否'}")
            celery_logger.info("=" * 60)

            return True

        except Exception as bucket_error:
            celery_logger.error("=" * 60)
            celery_logger.error("❌ OSS Bucket 访问失败")
            celery_logger.error(f"   Bucket: {settings.OSS_BUCKET_NAME}")
            celery_logger.error(f"   Endpoint: {settings.OSS_ENDPOINT}")
            celery_logger.error(f"   错误: {str(bucket_error)}")
            celery_logger.error(f"   错误类型: {type(bucket_error).__name__}")
            celery_logger.error("=" * 60)
            return False

    except Exception as e:
        celery_logger.error("=" * 60)
        celery_logger.error("❌ OSS 初始化失败")
        celery_logger.error(f"   错误: {str(e)}")
        celery_logger.error(f"   错误类型: {type(e).__name__}")
        celery_logger.error("=" * 60)
        return False


def check_gee_authentication():
    """检查GEE认证状态"""
    try:
        import ee

        # 尝试初始化GEE
        try:
            ee.Initialize()
            celery_logger.info("=" * 60)
            celery_logger.info("✅ GEE 认证成功")
            celery_logger.info(f"   项目ID: {settings.GEE_PROJECT_ID}")
            celery_logger.info("=" * 60)
            return True
        except Exception as init_error:
            celery_logger.warning("=" * 60)
            celery_logger.warning("⚠️  GEE 未认证或认证失败")
            celery_logger.warning(f"   错误: {str(init_error)}")
            celery_logger.warning("   提示: 运行 earthengine authenticate 进行认证")
            celery_logger.warning("=" * 60)
            return False

    except ImportError:
        celery_logger.warning("=" * 60)
        celery_logger.warning("⚠️  GEE SDK 未安装")
        celery_logger.warning("   提示: pip install earthengine-api")
        celery_logger.warning("=" * 60)
        return False


def check_storage_directories():
    """检查存储目录"""
    import os

    dirs_to_check = {
        'TIF': settings.STORAGE_TIF_DIR,
        'CSV': settings.STORAGE_CSV_DIR,
        'Results': settings.STORAGE_RESULTS_DIR,
        'Logs': settings.STORAGE_LOGS_DIR
    }

    all_exists = True
    missing_dirs = []

    for name, path in dirs_to_check.items():
        if not os.path.exists(path):
            all_exists = False
            missing_dirs.append(f"{name}: {path}")

    if all_exists:
        celery_logger.info("=" * 60)
        celery_logger.info("✅ 存储目录检查通过")
        for name, path in dirs_to_check.items():
            celery_logger.info(f"   {name}: {path}")
        celery_logger.info("=" * 60)
    else:
        celery_logger.warning("=" * 60)
        celery_logger.warning("⚠️  部分存储目录不存在")
        for missing in missing_dirs:
            celery_logger.warning(f"   缺失: {missing}")
        celery_logger.warning("   提示: 运行应用时会自动创建")
        celery_logger.warning("=" * 60)

    return all_exists


def run_startup_checks():
    """运行所有启动检查"""
    celery_logger.info("\n" + "=" * 60)
    celery_logger.info("🚀 系统启动健康检查")
    celery_logger.info("=" * 60 + "\n")

    results = {
        'redis': check_redis_connection(),
        'oss': check_oss_connection(),
        'gee': check_gee_authentication(),
        'storage': check_storage_directories()
    }

    # 总结
    celery_logger.info("\n" + "=" * 60)
    celery_logger.info("📊 健康检查总结")
    celery_logger.info("=" * 60)
    celery_logger.info(f"   Redis:      {'✅ 正常' if results['redis'] else '❌ 异常'}")
    celery_logger.info(f"   OSS:        {'✅ 正常' if results['oss'] else '❌ 异常'}")
    celery_logger.info(f"   GEE:        {'✅ 正常' if results['gee'] else '⚠️  未认证'}")
    celery_logger.info(f"   存储目录:   {'✅ 正常' if results['storage'] else '⚠️  部分缺失'}")
    celery_logger.info("=" * 60)

    # 关键服务检查
    critical_services = ['redis']
    critical_ok = all(results[service] for service in critical_services)

    if critical_ok:
        celery_logger.info("✅ 所有关键服务正常，系统可以启动")
    else:
        celery_logger.error("❌ 关键服务异常，请检查配置后重新启动")

    celery_logger.info("=" * 60 + "\n")

    return results
