# 后台管理系统 - 快速启动指南

## 方案选择

### 方案一: 使用现成模板 (推荐,最快)

#### Vue + Element Plus

```bash
# 1. 克隆模板
git clone https://github.com/PanJiaChen/vue-element-admin.git gee-admin
cd gee-admin

# 2. 安装依赖
npm install

# 3. 启动开发服务器
npm run dev

# 访问: http://localhost:9527
```

**优势**:
- ✅ 开箱即用
- ✅ 组件丰富
- ✅ 文档完善
- ✅ 1小时内可以看到效果

#### React + Ant Design

```bash
# 使用Ant Design Pro
npm create umi gee-admin
cd gee-admin
npm install
npm start

# 访问: http://localhost:8000
```

### 方案二: 从零开始 (灵活,需要时间)

#### 创建Vue项目

```bash
# 1. 创建项目
npm create vite@latest gee-admin -- --template vue
cd gee-admin

# 2. 安装依赖
npm install
npm install element-plus
npm install echarts
npm install axios

# 3. 启动
npm run dev
```

---

## 最小可行产品 (MVP)

### 第一版功能清单

**必须有**:
1. ✅ 登录页面
2. ✅ 仪表盘 (核心指标)
3. ✅ 缓存列表
4. ✅ 任务列表

**可以没有**:
- ❌ 用户管理
- ❌ 权限控制
- ❌ 复杂图表
- ❌ 告警系统

### 页面结构

```
gee-admin/
├── src/
│   ├── views/
│   │   ├── Dashboard.vue      # 仪表盘
│   │   ├── CacheList.vue      # 缓存列表
│   │   ├── TaskList.vue       # 任务列表
│   │   └── Settings.vue       # 设置
│   ├── components/
│   │   ├── StatCard.vue       # 统计卡片
│   │   ├── TrendChart.vue     # 趋势图表
│   │   └── TaskStatus.vue     # 任务状态
│   ├── api/
│   │   └── index.js           # API调用
│   └── router/
│       └── index.js           # 路由配置
```

---

## 快速实现示例

### 1. 仪表盘组件

```vue
<template>
  <div class="dashboard">
    <h1>GEE缓存管理系统</h1>
    
    <!-- 核心指标 -->
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-value">{{ stats.totalTiles }}</div>
            <div class="stat-label">缓存瓦片</div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-value">{{ stats.hitRate }}%</div>
            <div class="stat-label">缓存命中率</div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-value">{{ stats.todayTasks }}</div>
            <div class="stat-label">今日任务</div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-value">{{ stats.cacheSize }} GB</div>
            <div class="stat-label">缓存大小</div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 图表 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card title="缓存命中率趋势">
          <div ref="hitRateChart" style="height: 300px;"></div>
        </el-card>
      </el-col>
      
      <el-col :span="12">
        <el-card title="任务执行统计">
          <div ref="taskChart" style="height: 300px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { getCacheStats } from '@/api'

const stats = ref({
  totalTiles: 0,
  hitRate: 0,
  todayTasks: 0,
  cacheSize: 0
})

const hitRateChart = ref(null)
const taskChart = ref(null)

onMounted(async () => {
  // 获取统计数据
  const data = await getCacheStats()
  stats.value = {
    totalTiles: data.total_tiles,
    hitRate: (data.cache_hit_rate * 100).toFixed(1),
    todayTasks: data.today_tasks || 0,
    cacheSize: data.actual_size_gb.toFixed(1)
  }
  
  // 初始化图表
  initCharts()
})

function initCharts() {
  // 缓存命中率趋势图
  const hitChart = echarts.init(hitRateChart.value)
  hitChart.setOption({
    xAxis: { type: 'category', data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'] },
    yAxis: { type: 'value', max: 100 },
    series: [{
      data: [75, 82, 88, 85, 90, 87, 92],
      type: 'line',
      smooth: true,
      itemStyle: { color: '#1890ff' }
    }]
  })
  
  // 任务统计图
  const taskChartInstance = echarts.init(taskChart.value)
  taskChartInstance.setOption({
    xAxis: { type: 'category', data: ['0时', '4时', '8时', '12时', '16时', '20时'] },
    yAxis: { type: 'value' },
    series: [{
      data: [12, 8, 45, 67, 89, 34],
      type: 'bar',
      itemStyle: { color: '#52c41a' }
    }]
  })
}
</script>

<style scoped>
.stat-card {
  text-align: center;
  padding: 20px;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #1890ff;
}

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 8px;
}
</style>
```

### 2. API调用

```javascript
// src/api/index.js
import axios from 'axios'

const API_BASE = 'http://localhost:8000/api/v1'

const api = axios.create({
  baseURL: API_BASE,
  timeout: 10000
})

// 获取缓存统计
export const getCacheStats = async () => {
  const res = await api.get('/cache/stats')
  return res.data.statistics
}

// 获取缓存列表
export const getCacheTiles = async (limit = 50) => {
  const res = await api.get('/cache/tiles', { params: { limit } })
  return res.data.tiles
}

// 获取任务列表
export const getTasks = async () => {
  // 需要新增API
  const res = await api.get('/tasks')
  return res.data.tasks
}

// 删除瓦片
export const deleteTile = async (tileId) => {
  await api.delete(`/cache/tiles/${tileId}`)
}

// 手动预取
export const prefetchTiles = async (tileId, targetDate) => {
  const res = await api.post('/cache/prefetch', null, {
    params: { tile_id: tileId, target_date: targetDate }
  })
  return res.data
}
```

### 3. 路由配置

```javascript
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '@/views/Dashboard.vue'
import CacheList from '@/views/CacheList.vue'
import TaskList from '@/views/TaskList.vue'
import Settings from '@/views/Settings.vue'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { title: '仪表盘' }
  },
  {
    path: '/cache',
    name: 'CacheList',
    component: CacheList,
    meta: { title: '缓存管理' }
  },
  {
    path: '/tasks',
    name: 'TaskList',
    component: TaskList,
    meta: { title: '任务管理' }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings,
    meta: { title: '系统设置' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
```

---

## 开发时间估算

### 使用模板 (推荐)

| 任务 | 时间 |
|------|------|
| 环境搭建 | 1小时 |
| 修改模板 | 2小时 |
| 对接API | 4小时 |
| 调试优化 | 3小时 |
| **总计** | **1-2天** |

### 从零开始

| 任务 | 时间 |
|------|------|
| 项目搭建 | 2小时 |
| 布局设计 | 4小时 |
| 页面开发 | 16小时 |
| API对接 | 4小时 |
| 调试优化 | 6小时 |
| **总计** | **4-5天** |

---

## 推荐方案

### 最快方案 (1天)

1. 使用 **vue-element-admin** 模板
2. 只做3个页面:
   - 仪表盘 (核心指标)
   - 缓存列表
   - 任务列表
3. 对接现有API
4. 简单美化

### 完整方案 (1-2周)

1. 使用模板作为基础
2. 实现所有6大模块
3. 添加图表和可视化
4. 完善交互和体验
5. 添加权限和用户管理

---

## 下一步

1. **确认需求**: 需要哪些功能?
2. **选择方案**: 使用模板还是从零开始?
3. **技术选型**: Vue还是React?
4. **开始开发**: 搭建环境,实现MVP

需要我帮你实现具体的页面吗?
