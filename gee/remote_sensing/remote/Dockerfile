# ============================================
# GEE Remote Sensing Service - Dockerfile
# ============================================
# 用于部署 GEE 遥感计算服务（需要科学上网环境）
# Redis 和 PostgreSQL 使用远程服务

FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    # GEE 和 GDAL 依赖
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    # 网络工具
    curl \
    wget \
    # 其他工具
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    # 安装额外的依赖（如果 requirements.txt 中没有）
    pip install \
    fastapi \
    uvicorn[standard] \
    celery \
    redis \
    psycopg2-binary \
    earthengine-api \
    pydrive2 \
    rasterio \
    pandas \
    numpy \
    scikit-learn \
    pillow \
    requests \
    python-dotenv \
    tenacity \
    shapely

# 复制应用代码
COPY . .

# 创建必要的目录
RUN mkdir -p \
    storage/tif \
    storage/csv \
    storage/results \
    storage/logs \
    model

# 设置权限
RUN chmod +x /app

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

# 默认启动命令（可被 docker-compose 覆盖）
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
