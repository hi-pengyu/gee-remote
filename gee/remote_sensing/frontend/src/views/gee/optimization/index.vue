<template>
  <div class="optimization-container">
    <div class="left-sidebar glass-effect">
      <div class="sidebar-header">
        <h3>优化计算</h3>
        <p>配置参数与结果管理</p>
      </div>

      <!-- 模式切换 -->
      <div class="mode-selector">
        <el-radio-group v-model="mode" size="default">
          <el-radio-button value="manual">手动计算</el-radio-button>
          <el-radio-button value="history">历史记录</el-radio-button>
          <el-radio-button value="plots">地块列表</el-radio-button>
          <el-radio-button value="regions">预存区域</el-radio-button>
        </el-radio-group>
      </div>

      <!-- 手动计算模式 -->
      <div v-if="mode === 'manual'" class="sidebar-content">
        <div class="config-card card-container">
          <div class="card-header">
            <span>计算配置</span>
          </div>
          <el-form :model="optimizeForm" label-position="top" size="default">
            <el-form-item label="计算日期">
              <el-date-picker
                v-model="optimizeForm.calculationDate"
                type="date"
                placeholder="选择日期"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
            <el-form-item label="搜索窗口(天)">
              <el-input-number v-model="optimizeForm.windowDays" :min="1" :max="30" style="width: 100%" />
            </el-form-item>
            <el-form-item label="缓冲区(km)">
              <el-input-number v-model="optimizeForm.bufferKm" :min="0" :max="50" :step="0.5" style="width: 100%" />
            </el-form-item>
            <el-form-item label="包含自定义区域">
              <el-switch v-model="optimizeForm.includeCustomRegions" />
            </el-form-item>
            <el-form-item class="form-actions">
              <el-button type="primary" @click="handleCalculateAndSave" :loading="calculating" style="width: 100%">
                计算并保存
              </el-button>
              <el-button type="success" @click="handleTrigger" :loading="triggering" :disabled="!currentResult" style="width: 100%; margin-top: 10px; margin-left: 0;">
                触发下载
              </el-button>
              <el-button @click="resetForm" style="width: 100%; margin-top: 10px; margin-left: 0;">重置</el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>

      <!-- 历史记录模式 -->
      <div v-if="mode === 'history'" class="sidebar-content">
        <div class="history-card card-container">
          <div class="card-header">
            <span>历史记录</span>
          </div>
          <el-table 
            :data="historyList" 
            size="small" 
            max-height="400"
            highlight-current-row
            @row-click="handleSelectHistory"
            class="custom-table"
          >
            <el-table-column label="日期" prop="calculation_date" width="100" />
            <el-table-column label="区域数" prop="total_regions" width="70" align="center" />
            <el-table-column label="状态" width="80" align="center">
              <template #default="scope">
                <el-tag :type="getStatusType(scope.row.status)" size="small" effect="light">
                  {{ getStatusText(scope.row.status) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination
              v-model:current-page="historyQuery.pageNum"
              v-model:page-size="historyQuery.pageSize"
              :total="historyTotal"
              :page-sizes="[10, 20, 50]"
              layout="prev, pager, next"
              @size-change="loadHistory"
              @current-change="loadHistory"
              small
            />
          </div>
        </div>
      </div>

      <!-- 地块列表模式 -->
      <div v-if="mode === 'plots'" class="sidebar-content list-panel">
        <div class="search-box">
          <el-input v-model="searchQuery" placeholder="搜索地块名称" prefix-icon="Search" clearable />
        </div>
        <div class="item-list">
          <div 
            v-for="item in filteredPlots" 
            :key="item.plotId" 
            class="list-item"
            @click="locateItem(item)"
          >
            <div class="item-icon blue">
              <svg-icon icon-class="guide" />
            </div>
            <div class="item-info">
              <div class="item-name">{{ item.plotName }}</div>
              <div class="item-desc">ID: {{ item.plotId }}</div>
            </div>
          </div>
          <el-empty v-if="filteredPlots.length === 0" description="无数据" :image-size="40" />
        </div>
      </div>

      <!-- 预存区域列表模式 -->
      <div v-if="mode === 'regions'" class="sidebar-content list-panel">
        <div class="search-box">
          <el-input v-model="searchQuery" placeholder="搜索区域名称" prefix-icon="Search" clearable />
        </div>
        <div class="item-list">
          <div 
            v-for="item in filteredRegions" 
            :key="item.regionId" 
            class="list-item"
            @click="locateItem(item)"
          >
            <div class="item-icon green">
              <svg-icon icon-class="tree" />
            </div>
            <div class="item-info">
              <div class="item-name">{{ item.regionName }}</div>
              <div class="item-desc">缓冲区: {{ item.bufferKm }}km</div>
            </div>
          </div>
          <el-empty v-if="filteredRegions.length === 0" description="无数据" :image-size="40" />
        </div>
      </div>

      <!-- 当前选中的结果 -->
      <div v-if="currentResult" class="result-card card-container">
        <div class="card-header">
          <span>{{ currentResult.calculation_date || '当前' }} 的结果 ({{ currentResult.regions?.length || 0 }})</span>
        </div>
        <el-table :data="currentResult.regions" border size="small" max-height="300" class="custom-table">
          <el-table-column label="ID" prop="region_id" width="60" align="center" />
          <el-table-column label="面积(km²)" align="center" width="100">
            <template #default="scope">
              {{ scope.row.area_sq_km?.toFixed(2) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="70">
            <template #default="scope">
              <el-button type="primary" link size="small" @click="locateRegion(scope.row)">
                定位
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <!-- 右侧地图 -->
    <div class="map-wrapper">
      <div :id="mapId" class="map-view"></div>
    </div>
  </div>
</template>

<script setup name="GEEOptimization">
import { ref, reactive, onMounted, onUnmounted, nextTick, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { calculateAndSave, triggerBatchDownload, getOptimizationHistory, getOptimizationDetail } from '@/api/gee/optimization'
import { listPlot } from '@/api/gee/plot'
import { listRegions } from '@/api/gee/regions'
import { Scene, PolygonLayer, LineLayer, Popup } from '@antv/l7'
import { GaodeMap } from '@antv/l7-maps'

const mapId = ref('optimization-map-' + Date.now())
const mode = ref('manual')
const calculating = ref(false)
const triggering = ref(false)
const currentResult = ref(null)
const historyList = ref([])
const historyTotal = ref(0)
const scene = ref(null)
const polygonLayer = ref(null)
const lineLayer = ref(null)
const plotLayer = ref(null)
const plotLineLayer = ref(null)
const regionLayer = ref(null)
const regionLineLayer = ref(null)

const optimizeForm = reactive({
  calculationDate: new Date().toISOString().split('T')[0],
  windowDays: 7,
  bufferKm: 5.0,
  includeCustomRegions: true
})

const historyQuery = reactive({
  pageNum: 1,
  pageSize: 10
})

const allPlots = ref([])
const allRegions = ref([])
const searchQuery = ref('')

const filteredPlots = computed(() => {
  if (!searchQuery.value) return allPlots.value
  return allPlots.value.filter(p => p.plotName && p.plotName.toLowerCase().includes(searchQuery.value.toLowerCase()))
})

const filteredRegions = computed(() => {
  if (!searchQuery.value) return allRegions.value
  return allRegions.value.filter(r => r.regionName && r.regionName.toLowerCase().includes(searchQuery.value.toLowerCase()))
})

onMounted(() => {
  nextTick(() => {
    initMap()
    loadHistory()
  })
})

onUnmounted(() => {
  console.log('组件卸载，清理地图资源')
  if (polygonLayer.value) {
    scene.value?.removeLayer(polygonLayer.value)
    polygonLayer.value = null
  }
  if (lineLayer.value) {
    scene.value?.removeLayer(lineLayer.value)
    lineLayer.value = null
  }
  if (plotLayer.value) {
    scene.value?.removeLayer(plotLayer.value)
    plotLayer.value = null
  }
  if (plotLineLayer.value) {
    scene.value?.removeLayer(plotLineLayer.value)
    plotLineLayer.value = null
  }
  if (regionLayer.value) {
    scene.value?.removeLayer(regionLayer.value)
    regionLayer.value = null
  }
  if (regionLineLayer.value) {
    scene.value?.removeLayer(regionLineLayer.value)
    regionLineLayer.value = null
  }
  if (scene.value) {
    scene.value.destroy()
    scene.value = null
  }
})

function initMap() {
  console.log('初始化地图...')
  
  // 如果已存在 scene，先销毁
  if (scene.value) {
    console.log('销毁旧的地图实例')
    scene.value.destroy()
    scene.value = null
  }
  
  scene.value = new Scene({
    id: mapId.value,
    map: new GaodeMap({
      center: [104.06, 35.67],
      pitch: 0,
      style: 'light',
      zoom: 4,
      token: '<REDACTED_AMAP_TOKEN>'
    }),
    logoVisible: false
  })

  scene.value.on('loaded', () => {
    console.log('地图加载完成')
    const tileLayer = new AMap.TileLayer.Satellite()
    tileLayer.setMap(scene.value.map)
    
    // 地图加载完成后，加载所有地块和预存区域
    setTimeout(() => {
      loadAllPlots()
      loadAllRegions()
    }, 500)
  })
  
  scene.value.on('destroy', () => {
    console.log('地图已销毁')
  })
}

function locateItem(item) {
  console.log('定位项目:', item)
  try {
    let geo = typeof item.geometry === 'string' ? JSON.parse(item.geometry) : item.geometry
    console.log('解析后的几何:', geo)
    
    // 如果是数组，说明是坐标点数组，需要包装成 GeoJSON Polygon
    if (Array.isArray(geo)) {
      geo = {
        type: 'Polygon',
        coordinates: [geo]
      }
      console.log('包装后的几何:', geo)
    }
    
    if (geo && geo.coordinates && geo.coordinates.length > 0) {
      // 计算边界
      let minX = 180, minY = 90, maxX = -180, maxY = -90
      // 处理 Polygon 和 MultiPolygon
      const coords = geo.type === 'MultiPolygon' ? geo.coordinates.flat(2) : geo.coordinates.flat(1)
      
      console.log('坐标点数量:', coords.length)
      
      coords.forEach(p => {
        const [x, y] = p
        if (x < minX) minX = x
        if (y < minY) minY = y
        if (x > maxX) maxX = x
        if (y > maxY) maxY = y
      })
      
      console.log('边界:', { minX, minY, maxX, maxY })
      
      // 稍微扩大边界以获得更好的视野
      const padding = 0.1
      scene.value.fitBounds([[minX - padding, minY - padding], [maxX + padding, maxY + padding]])
      
      // 添加弹窗
      const center = [(minX + maxX) / 2, (minY + maxY) / 2]
      const popup = new Popup({ closeButton: true })
        .setLnglat(center)
        .setHTML(`<div style="padding:8px;"><h4>${item.plotName || item.regionName}</h4></div>`)
      scene.value.addPopup(popup)
      
      console.log('定位完成')
    } else {
      console.warn('无效的几何数据')
    }
  } catch (e) {
    console.error('定位失败:', e)
  }
}

// 加载所有地块
function loadAllPlots() {
  console.log('开始加载地块...')
  listPlot({ pageNum: 1, pageSize: 1000 }).then(response => {
    console.log('地块API响应:', response)
    const data = response.result || response
    console.log('解析后的data:', data)
    const plots = data.rows || []
    console.log('地块数量:', plots.length)
    allPlots.value = plots
    if (plots.length > 0) {
      renderPlots(plots)
    } else {
      console.warn('没有地块数据')
    }
  }).catch(error => {
    console.error('加载地块失败:', error)
  })
}

// 加载所有预存区域
function loadAllRegions() {
  console.log('开始加载预存区域...')
  listRegions({ pageNum: 1, pageSize: 1000, isActive: true }).then(response => {
    console.log('预存区域API响应:', response)
    const data = response.result || response
    console.log('解析后的data:', data)
    const regions = data.rows || []
    console.log('预存区域数量:', regions.length)
    allRegions.value = regions
    if (regions.length > 0) {
      renderCustomRegions(regions)
    } else {
      console.warn('没有预存区域数据')
    }
  }).catch(error => {
    console.error('加载预存区域失败:', error)
  })
}

// 渲染地块
function renderPlots(plots) {
  console.log('开始渲染地块:', plots.length, '个')
  if (!scene.value || !plots || plots.length === 0) {
    console.warn('无法渲染地块: scene=', !!scene.value, 'plots=', plots?.length)
    return
  }
  
  if (plotLayer.value) scene.value.removeLayer(plotLayer.value)
  if (plotLineLayer.value) scene.value.removeLayer(plotLineLayer.value)
  
  const features = plots.map((plot, index) => {
    try {
      let geo = typeof plot.geometry === 'string' ? JSON.parse(plot.geometry) : plot.geometry
      
      // 如果是数组，说明是坐标点数组，需要包装成 GeoJSON Polygon
      if (Array.isArray(geo)) {
        geo = {
          type: 'Polygon',
          coordinates: [geo]
        }
      }
      
      return {
        type: 'Feature',
        properties: {
          id: plot.plotId,
          name: plot.plotName,
          type: 'plot'
        },
        geometry: geo
      }
    } catch (e) {
      console.error('解析地块几何数据失败:', e, plot)
      return null
    }
  }).filter(f => f)
  
  if (features.length === 0) {
    console.error('没有有效的地块特征数据')
    return
  }
  
  console.log('有效地块特征数量:', features.length)
  console.log('首个特征:', features[0])
  
  const geoData = { type: 'FeatureCollection', features }
  
  plotLayer.value = new PolygonLayer()
    .source(geoData)
    .color('#409EFF')
    .shape('fill')
    .style({ opacity: 0.3 })
  
  plotLineLayer.value = new LineLayer()
    .source(geoData)
    .color('#409EFF')
    .size(1)
    .style({ opacity: 0.6 })
  
  scene.value.addLayer(plotLayer.value)
  scene.value.addLayer(plotLineLayer.value)
  
  console.log('地块图层已添加到地图')
  
  plotLayer.value.on('click', (e) => {
    const { feature, lngLat } = e
    const popup = new Popup({ closeButton: true })
      .setLnglat(lngLat)
      .setHTML(`<div style="padding:8px;"><h4>地块: ${feature.properties.name}</h4></div>`)
    scene.value.addPopup(popup)
  })
}

// 渲染预存区域
function renderCustomRegions(regions) {
  console.log('开始渲染预存区域:', regions.length, '个')
  if (!scene.value || !regions || regions.length === 0) {
    console.warn('无法渲染预存区域: scene=', !!scene.value, 'regions=', regions?.length)
    return
  }
  
  if (regionLayer.value) scene.value.removeLayer(regionLayer.value)
  if (regionLineLayer.value) scene.value.removeLayer(regionLineLayer.value)
  
  const features = regions.map(region => {
    try {
      const geo = typeof region.geometry === 'string' ? JSON.parse(region.geometry) : region.geometry
      return {
        type: 'Feature',
        properties: {
          id: region.regionId,
          name: region.regionName,
          type: 'custom_region'
        },
        geometry: geo
      }
    } catch (e) {
      console.error('解析预存区域几何数据失败:', e)
      return null
    }
  }).filter(f => f)
  
  if (features.length === 0) return
  
  const geoData = { type: 'FeatureCollection', features }
  
  regionLayer.value = new PolygonLayer()
    .source(geoData)
    .color('#67C23A')
    .shape('fill')
    .style({ opacity: 0.3 })
  
  regionLineLayer.value = new LineLayer()
    .source(geoData)
    .color('#67C23A')
    .size(1)
    .style({ opacity: 0.6 })
  
  scene.value.addLayer(regionLayer.value)
  scene.value.addLayer(regionLineLayer.value)
  
  regionLayer.value.on('click', (e) => {
    const { feature, lngLat } = e
    const popup = new Popup({ closeButton: true })
      .setLnglat(lngLat)
      .setHTML(`<div style="padding:8px;"><h4>预存区域: ${feature.properties.name}</h4></div>`)
    scene.value.addPopup(popup)
  })
}

function renderOptimizedRegions(regions) {
  if (!scene.value || !regions || regions.length === 0) return

  if (polygonLayer.value) scene.value.removeLayer(polygonLayer.value)
  if (lineLayer.value) scene.value.removeLayer(lineLayer.value)

  const features = regions.map((region) => ({
    type: 'Feature',
    properties: {
      id: region.region_id,
      area: region.area_sq_km
    },
    geometry: {
      type: 'Polygon',
      coordinates: [region.aoi_coords]
    }
  }))

  const geoData = {
    type: 'FeatureCollection',
    features: features
  }

  polygonLayer.value = new PolygonLayer()
    .source(geoData)
    .color('id', ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4', '#fed9a6'])
    .shape('fill')
    .style({ opacity: 0.6 })

  lineLayer.value = new LineLayer()
    .source(geoData)
    .color('#fff')
    .size(2)

  scene.value.addLayer(polygonLayer.value)
  scene.value.addLayer(lineLayer.value)

  polygonLayer.value.on('click', (e) => {
    const { feature, lngLat } = e
    const popup = new Popup({ closeButton: true })
      .setLnglat(lngLat)
      .setHTML(`<div style="padding:8px;"><h4>区域 #${feature.properties.id}</h4><p>面积: ${feature.properties.area.toFixed(2)} km²</p></div>`)
    scene.value.addPopup(popup)
  })
  
  if (regions.length > 0) {
    let minX = 180, minY = 90, maxX = -180, maxY = -90
    regions.forEach(r => {
      const [rMinX, rMinY, rMaxX, rMaxY] = r.bounds
      if (rMinX < minX) minX = rMinX
      if (rMinY < minY) minY = rMinY
      if (rMaxX > maxX) maxX = rMaxX
      if (rMaxY > maxY) maxY = rMaxY
    })
    scene.value.fitBounds([[minX, minY], [maxX, maxY]])
  }
}

function locateRegion(row) {
  if (!scene.value || !row || !row.bounds) return
  const [minX, minY, maxX, maxY] = row.bounds
  scene.value.fitBounds([[minX, minY], [maxX, maxY]])
}

async function handleCalculateAndSave() {
  calculating.value = true
  try {
    const response = await calculateAndSave(optimizeForm)
    if (response.is_success || response.success) {
      const data = response.result || response.data
      currentResult.value = {
        calculation_date: optimizeForm.calculationDate,
        regions: data.regions
      }
      ElMessage.success('计算完成并已保存')
      renderOptimizedRegions(data.regions)
      loadHistory()
    } else {
      ElMessage.error(response.message || '计算失败')
    }
  } catch (error) {
    ElMessage.error('计算失败: ' + error.message)
  } finally {
    calculating.value = false
  }
}

async function loadHistory() {
  try {
    const response = await getOptimizationHistory(historyQuery)
    if (response.is_success || response.success) {
      const data = response.result || response.data
      historyList.value = data.rows || []
      historyTotal.value = data.total || 0
    }
  } catch (error) {
    console.error('加载历史记录失败:', error)
  }
}

async function handleSelectHistory(row) {
  try {
    const response = await getOptimizationDetail(row.id)
    if (response.is_success || response.success) {
      const data = response.result || response.data
      currentResult.value = {
        calculation_date: data.calculation_date,
        regions: data.regions_data
      }
      renderOptimizedRegions(data.regions_data)
    }
  } catch (error) {
    ElMessage.error('加载详情失败: ' + error.message)
  }
}

async function handleTrigger() {
  if (!currentResult.value || !currentResult.value.regions) {
    ElMessage.warning('请先计算优化区域')
    return
  }
  
  triggering.value = true
  try {
    const response = await triggerBatchDownload({
      ...optimizeForm,
      targetDate: optimizeForm.calculationDate
    })
    if (response.success || response.is_success) {
      ElMessage.success('下载任务已提交')
    } else {
      ElMessage.error(response.message || '提交失败')
    }
  } catch (error) {
    ElMessage.error('提交失败: ' + error.message)
  } finally {
    triggering.value = false
  }
}

function resetForm() {
  optimizeForm.calculationDate = new Date().toISOString().split('T')[0]
  optimizeForm.windowDays = 7
  optimizeForm.bufferKm = 5.0
  optimizeForm.includeCustomRegions = true
  currentResult.value = null
  
  if (polygonLayer.value) scene.value.removeLayer(polygonLayer.value)
  if (lineLayer.value) scene.value.removeLayer(lineLayer.value)
}

function getStatusType(status) {
  const types = {
    'calculated': 'success',
    'downloading': 'warning',
    'downloaded': 'info',
    'failed': 'danger'
  }
  return types[status] || 'info'
}

function getStatusText(status) {
  const texts = {
    'calculated': '已计算',
    'downloading': '下载中',
    'downloaded': '已下载',
    'failed': '失败'
  }
  return texts[status] || status
}
</script>

<style scoped lang="scss">
.optimization-container {
  display: flex;
  width: 100%;
  height: calc(100vh - 84px);
  overflow: hidden;
  background-color: #f8fafc;
}

.left-sidebar {
  width: 320px;
  min-width: 320px;
  height: 100%;
  padding: 20px;
  background: #ffffff;
  overflow-y: auto;
  border-right: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
  z-index: 10;
  box-shadow: 4px 0 16px rgba(0, 0, 0, 0.04);
  
  &::-webkit-scrollbar {
    width: 5px;
  }
  
  &::-webkit-scrollbar-track {
    background: transparent;
  }
  
  &::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 3px;
    
    &:hover {
      background: rgba(0, 0, 0, 0.3);
    }
  }
}

.sidebar-header {
  margin-bottom: 24px;
  
  h3 {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
    color: #1e293b;
  }
  
  p {
    margin: 4px 0 0;
    font-size: 13px;
    color: #64748b;
  }
}

.mode-selector {
  margin-bottom: 20px;
  
  :deep(.el-radio-group) {
    width: 100%;
    display: flex;
    background-color: #f1f5f9;
    padding: 4px;
    border-radius: 8px;
  }
  
  :deep(.el-radio-button) {
    flex: 1;
    
    .el-radio-button__inner {
      width: 100%;
      padding: 8px 0;
      font-size: 13px;
      border: none;
      background: transparent;
      border-radius: 6px;
      color: #64748b;
    }
    
    &.is-active .el-radio-button__inner {
      background: #ffffff;
      color: #2563eb;
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
    }
  }
}

.sidebar-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-container {
  background: #ffffff;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  padding: 16px;
  
  .card-header {
    margin-bottom: 16px;
    font-weight: 600;
    font-size: 14px;
    color: #1e293b;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.list-panel {
  .search-box {
    margin-bottom: 16px;
  }
  
  .item-list {
    flex: 1;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .list-item {
    display: flex;
    align-items: center;
    padding: 12px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
      background: #f1f5f9;
      border-color: #cbd5e1;
      transform: translateY(-1px);
    }
    
    .item-icon {
      width: 36px;
      height: 36px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 12px;
      font-size: 18px;
      
      &.blue {
        background: rgba(37, 99, 235, 0.1);
        color: #2563eb;
      }
      
      &.green {
        background: rgba(16, 185, 129, 0.1);
        color: #10b981;
      }
    }
    
    .item-info {
      flex: 1;
      overflow: hidden;
      
      .item-name {
        font-size: 14px;
        font-weight: 500;
        color: #1e293b;
        margin-bottom: 2px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      
      .item-desc {
        font-size: 12px;
        color: #64748b;
      }
    }
  }
}

.map-wrapper {
  flex: 1;
  position: relative;
  background: #e2e8f0;
  
  .map-view {
    width: 100%;
    height: 100%;
  }
}

.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: center;
}

.custom-table {
  :deep(th.el-table__cell) {
    background-color: #f8fafc !important;
    color: #475569;
    font-weight: 600;
  }
}
</style>
