"""Controller包初始化"""

from .cache_controller import router as cache_router
from .task_controller import router as task_router
from .stats_controller import router as stats_router
from .optimization_controller import router as optimization_router
from .custom_region_controller import router as custom_region_router
from .accounts_controller import router as accounts_router
from .daily_update_controller import router as daily_update_router
from .plot_controller import router as plot_router
from .region_controller import router as region_router
from .admin_region_controller import adminRegionController as admin_region_router
from .fine_control_controller import fineControlController as fine_control_router
from .crop_type_controller import cropTypeController as crop_type_router

__all__ = [
    'cache_router', 
    'task_router', 
    'stats_router', 
    'optimization_router', 
    'custom_region_router', 
    'accounts_router', 
    'daily_update_router',
    'plot_router',
    'region_router',
    'admin_region_router',
    'fine_control_router',
    'crop_type_router'
]
