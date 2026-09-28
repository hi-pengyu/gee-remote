<template>
  <div class="regions-container">
    <!-- 左侧面板 -->
    <div class="left-sidebar glass-effect">
      <!-- 列表模式 -->
      <div v-if="mode === 'list'" class="list-panel">
        <div class="panel-header">
          <div class="title">区域管理</div>
          <el-button type="primary" size="small" icon="Plus" @click="handleAdd">新增区域</el-button>
        </div>
        
        <!-- 搜索栏 -->
        <div class="search-box">
          <el-input
            v-model="queryParams.regionName"
            placeholder="搜索区域名称"
            prefix-icon="Search"
            clearable
            @input="handleQuery"
          />
        </div>

        <!-- 区域列表 -->
        <div class="region-list" v-loading="loading">
          <div 
            v-for="item in regionList" 
            :key="item.regionId" 
            class="region-card card-container"
            :class="{ active: currentRegion?.regionId === item.regionId }"
            @click="handleSelectRegion(item)"
          >
            <div class="card-header">
              <span class="region-name">{{ item.regionName }}</span>
              <el-tag :type="item.isActive ? 'success' : 'info'" size="small" effect="light">
                {{ item.isActive ? '启用' : '禁用' }}
              </el-tag>
            </div>
            <div class="card-content">
              <div class="info-item">
                <span class="label">缓冲区:</span>
                <span class="value">{{ item.bufferKm }} km</span>
              </div>
              <div class="info-item">
                <span class="label">优先级:</span>
                <span class="value">{{ item.priority }}</span>
              </div>
            </div>
            <div class="card-actions">
              <el-button link type="primary" size="small" @click.stop="handleUpdate(item)">编辑</el-button>
              <el-button link type="danger" size="small" @click.stop="handleDelete(item)">删除</el-button>
            </div>
          </div>
          
          <!-- 空状态 -->
          <el-empty v-if="regionList.length === 0" description="暂无区域数据" :image-size="60" />
        </div>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="queryParams.pageNum"
            v-model:page-size="queryParams.pageSize"
            :total="total"
            :pager-count="5"
            layout="prev, pager, next"
            @current-change="getList"
            small
          />
        </div>
      </div>

      <!-- 表单模式 -->
      <div v-else class="form-panel">
        <div class="panel-header">
          <div class="title">{{ form.regionId ? '编辑区域' : '新增区域' }}</div>
          <el-button link @click="cancel">返回</el-button>
        </div>
        
        <div class="form-content">
          <el-alert
            title="请在地图上绘制区域"
            type="info"
            description="点击地图开始绘制多边形，双击结束绘制"
            show-icon
            :closable="false"
            class="mb16"
          />
          
          <el-form ref="formRef" :model="form" :rules="rules" label-position="top" size="default">
            <el-form-item label="区域名称" prop="regionName">
              <el-input v-model="form.regionName" placeholder="请输入区域名称" />
            </el-form-item>
            
            <el-form-item label="缓冲区(km)" prop="bufferKm">
              <el-input-number v-model="form.bufferKm" :min="0" :max="100" :step="0.5" style="width: 100%" />
            </el-form-item>
            
            <el-form-item label="优先级" prop="priority">
              <el-input-number v-model="form.priority" :min="0" :max="100" style="width: 100%" />
            </el-form-item>
            
            <el-form-item label="状态" prop="isActive">
              <el-switch v-model="form.isActive" active-text="启用" inactive-text="禁用" />
            </el-form-item>
            
            <el-form-item label="描述" prop="description">
              <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入描述" />
            </el-form-item>
            
            <el-form-item label="几何数据(自动生成)" prop="geometry">
              <el-input 
                v-model="form.geometry" 
                type="textarea" 
                :rows="3" 
                readonly 
                placeholder="在地图上绘制后自动生成"
                class="geometry-input"
              />
            </el-form-item>
            
            <div class="form-actions">
              <el-button @click="cancel" style="flex: 1">取消</el-button>
              <el-button type="primary" @click="submitForm" :loading="submitting" style="flex: 1">保存</el-button>
            </div>
          </el-form>
        </div>
      </div>
    </div>

    <!-- 右侧地图 -->
    <div class="map-wrapper">
      <div :id="mapId" class="map-view"></div>
      
      <!-- 地图工具栏 -->
      <div class="map-tools card-container" v-if="mode === 'form'">
        <el-button-group>
          <el-button type="primary" :icon="Edit" @click="startDraw" :disabled="isDrawing">重新绘制</el-button>
          <el-button type="warning" :icon="Delete" @click="clearDraw">清除</el-button>
        </el-button-group>
      </div>
    </div>
  </div>
