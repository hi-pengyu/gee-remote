<template>
  <div class="app-container">
    <div class="page-header">
      <h2>仪表盘</h2>
      <p>欢迎回来，查看系统概况与任务统计</p>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="mb-4">
      <el-col :span="6">
        <div class="stat-card card-container">
          <div class="stat-icon blue">
            <svg-icon icon-class="list" />
          </div>
          <div class="stat-info">
            <div class="stat-label">任务总数</div>
            <div class="stat-value">{{ stats.task_stats.total_tasks || 0 }}</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card card-container">
          <div class="stat-icon green">
            <svg-icon icon-class="guide" />
          </div>
          <div class="stat-info">
            <div class="stat-label">成功率</div>
            <div class="stat-value">{{ stats.task_stats.success_rate || '0%' }}</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card card-container">
          <div class="stat-icon orange">
            <svg-icon icon-class="bug" />
          </div>
          <div class="stat-info">
            <div class="stat-label">运行中任务</div>
            <div class="stat-value">{{ stats.task_stats.running_tasks || 0 }}</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card card-container">
          <div class="stat-icon purple">
            <svg-icon icon-class="server" />
          </div>
          <div class="stat-info">
            <div class="stat-label">缓存大小</div>
            <div class="stat-value">{{ (stats.cache_stats.actual_size_gb || 0).toFixed(2) }} GB</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表与服务器信息 -->
    <el-row :gutter="20" class="mb-4">
      <el-col :span="16">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span class="header-title">任务趋势</span>
            </div>
          </template>
          <div ref="trendChartRef" style="height: 350px; width: 100%"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never" class="server-card">
          <template #header>
            <div class="card-header">
              <span class="header-title">服务器状态</span>
            </div>
          </template>
          <div class="server-info">
            <div class="info-item">
              <div class="info-label">
                <span>CPU 使用率</span>
                <span class="info-percent">{{ serverInfo.cpu || 0 }}%</span>
              </div>
              <el-progress :percentage="serverInfo.cpu || 0" :color="customColors" :show-text="false" :stroke-width="10" />
            </div>
            <div class="info-item">
              <div class="info-label">
                <span>内存使用率</span>
                <span class="info-percent">{{ serverInfo.memory || 0 }}%</span>
              </div>
              <el-progress :percentage="serverInfo.memory || 0" :color="customColors" :show-text="false" :stroke-width="10" />
            </div>
            <div class="info-item">
              <div class="info-label">
                <span>磁盘使用率</span>
                <span class="info-percent">{{ serverInfo.disk || 0 }}%</span>
              </div>
              <el-progress :percentage="serverInfo.disk || 0" :color="customColors" :show-text="false" :stroke-width="10" />
            </div>
            
            <div class="server-meta">
              <div class="meta-item">
                <span class="label">系统</span>
                <span class="value">{{ serverInfo.sysOsName || 'Unknown' }}</span>
              </div>
              <div class="meta-item">
                <span class="label">IP</span>
                <span class="value">{{ serverInfo.sysIp || 'Unknown' }}</span>
              </div>
              <div class="meta-item">
                <span class="label">架构</span>
                <span class="value">{{ serverInfo.sysArch || 'Unknown' }}</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 缓存详情 -->
    <el-row>
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="header-title">缓存详情</span>
            </div>
          </template>
          <el-descriptions :column="4" border>
            <el-descriptions-item label="总瓦片数">{{ stats.cache_stats.total_tiles }}</el-descriptions-item>
            <el-descriptions-item label="活跃瓦片">{{ stats.cache_stats.active_tiles }}</el-descriptions-item>
            <el-descriptions-item label="过期瓦片">{{ stats.cache_stats.expired_tiles }}</el-descriptions-item>
            <el-descriptions-item label="缓存命中潜力">{{ stats.cache_stats.cache_hit_potential }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import * as echarts from 'echarts';
import { getDashboard, getTrend } from '@/api/gee/stats';
import { getServer } from '@/api/monitor/server';

const stats = reactive({
  task_stats: {
    total_tasks: 0,
    success_rate: '0%',
    running_tasks: 0,
    pending_tasks: 0,
    completed_tasks: 0,
    failed_tasks: 0
  },
  cache_stats: {
    total_tiles: 0,
    active_tiles: 0,
    expired_tiles: 0,
    actual_size_gb: 0,
    total_accesses: 0,
    cache_hit_potential: '0%'
  },
  charts: {
    task_trend: [],
    cache_growth: []
  }
});

const serverInfo = reactive({
  cpu: 0,
  memory: 0,
  disk: 0,
  sysOsName: '',
  sysIp: '',
  sysArch: ''
});

const trendChartRef = ref(null);
let trendChart = null;

const customColors = [
  { color: '#5cb87a', percentage: 60 },
  { color: '#e6a23c', percentage: 80 },
  { color: '#f56c6c', percentage: 100 },
];

const initChart = (data) => {
  if (!trendChartRef.value) return;
  
  trendChart = echarts.init(trendChartRef.value);
  
  // Handle empty data or specific structure
  const dates = data && data.length ? data.map(item => item.date) : [];
  const values = data && data.length ? data.map(item => item.count) : [];

  const option = {
    tooltip: {
      trigger: 'axis'
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: dates,
      axisLine: {
        lineStyle: {
          color: '#909399'
        }
      }
    },
    yAxis: {
      type: 'value',
      axisLine: {
        show: false
      },
      axisTick: {
        show: false
      },
      splitLine: {
        lineStyle: {
          color: '#EBEEF5'
        }
      }
    },
    series: [
      {
        name: '任务数',
        type: 'line',
        stack: 'Total',
        smooth: true,
        showSymbol: false,
        areaStyle: {
          opacity: 0.8,
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            {
              offset: 0,
              color: 'rgba(37, 99, 235, 0.5)'
            },
            {
              offset: 1,
              color: 'rgba(37, 99, 235, 0.01)'
            }
          ])
        },
        emphasis: {
          focus: 'series'
        },
        data: values,
        itemStyle: {
          color: '#2563eb'
        }
      }
    ]
  };

  trendChart.setOption(option);
};

