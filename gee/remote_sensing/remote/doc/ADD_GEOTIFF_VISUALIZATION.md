# 添加GeoTIFF可视化输出

## 更新时间
2025-11-11

## 更新内容

在原有PNG可视化图像的基础上，新增了**GeoTIFF格式的可视化输出**。现在系统会同时生成：
1. **PNG图像** - 用于Web展示，透明背景
2. **GeoTIFF图像** - 用于GIS软件和地图服务，包含地理坐标信息

## 主要特性

### 1. GeoTIFF格式规格
- **格式**: GeoTIFF (4波段RGBA)
- **坐标系**: EPSG:4326 (WGS84)
- **压缩**: LZW压缩，减小文件体积
- **波段**: 4个波段（Red, Green, Blue, Alpha）
- **透明度**: 支持透明背景（背景像素Alpha=0）

### 2. 文件命名
```
prediction_{model}_{filename}_visualization.png   # PNG图像
prediction_{model}_{filename}_visualization.tif   # GeoTIFF图像
```

### 3. 存储位置
```
./storage/results/images/
├── prediction_zg_workflow_xxx_visualization.png
├── prediction_zg_workflow_xxx_visualization.tif
├── prediction_agb_workflow_xxx_visualization.png
├── prediction_agb_workflow_xxx_visualization.tif
└── ...
```

## 技术实现

### 1. 可视化服务增强

**文件**: `app/services/visualization_service.py`

新增参数：
```python
def create_colored_map(
    self,
    json_path: str,
    model_type: str,
    method: str = 'quantile',
    proportions: List[float] = None,
    tif_path: str = None,         # 新增：TIF路径
    geo_bounds: Dict = None       # 新增：地理坐标边界
) -> Dict:
```

生成GeoTIFF逻辑：
```python
# 从tif_path或geo_bounds获取地理坐标
if geo_bounds is None and tif_path is not None:
    with rasterio.open(tif_path) as src:
        bounds = src.bounds
        geo_bounds = {
            'top_left': [bounds.left, bounds.top],
            'bottom_right': [bounds.right, bounds.bottom]
        }

# 计算仿射变换
transform = from_bounds(
    top_left[0], bottom_right[1],  # west, south
    bottom_right[0], top_left[1],  # east, north
    width, height
)

# 保存为GeoTIFF
with rasterio.open(
    geotif_path,
    'w',
    driver='GTiff',
    height=height,
    width=width,
    count=4,  # RGBA
    dtype=rasterio.uint8,
    crs='EPSG:4326',
    transform=transform,
    compress='lzw'
) as dst:
    for i in range(4):
        dst.write(color_image[:, :, i], i + 1)
```

### 2. 预测服务传递参数

**文件**: `app/services/prediction_service.py`

修改方法签名：
```python
def predict_from_dataframe(
    self,
    df: pd.DataFrame,
    model_type: str,
    file_name: str,
    tif_path: str = None,        # 新增
    geo_bounds: Dict = None      # 新增
) -> Dict:
```

调用可视化服务：
```python
vis_full_result = self.visualization_service.create_colored_map(
    json_path=result_path,
    model_type=model_type,
    method='quantile',
    tif_path=tif_path,      # 传递TIF路径
    geo_bounds=geo_bounds   # 传递地理坐标
)
```

### 3. 工作流传递TIF信息

**文件**: `app/tasks/workflow.py`

单模型预测：
```python
predict_result = prediction_service.predict_from_dataframe(
    df=df,
    model_type=model_type,
    file_name=file_name,
    tif_path=tif_path,                        # 传递TIF路径
    geo_bounds=data_metadata.get('geo_bounds')  # 传递地理坐标
)
```

多模型预测：
```python
predict_result = prediction_service.predict_all_models(
    df=df,
    file_name=file_name,
    tif_path=tif_path,                        # 传递TIF路径
    geo_bounds=data_metadata.get('geo_bounds')  # 传递地理坐标
)
```

## API响应格式

### 单模型响应

```json
{
  "success": true,
  "file_name": "workflow_2025-09-21_20251111_120000",
  "tif_path": "./storage/tif/workflow_2025-09-21_20251111_120000.tif",
  "result_path": "./storage/results/prediction_agb_workflow_xxx.json",
  "metadata": {
    "geo_bounds": {
      "top_left": [86.025, 44.555],
      "bottom_right": [86.035, 44.545]
    },
    ...
  }
}
```

### 模型结果中的可视化字段

