<template>
  <div class="app-container">
    <div class="page-header">
      <h2>应用管理</h2>
      <p>管理 GEE 外部应用接入与授权</p>
    </div>

    <div class="card-container search-card mb-4">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
        <el-form-item label="应用名称" prop="appName">
          <el-input
            v-model="queryParams.appName"
            placeholder="请输入应用名称"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="card-container table-card">
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button
            type="primary"
            plain
            icon="Plus"
            @click="handleAdd"
            v-hasPermi="['gee:app:add']"
          >新增</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="appList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="应用ID" align="center" prop="appId" width="80" />
        <el-table-column label="应用名称" align="center" prop="appName" min-width="120" />
        <el-table-column label="API Key" align="center" prop="appKey" width="280">
          <template #default="scope">
            <div class="api-key-wrapper">
              <span>{{ scope.row.appKey }}</span>
              <el-button
                link
                type="primary"
                icon="CopyDocument"
                @click="handleCopy(scope.row.appKey)"
                title="复制"
              ></el-button>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="描述" align="center" prop="description" show-overflow-tooltip />
        <el-table-column label="状态" align="center" prop="isEnabled" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.isEnabled ? 'success' : 'danger'" effect="light">
              {{ scope.row.isEnabled ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="每日更新" align="center" prop="enableDailyUpdate" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.enableDailyUpdate ? 'success' : 'info'" effect="plain">
              {{ scope.row.enableDailyUpdate ? '开启' : '关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="回调地址" align="center" prop="callbackUrl" show-overflow-tooltip min-width="200" />
        <el-table-column label="创建时间" align="center" prop="createdAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="220">
          <template #default="scope">
            <el-button
              link
              type="primary"
              icon="Edit"
              @click="handleUpdate(scope.row)"
              v-hasPermi="['gee:app:edit']"
            >修改</el-button>
            <el-button
              link
              type="warning"
              icon="Refresh"
              @click="handleRegenerateKey(scope.row)"
              v-hasPermi="['gee:app:edit']"
            >重置Key</el-button>
            <el-button
              link
              type="danger"
              icon="Delete"
              @click="handleDelete(scope.row)"
              v-hasPermi="['gee:app:remove']"
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

    <!-- 添加或修改应用对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body destroy-on-close>
      <el-form ref="appRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="应用名称" prop="appName">
          <el-input v-model="form.appName" placeholder="请输入应用名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="状态" prop="isEnabled" v-if="form.appId">
          <el-radio-group v-model="form.isEnabled">
            <el-radio :label="true">启用</el-radio>
            <el-radio :label="false">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="回调地址" prop="callbackUrl">
          <el-input v-model="form.callbackUrl" placeholder="请输入回调地址 (Webhook URL)" />
        </el-form-item>
        <el-form-item label="每日更新" prop="enableDailyUpdate">
          <el-switch v-model="form.enableDailyUpdate" active-text="开启" inactive-text="关闭" />
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

<script setup name="GeeApp">
import { listApp, getApp, delApp, createApp, updateApp, regenerateKey } from "@/api/gee/app";
import { parseTime } from "@/utils/ruoyi";
import useClipboard from 'vue-clipboard3'

const { toClipboard } = useClipboard()
const { proxy } = getCurrentInstance();

const appList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    appName: undefined
  },
  rules: {
    appName: [
      { required: true, message: "应用名称不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询应用列表 */
function getList() {
  loading.value = true;
  listApp(queryParams.value).then(response => {
    appList.value = response.result.rows;
    total.value = response.result.total;
    loading.value = false;
  });
}

/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
}

/** 表单重置 */
function reset() {
  form.value = {
    appId: undefined,
    appName: undefined,
    description: undefined,
    isEnabled: true,
    callbackUrl: undefined,
    enableDailyUpdate: false
  };
  proxy.resetForm("appRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1;
  getList();
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef");
  handleQuery();
}

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.appId);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加应用";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const appId = row.appId || ids.value;
  getApp(appId).then(response => {
    form.value = response.result;
    open.value = true;
    title.value = "修改应用";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["appRef"].validate(valid => {
    if (valid) {
      if (form.value.appId != undefined) {
        updateApp(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        createApp(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          open.value = false;
          getList();
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  const appIds = row.appId || ids.value;
  proxy.$modal.confirm('是否确认删除应用编号为"' + appIds + '"的数据项？').then(function() {
    return delApp(appIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

/** 重置Key操作 */
function handleRegenerateKey(row) {
  proxy.$modal.confirm('确认要重置应用 "' + row.appName + '" 的API Key吗？旧的Key将立即失效！').then(function() {
    return regenerateKey(row.appId);
  }).then(response => {
    proxy.$modal.msgSuccess("重置成功");
    // 显示新的Key
    proxy.$alert('新的API Key: ' + response.result.appKey, '重置成功', {
      confirmButtonText: '复制并关闭',
      callback: action => {
        handleCopy(response.result.appKey);
        getList();
      }
    });
  }).catch(() => {});
}

/** 复制API Key */
async function handleCopy(text) {
  try {
    await toClipboard(text)
    proxy.$modal.msgSuccess("复制成功")
  } catch (e) {
    proxy.$modal.msgError("复制失败")
  }
}

getList();
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

.api-key-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  
  span {
    font-family: monospace;
    background: #f1f5f9;
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 12px;
  }
}
</style>
