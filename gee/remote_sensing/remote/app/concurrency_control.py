"""GEE并发控制 - 使用Redis信号量限制同时执行的GEE任务数量"""
import time
from redis import Redis
from app.utils.logger import celery_logger
from app.config import settings


class GEEConcurrencyControl:
    """GEE并发控制器 - 使用Redis实现分布式信号量"""

    def __init__(self, max_concurrent=5):
        """
        初始化并发控制器

        Args:
            max_concurrent: 最大并发数（默认5，GEE限制）
        """
        self.max_concurrent = max_concurrent
        self.semaphore_key = "gee:concurrent_semaphore"
        self.task_locks_prefix = "gee:task_lock:"  # 新增：任务锁前缀

        # 使用 Redis 连接池
        from app.utils.redis_pool import get_redis_client
        
        self.redis_client = get_redis_client(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=settings.REDIS_DB,
            password=settings.REDIS_PASSWORD
        )
        
        celery_logger.info(f"[并发控制] 初始化完成 - 最大并发数: {max_concurrent}")
        celery_logger.info(f"[并发控制] 使用 Redis 连接池")

    def acquire(self, task_id: str, timeout: int = 300):
        """
        获取执行权限（信号量）

        Args:
            task_id: 任务ID
            timeout: 超时时间（秒），默认5分钟

        Returns:
            bool: 是否成功获取
        """
        start_time = time.time()
        wait_count = 0

        while True:
            # 尝试获取信号量
            current = self.redis_client.incr(self.semaphore_key)

            if current <= self.max_concurrent:
                # 获取成功，创建任务锁（带过期时间）
                lock_key = f"{self.task_locks_prefix}{task_id}"
                self.redis_client.setex(lock_key, 3600, "locked")  # 1小时过期
                
                celery_logger.info(
                    f"[并发控制] ✓ 任务 {task_id[:12]}... 获取执行权限 "
                    f"(当前: {current}/{self.max_concurrent})"
                )
                return True
            else:
                # 超过限制，释放并等待
                self.redis_client.decr(self.semaphore_key)

                # 检查超时
                elapsed = time.time() - start_time
                if elapsed >= timeout:
                    celery_logger.error(
                        f"[并发控制] ✗ 任务 {task_id[:12]}... 获取执行权限超时 "
                        f"({elapsed:.1f}秒)"
                    )
                    return False

                # 第一次等待时记录日志
                if wait_count == 0:
                    celery_logger.info(
                        f"[并发控制] ⏳ 任务 {task_id[:12]}... 等待执行权限 "
                        f"(当前: {current-1}/{self.max_concurrent})"
                    )

                wait_count += 1
                time.sleep(5)  # 等待5秒后重试

    def release(self, task_id: str):
        """
        释放执行权限（信号量）

        Args:
            task_id: 任务ID
        """
        # 删除任务锁
        lock_key = f"{self.task_locks_prefix}{task_id}"
        self.redis_client.delete(lock_key)
        
        # 减少信号量
        current = self.redis_client.decr(self.semaphore_key)
        # 确保不会小于0
        if current < 0:
            self.redis_client.set(self.semaphore_key, 0)
            current = 0

        celery_logger.info(
            f"[并发控制] ✓ 任务 {task_id[:12]}... 释放执行权限 "
            f"(当前: {current}/{self.max_concurrent})"
        )

    def get_current_count(self) -> int:
        """
        获取当前并发数

        Returns:
            int: 当前正在执行的任务数
        """
        count = self.redis_client.get(self.semaphore_key)
        return int(count) if count else 0

    def get_available_slots(self) -> int:
        """
        获取可用槽位数

        Returns:
            int: 还能接受多少个任务
        """
        current = self.get_current_count()
        return max(0, self.max_concurrent - current)

    def reset(self):
        """
        重置信号量（用于故障恢复）
        """
        self.redis_client.set(self.semaphore_key, 0)
        celery_logger.warning("[并发控制] ⚠ 信号量已重置")
    
    def cleanup_expired_locks(self):
        """
        清理过期的任务锁并修正信号量
        
        Returns:
            dict: 清理结果
        """
        # 扫描所有任务锁
        pattern = f"{self.task_locks_prefix}*"
        active_locks = 0
        
        for key in self.redis_client.scan_iter(match=pattern):
            if self.redis_client.exists(key):
                active_locks += 1
        
        # 修正信号量
        current = self.get_current_count()
        if current != active_locks:
            celery_logger.warning(
                f"[并发控制] ⚠ 信号量不一致: Redis={current}, 实际锁={active_locks}"
            )
            self.redis_client.set(self.semaphore_key, active_locks)
            celery_logger.info(f"[并发控制] ✓ 信号量已修正为: {active_locks}")
        
        return {
            "before": current,
            "after": active_locks,
            "corrected": current != active_locks
        }


# 全局单例
_gee_concurrency_control = None

def get_gee_concurrency_control() -> GEEConcurrencyControl:
    """获取GEE并发控制器单例"""
    global _gee_concurrency_control
    if _gee_concurrency_control is None:
        _gee_concurrency_control = GEEConcurrencyControl(max_concurrent=5)
    return _gee_concurrency_control
