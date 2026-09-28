# GEE 行政区管控地图页面 - 设计方案

## 📋 页面概述

**路径：** `/gee/stop/index`  
**功能：** 地图可视化展示所有地块和行政区域，支持行政区批量管控操作

---

## 🎨 页面布局

### 整体结构（参考 optimization 页面）

```
┌─────────────────────────────────────────────────────────────┐
│                        顶部导航栏                            │
├──────────────┬──────────────────────────────────────────────┤
│              │                                              │
│              │                                              │
│   左侧面板    │              地图区域                         │
│   (320px)    │          (L7 地图 + 图层控制)                 │
│              │                                              │
│              │                                              │
└──────────────┴──────────────────────────────────────────────┘
```

---

## 🗂️ 左侧面板设计

### 1. 顶部标题区
```vue
<div class="sidebar-header">
  <h3>行政区管控</h3>
  <p>地块与行政区可视化管理</p>
</div>
```

### 2. 模式切换（4个标签）
```vue
<el-radio-group v-model="mode">
  <el-radio-button value="control">管控操作</el-radio-button>
  <el-radio-button value="plots">地块列表</el-radio-button>
  <el-radio-button value="regions">行政区</el-radio-button>
  <el-radio-button value="paused">暂停列表</el-radio-button>
</el-radio-group>
```

### 3. 各模式内容

#### 模式1：管控操作 (control)
```vue
<div class="control-panel">
  <!-- 快速统计 -->
  <el-card class="stats-card">
    <div class="stat-item">
      <span class="stat-label">总地块数</span>
      <span class="stat-value">{{ totalPlots }}</span>
    </div>
    <div class="stat-item">
      <span class="stat-label">监测中</span>
      <span class="stat-value active">{{ activePlots }}</span>
    </div>
    <div class="stat-item">
      <span class="stat-label">已暂停</span>
      <span class="stat-value paused">{{ pausedPlots }}</span>
    </div>
  </el-card>

  <!-- 暂停行政区 -->
  <el-card class="action-card">
    <h4>暂停行政区</h4>
    <el-form :model="pauseForm" label-position="top">
      <el-form-item label="行政区代码">
        <el-input 
          v-model="pauseForm.adcode" 
          placeholder="如：41（河南省）"
        >
          <template #append>
            <el-button @click="showAdcodeHelp">说明</el-button>
          </template>
        </el-input>
        <div class="help-text">
          支持前缀匹配：41=河南省，4101=郑州市
        </div>
      </el-form-item>

      <el-form-item label="暂停原因">
        <el-input 
          v-model="pauseForm.reason" 
          type="textarea" 
          :rows="3"
          placeholder="请输入暂停原因"
        />
      </el-form-item>

      <el-form-item>
        <el-button 
          type="primary" 
          @click="previewImpact" 
          :loading="previewLoading"
          style="width: 100%"
        >
          查看影响范围
        </el-button>
      </el-form-item>

      <!-- 影响预览 -->
      <div v-if="impactStats" class="impact-preview">
        <el-alert 
          :title="`将影响 ${impactStats.totalPlots} 个地块`" 
          type="warning"
          :closable="false"
        />
        <div class="impact-details">
          <div class="detail-item">
            <span>监测中：</span>
            <span class="value">{{ impactStats.activePlots }}</span>
          </div>
          <div class="detail-item">
            <span>已暂停：</span>
            <span class="value">{{ impactStats.pausedPlots }}</span>
          </div>
        </div>
      </div>

      <el-form-item>
        <el-button 
          type="danger" 
          @click="handlePause" 
          :loading="pauseLoading"
          :disabled="!impactStats"
          style="width: 100%"
        >
          确认暂停
        </el-button>
      </el-form-item>
    </el-form>
  </el-card>
</div>
```

