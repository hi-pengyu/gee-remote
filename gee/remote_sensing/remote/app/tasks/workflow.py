"""Celery 任务 - 工作流编排"""
import os
import time
from datetime import datetime
from typing import List
from celery import Task
from app.celery_app import celery_app
from app.services.gee_service import GEEService
from app.services.data_service import DataProcessingService
from app.services.prediction_service import PredictionService
from app.config import settings
from app.utils.logger import celery_logger
from app.concurrency_control import get_gee_concurrency_control
from app.services.task_recorder import TaskRecorder


class WorkflowTask(Task):
    """自定义任务基类 - 支持进度更新"""
    
    def update_progress(self, progress: int, message: str, **kwargs):
        """更新任务进度 - 确保所有数据都可序列化"""
        try:
            # 尝试更新数据库中的进度
            try:
                task_recorder = TaskRecorder()
                task_recorder.update_progress(self.request.id, progress, '1', message)
            except Exception:
                pass
                
            # 确保所有传入的数据都是可序列化的
            meta_data = {
                'progress': int(progress),
                'message': str(message),
                'timestamp': datetime.now().isoformat(),
            }
            
            # 只添加可序列化的额外数据
            for key, value in kwargs.items():
                try:
                    # 尝试序列化测试
                    import json
                    json.dumps(value)
                    meta_data[key] = value
                except (TypeError, ValueError):
                    # 不可序列化的对象转为字符串
                    meta_data[key] = str(value)
            
            self.update_state(
                state='PROGRESS',
                meta=meta_data
            )
        except Exception as e:
            # 进度更新失败不应该中断任务
            print(f"⚠️ 进度更新失败: {e}")


@celery_app.task(bind=True, base=WorkflowTask, name='gee.download_image', queue='gee_queue')
def download_gee_image_task(
    self,
    aoi_coords: list,
    target_date: str,
    window_days: int,
    file_name: str,
    scale: int
):
    """
    任务1: 下载 GEE 遥感图
    
    Returns:
        {
            'tif_path': str,
            'found_date': str,
            'cloud_cover': float
        }
    """
    celery_logger.info("=" * 60)
    celery_logger.info(f"🚀 任务开始: download_gee_image_task")
    celery_logger.info(f"   Task ID: {self.request.id}")
    celery_logger.info(f"   文件名: {file_name}")
    celery_logger.info(f"   日期: {target_date}")
    celery_logger.info("=" * 60)
    
    try:
        self.update_progress(5, "正在初始化 GEE 服务...")
        celery_logger.info("📦 初始化 GEE 服务...")
        
        gee_service = GEEService()
        
        # 导出到 Google Drive
        self.update_progress(10, "正在从 GEE 导出影像...")
        export_result = gee_service.export_image_to_drive(
            aoi_coords=aoi_coords,
            target_date=target_date,
            window_days=window_days,
            file_name=file_name,
            scale=scale
        )
        
        self.update_progress(
            60,
            f"导出完成！影像日期: {export_result['found_date']}, "
            f"云量: {export_result['cloud_cover']:.2f}%"
        )
        
        # 下载到本地
        self.update_progress(65, "正在从 Google Drive 下载...")
        local_path = os.path.join(settings.STORAGE_TIF_DIR, f"{file_name}.tif")
        
        tif_path = gee_service.download_from_drive(
            file_name=file_name,
            local_download_path=local_path
        )
        
        self.update_progress(100, "遥感图下载完成！")
        
        return {
            'success': True,
            'tif_path': tif_path,
            'found_date': export_result['found_date'],
            'cloud_cover': export_result['cloud_cover'],
            'image_count': export_result['image_count']
        }
    
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"❌ 任务失败: {error_msg}")
        
        # 使用简单的可序列化数据来更新状态
        self.update_state(
            state='FAILURE',
            meta={
                'error': error_msg,
                'step': 'download_image',
                'timestamp': datetime.now().isoformat()
            }
        )
        raise Exception(error_msg)


