<template>
  <div class="fine-control-container">
    <div class="left-sidebar glass-effect">
      <div class="sidebar-header">
        <h3>精细化管控</h3>
        <p>地块与行政区可视化管理</p>
      </div>

      <!-- 模式切换 -->
      <div class="mode-selector">
        <el-radio-group v-model="mode" size="default">
          <el-radio-button value="control">管控操作</el-radio-button>
          <el-radio-button value="plots">地块列表</el-radio-button>
          <el-radio-button value="policies">策略列表</el-radio-button>
        </el-radio-group>
      </div>

      <!-- 模式内容项 -->
      <div class="sidebar-content">
        <!-- 管控操作模式 -->
        <div v-if="mode === 'control'" class="control-panel">
          <!-- 统计卡片 -->
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-label">总地块</div>
              <div class="stat-value">{{ totalPlots }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-label">监测中</div>
              <div class="stat-value active">{{ activePlotsCount }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-label">已暂停</div>
              <div class="stat-value paused">{{ pausedPlotsCount }}</div>
            </div>
          </div>

          <!-- 操作表单 -->
          <div class="action-card card-container">
            <div class="card-header">
              <span>新建管控策略</span>
            </div>
            <el-form :model="controlForm" label-position="top" size="default">
              <el-form-item label="策略类型">
                <el-select v-model="controlForm.policyType" @change="handlePolicyTypeChange" style="width: 100%">
                  <el-option label="行政区管控" value="admin_region" />
                  <el-option label="自定义区域" value="custom_region" />
                  <el-option label="单个地块" value="single_plot" />
                </el-select>
              </el-form-item>

              <el-form-item v-if="controlForm.policyType === 'admin_region'" label="行政区">
                <el-cascader
                  v-model="controlForm.adcode"
                  :props="cascaderProps"
                  placeholder="选择行政区（省->市->区）"
                  clearable
                  filterable
                  style="width: 100%"
                />
              </el-form-item>

              <el-form-item v-if="controlForm.policyType === 'custom_region'" label="区域选择">
                <el-button-group class="full-width">
                  <el-button type="primary" :plain="!isDrawing" @click="startDraw">
                    <el-icon><Edit /></el-icon> {{ isDrawing ? '绘图中...' : '手动划线' }}
                  </el-button>
                  <el-button v-if="controlForm.customGeometry" type="danger" plain @click="clearDraw">
                    <el-icon><Delete /></el-icon> 清除
                  </el-button>
                </el-button-group>
                <div v-if="controlForm.customGeometry" class="geometry-success">
                  <el-icon color="#67C23A"><CircleCheck /></el-icon> 区域已锁定
                </div>
              </el-form-item>

              <el-form-item v-if="controlForm.policyType === 'single_plot'" label="已选地块">
                <el-input v-model="selectedPlotName" placeholder="请在右侧地图点击选择地块" readonly />
              </el-form-item>

              <el-form-item label="作物类型">
                <el-select v-model="controlForm.cropCodes" multiple collapse-tags placeholder="选择作物（留空则全部）" style="width: 100%">
                  <el-option
                    v-for="item in cropTypes"
                    :key="item.cropCode"
                    :label="item.cropName"
                    :value="item.cropCode"
                  />
                </el-select>
              </el-form-item>

              <el-form-item label="管控动作">
                <el-radio-group v-model="controlForm.controlAction" class="full-width-radio">
                  <el-radio-button value="pause">暂停监测</el-radio-button>
                  <el-radio-button value="resume">恢复监测</el-radio-button>
                </el-radio-group>
              </el-form-item>

              <el-form-item label="策略名称">
                <el-input v-model="controlForm.policyName" placeholder="给这个决定起个名字" />
              </el-form-item>

              <el-form-item label="暂停/恢复原因">
                <el-input v-model="controlForm.reason" type="textarea" :rows="2" placeholder="请输入原因" />
              </el-form-item>

              <div class="form-footer">
                <el-button type="success" :loading="previewLoading" @click="handlePreview" style="flex: 1">影响预览</el-button>
                <el-button type="primary" :loading="submitLoading" :disabled="!canSubmit" @click="handleSubmit" style="flex: 1">确认提交</el-button>
              </div>
            </el-form>
          </div>

          <!-- 预览结果 -->
          <div v-if="previewData" class="preview-card card-container animate-fade-in">
            <div class="card-header highlight">
              <span>影响预览结果</span>
              <el-tag size="small" type="warning">预计覆盖</el-tag>
            </div>
            <div class="preview-stats">
              <div class="preview-main">覆盖地块：<span>{{ previewData.totalPlots }}</span> 个</div>
              <div v-if="previewData.cropStats && Object.keys(previewData.cropStats).length > 0" class="crop-breakdown">
                <div v-for="(stat, code) in previewData.cropStats" :key="code" class="crop-stat-line">
                  <span class="crop-name">{{ getCropName(code) }}:</span>
                  <span class="crop-count">{{ stat.total }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 地块列表模式 -->
        <div v-if="mode === 'plots'" class="list-panel">
          <div class="search-box">
            <el-input v-model="plotSearch" placeholder="搜索地块名称..." prefix-icon="Search" clearable />
          </div>
          <div class="item-list">
            <div 
              v-for="item in filteredPlots" 
              :key="item.plotId" 
              class="list-item"
              :class="{ 'paused': item.effectiveStatus === 0 }"
              @click="locatePlot(item)"
            >
              <div class="item-icon" :class="item.effectiveStatus === 1 ? 'blue' : 'gray'">
                <el-icon v-if="item.effectiveStatus === 1"><Aim /></el-icon>
                <el-icon v-else><CircleClose /></el-icon>
              </div>
              <div class="item-info">
                <div class="item-name">{{ item.plotName }}</div>
                <div class="item-desc">{{ item.province }} {{ item.city }}</div>
                <div class="item-tags">
                  <el-tag size="mini" :type="item.effectiveStatus === 1 ? 'success' : 'info'">
                    {{ item.effectiveStatus === 1 ? '活跃' : '被暂停' }}
                  </el-tag>
                  <el-tag v-if="item.cropType" size="mini" type="primary" effect="plain">{{ getCropName(item.cropType) }}</el-tag>
                </div>
              </div>
            </div>
            <el-empty v-if="filteredPlots.length === 0" description="未找到相关地块" :image-size="40" />
          </div>
        </div>

        <!-- 行政区域模式 -->


        <!-- 策略列表模式 -->
        <div v-if="mode === 'policies'" class="list-panel">
          <div class="item-list">
            <div 
              v-for="item in policies" 
              :key="item.policyId" 
              class="policy-list-item"
              :class="{ 'inactive': !item.isActive }"
            >
              <div class="policy-header">
                <div class="policy-type">
                  <el-tag size="small" :type="getPolicyTypeTag(item.policyType)">{{ getPolicyTypeLabel(item.policyType) }}</el-tag>
                </div>
                <div class="policy-actions">
                  <el-switch v-model="item.isActive" size="small" @change="togglePolicy(item)" />
                  <el-button link type="danger" icon="Delete" class="ml-1" @click="handleDeletePolicy(item)"></el-button>
                </div>
              </div>
              <div class="policy-body">
                <div class="policy-name">{{ item.policyName }}</div>
                <div class="policy-target">
                  <el-icon><InfoFilled /></el-icon>
                  <span>{{ getPolicyTargetDesc(item) }}</span>
                </div>
                <div class="policy-meta">
                  <span class="date">{{ formatTime(item.createdAt) }}</span>
                  <span class="action" :class="item.controlAction">行为: {{ item.controlAction === 'pause' ? '暂停' : '恢复' }}</span>
                </div>
              </div>
            </div>
            <el-empty v-if="policies.length === 0" description="暂无活动策略" :image-size="40" />
          </div>
        </div>
      </div>
    </div>

    <!-- 右侧地图 -->
    <div class="map-wrapper">
      <div :id="mapId" class="map-view"></div>
      
      <!-- 地图覆盖层：比例尺、图层切换等 -->
      <div class="map-overlays">
        <!-- 图层控制 -->
        <div class="overlay-card glass-effect">
          <div class="overlay-header">图层管理</div>
          <div class="overlay-body">
            <el-checkbox v-model="visibleLayers.plots" @change="updateLayersVisibility">地块图层</el-checkbox>
            <el-checkbox v-model="visibleLayers.regions" @change="updateLayersVisibility">区域边界</el-checkbox>
            <el-checkbox v-model="visibleLayers.satellite" @change="toggleMapType">卫星底图</el-checkbox>
          </div>
        </div>
      </div>

      <!-- 地图工具条 -->
      <div class="map-tools">
        <el-button-group vertical>
          <el-button circle icon="Plus" @click="mapZoomIn"></el-button>
          <el-button circle icon="Minus" @click="mapZoomOut"></el-button>
          <el-button circle icon="FullScreen" @click="resetView"></el-button>
        </el-button-group>
      </div>
    </div>

    <!-- 影响范围抽屉 -->
    <el-drawer
      v-model="impactDrawer"
      title="影响范围详情"
      direction="rtl"
      size="400px"
      append-to-body
    >
      <div class="impact-content">
        <div class="info-group">
          <div class="info-label">本次管控将影响以下地块：</div>
          <div class="impact-list">
            <div v-for="plot in previewData?.plots" :key="plot.plotId" class="impact-item">
              <span class="name">{{ plot.plotName }}</span>
              <el-tag size="mini">{{ getCropName(plot.cropType) }}</el-tag>
            </div>
            <div v-if="previewData?.totalPlots > 100" class="more-hint">还有 {{ previewData.totalPlots - 100 }} 个地块未列出...</div>
          </div>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup name="GeeFineControl">
import { ref, reactive, onMounted, onUnmounted, nextTick, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Aim, Location, Search, CircleClose, Edit, Delete, CircleCheck, 
  InfoFilled, Plus, Minus, FullScreen 
} from '@element-plus/icons-vue'
import { Scene, PolygonLayer, LineLayer, Popup } from '@antv/l7'
import { GaodeMap } from '@antv/l7-maps'

// API
import { listPlot } from '@/api/gee/plot'
import { getAdminRegions, getAdminRegionsWithStats, getAdminRegionDetail } from '@/api/gee/adminRegion'
import { getCropTypes } from '@/api/gee/cropType'
import { 
  createControlPolicy, previewImpact, getControlPolicies, 
  deleteControlPolicy, toggleControlPolicy, getPlotControlStatus 
} from '@/api/gee/fineControl'

// 基础变量
const mapId = ref('fine-control-map-' + Date.now())
const mode = ref('control')
const scene = ref(null)
const mapLoaded = ref(false)

// 数据源
const allPlots = ref([])
const adminRegions = ref([])
const cropTypes = ref([])
const policies = ref([])
const regionStats = ref([])

// 搜索和过滤
const plotSearch = ref('')
const regionLevel = ref('province')
const plotFilter = ref('all')

// 图层管理
const layers = reactive({
  plots: null,
  plotLines: null,
  regions: null,
  regionLines: null,
  highlight: null,
  draw: null
})

const visibleLayers = reactive({
  plots: true,
  regions: true,
  satellite: true
})

// 表单状态
const controlForm = reactive({
  policyName: '',
  policyType: 'admin_region',
  controlAction: 'pause',
  adcode: null,
  customGeometry: null,
  plotId: null,
  cropCodes: [],
  reason: '',
  priority: 10
})

const selectedPlot = ref(null)
const selectedPlotName = computed(() => selectedPlot.value ? selectedPlot.value.plotName : '')

// UI 状态
const isDrawing = ref(false)
const previewLoading = ref(false)
const submitLoading = ref(false)
const previewData = ref(null)
const impactDrawer = ref(false)

// ----------------- 计算属性 -----------------

const totalPlots = computed(() => allPlots.value.length)
const activePlotsCount = computed(() => allPlots.value.filter(p => p.effectiveStatus === 1).length)
const pausedPlotsCount = computed(() => allPlots.value.filter(p => p.effectiveStatus === 0).length)

const filteredPlots = computed(() => {
  let result = allPlots.value
  if (plotSearch.value) {
    result = result.filter(p => p.plotName && p.plotName.toLowerCase().includes(plotSearch.value.toLowerCase()))
  }
  return result
})

// 级联选择器配置 - 使用懒加载模式
const cascaderProps = {
  value: 'adcode',
  label: 'name',
  lazy: true,
  checkStrictly: true,
  emitPath: false,
  lazyLoad: async (node, resolve) => {
    try {
      const { level, value } = node
      let params = {}
      
      if (level === 0) {
        // 加载省级数据
        params.level = 'province'
      } else {
        // 加载子级数据（根据父级adcode）
        params.parentAdcode = value
      }
      
      const res = await getAdminRegionsWithStats(params)
      const nodes = (res.result?.rows || res.rows || []).map(item => ({
        adcode: item.adcode,
        name: item.name,
        level: item.level,
        // district级别没有子节点了
        leaf: item.level === 'district'
      }))
      
      resolve(nodes)
    } catch (error) {
      console.error('加载行政区数据失败:', error)
      resolve([])
    }
  }
}


const canSubmit = computed(() => {
  if (!controlForm.policyName) return false
  if (controlForm.policyType === 'admin_region' && !controlForm.adcode) return false
  if (controlForm.policyType === 'custom_region' && !controlForm.customGeometry) return false
  if (controlForm.policyType === 'single_plot' && !controlForm.plotId) return false
  return true
})

// ----------------- 生命周期 -----------------

onMounted(() => {
  nextTick(() => {
    initMap()
    loadData()
  })
})

onUnmounted(() => {
  if (scene.value) {
    scene.value.destroy()
    scene.value = null
  }
})

// ----------------- 数据加载 -----------------

async function loadData() {
  try {
    const [cropsRes, plotsRes] = await Promise.all([
      getCropTypes(),
      listPlot({ pageNum: 1, pageSize: 10000 })
    ])
    
    cropTypes.value = cropsRes.result || cropsRes
    allPlots.value = plotsRes.result?.rows || plotsRes.rows || []
    
    loadRegionStats()
    loadPolicies()
    
    // 如果地图已准备好，渲染图层
    if (mapLoaded.value) {
      renderPlotLayers()
    }
  } catch (error) {
    console.error('加载数据失败:', error)
  }
}

async function loadRegionStats() {
  try {
    const res = await getAdminRegionsWithStats({ level: regionLevel.value })
    regionStats.value = res.result?.rows || res.rows || []
    
    // 同时更新级联选择器的列表（缓存）
    if (regionLevel.value === 'province') {
      adminRegions.value = regionStats.value
    }
  } catch (error) {
    console.error('加载区域统计失败:', error)
  }
}

async function loadPolicies() {
  try {
    const res = await getControlPolicies({ pageNum: 1, pageSize: 100 })
    policies.value = res.result?.rows || res.rows || []
  } catch (error) {
    console.error('加载策略列表失败:', error)
  }
}

// ----------------- 地图逻辑 -----------------

function initMap() {
  scene.value = new Scene({
    id: mapId.value,
    map: new GaodeMap({
      center: [104.06, 35.67],
      pitch: 0,
      zoom: 4,
      style: 'light',
      token: '<REDACTED_AMAP_TOKEN>'
    }),
    logoVisible: false
  })

  scene.value.on('loaded', () => {
    mapLoaded.value = true
    
    // 添加卫星图层
    if (window.AMap) {
      const satellite = new AMap.TileLayer.Satellite()
      satellite.setMap(scene.value.map)
      satellite.setOpacity(visibleLayers.satellite ? 1 : 0)
      scene.value.map._satellite = satellite
    }
    
    if (allPlots.value.length > 0) {
      renderPlotLayers()
    }
    
    // 监听地图点击（用于单选地块）
    scene.value.on('click', handleMapClick)
  })
}

function handleMapClick(e) {
  // 如果当前是绘制模式，不处理点击
  if (isDrawing.value) return
  
  // 核心逻辑在图层点击，但也可以根据坐标在此处理
}

function renderPlotLayers() {
  if (!scene.value) return
  
  // 清理旧图层
  if (layers.plots) scene.value.removeLayer(layers.plots)
  if (layers.plotLines) scene.value.removeLayer(layers.plotLines)
  
  const features = allPlots.value.map(p => {
    try {
      let geo = typeof p.geometry === 'string' ? JSON.parse(p.geometry) : p.geometry
      
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
          id: p.plotId,
          name: p.plotName,
          status: p.effectiveStatus,
          crop: p.cropType
        },
        geometry: geo
      }
    } catch (e) { return null }
  }).filter(f => f)

  const geoData = { type: 'FeatureCollection', features }

  layers.plots = new PolygonLayer({ autoFit: false })
    .source(geoData)
    .color('status', status => {
      return status === 1 ? '#409EFF' : '#909399'
    })
    .shape('fill')
    .style({ opacity: 0.4 })
  
  layers.plotLines = new LineLayer()
    .source(geoData)
    .color('status', status => {
      return status === 1 ? '#409EFF' : '#333'
    })
    .size(1)
    .style({ opacity: 0.8 })

  scene.value.addLayer(layers.plots)
  scene.value.addLayer(layers.plotLines)

  // 交互
  layers.plots.on('click', (ev) => {
    const { feature, lngLat } = ev
    if (controlForm.policyType === 'single_plot') {
      controlForm.plotId = feature.properties.id
      selectedPlot.value = allPlots.value.find(p => p.plotId === feature.properties.id)
      ElMessage.success(`已选择地块: ${feature.properties.name}`)
    } else {
      showPlotPopup(feature, lngLat)
    }
  })
  
  layers.plots.on('mousemove', (ev) => {
    // hover 效果
  })
}

function showPlotPopup(feature, lngLat) {
  const plot = allPlots.value.find(p => p.plotId === feature.properties.id)
  if (!plot) return

  const html = `
    <div class="map-popup">
      <div class="popup-title">${plot.plotName}</div>
      <div class="popup-content">
        <p>作物: ${getCropName(plot.cropType)}</p>
        <p>状态: <span style="color:${plot.effectiveStatus === 1 ? '#67C23A' : '#F56C6C'}">${plot.effectiveStatus === 1 ? '监测中' : '已暂停'}</span></p>
        <p>区域: ${plot.province}/${plot.city}</p>
      </div>
    </div>
  `
  
  const popup = new Popup({
    offsets: [0, 10],
    closeButton: true,
    closeOnClick: true
  }).setLnglat(lngLat).setHTML(html)
  
  scene.value.addPopup(popup)
}

// ----------------- 交互逻辑 -----------------

function handlePolicyTypeChange() {
  controlForm.adcode = null
  controlForm.customGeometry = null
  controlForm.plotId = null
  selectedPlot.value = null
  previewData.value = null
  clearDraw()
}

function startDraw() {
  if (isDrawing.value) {
    finishDraw()
    return
  }
  isDrawing.value = true
  ElMessage.info('请在地图上点击绘制多边形，右键点击结束')
  
  // 这里可以写简单的 L7 绘图逻辑或者调用 L7-Draw
  // 由于没有 package，我们实现一个基点收集逻辑
  const points = []
  
  const handleMapClick = (ev) => {
    points.push(ev.lngLat)
    updateDrawLayer(points)
  }
  
  const handleContext = (ev) => {
    if (points.length > 2) {
      finishDraw(points)
    }
    scene.value.off('click', handleMapClick)
    scene.value.off('contextmenu', handleContext)
  }
  
  scene.value.on('click', handleMapClick)
  scene.value.on('contextmenu', handleContext)
}

function updateDrawLayer(points) {
  if (points.length < 2) return
  
  if (layers.draw) scene.value.removeLayer(layers.draw)
  
  // 闭合路径
  const coords = [...points, points[0]].map(p => [p.lng, p.lat])
  const feature = {
    type: 'Feature',
    geometry: { type: 'Polygon', coordinates: [coords] }
  }
  
  layers.draw = new LineLayer()
    .source({ type: 'FeatureCollection', features: [feature] })
    .color('#F56C6C')
    .size(2)
    .style({ lineType: 'dash', dashArray: [5, 5] })
    
  scene.value.addLayer(layers.draw)
}

function finishDraw(points) {
  isDrawing.value = false
  if (!points || points.length < 3) return
  
  const coords = [...points, points[0]].map(p => [p.lng, p.lat])
  const geometry = { type: 'Polygon', coordinates: [coords] }
  controlForm.customGeometry = JSON.stringify(geometry)
  
  // 渲染实线
  if (layers.draw) scene.value.removeLayer(layers.draw)
  layers.draw = new PolygonLayer()
    .source({ type: 'FeatureCollection', features: [{ type: 'Feature', geometry }] })
    .color('#F56C6C')
    .shape('fill')
    .style({ opacity: 0.2 })
  scene.value.addLayer(layers.draw)
  
  ElMessage.success('区域绘制完成')
}

function clearDraw() {
  if (layers.draw) {
    scene.value.removeLayer(layers.draw)
    layers.draw = null
  }
  controlForm.customGeometry = null
  isDrawing.value = false
}

// ----------------- 执行操作 -----------------

async function handlePreview() {
  if (!canSubmit.value) {
    ElMessage.warning('请先完善管控配置')
    return
  }
  
  previewLoading.value = true
  try {
    const res = await previewImpact(controlForm)
    if (res.is_success || res.success) {
      previewData.value = res.result || res.data
      impactDrawer.value = true
    }
  } catch (error) {
    ElMessage.error('预览失败')
  } finally {
    previewLoading.value = false
  }
}

async function handleSubmit() {
  if (!canSubmit.value) return
  
  submitLoading.value = true
  try {
    const res = await createControlPolicy(controlForm)
    if (res.is_success || res.success) {
      ElMessage.success('策略创建并执行成功')
      resetForm()
      loadData() // 刷新列表和地图
    }
  } catch (error) {
    ElMessage.error('执行失败')
  } finally {
    submitLoading.value = false
  }
}

function resetForm() {
  Object.assign(controlForm, {
    policyName: '',
    policyType: 'admin_region',
    controlAction: 'pause',
    adcode: null,
    customGeometry: null,
    plotId: null,
    cropCodes: [],
    reason: '',
    priority: 10
  })
  selectedPlot.value = null
  previewData.value = null
  clearDraw()
}

async function togglePolicy(policy) {
  try {
    const res = await toggleControlPolicy(policy.policyId, policy.isActive)
    if (res.is_success || res.success) {
      ElMessage.success(`策略已${policy.isActive ? '启用' : '禁用'}`)
      loadData() // 刷新受影响状态
    }
  } catch (error) {
    policy.isActive = !policy.isActive // 恢复原状
    ElMessage.error('操作失败')
  }
}

async function handleDeletePolicy(policy) {
  try {
    await ElMessageBox.confirm('确定要永久删除此管控策略吗？地块状态将根据剩余策略重新计算。', '确认删除')
    const res = await deleteControlPolicy(policy.policyId)
    if (res.is_success || res.success) {
      ElMessage.success('策略已删除')
      loadPolicies()
      loadData()
    }
  } catch {}
}

// ----------------- 功能辅助 -----------------

function getCropName(code) {
  if (!code) return '未设置'
  const crop = cropTypes.value.find(c => c.cropCode === code)
  return crop ? crop.cropName : code
}

function getPolicyTypeLabel(type) {
  const map = {
    'admin_region': '行政区',
    'custom_region': '自定义区域',
    'single_plot': '地块'
  }
  return map[type] || type
}

function getPolicyTypeTag(type) {
  const map = {
    'admin_region': 'success',
    'custom_region': 'warning',
    'single_plot': 'primary'
  }
  return map[type] || 'info'
}

function getPolicyTargetDesc(p) {
  if (p.policyType === 'admin_region') return p.regionName || p.adcode
  if (p.policyType === 'single_plot') return `地块 ID: ${p.plotId}`
  if (p.policyType === 'custom_region') return '已绘制的空间区域'
  return '-'
}

function formatTime(timeStr) {
  if (!timeStr) return '-'
  return new Date(timeStr).toLocaleString()
}

function locatePlot(plot) {
  if (!scene.value) return
  let geo = typeof plot.geometry === 'string' ? JSON.parse(plot.geometry) : plot.geometry
  if (geo) {
    scene.value.fitBounds(getBounds(geo))
    showPlotPopup({ properties: { id: plot.plotId, name: plot.plotName } }, getCenter(geo))
  }
}

function locateAdminRegion(region) {
  if (!scene.value || !region.geometry) return
  const geo = typeof region.geometry === 'string' ? JSON.parse(region.geometry) : region.geometry
  scene.value.fitBounds(getBounds(geo))
}

function getBounds(geo) {
  let coords = []
  if (geo.type === 'Polygon') coords = geo.coordinates[0]
  else if (geo.type === 'MultiPolygon') coords = geo.coordinates[0][0]
  else if (Array.isArray(geo)) coords = geo
  
  let minX = 180, minY = 90, maxX = -180, maxY = -90
  coords.forEach(p => {
    if (p[0] < minX) minX = p[0]
    if (p[1] < minY) minY = p[1]
    if (p[0] > maxX) maxX = p[0]
    if (p[1] > maxY) maxY = p[1]
  })
  return [[minX, minY], [maxX, maxY]]
}

function getCenter(geo) {
  const b = getBounds(geo)
  return [(b[0][0] + b[1][0]) / 2, (b[0][1] + b[1][1]) / 2]
}

function quickApplyAdmin(item) {
  mode.value = 'control'
  controlForm.policyType = 'admin_region'
  controlForm.adcode = item.adcode
  controlForm.policyName = `${item.name}管控策略`
}

function updateLayersVisibility() {
  if (layers.plots) visibleLayers.plots ? layers.plots.show() : layers.plots.hide()
  if (layers.plotLines) visibleLayers.plots ? layers.plotLines.show() : layers.plotLines.hide()
}

function toggleMapType() {
  if (scene.value.map._satellite) {
    scene.value.map._satellite.setOpacity(visibleLayers.satellite ? 1 : 0)
  }
}

function mapZoomIn() { scene.value.setZoom(scene.value.getZoom() + 1) }
function mapZoomOut() { scene.value.setZoom(scene.value.getZoom() - 1) }
function resetView() { scene.value.setZoomAndCenter(4, [104.06, 35.67]) }

</script>

<style scoped lang="scss">
.fine-control-container {
  display: flex;
  width: 100%;
  height: calc(100vh - 84px);
  overflow: hidden;
  background-color: #f8fafc;
}

.left-sidebar {
  width: 340px;
  min-width: 340px;
  height: 100%;
  padding: 20px;
  background: rgba(255, 255, 255, 0.95);
  overflow-y: auto;
  border-right: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
  z-index: 10;
  box-shadow: 4px 0 16px rgba(0, 0, 0, 0.04);
  backdrop-filter: blur(10px);
  
  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 2px; }
}