const loadData = async () => {
  try {
    // 1. Dashboard Stats
    try {
        const dashboardRes = await getDashboard();
        if (dashboardRes.data) {
            // Update stats with API data
            if (dashboardRes.data.task_stats) Object.assign(stats.task_stats, dashboardRes.data.task_stats);
            if (dashboardRes.data.cache_stats) Object.assign(stats.cache_stats, dashboardRes.data.cache_stats);
            if (dashboardRes.data.charts) {
                Object.assign(stats.charts, dashboardRes.data.charts);
                initChart(stats.charts.task_trend);
            } else {
                initChart([]);
            }
        }
    } catch (e) {
        console.warn('Failed to load dashboard stats', e);
    }

    // 2. Server Info
    try {
        const serverRes = await getServer();
        if (serverRes.data) {
            const { cpu, mem, sys, sysFiles } = serverRes.data;
            serverInfo.cpu = cpu ? cpu.used : 0;
            serverInfo.memory = mem ? mem.usage : 0;
            serverInfo.disk = sysFiles && sysFiles.length > 0 ? sysFiles[0].usage : 0;
            serverInfo.sysOsName = sys ? sys.osName : '';
            serverInfo.sysIp = sys ? sys.computerIp : '';
            serverInfo.sysArch = sys ? sys.osArch : '';
        }
    } catch (e) {
        console.warn('Failed to load server info', e);
    }

  } catch (error) {
    console.error('Error loading dashboard data:', error);
  }
};

onMounted(() => {
  loadData();
  
  window.addEventListener('resize', () => {
    trendChart && trendChart.resize();
  });
});
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

.stat-card {
  display: flex;
  align-items: center;
  padding: 24px;
  
  .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 16px;
    font-size: 24px;
    
    &.blue {
      background-color: rgba(37, 99, 235, 0.1);
      color: #2563eb;
    }
    
    &.green {
      background-color: rgba(16, 185, 129, 0.1);
      color: #10b981;
    }
    
    &.orange {
      background-color: rgba(245, 158, 11, 0.1);
      color: #f59e0b;
    }
    
    &.purple {
      background-color: rgba(139, 92, 246, 0.1);
      color: #8b5cf6;
    }
  }
  
  .stat-info {
    .stat-label {
      font-size: 14px;
      color: #64748b;
      margin-bottom: 4px;
    }
    
    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: #1e293b;
    }
  }
}

.header-title {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
}

.server-info {
  .info-item {
    margin-bottom: 20px;
    
    .info-label {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;
      font-size: 14px;
      color: #475569;
      
      .info-percent {
        font-weight: 600;
        color: #1e293b;
      }
    }
  }
  
  .server-meta {
    margin-top: 24px;
    padding-top: 24px;
    border-top: 1px solid #e2e8f0;
    
    .meta-item {
      display: flex;
      justify-content: space-between;
      margin-bottom: 12px;
      font-size: 13px;
      
      .label {
        color: #64748b;
      }
      
      .value {
        color: #1e293b;
        font-weight: 500;
      }
      
      &:last-child {
        margin-bottom: 0;
      }
    }
  }
}

.mb-4 {
  margin-bottom: 24px;
}
</style>