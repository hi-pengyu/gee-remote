"""
GEE统计分析控制器

提供缓存统计、任务统计、性能分析等功能
"""
from fastapi import APIRouter, Request, Query
from module_gee.service.tile_manager import TileManager
from module_gee.service.task_service import TaskService

router = APIRouter(prefix="/gee/stats", tags=["GEE统计分析"])

# 简化的响应工具
class ResponseUtil:
    @staticmethod
    def success(data=None, msg="操作成功"):
        return {"code": 200, "msg": msg, "data": data}


# 初始化服务
tile_manager = TileManager()
task_service = TaskService()


@router.get("/dashboard")
async def get_dashboard_data(request: Request):
    """获取仪表盘数据"""
    try:
        cache_stats = tile_manager.get_cache_stats()
        task_stats = task_service.get_task_stats()
        
        data = {
            "cache_stats": cache_stats,
            "task_stats": task_stats,
            "charts": {
                "task_trend": [],  # 任务趋势数据
                "cache_growth": []  # 缓存增长数据
            }
        }
        return ResponseUtil.success(data=data)
    except Exception as e:
        print(f"[StatsController] 获取仪表盘数据失败: {e}")
        return ResponseUtil.success(data={
            "cache_stats": {},
            "task_stats": {},
            "charts": {}
        })


@router.get("/trend")
async def get_trend_data(request: Request, days: int = Query(7, alias="days")):
    """获取趋势数据"""
    # TODO: 实现趋势数据查询
    return ResponseUtil.success(data=[])


@router.get("/performance")
async def get_performance_data(request: Request):
    """获取性能数据"""
    try:
        cache_stats = tile_manager.get_cache_stats()
        task_stats = task_service.get_task_stats()
        
        data = {
            "cache_performance": {
                "total_size_gb": cache_stats.get('actual_size_gb', 0),
                "hit_rate": cache_stats.get('cache_hit_potential', '0%')
            },
            "task_performance": {
                "success_rate": task_stats.get('success_rate', '0%'),
                "total_tasks": task_stats.get('total_tasks', 0)
            }
        }
        return ResponseUtil.success(data=data)
    except Exception as e:
        print(f"[StatsController] 获取性能数据失败: {e}")
        return ResponseUtil.success(data={})

