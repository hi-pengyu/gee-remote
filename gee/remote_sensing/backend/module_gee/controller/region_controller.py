"""行政区管控控制器"""
from fastapi import APIRouter, Body, Request, Query
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.region_policy_service import region_policy_service
from typing import Optional

router = APIRouter(prefix="/gee/region", tags=["行政区管控"])


@router.post("/pause", response_model=CrudResponseModel)
async def pause_region(
    request: Request,
    adcode: str = Body(..., description="行政区代码", embed=True),
    reason: str = Body(..., description="暂停原因", embed=True)
):
    """
    暂停某个行政区的监测
    
    支持前缀匹配：
    - 41 代表河南省
    - 4101 代表郑州市
    - 410100 代表郑州市市辖区
    """
    try:
        operator = request.state.user.get('user_name', 'admin') if hasattr(request.state, 'user') else 'admin'
        result = region_policy_service.pause_region(adcode, reason, operator)
        
        if result.get('success'):
            return CrudResponseModel(
                is_success=True,
                message=f"已暂停行政区 {adcode} 的监测，影响 {result.get('affected_plots', 0)} 个地块",
                result=result
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message=f"暂停失败: {result.get('error', '未知错误')}",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"操作失败: {str(e)}",
            result=None
        )


@router.post("/resume", response_model=CrudResponseModel)
async def resume_region(
    request: Request,
    adcode: str = Body(..., description="行政区代码", embed=True)
):
    """恢复某个行政区的监测"""
    try:
        operator = request.state.user.get('user_name', 'admin') if hasattr(request.state, 'user') else 'admin'
        result = region_policy_service.resume_region(adcode, operator)
        
        if result.get('success'):
            return CrudResponseModel(
                is_success=True,
                message=f"已恢复行政区 {adcode} 的监测，影响 {result.get('affected_plots', 0)} 个地块",
                result=result
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message=f"恢复失败: {result.get('error', '未知错误')}",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"操作失败: {str(e)}",
            result=None
        )


@router.get("/paused-list", response_model=CrudResponseModel)
async def get_paused_regions(request: Request):
    """获取所有暂停的行政区列表"""
    try:
        regions = region_policy_service.get_paused_regions()
        return CrudResponseModel(
            is_success=True,
            message="查询成功",
            result={'rows': regions, 'total': len(regions)}
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/stats/{adcode}", response_model=CrudResponseModel)
async def get_region_stats(
    request: Request,
    adcode: str
):
    """获取某个行政区的地块统计信息"""
    try:
        stats = region_policy_service.get_region_stats(adcode)
        return CrudResponseModel(
            is_success=True,
            message="查询成功",
            result=stats
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )
