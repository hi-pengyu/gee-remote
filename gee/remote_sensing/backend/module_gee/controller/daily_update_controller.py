"""每日更新控制器"""
from fastapi import APIRouter, Request, Body
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.daily_update_service import DailyUpdateService
from typing import Optional

router = APIRouter(prefix="/gee/daily-update", tags=["GEE每日更新"])
daily_update_service = DailyUpdateService()


@router.post("/trigger", response_model=CrudResponseModel)
async def trigger_daily_update(
    request: Request,
    appId: Optional[int] = Body(None, embed=True, alias="appId")
):
    """
    触发每日更新
    如果提供 appId，则只更新该应用；否则更新所有启用每日更新的应用
    """
    try:
        result = daily_update_service.trigger_daily_update(appId)
        
        if result.get('success'):
            return CrudResponseModel(
                is_success=True,
                message=result.get('message', '触发成功'),
                result=result
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message=result.get('message', '触发失败'),
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"触发失败: {str(e)}",
            result=None
        )
