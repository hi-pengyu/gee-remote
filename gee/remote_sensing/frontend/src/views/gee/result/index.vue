<template>
  <div class="app-container">
    <div class="page-header">
      <h2>结果管理</h2>
      <p>查看和导出 GEE 遥感分析结果</p>
    </div>

    <!-- 查询表单 -->
    <div class="card-container search-card mb-4">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
        <el-form-item label="任务名称" prop="taskName">
          <el-input
            v-model="queryParams.taskName"
            placeholder="请输入任务名称"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="缓存来源" prop="cacheSource">
          <el-select v-model="queryParams.cacheSource" placeholder="缓存来源" clearable>
            <el-option label="缓存" value="cache" />
            <el-option label="GEE" value="gee" />
          </el-select>
        </el-form-item>
        <el-form-item label="数据日期" prop="dateRange">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="-"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 数据表格 -->
    <div class="card-container table-card">
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button
            type="warning"
            plain
            icon="Download"
            @click="handleExport"
            v-hasPermi="['gee:result:export']"
          >导出</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="resultList">
        <el-table-column label="任务名称" align="center" prop="taskName" min-width="180" show-overflow-tooltip />
        <el-table-column label="任务类型" align="center" prop="taskType" width="120" />
        <el-table-column label="目标日期" align="center" prop="targetDate" width="120" />
        <el-table-column label="实际日期" align="center" prop="foundDate" width="120" />
        <el-table-column label="缓存来源" align="center" prop="cacheSource" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.cacheSource === 'cache' ? 'success' : 'info'" effect="light">
              {{ scope.row.cacheSource === 'cache' ? '缓存' : 'GEE' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="缓存命中率" align="center" prop="cacheHitRate" width="120">
          <template #default="scope">
            <el-progress :percentage="scope.row.cacheHitRate || 0" :color="getHitRateColor(scope.row.cacheHitRate)" />
          </template>
        </el-table-column>
        <el-table-column label="云覆盖率" align="center" prop="cloudCover" width="100">
          <template #default="scope">
            {{ scope.row.cloudCover ? scope.row.cloudCover.toFixed(2) + '%' : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="处理时间" align="center" prop="processingTime" width="100">
          <template #default="scope">
            {{ scope.row.processingTime ? scope.row.processingTime.toFixed(1) + 's' : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="模型预测" align="center" width="140">
          <template #default="scope">
            <span style="color: #10b981; font-weight: 600;">{{ scope.row.modelsSuccessful }}</span> / 
            <span style="color: #64748b;">{{ scope.row.modelsTotal }}</span>
            <span v-if="scope.row.modelsFailed > 0" style="color: #ef4444; font-size: 12px;"> ({{ scope.row.modelsFailed }}失败)</span>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" align="center" prop="createdAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="120">
          <template #default="scope">
            <el-button
              link
              type="primary"
              icon="View"
              @click="handleDetail(scope.row)"
              v-hasPermi="['gee:result:detail']"
            >详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-show="total > 0"
        :total="total"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        @pagination="getList"
      />
    </div>

    <!-- 详情抽屉 -->
    <el-drawer v-model="detailOpen" title="任务结果详情" size="80%" direction="rtl" destroy-on-close>
      <div v-if="resultDetail" class="result-detail">
        <!-- 基本信息 -->
        <div class="detail-section">
          <h3 class="section-title">基本信息</h3>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="任务ID">{{ resultDetail.taskId }}</el-descriptions-item>
            <el-descriptions-item label="任务名称">{{ resultDetail.taskName }}</el-descriptions-item>
            <el-descriptions-item label="任务类型">{{ resultDetail.taskType }}</el-descriptions-item>
            <el-descriptions-item label="目标日期">{{ resultDetail.targetDate }}</el-descriptions-item>
            <el-descriptions-item label="实际日期">{{ resultDetail.foundDate }}</el-descriptions-item>
            <el-descriptions-item label="任务状态">
              <el-tag :type="getStatusType(resultDetail.taskStatus)" effect="light">
                {{ getStatusText(resultDetail.taskStatus) }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 缓存信息 -->
        <div class="detail-section">
          <h3 class="section-title">缓存信息</h3>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="缓存来源">
              <el-tag :type="resultDetail.cacheSource === 'cache' ? 'success' : 'info'" effect="light">
                {{ resultDetail.cacheSource === 'cache' ? '缓存命中' : 'GEE下载' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="缓存命中率">
              <el-progress :percentage="resultDetail.cacheHitRate || 0" :color="getHitRateColor(resultDetail.cacheHitRate)" />
            </el-descriptions-item>
            <el-descriptions-item label="瓦片数量">{{ resultDetail.tileCount }}</el-descriptions-item>
            <el-descriptions-item label="瓦片ID" :span="3">
              <div class="tile-ids">
                <el-tag v-for="tileId in resultDetail.tileIds" :key="tileId" class="mr-2 mb-2" size="small" effect="plain">{{ tileId }}</el-tag>
              </div>
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 数据信息 -->
        <div class="detail-section">
          <h3 class="section-title">数据信息</h3>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="云覆盖率">{{ resultDetail.cloudCover }}%</el-descriptions-item>
            <el-descriptions-item label="总像素数">{{ resultDetail.totalPixels }}</el-descriptions-item>
            <el-descriptions-item label="有效像素数">{{ resultDetail.validPixels }}</el-descriptions-item>
            <el-descriptions-item label="处理时间">{{ resultDetail.processingTime }}秒</el-descriptions-item>
            <el-descriptions-item label="文件名称">{{ resultDetail.fileName }}</el-descriptions-item>
            <el-descriptions-item label="是否过期">
              <el-tag :type="resultDetail.isExpired ? 'danger' : 'success'" effect="light">
                {{ resultDetail.isExpired ? '已过期' : '有效' }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 模型预测结果 -->
        <div class="detail-section">
          <h3 class="section-title">模型预测结果 ({{ resultDetail.modelsSuccessful }}/{{ resultDetail.modelsTotal }})</h3>
          
          <el-row :gutter="20">
            <el-col 
              v-for="prediction in resultDetail.predictions" 
              :key="prediction.predictionId"
              :xs="24" :sm="12" :md="8" :lg="6"
              class="mb-4"
            >
              <div class="model-card card-container">
                <!-- 模型可视化图片 -->
                <div class="model-image-container">
                  <el-image
                    v-if="prediction.visualizationSuccess && prediction.visualizationImage"
                    :src="getImageUrl(prediction.visualizationImage)"
                    :preview-src-list="[getImageUrl(prediction.visualizationImage)]"
                    fit="cover"
                    class="model-image"
                  >
                    <template #error>
                      <div class="image-slot">
                        <el-icon><icon-picture /></el-icon>
                      </div>
                    </template>
                  </el-image>
                  <div v-else class="image-slot">
                    <el-icon><icon-picture /></el-icon>
                    <div>暂无图片</div>
                  </div>
                </div>

                <!-- 模型信息 -->
                <div class="model-info">
                  <div class="model-name">
                    <el-tag :type="prediction.success ? 'success' : 'danger'" size="default" effect="dark">
                      {{ prediction.modelName }}
                    </el-tag>
                  </div>
                  
                  <!-- 分级统计 -->
                  <div v-if="prediction.gradeColors && prediction.gradeColors.length" class="grade-stats">
                    <div 
                      v-for="(grade, index) in prediction.gradeColors" 
                      :key="index"
                      class="grade-item"
                    >
                      <span 
                        class="grade-color" 
                        :style="{ backgroundColor: grade.color }"
                      ></span>
                      <span class="grade-label">{{ grade.label }}</span>
                      <span class="grade-proportion">{{ (grade.proportion * 100).toFixed(1) }}%</span>
                    </div>
                  </div>
                </div>
              </div>
            </el-col>
          </el-row>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup name="GeeResult">
import { listResult, getResult } from '@/api/gee/result'
import { Picture as IconPicture } from '@element-plus/icons-vue'

const { proxy } = getCurrentInstance()

const resultList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const detailOpen = ref(false)
const resultDetail = ref(null)
const dateRange = ref([])

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  taskName: undefined,
  cacheSource: undefined,
  startDate: undefined,
  endDate: undefined
})

/** 查询结果列表 */
function getList() {
  loading.value = true
  
  // 处理日期范围
  if (dateRange.value && dateRange.value.length === 2) {
    queryParams.value.startDate = dateRange.value[0]
    queryParams.value.endDate = dateRange.value[1]
  } else {
    queryParams.value.startDate = undefined
    queryParams.value.endDate = undefined
  }
  
  listResult(queryParams.value).then(response => {
    resultList.value = response.result.rows
    total.value = response.result.total
    loading.value = false
  })
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  dateRange.value = []
  proxy.resetForm('queryRef')
  handleQuery()
}

/** 详情按钮操作 */
function handleDetail(row) {
  const taskId = row.taskId
  getResult(taskId).then(response => {
    resultDetail.value = response.result
    detailOpen.value = true
  })
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('gee/result/export', {
    ...queryParams.value
  }, `result_${new Date().getTime()}.xlsx`)
}

/** 获取缓存命中率颜色 */
function getHitRateColor(rate) {
  if (rate >= 80) return '#67C23A'
  if (rate >= 50) return '#E6A23C'
  return '#F56C6C'
}

/** 获取状态类型 */
function getStatusType(status) {
  const statusMap = {
    '0': 'info',
    '1': 'warning',
    '2': 'success',
    '3': 'danger',
    '4': 'info'
  }
  return statusMap[status]
}

/** 获取状态文本 */
function getStatusText(status) {
  const statusMap = {
    '0': '待处理',
    '1': '处理中',
    '2': '成功',
    '3': '失败',
    '4': '已取消'
  }
  return statusMap[status]
}

/** 获取图片URL */
function getImageUrl(path) {
  // 这里需要根据实际情况调整图片访问路径
  // 如果图片在静态服务器上，需要拼接完整URL
  return path
}

getList()
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
}

.search-card {
  margin-bottom: 24px;
}

.mb8 {
  margin-bottom: 16px;
}

.result-detail {
  padding: 0 20px;
}

.detail-section {
  margin-bottom: 32px;
  
  .section-title {
    font-size: 16px;
    font-weight: 600;
    color: #1e293b;
    margin-bottom: 16px;
    padding-left: 12px;
    border-left: 4px solid #2563eb;
  }
}

.tile-ids {
  display: flex;
  flex-wrap: wrap;
}

.mr-2 {
  margin-right: 8px;
}

.mb-2 {
  margin-bottom: 8px;
}

.mb-4 {
  margin-bottom: 24px;
}

.model-card {
  height: 100%;
  padding: 0;
  overflow: hidden;
  transition: all 0.3s;
  border: 1px solid #e2e8f0;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
  }
}

.model-image-container {
  width: 100%;
  height: 200px;
  overflow: hidden;
  background-color: #f1f5f9;
  border-bottom: 1px solid #e2e8f0;
}

.model-image {
  width: 100%;
  height: 100%;
}

.image-slot {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  background-color: #f1f5f9;
  color: #94a3b8;
  font-size: 14px;
  
  .el-icon {
    font-size: 48px;
    margin-bottom: 8px;
  }
}

.model-info {
  padding: 16px;
}

.model-name {
  margin-bottom: 16px;
  font-size: 14px;
  font-weight: 600;
}

.grade-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.grade-item {
  display: flex;
  align-items: center;
  font-size: 13px;
  gap: 8px;
}

.grade-color {
  width: 12px;
  height: 12px;
  border-radius: 3px;
  flex-shrink: 0;
}

.grade-label {
  flex: 1;
  color: #475569;
}

.grade-proportion {
  color: #64748b;
  font-weight: 500;
}
</style>
