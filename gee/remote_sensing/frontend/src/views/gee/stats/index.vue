<template>
  <div class="app-container">
    <div class="page-header">
      <h2>统计分析</h2>
      <p>GEE 任务执行情况与性能分析</p>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-blue">
            <el-icon :size="24" color="#409EFF"><DataAnalysis /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ dashboard.totalTasks || 0 }}</div>
            <div class="stat-label">总任务数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-green">
            <el-icon :size="24" color="#67C23A"><SuccessFilled /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ dashboard.successRate || '0%' }}</div>
            <div class="stat-label">成功率</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-orange">
            <el-icon :size="24" color="#E6A23C"><Timer /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ dashboard.avgDuration || 0 }}s</div>
            <div class="stat-label">平均耗时</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-red">
            <el-icon :size="24" color="#F56C6C"><TrendCharts /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ dashboard.cacheHitRate || '0%' }}</div>
            <div class="stat-label">缓存命中率</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 趋势图表 -->
    <el-row :gutter="20" class="mb20">
      <el-col :span="12">
        <div class="card-container chart-card">
          <div class="card-header">
            <span class="card-title">任务趋势</span>
            <el-radio-group v-model="trendDays" size="small" @change="loadTrend">
              <el-radio-button :label="7">7天</el-radio-button>
              <el-radio-button :label="30">30天</el-radio-button>
              <el-radio-button :label="90">90天</el-radio-button>
            </el-radio-group>
          </div>
          <div ref="trendChart" style="height: 300px"></div>
        </div>
      </el-col>
      <el-col :span="12">
        <div class="card-container chart-card">
          <div class="card-header">
            <span class="card-title">性能分析</span>
          </div>
          <div ref="performanceChart" style="height: 300px"></div>
        </div>
      </el-col>
    </el-row>

    <!-- 详细统计表格 -->
    <div class="card-container table-card">
      <div class="card-header mb-4">
        <span class="card-title">详细统计</span>
      </div>
      <el-table :data="statsData">
        <el-table-column label="日期" prop="date" width="120" />
        <el-table-column label="总任务" prop="totalTasks" width="100" />
        <el-table-column label="成功" prop="successTasks" width="100">
          <template #default="scope">
            <el-tag type="success" effect="light">{{ scope.row.successTasks }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="失败" prop="failedTasks" width="100">
          <template #default="scope">
            <el-tag type="danger" effect="light">{{ scope.row.failedTasks }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="成功率" prop="successRate" width="100">
          <template #default="scope">
            {{ scope.row.successRate }}%
          </template>
        </el-table-column>
        <el-table-column label="平均耗时(s)" prop="avgDuration" width="120" />
        <el-table-column label="缓存命中率" prop="cacheHitRate" width="120">
          <template #default="scope">
            {{ scope.row.cacheHitRate }}%
          </template>
        </el-table-column>
        <el-table-column label="数据量(MB)" prop="dataSize" />
      </el-table>
    </div>
  </div>
</template>

<script setup name="GeeStats">
import { getDashboard, getTrend, getPerformance } from '@/api/gee/stats'
import * as echarts from 'echarts'
import { DataAnalysis, SuccessFilled, Timer, TrendCharts } from '@element-plus/icons-vue'

const { proxy } = getCurrentInstance()

const dashboard = ref({})
const trendDays = ref(7)
const statsData = ref([])
const trendChart = ref(null)
const performanceChart = ref(null)
let trendChartInstance = null
let performanceChartInstance = null

/** 加载仪表盘数据 */
function loadDashboard() {
  getDashboard().then(response => {
    dashboard.value = response.data
  })
}

/** 加载趋势数据 */
function loadTrend() {
  getTrend(trendDays.value).then(response => {
    const data = response.data
    statsData.value = data
    
    // 绘制趋势图
    if (!trendChartInstance) {
      trendChartInstance = echarts.init(trendChart.value)
    }
    
    const option = {
      tooltip: {
        trigger: 'axis'
      },
      legend: {
        data: ['总任务', '成功', '失败'],
        bottom: 0
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: data.map(item => item.date),
        axisLine: {
          lineStyle: {
            color: '#e2e8f0'
          }
        },
        axisLabel: {
          color: '#64748b'
        }
      },
      yAxis: {
        type: 'value',
        splitLine: {
          lineStyle: {
            color: '#f1f5f9'
          }
        },
        axisLabel: {
          color: '#64748b'
        }
      },
      series: [
        {
          name: '总任务',
          type: 'line',
          data: data.map(item => item.totalTasks),
          smooth: true,
          itemStyle: { color: '#409EFF' },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
              { offset: 1, color: 'rgba(64, 158, 255, 0.05)' }
            ])
          }
        },
        {
          name: '成功',
          type: 'line',
          data: data.map(item => item.successTasks),
          smooth: true,
          itemStyle: { color: '#67C23A' }
        },
        {
          name: '失败',
          type: 'line',
          data: data.map(item => item.failedTasks),
          smooth: true,
          itemStyle: { color: '#F56C6C' }
        }
      ]
    }
    
    trendChartInstance.setOption(option)
  })
}

