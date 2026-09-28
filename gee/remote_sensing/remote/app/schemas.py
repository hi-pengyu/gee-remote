"""API 请求和响应模型"""
from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


class TaskStatusEnum(str, Enum):
    """任务状态枚举"""
    PENDING = "pending"
    STARTED = "started"
    DOWNLOADING_IMAGE = "downloading_image"
    PROCESSING_DATA = "processing_data"
    PREDICTING = "predicting"
    SUCCESS = "success"
    FAILURE = "failure"


class CoordinateInput(BaseModel):
    """坐标输入模型"""
    lon: float = Field(..., description="经度", ge=-180, le=180)
    lat: float = Field(..., description="纬度", ge=-90, le=90)
    
    class Config:
        json_schema_extra = {
            "example": {
                "lon": 86.0388457571117,
                "lat": 44.552453045732314
            }
        }


class GEEDownloadRequest(BaseModel):
    """GEE 遥感图下载请求"""
    aoi_coords: List[List[float]] = Field(
        ...,
        description="AOI 区域坐标列表，格式: [[lon, lat], [lon, lat], ...]",
        min_length=3
    )
    target_date: str = Field(
        ...,
        description="目标日期，格式: YYYY-MM-DD",
        pattern=r"^\d{4}-\d{2}-\d{2}$"
    )
    window_days: Optional[int] = Field(
        default=2,
        description="目标日期前后搜索天数",
        ge=0,
        le=30
    )
    file_name: Optional[str] = Field(
        default=None,
        description="自定义文件名（不含扩展名）"
    )
    scale: Optional[int] = Field(
        default=10,
        description="导出分辨率（米）",
        ge=10,
        le=100
    )
    
    @validator('aoi_coords')
    def validate_coords(cls, v):
        """验证坐标格式"""
        for coord in v:
            if len(coord) != 2:
                raise ValueError("每个坐标必须是 [经度, 纬度] 格式")
            lon, lat = coord
            if not (-180 <= lon <= 180):
                raise ValueError(f"经度必须在 -180 到 180 之间: {lon}")
            if not (-90 <= lat <= 90):
                raise ValueError(f"纬度必须在 -90 到 90 之间: {lat}")
        
        # 检查是否闭合
        if v[0] != v[-1]:
            raise ValueError("AOI 坐标必须首尾相同（闭合多边形）")
        
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "aoi_coords": [
                    [86.0388457571117, 44.552453045732314],
                    [86.0405231637295, 44.5488551561015],
                    [86.041776483188, 44.54909929116849],
                    [86.0388457571117, 44.552453045732314]
                ],
                "target_date": "2025-09-21",
                "window_days": 2,
                "file_name": "my_custom_image"
            }
        }


class GEEDateRequest(BaseModel):
    """GEE 日期查询请求"""
    aoi_coords: List[List[float]] = Field(
        ...,
        description="AOI 区域坐标列表，格式: [[lon, lat], [lon, lat], ...]",
        min_length=3
    )
    start_date: Optional[str] = Field(
        default=None,
        description="开始日期，格式: YYYY-MM-DD (默认: 当年1月1日)",
        pattern=r"^\d{4}-\d{2}-\d{2}$"
    )
    end_date: Optional[str] = Field(
        default=None,
        description="结束日期，格式: YYYY-MM-DD (默认: 当年12月31日)",
        pattern=r"^\d{4}-\d{2}-\d{2}$"
    )
    cloud_cover_threshold: float = Field(
        default=20.0,
        description="云量阈值 (0-100)",
        ge=0,
        le=100
    )
    predict_future: bool = Field(
        default=False,
        description="是否预测未来日期 (基于5天重访周期)"
    )
    
    @validator('aoi_coords')
    def validate_coords(cls, v):
        """验证坐标格式"""
        for coord in v:
            if len(coord) != 2:
                raise ValueError("每个坐标必须是 [经度, 纬度] 格式")
            lon, lat = coord
            if not (-180 <= lon <= 180):
                raise ValueError(f"经度必须在 -180 到 180 之间: {lon}")
            if not (-90 <= lat <= 90):
                raise ValueError(f"纬度必须在 -90 到 90 之间: {lat}")
        
        # 检查是否闭合
        if v[0] != v[-1]:
            raise ValueError("AOI 坐标必须首尾相同（闭合多边形）")
        
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "aoi_coords": [
                    [86.0388457571117, 44.552453045732314],
                    [86.0405231637295, 44.5488551561015],
                    [86.041776483188, 44.54909929116849],
                    [86.0388457571117, 44.552453045732314]
                ],
                "start_date": "2025-01-01",
                "end_date": "2025-12-31",
                "cloud_cover_threshold": 20.0
            }
        }


class WorkflowRequest(BaseModel):
    """完整工作流请求（下载 + 处理 + 预测）"""
    target_date: str = Field(
        ...,
        description="目标日期，格式: YYYY-MM-DD",
        pattern=r"^\d{4}-\d{2}-\d{2}$"
    )
    model_type: str = Field(
        ...,
        description="预测模型类型 (zg, agb, hsl, spad, n, p, k) 或 'all' (运行所有模型)"
    )
    aoi_coords: Optional[List[List[float]]] = Field(
        default=None,
        description="AOI 区域坐标列表 (如果提供了plot_id，则此项可选)",
        min_length=3
    )
    plot_id: Optional[int] = Field(
        default=None,
        description="地块ID (如果提供了aoi_coords，则此项可选)"
    )
    plot_name: Optional[str] = Field(
        default=None,
        description="地块名称（可选，如果提供则自动创建/关联地块，需同时提供aoi_coords）",
        max_length=100
    )
    window_days: Optional[int] = Field(default=2, ge=0, le=30)
    file_name: Optional[str] = None
    scale: Optional[int] = Field(default=10, ge=10, le=100)
    callback_url: Optional[str] = Field(
        default=None,
        description="任务完成后的回调URL（可选）",
        max_length=500
    )

    @validator('aoi_coords')
    def validate_coords(cls, v, values):
        """验证坐标"""
        if v is None:
            return v
            
        for coord in v:
            if len(coord) != 2:
                raise ValueError("每个坐标必须是 [经度, 纬度] 格式")
        if v[0] != v[-1]:
            raise ValueError("AOI 坐标必须首尾相同（闭合多边形）")
        return v
        
    @validator('plot_id')
    def validate_plot_or_aoi(cls, v, values):
        """验证 plot_id 或 aoi_coords 至少存在一个"""
        if v is None and values.get('aoi_coords') is None:
            raise ValueError("必须提供 aoi_coords 或 plot_id 其中之一")
        return v
    
    @validator('plot_name')
    def validate_plot_name(cls, v, values):
        """验证 plot_name 必须与 aoi_coords 一起提供"""
        if v is not None and values.get('aoi_coords') is None:
            raise ValueError("提供 plot_name 时必须同时提供 aoi_coords")
        return v

    @validator('model_type')
    def validate_model_type(cls, v):
        """验证模型类型"""
        from app.config import settings

        # 允许 'all' 表示运行所有模型
        if v.lower() == 'all':
            return v.lower()

        # 验证单个模型类型
        available_models = settings.AVAILABLE_MODELS
        if v.lower() not in available_models:
            raise ValueError(
                f"不支持的模型类型: {v}。可用模型: {', '.join(available_models)} 或 'all'"
            )
        return v.lower()

    class Config:
        json_schema_extra = {
            "example": {
                "aoi_coords": [
                    [86.0388457571117, 44.552453045732314],
                    [86.0405231637295, 44.5488551561015],
                    [86.041776483188, 44.54909929116849],
                    [86.0388457571117, 44.552453045732314]
                ],
                "target_date": "2025-09-21",
                "model_type": "agb",
                "window_days": 2
            }
        }


class TaskResponse(BaseModel):
    """任务提交响应"""
    task_id: str = Field(..., description="任务唯一标识")
    status: str = Field(..., description="任务状态")
    message: str = Field(..., description="提示信息")
    created_at: datetime = Field(..., description="创建时间")
    
    class Config:
        json_schema_extra = {
            "example": {
                "task_id": "abc123-def456-ghi789",
                "status": "pending",
                "message": "任务已提交，正在队列中等待处理",
                "created_at": "2025-11-09T12:00:00"
            }
        }


class TaskStatusResponse(BaseModel):
    """任务状态查询响应"""
    task_id: str
    status: str
    progress: int = Field(..., description="进度百分比 (0-100)", ge=0, le=100)
    current_step: Optional[str] = None
    created_at: Optional[datetime] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    error_message: Optional[str] = None
    result: Optional[Dict[str, Any]] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "task_id": "abc123",
                "status": "downloading_image",
                "progress": 30,
                "current_step": "正在从 GEE 导出遥感图像...",
                "created_at": "2025-11-09T12:00:00",
                "started_at": "2025-11-09T12:00:05"
            }
        }


class FileInfo(BaseModel):
    """文件信息"""
    file_id: str
    file_name: str
    file_path: str
    file_type: str  # tif, csv, json
    file_size: int  # bytes
    created_at: datetime


class HealthResponse(BaseModel):
    """健康检查响应"""
    status: str
    version: str
    redis_connected: bool
    celery_workers: int
    storage_available: bool


