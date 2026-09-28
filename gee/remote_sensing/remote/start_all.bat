@echo off
chcp 65001 >nul
echo ========================================
echo   GEE缓存系统 - 完整启动脚本
echo ========================================
echo.

echo [1/4] 启动 FastAPI 服务...
start "FastAPI Server" cmd /k "python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
timeout /t 2 >nul

echo [2/4] 启动 Celery Worker...
start "Celery Worker" cmd /k "celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo"
timeout /t 2 >nul

echo [3/3] 启动 Celery Beat (定时任务)...
start "Celery Beat" cmd /k "celery -A app.celery_beat beat --loglevel=info"
timeout /t 2 >nul

echo.
echo ========================================
echo   ✅ 所有核心服务已启动！
echo ========================================
echo.
echo 📚 API 文档:     http://localhost:8000/docs
echo ❤️  健康检查:    http://localhost:8000/api/v1/health
echo 📊 缓存统计:    http://localhost:8000/api/v1/cache/stats
echo.
echo 定时任务:
echo   - 每天2点: 更新过期瓦片
echo   - 每周日3点: 清理旧瓦片
echo   - 每小时: 检查缓存大小
echo   - 每天8点: 生成缓存报告
echo.
echo ========================================
echo 可选: 安装Flower监控面板
echo   pip install flower
echo   celery -A app.celery_app flower --port=5555
echo ========================================
echo.
echo 按任意键关闭此窗口...
pause >nul
