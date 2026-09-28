"""Celery 应用配置"""
from celery import Celery
from celery.signals import task_prerun, task_postrun, task_failure, worker_ready
from app.config import settings
import logging

# 配置 Celery 日志
logger = logging.getLogger('celery')
logger.setLevel(logging.DEBUG)

# 创建 Celery 实例
celery_app = Celery(
    'gee_tasks',
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=[
        'app.tasks.workflow',
        'app.tasks.cached_workflow',  # 添加缓存工作流
        'app.tasks.cache_tasks',  # 添加缓存管理任务
        'app.tasks.maintenance_tasks'  # 添加维护任务
    ]
)

# Celery 配置
celery_app.conf.update(
    task_track_started=settings.CELERY_TASK_TRACK_STARTED,
    task_time_limit=settings.CELERY_TASK_TIME_LIMIT,  # 硬超时
    task_soft_time_limit=getattr(settings, 'CELERY_TASK_SOFT_TIME_LIMIT', 3000),  # 软超时
    task_serializer='json',
    result_serializer='json',
    accept_content=['json'],
    timezone='Asia/Shanghai',
    enable_utc=False,
    task_routes={
        'app.tasks.workflow.*': {'queue': 'gee_queue'},
        'gee.*': {'queue': 'gee_queue'},
        'cache.*': {'queue': 'gee_queue'},
        'maintenance.*': {'queue': 'gee_queue'}  # 维护任务路由
    },
    worker_log_format='[%(asctime)s: %(levelname)s/%(processName)s] %(message)s',
    worker_task_log_format='[%(asctime)s: %(levelname)s/%(processName)s][%(task_name)s(%(task_id)s)] %(message)s',
    # 错误处理配置
    task_acks_late=True,  # 任务执行完成后才确认
    task_reject_on_worker_lost=True,  # Worker 丢失时拒绝任务
    result_extended=True,  # 扩展结果信息
    # 新增：任务结果过期时间
    result_expires=86400,  # 24小时后过期
    # 新增：任务重试配置
    task_default_retry_delay=60,  # 重试延迟60秒
    task_max_retries=3,  # 最多重试3次
)



# 任务信号处理
@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, **kwargs):
    """任务开始前的信号"""
    logger.info(f"⏳ 任务开始执行: {task.name} | ID: {task_id}")


@task_postrun.connect
def task_postrun_handler(sender=None, task_id=None, task=None, **kwargs):
    """任务完成后的信号"""
    logger.info(f"✅ 任务执行完成: {task.name} | ID: {task_id}")


@task_failure.connect
def task_failure_handler(sender=None, task_id=None, exception=None, **kwargs):
    """任务失败的信号"""
    logger.error(f"❌ 任务执行失败: {sender.name} | ID: {task_id} | 错误: {exception}")


@worker_ready.connect
def worker_ready_handler(sender=None, **kwargs):
    """Worker启动完成后的信号 - 同步凭证和运行健康检查"""
    # 同步 GEE 用户凭证
    try:
        from app.utils.credentials_manager import sync_credentials_on_startup
        sync_credentials_on_startup()
    except Exception as e:
        logger.warning(f"同步 GEE 凭证失败: {e}")
    
    # 运行健康检查
    try:
        from app.startup_check import run_startup_checks
        run_startup_checks()
    except ImportError:
        logger.warning("启动检查模块未找到,跳过健康检查")

print("✅ Celery应用已配置")
print(f"   Broker: {settings.CELERY_BROKER_URL}")
print(f"   Backend: {settings.CELERY_RESULT_BACKEND}")
print(f"   已注册任务模块: workflow, cached_workflow, cache_tasks")
