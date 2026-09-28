# 响应格式优化 v2.3

## 更新时间
2025-11-11

## 本次更新内容

### 1. 移除可视化详细统计信息

**修改前**:
```json
"visualization": {
  "success": true,
  "image_path": "./storage/results/images/prediction_zg_xxx.png",
  "width": 33,
  "height": 41,
  "statistics": {
    "min": 58.4197998046875,
    "max": 65.09210205078125,
    "mean": 60.77594757080078,
    "valid_pixels": 373,
    "breaks": [59.066, 59.584, 62.083, 62.241],
    "grade_pixel_counts": {
      "1": 42,
      "2": 86,
      "3": 151,
      "4": 37,
      "5": 57
    }
  }
}
```

**修改后**:
```json
"visualization": {
  "success": true,
  "image_path": "./storage/results/images/prediction_zg_xxx.png"
}
```

**说明**:
- 只保留 `success` 和 `image_path` 两个字段
- 移除 `width`, `height`, `statistics` 等详细信息
- 减少响应体积，客户端只需要知道图像路径即可

### 2. 添加TIF图像地理坐标边界

为了让客户端能够在地图上正确覆盖图层，新增了 `geo_bounds` 字段，包含左上角和右下角的经纬度坐标。

**新增字段**:
```json
"metadata": {
  "geo_bounds": {
    "top_left": [86.025, 44.555],       // [经度, 纬度]
    "bottom_right": [86.035, 44.545]    // [经度, 纬度]
  },
  ...
}
```

**使用场景**:
客户端可以使用这些坐标在地图上叠加可视化图像：

```javascript
// 示例：Leaflet.js
const bounds = [
  [metadata.geo_bounds.top_left[1], metadata.geo_bounds.top_left[0]],      // [纬度, 经度]
  [metadata.geo_bounds.bottom_right[1], metadata.geo_bounds.bottom_right[0]]
];

L.imageOverlay(visualization.image_path, bounds).addTo(map);
```

```javascript
// 示例：高德地图
const bounds = new AMap.Bounds(
  metadata.geo_bounds.top_left,      // 西南角
  metadata.geo_bounds.bottom_right   // 东北角
);

const imageLayer = new AMap.ImageLayer({
  url: visualization.image_path,
  bounds: bounds
});
map.add(imageLayer);
```

## 技术实现

### 1. 数据服务提取地理坐标

**文件**: `app/services/data_service.py`

使用 `rasterio` 库提取TIF文件的地理边界：

```python
with rasterio.open(tif_path) as src:
    # 提取地理坐标边界（左上角和右下角）
    bounds = src.bounds  # (left, bottom, right, top)
    top_left = [bounds.left, bounds.top]  # [经度, 纬度]
    bottom_right = [bounds.right, bounds.bottom]  # [经度, 纬度]

    metadata = {
        'geo_bounds': {
            'top_left': top_left,
            'bottom_right': bottom_right
        },
        ...
    }
```

### 2. 工作流传递地理坐标

**文件**: `app/tasks/workflow.py`

将地理坐标添加到返回的metadata中：

```python
'metadata': {
    'geo_bounds': data_metadata.get('geo_bounds'),  # 添加地理坐标边界
    'found_date': export_result['found_date'],
    ...
}
```

### 3. 预测服务精简可视化结果

**文件**: `app/services/prediction_service.py`

从完整的可视化结果中提取实际像素统计用于计算 `grade_colors`，但只返回精简版：

```python
# 获取完整结果用于统计
vis_full_result = self.visualization_service.create_colored_map(...)

if vis_full_result.get('success'):
    # 使用统计信息计算实际比例
    stats = vis_full_result.get('statistics', {})
    grade_pixel_counts = stats.get('grade_pixel_counts', {})
    total_pixels = stats.get('valid_pixels', 0)

    grade_colors = VisualizationService.get_grade_colors_from_stats(
        model_type=model_type,
        grade_pixel_counts=grade_pixel_counts,
        total_pixels=total_pixels
    )

    # 只返回精简版
    visualization_result = {
        'success': True,
        'image_path': vis_full_result['image_path']
    }
```

## 完整响应示例

### 单模型响应

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
    "geo_bounds": {
      "top_left": [86.025, 44.555],
      "bottom_right": [86.035, 44.545]
    },
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
        "proportion": 0.1126  // 实际比例：42/373 = 0.1126
      },
      {
        "level": 2,
        "label": "较低",
        "color": "#EAA1A1",
        "proportion": 0.2306  // 实际比例：86/373 = 0.2306
      },
      {
        "level": 3,
        "label": "正常",
        "color": "#87F27C",
        "proportion": 0.4048  // 实际比例：151/373 = 0.4048
      },
      {
        "level": 4,
        "label": "较高",
        "color": "#268845",
        "proportion": 0.0992  // 实际比例：37/373 = 0.0992
      },
      {
        "level": 5,
        "label": "高",
        "color": "#024D2E",
        "proportion": 0.1528  // 实际比例：57/373 = 0.1528
      }
    ],
    "result_path": "./storage/results/prediction_zg_workflow_2025-09-21_20251111_120000.json",
    "visualization": {
      "success": true,
      "image_path": "./storage/results/images/prediction_zg_workflow_2025-09-21_20251111_120000_visualization.png"
    }
  }
}
```

### 多模型总体响应

```json
{
  "success": true,
  "all_models": true,
  "file_name": "workflow_2025-09-21_20251111_120000",
  "tif_path": "./storage/tif/workflow_2025-09-21_20251111_120000.tif",
  "all_models_results": {
    "zg": {...},
    "agb": {...},
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
    "geo_bounds": {
      "top_left": [86.025, 44.555],
      "bottom_right": [86.035, 44.545]
    },
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

## 修改的文件

1. **app/services/data_service.py**
   - 从TIF文件提取地理边界坐标
   - 添加到返回的metadata中

2. **app/tasks/workflow.py**
   - 将 `geo_bounds` 添加到最终响应的metadata中
   - 对单模型和多模型都适用

3. **app/services/prediction_service.py**
   - 精简可视化结果，只返回 `success` 和 `image_path`
   - 保持使用完整统计信息计算 `grade_colors` 的逻辑

## 优势

### 1. 减少响应体积
- 移除可视化的详细统计信息（width, height, statistics）
- 减少每个模型约200-500字节的数据
- 多模型情况下节省更多（7个模型约1.5-3.5KB）

### 2. 提供地图覆盖能力
- `geo_bounds` 提供精确的地理坐标
- 客户端可以直接使用坐标在地图上叠加图像
- 支持各种地图库（Leaflet、高德、百度、Google Maps等）

### 3. 保持功能完整性
- `grade_colors` 仍然使用实际像素统计计算
- 可视化图像路径仍然返回
- 所有必要信息都包含在响应中

## 部署步骤

1. 拉取最新代码
2. 重启服务：
   ```bash
   # 停止现有服务 (Ctrl+C)

   # 重启 FastAPI
   uvicorn app.main:app --reload

   # 重启 Celery Worker (新终端)
   celery -A app.celery_app worker --loglevel=info --pool=solo -Q gee_queue
   ```

3. 测试新的响应格式
4. 更新客户端代码以使用 `geo_bounds` 进行地图覆盖

---

**版本**: 2.3.0
**更新日期**: 2025-11-11