.sidebar-header {
  margin-bottom: 24px;
  h3 { margin: 0; font-size: 20px; font-weight: 700; color: #0f172a; }
  p { margin: 4px 0 0; font-size: 13px; color: #64748b; }
}

.mode-selector {
  margin-bottom: 20px;
  :deep(.el-radio-group) {
    width: 100%;
    display: flex;
    background: #f1f5f9;
    padding: 2px;
    border-radius: 8px;
    .el-radio-button { flex: 1; border: none; }
    .el-radio-button__inner { width: 100%; border: none !important; border-radius: 6px !important; background: transparent; padding: 8px 0; font-size: 12px; }
    .is-active .el-radio-button__inner { background: #fff !important; color: #3b82f6; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
  }
}

.sidebar-content { flex: 1; display: flex; flex-direction: column; gap: 16px; }

.stats-grid { 
  display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 10px;
}

.stat-card {
  background: #f8fafc; border-radius: 8px; padding: 10px; border: 1px solid #f1f5f9; text-align: center;
  .stat-label { font-size: 11px; color: #64748b; margin-bottom: 4px; }
  .stat-value { font-size: 16px; font-weight: 700; color: #1e293b; }
  .stat-value.active { color: #3b82f6; }
  .stat-value.paused { color: #94a3b8; }
}

.card-container {
  background: #fff; border-radius: 12px; border: 1px solid #e2e8f0; padding: 15px;
  .card-header { font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
  .card-header.highlight { border-bottom: 2px solid #3b82f6; padding-bottom: 8px; }
}

.full-width { width: 100%; :first-child { flex: 1; } }
.full-width-radio { 
  width: 100%; 
  :deep(.el-radio-button) { width: 50%; .el-radio-button__inner { width: 100%; } }
}

.form-footer { display: flex; gap: 10px; margin-top: 10px; }

.preview-stats {
  .preview-main { font-size: 14px; margin-bottom: 10px; span { font-size: 18px; font-weight: 700; color: #f59e0b; } }
  .crop-breakdown { display: flex; flex-wrap: wrap; gap: 8px; }
  .crop-stat-line { background: #fff7ed; padding: 4px 10px; border-radius: 4px; font-size: 12px; border: 1px solid #ffedd5; .crop-name { font-weight: 600; } }
}

.list-item {
  display: flex; align-items: center; padding: 12px; border-radius: 10px; cursor: pointer; transition: all 0.2s; border: 1px solid transparent; margin-bottom: 8px;
  &:hover { background: #f1f5f9; }
  &.paused { opacity: 0.8; .item-name { color: #64748b; } }
  
  .item-icon { width: 36px; height: 36px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 18px; margin-right: 12px; }
  .item-icon.blue { background: #eff6ff; color: #3b82f6; }
  .item-icon.gray { background: #f1f5f9; color: #94a3b8; }
  .item-icon.green { background: #f0fdf4; color: #22c55e; }
  
  .item-info { flex: 1; overflow: hidden; }
  .item-name { font-size: 14px; font-weight: 600; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .item-desc { font-size: 12px; color: #64748b; margin-top: 2px; }
  .item-tags { margin-top: 5px; display: flex; gap: 4px; }
}

.policy-list-item {
  background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px; margin-bottom: 12px; transition: all 0.3s;
  &:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
  &.inactive { opacity: 0.6; filter: grayscale(0.5); }
  
  .policy-header { display: flex; justify-content: space-between; margin-bottom: 8px; }
  .policy-name { font-weight: 700; font-size: 14px; color: #0f172a; margin-bottom: 5px; }
  .policy-target { font-size: 12px; color: #334155; display: flex; align-items: center; gap: 4px; margin-bottom: 8px; }
  .policy-meta { display: flex; justify-content: space-between; font-size: 11px; color: #94a3b8; .action.pause { color: #ef4444; } .action.resume { color: #10b981; } }
}

.map-wrapper { flex: 1; position: relative; }
.map-view { width: 100%; height: 100%; }

.map-overlays { position: absolute; top: 20px; right: 20px; z-index: 100; }
.overlay-card { width: 180px; padding: 15px; border-radius: 12px; .overlay-header { font-size: 12px; font-weight: 700; margin-bottom: 10px; color: #334155; } }
.overlay-body { display: flex; flex-direction: column; gap: 8px; }

.map-tools { position: absolute; bottom: 30px; right: 20px; z-index: 100; }
.full-width-drawer { .el-drawer__body { padding: 0; } }

.geometry-success { font-size: 12px; margin-top: 5px; display: flex; align-items: center; gap: 4px; }

.animate-fade-in { animation: fadeIn 0.3s ease-in-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

.map-popup {
  padding: 5px; min-width: 150px;
  .popup-title { font-weight: 700; border-bottom: 1px solid #eee; padding-bottom: 5px; margin-bottom: 5px; }
  .popup-content p { margin: 2px 0; font-size: 12px; }
}
</style>
