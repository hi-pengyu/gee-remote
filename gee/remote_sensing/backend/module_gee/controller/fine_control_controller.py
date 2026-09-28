"""
精细化管控控制器

提供精细化管控策略的CRUD操作API
"""

from fastapi import APIRouter, Query, Body, Request
from typing import Optional, List
from module_admin.annotation.log_annotation import Log
from config.enums import BusinessType
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.fine_control_service import fine_control_service


# 创建路由
fineControlController = APIRouter(prefix="/gee/fine-control", tags=["精细化管控"])


@fineControlController.post("/policies", response_model=CrudResponseModel)
@Log(title="精细化管控", business_type=BusinessType.INSERT, log_type="operation")
async def create_control_policy(
    request: Request,
    policyName: str = Body(..., description="策略名称"),
    policyType: str = Body(..., description="策略类型(admin_region/custom_region/single_plot)"),
    controlAction: str = Body(..., description="控制动作(pause/resume)"),
    adcode: Optional[str] = Body(None, description="行政区代码"),
    customGeometry: Optional[str] = Body(None, description="自定义区域几何"),
    plotId: Optional[int] = Body(None, description="地块ID"),
    cropCodes: Optional[List[str]] = Body(None, description="作物代码列表"),
    reason: Optional[str] = Body(None, description="原因"),
    priority: int = Body(0, description="优先级"),
    createdBy: Optional[str] = Body(None, description="创建人")
):
    """
    创建管控策略
    
    Args:
        policyName: 策略名称
        policyType: 策略类型
        controlAction: 控制动作
        adcode: 行政区代码
        customGeometry: 自定义区域几何
        plotId: 地块ID
        cropCodes: 作物代码列表
        reason: 原因
        priority: 优先级
        createdBy: 创建人
        
    Returns:
        创建结果
    """
    try:
        result = fine_control_service.create_control_policy(
            policy_name=policyName,
            policy_type=policyType,
            control_action=controlAction,
            adcode=adcode,
            custom_geometry=customGeometry,
            plot_id=plotId,
            crop_codes=cropCodes,
            reason=reason,
            priority=priority,
            created_by=createdBy
        )
        
        return CrudResponseModel(
            is_success=True,
            message="策略创建成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"策略创建失败: {str(e)}"
        )


@fineControlController.post("/preview", response_model=CrudResponseModel)
@Log(title="精细化管控", business_type=BusinessType.OTHER, log_type="operation")
async def preview_impact(
    request: Request,
    policyType: str = Body(..., description="策略类型"),
    adcode: Optional[str] = Body(None, description="行政区代码"),
    customGeometry: Optional[str] = Body(None, description="自定义区域几何"),
    plotId: Optional[int] = Body(None, description="地块ID"),
    cropCodes: Optional[List[str]] = Body(None, description="作物代码列表")
):
    """
    预览管控影响范围
    
    Args:
        policyType: 策略类型
        adcode: 行政区代码
        customGeometry: 自定义区域几何
        plotId: 地块ID
        cropCodes: 作物代码列表
        
    Returns:
        影响统计
    """
    try:
        result = fine_control_service.preview_impact(
            policy_type=policyType,
            adcode=adcode,
            custom_geometry=customGeometry,
            plot_id=plotId,
            crop_codes=cropCodes
        )
        
        return CrudResponseModel(
            is_success=True,
            message="预览成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"预览失败: {str(e)}"
        )


@fineControlController.get("/policies", response_model=CrudResponseModel)
@Log(title="精细化管控", business_type=BusinessType.OTHER, log_type="operation")
async def get_policies_list(
    request: Request,
    policyType: Optional[str] = Query(None, description="策略类型"),
    isActive: Optional[bool] = Query(None, description="是否启用"),
    pageNum: int = Query(1, description="页码"),
    pageSize: int = Query(20, description="每页数量")
):
    """
    获取策略列表
    
    Args:
        policyType: 策略类型筛选
        isActive: 是否启用筛选
        pageNum: 页码
        pageSize: 每页数量
        
    Returns:
        策略列表
    """
    try:
        result = fine_control_service.get_active_policies(
            policy_type=policyType,
            is_active=isActive,
            page_num=pageNum,
            page_size=pageSize
        )
        
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


@fineControlController.delete("/policies/{policyId}", response_model=CrudResponseModel)
@Log(title="精细化管控", business_type=BusinessType.DELETE, log_type="operation")
async def delete_policy(request: Request, policyId: int):
    """
    删除策略
    
    Args:
        policyId: 策略ID
        
    Returns:
        删除结果
    """
    try:
        success = fine_control_service.delete_policy(policyId)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="策略删除成功"
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="策略不存在或已删除"
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"删除失败: {str(e)}"
        )


@fineControlController.put("/policies/{policyId}/toggle", response_model=CrudResponseModel)
@Log(title="精细化管控", business_type=BusinessType.UPDATE, log_type="operation")
async def toggle_policy(
    request: Request,
    policyId: int,
    isActive: bool = Body(..., embed=True, description="是否启用")
):
    """
    启用/禁用策略
    
    Args:
        policyId: 策略ID
        isActive: 是否启用
        
    Returns:
        操作结果
    """
    try:
        success = fine_control_service.toggle_policy(policyId, isActive)
        
        if success:
            action = "启用" if isActive else "禁用"
            return CrudResponseModel(
                is_success=True,
                message=f"策略已{action}"
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="策略不存在"
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"操作失败: {str(e)}"
        )


@fineControlController.get("/plots/{plotId}/status", response_model=CrudResponseModel)
@Log(title="精细化管控", business_type=BusinessType.OTHER, log_type="operation")
async def get_plot_control_status(request: Request, plotId: int):
    """
    获取地块的管控状态
    
    Args:
        plotId: 地块ID
        
    Returns:
        地块管控状态
    """
    try:
        result = fine_control_service.get_plot_control_status(plotId)
        
        if result:
            return CrudResponseModel(
                is_success=True,
                message="查询成功",
                result=result
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="地块不存在"
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}"
        )
