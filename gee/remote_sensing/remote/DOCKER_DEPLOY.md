# ============================================
# GEE Remote Sensing Service - 部署指南
# ============================================

## 📦 Docker 部署

### 前置要求

1. **安装 Docker 和 Docker Compose**
   ```bash
   # 验证安装
   docker --version
   docker-compose --version
   ```

2. **准备 GEE 凭证**
   - 在本地完成 GEE 认证：`earthengine authenticate`
   - 凭证文件位于：`~/.config/earthengine/`

3. **准备模型文件**
   - 将 `.pkl` 模型文件放到 `model/` 目录

4. **确保科学上网环境**
   - Docker 容器需要能访问 Google 服务

### 快速启动

```bash
# 1. 进入项目目录
cd F:/gee/remote_sensing/remote

# 2. 构建镜像
docker-compose build

# 3. 启动所有服务
docker-compose up -d

# 4. 查看日志
docker-compose logs -f

# 5. 查看服务状态
docker-compose ps
```

### 访问服务

- **API 文档**: http://localhost:8000/docs
- **健康检查**: http://localhost:8000/api/v1/health

### 常用命令

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看特定服务日志
docker-compose logs -f api
docker-compose logs -f worker

# 进入容器
docker-compose exec api bash
docker-compose exec worker bash

# 清理并重新构建
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## 🔧 配置说明

### 环境变量

在 `docker-compose.yml` 中修改以下配置：

```yaml
environment:
  # 数据库配置（远程）
  - DB_HOST=your-db-host
  - DB_PORT=5433
  - DB_USER=postgres
  - DB_PASSWORD=your-password
  - DB_DATABASE=remote_sensing
  
  # Redis 配置（远程）
  - REDIS_HOST=your-redis-host
  - REDIS_PORT=6379
  - REDIS_DB=3
  - REDIS_PASSWORD=your-redis-password
  
  # GEE 配置
  - GEE_PROJECT_ID=your-gee-project
```

### 挂载卷说明

```yaml
volumes:
  # 存储目录（持久化数据）
  - ./storage:/app/storage
  
  # 模型文件
  - ./model:/app/model
  
  # GEE 凭证（只读）
  - ~/.config/earthengine:/root/.config/earthengine:ro
```

## 🚀 生产环境部署

### 1. 使用 .env 文件管理敏感信息

创建 `.env` 文件：
```bash
DB_HOST=<REDACTED_DB_HOST>
DB_PORT=5433
DB_USER=postgres
DB_PASSWORD=your-password
DB_DATABASE=remote_sensing

REDIS_HOST=<REDACTED_REDIS_HOST>
REDIS_PORT=6379
REDIS_DB=3
REDIS_PASSWORD=your-redis-password

GEE_PROJECT_ID=<REDACTED_GCP_PROJECT_ID>
```

修改 `docker-compose.yml`：
```yaml
services:
  api:
    env_file:
      - .env
```

### 2. 使用 Docker Secrets（推荐）

```bash
# 创建 secrets
echo "your-db-password" | docker secret create db_password -
echo "your-redis-password" | docker secret create redis_password -

# 在 docker-compose.yml 中引用
secrets:
  - db_password
  - redis_password
```

### 3. 配置反向代理（Nginx）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 支持（如果需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 4. 配置 HTTPS（Let's Encrypt）

```bash
# 安装 certbot
apt-get install certbot python3-certbot-nginx

# 获取证书
certbot --nginx -d your-domain.com

# 自动续期
certbot renew --dry-run
```

## 📊 监控和日志

### 查看实时日志

```bash
# 所有服务
docker-compose logs -f

# 特定服务
docker-compose logs -f api
docker-compose logs -f worker
docker-compose logs -f beat

# 最近 100 行
docker-compose logs --tail=100 worker
```

### 日志持久化

修改 `docker-compose.yml`：
```yaml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 🔍 故障排查

### 1. 容器无法启动

```bash
# 查看容器状态
docker-compose ps

# 查看详细日志
docker-compose logs api

# 检查配置
docker-compose config
```

### 2. GEE 认证失败

```bash
# 进入容器
docker-compose exec api bash

# 检查凭证文件
ls -la /root/.config/earthengine/

# 重新认证（如果需要）
earthengine authenticate
```

### 3. 网络连接问题

```bash
# 测试 Redis 连接
docker-compose exec api bash
apt-get update && apt-get install -y redis-tools
redis-cli -h <REDACTED_REDIS_HOST> -p 6379 -a 123456 ping

# 测试数据库连接
apt-get install -y postgresql-client
psql -h <REDACTED_DB_HOST> -p 5433 -U postgres -d remote_sensing
```

### 4. 清理和重置

```bash
# 停止并删除所有容器
docker-compose down

# 删除所有数据卷
docker-compose down -v

# 删除镜像
docker-compose down --rmi all

# 清理未使用的资源
docker system prune -a
```

## 🔄 更新和维护

### 更新代码

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建镜像
docker-compose build

# 3. 重启服务
docker-compose up -d

# 4. 查看日志确认
docker-compose logs -f
```

### 数据备份

```bash
# 备份存储目录
tar -czf storage-backup-$(date +%Y%m%d).tar.gz storage/

# 备份模型文件
tar -czf model-backup-$(date +%Y%m%d).tar.gz model/
```

## 📈 性能优化

### 调整 Worker 并发数

```yaml
worker:
  command: celery -A app.celery_app worker --loglevel=info -Q gee_queue --concurrency=4
```

### 资源限制

```yaml
services:
  worker:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

## 🛡️ 安全建议

1. **不要在 docker-compose.yml 中硬编码密码**，使用 `.env` 文件或 Docker Secrets
2. **限制容器权限**，避免使用 `privileged: true`
3. **定期更新基础镜像**：`docker-compose pull && docker-compose up -d`
4. **配置防火墙**，只开放必要端口
5. **使用 HTTPS**，保护 API 通信

## 📞 技术支持

如遇问题，请检查：
1. Docker 日志：`docker-compose logs`
2. 应用日志：`storage/logs/`
3. 系统资源：`docker stats`
