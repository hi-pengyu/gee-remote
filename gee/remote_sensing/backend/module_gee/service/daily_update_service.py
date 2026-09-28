"""每日更新服务"""
import requests
from typing import Dict, List
from module_gee.service.app_service import GeeAppService
from module_gee.service.plot_service import GeePlotService
import logging

logger = logging.getLogger(__name__)


class DailyUpdateService:
    """每日更新服务"""
    
    def __init__(self):
        self.app_service = GeeAppService()
        self.plot_service = GeePlotService()
    
    def trigger_daily_update(self, app_id: int = None) -> Dict:
        """
        触发每日更新
        :param app_id: 应用ID，如果为None则更新所有启用的应用
        """
        if app_id:
            # 更新单个应用
            app = self.app_service.get_app_by_id(app_id)
            if not app:
                return {'success': False, 'message': '应用不存在'}
            
            if not app['isEnabled']:
                return {'success': False, 'message': '应用未启用'}
            
            if not app['enableDailyUpdate']:
                return {'success': False, 'message': '应用未启用每日更新'}
            
            result = self._update_single_app(app)
            return result
        else:
            # 更新所有启用的应用
            apps = self.app_service.get_apps_with_daily_update()
            results = []
            
            for app in apps:
                result = self._update_single_app(app)
                results.append(result)
            
            return {
                'success': True,
                'message': f'已触发 {len(apps)} 个应用的每日更新',
                'results': results
            }
    
    def _update_single_app(self, app: Dict) -> Dict:
        """
        更新单个应用的所有地块
        """
        app_id = app['appId']
        app_name = app['appName']
        callback_url = app.get('callbackUrl')
        
        # 使用新的过滤逻辑获取活跃地块
        # 已自动过滤：monitor_status=0, 行政区暂停, 生育期不在范围内
        plots = self.plot_service.get_active_plots_for_update(app_id=app_id)
        
        if not plots:
            return {
                'appId': app_id,
                'appName': app_name,
                'success': True,
                'message': '该应用没有需要更新的地块（已过滤）',
                'totalPlots': 0
            }
        
        # TODO: 这里应该调用 Remote 服务的 API 来提交 GEE 任务
        # 目前先返回模拟数据
        logger.info(f"触发应用 {app_name} 的每日更新，共 {len(plots)} 个地块")
        
        # 模拟结果
        results = []
        for plot in plots:
            results.append({
                'plotId': plot['plot_id'],
                'plotName': plot['plot_name'],
                'status': 'submitted',  # 任务已提交
                'message': '任务已提交到队列'
            })
        
        # 如果有回调地址，记录（实际应该在任务完成后推送）
        if callback_url:
            logger.info(f"应用 {app_name} 配置了回调地址: {callback_url}")
        
        return {
            'appId': app_id,
            'appName': app_name,
            'success': True,
            'message': f'已提交 {len(plots)} 个地块的更新任务',
            'totalPlots': len(plots),
            'callbackUrl': callback_url,
            'results': results
        }

    
    def send_webhook(self, callback_url: str, payload: Dict) -> bool:
        """
        发送 Webhook 回调
        """
        try:
            response = requests.post(
                callback_url,
                json=payload,
                timeout=30,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                logger.info(f"Webhook 推送成功: {callback_url}")
                return True
            else:
                logger.error(f"Webhook 推送失败: {callback_url}, 状态码: {response.status_code}")
                return False
        except Exception as e:
            logger.error(f"Webhook 推送异常: {callback_url}, 错误: {str(e)}")
            return False
