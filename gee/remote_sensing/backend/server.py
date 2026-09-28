from contextlib import asynccontextmanager
from fastapi import FastAPI
from config.env import AppConfig
from config.get_db import init_create_table
from config.get_redis import RedisUtil
from config.get_scheduler import SchedulerUtil
from exceptions.handle import handle_exception
from middlewares.handle import handle_middleware
from module_admin.controller.cache_controller import cacheController
from module_admin.controller.captcha_controller import captchaController
from module_admin.controller.common_controller import commonController
from module_admin.controller.config_controller import configController
from module_admin.controller.dept_controller import deptController
from module_admin.controller.dict_controller import dictController
from module_admin.controller.log_controller import logController
from module_admin.controller.login_controller import loginController
from module_admin.controller.job_controller import jobController
from module_admin.controller.menu_controller import menuController
from module_admin.controller.notice_controller import noticeController
from module_admin.controller.online_controller import onlineController
from module_admin.controller.post_controler import postController
from module_admin.controller.role_controller import roleController
from module_admin.controller.server_controller import serverController
from module_admin.controller.user_controller import userController
from module_generator.controller.gen_controller import genController
from module_gee.controller.cache_controller import router as gee_cache_router
from module_gee.controller.task_controller import router as gee_task_router
from module_gee.controller.stats_controller import router as gee_stats_router
from module_gee.controller.result_controller import router as gee_result_router
from module_gee.controller.config_controller import router as gee_config_router
from module_gee.controller.app_controller import router as gee_app_router
from module_gee.controller.plot_controller import router as gee_plot_router
from module_gee.controller.optimization_controller import router as gee_optimization_router
from module_gee.controller.custom_region_controller import router as gee_custom_region_router
from module_gee.controller.accounts_controller import router as gee_accounts_router
from module_gee.controller.daily_update_controller import router as gee_daily_update_router
from module_gee.controller.admin_region_controller import adminRegionController
from module_gee.controller.fine_control_controller import fineControlController
from module_gee.controller.crop_type_controller import cropTypeController
from sub_applications.handle import handle_sub_applications
from utils.common_util import worship
from utils.log_util import logger


# 生命周期事件
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f'⏰️ {AppConfig.app_name}开始启动')
    worship()
    await init_create_table()
    app.state.redis = await RedisUtil.create_redis_pool()
    await RedisUtil.init_sys_dict(app.state.redis)
    await RedisUtil.init_sys_config(app.state.redis)
    await SchedulerUtil.init_system_scheduler()
    logger.info(f'🚀 {AppConfig.app_name}启动成功')
    yield
    await RedisUtil.close_redis_pool(app)
    await SchedulerUtil.close_system_scheduler()


# 初始化FastAPI对象
app = FastAPI(
    title=AppConfig.app_name,
    description=f'{AppConfig.app_name}接口文档',
    version=AppConfig.app_version,
    lifespan=lifespan,
)

# 挂载子应用
handle_sub_applications(app)
# 加载中间件处理方法
handle_middleware(app)
# 加载全局异常处理方法
handle_exception(app)


# 加载路由列表
controller_list = [
    {'router': loginController, 'tags': ['登录模块']},
    {'router': captchaController, 'tags': ['验证码模块']},
    {'router': userController, 'tags': ['系统管理-用户管理']},
    {'router': roleController, 'tags': ['系统管理-角色管理']},
    {'router': menuController, 'tags': ['系统管理-菜单管理']},
    {'router': deptController, 'tags': ['系统管理-部门管理']},
    {'router': postController, 'tags': ['系统管理-岗位管理']},
    {'router': dictController, 'tags': ['系统管理-字典管理']},
    {'router': configController, 'tags': ['系统管理-参数管理']},
    {'router': noticeController, 'tags': ['系统管理-通知公告管理']},
    {'router': logController, 'tags': ['系统管理-日志管理']},
    {'router': onlineController, 'tags': ['系统监控-在线用户']},
    {'router': jobController, 'tags': ['系统监控-定时任务']},
    {'router': serverController, 'tags': ['系统监控-菜单管理']},
    {'router': cacheController, 'tags': ['系统监控-缓存监控']},
    {'router': commonController, 'tags': ['通用模块']},
    {'router': genController, 'tags': ['代码生成']},
    {'router': gee_cache_router, 'tags': ['GEE-缓存管理']},
    {'router': gee_task_router, 'tags': ['GEE-任务管理']},
    {'router': gee_stats_router, 'tags': ['GEE-数据统计']},
    {'router': gee_result_router, 'tags': ['GEE-任务结果']},
    {'router': gee_config_router, 'tags': ['GEE-配置管理']},
    {'router': gee_app_router, 'tags': ['GEE-应用管理']},
    {'router': gee_plot_router, 'tags': ['GEE-地块管理']},
    {'router': gee_optimization_router, 'tags': ['GEE-瓦片优化']},
    {'router': gee_custom_region_router, 'tags': ['GEE-自定义区域']},
    {'router': gee_accounts_router, 'tags': ['GEE-账号池管理']},
    {'router': gee_daily_update_router, 'tags': ['GEE-每日更新']},
    {'router': adminRegionController, 'tags': ['GEE-行政区管理']},
    {'router': fineControlController, 'tags': ['GEE-精细化管控']},
    {'router': cropTypeController, 'tags': ['GEE-作物类型管理']},
]

for controller in controller_list:
    app.include_router(router=controller.get('router'), tags=controller.get('tags'))
