from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import date


class OptimizationResultCreate(BaseModel):
    """创建优化结果请求"""
    calculation_date: date = Field(..., description="计算日期")
    buffer_km: float = Field(5.0, description="缓冲区大小(km)")
    include_custom_regions: bool = Field(True, description="是否包含自定义区域")
    

class OptimizationResultQuery(BaseModel):
    """查询优化结果请求"""
    start_date: Optional[date] = Field(None, description="开始日期")
    end_date: Optional[date] = Field(None, description="结束日期")
    status: Optional[str] = Field(None, description="状态")
    page_num: int = Field(1, description="页码")
    page_size: int = Field(10, description="每页数量")


class OptimizationResultVO(BaseModel):
    """优化结果响应"""
    id: int
    calculation_date: date
    buffer_km: float
    include_custom_regions: bool
    total_regions: int
    original_plot_count: Optional[int] = 0
    optimized_region_count: Optional[int] = 0
    custom_region_count: Optional[int] = 0
    optimization_rate: Optional[float] = 0
    regions_data: Optional[List[Dict[str, Any]]] = None
    status: str
    created_at: str
    created_by: Optional[str] = None
    remark: Optional[str] = None
    
    class Config:
        from_attributes = True
