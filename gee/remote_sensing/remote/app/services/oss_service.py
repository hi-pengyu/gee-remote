"""阿里云OSS上传服务"""
import os
import oss2
from typing import Optional, List, Dict
from datetime import datetime
from app.utils.logger import celery_logger


class OSSService:
    """阿里云OSS上传服务"""

    def __init__(
        self,
        access_key_id: str = None,
        access_key_secret: str = None,
        endpoint: str = None,
        bucket_name: str = None
    ):
        """
        初始化OSS服务

        Args:
            access_key_id: 阿里云AccessKey ID
            access_key_secret: 阿里云AccessKey Secret
            endpoint: OSS区域节点（如 oss-cn-hangzhou.aliyuncs.com）
            bucket_name: OSS Bucket名称
        """
        # 从配置或参数获取
        from app.config import settings

        self.access_key_id = access_key_id or settings.OSS_ACCESS_KEY_ID
        self.access_key_secret = access_key_secret or settings.OSS_ACCESS_KEY_SECRET
        self.endpoint = endpoint or settings.OSS_ENDPOINT
        self.bucket_name = bucket_name or settings.OSS_BUCKET_NAME

        # 验证配置
        if not all([self.access_key_id, self.access_key_secret, self.endpoint, self.bucket_name]):
            raise ValueError("OSS配置不完整，请检查环境变量")

        # 创建认证对象
        self.auth = oss2.Auth(self.access_key_id, self.access_key_secret)

        # 创建Bucket对象
        self.bucket = oss2.Bucket(self.auth, self.endpoint, self.bucket_name)

        celery_logger.info(f"[OSS] 初始化成功 | Bucket: {self.bucket_name} | Endpoint: {self.endpoint}")

    def upload_file(
        self,
        local_file_path: str,
        oss_object_key: str = None,
        delete_local: bool = True
    ) -> Dict:
        """
        上传单个文件到OSS

        Args:
            local_file_path: 本地文件路径
            oss_object_key: OSS对象键（可选，默认使用文件名）
            delete_local: 上传成功后是否删除本地文件

        Returns:
            {
                'success': bool,
                'oss_url': str,
                'oss_object_key': str,
                'file_size': int,
                'deleted_local': bool
            }
        """
        try:
            # 检查本地文件是否存在
            if not os.path.exists(local_file_path):
                raise FileNotFoundError(f"本地文件不存在: {local_file_path}")

            # 默认使用文件名作为对象键
            if not oss_object_key:
                file_name = os.path.basename(local_file_path)
                # 构建OSS路径（按日期分类）
                date_str = datetime.now().strftime('%Y/%m/%d')
                oss_object_key = f"gee/{date_str}/{file_name}"

            # 获取文件大小
            file_size = os.path.getsize(local_file_path)

            celery_logger.info(f"[OSS] 开始上传: {local_file_path} -> {oss_object_key}")
            celery_logger.info(f"[OSS] 文件大小: {file_size / 1024 / 1024:.2f} MB")

            # 上传文件
            result = self.bucket.put_object_from_file(oss_object_key, local_file_path)

            # 检查上传是否成功（HTTP 200）
            if result.status == 200:
                # 构建文件访问URL
                oss_url = f"https://{self.bucket_name}.{self.endpoint}/{oss_object_key}"

                celery_logger.info(f"[OSS] ✓ 上传成功 | URL: {oss_url}")

                # 删除本地文件（如果需要）
                deleted_local = False
                if delete_local:
                    try:
                        os.remove(local_file_path)
                        deleted_local = True
                        celery_logger.info(f"[OSS] ✓ 本地文件已删除: {local_file_path}")
                    except Exception as e:
                        celery_logger.warning(f"[OSS] ⚠ 本地文件删除失败: {e}")

                return {
                    'success': True,
                    'oss_url': oss_url,
                    'oss_object_key': oss_object_key,
                    'file_size': file_size,
                    'deleted_local': deleted_local
                }
            else:
                raise Exception(f"上传失败，HTTP状态码: {result.status}")

        except Exception as e:
            celery_logger.error(f"[OSS] ✗ 上传失败: {local_file_path} | 错误: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'local_file_path': local_file_path
            }

    def upload_files(
        self,
        file_paths: List[str],
        delete_local: bool = True
    ) -> Dict:
        """
        批量上传文件到OSS

        Args:
            file_paths: 本地文件路径列表
            delete_local: 上传成功后是否删除本地文件

        Returns:
            {
                'total': int,
                'successful': int,
                'failed': int,
                'results': List[Dict]
            }
        """
        celery_logger.info(f"[OSS] 开始批量上传 | 文件数: {len(file_paths)}")

        results = []
        successful = 0
        failed = 0

        for file_path in file_paths:
            result = self.upload_file(file_path, delete_local=delete_local)
            results.append(result)

            if result['success']:
                successful += 1
            else:
                failed += 1

        celery_logger.info(
            f"[OSS] 批量上传完成 | "
            f"总数: {len(file_paths)} | "
            f"成功: {successful} | "
            f"失败: {failed}"
        )

        return {
            'total': len(file_paths),
            'successful': successful,
            'failed': failed,
            'results': results
        }

    def upload_tif_and_pngs(
        self,
        tif_path: str,
        png_paths: List[str] = None,
        delete_local: bool = True
    ) -> Dict:
        """
        上传TIF文件和相关PNG文件

        Args:
            tif_path: TIF文件路径
            png_paths: PNG文件路径列表（可选）
            delete_local: 上传成功后是否删除本地文件

        Returns:
            {
                'success': bool,
                'tif_result': Dict,
                'png_results': List[Dict],
                'total_uploaded': int,
                'total_deleted': int
            }
        """
        celery_logger.info(f"[OSS] 上传TIF和PNG文件")

        # 上传TIF文件
        tif_result = self.upload_file(tif_path, delete_local=delete_local)

        # 检查 tif_result 是否为字典
        if not isinstance(tif_result, dict):
            celery_logger.error(f"[OSS] TIF上传返回了非字典类型: {type(tif_result)} - {tif_result}")
            return {
                'success': False,
                'tif_result': {'success': False, 'error': 'Invalid return type'},
                'png_results': [],
                'total_uploaded': 0,
                'total_deleted': 0
            }

        # 上传PNG文件
        png_results = []
        if png_paths:
            for png_path in png_paths:
                if os.path.exists(png_path):
                    png_result = self.upload_file(png_path, delete_local=delete_local)
                    # 确保结果是字典
                    if isinstance(png_result, dict):
                        png_results.append(png_result)
                    else:
                        celery_logger.warning(f"[OSS] PNG上传返回了非字典类型: {type(png_result)}")
                        png_results.append({'success': False, 'error': 'Invalid return type'})

        # 统计结果（添加安全检查）
        total_uploaded = (1 if isinstance(tif_result, dict) and tif_result.get('success') else 0) + sum(
            1 for r in png_results if isinstance(r, dict) and r.get('success')
        )
        total_deleted = (1 if isinstance(tif_result, dict) and tif_result.get('deleted_local', False) else 0) + sum(
            1 for r in png_results if isinstance(r, dict) and r.get('deleted_local', False)
        )

        success = isinstance(tif_result, dict) and tif_result.get('success', False) and all(
            isinstance(r, dict) and r.get('success', False) for r in png_results
        )

        celery_logger.info(
            f"[OSS] TIF和PNG上传完成 | "
            f"已上传: {total_uploaded} | "
            f"已删除: {total_deleted}"
        )

        return {
            'success': success,
            'tif_result': tif_result,
            'png_results': png_results,
            'total_uploaded': total_uploaded,
            'total_deleted': total_deleted
        }

    def delete_object(self, oss_object_key: str) -> bool:
        """
        删除OSS上的对象

        Args:
            oss_object_key: OSS对象键

        Returns:
            bool: 是否删除成功
        """
        try:
            self.bucket.delete_object(oss_object_key)
            celery_logger.info(f"[OSS] ✓ 对象已删除: {oss_object_key}")
            return True
        except Exception as e:
            celery_logger.error(f"[OSS] ✗ 删除对象失败: {oss_object_key} | 错误: {e}")
            return False

    def get_object_url(self, oss_object_key: str, expires: int = 3600) -> str:
        """
        生成OSS对象的临时访问URL

        Args:
            oss_object_key: OSS对象键
            expires: 过期时间（秒），默认1小时

        Returns:
            str: 临时访问URL
        """
        try:
            url = self.bucket.sign_url('GET', oss_object_key, expires)
            return url
        except Exception as e:
            celery_logger.error(f"[OSS] 生成URL失败: {e}")
            return None


# 便捷函数
def upload_to_oss(
    file_paths: List[str],
    delete_local: bool = True
) -> Dict:
    """
    上传文件到OSS（便捷函数）

    Args:
        file_paths: 文件路径列表
        delete_local: 是否删除本地文件

    Returns:
        上传结果字典
    """
    oss_service = OSSService()
    if len(file_paths) == 1:
        return oss_service.upload_file(file_paths[0], delete_local=delete_local)
    else:
        return oss_service.upload_files(file_paths, delete_local=delete_local)
