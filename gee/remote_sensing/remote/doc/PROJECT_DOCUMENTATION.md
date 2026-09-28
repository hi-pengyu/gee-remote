# GEE 遥感图像处理与预测系统 - 完整文档与使用流程

## 1. 项目概述

本项目是一个基于 **Google Earth Engine (GEE)** 的遥感图像处理与农业指标预测系统。它集成了 **FastAPI** 后端、**Celery** 异步任务队列、**Redis** 缓存与消息代理，以及 **Vue.js** 前端（开发中）。

系统主要功能是根据用户指定的区域（AOI）和日期，自动从 GEE 下载 Sentinel-2 卫星影像，并在本地运行机器学习模型，预测多种农业指标（如株高、生物量、叶绿素等）。

### 核心特性

*   **自动化工作流**：一键完成 影像下载 -> 数据处理 -> 模型预测。
*   **多模型支持**：内置 7 种农业指标预测模型（株高、生物量、叶绿素、SPAD、氮、磷、钾）。
*   **高性能缓存**：基于网格的瓦片缓存系统，大幅减少 GEE 重复请求，命中缓存时响应速度提升 10-20 倍。
*   **并发控制**：智能限制 GEE 并发请求数（默认 5 个），支持无限任务排队，防止账号被封。
*   **回调机制**：支持 WebHook 回调，任务完成后自动通知业务系统。
*   **本地预测**：模型在本地运行，无需依赖外部预测 API，数据更安全，速度更快。

---

## 2. 系统架构

### 技术栈

*   **后端**: Python 3.9+, FastAPI
*   **异步队列**: Celery
*   **消息代理/缓存**: Redis
*   **数据源**: Google Earth Engine (Sentinel-2)
*   **前端**: Vue 3 + Vite + Element Plus (推荐)

### 数据流向

1.  **用户/前端** 提交任务请求（包含 AOI 坐标、日期、模型类型）。
2.  **FastAPI** 接收请求，生成 Task ID，并将任务推送到 **Redis** 队列。
3.  **Celery Worker** 从队列获取任务：
    *   检查本地缓存（Redis + 文件系统）。
    *   如果未命中缓存，通过 **GEE API** 下载影像（受并发信号量控制）。
    *   处理影像数据，提取特征。
    *   调用本地 **Pickle 模型** 进行预测。
    *   保存结果（JSON/TIF）。
4.  **系统** 通过回调 URL 通知用户，或用户轮询 API 获取结果。

---

## 3. 安装与部署

### 3.1 环境准备

*   **操作系统**: Windows / Linux / macOS
*   **Python**: 3.9 或更高版本
*   **Redis**: 必须安装并运行
*   **GEE 账号**: 需要通过 `earthengine authenticate` 认证

### 3.2 后端部署

1.  **克隆项目**
    ```bash
    git clone <repository_url>
    cd gee-fastapi-project
    ```

2.  **安装依赖**
    ```bash
    pip install -r requirements.txt
    ```

3.  **配置环境变量**
    复制 `.env.example` 为 `.env` 并修改配置：
    ```ini
    # .env
    GEE_PROJECT_ID=your-project-id
    REDIS_HOST=localhost
    ENABLE_TILE_CACHE=true
    ```

4.  **准备模型文件**
    确保 `model/` 目录下包含以下模型文件：
    *   `zg_reg_model.pkl` (株高)
    *   `agb_reg_model.pkl` (生物量)
    *   `hsl_reg_model.pkl` (叶绿素)
    *   ... (其他模型)

5.  **启动服务**

    *   **Windows**: 双击 `start.bat`
    *   **Linux/Mac**: 运行 `./start.sh`
    *   **手动启动**:
        ```bash
        # 终端 1: API 服务
        uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
        
        # 终端 2: Worker 服务
        celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
        ```

### 3.3 前端部署 (gee-admin)

1.  **进入前端目录**
    ```bash
    cd gee-admin
    ```

2.  **安装依赖**
    ```bash
    npm install
    ```

3.  **启动开发服**
    ```bash
    npm run dev
    ```

---

## 4. 使用流程 (User Guide)

### 场景一：标准预测任务

这是最常用的功能，用户提交一个区域，系统返回预测结果。

1.  **提交任务**
    *   **接口**: `POST /api/v1/workflow/run-cached` (推荐)
    *   **参数**:
        ```json
        {
          "aoi_coords": [[86.038, 44.552], [86.040, 44.548], ...],
          "target_date": "2024-06-15",
          "model_type": "all",
          "window_days": 7
        }
        ```
    *   **说明**: `model_type` 设为 `"all"` 可一次性获取所有指标。

2.  **获取任务 ID**
    *   接口返回 `{"task_id": "abc-123", ...}`。

3.  **查询进度**
    *   **接口**: `GET /api/v1/tasks/{task_id}`
    *   **响应**:
        ```json
        {
          "status": "progress",
          "progress": 45,
          "current_step": "正在从 GEE 导出影像..."
        }
        ```

4.  **获取结果**
    *   当状态变为 `success` 时，响应中包含 `result` 字段，内含预测值、文件路径等信息。

### 场景二：集成回调 (Webhook)

适用于业务系统集成，无需轮询。

1.  **提交任务时带上 `callback_url`**
    ```json
    {
      ...
      "callback_url": "https://your-system.com/api/callback"
    }
    ```

2.  **接收通知**
    *   任务完成后，系统会向该 URL 发送 POST 请求，包含完整的任务结果。

### 场景三：缓存管理

用于优化性能和预热数据。

1.  **查看缓存统计**: `GET /api/v1/cache/stats`
2.  **手动预取**: `POST /api/v1/cache/prefetch` (提前下载某区域数据)
3.  **清理缓存**: `DELETE /api/v1/cache/cleanup`

---

## 5. API 参考摘要

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| **POST** | `/api/v1/workflow/run-cached` | **[核心]** 提交带缓存的预测任务 |
| **POST** | `/api/v1/workflow/run` | 提交普通预测任务 (不强制走缓存逻辑) |
| **GET** | `/api/v1/tasks/{task_id}` | 查询任务状态和结果 |
| **GET** | `/api/v1/models` | 获取所有可用模型列表 |
| **GET** | `/api/v1/queue/stats` | 查看队列排队和并发情况 |
| **POST** | `/api/v1/gee/dates` | 查询某区域可用的卫星影像日期 |
| **GET** | `/api/v1/cache/stats` | 查看缓存系统统计信息 |

---

## 6. 常见问题 (FAQ)

**Q: 为什么第一次请求很慢？**
A: 首次请求需要从 Google Earth Engine 下载影像，受网络和 GEE 处理速度影响，通常需要 30-60 秒。后续请求命中缓存后，仅需 1-3 秒。

**Q: 任务一直处于 Pending 状态？**
A: 检查 `GET /api/v1/queue/stats`。系统限制 GEE 并发为 5 个，如果当前任务较多，新任务会排队等待。

**Q: 如何添加新的预测模型？**
A: 将训练好的 `.pkl` 文件放入 `model/` 目录，并在 `.env` 或配置中注册即可，无需修改核心代码。

**Q: 报错 "Redis connection error"？**
A: 请确保 Redis 服务已启动，且 `.env` 中的 `REDIS_HOST` 配置正确。
