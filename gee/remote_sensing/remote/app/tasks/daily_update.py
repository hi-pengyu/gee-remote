"""每日更新任务"""
from celery import Task
from app.celery_app import celery_app
from app.utils.logger import celery_logger
from app.config import ConfigManager
import psycopg2
from psycopg2.extras import RealDictCursor
from app.tasks.cached_workflow import cached_workflow_task
from datetime import datetime

@celery_app.task(name='daily.trigger_updates', bind=True)
def trigger_daily_updates(self):
    """
    触发每日遥感数据更新
    
    1. 获取所有启用的应用
    2. 获取应用下的所有地块
    3. 为每个地块触发下载任务
    """
    celery_logger.info("🌅 开始触发每日遥感数据更新...")
    
    conn = None
    try:
        # 获取数据库连接配置
        db_config = ConfigManager.get_db_config()
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # 1. 获取所有启用的应用
        cursor.execute("SELECT app_id, app_name FROM gee_apps WHERE is_enabled = TRUE")
        apps = cursor.fetchall()
        
        total_tasks = 0
        
        for app in apps:
            app_id = app['app_id']
            app_name = app['app_name']
            
            # 2. 获取应用下的所有地块
            cursor.execute("SELECT plot_id, plot_name, geometry FROM gee_plots WHERE app_id = %s", (app_id,))
            plots = cursor.fetchall()
            
            celery_logger.info(f"📱 应用 [{app_name}] 共有 {len(plots)} 个地块需要更新")
            
            for plot in plots:
                # 3. 触发任务
                # 使用当前日期作为目标日期
                target_date = datetime.now().strftime('%Y-%m-%d')
                
                # 调用 cached_workflow_task
                # 注意：这里需要根据实际情况传递参数，例如 model_type
                # 假设默认使用 'L8' (Landsat 8) 或者从配置中获取
                cached_workflow_task.delay(
                    geometry=plot['geometry'],
                    date=target_date,
                    model_type='L8',  # 默认模型，后续可配置
                    plot_id=plot['plot_id'],
                    app_id=app_id
                )
                total_tasks += 1
        
        celery_logger.info(f"✅ 每日更新触发完成，共提交 {total_tasks} 个任务")
        return {"success": True, "total_tasks": total_tasks}
        
    except Exception as e:
        celery_logger.error(f"❌ 触发每日更新失败: {e}")
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()
