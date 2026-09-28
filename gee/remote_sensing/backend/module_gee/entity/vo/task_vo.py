"""
任务管理相关VO模型
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime


class TaskQueryModel(BaseModel):
    """任务查询模型"""
    task_type: Optional[str] = Field(default=None, description="任务类型")
    status: Optional[str] = Field(default=None, description="状态")
    target_date: Optional[date] = Field(default=None, description="目标日期")
    page_num: int = Field(default=1, description="页码")
    page_size: int = Field(default=10, description="每页数量")


class TaskCreateModel(BaseModel):
    """任务创建模型"""
    task_name: Optional[str] = Field(default=None, description="任务名称")
    target_date: date = Field(description="目标日期")
    model_type: str = Field(default="all", description="模型类型")
    aoi_coords: Optional[List[List[float]]] = Field(default=None, description="AOI坐标 (如果提供了plot_id，则此项可选)")
    window_days: int = Field(default=10, description="日期窗口")
    app_key: Optional[str] = Field(default=None, description="应用API Key")
    plot_id: Optional[int] = Field(default=None, description="地块ID")


class TaskDetailModel(BaseModel):
    """任务详情模型"""
    task_id: str = Field(description="任务ID")
    task_name: Optional[str] = Field(description="任务名称")
    task_type: str = Field(description="任务类型")
    status: str = Field(description="状态")
    progress: int = Field(description="进度")
    cache_hit_rate: Optional[float] = Field(description="缓存命中率")
    start_time: Optional[datetime] = Field(description="开始时间")
    end_time: Optional[datetime] = Field(description="结束时间")
    duration: Optional[int] = Field(description="耗时秒数")
