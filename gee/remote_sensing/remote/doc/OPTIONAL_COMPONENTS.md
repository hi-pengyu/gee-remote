# GEE缓存系统 - 可选组件安装

## Flower监控面板 (可选)

Flower是Celery的Web监控工具,提供:
- 实时任务监控
- Worker状态查看
- 任务历史记录
- 性能图表

### 安装

```bash
pip install flower
```

### 启动

```bash
# 启动Flower
celery -A app.celery_app flower --port=5555

# 访问
http://localhost:5555
```

### 功能

- **任务列表**: 查看所有任务状态
- **Worker监控**: 查看Worker负载
- **任务详情**: 查看任务参数和结果
- **性能图表**: 任务执行时间统计

### 截图

访问后可以看到:
- Tasks页面: 所有任务的执行记录
- Workers页面: Worker的状态和统计
- Monitor页面: 实时任务流

## 其他可选组件

### 1. Redis Commander (Redis可视化)

```bash
npm install -g redis-commander
redis-commander
# 访问 http://localhost:8081
```

### 2. Prometheus + Grafana (监控)

用于生产环境的专业监控方案

### 3. Sentry (错误追踪)

```bash
pip install sentry-sdk
```

配置后可以自动收集错误信息

## 推荐配置

**开发环境**:
- ✅ Flower (方便调试)

**生产环境**:
- ✅ Prometheus + Grafana (专业监控)
- ✅ Sentry (错误追踪)
- ❌ Flower (不推荐,有安全风险)
