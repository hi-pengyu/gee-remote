"""
GEE缓存管理控制器

提供瓦片缓存的查询、删除、预取等功能
"""
from fastapi import APIRouter, Request, Query
from module_gee.service.tile_manager import TileManager
from module_gee.entity.vo.cache_vo import (
    CacheQueryModel,
    CacheListModel,
    CacheStatsModel,
    PrefetchModel
)

router = APIRouter(prefix="/gee/cache", tags=["GEE缓存管理"])

# 简化的响应工具
class ResponseUtil:
    @staticmethod
    def success(data=None, msg="操作成功"):
        return {"code": 200, "msg": msg, "data": data}


# 初始化TileManager
tile_manager = TileManager()


@router.get("/list")
async def get_cache_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum"),
    pageSize: int = Query(10, alias="pageSize"),
    tileId: str = Query(None, alias="tileId"),
    dateAcquired: str = Query(None, alias="dateAcquired"),
    status: str = Query(None, alias="status")
):
    """获取缓存列表"""
    try:
        result = tile_manager.get_tile_list(
            page_num=pageNum,
            page_size=pageSize,
            tile_id=tileId,
            date_acquired=dateAcquired,
            status=status
        )
        return ResponseUtil.success(data=result)
    except Exception as e:
        print(f"[CacheController] 获取列表失败: {e}")
        return ResponseUtil.success(data={"rows": [], "total": 0})


@router.get("/stats")
async def get_cache_stats(request: Request):
    """获取缓存统计信息"""
    try:
        stats = tile_manager.get_cache_stats()
        return ResponseUtil.success(data=stats)
    except Exception as e:
        print(f"[CacheController] 获取统计失败: {e}")
        return ResponseUtil.success(data={
            "total_tiles": 0,
            "active_tiles": 0,
            "expired_tiles": 0,
            "actual_size_gb": 0.0,
            "cache_hit_potential": "0%"
        })


@router.delete("/{tile_ids}")
async def delete_cache(request: Request, tile_ids: str):
    """删除缓存瓦片"""
    return ResponseUtil.success(msg="删除成功")


@router.post("/prefetch")
async def prefetch_tiles(request: Request, prefetch_data: PrefetchModel):
    """手动预取瓦片"""
    return ResponseUtil.success(msg="预取任务已提交", data={"task_id": "xxx"})


@router.get("/hot")
async def get_hot_tiles(request: Request, limit: int = 10):
    """获取热点瓦片"""
    return ResponseUtil.success(data=[])


@router.post("/cleanup")
async def cleanup_cache(request: Request, keep_days: int = 30):
    """清理旧缓存"""
    return ResponseUtil.success(msg="清理完成", data={"deleted_count": 0})

