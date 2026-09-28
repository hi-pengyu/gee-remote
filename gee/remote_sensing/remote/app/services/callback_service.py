"""回调服务 - 任务完成后通知业务端"""
import requests
from typing import Dict, Optional
from datetime import datetime
from app.utils.logger import celery_logger


class CallbackService:
    """回调服务 - 负责通知业务端任务结果"""

    @staticmethod
    def notify_callback(
        callback_url: str,
        task_id: str,
        status: str,
        result: Optional[Dict] = None,
        error: Optional[str] = None,
        timeout: int = 30
    ) -> bool:
        """
        发送回调通知到业务端

        Args:
            callback_url: 回调URL
            task_id: 任务ID
            status: 任务状态 (success/failure)
            result: 任务结果（成功时）
            error: 错误信息（失败时）
            timeout: 请求超时时间（秒）

        Returns:
            bool: 回调是否成功
        """
        if not callback_url:
            celery_logger.debug(f"[回调] 任务 {task_id[:12]}... 未配置回调URL，跳过")
            return True

        celery_logger.info(f"[回调] 开始通知业务端: {callback_url}")
        celery_logger.info(f"[回调] 任务ID: {task_id}")
        celery_logger.info(f"[回调] 状态: {status}")

        # 构建回调数据
        callback_data = {
            "task_id": task_id,
            "status": status,
            "timestamp": datetime.now().isoformat(),
        }

        if status == "success" and result:
            callback_data["result"] = result
        elif status == "failure" and error:
            callback_data["error"] = error

        try:
            # 发送POST请求到业务端
            response = requests.post(
                callback_url,
                json=callback_data,
                timeout=timeout,
                headers={
                    "Content-Type": "application/json",
                    "User-Agent": "GEE-Service-Callback/1.0"
                }
            )

            # 检查响应状态
            if response.status_code == 200:
                celery_logger.info(
                    f"[回调] ✓ 回调成功 | "
                    f"URL: {callback_url} | "
                    f"响应: {response.status_code}"
                )
                return True
            else:
                celery_logger.warning(
                    f"[回调] ⚠ 回调失败 | "
                    f"URL: {callback_url} | "
                    f"状态码: {response.status_code} | "
                    f"响应: {response.text[:200]}"
                )
                return False

        except requests.exceptions.Timeout:
            celery_logger.error(
                f"[回调] ✗ 回调超时 | "
                f"URL: {callback_url} | "
                f"超时时间: {timeout}秒"
            )
            return False

        except requests.exceptions.ConnectionError as e:
            celery_logger.error(
                f"[回调] ✗ 连接失败 | "
                f"URL: {callback_url} | "
                f"错误: {str(e)[:200]}"
            )
            return False

        except Exception as e:
            celery_logger.error(
                f"[回调] ✗ 回调异常 | "
                f"URL: {callback_url} | "
                f"错误类型: {type(e).__name__} | "
                f"错误: {str(e)[:200]}"
            )
            return False

    @staticmethod
    def notify_success(callback_url: str, task_id: str, result: Dict) -> bool:
        """
        通知任务成功

        Args:
            callback_url: 回调URL
            task_id: 任务ID
            result: 任务结果

        Returns:
            bool: 回调是否成功
        """
        return CallbackService.notify_callback(
            callback_url=callback_url,
            task_id=task_id,
            status="success",
            result=result
        )

    @staticmethod
    def notify_failure(callback_url: str, task_id: str, error: str) -> bool:
        """
        通知任务失败

        Args:
            callback_url: 回调URL
            task_id: 任务ID
            error: 错误信息

        Returns:
            bool: 回调是否成功
        """
        return CallbackService.notify_callback(
            callback_url=callback_url,
            task_id=task_id,
            status="failure",
            error=error
        )


# 便捷函数
def notify_callback_success(callback_url: str, task_id: str, result: Dict) -> bool:
    """通知任务成功（便捷函数）"""
    return CallbackService.notify_success(callback_url, task_id, result)


def notify_callback_failure(callback_url: str, task_id: str, error: str) -> bool:
    """通知任务失败（便捷函数）"""
    return CallbackService.notify_failure(callback_url, task_id, error)
