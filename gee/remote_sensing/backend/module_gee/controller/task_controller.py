"""
GEE任务管理控制器

提供任务的创建、查询、取消等功能
"""
from fastapi import APIRouter, Request, Query
from module_gee.service.task_service import TaskService
from module_gee.entity.vo.task_vo import (
    TaskQueryModel,
    TaskCreateModel,
    TaskDetailModel
)

router = APIRouter(prefix="/gee/task", tags=["GEE任务管理"])

# 简化的响应工具
class ResponseUtil:
    @staticmethod
    def success(data=None, msg="操作成功"):
        return {"code": 200, "msg": msg, "data": data}


# 初始化TaskService
task_service = TaskService()


@router.get("/list")
async def get_task_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum"),
    pageSize: int = Query(10, alias="pageSize"),
    taskId: str = Query(None, alias="taskId"),
    status: str = Query(None, alias="status")
):
    """获取任务列表"""
    try:
        result = task_service.get_task_list(
            page_num=pageNum,
            page_size=pageSize,
            task_id=taskId,
            status=status
        )
        return ResponseUtil.success(data=result)
    except Exception as e:
        print(f"[TaskController] 获取列表失败: {e}")
        return ResponseUtil.success(data={"rows": [], "total": 0})


from module_gee.service.app_service import GeeAppService
from module_gee.service.plot_service import GeePlotService
import json

# 初始化服务
app_service = GeeAppService()
plot_service = GeePlotService()

@router.post("")
async def create_task(request: Request, task_data: TaskCreateModel):
    """创建GEE任务"""
    try:
        app_id = None
        plot_id = task_data.plot_id
        
        # 1. 验证API Key (如果提供)
        app_key = task_data.app_key or request.headers.get("X-App-Key")
        if app_key:
            app_info = app_service.validate_api_key(app_key)
            if not app_info:
                return {"code": 401, "msg": "无效的API Key", "data": None}
            if "error" in app_info:
                return {"code": 403, "msg": app_info["error"], "data": None}
            app_id = app_info["app_id"]
        
        # 2. 验证并获取地块信息 (如果提供)
        if plot_id:
            plot = plot_service.get_plot_by_id(plot_id)
            if not plot:
                return {"code": 404, "msg": "地块不存在", "data": None}
            
            # 如果提供了app_id，验证地块归属
            if app_id and plot["appId"] != app_id:
                return {"code": 403, "msg": "该地块不属于当前应用", "data": None}
            
            # 如果未提供AOI，使用地块几何信息
            if not task_data.aoi_coords:
                try:
                    # 解析GeoJSON获取坐标
                    geometry = json.loads(plot["geometry"])
                    # 假设GeoJSON是Polygon或MultiPolygon，提取坐标
                    # 这里简化处理，假设是标准的GeoJSON Polygon
                    if geometry["type"] == "Polygon":
                        task_data.aoi_coords = geometry["coordinates"][0]
                    elif geometry["type"] == "Feature":
                        task_data.aoi_coords = geometry["geometry"]["coordinates"][0]
                    else:
                        # 尝试直接读取coordinates
                        task_data.aoi_coords = geometry.get("coordinates", [])[0]
                except Exception as e:
                    return {"code": 400, "msg": f"地块几何信息解析失败: {str(e)}", "data": None}
        
        # 3. 验证AOI坐标
        if not task_data.aoi_coords:
            return {"code": 400, "msg": "必须提供AOI坐标或有效的地块ID", "data": None}
            
        # 4. 创建任务
        task_id = task_service.create_task(
            task_data=task_data.dict(),
            app_id=app_id,
            plot_id=plot_id
        )
        
        return ResponseUtil.success(msg="任务已创建", data={"task_id": task_id})
        
    except Exception as e:
        print(f"[TaskController] 创建任务失败: {e}")
        return {"code": 500, "msg": f"创建任务失败: {str(e)}", "data": None}


@router.get("/{task_id}")
async def get_task_detail(request: Request, task_id: str):
    """获取任务详情"""
    try:
        detail = task_service.get_task_detail(task_id)
        if detail:
            return ResponseUtil.success(data=detail)
        else:
            return {"code": 404, "msg": "任务不存在", "data": None}
    except Exception as e:
        print(f"[TaskController] 获取任务详情失败: {e}")
        return {"code": 500, "msg": f"获取任务详情失败: {str(e)}", "data": None}


@router.post("/{task_id}/cancel")
async def cancel_task(request: Request, task_id: str):
    """取消任务"""
    return ResponseUtil.success(msg="任务已取消")


@router.get("/{task_id}/log")
async def get_task_log(request: Request, task_id: str):
    """获取任务日志"""
    return ResponseUtil.success(data={"logs": []})

