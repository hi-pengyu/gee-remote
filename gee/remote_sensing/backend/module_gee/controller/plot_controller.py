"""GEE地块管理控制器"""
from fastapi import APIRouter, Query, Request, Body
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.plot_service import GeePlotService
from typing import Optional

# 创建路由
router = APIRouter(prefix="/gee/plot", tags=["GEE地块管理"])

# 初始化服务
plot_service = GeePlotService()


@router.get("/list", response_model=CrudResponseModel)
async def get_plot_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum", description="页码"),
    pageSize: int = Query(10, alias="pageSize", description="每页数量"),
    plotName: Optional[str] = Query(None, alias="plotName", description="地块名称"),
    appId: Optional[int] = Query(None, alias="appId", description="应用ID")
):
    """获取地块列表"""
    try:
        result = plot_service.get_plot_list(
            page_num=pageNum,
            page_size=pageSize,
            plot_name=plotName,
            app_id=appId
        )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/{plot_id}", response_model=CrudResponseModel)
async def get_plot_detail(request: Request, plot_id: int):
    """获取地块详情"""
    try:
        detail = plot_service.get_plot_by_id(plot_id)
        
        if not detail:
            return CrudResponseModel(
                is_success=False,
                message="地块不存在",
                result=None
            )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=detail
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.post("/", response_model=CrudResponseModel)
async def create_plot(
    request: Request,
    appId: int = Body(..., embed=True, alias="appId"),
    plotName: str = Body(..., embed=True, alias="plotName"),
    geometry: str = Body(..., embed=True),
    description: Optional[str] = Body(None, embed=True),
    cropType: Optional[str] = Body(None, embed=True, alias="cropType"),
    adcode: Optional[str] = Body(None, embed=True)
):
    """
    创建地块（支持自动识别行政区）
    
    参数：
    - appId: 应用ID
    - plotName: 地块名称
    - geometry: GeoJSON几何信息
    - description: 描述
    - cropType: 作物类型（可选，如：corn, rice, wheat）
    - adcode: 行政区代码（可选，如不提供则自动识别）
    """
    try:
        plot_id = plot_service.create_plot(
            app_id=appId,
            plot_name=plotName,
            geometry=geometry,
            description=description,
            crop_type=cropType,
            adcode=adcode
        )
        
        if plot_id:
            return CrudResponseModel(
                is_success=True,
                message="创建成功",
                result={'plotId': plot_id}
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="创建失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"创建失败: {str(e)}",
            result=None
        )



@router.put("/{plot_id}", response_model=CrudResponseModel)
async def update_plot(
    request: Request,
    plot_id: int,
    plotName: str = Body(..., embed=True, alias="plotName"),
    geometry: str = Body(..., embed=True),
    description: Optional[str] = Body(None, embed=True)
):
    """更新地块"""
    try:
        success = plot_service.update_plot(plot_id, plotName, geometry, description)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="更新成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="更新失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"更新失败: {str(e)}",
            result=None
        )


@router.delete("/{plot_id}", response_model=CrudResponseModel)
async def delete_plot(request: Request, plot_id: int):
    """删除地块"""
    try:
        success = plot_service.delete_plot(plot_id)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="删除成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="删除失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"删除失败: {str(e)}",
            result=None
        )


@router.get("/{plot_id}/tasks", response_model=CrudResponseModel)
async def get_plot_tasks(request: Request, plot_id: int):
    """获取地块关联的任务列表"""
    try:
        result = plot_service.get_plot_tasks(plot_id)
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/{plot_id}/dates", response_model=CrudResponseModel)
async def get_plot_dates(
    request: Request,
    plot_id: int,
    startDate: Optional[str] = Query(None, alias="startDate"),
    endDate: Optional[str] = Query(None, alias="endDate")
):
    """获取地块可用的遥感日期"""
    try:
        result = plot_service.get_plot_dates(
            plot_id=plot_id,
            start_date=startDate,
            end_date=endDate
        )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=result
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.put("/{plot_id}/toggle", response_model=CrudResponseModel)
async def toggle_monitor_status(
    request: Request,
    plot_id: int,
    monitorStatus: int = Body(..., embed=True, alias="monitorStatus")
):
    """
    切换地块监测状态
    
    参数：
    - monitorStatus: 监测状态 (1=开启, 0=关闭)
    """
    try:
        operator = request.state.user.get('user_name', 'admin') if hasattr(request.state, 'user') else 'admin'
        success = plot_service.toggle_monitor_status(plot_id, monitorStatus, operator)
        
        if success:
            status_text = "开启" if monitorStatus == 1 else "关闭"
            return CrudResponseModel(
                is_success=True,
                message=f"地块监测已{status_text}",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="操作失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"操作失败: {str(e)}",
            result=None
        )
