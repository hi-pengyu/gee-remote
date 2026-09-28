"""
缓存管理相关VO模型
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime


class CacheQueryModel(BaseModel):
    """缓存查询模型"""
    tile_id: Optional[str] = Field(default=None, description="瓦片ID")
    date_acquired: Optional[date] = Field(default=None, description="影像日期")
    status: Optional[str] = Field(default=None, description="状态")
    page_num: int = Field(default=1, description="页码")
    page_size: int = Field(default=10, description="每页数量")


class CacheListModel(BaseModel):
    """缓存列表模型"""
    tile_id: str = Field(description="瓦片ID")
    date_acquired: date = Field(description="影像日期")
    file_size: int = Field(description="文件大小")
    access_count: int = Field(description="访问次数")
    last_access: Optional[datetime] = Field(description="最后访问时间")
    status: str = Field(description="状态")


class CacheStatsModel(BaseModel):
    """缓存统计模型"""
    total_tiles: int = Field(description="总瓦片数")
    active_tiles: int = Field(description="活跃瓦片数")
    expired_tiles: int = Field(description="过期瓦片数")
    total_size_gb: float = Field(description="总大小GB")
    cache_hit_rate: float = Field(description="缓存命中率")


class PrefetchModel(BaseModel):
    """预取模型"""
    tile_id: str = Field(description="中心瓦片ID")
    target_date: date = Field(description="目标日期")
    window_days: int = Field(default=10, description="日期窗口")