</template>

<script setup name="GEERegions">
import { ref, reactive, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Edit, Delete, Search, Plus } from '@element-plus/icons-vue'
import { Scene, PolygonLayer, LineLayer, Popup } from '@antv/l7'
import { GaodeMap } from '@antv/l7-maps'
import { listRegions, getRegion, createRegion, updateRegion, delRegion } from '@/api/gee/regions'

const mapId = ref('region-map-' + Date.now())
const mode = ref('list') // list | form
const loading = ref(false)
const submitting = ref(false)
const regionList = ref([])
const total = ref(0)
const currentRegion = ref(null)
const isDrawing = ref(false)

// 地图相关
const scene = ref(null)
const polygonLayer = ref(null)
const lineLayer = ref(null)
const mouseTool = ref(null)
const mapInstance = ref(null)
const drawLayer = ref(null) // 用于显示当前绘制的图层

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  regionName: undefined,
  isActive: undefined
})

const form = ref({})
const formRef = ref(null)
const rules = {
  regionName: [{ required: true, message: '区域名称不能为空', trigger: 'blur' }],
  geometry: [{ required: true, message: '请在地图上绘制区域', trigger: 'change' }],
  bufferKm: [{ required: true, message: '缓冲区不能为空', trigger: 'blur' }]
}

onMounted(() => {
  nextTick(() => {
    initMap()
    getList()
  })
})

onUnmounted(() => {
  if (scene.value) scene.value.destroy()
  if (mouseTool.value) mouseTool.value.close()
})

// 初始化地图
function initMap() {
  scene.value = new Scene({
    id: mapId.value,
    map: new GaodeMap({
      center: [104.06, 30.67],
      pitch: 0,
      style: 'light',
      zoom: 5,
      token: '<REDACTED_AMAP_TOKEN>'
    }),
    logoVisible: false
  })

  scene.value.on('loaded', () => {
    mapInstance.value = scene.value.map
    const tileLayer = new AMap.TileLayer.Satellite()
    tileLayer.setMap(mapInstance.value)
    
    // 初始化鼠标工具
    mapInstance.value.plugin(['AMap.MouseTool'], function() {
      mouseTool.value = new AMap.MouseTool(mapInstance.value)
      
      mouseTool.value.on('draw', function(e) {
        console.log('绘制完成:', e)
        const path = e.obj.getPath()
        const coords = path.map(p => [p.lng, p.lat])
        // 闭合多边形
        if (coords.length > 0 && (coords[0][0] !== coords[coords.length-1][0] || coords[0][1] !== coords[coords.length-1][1])) {
          coords.push(coords[0])
        }
        
        const geojson = {
          type: 'Polygon',
          coordinates: [coords]
        }
        
        const geoStr = JSON.stringify(geojson)
        console.log('生成的GeoJSON:', geoStr)
        form.value.geometry = geoStr
        isDrawing.value = false
        
        // 手动触发验证
        if (formRef.value) {
          formRef.value.validateField('geometry', (isValid) => {
            console.log('几何数据验证结果:', isValid)
          })
        }
        
        // 绘制完成后保留覆盖物以便查看，但在提交或取消时清除
        drawLayer.value = e.obj
      })
    })
  })
}

