# JSON响应格式更新日志

## 更新时间
2025-11-11

## 更新内容

### 1. 添加处理时间字段
在 `metadata` 中新增 `processing_time_seconds` 字段，记录完整工作流的执行时间（秒）。

**位置**: `app/tasks/workflow.py`

**实现**:
```python
import time
start_time = time.time()  # 任务开始时记录

# 任务结束前计算
processing_time = round(time.time() - start_time, 2)

# 添加到返回的 metadata 中
'processing_time_seconds': processing_time
```

### 2. 统一 model_type 为数组格式
无论是单模型还是多模型，`metadata.model_type` 统一返回为数组格式。

**修改前**:
- 单模型: `"model_type": "agb"` (字符串)
- 多模型: `"model_type": "all"` (字符串)

**修改后**:
- 单模型: `"model_type": ["agb"]` (数组)
- 多模型: `"model_type": ["zg", "agb", "hsl", "spad", "n", "p", "k"]` (成功模型的数组)

### 3. 添加模型名称和分级颜色
在每个模型的预测结果中新增 `model_name` 和 `grade_colors` 字段。

**位置**: `app/services/prediction_service.py`

**新增字段**:
```json
{
  "model_name": "株高",
  "grade_colors": [
    {
      "level": 1,
      "label": "低",
      "color": "#FF0000",
      "proportion": 0.15
    },
    {
      "level": 2,
      "label": "较低",
      "color": "#EAA1A1",
      "proportion": 0.2
    },
    ...
  ]
}
```

## 完整响应示例

### 单模型预测 (model_type="agb")

```json
{
  "success": true,
  "file_name": "workflow_2025-09-21_20251111_120000",
  "tif_path": "./storage/tif/workflow_2025-09-21_20251111_120000.tif",
  "result_path": "./storage/results/prediction_agb_workflow_2025-09-21_20251111_120000.json",
  "metadata": {
    "found_date": "2025-09-21",
    "cloud_cover": 5.32,
    "image_count": 3,
    "total_pixels": 100000,
    "valid_pixels": 98765,
    "result_count": 98765,
    "model_type": ["agb"],
    "prediction_success": true,
    "processing_time_seconds": 45.32,
    "indices": {
      "ndvi": {
        "min": 0.12,
        "max": 0.89,
        "mean": 0.65
      }
    }
  }
}
```

### 多模型预测 (model_type="all")

```json
{
  "success": true,
  "file_name": "workflow_2025-09-21_20251111_120000",
  "tif_path": "./storage/tif/workflow_2025-09-21_20251111_120000.tif",
  "all_models": true,
  "all_models_results": {
    "zg": {
      "success": true,
      "model_name": "株高",
      "grade_colors": [
        {
          "level": 1,
          "label": "低",
          "color": "#FF0000",
          "proportion": 0.15
        },
        {
          "level": 2,
          "label": "较低",
          "color": "#EAA1A1",
          "proportion": 0.2
        },
        {
          "level": 3,
          "label": "正常",
          "color": "#87F27C",
          "proportion": 0.3
        },
        {
          "level": 4,
          "label": "较高",
          "color": "#268845",
          "proportion": 0.2
        },
        {
          "level": 5,
          "label": "高",
          "color": "#024D2E",
          "proportion": 0.15
        }
      ],
      "result_path": "./storage/results/prediction_zg_workflow_2025-09-21_20251111_120000.json",
      "result_count": 98765,
      "prediction_result": {
        "status": "success",
        "results": [...],
        "indices": {...}
      },
      "indices": {...},
      "visualization": {
        "success": true,
        "image_path": "./storage/results/images/prediction_zg_workflow_2025-09-21_20251111_120000_visualization.png",
        "width": 512,
        "height": 512,
        "statistics": {
          "min": 45.23,
          "max": 234.67,
          "mean": 125.45,
          "valid_pixels": 98765,
          "breaks": [98.14, 145.32, 189.45, 212.88]
        }
      }
    },
    "agb": {
      "success": true,
      "model_name": "生物量",
      "grade_colors": [
        {
          "level": 1,
          "label": "低",
          "color": "#FFFFE5",
          "proportion": 0.15
        },
        {
          "level": 2,
          "label": "较低",
          "color": "#D2EDA0",
          "proportion": 0.2
        },
        {
          "level": 3,
          "label": "正常",
          "color": "#85CC7E",
          "proportion": 0.4
        },
        {
          "level": 4,
          "label": "较高",
          "color": "#268845",
          "proportion": 0.15
        },
        {
          "level": 5,
          "label": "高",
          "color": "#004529",
          "proportion": 0.1
        }
      ],
      "result_path": "./storage/results/prediction_agb_workflow_2025-09-21_20251111_120000.json",
      "result_count": 98765,
      "visualization": {...}
    },
    "hsl": {...},
    "spad": {...},
    "n": {...},
    "p": {...},
    "k": {...}
  },
  "metadata": {
    "found_date": "2025-09-21",
    "cloud_cover": 5.32,
    "image_count": 3,
    "total_pixels": 100000,
    "valid_pixels": 98765,
    "total_predictions": 691255,
    "model_type": ["zg", "agb", "hsl", "spad", "n", "p", "k"],
    "models_count": {
      "total": 7,
      "successful": 7,
      "failed": 0
    },
    "successful_models": ["zg", "agb", "hsl", "spad", "n", "p", "k"],
    "failed_models": [],
    "processing_time_seconds": 94.18
  }
}
```

## 修改的文件列表

1. **app/tasks/workflow.py**
   - 添加时间跟踪
   - 修改 `model_type` 为数组格式
   - 添加 `processing_time_seconds` 字段

2. **app/services/prediction_service.py**
   - 添加 `model_name` 字段（中文名称）
   - 添加 `grade_colors` 字段（分级颜色配置）

3. **app/services/visualization_service.py**
   - 新增 `MODEL_NAMES` 字典
   - 新增 `MODEL_PALETTE_HEX` 字典
   - 新增 `get_grade_colors()` 静态方法

4. **VISUALIZATION_README.md**
   - 更新文档中的响应示例

## 兼容性说明

**Breaking Changes**:
- `metadata.model_type` 从字符串改为数组，现有的客户端需要更新解析逻辑

**新增字段**:
- `metadata.processing_time_seconds` - 新字段，向后兼容
- `model_name` - 新字段，向后兼容
- `grade_colors` - 新字段，向后兼容

## 部署步骤

1. 停止现有服务
2. 拉取最新代码
3. 重启 FastAPI 服务
4. 重启 Celery Worker
5. 测试新的响应格式

```bash
# 停止服务（根据实际情况）
# Ctrl+C 停止 uvicorn 和 celery

# 重启服务
uvicorn app.main:app --reload

# 在另一个终端
celery -A app.celery_app worker --loglevel=info --pool=solo -Q gee_queue
```

---

**版本**: 2.1.0
**更新日期**: 2025-11-11
