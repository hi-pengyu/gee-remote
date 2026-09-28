<template>
  <div class="app-container">
    <div class="page-header">
      <h2>任务管理</h2>
      <p>监控与管理 GEE 遥感任务状态</p>
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
        <el-form-item label="任务状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="任务状态" clearable>
            <el-option label="待处理" value="0" />
            <el-option label="处理中" value="1" />
            <el-option label="成功" value="2" />
            <el-option label="失败" value="3" />
            <el-option label="已取消" value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="目标日期" prop="targetDate">
          <el-date-picker
            v-model="queryParams.targetDate"
            type="date"
            placeholder="选择日期"
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
            type="primary"
            plain
            icon="Plus"
            @click="handleAdd"
            v-hasPermi="['gee:task:add']"
          >新增</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="danger"
            plain
            icon="Delete"
            :disabled="multiple"
            @click="handleCancel"
            v-hasPermi="['gee:task:cancel']"
          >取消</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="warning"
            plain
            icon="Download"
            @click="handleExport"
            v-hasPermi="['gee:task:export']"
          >导出</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="taskList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="任务ID" align="center" prop="taskId" width="180" show-overflow-tooltip />
        <el-table-column label="任务名称" align="center" prop="taskName" min-width="120" />
        <el-table-column label="任务类型" align="center" prop="taskType" width="100" />
        <el-table-column label="目标日期" align="center" prop="targetDate" width="120" />
        <el-table-column label="状态" align="center" prop="status" width="100">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)" effect="light">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="进度" align="center" prop="progress" width="150">
          <template #default="scope">
            <el-progress :percentage="scope.row.progress || 0" :status="scope.row.status === '2' ? 'success' : null" />
          </template>
        </el-table-column>
        <el-table-column label="缓存命中率" align="center" prop="cacheHitRate" width="120">
          <template #default="scope">
            {{ scope.row.cacheHitRate ? scope.row.cacheHitRate + '%' : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="耗时(秒)" align="center" prop="duration" width="100" />
        <el-table-column label="创建时间" align="center" prop="createdAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
          <template #default="scope">
            <el-button
              link
              type="primary"
              icon="View"
              @click="handleDetail(scope.row)"
              v-hasPermi="['gee:task:detail']"
            >详情</el-button>
            <el-button
              link
              type="warning"
              icon="Close"
              @click="handleCancel(scope.row)"
              v-hasPermi="['gee:task:cancel']"
              v-if="scope.row.status === '0' || scope.row.status === '1'"
            >取消</el-button>
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

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" v-model="open" width="600px" append-to-body destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="任务名称" prop="taskName">
          <el-input v-model="form.taskName" placeholder="请输入任务名称" />
        </el-form-item>
        <el-form-item label="任务类型" prop="taskType">
          <el-select v-model="form.taskType" placeholder="请选择任务类型" style="width: 100%">
            <el-option label="预测任务" value="predict" />
            <el-option label="下载任务" value="download" />
          </el-select>
        </el-form-item>
        <el-form-item label="目标日期" prop="targetDate">
          <el-date-picker
            v-model="form.targetDate"
            type="date"
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="模型类型" prop="modelType">
          <el-input v-model="form.modelType" placeholder="请输入模型类型" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 详情抽屉 -->
    <el-drawer v-model="detailOpen" title="任务详情" size="50%">
      <el-descriptions :column="2" border v-if="taskDetail">
        <el-descriptions-item label="任务ID">{{ taskDetail.taskId }}</el-descriptions-item>
        <el-descriptions-item label="任务名称">{{ taskDetail.taskName }}</el-descriptions-item>
        <el-descriptions-item label="任务类型">{{ taskDetail.taskType }}</el-descriptions-item>
        <el-descriptions-item label="目标日期">{{ taskDetail.targetDate }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(taskDetail.status)" effect="light">
            {{ getStatusText(taskDetail.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="进度">
          <el-progress :percentage="taskDetail.progress || 0" :status="taskDetail.status === '2' ? 'success' : null" />
        </el-descriptions-item>
        <el-descriptions-item label="缓存命中率">{{ taskDetail.cacheHitRate }}%</el-descriptions-item>
        <el-descriptions-item label="缓存来源">{{ taskDetail.cacheSource }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ parseTime(taskDetail.startTime) }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ parseTime(taskDetail.endTime) }}</el-descriptions-item>
        <el-descriptions-item label="耗时">{{ taskDetail.duration }}秒</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ parseTime(taskDetail.createdAt) }}</el-descriptions-item>
        <el-descriptions-item label="错误信息" :span="2" v-if="taskDetail.errorMsg">
          <el-alert :title="taskDetail.errorMsg" type="error" :closable="false" />
        </el-descriptions-item>
      </el-descriptions>
    </el-drawer>
  </div>
</template>

<script setup name="GeeTask">
import { listTask, getTask, addTask, cancelTask, exportTask } from '@/api/gee/task'

const { proxy } = getCurrentInstance()

const taskList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref('')
const open = ref(false)
const detailOpen = ref(false)
const taskDetail = ref(null)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  taskName: undefined,
  status: undefined,
  targetDate: undefined
})

const form = ref({})
const rules = {
  taskName: [{ required: true, message: '任务名称不能为空', trigger: 'blur' }],
  taskType: [{ required: true, message: '任务类型不能为空', trigger: 'change' }],
  targetDate: [{ required: true, message: '目标日期不能为空', trigger: 'blur' }]
}

/** 查询任务列表 */
function getList() {
  loading.value = true
  listTask(queryParams.value).then(response => {
    taskList.value = response.data.rows
    total.value = response.data.total
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
  proxy.resetForm('queryRef')
  handleQuery()
}

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.taskId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = '添加任务'
}

/** 表单重置 */
function reset() {
  form.value = {
    taskName: undefined,
    taskType: undefined,
    targetDate: undefined,
    modelType: undefined,
    remark: undefined
  }
  proxy.resetForm('formRef')
}

/** 取消按钮 */
function cancel() {
  open.value = false
  reset()
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs['formRef'].validate(valid => {
    if (valid) {
      addTask(form.value).then(response => {
        proxy.$modal.msgSuccess('新增成功')
        open.value = false
        getList()
      })
    }
  })
}

/** 详情按钮操作 */
function handleDetail(row) {
  const taskId = row.taskId
  getTask(taskId).then(response => {
    taskDetail.value = response.data
    detailOpen.value = true
  })
}

/** 取消按钮操作 */
function handleCancel(row) {
  const taskIds = row.taskId || ids.value
  proxy.$modal.confirm('是否确认取消任务ID为"' + taskIds + '"的任务?').then(function() {
    return cancelTask(taskIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('取消成功')
  }).catch(() => {})
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('gee/task/export', {
    ...queryParams.value
  }, `task_${new Date().getTime()}.xlsx`)
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
</style>