// 渲染所有区域
function renderRegions(regions) {
  if (!scene.value || !regions) return

  if (polygonLayer.value) scene.value.removeLayer(polygonLayer.value)
  if (lineLayer.value) scene.value.removeLayer(lineLayer.value)
  
  if (regions.length === 0) return

  const features = regions.map(r => {
    try {
      const geo = typeof r.geometry === 'string' ? JSON.parse(r.geometry) : r.geometry
      return {
        type: 'Feature',
        properties: {
          id: r.regionId,
          name: r.regionName,
          isActive: r.isActive
        },
        geometry: geo
      }
    } catch (e) {
      console.error('解析几何数据失败:', e)
      return null
    }
  }).filter(f => f)

  const geoData = {
    type: 'FeatureCollection',
    features: features
  }

  polygonLayer.value = new PolygonLayer()
    .source(geoData)
    .color('isActive', (isActive) => isActive ? '#67C23A' : '#909399')
    .shape('fill')
    .style({ opacity: 0.4 })

  lineLayer.value = new LineLayer()
    .source(geoData)
    .color('#fff')
    .size(1)
    .style({ opacity: 0.8 })

  scene.value.addLayer(polygonLayer.value)
  scene.value.addLayer(lineLayer.value)
  
  // 点击事件
  polygonLayer.value.on('click', (e) => {
    if (mode.value === 'form') return // 编辑模式下不触发弹窗
    
    const { feature, lngLat } = e
    const popup = new Popup({ closeButton: true })
      .setLnglat(lngLat)
      .setHTML(`
        <div style="padding:5px;">
          <h4>${feature.properties.name}</h4>
          <p>状态: ${feature.properties.isActive ? '启用' : '禁用'}</p>
        </div>
      `)
    scene.value.addPopup(popup)
    
    // 选中列表项
    const region = regionList.value.find(r => r.regionId === feature.properties.id)
    if (region) handleSelectRegion(region)
  })
}

