"""GEE账号池控制器"""
from fastapi import APIRouter, Query, Request, Body
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.account_service import AccountService
from typing import Optional

router = APIRouter(prefix="/gee/accounts", tags=["GEE账号池"])
account_service = AccountService()


@router.get("", response_model=CrudResponseModel)
async def get_account_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum"),
    pageSize: int = Query(10, alias="pageSize"),
    accountName: Optional[str] = Query(None, alias="accountName"),
    isActive: Optional[bool] = Query(None, alias="isActive")
):
    """获取账号列表"""
    try:
        result = account_service.get_account_list(
            page_num=pageNum,
            page_size=pageSize,
            account_name=accountName,
            is_active=isActive
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


@router.get("/stats", response_model=CrudResponseModel)
async def get_account_stats(request: Request):
    """获取账号统计信息"""
    try:
        stats = account_service.get_account_stats()
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result={'stats': stats}
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/{account_id}", response_model=CrudResponseModel)
async def get_account_detail(request: Request, account_id: int):
    """获取账号详情"""
    try:
        detail = account_service.get_account_by_id(account_id)
        
        if not detail:
            return CrudResponseModel(
                is_success=False,
                message="账号不存在",
                result=None
            )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result={'data': detail}
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.post("", response_model=CrudResponseModel)
async def create_account(
    request: Request,
    account_name: str = Body(..., alias="account_name"),
    project_id: str = Body(..., alias="project_id"),
    credentials_json: str = Body(..., alias="credentials_json"),
    drive_token_json: Optional[str] = Body(None, alias="drive_token_json"),
    drive_folder_id: Optional[str] = Body(None, alias="drive_folder_id"),
    priority: int = Body(0),
    description: Optional[str] = Body(None)
):
    """创建账号"""
    try:
        success = account_service.create_account(
            account_name=account_name,
            project_id=project_id,
            credentials_json=credentials_json,
            drive_token_json=drive_token_json,
            drive_folder_id=drive_folder_id,
            priority=priority,
            description=description
        )
        
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


@router.put("/{account_id}", response_model=CrudResponseModel)
async def update_account(
    request: Request,
    account_id: int,
    account_name: str = Body(..., alias="account_name"),
    project_id: str = Body(..., alias="project_id"),
    credentials_json: Optional[str] = Body(None, alias="credentials_json"),
    drive_token_json: Optional[str] = Body(None, alias="drive_token_json"),
    drive_folder_id: Optional[str] = Body(None, alias="drive_folder_id"),
    priority: int = Body(0),
    is_active: bool = Body(True, alias="is_active"),
    description: Optional[str] = Body(None)
):
    """更新账号"""
    try:
        success = account_service.update_account(
            account_id=account_id,
            account_name=account_name,
            project_id=project_id,
            credentials_json=credentials_json,
            drive_token_json=drive_token_json,
            drive_folder_id=drive_folder_id,
            priority=priority,
            is_active=is_active,
            description=description
        )
        
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


@router.delete("/{account_id}", response_model=CrudResponseModel)
async def delete_account(request: Request, account_id: int):
    """删除账号"""
    try:
        success = account_service.delete_account(account_id)
        
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


@router.post("/{account_id}/mark-healthy", response_model=CrudResponseModel)
async def mark_account_healthy(request: Request, account_id: int):
    """标记账号为健康状态"""
    try:
        success = account_service.mark_account_healthy(account_id)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="标记成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="标记失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"标记失败: {str(e)}",
            result=None
        )