/** 加载性能数据 */
function loadPerformance() {
  getPerformance().then(response => {
    const data = response.data
    
    // 绘制性能图
    if (!performanceChartInstance) {
      performanceChartInstance = echarts.init(performanceChart.value)
    }
    
    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        data: ['平均耗时', '缓存命中率'],
        bottom: 0
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: data.map(item => item.date),
        axisLine: {
          lineStyle: {
            color: '#e2e8f0'
          }
        },
        axisLabel: {
          color: '#64748b'
        }
      },
      yAxis: [
        {
          type: 'value',
          name: '耗时(秒)',
          position: 'left',
          splitLine: {
            lineStyle: {
              color: '#f1f5f9'
            }
          },
          axisLabel: {
            color: '#64748b'
          }
        },
        {
          type: 'value',
          name: '命中率(%)',
          position: 'right',
          max: 100,
          splitLine: {
            show: false
          },
          axisLabel: {
            color: '#64748b'
          }
        }
      ],
      series: [
        {
          name: '平均耗时',
          type: 'bar',
          data: data.map(item => item.avgDuration),
          itemStyle: {
            color: '#E6A23C',
            borderRadius: [4, 4, 0, 0]
          }
        },
        {
          name: '缓存命中率',
          type: 'line',
          yAxisIndex: 1,
          data: data.map(item => item.cacheHitRate),
          smooth: true,
          itemStyle: { color: '#F56C6C' }
        }
      ]
    }
    
    performanceChartInstance.setOption(option)
  })
}

onMounted(() => {
  loadDashboard()
  loadTrend()
  loadPerformance()
  
  // 响应式调整
  window.addEventListener('resize', () => {
    trendChartInstance?.resize()
    performanceChartInstance?.resize()
  })
})

onBeforeUnmount(() => {
  trendChartInstance?.dispose()
  performanceChartInstance?.dispose()
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 24px;
  background-color: #f8fafc;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
  
  h2 {
    font-size: 24px;
    font-weight: 600;
    color: #1e293b;
    margin: 0;
  }
  
  p {
    color: #64748b;
    margin-top: 8px;
    font-size: 14px;
  }
}

.card-container {
  background: #ffffff;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  height: 100%;
}

.mb20 {
  margin-bottom: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.stat-card-wrapper {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px;
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  }
}

.stat-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  
  &.bg-blue {
    background-color: rgba(64, 158, 255, 0.1);
  }
  
  &.bg-green {
    background-color: rgba(103, 194, 58, 0.1);
  }
  
  &.bg-orange {
    background-color: rgba(230, 162, 60, 0.1);
  }
  
  &.bg-red {
    background-color: rgba(245, 108, 108, 0.1);
  }
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  line-height: 1.2;
}

.stat-label {
  font-size: 14px;
  color: #64748b;
  margin-top: 4px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
}

.chart-card {
  min-height: 380px;
}
</style>
