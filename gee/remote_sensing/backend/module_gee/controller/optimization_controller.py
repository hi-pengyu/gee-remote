"""瓦片下载优化控制器"""
from fastapi import APIRouter, Query, Request, Body
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.optimization_service import TileOptimizationService
from module_gee.service.optimization_result_service import optimization_result_service
from module_admin.annotation.log_annotation import Log
from config.enums import BusinessType
from typing import Optional
from datetime import date
import requests

router = APIRouter(prefix="/gee/optimization", tags=["GEE瓦片优化"])
optimization_service = TileOptimizationService()



@router.post("/calculate", response_model=CrudResponseModel)
async def calculate_optimized_regions(
    request: Request,
    bufferKm: float = Body(5.0, alias="bufferKm"),
    appId: Optional[int] = Body(None, alias="appId"),
    includeCustomRegions: bool = Body(True, alias="includeCustomRegions")
):
    """计算优化后的下载区域（不触发下载）"""
    try:
        regions = optimization_service.calculate_optimized_regions(
            buffer_km=bufferKm,
            app_id=appId,
            include_custom_regions=includeCustomRegions
        )
        
        return CrudResponseModel(
            is_success=True,
            message=f"计算完成，优化后共 {len(regions)} 个区域",
            result={
                'regions': regions,
                'totalRegions': len(regions),
                'bufferKm': bufferKm,
                'includeCustomRegions': includeCustomRegions
            }
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"计算失败: {str(e)}",
            result=None
        )


@router.post("/trigger", response_model=CrudResponseModel)
async def trigger_batch_download(
    request: Request,
    bufferKm: float = Body(5.0, alias="bufferKm"),
    targetDate: str = Body(..., alias="targetDate"),
    modelType: str = Body("all", alias="modelType"),
    windowDays: int = Body(7, alias="windowDays"),
    appId: Optional[int] = Body(None, alias="appId"),
    includeCustomRegions: bool = Body(True, alias="includeCustomRegions"),
    remoteUrl: str = Body("http://localhost:8001", alias="remoteUrl")
):
    """触发批量下载任务"""
    try:
        # 1. 计算优化区域
        regions = optimization_service.calculate_optimized_regions(
            buffer_km=bufferKm,
            app_id=appId,
            include_custom_regions=includeCustomRegions
        )
        
        if not regions:
            return CrudResponseModel(
                is_success=False,
                message="没有可下载的区域",
                result=None
            )
        
        # 2. 调用 Remote 服务的 API 提交任务
        submitted_tasks = []
        failed_tasks = []
        
        for region in regions:
            try:
                response = requests.post(
                    f"{remoteUrl}/api/submit",
                    json={
                        "aoi_coords": region['aoi_coords'],
                        "target_date": targetDate,
                        "model_type": modelType,
                        "window_days": windowDays,
                        "file_name": f"optimized_region_{region['region_id']}_{targetDate}"
                    },
                    timeout=30
                )
                
                if response.status_code == 200:
                    result = response.json()
                    submitted_tasks.append({
                        'regionId': region['region_id'],
                        'taskId': result.get('task_id'),
                        'status': 'submitted',
                        'bounds': region['bounds']
                    })
                else:
                    failed_tasks.append({
                        'regionId': region['region_id'],
                        'error': f"HTTP {response.status_code}",
                        'bounds': region['bounds']
                    })
            except Exception as e:
                failed_tasks.append({
                    'regionId': region['region_id'],
                    'error': str(e),
                    'bounds': region['bounds']
                })
        
        return CrudResponseModel(
            is_success=True,
            message=f"已提交 {len(submitted_tasks)} 个任务，失败 {len(failed_tasks)} 个",
            result={
                'totalRegions': len(regions),
                'submitted': submitted_tasks,
                'failed': failed_tasks,
                'targetDate': targetDate,
                'modelType': modelType
            }
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"触发失败: {str(e)}",
            result=None
        )


@router.post("/calculate-and-save", response_model=CrudResponseModel)
async def calculate_and_save_optimization(
    request: Request,
    calculationDate: str = Body(..., alias="calculationDate"),
    bufferKm: float = Body(5.0, alias="bufferKm"),
    appId: Optional[int] = Body(None, alias="appId"),
    includeCustomRegions: bool = Body(True, alias="includeCustomRegions")
):
    """计算并保存优化结果"""
    try:
        # 1. 计算优化区域
        regions = optimization_service.calculate_optimized_regions(
            buffer_km=bufferKm,
            app_id=appId,
            include_custom_regions=includeCustomRegions
        )
        
        # 2. 保存到数据库
        calc_date = date.fromisoformat(calculationDate)
        saved_result = optimization_result_service.save_result(
            calculation_date=calc_date,
            buffer_km=bufferKm,
            include_custom_regions=includeCustomRegions,
            regions=regions,
            created_by=request.state.user.get('user_name') if hasattr(request.state, 'user') else None
        )
        
        return CrudResponseModel(
            is_success=True,
            message=f"计算完成并已保存，共 {len(regions)} 个区域",
            result={
                'id': saved_result['id'],
                'calculation_date': calculationDate,
                'regions': regions,
                'totalRegions': len(regions),
                'bufferKm': bufferKm,
                'includeCustomRegions': includeCustomRegions
            }
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"保存失败: {str(e)}",
            result=None
        )



@router.post("/history", response_model=CrudResponseModel)
async def get_optimization_history(
    request: Request,
    startDate: Optional[str] = Body(None, alias="startDate"),
    endDate: Optional[str] = Body(None, alias="endDate"),
    status: Optional[str] = Body(None, alias="status"),
    pageNum: int = Body(1, alias="pageNum"),
    pageSize: int = Body(10, alias="pageSize")
):
    """获取优化结果历史记录"""
    try:
        records, total = optimization_result_service.get_history(
            start_date=date.fromisoformat(startDate) if startDate else None,
            end_date=date.fromisoformat(endDate) if endDate else None,
            status=status,
            page_num=pageNum,
            page_size=pageSize
        )
        
        # 转换为VO
        rows = [
            {
                'id': r['id'],
                'calculation_date': r['calculation_date'].isoformat(),
                'buffer_km': float(r['buffer_km']),
                'include_custom_regions': r['include_custom_regions'],
                'total_regions': r['total_regions'],
                'optimized_region_count': r['optimized_region_count'],
                'custom_region_count': r['custom_region_count'],
                'optimization_rate': float(r['optimization_rate']) if r['optimization_rate'] else 0,
                'status': r['status'],
                'created_at': r['created_at'].isoformat() if r['created_at'] else None,
                'created_by': r['created_by']
            }
            for r in records
        ]
        
        return CrudResponseModel(
            is_success=True,
            message="查询成功",
            result={'rows': rows, 'total': total}
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/history/{result_id}", response_model=CrudResponseModel)
async def get_optimization_detail(result_id: int):
    """获取优化结果详情"""
    try:
        record = optimization_result_service.get_by_id(result_id)
        if not record:
            return CrudResponseModel(
                is_success=False,
                message="记录不存在",
                result=None
            )
        
        return CrudResponseModel(
            is_success=True,
            message="查询成功",
            result={
                'id': record['id'],
                'calculation_date': record['calculation_date'].isoformat(),
                'buffer_km': float(record['buffer_km']),
                'include_custom_regions': record['include_custom_regions'],
                'total_regions': record['total_regions'],
                'regions_data': record['regions_data'],
                'status': record['status'],
                'created_at': record['created_at'].isoformat() if record['created_at'] else None,
                'created_by': record['created_by'],
                'remark': record['remark']
            }
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )

