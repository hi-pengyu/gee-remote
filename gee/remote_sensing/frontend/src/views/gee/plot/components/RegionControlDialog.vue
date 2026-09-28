<template>
  <el-dialog
    v-model="dialogVisible"
    title="行政区监测管控"
    width="900px"
    :close-on-click-modal="false"
  >
    <el-tabs v-model="activeTab">
      <!-- 暂停管理 -->
      <el-tab-pane label="暂停管理" name="pause">
        <el-form :model="pauseForm" ref="pauseFormRef" :rules="pauseRules" label-width="100px">
          <el-form-item label="行政区代码" prop="adcode">
            <el-input
              v-model="pauseForm.adcode"
              placeholder="如：41（河南省）、4101（郑州市）、410100（市辖区）"
              clearable
            >
              <template #append>
                <el-button @click="showAdcodeHelp">代码说明</el-button>
              </template>
            </el-input>
            <div class="help-text">
              支持前缀匹配：暂停"41"将暂停所有河南省的地块
            </div>
          </el-form-item>
          <el-form-item label="暂停原因" prop="reason">
            <el-input
              v-model="pauseForm.reason"
              type="textarea"
              :rows="3"
              placeholder="请输入暂停原因"
            />
          </el-form-item>
          <el-form-item label="预览影响">
            <el-button @click="previewImpact" :loading="previewLoading">
              查看影响范围
            </el-button>
            <div v-if="impactStats" class="impact-stats">
              <el-alert
                :title="`将影响 ${impactStats.totalPlots} 个地块（其中 ${impactStats.activePlots} 个正在监测）`"
                type="warning"
                :closable="false"
              />
            </div>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="submitPause" :loading="submitLoading">
              确认暂停
            </el-button>
            <el-button @click="resetPauseForm">重置</el-button>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <!-- 暂停列表 -->
      <el-tab-pane label="暂停列表" name="list">
        <el-table v-loading="listLoading" :data="pausedList" border>
          <el-table-column label="行政区代码" align="center" prop="adcode" width="120" />
          <el-table-column label="暂停原因" align="center" prop="reason" min-width="200" />
          <el-table-column label="操作人" align="center" prop="createdBy" width="120" />
          <el-table-column label="暂停时间" align="center" prop="createdAt" width="180" />
          <el-table-column label="操作" align="center" width="150">
            <template #default="scope">
              <el-button
                link
                type="primary"
                @click="handleResume(scope.row)"
              >
                恢复监测
              </el-button>
              <el-button
                link
                type="info"
                @click="viewStats(scope.row.adcode)"
              >
                查看统计
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <!-- 行政区代码说明对话框 -->
    <el-dialog
      v-model="adcodeHelpVisible"
      title="行政区代码说明"
      width="600px"
      append-to-body
    >
      <el-table :data="adcodeExamples" border>
        <el-table-column label="代码" prop="code" width="100" />
        <el-table-column label="说明" prop="desc" />
        <el-table-column label="示例" prop="example" />
      </el-table>
      <div class="mt-3">
        <el-alert
          title="提示：代码越短，影响范围越大。建议先查看影响范围再确认暂停。"
          type="info"
          :closable="false"
        />
      </div>
    </el-dialog>
  </el-dialog>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { pauseRegion, resumeRegion, getPausedRegions, getRegionStats } from '@/api/gee/region'
import { ElMessage, ElMessageBox } from 'element-plus'

const emit = defineEmits(['refresh'])

const dialogVisible = ref(false)
const activeTab = ref('pause')
const pauseFormRef = ref(null)
const submitLoading = ref(false)
const listLoading = ref(false)
const previewLoading = ref(false)
const adcodeHelpVisible = ref(false)

const pauseForm = reactive({
  adcode: '',
  reason: ''
})

const pauseRules = {
  adcode: [
    { required: true, message: '请输入行政区代码', trigger: 'blur' },
    { pattern: /^\d+$/, message: '行政区代码只能包含数字', trigger: 'blur' }
  ],
  reason: [
    { required: true, message: '请输入暂停原因', trigger: 'blur' }
  ]
}

const pausedList = ref([])
const impactStats = ref(null)

const adcodeExamples = [
  { code: '41', desc: '省级', example: '暂停整个河南省' },
  { code: '4101', desc: '市级', example: '暂停郑州市' },
  { code: '410100', desc: '区县级', example: '暂停郑州市市辖区' },
  { code: '410102', desc: '具体区', example: '暂停中原区' }
]

// 打开对话框
const open = () => {
  dialogVisible.value = true
  loadPausedList()
}

// 加载暂停列表
const loadPausedList = async () => {
  listLoading.value = true
  try {
    const response = await getPausedRegions()
    if (response.isSuccess) {
      pausedList.value = response.result.rows
    }
  } catch (error) {
    ElMessage.error('加载暂停列表失败')
  } finally {
    listLoading.value = false
  }
}

// 预览影响
const previewImpact = async () => {
  if (!pauseForm.adcode) {
    ElMessage.warning('请先输入行政区代码')
    return
  }
  
  previewLoading.value = true
  try {
    const response = await getRegionStats(pauseForm.adcode)
    if (response.isSuccess) {
      impactStats.value = response.result
    }
  } catch (error) {
    ElMessage.error('查询影响范围失败')
  } finally {
    previewLoading.value = false
  }
}

// 提交暂停
const submitPause = async () => {
  const valid = await pauseFormRef.value.validate()
  if (!valid) return
  
  try {
    await ElMessageBox.confirm(
      `确认暂停行政区 ${pauseForm.adcode} 的监测吗？`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    submitLoading.value = true
    const response = await pauseRegion(pauseForm)
    if (response.isSuccess) {
      ElMessage.success(response.message)
      resetPauseForm()
      loadPausedList()
      emit('refresh')
    } else {
      ElMessage.error(response.message)
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('暂停失败')
    }
  } finally {
    submitLoading.value = false
  }
}

// 恢复监测
const handleResume = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确认恢复行政区 ${row.adcode} 的监测吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'info'
      }
    )
    
    const response = await resumeRegion(row.adcode)
    if (response.isSuccess) {
      ElMessage.success(response.message)
      loadPausedList()
      emit('refresh')
    } else {
      ElMessage.error(response.message)
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('恢复失败')
    }
  }
}

// 查看统计
const viewStats = async (adcode) => {
  try {
    const response = await getRegionStats(adcode)
    if (response.isSuccess) {
      const stats = response.result
      ElMessageBox.alert(
        `
        <div>
          <p>行政区代码：${stats.adcode}</p>
          <p>总地块数：${stats.totalPlots}</p>
          <p>监测中：${stats.activePlots}</p>
          <p>已暂停：${stats.pausedPlots}</p>
          <p>自动更新：${stats.autoUpdatePlots}</p>
        </div>
        `,
        '地块统计',
        {
          dangerouslyUseHTMLString: true
        }
      )
    }
  } catch (error) {
    ElMessage.error('查询统计失败')
  }
}

// 重置表单
const resetPauseForm = () => {
  pauseFormRef.value.resetFields()
  impactStats.value = null
}

// 显示代码说明
const showAdcodeHelp = () => {
  adcodeHelpVisible.value = true
}

defineExpose({
  open
})
</script>

<style scoped>
.help-text {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

.impact-stats {
  margin-top: 10px;
}

.mt-3 {
  margin-top: 15px;
}
</style>