#### 模式2：地块列表 (plots)
```vue
<div class="list-panel">
  <!-- 搜索框 -->
  <div class="search-box">
    <el-input 
      v-model="searchQuery" 
      placeholder="搜索地块名称" 
      prefix-icon="Search" 
      clearable 
    />
  </div>

  <!-- 筛选器 -->
  <div class="filter-bar">
    <el-select v-model="plotFilter" placeholder="筛选状态" size="small">
      <el-option label="全部" value="all" />
      <el-option label="监测中" value="active" />
      <el-option label="已暂停" value="paused" />
    </el-select>
  </div>

  <!-- 地块列表 -->
  <div class="item-list">
    <div 
      v-for="plot in filteredPlots" 
      :key="plot.plotId" 
      class="list-item"
      @click="locatePlot(plot)"
    >
      <div class="item-icon" :class="plot.monitorStatus === 1 ? 'active' : 'paused'">
        <svg-icon icon-class="guide" />
      </div>
      <div class="item-info">
        <div class="item-name">{{ plot.plotName }}</div>
        <div class="item-desc">
          {{ plot.province }} / {{ plot.city }}
        </div>
        <div class="item-tags">
          <el-tag 
            :type="plot.monitorStatus === 1 ? 'success' : 'info'" 
            size="small"
          >
            {{ plot.monitorStatus === 1 ? '监测中' : '已暂停' }}
          </el-tag>
          <el-tag v-if="plot.cropType" type="primary" size="small">
            {{ getCropTypeName(plot.cropType) }}
          </el-tag>
        </div>
      </div>
    </div>
  </div>
</div>
```

#### 模式3：行政区 (regions)
```vue
<div class="list-panel">
  <!-- 搜索框 -->
  <div class="search-box">
    <el-input 
      v-model="searchQuery" 
      placeholder="搜索行政区" 
      prefix-icon="Search" 
      clearable 
    />
  </div>

  <!-- 级别筛选 -->
  <div class="filter-bar">
    <el-radio-group v-model="regionLevel" size="small">
      <el-radio-button label="province">省级</el-radio-button>
      <el-radio-button label="city">市级</el-radio-button>
      <el-radio-button label="district">区县</el-radio-button>
    </el-radio-group>
  </div>

  <!-- 行政区列表 -->
  <div class="item-list">
    <div 
      v-for="region in filteredRegions" 
      :key="region.adcode" 
      class="list-item"
      @click="locateRegion(region)"
    >
      <div class="item-icon green">
        <svg-icon icon-class="tree" />
      </div>
      <div class="item-info">
        <div class="item-name">{{ region.name }}</div>
        <div class="item-desc">代码: {{ region.adcode }}</div>
        <div class="item-stats">
          <span>地块: {{ region.plotCount || 0 }}</span>
        </div>
      </div>
      <div class="item-actions">
        <el-button 
          type="text" 
          size="small" 
          @click.stop="quickPause(region)"
        >
          暂停
        </el-button>
      </div>
    </div>
  </div>
</div>
```

#### 模式4：暂停列表 (paused)
```vue
<div class="paused-panel">
  <!-- 暂停的行政区列表 -->
  <div class="paused-list">
    <div 
      v-for="item in pausedList" 
      :key="item.adcode" 
      class="paused-item"
    >
      <div class="paused-header">
        <el-tag type="warning" size="small">{{ item.adcode }}</el-tag>
        <el-button 
          type="success" 
          size="small" 
          link
          @click="handleResume(item)"
        >
          恢复
        </el-button>
      </div>
      <div class="paused-reason">{{ item.reason }}</div>
      <div class="paused-meta">
        <span>影响: {{ item.affectedPlots }} 个地块</span>
        <span>{{ formatTime(item.createdAt) }}</span>
      </div>
    </div>
  </div>
</div>
```

---

## 🗺️ 地图区域设计

### 1. 图层控制面板（右上角）
```vue
<div class="map-controls">
  <el-card class="layer-control">
    <h4>图层控制</h4>
    <div class="layer-item">
      <el-checkbox v-model="layers.plots">
        <span class="layer-label">
          <span class="layer-color" style="background: #409EFF"></span>
          地块
        </span>
      </el-checkbox>
      <span class="layer-count">{{ allPlots.length }}</span>
    </div>
    <div class="layer-item">
      <el-checkbox v-model="layers.adminRegions">
        <span class="layer-label">
          <span class="layer-color" style="background: #67C23A"></span>
          行政区
        </span>
      </el-checkbox>
      <span class="layer-count">{{ adminRegions.length }}</span>
    </div>
    <div class="layer-item">
      <el-checkbox v-model="layers.pausedRegions">
        <span class="layer-label">
          <span class="layer-color" style="background: #F56C6C"></span>
          暂停区域
        </span>
      </el-checkbox>
      <span class="layer-count">{{ pausedRegions.length }}</span>
    </div>
  </el-card>
</div>
```

### 2. 地图图层

#### 图层1：地块图层
- **颜色：** 
  - 监测中：蓝色 (#409EFF)
  - 已暂停：灰色 (#909399)
- **透明度：** 0.3
- **边框：** 1px，透明度 0.6
- **点击事件：** 显示地块详情弹窗

#### 图层2：行政区边界图层
- **颜色：** 绿色 (#67C23A)
- **透明度：** 0.2
- **边框：** 2px，虚线
- **点击事件：** 显示行政区统计弹窗

#### 图层3：暂停区域高亮图层
- **颜色：** 红色 (#F56C6C)
- **透明度：** 0.4
- **边框：** 2px，实线
- **闪烁效果：** 动画提示

### 3. 弹窗设计

#### 地块弹窗
```html
<div class="plot-popup">
  <h4>{{ plot.plotName }}</h4>
  <div class="popup-info">
    <div class="info-row">
      <span>行政区：</span>
      <span>{{ plot.province }} / {{ plot.city }} / {{ plot.district }}</span>
    </div>
    <div class="info-row">
      <span>作物类型：</span>
      <span>{{ getCropTypeName(plot.cropType) }}</span>
    </div>
    <div class="info-row">
      <span>监测状态：</span>
      <el-tag :type="plot.monitorStatus === 1 ? 'success' : 'info'">
        {{ plot.monitorStatus === 1 ? '监测中' : '已暂停' }}
      </el-tag>
    </div>
  </div>
  <div class="popup-actions">
    <el-button size="small" @click="togglePlotStatus(plot)">
      {{ plot.monitorStatus === 1 ? '暂停监测' : '恢复监测' }}
    </el-button>
  </div>
</div>
```

#### 行政区弹窗
```html
<div class="region-popup">
  <h4>{{ region.name }}</h4>
  <div class="popup-stats">
    <div class="stat-item">
      <span class="label">代码：</span>
      <span class="value">{{ region.adcode }}</span>
    </div>
    <div class="stat-item">
      <span class="label">总地块：</span>
      <span class="value">{{ region.totalPlots }}</span>
    </div>
    <div class="stat-item">
      <span class="label">监测中：</span>
      <span class="value active">{{ region.activePlots }}</span>
    </div>
    <div class="stat-item">
      <span class="label">已暂停：</span>
      <span class="value paused">{{ region.pausedPlots }}</span>
    </div>
  </div>
  <div class="popup-actions">
    <el-button type="danger" size="small" @click="pauseRegion(region)">
      暂停该区域
    </el-button>
  </div>
</div>
```

---

## 🎯 核心功能

### 1. 数据加载
```javascript
// 加载所有地块
async function loadAllPlots() {
  const response = await listPlot({ pageNum: 1, pageSize: 10000 })
  allPlots.value = response.result.rows
  renderPlots(allPlots.value)
}

// 加载行政区数据
async function loadAdminRegions() {
  const response = await getAdminRegions({ level: regionLevel.value })
  adminRegions.value = response.result.rows
  renderAdminRegions(adminRegions.value)
}

// 加载暂停列表
async function loadPausedRegions() {
  const response = await getPausedRegions()
  pausedList.value = response.result.rows
  renderPausedRegions(pausedList.value)
}
```

### 2. 地图渲染
```javascript
// 渲染地块
function renderPlots(plots) {
  const features = plots.map(plot => ({
    type: 'Feature',
    properties: {
      id: plot.plotId,
      name: plot.plotName,
      status: plot.monitorStatus,
      ...plot
    },
    geometry: JSON.parse(plot.geometry)
  }))

  plotLayer.value = new PolygonLayer()
    .source({ type: 'FeatureCollection', features })
    .color('status', status => status === 1 ? '#409EFF' : '#909399')
    .shape('fill')
    .style({ opacity: 0.3 })

  scene.value.addLayer(plotLayer.value)
}

// 渲染行政区
function renderAdminRegions(regions) {
  const features = regions.map(region => ({
    type: 'Feature',
    properties: { ...region },
    geometry: region.geometry
  }))

  adminLayer.value = new LineLayer()
    .source({ type: 'FeatureCollection', features })
    .color('#67C23A')
    .size(2)
    .style({ 
      opacity: 0.6,
      lineType: 'dash',
      dashArray: [5, 5]
    })

  scene.value.addLayer(adminLayer.value)
}
```

### 3. 交互功能
```javascript
// 定位到地块
function locatePlot(plot) {
  const geometry = JSON.parse(plot.geometry)
  const bounds = calculateBounds(geometry)
  scene.value.fitBounds(bounds)
  
  // 高亮显示
  highlightFeature(plot.plotId)
}

// 暂停行政区
async function handlePause() {
  const response = await pauseRegion(pauseForm)
  if (response.isSuccess) {
    ElMessage.success(`已暂停 ${pauseForm.adcode}`)
    loadPausedRegions()
    loadAllPlots() // 刷新地块状态
  }
}

// 恢复行政区
async function handleResume(item) {
  const response = await resumeRegion(item.adcode)
  if (response.isSuccess) {
    ElMessage.success(`已恢复 ${item.adcode}`)
    loadPausedRegions()
    loadAllPlots()
  }
}
```

---

## 🎨 样式设计

### 配色方案
- **主色调：** #2563eb (蓝色)
- **成功色：** #67C23A (绿色)
- **警告色：** #E6A23C (橙色)
- **危险色：** #F56C6C (红色)
- **信息色：** #909399 (灰色)

### 玻璃态效果
```scss
.glass-effect {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}
```

---

## 📊 数据结构

### 地块数据
```typescript
interface Plot {
  plotId: number
  plotName: string
  geometry: string // GeoJSON
  province: string
  city: string
  district: string
  adcode: string
  cropType: string
  monitorStatus: 0 | 1
  autoUpdate: boolean
  monitorStartDate: string
  monitorEndDate: string
}
```

### 行政区数据
```typescript
interface AdminRegion {
  adcode: string
  name: string
  level: 'province' | 'city' | 'district'
  geometry: GeoJSON
  totalPlots: number
  activePlots: number
  pausedPlots: number
}
```

### 暂停记录
```typescript
interface PausedRegion {
  adcode: string
  reason: string
  affectedPlots: number
  createdBy: string
  createdAt: string
}
```

---

## 🚀 实施步骤

1. **创建页面文件** - `src/views/gee/stop/index.vue`
2. **创建API接口** - 复用已有的 region API
3. **实现地图初始化** - 参考 optimization 页面
4. **实现图层渲染** - 地块、行政区、暂停区域
5. **实现交互功能** - 点击、定位、暂停、恢复
6. **添加路由配置** - 注册到路由表
7. **测试功能** - 确保所有功能正常

---

**设计完成！** 这个方案提供了完整的地图可视化行政区管控功能，界面美观、交互流畅、功能强大。
