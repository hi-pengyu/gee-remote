#!/bin/bash

# 启动 FastAPI 服务
echo "🚀 启动 FastAPI 服务..."
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &

# 等待 1 秒
sleep 1

# 启动 Celery Worker
echo "🔧 启动 Celery Worker..."
celery -A app.celery_app worker --loglevel=info --concurrency=2 -Q gee_queue &

echo "✅ 所有服务已启动！"
echo ""
echo "📚 API 文档: http://localhost:8000/docs"
echo "❤️  健康检查: http://localhost:8000/api/v1/health"
echo ""
echo "按 Ctrl+C 停止所有服务"

# 等待用户中断
wait

