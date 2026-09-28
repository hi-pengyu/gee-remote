<template>
  <div class="app-container">
    <div class="page-header">
      <h2>账号管理</h2>
      <p>管理 GEE 服务账号与授权信息</p>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-blue">
            <el-icon :size="24" color="#409EFF"><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalAccounts || 0 }}</div>
            <div class="stat-label">总账号数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-green">
            <el-icon :size="24" color="#67C23A"><CircleCheck /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.activeAccounts || 0 }}</div>
            <div class="stat-label">启用账号</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-orange">
            <el-icon :size="24" color="#E6A23C"><Loading /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalRunningTasks || 0 }}</div>
            <div class="stat-label">运行任务</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card-wrapper card-container">
          <div class="stat-icon-wrapper bg-red">
            <el-icon :size="24" color="#F56C6C"><DataAnalysis /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalExecutedTasks || 0 }}</div>
            <div class="stat-label">总执行任务</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 搜索栏 -->
    <div class="card-container search-card mb-4">
      <el-form :model="queryParams" ref="queryRef" :inline="true">
        <el-form-item label="账号名称" prop="accountName">
          <el-input
            v-model="queryParams.accountName"
            placeholder="请输入账号名称"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="状态" prop="isActive">
          <el-select v-model="queryParams.isActive" placeholder="账号状态" clearable>
            <el-option label="启用" :value="true" />
            <el-option label="禁用" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 表格 -->
    <div class="card-container table-card">
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button type="primary" icon="Plus" @click="handleAdd">新增账号</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button type="success" icon="Refresh" @click="getList">刷新</el-button>
        </el-col>
      </el-row>

      <el-table v-loading="loading" :data="accountList">
        <el-table-column label="ID" align="center" prop="account_id" width="80" />
        <el-table-column label="账号名称" align="center" prop="account_name" min-width="150" />
        <el-table-column label="项目ID" align="center" prop="project_id" min-width="180" show-overflow-tooltip />
        <el-table-column label="服务账号邮箱" align="center" prop="service_account_email" min-width="250" show-overflow-tooltip />
        <el-table-column label="状态" align="center" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.is_active ? 'success' : 'info'" effect="light">
              {{ scope.row.is_active ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="健康状态" align="center" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.is_healthy ? 'success' : 'danger'" effect="light">
              {{ scope.row.is_healthy ? '健康' : '异常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="当前任务" align="center" prop="current_tasks_running" width="100" />
        <el-table-column label="总任务数" align="center" prop="total_tasks_executed" width="100" />
        <el-table-column label="优先级" align="center" prop="priority" width="80" />
        <el-table-column label="最后使用" align="center" prop="last_used_at" width="160" />
        <el-table-column label="操作" align="center" width="200" fixed="right" class-name="small-padding fixed-width">
          <template #default="scope">
            <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)">编辑</el-button>
            <el-button 
              v-if="!scope.row.is_healthy" 
              link 
              type="success" 
              icon="CircleCheck" 
              @click="handleMarkHealthy(scope.row)"
            >
              标记健康
            </el-button>
            <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)">删除</el-button>
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

    <!-- 添加或修改对话框 -->
    <el-dialog :title="title" v-model="open" width="600px" append-to-body destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="140px">
        <el-form-item label="账号名称" prop="account_name">
          <el-input v-model="form.account_name" placeholder="请输入账号名称" />
        </el-form-item>
        <el-form-item label="项目ID" prop="project_id">
          <el-input v-model="form.project_id" placeholder="请输入GEE项目ID，例如: <REDACTED_GCP_PROJECT_ID>" />
        </el-form-item>
        <el-form-item label="GEE Credentials" prop="credentials_json">
          <el-input 
            v-model="form.credentials_json" 
            type="textarea" 
            :rows="4" 
            placeholder="请粘贴用户认证 credentials 内容（Base64 编码）"
          />
          <div class="form-tip">
            💡 提示: 运行 <code>python test_gee_auth.py</code> 生成 Base64 编码的 credentials
          </div>
        </el-form-item>
        
        <!-- Drive Token JSON -->
        <el-form-item label="Drive Token JSON" prop="drive_token_json">
          <el-input 
            v-model="form.drive_token_json" 
            type="textarea" 
            :rows="6" 
            placeholder='请粘贴 Google Drive 服务账号 token JSON 内容，例如:
{
  "type": "service_account",
  "project_id": "xxx",
  "private_key_id": "xxx",
  "private_key": "<REDACTED_PRIVATE_KEY>",
  "client_email": "xxx@xxx.iam.gserviceaccount.com",
  ...
}'
          />
          <div class="form-tip">
            💡 提示: 粘贴完整的 Drive 服务账号 JSON 内容（从 token/token.json 文件）
          </div>
        </el-form-item>
        
        <!-- Drive Folder ID -->
        <el-form-item label="Drive 文件夹 ID" prop="drive_folder_id">
          <el-input 
            v-model="form.drive_folder_id" 
            placeholder="请输入 Google Drive 文件夹 ID，例如: 1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV"
          />
          <div class="form-tip">
            💡 提示: 从 Drive URL 中获取文件夹 ID，或运行 <code>python test_list_drive_files.py</code> 查看
          </div>
        </el-form-item>
        
        <el-form-item label="优先级" prop="priority">
          <el-input-number v-model="form.priority" :min="0" :max="100" />
        </el-form-item>
        <el-form-item label="是否启用" prop="is_active">
          <el-switch v-model="form.is_active" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancel">取 消</el-button>
          <el-button type="primary" @click="submitForm">确 定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="GEEAccounts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  listAccounts, 
  getAccount, 
  createAccount, 
  updateAccount, 
  delAccount,
  getAccountStats,
  markAccountHealthy
} from '@/api/gee/accounts'

const loading = ref(true)
const accountList = ref([])
const open = ref(false)
const title = ref('')
const total = ref(0)

const stats = ref({
  totalAccounts: 0,
  activeAccounts: 0,
  totalRunningTasks: 0,
  totalExecutedTasks: 0
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  accountName: undefined,
  isActive: undefined
})

const formRef = ref(null)
const form = ref({})
const rules = {
  account_name: [{ required: true, message: '账号名称不能为空', trigger: 'blur' }],
  project_id: [{ required: true, message: '项目ID不能为空', trigger: 'blur' }],
  credentials_json: [{ required: true, message: '密钥JSON不能为空', trigger: 'blur' }]
}

/** 查询账号列表 */
function getList() {
  loading.value = true
  listAccounts(queryParams).then(response => {
    accountList.value = response.result.rows
    total.value = response.result.total
    loading.value = false
  })
}

/** 获取统计信息 */
function getStats() {
  getAccountStats().then(response => {
    stats.value = response.stats
  })
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  queryParams.accountName = undefined
  queryParams.isActive = undefined
  handleQuery()
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = '添加GEE账号'
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const accountId = row.account_id
  getAccount(accountId).then(response => {
    form.value = response.result.data
    open.value = true
    title.value = '修改GEE账号'
  })
}

/** 提交按钮 */
function submitForm() {
  if (!formRef.value) return
  formRef.value.validate(valid => {
    if (valid) {
      if (form.value.account_id) {
        updateAccount(form.value).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
          getStats()
        })
      } else {
        createAccount(form.value).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
          getStats()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row) {
  ElMessageBox.confirm('是否确认删除账号"' + row.account_name + '"?', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delAccount(row.account_id)
  }).then(() => {
    getList()
    getStats()
    ElMessage.success('删除成功')
  })
}

/** 标记健康 */
function handleMarkHealthy(row) {
  ElMessageBox.confirm('确认标记账号"' + row.account_name + '"为健康状态?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'info'
  }).then(() => {
    return markAccountHealthy(row.account_id)
  }).then(() => {
    getList()
    ElMessage.success('标记成功')
  })
}

/** 表单重置 */
function reset() {
  form.value = {
    account_id: undefined,
    account_name: undefined,
    project_id: undefined,
    credentials_json: undefined,
    drive_token_json: undefined,
    drive_folder_id: undefined,
    priority: 0,
    is_active: true,
    description: undefined
  }
}

/** 取消按钮 */
function cancel() {
  open.value = false
  reset()
}

onMounted(() => {
  getList()
  getStats()
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

.form-tip {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}
</style>
