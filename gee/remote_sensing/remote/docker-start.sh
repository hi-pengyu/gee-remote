#!/bin/bash

# ============================================
# GEE Remote Service - 快速启动脚本
# ============================================

set -e

echo "=========================================="
echo "  GEE Remote Sensing Service"
echo "  Docker 快速启动"
echo "=========================================="
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未安装 Docker"
    echo "   请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误: 未安装 Docker Compose"
    echo "   请先安装 Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker 已安装: $(docker --version)"
echo "✓ Docker Compose 已安装: $(docker-compose --version)"
echo ""

# 检查 GEE 凭证
if [ ! -d "$HOME/.config/earthengine" ]; then
    echo "⚠️  警告: 未找到 GEE 凭证"
    echo "   请先运行: earthengine authenticate"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查模型文件
if [ ! -d "model" ] || [ -z "$(ls -A model)" ]; then
    echo "⚠️  警告: model/ 目录为空"
    echo "   请将 .pkl 模型文件放到 model/ 目录"
    echo ""
fi

# 创建必要的目录
echo "[1/4] 创建存储目录..."
mkdir -p storage/tif storage/csv storage/results storage/logs
echo "✓ 存储目录已创建"
echo ""

# 构建镜像
echo "[2/4] 构建 Docker 镜像..."
docker-compose build
echo "✓ 镜像构建完成"
echo ""

# 启动服务
echo "[3/4] 启动服务..."
docker-compose up -d
echo "✓ 服务已启动"
echo ""

# 等待服务就绪
echo "[4/4] 等待服务就绪..."
sleep 5

# 检查服务状态
echo ""
echo "=========================================="
echo "  服务状态"
echo "=========================================="
docker-compose ps
echo ""

# 健康检查
echo "正在检查 API 健康状态..."
for i in {1..10}; do
    if curl -f http://localhost:8000/api/v1/health &> /dev/null; then
        echo "✓ API 服务正常"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "⚠️  API 服务可能未就绪，请检查日志"
    fi
    sleep 2
done

echo ""
echo "=========================================="
echo "  ✅ 部署完成！"
echo "=========================================="
echo ""
echo "📚 API 文档:     http://localhost:8000/docs"
echo "❤️  健康检查:    http://localhost:8000/api/v1/health"
echo ""
echo "📊 查看日志:     docker-compose logs -f"
echo "🛑 停止服务:     docker-compose down"
echo "🔄 重启服务:     docker-compose restart"
echo ""
