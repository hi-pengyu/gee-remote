# GEE FastAPI 遥感图像处理服务

基于 FastAPI + Celery + Redis 的 Google Earth Engine 遥感图像下载、处理和预测服务。

## ✨ 功能特性

- 🌍 **接受坐标下载遥感图**：通过 API 提交任意 AOI 坐标，自动从 GEE 下载 Sentinel-2 影像
- ⚡ **异步任务队列**：使用 Celery 处理耗时任务，支持实时进度查询
- 🔄 **完整工作流**：自动完成 GEE 导出 → TIF 数据提取 → 本地预测
- 🔒 **GEE并发控制** ⭐ NEW：使用Redis信号量自动限制GEE并发为5个，支持无限排队
- 🤖 **本地预测模型**：使用本地机器学习模型，无需调用外部API
- 📊 **多模型支持**：支持 ZG(株高), AGB(生物量), HSL(叶绿素), SPAD, N(氮), P(磷), K(钾) 等7种预测模型
- 📡 **回调机制** ⭐ NEW：支持任务完成后自动通知业务端
- 🔍 **算法查询接口** ⭐ NEW：查询所有可用的预测模型
- 🎯 **灵活配置**：所有参数可通过配置文件或环境变量调整
- 📝 **完整文档**：自动生成的 Swagger API 文档

## 🏗️ 项目结构

```
gee-fastapi-project/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI 主应用
│   ├── config.py               # 配置管理
│   ├── schemas.py              # 数据模型
│   ├── celery_app.py           # Celery 配置
│   ├── services/               # 服务层
│   │   ├── gee_service.py      # GEE 下载服务
│   │   ├── data_service.py     # 数据处理服务
│   │   ├── prediction_service.py  # 预测服务（本地）
│   │   ├── callback_service.py # 回调服务 ⭐ NEW
│   │   └── local_predictor.py  # 本地预测模块
│   ├── tasks/                  # Celery 任务
│   │   └── workflow.py         # 工作流任务
│   ├── api/
│   │   └── routes.py           # API 路由
│   ├── utils/
│   │   └── logger.py           # 日志工具
│   └── concurrency_control.py  # GEE并发控制 ⭐ NEW
├── model/                      # 模型文件目录 ⭐ NEW
│   ├── README.md               # 模型说明文档
│   ├── zg_reg_model.pkl        # 株高模型
│   ├── agb_reg_model.pkl       # 生物量模型
│   ├── hsl_reg_model.pkl       # 叶绿素模型
│   ├── spad_reg_model.pkl      # SPAD模型
│   ├── N_reg_model.pkl         # 氮含量模型
│   ├── P_reg_model.pkl         # 磷含量模型
│   └── K_reg_model.pkl         # 钾含量模型
├── storage/                    # 数据存储目录
│   ├── tif/                    # TIF 文件
│   ├── csv/                    # CSV 文件（可选）
│   ├── results/                # 预测结果
│   └── logs/                   # 日志文件
├── requirements.txt
├── .env.example                # 环境变量示例
├── start.sh                    # Linux/Mac 启动脚本
├── start.bat                   # Windows 启动脚本
└── README.md
```

## 🚀 快速开始

### 1. 安装依赖

```bash
# 创建虚拟环境（推荐）
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt
```

### 1.1 准备模型文件 ⭐ NEW

将训练好的模型文件（`.pkl` 格式）放置到 `model/` 文件夹中：

```
model/
├── zg_reg_model.pkl      # 株高模型
├── agb_reg_model.pkl     # 生物量模型
├── hsl_reg_model.pkl     # 叶绿素模型
├── spad_reg_model.pkl    # SPAD模型
├── N_reg_model.pkl       # 氮含量模型
├── P_reg_model.pkl       # 磷含量模型
└── K_reg_model.pkl       # 钾含量模型
```

详细说明请参考 `model/README.md`

### 2. 安装 Redis

**Windows:**
下载 Redis for Windows 或使用 Docker：
```bash
docker run -d -p 6379:6379 redis:alpine
```

**Linux/Mac:**
```bash
# Ubuntu/Debian
sudo apt-get install redis-server

# Mac
brew install redis
```

### 3. 配置环境变量

```bash
# 复制示例配置
cp .env.example .env

# 编辑 .env 文件，修改必要的配置
```

### 4. GEE 认证

确保已经完成 GEE 认证：
```bash
earthengine authenticate
```

### 5. 启动服务

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