@celery_app.task(bind=True, base=WorkflowTask, name='gee.process_data', queue='gee_queue')
def process_data_task(self, tif_path: str, output_csv_name: str):
    """
    任务2: 处理数据（TIF -> CSV）
    
    Returns:
        {
            'csv_path': str,
            'valid_pixels': int
        }
    """
    try:
        self.update_progress(5, "正在初始化数据处理服务...")
        
        data_service = DataProcessingService()
        
        self.update_progress(10, "正在转换 TIF -> CSV...")
        
        csv_path = os.path.join(settings.STORAGE_CSV_DIR, output_csv_name)
        
        result = data_service.convert_tif_to_csv(
            tif_path=tif_path,
            csv_path=csv_path
        )
        
        self.update_progress(100, f"数据处理完成！有效像素: {result['valid_pixels']:,}")
        
        return {
            'success': True,
            'csv_path': result['csv_path'],
            'total_pixels': result['total_pixels'],
            'valid_pixels': result['valid_pixels']
        }
    
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"❌ 任务失败: {error_msg}")
        
        self.update_state(
            state='FAILURE',
            meta={
                'error': error_msg,
                'step': 'process_data',
                'timestamp': datetime.now().isoformat()
            }
        )
        raise Exception(error_msg)


@celery_app.task(bind=True, base=WorkflowTask, name='gee.predict', queue='gee_queue')
def predict_task(self, csv_path: str, model_type: str):
    """
    任务3: 调用预测 API
    
    Returns:
        {
            'result_path': str,
            'result_count': int
        }
    """
    try:
        self.update_progress(5, f"正在初始化预测服务（模型: {model_type}）...")
        
        prediction_service = PredictionService()
        
        self.update_progress(10, "正在调用外部预测 API...")
        
        result = prediction_service.predict(
            csv_path=csv_path,
            model_type=model_type
        )
        
        if result['success']:
            self.update_progress(
                100,
                f"预测完成！结果数量: {result['result_count']:,}"
            )
            
            return {
                'success': True,
                'result_path': result['result_path'],
                'result_count': result['result_count'],
                'model_type': model_type
            }
        else:
            raise Exception(f"预测失败: {result.get('message', '未知错误')}")
    
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"❌ 任务失败: {error_msg}")
        
        self.update_state(
            state='FAILURE',
            meta={
                'error': error_msg,
                'step': 'predict',
                'timestamp': datetime.now().isoformat()
            }
        )
        raise Exception(error_msg)


