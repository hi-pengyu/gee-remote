"""GEE应用管理控制器"""
from fastapi import APIRouter, Query, Request, Body
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.app_service import GeeAppService
from typing import Optional

# 创建路由
router = APIRouter(prefix="/gee/app", tags=["GEE应用管理"])

# 初始化服务
app_service = GeeAppService()


@router.get("/list", response_model=CrudResponseModel)
async def get_app_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum", description="页码"),
    pageSize: int = Query(10, alias="pageSize", description="每页数量"),
    appName: Optional[str] = Query(None, alias="appName", description="应用名称")
):
    """获取应用列表"""
    try:
        result = app_service.get_app_list(
            page_num=pageNum,
            page_size=pageSize,
            app_name=appName
        )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/{app_id}", response_model=CrudResponseModel)
async def get_app_detail(request: Request, app_id: int):
    """获取应用详情"""
    try:
        detail = app_service.get_app_by_id(app_id)
        
        if not detail:
            return CrudResponseModel(
                is_success=False,
                message="应用不存在",
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


@router.post("/", response_model=CrudResponseModel)
async def create_app(
    request: Request,
    appName: str = Body(..., embed=True, alias="appName"),
    description: Optional[str] = Body(None, embed=True),
    callbackUrl: Optional[str] = Body(None, embed=True, alias="callbackUrl"),
    enableDailyUpdate: bool = Body(False, embed=True, alias="enableDailyUpdate")
):
    """创建应用"""
    try:
        success = app_service.create_app(appName, description, callbackUrl, enableDailyUpdate)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="创建成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="创建失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"创建失败: {str(e)}",
            result=None
        )


@router.put("/{app_id}", response_model=CrudResponseModel)
async def update_app(
    request: Request,
    app_id: int,
    appName: str = Body(..., embed=True, alias="appName"),
    description: Optional[str] = Body(None, embed=True),
    isEnabled: bool = Body(True, embed=True, alias="isEnabled"),
    callbackUrl: Optional[str] = Body(None, embed=True, alias="callbackUrl"),
    enableDailyUpdate: bool = Body(False, embed=True, alias="enableDailyUpdate")
):
    """更新应用"""
    try:
        success = app_service.update_app(app_id, appName, description, isEnabled, callbackUrl, enableDailyUpdate)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="更新成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="更新失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"更新失败: {str(e)}",
            result=None
        )


@router.delete("/{app_id}", response_model=CrudResponseModel)
async def delete_app(request: Request, app_id: int):
    """删除应用"""
    try:
        success = app_service.delete_app(app_id)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="删除成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="删除失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"删除失败: {str(e)}",
            result=None
        )


@router.post("/{app_id}/regenerate-key", response_model=CrudResponseModel)
async def regenerate_api_key(request: Request, app_id: int):
    """重新生成API Key"""
    try:
        new_key = app_service.regenerate_api_key(app_id)
        
        if new_key:
            return CrudResponseModel(
                is_success=True,
                message="API Key重置成功",
                result={"appKey": new_key}
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="API Key重置失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"操作失败: {str(e)}",
            result=None
        )


@router.get("/callback", response_model=CrudResponseModel)
async def get_callback_by_key(
    request: Request,
    appKey: str = Query(..., alias="appKey", description="应用Key")
):
    """根据API Key查询回调地址"""
    try:
        result = app_service.get_callback_by_key(appKey)
        
        if not result:
            return CrudResponseModel(
                is_success=False,
                message="应用不存在",
                result=None
            )
        
        if 'error' in result:
            return CrudResponseModel(
                is_success=False,
                message=result['error'],
                result=None
            )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )
