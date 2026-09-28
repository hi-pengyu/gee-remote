# GEE 地块行政区管控功能 - 实施指南

## 📋 功能概述

本次升级实现了以下核心功能：

1. **自动识别行政区**：创建地块时自动识别所属行政区
2. **按行政区批量控制**：支持按省/市/区批量暂停/恢复地块监测
3. **生育期自动控制**：根据作物类型自动设置监测周期
4. **地块监测开关**：支持手动开启/关闭单个地块的监测
5. **智能过滤机制**：每日自动更新时自动过滤不符合条件的地块

---

## 🚀 实施步骤

### 第一步：执行数据库升级脚本

```bash
# 进入SQL目录
cd F:\gee\remote_sensing\RuoYi-Vue3-FastAPI\ruoyi-fastapi-backend\sql

# 使用 psql 或其他工具执行升级脚本
psql -U your_username -d your_database -f gee_plot_region_upgrade.sql
```

**脚本包含内容：**
- 扩展 `gee_plots` 表（添加行政区、作物类型、监测控制字段）
- 创建 `gee_region_policies` 表（行政区管控策略）
- 创建 `gee_crop_types` 表（作物类型配置）
- 创建 `china_administrative_divisions` 表（行政区边界数据，可选）
- 创建视图、触发器和存储过程

### 第二步：配置高德地图API（可选）

如果需要使用高德地图API自动识别行政区：

1. 前往 [高德开放平台](https://lbs.amap.com/) 注册账号
2. 创建应用，获取 API Key
3. 修改配置文件：

```python
# module_gee/service/geocoding_service.py
class GeocodingService:
    AMAP_KEY = "your_amap_api_key_here"  # 替换为实际的API Key
    AMAP_ENABLED = True  # 启用高德地图API
```

**注意：** 如果不配置高德API，系统会尝试使用PostGIS空间查询（需要导入行政区边界数据）。

### 第三步：导入行政区边界数据（可选，用于PostGIS）

如果希望使用PostGIS进行离线行政区查询：

1. 启用PostGIS扩展：
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

2. 下载行政区GeoJSON数据：
   - [阿里云DataV GeoAtlas](http://datav.aliyun.com/portal/school/atlas/area_selector)
   - [高德开放平台](https://lbs.amap.com/api/webservice/guide/api/district)

3. 使用Python脚本导入数据（参考 `geocoding_service.py` 中的注释）

### 第四步：注册路由

确保在主应用中注册新的路由：

```python
# server.py 或 main.py
from module_gee.controller import plot_router, region_router

app.include_router(plot_router)
app.include_router(region_router)
```

### 第五步：重启服务

```bash
# 重启FastAPI服务
python server.py
```

---

## 📡 API 接口文档

### 1. 地块管理接口

#### 1.1 创建地块（支持自动识别行政区）

```http
POST /gee/plot/
Content-Type: application/json

{
  "appId": 1,
  "plotName": "河南省某农场地块A",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[113.5, 34.5], [113.6, 34.5], [113.6, 34.6], [113.5, 34.6], [113.5, 34.5]]]
  },
  "description": "测试地块",
  "cropType": "corn",       // 可选：作物类型
  "adcode": "410100"        // 可选：行政区代码（不提供则自动识别）
}
```

**响应：**
```json
{
  "isSuccess": true,
  "message": "创建成功",
  "result": {
    "plotId": 123
  }
}
```

#### 1.2 切换地块监测状态

```http
PUT /gee/plot/{plot_id}/toggle
Content-Type: application/json

{
  "monitorStatus": 0  // 0=关闭, 1=开启
}
```

#### 1.3 获取地块列表

```http
GET /gee/plot/list?pageNum=1&pageSize=10&appId=1
```

### 2. 行政区管控接口

#### 2.1 暂停某个行政区的监测

```http
POST /gee/region/pause
Content-Type: application/json

{
  "adcode": "410000",           // 河南省
  "reason": "非农用地区暂停监测"
}
```

**支持前缀匹配：**
- `41` → 暂停整个河南省
- `4101` → 暂停郑州市
- `410100` → 暂停郑州市市辖区

**响应：**
```json
{
  "isSuccess": true,
  "message": "已暂停行政区 410000 的监测，影响 156 个地块",
  "result": {
    "success": true,
    "affected_plots": 156,
    "adcode": "410000",
    "reason": "非农用地区暂停监测"
  }
}
```

#### 2.2 恢复某个行政区的监测

```http
POST /gee/region/resume
Content-Type: application/json

{
  "adcode": "410000"
}
```

#### 2.3 查看暂停的行政区列表

```http
GET /gee/region/paused-list
```

#### 2.4 查看行政区地块统计

```http
GET /gee/region/stats/410000
```

**响应：**
```json
{
  "isSuccess": true,
  "message": "查询成功",
  "result": {
    "adcode": "410000",
    "totalPlots": 200,
    "activePlots": 150,
    "pausedPlots": 50,
    "autoUpdatePlots": 180
  }
}
```

---

## 🔄 每日自动更新逻辑

每日自动更新任务会自动应用以下过滤器：

### 过滤器 1：手动状态检查
- 跳过 `monitor_status = 0` 的地块

### 过滤器 2：行政区管控检查
- 查询 `gee_region_policies` 表
- 如果地块的 `adcode` 匹配暂停区域（支持前缀），则跳过

### 过滤器 3：生育期时间窗检查
- 检查当前日期是否在 `[monitor_start_date, monitor_end_date]` 范围内
- 支持跨年情况（如小麦：10-01 到次年 06-30）

**示例日志：**
```
共 200 个地块，过滤后 85 个需要更新
地块 101 位于暂停区域 410000，跳过
地块 102 不在监测周期内，跳过
地块 103 已手动关闭，跳过
```

---

## 🎯 使用场景示例

### 场景 1：创建玉米地块并自动设置监测周期

```javascript
// 前端调用
POST /gee/plot/
{
  "appId": 1,
  "plotName": "河南玉米地块001",
  "geometry": {...},
  "cropType": "corn"  // 系统自动设置 monitor_start_date=04-01, monitor_end_date=09-30
}
```

### 场景 2：暂停河南省所有地块监测

```javascript
// 管理员操作
POST /gee/region/pause
{
  "adcode": "41",  // 前缀匹配，所有41开头的地块都会被暂停
  "reason": "极端天气预警"
}

// 影响：
// - 410100（郑州）
// - 410200（开封）
// - 410300（洛阳）
// ... 所有河南省的地块
```

### 场景 3：手动关闭单个地块

```javascript
// 用户操作
PUT /gee/plot/123/toggle
{
  "monitorStatus": 0  // 关闭地块123的监测
}
```

### 场景 4：查看每日更新结果

```javascript
// 每日凌晨自动执行
GET /gee/daily-update/trigger

// 系统自动：
// 1. 获取所有 monitor_status=1 且 auto_update=TRUE 的地块
// 2. 过滤掉暂停区域的地块
// 3. 过滤掉不在生育期的地块
// 4. 为剩余地块创建GEE任务
```

---

## 📊 数据库表结构说明

### gee_plots（地块表）- 新增字段

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| adcode | VARCHAR(20) | 行政区代码 | 410100 |
| province | VARCHAR(50) | 省份名称 | 河南省 |
| city | VARCHAR(50) | 城市名称 | 郑州市 |
| district | VARCHAR(50) | 区县名称 | 中原区 |
| crop_type | VARCHAR(50) | 作物类型 | corn |
| monitor_status | SMALLINT | 监测状态 | 1=开启, 0=关闭 |
| monitor_start_date | VARCHAR(10) | 监测开始日期 | 04-01 |
| monitor_end_date | VARCHAR(10) | 监测结束日期 | 09-30 |
| auto_update | BOOLEAN | 是否自动更新 | TRUE |

### gee_region_policies（行政区管控表）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| policy_id | SERIAL | 主键 |
| adcode | VARCHAR(20) | 行政区代码 |
| policy_type | VARCHAR(20) | 策略类型（pause） |
| reason | VARCHAR(500) | 暂停原因 |
| is_active | BOOLEAN | 是否激活 |

### gee_crop_types（作物类型配置表）

| 作物代码 | 作物名称 | 默认监测周期 |
|----------|----------|--------------|
| corn | 玉米 | 04-01 ~ 09-30 |
| rice | 水稻 | 05-01 ~ 10-31 |
| wheat | 小麦 | 10-01 ~ 06-30 |
| soybean | 大豆 | 05-01 ~ 09-30 |
| cotton | 棉花 | 04-01 ~ 10-31 |

---

## ⚠️ 注意事项

1. **高德API限额**：免费版每日30万次调用，超出需付费
2. **PostGIS性能**：行政区边界数据较大，建议创建空间索引
3. **跨年生育期**：小麦等跨年作物已支持（10-01 到次年 06-30）
4. **级联删除**：删除应用会级联删除其下所有地块
5. **日志审计**：地块状态变更会自动记录到 `gee_plot_monitor_logs` 表

---

## 🐛 故障排查

### 问题1：无法自动识别行政区

**原因：** 高德API未配置或PostGIS数据未导入

**解决：**
1. 检查 `geocoding_service.py` 中的 `AMAP_KEY` 是否配置
2. 或导入行政区边界数据到 `china_administrative_divisions` 表

### 问题2：每日更新没有跳过暂停区域

**原因：** 地块的 `adcode` 字段为空

**解决：**
```sql
-- 为现有地块补充行政区信息
UPDATE gee_plots SET adcode = '410100' WHERE plot_id = xxx;
```

### 问题3：生育期过滤不生效

**原因：** `monitor_start_date` 或 `monitor_end_date` 为空

**解决：**
```sql
-- 手动设置监测周期
UPDATE gee_plots 
SET monitor_start_date = '04-01', 
    monitor_end_date = '09-30'
WHERE crop_type = 'corn';
```

---

## 📞 技术支持

如有问题，请查看：
- 数据库升级脚本：`sql/gee_plot_region_upgrade.sql`
- 地理编码服务：`module_gee/service/geocoding_service.py`
- 行政区管控服务：`module_gee/service/region_policy_service.py`
- 地块服务：`module_gee/service/plot_service.py`

---

**版本：** 2.0.0  
**更新日期：** 2026-01-26
