@echo off
chcp 65001 >nul

echo 🚀 启动 FastAPI 服务...
start "FastAPI" cmd /k "uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

timeout /t 2 /nobreak >nul

echo 🔧 启动 Celery Worker...
start "Celery Worker" cmd /k "celery -A app.celery_app worker --loglevel=info --concurrency=2 -Q gee_queue --pool=solo"

echo.
echo ✅ 所有服务已启动！
echo.
echo 📚 API 文档: http://localhost:8000/docs
echo ❤️  健康检查: http://localhost:8000/api/v1/health
echo.
echo 按任意键关闭此窗口...
pause >nul

