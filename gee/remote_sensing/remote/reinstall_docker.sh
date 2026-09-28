#!/bin/bash

# ==========================================
# Docker 重新安装脚本 (替换 Snap 版本)
# 适配国内网络环境
# ==========================================

set -e

echo "Starting Docker re-installation process..."

# 1. 卸载旧版本 (Snap 和 Apt)
echo "[1/5] Removing old Docker versions..."
# 尝试停止所有 docker 进程
systemctl stop docker 2>/dev/null || true
systemctl stop docker.socket 2>/dev/null || true

# 卸载 snap 版本
if command -v snap &> /dev/null; then
    echo "  Removing snap docker..."
    snap remove docker || true
fi

# 卸载 apt 旧版本
echo "  Removing apt docker packages..."
apt-get remove -y docker docker-engine docker.io containerd runc docker-compose docker-compose-plugin || true
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras || true
# 清理残留
apt-get autoremove -y

# 2. 安装依赖
echo "[2/5] Installing dependencies..."
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. 添加 Docker 官方 GPG Key (使用阿里云镜像)
echo "[3/5] Adding Docker GPG key (Aliyun)..."
mkdir -p /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 4. 设置软件源 (使用阿里云镜像)
echo "[4/5] Setting up repository (Aliyun)..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. 安装 Docker Engine 和 Docker Compose 插件
echo "[5/5] Installing Docker Engine & Compose..."
apt-get update
# 安装最新版
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. 配置 Docker 镜像加速 (可选，但推荐)
echo "Configuring Docker registry mirrors..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1panel.live",
    "https://hub.rat.dev"
  ]
}
EOF

# 7. 启动服务
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker

# 验证安装
echo ""
echo "=========================================="
echo "Installation Complete!"
echo "Docker Version:"
docker --version
echo "Docker Compose Version:"
docker compose version
echo "=========================================="
echo "Note: You may need to run 'newgrp docker' or logout/login to use docker without sudo."
