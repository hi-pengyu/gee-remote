"""任务结果控制器"""
from fastapi import APIRouter, Query, Request
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.result_service import ResultService
from typing import Optional

# 创建路由
router = APIRouter(prefix="/gee/result", tags=["GEE任务结果"])

# 初始化服务
result_service = ResultService()


@router.get("/list", response_model=CrudResponseModel)
async def get_result_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum", description="页码"),
    pageSize: int = Query(10, alias="pageSize", description="每页数量"),
    taskName: Optional[str] = Query(None, alias="taskName", description="任务名称"),
    cacheSource: Optional[str] = Query(None, alias="cacheSource", description="缓存来源"),
    startDate: Optional[str] = Query(None, alias="startDate", description="开始日期"),
    endDate: Optional[str] = Query(None, alias="endDate", description="结束日期")
):
    """
    获取任务结果列表
    """
    try:
        result = result_service.get_result_list(
            page_num=pageNum,
            page_size=pageSize,
            task_name=taskName,
            cache_source=cacheSource,
            start_date=startDate,
            end_date=endDate
        )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result={
                'rows': result['rows'],
                'total': result['total']
            }
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/detail/{task_id}", response_model=CrudResponseModel)
async def get_result_detail(request: Request, task_id: str):
    """
    获取任务结果详情
    """
    try:
        detail = result_service.get_result_detail(task_id)
        
        if not detail:
            return CrudResponseModel(
                is_success=False,
                message="任务结果不存在",
                result=None
            )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=detail
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/predictions/{task_id}", response_model=CrudResponseModel)
async def get_model_predictions(request: Request, task_id: str):
    """
    获取任务的模型预测结果
    """
    try:
        predictions = result_service.get_model_predictions(task_id)
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=predictions
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


