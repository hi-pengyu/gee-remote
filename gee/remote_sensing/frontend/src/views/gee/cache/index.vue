<template>
  <div class="app-container">
    <div class="page-header">
      <h2>缓存管理</h2>
      <p>管理 GEE 瓦片缓存与存储空间</p>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-blue">
            <el-icon :size="24" color="#409EFF"><DataBoard /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.total_tiles || 0 }}</div>
            <div class="stat-label">总瓦片数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-green">
            <el-icon :size="24" color="#67C23A"><SuccessFilled /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.active_tiles || 0 }}</div>
            <div class="stat-label">活跃瓦片</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-orange">
            <el-icon :size="24" color="#E6A23C"><Coin /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ (stats.actual_size_gb || 0).toFixed(2) }} GB</div>
            <div class="stat-label">缓存大小</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-red">
            <el-icon :size="24" color="#F56C6C"><TrendCharts /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.cache_hit_potential || '0%' }}</div>
            <div class="stat-label">缓存命中率</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 查询表单 -->
    <div class="card-container search-card mb-4">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
        <el-form-item label="瓦片ID" prop="tileId">
          <el-input
            v-model="queryParams.tileId"
            placeholder="请输入瓦片ID"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="影像日期" prop="dateAcquired">
          <el-date-picker
            v-model="queryParams.dateAcquired"
            type="date"
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="瓦片状态" clearable>
            <el-option label="活跃" value="0" />
            <el-option label="已删除" value="1" />
          </el-select>
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
            type="danger"
            plain
            icon="Delete"
            :disabled="multiple"
            @click="handleDelete"
            v-hasPermi="['gee:cache:remove']"
          >删除</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="warning"
            plain
            icon="Download"
            @click="handlePrefetch"
            v-hasPermi="['gee:cache:prefetch']"
          >预取</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="info"
            plain
            icon="Delete"
            @click="handleCleanup"
            v-hasPermi="['gee:cache:remove']"
          >清理</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="warning"
            plain
            icon="Download"
            @click="handleExport"
            v-hasPermi="['gee:cache:export']"
          >导出</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="cacheList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="瓦片ID" align="center" prop="tileId" width="150" show-overflow-tooltip />
        <el-table-column label="影像日期" align="center" prop="dateAcquired" width="120" />
        <el-table-column label="文件大小" align="center" prop="fileSize" width="100">
          <template #default="scope">
            {{ formatFileSize(scope.row.fileSize) }}
          </template>
        </el-table-column>
        <el-table-column label="访问次数" align="center" prop="accessCount" width="100" />
        <el-table-column label="最后访问" align="center" prop="lastAccess" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.lastAccess) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="过期时间" align="center" prop="expiresAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.expiresAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" align="center" prop="status" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.status === '0' ? 'success' : 'info'" effect="light">
              {{ scope.row.status === '0' ? '活跃' : '已删除' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
          <template #default="scope">
            <el-button
              link
              type="danger"
              icon="Delete"
              @click="handleDelete(scope.row)"
              v-hasPermi="['gee:cache:remove']"
            >删除</el-button>
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
  </div>
</template>

<script setup name="GeeCache">
import { listCache, getCacheStats, delCache, cleanupCache, exportCache } from '@/api/gee/cache'
import { DataBoard, SuccessFilled, Coin, TrendCharts } from '@element-plus/icons-vue'

const { proxy } = getCurrentInstance()

const cacheList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const stats = ref({})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  tileId: undefined,
  dateAcquired: undefined,
  status: undefined
})

/** 查询缓存列表 */
function getList() {
  loading.value = true
  listCache(queryParams.value).then(response => {
    cacheList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

/** 获取统计信息 */
function getStats() {
  getCacheStats().then(response => {
    stats.value = response.data
  })
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm('queryRef')
  handleQuery()
}

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.tileId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 删除按钮操作 */
function handleDelete(row) {
  const tileIds = row.tileId || ids.value
  proxy.$modal.confirm('是否确认删除瓦片ID为"' + tileIds + '"的缓存?').then(function() {
    return delCache(tileIds)
  }).then(() => {
    getList()
    getStats()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

/** 清理按钮操作 */
function handleCleanup() {
  proxy.$modal.prompt('请输入保留天数', '清理缓存').then(({ value }) => {
    return cleanupCache(value)
  }).then((response) => {
    getList()
    getStats()
    proxy.$modal.msgSuccess('清理完成,删除了 ' + response.data.deleted_count + ' 个瓦片')
  }).catch(() => {})
}

/** 预取按钮操作 */
function handlePrefetch() {
  proxy.$modal.msgInfo('预取功能开发中...')
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('gee/cache/export', {
    ...queryParams.value
  }, `cache_${new Date().getTime()}.xlsx`)
}

/** 格式化文件大小 */
function formatFileSize(bytes) {
  if (!bytes) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return (bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i]
}

getList()
getStats()
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

.mb20 {
  margin-bottom: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.mb8 {
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
</style>
