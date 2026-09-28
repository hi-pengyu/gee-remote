@echo off
chcp 65001 >nul
echo ========================================
echo   强制重启 FastAPI 服务器
echo ========================================
echo.

echo [1/3] 停止所有相关进程...
taskkill /F /FI "WINDOWTITLE eq FastAPI Server*" 2>nul
taskkill /F /FI "WINDOWTITLE eq Celery Worker*" 2>nul
taskkill /F /FI "WINDOWTITLE eq Celery Beat*" 2>nul
timeout /t 2 >nul

echo [2/3] 清除 Python 缓存...
if exist "app\__pycache__" rd /s /q "app\__pycache__"
if exist "app\api\__pycache__" rd /s /q "app\api\__pycache__"
if exist "app\services\__pycache__" rd /s /q "app\services\__pycache__"
if exist "app\tasks\__pycache__" rd /s /q "app\tasks\__pycache__"
if exist "app\utils\__pycache__" rd /s /q "app\utils\__pycache__"
echo ✓ 缓存已清除

echo [3/3] 启动服务...
start "FastAPI Server" cmd /k "conda activate gee && python clear_redis.py && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
timeout /t 3 >nul

start "Celery Worker" cmd /k "conda activate gee && celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo"
timeout /t 2 >nul

start "Celery Beat" cmd /k "conda activate gee && celery -A app.celery_beat beat --loglevel=info"

echo.
echo ========================================
echo   ✅ 服务已重启！
echo ========================================
echo.
echo 📚 API 文档:     http://localhost:8000/docs
echo ❤️  健康检查:    http://localhost:8000/api/v1/health
echo.
echo 🔍 DEBUG 模式已启用
echo    查看 FastAPI Server 窗口应该能看到 DEBUG 输出
echo.
pause
