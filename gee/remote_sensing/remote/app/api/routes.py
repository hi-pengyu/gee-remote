"""API 路由"""
from fastapi import APIRouter, HTTPException, status, Header
from celery.result import AsyncResult
from datetime import datetime
from typing import List, Optional
import redis
import os

from app.utils.logger import api_logger
from app.schemas import (
    GEEDownloadRequest,
    GEEDateRequest,
    WorkflowRequest,
    TaskResponse,
    TaskStatusResponse,
    HealthResponse,
    FileInfo
)
from app.tasks.workflow import (
    download_gee_image_task,
    process_data_task,
    predict_task,
    full_workflow_task
)
from app.celery_app import celery_app
from app.config import settings
from app.services.auth_service import AuthService

# 创建路由器
router = APIRouter(prefix="/api/v1", tags=["API"])
auth_service = AuthService()


@router.post("/gee/download", response_model=TaskResponse, status_code=status.HTTP_202_ACCEPTED)
async def download_gee_image(request: GEEDownloadRequest):
    """
    下载 GEE 遥感图（仅步骤1）
    
    接受坐标参数，启动 GEE 下载任务
    """
    # 生成文件名
    file_name = request.file_name or f"gee_image_{request.target_date}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    api_logger.info(f"📥 接收下载请求 | 文件名: {file_name} | 日期: {request.target_date}")
    api_logger.debug(f"坐标点数: {len(request.aoi_coords)} | 搜索窗口: ±{request.window_days}天")
    
    # 提交 Celery 任务
    task = download_gee_image_task.delay(
        aoi_coords=request.aoi_coords,
        target_date=request.target_date,
        window_days=request.window_days,
        file_name=file_name,
        scale=request.scale
    )
    
    api_logger.info(f"✅ 任务已提交 | Task ID: {task.id}")
    
    return TaskResponse(
        task_id=task.id,
        status="pending",
        message="遥感图下载任务已提交，正在队列中等待处理",
        created_at=datetime.now()
    )