**Windows:**
```bash
start.bat
```

**或手动启动：**
```bash
# 终端 1: 启动 FastAPI
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 终端 2: 启动 Celery Worker（自动限制5个GEE并发）
celery -A app.celery_app worker --loglevel=info -Q gee_queue
```

**Windows 用户注意：** Celery 在 Windows 上需要添加 `--pool=solo` 参数：
```bash
celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
```

**GEE并发控制说明：**
- 系统使用Redis信号量自动限制GEE并发数为5（GEE官方限制）
- 业务端可以同时发送多个请求，系统会自动排队处理
- 无需手动控制Celery worker的concurrency参数
- 超过5个的任务会自动等待，直到有槽位空出


## 📚 API 使用

启动后访问：
- **API 文档**: http://localhost:8000/docs
- **健康检查**: http://localhost:8000/api/v1/health

### 主要接口

#### 1. 查询可用算法 ⭐ NEW

**GET** `/api/v1/models`

查询所有支持的预测模型

```bash
curl http://localhost:8000/api/v1/models
```

**响应：**
```json
{
  "total": 7,
  "models": [
    {
      "code": "zg",
      "name": "株高",
      "description": "株高预测模型",
      "unit": "cm"
    },
    {
      "code": "agb",
      "name": "地上生物量",
      "description": "地上生物量预测模型",
      "unit": "g/m²"
    }
    // ... 其他5个模型
  ],
  "support_all": true,
  "message": "使用 model_type='all' 可以一次运行所有模型"
}
```

#### 2. 完整工作流（推荐）

**POST** `/api/v1/workflow/run`

接受坐标，自动完成下载 → 处理 → 预测

```json
{
  "aoi_coords": [
    [86.0388457571117, 44.552453045732314],
    [86.0405231637295, 44.5488551561015],
    [86.041776483188, 44.54909929116849],
    [86.0388457571117, 44.552453045732314]
  ],
  "target_date": "2025-09-21",
  "model_type": "agb",
  "window_days": 2
}
```

**响应：**
```json
{
  "task_id": "abc123-def456",
  "status": "pending",
  "message": "完整工作流任务已提交",
  "created_at": "2025-11-09T12:00:00"
}
```

#### 2.1 使用回调机制 ⭐ NEW

**POST** `/api/v1/workflow/run` (带 `callback_url`)

提供回调URL，任务完成后自动通知业务端

```json
{
  "aoi_coords": [
    [86.0388457571117, 44.552453045732314],
    [86.0405231637295, 44.5488551561015],
    [86.041776483188, 44.54909929116849],
    [86.0388457571117, 44.552453045732314]
  ],
  "target_date": "2025-09-21",
  "model_type": "agb",
  "callback_url": "https://your-business-api.com/gee-callback"
}
```

**任务完成后自动回调：**
```json
POST https://your-business-api.com/gee-callback
Content-Type: application/json

{
  "task_id": "abc123-def456",
  "status": "success",
  "timestamp": "2025-11-11T10:32:15.123456",
  "result": {
    "success": true,
    "file_name": "workflow_2025-09-21_...",
    "tif_path": "...",
    "result_path": "...",
    "metadata": { /* 详细结果 */ }
  }
}
```

详细说明请参考 [CALLBACK_IMPLEMENTATION.md](CALLBACK_IMPLEMENTATION.md)

#### 3. 查询队列状态 ⭐ NEW

**GET** `/api/v1/queue/stats`

查询当前队列和GEE并发状态

```bash
curl http://localhost:8000/api/v1/queue/stats
```

**响应：**
```json
{
  "celery_queue": {
    "active_tasks": 8,
    "waiting_tasks": 12,
    "total_tasks": 20
  },
  "gee_concurrency": {
    "current_executing": 5,
    "available_slots": 0,
    "max_concurrent": 5,
    "utilization": "100%"
  },
  "status": "busy",
  "message": "当前5个GEE任务执行中，12个任务等待"
}
```

#### 4. 查询任务状态

**GET** `/api/v1/tasks/{task_id}`

```json
{
  "task_id": "abc123-def456",
  "status": "downloading_image",
  "progress": 30,
  "current_step": "正在从 GEE 导出影像..."
}
```

#### 5. 仅下载遥感图

**POST** `/api/v1/gee/download`

```json
{
  "aoi_coords": [[lon, lat], ...],
  "target_date": "2025-09-21",
  "window_days": 2
}
```

