# 响应格式优化更新

## 更新时间
2025-11-11

## 更新内容

### 1. **grade_colors 使用实际上色比例**

之前 `grade_colors` 中的 `proportion` 字段使用的是理论比例（预设的分级比例），现在改为**实际上色时该等级像素数占总有效像素的比例**。

**修改前**（理论比例）:
```json
"grade_colors": [
  {
    "level": 1,
    "label": "低",
    "color": "#FFFFE5",
    "proportion": 0.15  // 理论值：15%
  }
]
```

**修改后**（实际比例）:
```json
"grade_colors": [
  {
    "level": 1,
    "label": "低",
    "color": "#FFFFE5",
    "proportion": 0.1523  // 实际值：15.23% (实际上色了15234个像素 / 100000总像素)
  }
]
```

### 2. **移除 results 和 features 字段**

为了减少响应体积和避免暴露详细的坐标数据，从 `prediction_result` 中移除了：
- `results` - 包含每个像素的 X、Y 坐标和预测值的数组
- `features` - 模型使用的特征列表

**修改前**:
```json
{
  "prediction_result": {
    "status": "success",
    "model": "agb",
    "results": [
      {"X": 0, "Y": 0, "prediction": 123.4567},
      {"X": 1, "Y": 0, "prediction": 125.8901},
      // ... 98763 more items
    ],
    "metadata": {
      "features": ["narrow_nir", "swir", "coastal_aerosol", ...]
    },
    "indices": {...}
  }
}
```

**修改后**:
```json
{
  "prediction_result": {
    "status": "success",
    "model": "agb",
    "timestamp": "2025-11-11T12:34:56",
    "metadata": {},
    "indices": {
      "ndvi": {...},
      "evi": {...}
    }
  }
}
```

**说明**:
- 完整的预测结果仍然保存在服务器的JSON文件中（`result_path` 指向的文件）
- API响应只返回汇总信息，不包含具体的坐标和预测值
- 客户端可以通过下载 `result_path` 指向的JSON文件获取完整数据

## 技术实现

### 1. 可视化服务新增统计功能

**文件**: `app/services/visualization_service.py`

新增功能：
- 在 `create_colored_map()` 中统计每个等级的实际像素数
- 返回 `grade_pixel_counts` 字典：`{1: 15234, 2: 20123, ...}`

新增方法：
```python
@staticmethod
def get_grade_colors_from_stats(
    model_type: str,
    grade_pixel_counts: Dict[int, int],
    total_pixels: int
) -> List[Dict]:
    """根据实际上色统计生成分级颜色配置"""
    # 计算实际比例：每个等级的像素数 / 总像素数
    return [
        {
            "level": i + 1,
            "label": labels[i],
            "color": colors[i],
            "proportion": round(grade_pixel_counts.get(i + 1, 0) / total_pixels, 4)
        }
        for i in range(5)
    ]
```

### 2. 预测服务使用实际统计

**文件**: `app/services/prediction_service.py`

工作流程：
1. 执行预测 → 保存完整JSON（包含 results 和 features）
2. 生成可视化图像 → 统计各等级实际像素数
3. 使用实际统计生成 `grade_colors`
4. 准备返回数据时，移除 `results` 和 `features`

```python
# 从可视化统计中获取实际的等级像素分布
stats = visualization_result.get('statistics', {})
grade_pixel_counts = stats.get('grade_pixel_counts', {})
total_pixels = stats.get('valid_pixels', 0)

# 使用实际统计生成 grade_colors
grade_colors = VisualizationService.get_grade_colors_from_stats(
    model_type=model_type,
    grade_pixel_counts=grade_pixel_counts,
    total_pixels=total_pixels
)

# 准备返回的 prediction_result，移除 results 和 features
return_result_data = {
    "status": result_data["status"],
    "model": result_data["model"],
    "timestamp": result_data["timestamp"],
    "metadata": result_data.get("metadata", {}),
    "indices": result_data.get("indices", {})
    # 不包含 results 和 features
}
```

## 响应示例

### 单模型完整响应

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
      },
      "evi": {
        "min": 0.08,
        "max": 0.72,
        "mean": 0.48
      }
    }
  }
}
```

### 多模型响应中的单个模型结果

```json
{
  "zg": {
    "success": true,
    "model_name": "株高",
    "grade_colors": [
      {
        "level": 1,
        "label": "低",
        "color": "#FF0000",
        "proportion": 0.1523
      },
      {
        "level": 2,
        "label": "较低",
        "color": "#EAA1A1",
        "proportion": 0.2015
      },
      {
        "level": 3,
        "label": "正常",
        "color": "#87F27C",
        "proportion": 0.2987
      },
      {
        "level": 4,
        "label": "较高",
        "color": "#268845",
        "proportion": 0.1982
      },
      {
        "level": 5,
        "label": "高",
        "color": "#024D2E",
        "proportion": 0.1493
      }
    ],
    "result_path": "./storage/results/prediction_zg_workflow_2025-09-21_20251111_120000.json",
    "result_count": 98765,
    "prediction_result": {
      "status": "success",
      "model": "zg",
      "timestamp": "2025-11-11T12:34:56.789012",
      "metadata": {},
      "indices": {
        "ndvi": {
          "min": 0.12,
          "max": 0.89,
          "mean": 0.65
        }
      }
    },
    "indices": {
      "ndvi": {
        "min": 0.12,
        "max": 0.89,
        "mean": 0.65
      }
    },
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
        "breaks": [98.14, 145.32, 189.45, 212.88],
        "grade_pixel_counts": {
          "1": 15034,
          "2": 19893,
          "3": 29501,
          "4": 19567,
          "5": 14770
        }
      }
    }
  }
}
```

## 数据获取说明

### API响应中的数据（精简版）
- 模型名称、分级颜色配置
- 汇总统计（最小值、最大值、平均值）
- 植被指数统计
- 可视化图像路径和尺寸
- **不包含**: 每个像素的坐标和预测值

### JSON文件中的数据（完整版）
通过 `result_path` 下载的JSON文件包含：
```json
{
  "status": "success",
  "model": "agb",
  "timestamp": "2025-11-11T12:34:56",
  "results": [
    {"X": 0, "Y": 0, "prediction": 123.4567},
    {"X": 1, "Y": 0, "prediction": 125.8901},
    // ... 所有像素的完整数据
  ],
  "metadata": {
    "features": ["narrow_nir", "swir", "coastal_aerosol", ...]
  },
  "indices": {...}
}
```

## 优势

1. **减少响应体积**:
   - 移除数万条坐标数据，API响应从几MB减少到几KB
   - 提高传输速度，降低带宽消耗

2. **实际统计数据**:
   - `proportion` 反映真实的像素分布
   - 便于前端精确显示图例比例

3. **数据安全**:
   - 不在API响应中暴露详细坐标
   - 完整数据仍保存在服务器，可按需下载

4. **向后兼容**:
   - 添加新字段 `grade_pixel_counts`，不影响现有逻辑
   - JSON文件格式保持不变

## 部署步骤

1. 拉取最新代码
2. 重启服务：
   ```bash
   # 停止现有服务
   # Ctrl+C

   # 重启 FastAPI
   uvicorn app.main:app --reload

   # 重启 Celery Worker
   celery -A app.celery_app worker --loglevel=info --pool=solo -Q gee_queue
   ```

3. 测试新的响应格式
4. 更新客户端代码以适配新格式

---

**版本**: 2.2.0
**更新日期**: 2025-11-11
