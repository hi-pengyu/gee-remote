"""
行政区数据控制器

提供行政区数据查询API
"""

from fastapi import APIRouter, Query, Request
from typing import Optional
from module_admin.annotation.log_annotation import Log
from config.enums import BusinessType
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.admin_region_service import admin_region_service


# 创建路由
adminRegionController = APIRouter(prefix="/gee/admin-regions", tags=["行政区数据"])


@adminRegionController.get("/list", response_model=CrudResponseModel)
@Log(title="行政区管理", business_type=BusinessType.OTHER, log_type="operation")
async def get_admin_regions_list(
    request: Request,
    level: Optional[str] = Query(None, description="行政区级别(province/city/district)"),
    parentAdcode: Optional[str] = Query(None, description="父级行政区代码"),
    keyword: Optional[str] = Query(None, description="搜索关键词"),
    pageNum: int = Query(1, description="页码"),
    pageSize: int = Query(100, description="每页数量")
):
    """
    获取行政区列表
    
    Args:
        level: 行政区级别
        parentAdcode: 父级行政区代码
        keyword: 搜索关键词
        pageNum: 页码
        pageSize: 每页数量
        
    Returns:
        行政区列表
    """
    result = admin_region_service.get_admin_regions(
        level=level,
        parent_adcode=parentAdcode,
        keyword=keyword,
        page_num=pageNum,
        page_size=pageSize
    )
    
    return CrudResponseModel(
        is_success=True,
        message="查询成功",
        result=result
    )


@adminRegionController.get("/list-with-stats", response_model=CrudResponseModel)
@Log(title="行政区管理", business_type=BusinessType.OTHER, log_type="operation")
async def get_admin_regions_with_stats(
    request: Request,
    level: Optional[str] = Query(None, description="行政区级别(province/city/district)"),
    parentAdcode: Optional[str] = Query(None, description="父级行政区代码（用于级联查询）"),
    pageNum: int = Query(1, description="页码"),
    pageSize: int = Query(100, description="每页数量")
):
    """
    获取行政区列表（包含地块统计）- 支持级联查询
    
    Args:
        level: 行政区级别（可选）
        parentAdcode: 父级行政区代码（用于查询子级，例如查询某省下的所有市）
        pageNum: 页码
        pageSize: 每页数量
        
    Returns:
        行政区列表（含地块统计）
        
    示例：
        - 获取所有省: ?level=province
        - 获取某省下的所有市: ?parentAdcode=110000
        - 获取某市下的所有区县: ?parentAdcode=110100
    """
    result = admin_region_service.get_region_with_plots_count(
        level=level,
        parent_adcode=parentAdcode,
        page_num=pageNum,
        page_size=pageSize
    )
    
    return CrudResponseModel(
        is_success=True,
        message="查询成功",
        result=result
    )


@adminRegionController.get("/{adcode}", response_model=CrudResponseModel)
@Log(title="行政区管理", business_type=BusinessType.OTHER, log_type="operation")
async def get_admin_region_detail(request: Request, adcode: str):
    """
    获取行政区详情
    
    Args:
        adcode: 行政区代码
        
    Returns:
        行政区详情
    """
    result = admin_region_service.get_region_by_adcode(adcode)
    
    if result:
        return CrudResponseModel(
            is_success=True,
            message="查询成功",
            result=result
        )
    else:
        return CrudResponseModel(
            is_success=False,
            message=f"未找到行政区代码为 {adcode} 的数据"
        )


@adminRegionController.get("/search", response_model=CrudResponseModel)
@Log(title="行政区管理", business_type=BusinessType.OTHER, log_type="operation")
async def search_admin_regions(
    request: Request,
    keyword: str = Query(..., description="搜索关键词"),
    limit: int = Query(20, description="返回数量限制")
):
    """
    搜索行政区
    
    Args:
        keyword: 搜索关键词
        limit: 返回数量限制
        
    Returns:
        匹配的行政区列表
    """
    results = admin_region_service.search_regions(keyword, limit)
    
    return CrudResponseModel(
        is_success=True,
        message="搜索成功",
        result=results
    )
