@echo off
echo ============================================================
echo GEE Worker 启动脚本（支持配置热重载）
echo ============================================================
echo.

cd /d f:\gee

echo 激活conda环境...
call conda activate gee

echo.
echo 启动Celery Worker...
echo 注意：配置热重载监听会自动启动
echo.

celery -A app.celery_app worker --loglevel=INFO --pool=solo -Q gee_queue

pause