```json
{
  "agb": {
    "success": true,
    "model_name": "生物量",
    "grade_colors": [...],
    "result_path": "./storage/results/prediction_agb_xxx.json",
    "visualization": {
      "success": true,
      "image_path": "./storage/results/images/prediction_agb_xxx_visualization.png",
      "tif_path": "./storage/results/images/prediction_agb_xxx_visualization.tif"
    }
  }
}
```

## 使用场景

### 1. Web前端展示
使用PNG图像，支持透明背景：
```javascript
<img src="${visualization.image_path}" />
```

### 2. 地图叠加（使用GeoTIFF）

#### Leaflet with georaster-layer-for-leaflet
```javascript
fetch(visualization.tif_path)
  .then(response => response.arrayBuffer())
  .then(arrayBuffer => {
    parseGeoraster(arrayBuffer).then(georaster => {
      const layer = new GeoRasterLayer({
        georaster: georaster,
        opacity: 0.7
      });
      layer.addTo(map);
    });
  });
```

#### QGIS
1. 打开QGIS
2. 图层 → 添加栅格图层
3. 选择 `prediction_xxx_visualization.tif`
4. 图像会自动定位到正确的地理位置

#### ArcGIS
1. 添加数据 → 添加栅格数据
2. 选择GeoTIFF文件
3. 自动识别坐标系统和位置

### 3. GIS分析
- 使用GDAL读取和处理
- 提取地理坐标信息
- 进行空间分析

```python
import rasterio

with rasterio.open('prediction_xxx_visualization.tif') as src:
    # 读取元数据
    print(f"坐标系: {src.crs}")
    print(f"边界: {src.bounds}")
    print(f"变换: {src.transform}")

    # 读取数据
    rgba = src.read()  # (4, height, width)
```

## 文件大小对比

以 512x512 像素的图像为例：

| 格式 | 未压缩 | 压缩后 | 说明 |
|------|--------|--------|------|
| PNG | ~400KB | ~150KB | Web友好，透明支持 |
| GeoTIFF (无压缩) | ~1MB | - | 包含地理信息 |
| GeoTIFF (LZW压缩) | ~1MB | ~200KB | 包含地理信息，压缩后 |

## 优势

### 1. 完整的地理信息
- 包含精确的坐标系统（EPSG:4326）
- 包含仿射变换矩阵
- 可直接在GIS软件中使用

### 2. 多平台兼容
- Web浏览器：使用PNG
- GIS软件：使用GeoTIFF
- 移动端地图：两者皆可

### 3. 保持透明度
- RGBA格式，背景完全透明
- 便于叠加在底图上
- 不遮挡底层地图要素

### 4. 压缩优化
- LZW无损压缩
- 减小文件体积约80%
- 保持图像质量

## 兼容性说明

### 自动降级
如果无法生成GeoTIFF（例如缺少地理坐标信息），系统会：
1. 记录警告日志
2. `tif_path` 返回 `null`
3. `image_path` (PNG) 仍然可用
4. 不影响整个工作流

### 日志输出
```
[Visualization] ✓ PNG图像已保存: ./storage/results/images/xxx.png
[Visualization] ✓ GeoTIFF已保存: ./storage/results/images/xxx.tif
```

或

```
[Visualization] ✓ PNG图像已保存: ./storage/results/images/xxx.png
[Visualization] ⚠ GeoTIFF保存失败: ...
```

## 依赖项

确保已安装 `rasterio`:
```bash
pip install rasterio
```

## 部署步骤

1. 拉取最新代码
2. 安装/更新依赖：
   ```bash
   pip install -r requirements.txt
   ```

3. 重启服务：
   ```bash
   # 停止现有服务 (Ctrl+C)

   # 重启 FastAPI
   uvicorn app.main:app --reload

   # 重启 Celery Worker (新终端)
   celery -A app.celery_app worker --loglevel=info --pool=solo -Q gee_queue
   ```

4. 测试新功能

## 常见问题

### Q: 为什么我的GeoTIFF没有生成？
A: 检查日志，可能原因：
- TIF路径无效
- 地理坐标缺失
- rasterio库未安装

### Q: 如何在网页地图上使用GeoTIFF？
A: 推荐使用 `georaster-layer-for-leaflet` 或 `ol-tiff`（OpenLayers）库

### Q: GeoTIFF文件太大怎么办？
A: 系统已使用LZW压缩，如需进一步压缩可考虑：
- 降低原始影像分辨率
- 使用JPEG压缩（会损失透明度）

---

**版本**: 2.4.0
**更新日期**: 2025-11-11
