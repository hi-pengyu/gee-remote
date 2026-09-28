<template>
  <div class="app-container">
    <div class="page-header">
      <h2>配置管理</h2>
      <p>管理 GEE 服务系统配置参数</p>
    </div>

    <!-- 查询表单 -->
    <div class="card-container search-card mb-4">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
        <el-form-item label="配置键" prop="configKey">
          <el-input
            v-model="queryParams.configKey"
            placeholder="请输入配置键"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="配置分组" prop="configGroup">
          <el-select v-model="queryParams.configGroup" placeholder="配置分组" clearable>
            <el-option
              v-for="group in groupOptions"
              :key="group"
              :label="group"
              :value="group"
            />
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
            type="success"
            plain
            icon="Refresh"
            @click="handleReload"
            v-hasPermi="['gee:config:reload']"
          >热重载配置</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="configList">
        <el-table-column label="配置键" align="center" prop="configKey" width="250" show-overflow-tooltip />
        <el-table-column label="配置值" align="center" prop="configValue" show-overflow-tooltip>
          <template #default="scope">
            <el-tag v-if="scope.row.configType === 'bool'" :type="scope.row.configValue === 'true' ? 'success' : 'info'" effect="light">
              {{ scope.row.configValue }}
            </el-tag>
            <span v-else>{{ scope.row.configValue }}</span>
          </template>
        </el-table-column>
        <el-table-column label="类型" align="center" prop="configType" width="100">
          <template #default="scope">
            <el-tag :type="getTypeColor(scope.row.configType)" effect="plain">{{ scope.row.configType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="分组" align="center" prop="configGroup" width="120">
          <template #default="scope">
            <el-tag type="info" effect="plain">{{ scope.row.configGroup }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="说明" align="center" prop="description" show-overflow-tooltip />
        <el-table-column label="状态" align="center" prop="isEnabled" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.isEnabled ? 'success' : 'danger'" effect="light">
              {{ scope.row.isEnabled ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="更新时间" align="center" prop="updatedAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.updatedAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="120">
          <template #default="scope">
            <el-button
              link
              type="primary"
              icon="Edit"
              @click="handleUpdate(scope.row)"
              v-hasPermi="['gee:config:edit']"
            >修改</el-button>
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

    <!-- 编辑对话框 -->
    <el-dialog :title="'修改配置 - ' + form.configKey" v-model="open" width="600px" append-to-body destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="配置键" prop="configKey">
          <el-input v-model="form.configKey" disabled />
        </el-form-item>
        <el-form-item label="配置类型" prop="configType">
          <el-tag :type="getTypeColor(form.configType)">{{ form.configType }}</el-tag>
        </el-form-item>
        <el-form-item label="配置值" prop="configValue">
          <el-input
            v-if="form.configType === 'string'"
            v-model="form.configValue"
            type="textarea"
            :rows="3"
            placeholder="请输入配置值"
          />
          <el-input-number
            v-else-if="form.configType === 'int'"
            v-model.number="form.configValue"
            :controls="false"
            style="width: 100%"
          />
          <el-input-number
            v-else-if="form.configType === 'float'"
            v-model.number="form.configValue"
            :precision="2"
            :controls="false"
            style="width: 100%"
          />
          <el-switch
            v-else-if="form.configType === 'bool'"
            v-model="form.configValue"
            active-value="true"
            inactive-value="false"
          />
          <el-input
            v-else-if="form.configType === 'json'"
            v-model="form.configValue"
            type="textarea"
            :rows="5"
            placeholder="请输入JSON格式配置"
          />
          <el-input
            v-else
            v-model="form.configValue"
            placeholder="请输入配置值"
          />
        </el-form-item>
        <el-form-item label="配置说明">
          <span class="description-text">{{ form.description }}</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="GeeConfig">
import { listConfig, getConfigGroups, updateConfig, reloadConfig } from '@/api/gee/config'

const { proxy } = getCurrentInstance()

const configList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const open = ref(false)
const groupOptions = ref([])

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  configKey: undefined,
  configGroup: undefined
})

const form = ref({})

const rules = {
  configValue: [
    { required: true, message: "配置值不能为空", trigger: "blur" }
  ]
}

/** 查询配置列表 */
function getList() {
  loading.value = true
  listConfig(queryParams.value).then(response => {
    configList.value = response.result.rows
    total.value = response.result.total
    loading.value = false
  })
}

/** 查询配置分组 */
function getGroups() {
  getConfigGroups().then(response => {
    groupOptions.value = response.result
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

/** 修改按钮操作 */
function handleUpdate(row) {
  form.value = { ...row }
  open.value = true
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (valid) {
      updateConfig(form.value.configKey, form.value.configValue).then(response => {
        proxy.$modal.msgSuccess("修改成功")
        open.value = false
        getList()
      })
    }
  })
}

/** 取消按钮 */
function cancel() {
  open.value = false
  form.value = {}
}

/** 热重载配置 */
function handleReload() {
  proxy.$modal.confirm('确认要重新加载所有GEE服务的配置吗？').then(function() {
    return reloadConfig()
  }).then(() => {
    proxy.$modal.msgSuccess("配置重载请求已发送到所有GEE服务实例")
  }).catch(() => {})
}

/** 获取类型颜色 */
function getTypeColor(type) {
  const colorMap = {
    'string': '',
    'int': 'success',
    'float': 'warning',
    'bool': 'danger',
    'json': 'info'
  }
  return colorMap[type] || ''
}

getList()
getGroups()
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

.mb-4 {
  margin-bottom: 16px;
}

.description-text {
  color: #64748b;
  line-height: 1.4;
}
</style>