@celery_app.task(bind=True, base=WorkflowTask, name='gee.full_workflow', queue='gee_queue')
def full_workflow_task(
    self,
    aoi_coords: list,
    target_date: str,
    model_type: str,
    window_days: int = 2,
    file_name: str = None,
    scale: int = 10,
    callback_url: str = None,  # 新增：回调URL参数
    app_id: int = None,        # 新增：应用ID
    plot_id: int = None        # 新增：地块ID
):
    """
    完整工作流任务：下载 -> 提取数据 -> 本地预测

    优化版：不再生成CSV文件，直接使用DataFrame进行预测
    使用并发控制，限制同时执行的GEE任务数量为5
    支持回调机制：任务完成后自动通知业务端
    """
    start_time = time.time()  # 记录开始时间

    celery_logger.info("=" * 80)
    celery_logger.info(f"🚀 完整工作流任务开始（本地预测）")
    celery_logger.info(f"   Task ID: {self.request.id}")
    celery_logger.info(f"   日期: {target_date}")
    celery_logger.info(f"   模型: {model_type}")
    celery_logger.info(f"   坐标点数: {len(aoi_coords)}")
    if callback_url:
        celery_logger.info(f"   回调URL: {callback_url}")
    celery_logger.info("=" * 80)

    # 初始化任务记录器
    task_recorder = TaskRecorder()
    
    # 记录任务到数据库
    task_recorder.create_task(
        task_id=self.request.id,
        task_type='workflow',
        aoi_coords=aoi_coords,
        target_date=target_date,
        model_type=model_type,
        window_days=window_days,
        metadata={'file_name': file_name, 'scale': scale},
        app_id=app_id,
        plot_id=plot_id
    )

    # 获取并发控制器
    concurrency_control = get_gee_concurrency_control()

    # 获取执行权限（信号量）
    celery_logger.info(f"[并发控制] 尝试获取GEE执行权限...")
    if not concurrency_control.acquire(self.request.id, timeout=600):  # 10分钟超时
        error_msg = "获取GEE执行权限超时，队列可能拥堵"
        celery_logger.error(f"❌ {error_msg}")
        task_recorder.fail_task(self.request.id, error_msg)
        raise Exception(error_msg)

    try:
        # 生成文件名
        if not file_name:
            file_name = f"gee_image_{target_date}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        celery_logger.info(f"📁 生成文件名: {file_name}")
        
        # ========== 步骤1: 下载遥感图 ==========
        celery_logger.info("")
        celery_logger.info("📥 步骤 1/3: 开始下载遥感图")
        self.update_progress(0, "步骤 1/3: 开始下载遥感图...")
        
        celery_logger.info("   初始化 GEE 服务...")
        gee_service = GEEService()
        
        self.update_progress(5, "正在从 GEE 导出影像...")
        export_result = gee_service.export_image_to_drive(
            aoi_coords=aoi_coords,
            target_date=target_date,
            window_days=window_days,
            file_name=file_name,
            scale=scale
        )
        
        self.update_progress(
            20,
            f"导出完成！日期: {export_result['found_date']}, 云量: {export_result['cloud_cover']:.2f}%"
        )
        
        self.update_progress(25, "正在从 Google Drive 下载...")
        local_tif_path = os.path.join(settings.STORAGE_TIF_DIR, f"{file_name}.tif")
        tif_path = gee_service.download_from_drive(file_name, local_tif_path)
        
        self.update_progress(40, f"✓ 步骤 1/3 完成！TIF 文件: {tif_path}")
        
        # ========== 步骤2: 提取数据（不保存CSV）==========
        self.update_progress(45, "步骤 2/3: 开始提取数据...")
        
        data_service = DataProcessingService()
        
        self.update_progress(50, "正在从 TIF 提取数据...")
        df, data_metadata = data_service.extract_dataframe_from_tif(tif_path)
        
        self.update_progress(
            60,
            f"✓ 步骤 2/3 完成！有效像素: {data_metadata['valid_pixels']:,}"
        )
        
        # ========== 步骤3: 本地预测 ==========
        self.update_progress(65, f"步骤 3/3: 开始预测（模型: {model_type}）...")

        prediction_service = PredictionService()

        # 判断是运行所有模型还是单个模型
        if model_type == 'all':
            celery_logger.info("[Workflow] 运行所有模型预测")
            self.update_progress(70, "正在使用所有本地模型预测...")

            predict_result = prediction_service.predict_all_models(
                df=df,
                file_name=file_name,
                tif_path=tif_path,  # 传递TIF路径
                geo_bounds=data_metadata.get('geo_bounds')  # 传递地理坐标
            )

            if not predict_result['success']:
                celery_logger.warning(f"所有模型预测均失败")
            else:
                celery_logger.info(f"成功模型数: {len(predict_result['successful_models'])}")

            self.update_progress(
                100,
                f"✓ 步骤 3/3 完成！运行了 {predict_result['models_count']['total']} 个模型，"
                f"成功 {predict_result['models_count']['successful']} 个"
            )

            # 计算处理时间
            processing_time = round(time.time() - start_time, 2)

            # ========== 步骤4: 上传到OSS（可选）==========
            oss_upload_info = None
            if settings.OSS_ENABLE_UPLOAD:
                self.update_progress(95, "正在上传文件到OSS...")
                celery_logger.info("[Workflow] 开始上传文件到OSS")

                try:
                    from app.services.oss_service import OSSService
                    oss_service = OSSService()

                    # 收集需要上传的文件
                    files_to_upload = [tif_path]  # TIF文件

                    # 收集PNG文件（从all_models_results中）
                    all_models_results = predict_result.get('all_models_results', {})
                    if not isinstance(all_models_results, dict):
                        raise TypeError(f"all_models_results 应为字典，当前类型为 {type(all_models_results)}")

                    png_paths = []
                    for model_name, model_result in all_models_results.items():
                        if not isinstance(model_result, dict):
                            celery_logger.warning(f"[Workflow] 模型 {model_name} 返回了非字典结果，跳过PNG收集")
                            continue

                        visualization_info = model_result.get('visualization', {})
                        image_path = visualization_info.get('image_path') if isinstance(visualization_info, dict) else None

                        if model_result.get('success') and image_path:
                            png_paths.append(image_path)

                    celery_logger.info(f"[Workflow] 准备上传: TIF={tif_path}, PNG数量={len(png_paths)}")

                    # 上传TIF和PNG文件
                    oss_result = oss_service.upload_tif_and_pngs(
                        tif_path=tif_path,
                        png_paths=png_paths,
                        delete_local=settings.OSS_DELETE_LOCAL
                    )

                    celery_logger.info(f"[Workflow] OSS上传结果类型: {type(oss_result)}")
                    celery_logger.info(f"[Workflow] OSS上传结果: {oss_result}")

                    # 安全地提取结果
                    if not isinstance(oss_result, dict):
                        raise TypeError(f"OSS上传返回了非字典类型: {type(oss_result)}")

                    oss_upload_info = {
                        'enabled': True,
                        'total_uploaded': oss_result.get('total_uploaded', 0),
                        'total_deleted': oss_result.get('total_deleted', 0),
                        'tif_url': oss_result.get('tif_result', {}).get('oss_url') if isinstance(oss_result.get('tif_result'), dict) and oss_result.get('tif_result', {}).get('success') else None,
                        'png_urls': [r.get('oss_url') for r in oss_result.get('png_results', []) if isinstance(r, dict) and r.get('success')]
                    }

                    celery_logger.info(
                        f"[Workflow] OSS上传完成 | "
                        f"已上传: {oss_result.get('total_uploaded', 0)} | "
                        f"已删除: {oss_result.get('total_deleted', 0)}"
                    )

                except Exception as e:
                    celery_logger.warning(f"[Workflow] OSS上传失败: {str(e)}")
                    celery_logger.warning(f"[Workflow] 错误类型: {type(e).__name__}")
                    import traceback
                    celery_logger.warning(f"[Workflow] 错误堆栈:\n{traceback.format_exc()}")
                    oss_upload_info = {
                        'enabled': True,
                        'error': str(e),
                        'total_uploaded': 0,
                        'total_deleted': 0
                    }
            else:
                celery_logger.info("[Workflow] OSS上传已禁用")
                oss_upload_info = {'enabled': False}

            # 返回所有模型的结果
            result = {
                'success': True,
                'file_name': file_name,
                'tif_path': tif_path if not (settings.OSS_ENABLE_UPLOAD and settings.OSS_DELETE_LOCAL) else None,
                'all_models': True,
                'all_models_results': predict_result['all_models_results'],
                'oss_upload': oss_upload_info,  # 添加OSS上传信息
                'metadata': {
                    'found_date': export_result['found_date'],
                    'cloud_cover': export_result['cloud_cover'],
                    'image_count': export_result['image_count'],
                    'total_pixels': data_metadata['total_pixels'],
                    'valid_pixels': data_metadata['valid_pixels'],
                    'geo_bounds': data_metadata.get('geo_bounds'),  # 添加地理坐标边界
                    'total_predictions': predict_result['total_predictions'],
                    'model_type': predict_result['successful_models'],  # 返回成功模型的数组
                    'models_count': predict_result['models_count'],
                    'successful_models': predict_result['successful_models'],
                    'failed_models': predict_result['failed_models'],
                    'processing_time_seconds': processing_time
                }
            }

            # 发送成功回调
            if callback_url:
                from app.services.callback_service import notify_callback_success
                notify_callback_success(callback_url, self.request.id, result)

            # 记录任务完成
            execution_time = time.time() - start_time
            
            # 构建完整的结果对象（用于数据库存储）
            full_result_for_db = {
                'task_id': self.request.id,
                'status': 'success',
                'progress': 100,
                'result': result
            }
            
            task_recorder.complete_task(
                task_id=self.request.id,
                result_path=result.get('result_path') or result.get('tif_path'),
                result_data={
                    'found_date': export_result['found_date'],
                    'cloud_cover': export_result['cloud_cover']
                },
                execution_time=execution_time,
                full_result=full_result_for_db
            )

            return result
        else:
            # 运行单个模型（原有逻辑）
            celery_logger.info(f"[Workflow] 运行单个模型: {model_type}")
            self.update_progress(70, f"正在使用本地模型 {model_type} 预测...")

            predict_result = prediction_service.predict_from_dataframe(
                df=df,
                model_type=model_type,
                file_name=file_name,
                tif_path=tif_path,  # 传递TIF路径
                geo_bounds=data_metadata.get('geo_bounds')  # 传递地理坐标
            )

            if not predict_result['success']:
                celery_logger.warning(f"预测未成功: {predict_result.get('message')}")
                # 即使预测失败，也返回植被指数等信息

            self.update_progress(
                100,
                f"✓ 步骤 3/3 完成！预测结果: {predict_result['result_count']:,} 个"
            )

            # 计算处理时间
            processing_time = round(time.time() - start_time, 2)

            # ========== 步骤4: 上传到OSS（可选）==========
            oss_upload_info = None
            if settings.OSS_ENABLE_UPLOAD:
                self.update_progress(95, "正在上传文件到OSS...")
                celery_logger.info("[Workflow] 开始上传文件到OSS")

                try:
                    from app.services.oss_service import OSSService
                    oss_service = OSSService()

                    # 收集PNG文件
                    png_paths = []
                    if predict_result.get('png_path'):
                        png_paths.append(predict_result['png_path'])

                    # 上传TIF和PNG文件
                    oss_result = oss_service.upload_tif_and_pngs(
                        tif_path=tif_path,
                        png_paths=png_paths,
                        delete_local=settings.OSS_DELETE_LOCAL
                    )

                    oss_upload_info = {
                        'enabled': True,
                        'total_uploaded': oss_result['total_uploaded'],
                        'total_deleted': oss_result['total_deleted'],
                        'tif_url': oss_result['tif_result'].get('oss_url') if isinstance(oss_result['tif_result'], dict) and oss_result['tif_result'].get('success') else None,
                        'png_urls': [r.get('oss_url') for r in oss_result.get('png_results', []) if isinstance(r, dict) and r.get('success')]
                    }

                    celery_logger.info(
                        f"[Workflow] OSS上传完成 | "
                        f"已上传: {oss_result['total_uploaded']} | "
                        f"已删除: {oss_result['total_deleted']}"
                    )

                except Exception as e:
                    celery_logger.warning(f"[Workflow] OSS上传失败: {str(e)}")
                    oss_upload_info = {
                        'enabled': True,
                        'error': str(e),
                        'total_uploaded': 0,
                        'total_deleted': 0
                    }
            else:
                celery_logger.info("[Workflow] OSS上传已禁用")
                oss_upload_info = {'enabled': False}

            # 返回单个模型的结果（原有格式）
            result = {
                'success': True,
                'file_name': file_name,
                'tif_path': tif_path if not (settings.OSS_ENABLE_UPLOAD and settings.OSS_DELETE_LOCAL) else None,
                'result_path': predict_result.get('result_path'),
                'oss_upload': oss_upload_info,  # 添加OSS上传信息
                'metadata': {
                    'found_date': export_result['found_date'],
                    'cloud_cover': export_result['cloud_cover'],
                    'image_count': export_result['image_count'],
                    'total_pixels': data_metadata['total_pixels'],
                    'valid_pixels': data_metadata['valid_pixels'],
                    'geo_bounds': data_metadata.get('geo_bounds'),  # 添加地理坐标边界
                    'result_count': predict_result.get('result_count', 0),
                    'model_type': [model_type],  # 返回数组格式以保持一致
                    'prediction_success': predict_result['success'],
                    'indices': predict_result.get('indices', {}),
                    'processing_time_seconds': processing_time
                }
            }

            # 发送成功回调
            if callback_url:
                from app.services.callback_service import notify_callback_success
                notify_callback_success(callback_url, self.request.id, result)

            # 记录任务完成
            execution_time = time.time() - start_time
            
            # 构建完整的结果对象（用于数据库存储）
            full_result_for_db = {
                'task_id': self.request.id,
                'status': 'success',
                'progress': 100,
                'result': result
            }
            
            task_recorder.complete_task(
                task_id=self.request.id,
                result_path=result.get('result_path') or result.get('tif_path'),
                result_data={
                    'found_date': export_result['found_date'],
                    'cloud_cover': export_result['cloud_cover']
                },
                execution_time=execution_time,
                full_result=full_result_for_db
            )

            return result

    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"❌ 完整工作流失败: {error_msg}")
        celery_logger.error(f"   错误类型: {type(e).__name__}")

        import traceback
        error_trace = traceback.format_exc()
        celery_logger.error(f"   错误堆栈:\n{error_trace}")

        # 记录任务失败
        task_recorder.fail_task(
            task_id=self.request.id,
            error_message=error_msg,
            error_traceback=error_trace
        )

        # 发送失败回调
        if callback_url:
            from app.services.callback_service import notify_callback_failure
            notify_callback_failure(callback_url, self.request.id, error_msg)

        # 使用简单的可序列化数据
        self.update_state(
            state='FAILURE',
            meta={
                'error': error_msg,
                'error_type': type(e).__name__,
                'timestamp': datetime.now().isoformat()
            }
        )
        raise Exception(error_msg)

    finally:
        # 无论成功失败,都释放并发控制
        concurrency_control.release(self.request.id)


