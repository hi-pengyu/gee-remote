"""GEE配置管理控制器"""
from fastapi import APIRouter, Query, Request
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_gee.service.config_service import GeeConfigService
from typing import Optional

# 创建路由
router = APIRouter(prefix="/gee/config", tags=["GEE配置管理"])

# 初始化服务
config_service = GeeConfigService()


@router.get("/list", response_model=CrudResponseModel)
async def get_config_list(
    request: Request,
    pageNum: int = Query(1, alias="pageNum", description="页码"),
    pageSize: int = Query(10, alias="pageSize", description="每页数量"),
    configKey: Optional[str] = Query(None, alias="configKey", description="配置键"),
    configGroup: Optional[str] = Query(None, alias="configGroup", description="配置分组")
):
    """获取配置列表"""
    try:
        result = config_service.get_config_list(
            page_num=pageNum,
            page_size=pageSize,
            config_key=configKey,
            config_group=configGroup
        )
        
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result={
                'rows': result['rows'],
                'total': result['total']
            }
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/groups", response_model=CrudResponseModel)
async def get_config_groups(request: Request):
    """获取配置分组列表"""
    try:
        groups = config_service.get_groups()
        return CrudResponseModel(
            is_success=True,
            message="操作成功",
            result=groups
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"查询失败: {str(e)}",
            result=None
        )


@router.get("/{config_key}", response_model=CrudResponseModel)
async def get_config_detail(request: Request, config_key: str):
    """获取配置详情"""
    try:
        detail = config_service.get_config_by_key(config_key)
        
        if not detail:
            return CrudResponseModel(
                is_success=False,
                message="配置不存在",
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


@router.put("/{config_key}", response_model=CrudResponseModel)
async def update_config(
    request: Request,
    config_key: str,
    configValue: str = Query(..., alias="configValue", description="配置值")
):
    """更新配置"""
    try:
        success = config_service.update_config(config_key, configValue)
        
        if success:
            return CrudResponseModel(
                is_success=True,
                message="配置更新成功",
                result=None
            )
        else:
            return CrudResponseModel(
                is_success=False,
                message="配置更新失败",
                result=None
            )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"更新失败: {str(e)}",
            result=None
        )


@router.post("/reload", response_model=CrudResponseModel)
async def reload_config(request: Request):
    """重新加载配置（通知所有GEE服务实例热重载）"""
    try:
        import redis
        import os
        
        # 直接使用Redis发布消息
        redis_client = redis.Redis(
            host=os.getenv('REDIS_HOST', '<REDACTED_REDIS_HOST>'),
            port=int(os.getenv('REDIS_PORT', 6379)),
            db=int(os.getenv('REDIS_DB', 3)),
            password=os.getenv('REDIS_PASSWORD', '<REDACTED_REDIS_PASSWORD>'),
            decode_responses=True
        )
        
        # 发布配置重载消息
        redis_client.publish('gee_config_reload', '管理员触发配置重载')
        
        return CrudResponseModel(
            is_success=True,
            message="配置重载请求已发送到所有GEE服务实例",
            result=None
        )
    except Exception as e:
        return CrudResponseModel(
            is_success=False,
            message=f"操作失败: {str(e)}",
            result=None
        )
