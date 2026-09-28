"""自定义预存区域控制器"""
from fastapi import APIRouter, Query, Request, Body
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.custom_region_service import CustomRegionService
from typing import Optional

router = APIRouter(prefix="/gee/custom-region", tags=["GEE自定义区域"])
region_service = CustomRegionService()


@router.get("/list", response_model=CrudResponseModel)
async def get_region_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum"),
    pageSize: int = Query(10, alias="pageSize"),
    regionName: Optional[str] = Query(None, alias="regionName"),
    isActive: Optional[bool] = Query(None, alias="isActive")
):
    """获取自定义区域列表"""
    try:
        result = region_service.get_region_list(
            page_num=pageNum,
            page_size=pageSize,
            region_name=regionName,
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


@router.get("/{region_id}", response_model=CrudResponseModel)
async def get_region_detail(request: Request, region_id: int):
    """获取区域详情"""
    try:
        detail = region_service.get_region_by_id(region_id)
        
        if not detail:
            return CrudResponseModel(
                is_success=False,
                message="区域不存在",
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


@router.post("", response_model=CrudResponseModel)
async def create_region(
    request: Request,
    regionName: str = Body(..., alias="regionName"),
    geometry: str = Body(...),
    bufferKm: float = Body(5.0, alias="bufferKm"),
    priority: int = Body(0),
    description: Optional[str] = Body(None)
):
    """创建自定义区域"""
    try:
        success = region_service.create_region(
            region_name=regionName,
            geometry=geometry,
            buffer_km=bufferKm,
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


@router.put("/{region_id}", response_model=CrudResponseModel)
async def update_region(
    request: Request,
    region_id: int,
    regionName: str = Body(..., alias="regionName"),
    geometry: str = Body(...),
    bufferKm: float = Body(..., alias="bufferKm"),
    priority: int = Body(...),
    description: Optional[str] = Body(None)
):
    """更新区域"""
    try:
        success = region_service.update_region(
            region_id=region_id,
            region_name=regionName,
            geometry=geometry,
            buffer_km=bufferKm,
            priority=priority,
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


@router.delete("/{region_id}", response_model=CrudResponseModel)
async def delete_region(request: Request, region_id: int):
    """删除区域"""
    try:
        success = region_service.delete_region(region_id)
        
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