## 🔧 配置说明

主要配置项（在 `.env` 或 `app/config.py` 中）：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `GEE_PROJECT_ID` | GEE 项目 ID | - |
| `GEE_SCALE` | 影像分辨率（米） | 10 |
| `GEE_SEARCH_WINDOW_DAYS` | 搜索窗口天数 | 2 |
| `AVAILABLE_MODELS` | 可用模型列表 | ['zg', 'agb', 'hsl', 'spad', 'n', 'p', 'k'] |
| `REDIS_HOST` | Redis 主机 | localhost |
| `CELERY_TASK_TIME_LIMIT` | 任务超时时间（秒） | 3600 |

## 🎯 本地预测 vs 外部API

### 优势对比

**本地预测（当前版本）⭐**
- ✅ 无需网络请求，速度更快
- ✅ 不依赖外部服务，更稳定
- ✅ 直接处理DataFrame，无需CSV文件
- ✅ 节省存储空间（不生成中间CSV）
- ✅ 更好的错误处理和日志

**工作流程**
```
GEE下载TIF → 提取DataFrame → 本地模型预测 → 保存结果JSON
```

### 支持的模型

| 模型代码 | 模型名称 | 说明 |
|---------|---------|------|
| `zg` | 株高 | 植株高度预测 |
| `agb` | 生物量 | 地上生物量预测 |
| `hsl` | 叶绿素 | 叶绿素含量预测 |
| `spad` | SPAD | SPAD值预测 |
| `n` | 氮含量 | 氮元素含量预测 |
| `p` | 磷含量 | 磷元素含量预测 |
| `k` | 钾含量 | 钾元素含量预测 |

## 📖 使用示例

### Python 客户端

#### 单个AOI区域处理

```python
import requests
import time

# 1. 提交任务
response = requests.post("http://localhost:8000/api/v1/workflow/run", json={
    "aoi_coords": [
        [86.038, 44.552],
        [86.040, 44.549],
        [86.041, 44.549],
        [86.038, 44.552]
    ],
    "target_date": "2025-09-21",
    "model_type": "agb"
})

task_id = response.json()["task_id"]
print(f"任务 ID: {task_id}")

# 2. 查询进度
while True:
    status = requests.get(f"http://localhost:8000/api/v1/tasks/{task_id}").json()
    print(f"进度: {status['progress']}% - {status['current_step']}")
    
    if status['status'] in ['success', 'failure']:
        break
    
    time.sleep(5)

# 3. 获取结果
if status['status'] == 'success':
    print("结果:", status['result'])
```

#### 查询队列状态

```python
import requests

# 查询当前队列和GEE并发情况
response = requests.get("http://localhost:8000/api/v1/queue/stats")
stats = response.json()

print(f"Celery队列: {stats['celery_queue']['active_tasks']} 个任务执行中")
print(f"          {stats['celery_queue']['waiting_tasks']} 个任务等待")
print(f"GEE并发:  {stats['gee_concurrency']['current_executing']}/{stats['gee_concurrency']['max_concurrent']} 使用中")
print(f"          {stats['gee_concurrency']['available_slots']} 个可用槽位")
print(f"状态:     {stats['status']}")
```

### cURL

```bash
# 提交任务
curl -X POST "http://localhost:8000/api/v1/workflow/run" \
  -H "Content-Type: application/json" \
  -d '{
    "aoi_coords": [[86.038, 44.552], [86.040, 44.549], [86.041, 44.549], [86.038, 44.552]],
    "target_date": "2025-09-21",
    "model_type": "agb"
  }'

# 查询状态
curl "http://localhost:8000/api/v1/tasks/abc123"
```

## 🐛 故障排除

### Redis 连接失败
```bash
# 检查 Redis 是否运行
redis-cli ping
# 应返回 PONG
```

### Celery Worker 无法启动
```bash
# 检查 Redis 连接
# 确保 .env 中的 CELERY_BROKER_URL 正确
```

### GEE 认证失败
```bash
# 重新认证
earthengine authenticate
```

## 📝 开发说明

### 添加新的预测模型

1. 在 `.env` 中添加模型名称（如已在外部 API 支持）
2. 无需修改代码，直接使用即可

### 自定义工作流

编辑 `app/tasks/workflow.py`，可以添加新的任务或修改现有流程。

## 📄 许可证

MIT License

## 🙏 致谢

- Google Earth Engine
- FastAPI
- Celery

