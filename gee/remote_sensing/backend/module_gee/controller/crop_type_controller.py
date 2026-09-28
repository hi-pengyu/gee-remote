"""
作物类型控制器

提供作物类型字典查询API
"""

from fastapi import APIRouter, Query, Request
from typing import Optional
from config.enums import BusinessType
from module_admin.annotation.log_annotation import Log
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.crop_type_service import crop_type_service


# 创建路由
cropTypeController = APIRouter(prefix="/gee/crop-types", tags=["作物类型"])


@cropTypeController.get("/list", response_model=CrudResponseModel)
@Log(title="作物类型", business_type=BusinessType.OTHER, log_type="operation")
async def get_crop_types_list(
    request: Request,
    status: Optional[str] = Query('0', description="状态(0=正常 1=停用 None=全部)")
):
    """
    获取作物类型列表
    
    Args:
        status: 状态筛选
        
    Returns:
        作物类型列表
    """
    try:
        result = crop_type_service.get_all_crop_types(status=status)
        
        return CrudResponseModel(
            is_success=True,
            message="查询成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}"
        )


@cropTypeController.get("/{cropCode}", response_model=CrudResponseModel)
@Log(title="作物类型", business_type=BusinessType.OTHER, log_type="operation")
async def get_crop_type_detail(request: Request, cropCode: str):
    """
    获取作物类型详情
    
    Args:
        cropCode: 作物代码
        
    Returns:
        作物类型详情
    """
    try:
        result = crop_type_service.get_crop_type_by_code(cropCode)
        
        if result:
            return CrudResponseModel(
                is_success=True,
                message="查询成功",
                result=result
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message=f"未找到作物代码为 {cropCode} 的数据"
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}"
        )