// 列表操作
function getList() {
  loading.value = true
  listRegions(queryParams).then(response => {
    console.log('获取区域列表响应:', response)
    const data = response.result || response
    regionList.value = data.rows || []
    total.value = data.total || 0
    loading.value = false
    renderRegions(regionList.value)
  }).catch(error => {
    console.error('获取区域列表失败:', error)
    loading.value = false
  })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function handleSelectRegion(item) {
  currentRegion.value = item
  // 定位地图
  try {
    const geo = typeof item.geometry === 'string' ? JSON.parse(item.geometry) : item.geometry
    if (geo && geo.coordinates && geo.coordinates.length > 0) {
      const coords = geo.coordinates[0]
      let minX = 180, minY = 90, maxX = -180, maxY = -90
      coords.forEach(p => {
        const [x, y] = p
        if (x < minX) minX = x
        if (y < minY) minY = y
        if (x > maxX) maxX = x
        if (y > maxY) maxY = y
      })
      scene.value.fitBounds([[minX, minY], [maxX, maxY]])
    }
  } catch (e) {
    console.error('定位失败:', e)
  }
}

// 表单操作
function handleAdd() {
  reset()
  mode.value = 'form'
  startDraw()
}

function handleUpdate(row) {
  reset()
  mode.value = 'form'
  getRegion(row.regionId).then(response => {
    const data = response.result || response.data || response
    form.value = data
    // 如果有几何数据，显示在地图上（这里简单处理，先不显示编辑状态，只允许重绘）
    if (form.value.geometry) {
       // TODO: 可以实现将现有几何数据转换为可编辑的多边形
       handleSelectRegion(form.value)
    }
  })
}

function handleDelete(row) {
  ElMessageBox.confirm('确认删除该区域吗?', '警告', {
    type: 'warning'
  }).then(() => {
    return delRegion(row.regionId)
  }).then(() => {
    ElMessage.success('删除成功')
    getList()
  })
}

function submitForm() {
  formRef.value.validate(valid => {
    if (valid) {
      submitting.value = true
      const action = form.value.regionId ? updateRegion : createRegion
      action(form.value).then(() => {
        ElMessage.success(form.value.regionId ? '修改成功' : '新增成功')
        cancel()
        getList()
      }).finally(() => {
        submitting.value = false
      })
    }
  })
}

function cancel() {
  mode.value = 'list'
  clearDraw()
  if (mouseTool.value) mouseTool.value.close()
  reset()
  // 恢复显示所有区域
  renderRegions(regionList.value)
}

function reset() {
  form.value = {
    regionId: undefined,
    regionName: undefined,
    geometry: undefined,
    bufferKm: 5.0,
    priority: 0,
    isActive: true,
    description: undefined
  }
  currentRegion.value = null
}

// 绘制工具
function startDraw() {
  if (!mouseTool.value) return
  
  clearDraw()
  isDrawing.value = true
  mouseTool.value.polygon({
    strokeColor: "#FF33FF",
    strokeOpacity: 1,
    strokeWeight: 2,
    strokeOpacity: 0.8,
    fillColor: '#1791fc',
    fillOpacity: 0.4,
    strokeStyle: "solid"
  })
  ElMessage.info('请在地图上绘制区域，双击结束')
}

function clearDraw() {
  if (mouseTool.value) mouseTool.value.close(true) // true 清除覆盖物
  if (drawLayer.value) {
    mapInstance.value.remove(drawLayer.value)
    drawLayer.value = null
  }
  form.value.geometry = undefined
  isDrawing.value = false
}

</script>

<style scoped lang="scss">
.regions-container {
  display: flex;
  width: 100%;
  height: calc(100vh - 84px);
  overflow: hidden;
  background-color: #f8fafc;
}

.left-sidebar {
  width: 350px;
  min-width: 350px;
  height: 100%;
  background: #ffffff;
  border-right: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
  z-index: 10;
  box-shadow: 4px 0 16px rgba(0, 0, 0, 0.04);
}

.list-panel, .form-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.panel-header {
  padding: 20px;
  background: transparent;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .title {
    font-size: 18px;
    font-weight: 600;
    color: #1e293b;
  }
}

.search-box {
  padding: 16px;
  background: transparent;
  border-bottom: 1px solid #e2e8f0;
}

.region-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  
  &::-webkit-scrollbar {
    width: 5px;
  }
  &::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 3px;
  }
}

.region-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  border: 1px solid #e2e8f0;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    border-color: #cbd5e1;
  }
  
  &.active {
    border-color: #2563eb;
    background-color: #eff6ff;
    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.1);
  }
  
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    
    .region-name {
      font-weight: 600;
      font-size: 15px;
      color: #1e293b;
    }
  }
  
  .card-content {
    display: flex;
    gap: 16px;
    margin-bottom: 12px;
    
    .info-item {
      font-size: 13px;
      color: #64748b;
      
      .label {
        color: #94a3b8;
        margin-right: 6px;
      }
      
      .value {
        font-weight: 500;
      }
    }
  }
  
  .card-actions {
    display: flex;
    justify-content: flex-end;
    border-top: 1px solid #f1f5f9;
    padding-top: 12px;
  }
}

.pagination-wrapper {
  padding: 16px;
  background: transparent;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: center;
}

.form-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: transparent;
}

.mb16 {
  margin-bottom: 16px;
}

.geometry-input {
  :deep(.el-textarea__inner) {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    background-color: #f8fafc;
    color: #475569;
  }
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
  padding-bottom: 20px;
}

.map-wrapper {
  flex: 1;
  height: 100%;
  position: relative;
  background: #e2e8f0;
}

.map-view {
  width: 100%;
  height: 100%;
}

.map-tools {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 100;
  background: #fff;
  padding: 8px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
</style>