# ========== 瓦片缓存后台任务 ==========

@celery_app.task(bind=True, base=WorkflowTask, name='cache.prefetch_tiles', queue='gee_queue')
def prefetch_adjacent_tiles_task(
    self,
    tile_id: str,
    target_date: str,
    window_days: int = 7
):
    """
    后台任务:预取相邻瓦片
    
    Args:
        tile_id: 中心瓦片ID
        target_date: 目标日期
        window_days: 搜索窗口
    """
    celery_logger.info(f"[Cache] 开始预取相邻瓦片: {tile_id}")
    
    try:
        from app.services.cache_service import CacheService
        from app.services.tile_manager import TileManager
        
        cache_service = CacheService()
        tile_manager = TileManager()
        
        # 获取相邻瓦片(8邻域)
        adjacent_tiles = tile_manager.get_adjacent_tiles(tile_id, include_diagonals=True)
        
        celery_logger.info(f"[Cache] 需要预取 {len(adjacent_tiles)} 个相邻瓦片")
        
        # 预取瓦片
        result = cache_service.prefetch_tiles(
            tile_ids=adjacent_tiles,
            target_date=target_date,
            window_days=window_days
        )
        
        celery_logger.info(
            f"[Cache] 预取完成 | "
            f"成功: {result['success']} | "
            f"跳过: {result['skipped']} | "
            f"失败: {result['failed']}"
        )
        
        return {
            'success': True,
            'tile_id': tile_id,
            'result': result
        }
        
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"[Cache] 预取失败: {error_msg}")
        return {
            'success': False,
            'error': error_msg
        }


