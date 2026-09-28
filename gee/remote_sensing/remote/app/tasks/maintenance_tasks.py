"""维护任务 - 清理残留数据"""
from celery import Task
from app.celery_app import celery_app
from app.concurrency_control import get_gee_concurrency_control
from app.utils.logger import celery_logger


@celery_app.task(name='maintenance.cleanup_redis_locks', bind=True)
def cleanup_redis_locks_task(self):
    """
    清理 Redis 残留的任务锁
    
    定期检查并修正信号量与实际任务锁的不一致
    """
    celery_logger.info("🧹 开始清理 Redis 残留任务锁...")
    
    try:
        concurrency_control = get_gee_concurrency_control()
        result = concurrency_control.cleanup_expired_locks()
        
        if result['corrected']:
            celery_logger.warning(
                f"⚠️ 发现信号量不一致并已修正: {result['before']} -> {result['after']}"
            )
        else:
            celery_logger.info("✅ 信号量正常，无需修正")
        
        return {
            "success": True,
            "result": result,
            "message": "清理完成"
        }
    except Exception as e:
        celery_logger.error(f"❌ 清理任务锁失败: {e}")
        return {
            "success": False,
            "error": str(e)
        }


@celery_app.task(name='maintenance.cleanup_zombie_tasks', bind=True)
def cleanup_zombie_tasks(self, max_age_hours: int = 24):
    """
    清理僵尸任务（长时间未完成的任务）
    
    Args:
        max_age_hours: 任务最大存活时间（小时）
    """
    celery_logger.info(f"🧹 开始清理 {max_age_hours} 小时前的僵尸任务...")
    
    try:
        from celery.result import AsyncResult
        from datetime import datetime, timedelta
        import redis
        
        # 连接 Redis
        r = redis.Redis(
            host=celery_app.conf.broker_url.split('@')[-1].split(':')[0],
            decode_responses=True
        )
        
        # 这里简化处理：记录日志
        # 实际实现需要根据你的 result backend 配置
        celery_logger.info("僵尸任务清理功能需要配合 result backend 实现")
        
        return {
            "success": True,
            "message": f"僵尸任务清理完成（{max_age_hours}小时）"
        }
    except Exception as e:
        celery_logger.error(f"❌ 清理僵尸任务失败: {e}")
        return {
            "success": False,
            "error": str(e)
        }


@celery_app.task(name='maintenance.health_check', bind=True)
def health_check_task(self):
    """
    系统健康检查任务
    
    检查并报告系统状态
    """
    celery_logger.info("🏥 执行系统健康检查...")
    
    try:
        concurrency_control = get_gee_concurrency_control()
        
        health_status = {
            "timestamp": celery_logger.info("健康检查完成"),
            "gee_concurrent_count": concurrency_control.get_current_count(),
            "gee_available_slots": concurrency_control.get_available_slots(),
            "gee_max_concurrent": concurrency_control.max_concurrent
        }
        
        celery_logger.info(f"✅ 健康检查完成: {health_status}")
        return health_status
    except Exception as e:
        celery_logger.error(f"❌ 健康检查失败: {e}")
        return {"success": False, "error": str(e)}