@router.post("/gee/dates", response_model=List[str])
async def get_sentinel2_dates(request: GEEDateRequest):
    """
    查询 Sentinel-2 可用日期
    
    返回指定区域和时间范围内可用的 Sentinel-2 影像日期列表
    """
    from app.services.gee_service import GEEService
    
    api_logger.info(f"🔍 查询日期 | 坐标点数: {len(request.aoi_coords)}")
    
    try:
        service = GEEService()
        dates = service.get_sentinel2_dates(
            aoi_coords=request.aoi_coords,
            start_date=request.start_date,
            end_date=request.end_date,
            cloud_cover_threshold=request.cloud_cover_threshold,
            predict_future=request.predict_future
        )
        return dates
    except Exception as e:
        api_logger.error(f"❌ 查询日期失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.post("/workflow/run", response_model=TaskResponse, status_code=status.HTTP_202_ACCEPTED)
async def run_full_workflow(
    request: WorkflowRequest,
    x_app_key: Optional[str] = Header(None, alias="X-App-Key")
):
    """
    执行完整工作流（下载 + 处理 + 预测）

    这是主要接口：接受坐标后，自动完成所有步骤

    **支持的模型类型**:
    - 单个模型: zg, agb, hsl, spad, n, p, k
    - 所有模型: all (运行全部7个模型并返回所有结果)

    当 model_type='all' 时，系统将依次运行所有可用模型，
    并为每个模型生成独立的预测结果文件。
    
    **认证**:
    - 需要提供 X-App-Key 请求头
    - 如果提供了 plot_id，系统会自动使用地块的几何信息
    """
    # 🔍 DEBUG: 打印函数调用信息
    print("=" * 80)
    print("🔍 DEBUG: run_full_workflow 被调用")
    print(f"   x_app_key 参数值: {x_app_key}")
    print(f"   request 对象: {request}")
    print("=" * 80)
    
    # 1. 验证 API Key
    if not x_app_key:
        print("❌ DEBUG: x_app_key 为空，应该返回 401")
        raise HTTPException(status_code=401, detail="Missing X-App-Key header")
        
    print(f"✅ DEBUG: x_app_key 存在，开始验证: {x_app_key[:20]}...")
    app_info = auth_service.validate_app_key(x_app_key)
    if not app_info:
        print("❌ DEBUG: validate_app_key 返回 None，应该返回 401")
        raise HTTPException(status_code=401, detail="Invalid API Key")
    if "error" in app_info:
        print(f"❌ DEBUG: app_info 包含错误: {app_info['error']}")
        raise HTTPException(status_code=403, detail=app_info["error"])
        
    app_id = app_info["app_id"]
    print(f"✅ DEBUG: 认证通过 | App: {app_info['app_name']} (ID: {app_id})")
    api_logger.info(f"🔐 认证通过 | App: {app_info['app_name']} (ID: {app_id})")

    # 2. 处理地块创建（如果提供了plot_name）
    if request.plot_name and request.aoi_coords:
        try:
            from app.services.plot_service import PlotService
            plot_service = PlotService()
            
            # 创建或获取地块
            plot_id = plot_service.create_or_get_plot(
                app_id=app_id,
                plot_name=request.plot_name,
                geometry=request.aoi_coords,
                description=f"自动创建于工作流任务 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            )
            
            if plot_id:
                request.plot_id = plot_id
                api_logger.info(f"📍 地块已创建/关联 | Plot ID: {plot_id} | 名称: {request.plot_name}")
            else:
                api_logger.warning(f"⚠️ 地块创建失败，继续使用坐标 | 名称: {request.plot_name}")
        except Exception as e:
            api_logger.warning(f"⚠️ 地块处理失败: {e}，继续使用坐标")

    # 3. 处理地块几何信息
    if request.plot_id:
        try:
            geometry = auth_service.get_plot_geometry(request.plot_id, app_id)
            if not geometry:
                raise HTTPException(status_code=404, detail=f"Plot {request.plot_id} not found")
            request.aoi_coords = geometry
            api_logger.info(f"📍 使用地块几何信息 | Plot ID: {request.plot_id}")
        except ValueError as e:
            raise HTTPException(status_code=403, detail=str(e))
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to fetch plot geometry: {str(e)}")
    
    if not request.aoi_coords:
        raise HTTPException(status_code=400, detail="Missing AOI coordinates or valid Plot ID")

    # 验证模型类型（'all' 或单个模型）
    if request.model_type != 'all' and request.model_type not in settings.AVAILABLE_MODELS:
        api_logger.warning(f"❌ 不支持的模型: {request.model_type}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"不支持的模型类型: {request.model_type}. "
                   f"可用模型: {', '.join(settings.AVAILABLE_MODELS)} 或 'all'"
        )

    # 生成文件名
    file_name = request.file_name or f"workflow_{request.target_date}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    api_logger.info(f"📥 接收完整工作流请求")
    api_logger.info(f"   文件名: {file_name}")
    api_logger.info(f"   日期: {request.target_date}")
    api_logger.info(f"   模型: {request.model_type}")
    if request.model_type == 'all':
        api_logger.info(f"   ⚡ 将运行所有 {len(settings.AVAILABLE_MODELS)} 个模型")
    api_logger.info(f"   坐标点数: {len(request.aoi_coords)}")
    if request.callback_url:
        api_logger.info(f"   回调URL: {request.callback_url}")

    # 提交完整工作流任务
    # 注意：Celery任务签名可能需要更新以接受 app_id 和 plot_id
    # 目前先通过 kwargs 传递，或者在任务内部处理
    task = full_workflow_task.delay( 
        aoi_coords=request.aoi_coords,
        target_date=request.target_date,
        model_type=request.model_type,
        window_days=request.window_days,
        file_name=file_name,
        scale=request.scale,
        callback_url=request.callback_url,
        app_id=app_id,      # 传递 App ID
        plot_id=request.plot_id  # 传递 Plot ID
    )

    api_logger.info(f"✅ 工作流任务已提交到 Celery | Task ID: {task.id}")
    api_logger.debug(f"   队列: gee_queue")

    # 构建响应消息
    if request.model_type == 'all':
        message = f"完整工作流任务已提交（运行所有 {len(settings.AVAILABLE_MODELS)} 个模型），正在队列中等待处理"
    else:
        message = f"完整工作流任务已提交（模型: {request.model_type}），正在队列中等待处理"

    return TaskResponse(
        task_id=task.id,
        status="pending",
        message=message,
        created_at=datetime.now()
    )


@router.post("/workflow/run-cached", response_model=TaskResponse, status_code=status.HTTP_202_ACCEPTED)
async def run_cached_workflow(
    request: WorkflowRequest,
    x_app_key: Optional[str] = Header(None, alias="X-App-Key")
):
    """
    执行带缓存的完整工作流 (推荐使用)
    
    优先从缓存获取数据,大幅提升响应速度
    - 缓存命中: 1-3秒
    - 缓存未命中: 30-60秒 (自动下载并缓存)
    - 自动预取相邻瓦片,提高后续命中率
    """
    # 1. 验证 API Key
    if not x_app_key:
        raise HTTPException(status_code=401, detail="Missing X-App-Key header")
        
    app_info = auth_service.validate_app_key(x_app_key)
    if not app_info:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    if "error" in app_info:
        raise HTTPException(status_code=403, detail=app_info["error"])
        
    app_id = app_info["app_id"]
    api_logger.info(f"🔐 认证通过 | App: {app_info['app_name']} (ID: {app_id})")

    # 2. 处理地块创建（如果提供了plot_name）
    if request.plot_name and request.aoi_coords:
        try:
            from app.services.plot_service import PlotService
            plot_service = PlotService()
            
            # 创建或获取地块
            plot_id = plot_service.create_or_get_plot(
                app_id=app_id,
                plot_name=request.plot_name,
                geometry=request.aoi_coords,
                description=f"自动创建于工作流任务 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            )
            
            if plot_id:
                request.plot_id = plot_id
                api_logger.info(f"📍 地块已创建/关联 | Plot ID: {plot_id} | 名称: {request.plot_name}")
            else:
                api_logger.warning(f"⚠️ 地块创建失败，继续使用坐标 | 名称: {request.plot_name}")
        except Exception as e:
            api_logger.warning(f"⚠️ 地块处理失败: {e}，继续使用坐标")

    # 3. 处理地块几何信息
    if request.plot_id:
        try:
            geometry = auth_service.get_plot_geometry(request.plot_id, app_id)
            if not geometry:
                raise HTTPException(status_code=404, detail=f"Plot {request.plot_id} not found")
            request.aoi_coords = geometry
            api_logger.info(f"📍 使用地块几何信息 | Plot ID: {request.plot_id}")
        except ValueError as e:
            raise HTTPException(status_code=403, detail=str(e))
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to fetch plot geometry: {str(e)}")
    
    if not request.aoi_coords:
        raise HTTPException(status_code=400, detail="Missing AOI coordinates or valid Plot ID")

    # 验证模型类型
    if request.model_type != 'all' and request.model_type not in settings.AVAILABLE_MODELS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"不支持的模型类型: {request.model_type}"
        )
    
    # 生成文件名
    file_name = request.file_name or f"cached_{request.target_date}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    api_logger.info(f"📥 接收缓存工作流请求")
    api_logger.info(f"   文件名: {file_name}")
    api_logger.info(f"   日期: {request.target_date}")
    api_logger.info(f"   模型: {request.model_type}")
    api_logger.info(f"   缓存启用: {settings.ENABLE_TILE_CACHE}")
    
    # 导入缓存工作流任务
    from app.tasks.cached_workflow import cached_workflow_task
    
    # 提交任务
    task = cached_workflow_task.delay(
        aoi_coords=request.aoi_coords,
        target_date=request.target_date,
        model_type=request.model_type,
        window_days=request.window_days,
        file_name=file_name,
        scale=request.scale,
        callback_url=request.callback_url,
        app_id=app_id,      # 传递 App ID
        plot_id=request.plot_id  # 传递 Plot ID
    )
    
    api_logger.info(f"✅ 缓存工作流任务已提交 | Task ID: {task.id}")
    
    return TaskResponse(
        task_id=task.id,
        status="pending",
        message=f"带缓存的工作流任务已提交 (模型: {request.model_type})",
        created_at=datetime.now()
    )



@router.get("/tasks/{task_id}", response_model=TaskStatusResponse)
async def get_task_status(task_id: str):
    """
    查询任务状态
    
    通过 task_id 查询任务的执行进度和结果
    """
    task_result = AsyncResult(task_id, app=celery_app)
    
    api_logger.debug(f"🔍 查询任务状态 | Task ID: {task_id} | State: {task_result.state}")
    
    # 基础响应
    response = TaskStatusResponse(
        task_id=task_id,
        status=task_result.state.lower(),
        progress=0
    )
    
    # 根据状态填充详细信息
    if task_result.state == 'PENDING':
        response.progress = 0
        response.current_step = "任务正在队列中等待..."
    
    elif task_result.state == 'STARTED':
        response.progress = 5
        response.current_step = "任务已开始执行..."
    
    elif task_result.state == 'PROGRESS':
        # 自定义进度状态
        info = task_result.info or {}
        response.progress = info.get('progress', 0)
        response.current_step = info.get('message', '处理中...')
    
    elif task_result.state == 'SUCCESS':
        response.progress = 100
        response.status = "success"
        response.current_step = "任务完成！"
        response.completed_at = datetime.now()
        response.result = task_result.result
    
    elif task_result.state == 'FAILURE':
        response.progress = 0
        response.status = "failure"
        response.current_step = "任务失败"
        response.error_message = str(task_result.info)
    
    else:
        response.current_step = f"未知状态: {task_result.state}"
    
    return response


@router.get("/tasks", response_model=List[dict])
async def list_tasks():
    """
    列出所有任务（简化版）
    
    注意：需要 Celery 配置持久化才能获取完整任务列表
    """
    # 这里只是示例，实际需要配置 Celery result backend
    return {
        "message": "任务列表功能需要配置 Celery result backend",
        "tip": "使用 /tasks/{task_id} 查询具体任务状态"
    }


@router.delete("/tasks/{task_id}")
async def cancel_task(task_id: str):
    """
    取消任务
    """
    task_result = AsyncResult(task_id, app=celery_app)
    
    if task_result.state in ['PENDING', 'STARTED', 'PROGRESS']:
        task_result.revoke(terminate=True)
        return {"message": f"任务 {task_id} 已取消"}
    
    return {"message": f"任务 {task_id} 无法取消（状态: {task_result.state}）"}


@router.get("/files/list", response_model=List[FileInfo])
async def list_files():
    """
    列出所有生成的文件
    """
    files = []
    
    # 扫描存储目录
    for dir_path, file_type in [
        (settings.STORAGE_TIF_DIR, 'tif'),
        (settings.STORAGE_CSV_DIR, 'csv'),
        (settings.STORAGE_RESULTS_DIR, 'json')
    ]:
        if os.path.exists(dir_path):
            for filename in os.listdir(dir_path):
                file_path = os.path.join(dir_path, filename)
                if os.path.isfile(file_path):
                    stat = os.stat(file_path)
                    files.append(FileInfo(
                        file_id=filename,
                        file_name=filename,
                        file_path=file_path,
                        file_type=file_type,
                        file_size=stat.st_size,
                        created_at=datetime.fromtimestamp(stat.st_ctime)
                    ))
    
    # 按创建时间倒序排序
    files.sort(key=lambda x: x.created_at, reverse=True)
    
    return files


@router.get("/config")
async def get_config():
    """
    查看当前配置（敏感信息已隐藏）
    """
    return {
        "gee": {
            "project_id": settings.GEE_PROJECT_ID,
            "scale": settings.GEE_SCALE,
            "drive_folder": settings.GEE_DRIVE_FOLDER,
            "search_window_days": settings.GEE_SEARCH_WINDOW_DAYS
        },
        "storage": {
            "tif_dir": settings.STORAGE_TIF_DIR,
            "csv_dir": settings.STORAGE_CSV_DIR,
            "results_dir": settings.STORAGE_RESULTS_DIR
        },
        "prediction": {
            "api_url": settings.PREDICTION_API_URL,
            "available_models": settings.AVAILABLE_MODELS
        }
    }




@router.get("/models")
async def get_available_models():
    """
    查询所有可用的预测模型

    返回所有支持的模型列表，包括模型代码、中文名称、描述等信息
    """
    from app.services.visualization_service import MODEL_NAMES

    models = []
    for model_code in settings.AVAILABLE_MODELS:
        model_info = {
            "code": model_code,
            "name": MODEL_NAMES.get(model_code, model_code.upper()),
            "description": {
                "zg": "株高预测模型",
                "agb": "地上生物量预测模型",
                "hsl": "叶绿素含量预测模型",
                "spad": "SPAD值预测模型",
                "n": "氮含量预测模型",
                "p": "磷含量预测模型",
                "k": "钾含量预测模型"
            }.get(model_code, ""),
            "unit": {
                "zg": "cm",
                "agb": "g/m²",
                "hsl": "mg/g",
                "spad": "SPAD",
                "n": "%",
                "p": "%",
                "k": "%"
            }.get(model_code, "")
        }
        models.append(model_info)

    return {
        "total": len(models),
        "models": models,
        "support_all": True,  # 支持model_type='all'
        "message": "使用 model_type='all' 可以一次运行所有模型"
    }


@router.get("/queue/stats")
async def get_queue_stats():
    """
    查询当前队列状态和并发情况

    返回:
        - active_tasks: 正在执行的任务数
        - waiting_tasks: 排队等待的任务数
        - gee_concurrent_tasks: 正在执行GEE操作的任务数
        - available_gee_slots: 还能接受多少个GEE任务
        - max_gee_concurrent: GEE最大并发数
    """
    from app.celery_app import celery_app
    from app.concurrency_control import get_gee_concurrency_control

    # 获取Celery队列统计
    inspect = celery_app.control.inspect()

    # 获取活跃任务
    active = inspect.active()
    active_count = sum(len(tasks) for tasks in (active or {}).values()) if active else 0

    # 获取等待任务
    reserved = inspect.reserved()
    waiting_count = sum(len(tasks) for tasks in (reserved or {}).values()) if reserved else 0

    # 获取GEE并发控制信息
    concurrency_control = get_gee_concurrency_control()
    gee_concurrent_count = concurrency_control.get_current_count()
    gee_available_slots = concurrency_control.get_available_slots()
    gee_max_concurrent = concurrency_control.max_concurrent

    return {
        "celery_queue": {
            "active_tasks": active_count,
            "waiting_tasks": waiting_count,
            "total_tasks": active_count + waiting_count
        },
        "gee_concurrency": {
            "current_executing": gee_concurrent_count,
            "available_slots": gee_available_slots,
            "max_concurrent": gee_max_concurrent,
            "utilization": f"{(gee_concurrent_count / gee_max_concurrent * 100):.1f}%"
        },
        "status": "busy" if gee_concurrent_count >= gee_max_concurrent else "available",
        "message": f"当前{gee_concurrent_count}个GEE任务执行中，{waiting_count}个任务等待"
    }


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """
    健康检查
    """
    # 检查 Redis 连接
    redis_connected = False
    try:
        r = redis.from_url(settings.CELERY_BROKER_URL, socket_connect_timeout=2)
        r.ping()
        redis_connected = True
    except:
        pass
    
    # 检查 Celery Workers
    celery_workers = 0
    try:
        inspect = celery_app.control.inspect()
        stats = inspect.stats()
        if stats:
            celery_workers = len(stats)
    except:
        pass
    
    # 检查存储目录
    storage_available = all([
        os.path.exists(settings.STORAGE_TIF_DIR),
        os.path.exists(settings.STORAGE_CSV_DIR),
        os.path.exists(settings.STORAGE_RESULTS_DIR)
    ])
    
    return HealthResponse(
        status="healthy" if (redis_connected and celery_workers > 0) else "degraded",
        version=settings.APP_VERSION,
        redis_connected=redis_connected,
        celery_workers=celery_workers,
        storage_available=storage_available
    )


# ========== 瓦片缓存管理API ==========

@router.get("/cache/stats")
async def get_cache_stats():
    """
    获取瓦片缓存统计信息
    
    返回缓存命中率、存储使用情况等
    """
    try:
        from app.services.cache_service import CacheService
        
        cache_service = CacheService()
        stats = cache_service.get_cache_statistics()
        
        return {
            "success": True,
            "cache_enabled": settings.ENABLE_TILE_CACHE,
            "statistics": stats,
            "configuration": {
                "tile_size_km": settings.TILE_SIZE_KM,
                "cache_days": settings.TILE_CACHE_DAYS,
                "max_cache_gb": settings.MAX_CACHE_SIZE_GB,
                "prefetch_enabled": settings.PREFETCH_ADJACENT
            }
        }
        
    except Exception as e:
        api_logger.error(f"获取缓存统计失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.post("/cache/prefetch")
async def manual_prefetch(
    tile_id: str,
    target_date: str,
    window_days: int = 7
):
    """
    手动触发预取相邻瓦片
    
    Args:
        tile_id: 瓦片ID (格式: tile_x_y)
        target_date: 目标日期 (YYYY-MM-DD)
        window_days: 搜索窗口天数
    """
    from app.tasks.workflow import prefetch_adjacent_tiles_task
    
    api_logger.info(f"手动预取请求: {tile_id}, {target_date}")
    
    # 提交后台任务
    task = prefetch_adjacent_tiles_task.delay(
        tile_id=tile_id,
        target_date=target_date,
        window_days=window_days
    )
    
    return {
        "success": True,
        "message": "预取任务已提交",
        "task_id": task.id,
        "tile_id": tile_id
    }


@router.post("/cache/update-expired")
async def update_expired_tiles(limit: int = 10):
    """
    手动触发更新过期瓦片
    
    Args:
        limit: 每次更新的最大数量
    """
    from app.tasks.workflow import update_expired_tiles_task
    
    api_logger.info(f"手动更新过期瓦片: 限制={limit}")
    
    # 提交后台任务
    task = update_expired_tiles_task.delay(limit=limit)
    
    return {
        "success": True,
        "message": "更新任务已提交",
        "task_id": task.id,
        "limit": limit
    }


@router.delete("/cache/cleanup")
async def cleanup_old_tiles(keep_days: int = 30):
    """
    清理旧瓦片
    
    Args:
        keep_days: 保留最近N天的瓦片
    """
    from app.tasks.workflow import cleanup_old_tiles_task
    
    api_logger.info(f"手动清理旧瓦片: 保留={keep_days}天")
    
    # 提交后台任务
    task = cleanup_old_tiles_task.delay(keep_days=keep_days)
    
    return {
        "success": True,
        "message": "清理任务已提交",
        "task_id": task.id,
        "keep_days": keep_days
    }


@router.get("/cache/tiles")
async def list_cached_tiles(limit: int = 50):
    """
    列出缓存的瓦片
    
    Args:
        limit: 返回数量限制
    """
    try:
        from app.services.tile_manager import TileManager
        
        tile_manager = TileManager()
        hot_tiles = tile_manager.get_hot_tiles(limit=limit)
        
        return {
            "success": True,
            "total": len(hot_tiles),
            "tiles": hot_tiles
        }
        
    except Exception as e:
        api_logger.error(f"列出瓦片失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


# ========== 管理员维护API ==========

@router.post("/admin/cleanup-locks")
async def manual_cleanup_locks():
    """
    手动触发 Redis 锁清理
    
    清理过期的任务锁并修正信号量
    """
    from app.tasks.maintenance_tasks import cleanup_redis_locks_task
    
    api_logger.info("手动触发 Redis 锁清理")
    
    task = cleanup_redis_locks_task.delay()
    
    return {
        "success": True,
        "message": "清理任务已提交",
        "task_id": task.id
    }


@router.post("/admin/reset-semaphore")
async def reset_semaphore():
    """
    紧急重置信号量（谨慎使用）
    
    ⚠️ 警告：此操作会强制释放所有锁，请确保没有任务正在运行
    """
    from app.concurrency_control import get_gee_concurrency_control
    
    api_logger.warning("⚠️ 手动重置信号量")
    
    concurrency_control = get_gee_concurrency_control()
    concurrency_control.reset()
    
    return {
        "success": True,
        "message": "信号量已重置为 0",
        "warning": "此操作会强制释放所有锁，请确保没有任务正在运行"
    }


@router.get("/admin/semaphore-status")
async def get_semaphore_status():
    """
    查询信号量状态
    
    返回当前信号量值和实际任务锁数量
    """
    from app.concurrency_control import get_gee_concurrency_control
    
    concurrency_control = get_gee_concurrency_control()
    
    # 获取实际锁数量
    pattern = f"{concurrency_control.task_locks_prefix}*"
    active_locks = 0
    for key in concurrency_control.redis_client.scan_iter(match=pattern):
        if concurrency_control.redis_client.exists(key):
            active_locks += 1
    
    semaphore_value = concurrency_control.get_current_count()
    
    return {
        "semaphore_value": semaphore_value,
        "actual_locks": active_locks,
        "max_concurrent": concurrency_control.max_concurrent,
        "available_slots": concurrency_control.get_available_slots(),
        "is_consistent": semaphore_value == active_locks,
        "warning": None if semaphore_value == active_locks else "信号量与实际锁不一致，建议执行清理"
    }


@router.get("/admin/redis-pool-status")
async def get_redis_pool_status():
    """
    查询 Redis 连接池状态
    
    返回连接池配置和统计信息
    """
    from app.utils.redis_pool import RedisPoolManager
    
    stats = RedisPoolManager.get_pool_stats()
    
    return {
        "success": True,
        "pool_stats": stats,
        "message": "Redis 连接池使用中" if stats.get("initialized") else "连接池未初始化"
    }