@celery_app.task(bind=True, base=WorkflowTask, name='cache.update_expired', queue='gee_queue')
def update_expired_tiles_task(self, limit: int = 10):
    """
    后台任务:更新过期瓦片
    
    Args:
        limit: 每次更新的最大数量
    """
    celery_logger.info(f"[Cache] 开始更新过期瓦片(限制: {limit})")
    
    try:
        from app.services.cache_service import CacheService
        from app.services.tile_manager import TileManager
        
        cache_service = CacheService()
        tile_manager = TileManager()
        
        # 获取过期瓦片
        expired_tiles = tile_manager.get_expired_tiles(limit=limit)
        
        if not expired_tiles:
            celery_logger.info("[Cache] 没有过期瓦片需要更新")
            return {
                'success': True,
                'updated': 0,
                'message': '没有过期瓦片'
            }
        
        celery_logger.info(f"[Cache] 找到 {len(expired_tiles)} 个过期瓦片")
        
        # 更新瓦片
        success_count = 0
        for tile_info in expired_tiles:
            try:
                if cache_service.update_expired_tile(
                    tile_info['tile_id'],
                    tile_info['date_acquired']
                ):
                    success_count += 1
            except Exception as e:
                celery_logger.warning(
                    f"[Cache] 更新瓦片失败 {tile_info['tile_id']}: {e}"
                )
        
        celery_logger.info(f"[Cache] 更新完成,成功: {success_count}/{len(expired_tiles)}")
        
        return {
            'success': True,
            'total': len(expired_tiles),
            'updated': success_count
        }
        
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"[Cache] 更新过期瓦片失败: {error_msg}")
        return {
            'success': False,
            'error': error_msg
        }


@celery_app.task(bind=True, base=WorkflowTask, name='cache.cleanup', queue='gee_queue')
def cleanup_old_tiles_task(self, keep_days: int = 30):
    """
    后台任务:清理旧瓦片
    
    Args:
        keep_days: 保留最近N天的瓦片
    """
    celery_logger.info(f"[Cache] 开始清理旧瓦片(保留 {keep_days} 天)")
    
    try:
        from app.services.tile_manager import TileManager
        
        tile_manager = TileManager()
        
        # 清理旧瓦片
        deleted_count = tile_manager.cleanup_old_tiles(keep_days=keep_days)
        
        celery_logger.info(f"[Cache] 清理完成,删除 {deleted_count} 个瓦片")
        
        return {
            'success': True,
            'deleted': deleted_count
        }
        
    except Exception as e:
        error_msg = str(e)
        celery_logger.error(f"[Cache] 清理失败: {error_msg}")
        return {
            'success': False,
            'error': error_msg
        }

