<template>
  <div class="app-container">
    <div class="page-header">
      <h2>地块管理</h2>
      <p>管理遥感地块、查看关联任务与可用影像日期</p>
    </div>

    <div class="card-container search-card mb-4">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
        <el-form-item label="地块名称" prop="plotName">
          <el-input
            v-model="queryParams.plotName"
            placeholder="请输入地块名称"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="所属应用" prop="appId">
          <el-select v-model="queryParams.appId" placeholder="请选择应用" clearable filterable>
            <el-option
              v-for="item in appOptions"
              :key="item.appId"
              :label="item.appName"
              :value="item.appId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="监测状态" prop="monitorStatus">
          <el-select v-model="queryParams.monitorStatus" placeholder="请选择" clearable>
            <el-option label="全部" value="" />
            <el-option label="开启" :value="1" />
            <el-option label="关闭" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="作物类型" prop="cropType">
          <el-select v-model="queryParams.cropType" placeholder="请选择" clearable>
            <el-option
              v-for="item in cropTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
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
            v-hasPermi="['gee:plot:add']"
          >新增</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="warning"
            plain
            icon="Setting"
            @click="handleRegionControl"
          >行政区管控</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="plotList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="地块ID" align="center" prop="plotId" width="80" />
        <el-table-column label="地块名称" align="center" prop="plotName" min-width="120" />
        <el-table-column label="所属应用" align="center" prop="appName" min-width="120" />
        <el-table-column label="行政区" align="center" min-width="200">
          <template #default="scope">
            <span v-if="scope.row.province">
              {{ scope.row.province }} / {{ scope.row.city }} / {{ scope.row.district }}
            </span>
            <span v-else class="text-gray">未识别</span>
          </template>
        </el-table-column>
        <el-table-column label="作物类型" align="center" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.cropType" type="success" size="small">
              {{ getCropTypeName(scope.row.cropType) }}
            </el-tag>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column label="监测周期" align="center" width="150">
          <template #default="scope">
            <span v-if="scope.row.monitorStartDate && scope.row.monitorEndDate">
              {{ scope.row.monitorStartDate }} ~ {{ scope.row.monitorEndDate }}
            </span>
            <span v-else class="text-gray">全年</span>
          </template>
        </el-table-column>
        <el-table-column label="监测状态" align="center" width="100">
          <template #default="scope">
            <el-switch
              v-model="scope.row.monitorStatus"
              :active-value="1"
              :inactive-value="0"
              @change="handleToggleStatus(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="自动更新" align="center" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.autoUpdate ? 'success' : 'info'" size="small">
              {{ scope.row.autoUpdate ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" align="center" prop="createdAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="320">
          <template #default="scope">
            <el-button
              link
              type="success"
              icon="List"
              @click="handleViewTasks(scope.row)"
            >查看任务</el-button>
            <el-button
              link
              type="info"
              icon="Calendar"
              @click="handleViewDates(scope.row)"
            >查看日期</el-button>
            <el-button
              link
              type="primary"
              icon="Edit"
              @click="handleUpdate(scope.row)"
              v-hasPermi="['gee:plot:edit']"
            >修改</el-button>
            <el-button
              link
              type="danger"
              icon="Delete"
              @click="handleDelete(scope.row)"
              v-hasPermi="['gee:plot:remove']"
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

    <!-- 添加或修改地块对话框 -->
    <el-dialog :title="title" v-model="open" width="600px" append-to-body destroy-on-close>
      <el-form ref="plotRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="所属应用" prop="appId">
          <el-select v-model="form.appId" placeholder="请选择应用" filterable style="width: 100%">
            <el-option
              v-for="item in appOptions"
              :key="item.appId"
              :label="item.appName"
              :value="item.appId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="地块名称" prop="plotName">
          <el-input v-model="form.plotName" placeholder="请输入地块名称" />
        </el-form-item>
        <el-form-item label="几何信息" prop="geometry">
          <el-input 
            v-model="form.geometry" 
            type="textarea" 
            :rows="6" 
            placeholder="请输入GeoJSON格式的几何信息" 
          />
        </el-form-item>
        <el-form-item label="作物类型" prop="cropType">
          <el-select v-model="form.cropType" placeholder="请选择作物类型" clearable style="width: 100%">
            <el-option
              v-for="item in cropTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            >
              <span>{{ item.label }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                {{ item.period }}
              </span>
            </el-option>
          </el-select>
          <div class="help-text">选择作物类型后将自动设置监测周期</div>
        </el-form-item>
        <el-form-item label="行政区代码" prop="adcode">
          <el-input
            v-model="form.adcode"
            placeholder="可选，留空则自动识别"
            clearable
          />
          <div class="help-text">如：410100（郑州市市辖区），留空则根据坐标自动识别</div>
        </el-form-item>
        <el-form-item label="监测周期">
          <el-row :gutter="10">
            <el-col :span="11">
              <el-input v-model="form.monitorStartDate" placeholder="MM-DD" />
            </el-col>
            <el-col :span="2" class="text-center">
              <span>~</span>
            </el-col>
            <el-col :span="11">
              <el-input v-model="form.monitorEndDate" placeholder="MM-DD" />
            </el-col>
          </el-row>
          <div class="help-text">格式：MM-DD，如：04-01。选择作物类型后自动填充</div>
        </el-form-item>
        <el-form-item label="自动更新">
          <el-switch v-model="form.autoUpdate" />
          <span class="ml-2">启用后将参与每日自动更新</span>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 任务列表对话框 -->
    <el-dialog title="地块关联任务" v-model="taskDialogVisible" width="900px" append-to-body>
      <el-table v-loading="taskLoading" :data="taskList" max-height="400" @row-click="handleTaskRowClick" :row-style="{cursor: 'pointer'}">
        <el-table-column label="任务ID" align="center" prop="taskId" width="120" show-overflow-tooltip />
        <el-table-column label="目标日期" align="center" prop="targetDate" width="120" />
        <el-table-column label="模型类型" align="center" prop="modelType" width="100" />
        <el-table-column label="状态" align="center" prop="status" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.status === '2'" type="success">成功</el-tag>
            <el-tag v-else-if="scope.row.status === '1'" type="warning">处理中</el-tag>
            <el-tag v-else-if="scope.row.status === '3'" type="danger">失败</el-tag>
            <el-tag v-else type="info">待处理</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="进度" align="center" prop="progress" width="120">
          <template #default="scope">
            <el-progress :percentage="scope.row.progress" :status="scope.row.status === '2' ? 'success' : null" />
          </template>
        </el-table-column>
        <el-table-column label="创建时间" align="center" prop="createdAt" width="180">
          <template #default="scope">
            <span>{{ parseTime(scope.row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="100">
          <template #default="scope">
            <el-button link type="primary" @click.stop="viewTaskDetail(scope.row.taskId)">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-empty v-if="!taskLoading && taskList.length === 0" description="暂无关联任务" />
      
      <template #footer>
        <el-button @click="taskDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 日期列表对话框 -->
    <el-dialog title="可用遥感日期" v-model="dateDialogVisible" width="600px" append-to-body>
      <el-alert 
        title="提示" 
        type="info" 
        description="以下是该地块区域可用的 Sentinel-2 遥感影像日期" 
        :closable="false"
        style="margin-bottom: 20px"
      />
      
      <el-form :inline="true" style="margin-bottom: 10px">
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="fetchAvailableDates">查询</el-button>
        </el-form-item>
      </el-form>
      
      <el-table v-loading="dateLoading" :data="dateList" max-height="400" @row-click="handleDateRowClick" :row-style="{cursor: 'pointer'}">
        <el-table-column label="序号" type="index" width="60" align="center" />
        <el-table-column label="日期" align="center" prop="date" width="150" />
        <el-table-column label="任务数" align="center" prop="taskCount" width="80" />
        <el-table-column label="操作" align="center" width="100">
          <template #default="scope">
            <el-button link type="primary" @click.stop="viewDateTasks(scope.row.date)">查看任务</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-empty v-if="!dateLoading && dateList.length === 0" description="该时间范围内暂无可用影像" />
      
      <template #footer>
        <el-button @click="dateDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 任务详情对话框 -->
    <el-dialog title="任务详情" v-model="detailDialogVisible" width="90%" append-to-body>
      <div v-if="taskDetail" class="task-detail">
        <!-- 基本信息 -->
        <el-card class="mb-3" shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">基本信息</span>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="任务ID">{{ taskDetail.taskId }}</el-descriptions-item>
            <el-descriptions-item label="任务名称">{{ taskDetail.taskName }}</el-descriptions-item>
            <el-descriptions-item label="任务类型">{{ taskDetail.taskType }}</el-descriptions-item>
            <el-descriptions-item label="目标日期">{{ taskDetail.targetDate }}</el-descriptions-item>
            <el-descriptions-item label="实际日期">{{ taskDetail.foundDate }}</el-descriptions-item>
            <el-descriptions-item label="任务状态">
              <el-tag :type="getStatusType(taskDetail.taskStatus)">
                {{ getStatusText(taskDetail.taskStatus) }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 缓存信息 -->
        <el-card class="mb-3" shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">缓存信息</span>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="缓存来源">
              <el-tag :type="taskDetail.cacheSource === 'cache' ? 'success' : 'info'">
                {{ taskDetail.cacheSource === 'cache' ? '缓存命中' : 'GEE下载' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="缓存命中率">
              <el-progress :percentage="taskDetail.cacheHitRate || 0" :color="getHitRateColor(taskDetail.cacheHitRate)" />
            </el-descriptions-item>
            <el-descriptions-item label="瓦片数量">{{ taskDetail.tileCount }}</el-descriptions-item>
            <el-descriptions-item label="瓦片ID" :span="3">
              <el-tag v-for="tileId in taskDetail.tileIds" :key="tileId" class="mr-2">{{ tileId }}</el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 数据信息 -->
        <el-card class="mb-3" shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">数据信息</span>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="云覆盖率">{{ taskDetail.cloudCover }}%</el-descriptions-item>
            <el-descriptions-item label="总像素数">{{ taskDetail.totalPixels }}</el-descriptions-item>
            <el-descriptions-item label="有效像素数">{{ taskDetail.validPixels }}</el-descriptions-item>
            <el-descriptions-item label="处理时间">{{ taskDetail.processingTime }}秒</el-descriptions-item>
            <el-descriptions-item label="文件名称">{{ taskDetail.fileName }}</el-descriptions-item>
            <el-descriptions-item label="是否过期">
              <el-tag :type="taskDetail.isExpired ? 'danger' : 'success'">
                {{ taskDetail.isExpired ? '已过期' : '有效' }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 模型预测结果 -->
        <el-card shadow="never" v-if="taskDetail.predictions && taskDetail.predictions.length">
          <template #header>
            <div class="card-header">
              <span class="card-title">模型预测结果 ({{ taskDetail.modelsSuccessful }}/{{ taskDetail.modelsTotal }})</span>
            </div>
          </template>
          
          <el-row :gutter="20">
            <el-col 
              v-for="prediction in taskDetail.predictions" 
              :key="prediction.predictionId"
              :xs="24" :sm="12" :md="8" :lg="6"
              class="mb-3"
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
                        <el-icon><Picture /></el-icon>
                      </div>
                    </template>
                  </el-image>
                  <div v-else class="image-slot">
                    <el-icon><Picture /></el-icon>
                    <div>暂无图片</div>
                  </div>
                </div>

                <!-- 模型信息 -->
                <div class="model-info">
                  <div class="model-name">
                    <el-tag :type="prediction.success ? 'success' : 'danger'" size="small">
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
        </el-card>
      </div>
      
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 行政区管控对话框 -->
    <RegionControlDialog ref="regionControlDialogRef" @refresh="getList" />
  </div>
</template>

<script setup name="GeePlot">
import { listPlot, getPlot, delPlot, createPlot, updatePlot, getPlotTasks, getPlotDates, toggleMonitorStatus } from "@/api/gee/plot";
import { listApp } from "@/api/gee/app";
import { getResult } from "@/api/gee/result";
import { cropTypeOptions } from "@/api/gee/crop";
import { Picture } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import RegionControlDialog from './components/RegionControlDialog.vue';

const { proxy } = getCurrentInstance();

const plotList = ref([]);
const appOptions = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");
const taskDialogVisible = ref(false);
const dateDialogVisible = ref(false);
const taskLoading = ref(false);
const dateLoading = ref(false);
const taskList = ref([]);
const dateList = ref([]);
const currentPlot = ref(null);
const dateRange = ref([]);
const detailDialogVisible = ref(false);
const taskDetail = ref(null);
const regionControlDialogRef = ref(null);

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    plotName: undefined,
    appId: undefined,
    monitorStatus: '',
    cropType: undefined
  },
  rules: {
    appId: [
      { required: true, message: "所属应用不能为空", trigger: "change" }
    ],
    plotName: [
      { required: true, message: "地块名称不能为空", trigger: "blur" }
    ],
    geometry: [
      { required: true, message: "几何信息不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询地块列表 */
function getList() {
  loading.value = true;
  listPlot(queryParams.value).then(response => {
    plotList.value = response.result.rows;
    total.value = response.result.total;
    loading.value = false;
  });
}

/** 查询应用列表 */
function getAppList() {
  listApp({ pageNum: 1, pageSize: 100 }).then(response => {
    appOptions.value = response.result.rows;
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
    plotId: undefined,
    appId: undefined,
    plotName: undefined,
    geometry: undefined,
    description: undefined,
    cropType: undefined,
    adcode: undefined,
    monitorStartDate: undefined,
    monitorEndDate: undefined,
    autoUpdate: true
  };
  proxy.resetForm("plotRef");
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
  ids.value = selection.map(item => item.plotId);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加地块";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const plotId = row.plotId || ids.value;
  getPlot(plotId).then(response => {
    form.value = response.result;
    open.value = true;
    title.value = "修改地块";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["plotRef"].validate(valid => {
    if (valid) {
      if (form.value.plotId != undefined) {
        updatePlot(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        createPlot(form.value).then(response => {
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
  const plotIds = row.plotId || ids.value;
  proxy.$modal.confirm('是否确认删除地块编号为"' + plotIds + '"的数据项？').then(function() {
    return delPlot(plotIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

/** 查看任务列表 */
function handleViewTasks(row) {
  currentPlot.value = row;
  taskDialogVisible.value = true;
  taskLoading.value = true;
  
  getPlotTasks(row.plotId).then(response => {
    taskList.value = response.result.rows || [];
    taskLoading.value = false;
  }).catch(() => {
    taskLoading.value = false;
  });
}

/** 查看可用日期 */
function handleViewDates(row) {
  currentPlot.value = row;
  dateDialogVisible.value = true;
  
  // 设置默认时间范围（当年）
  const year = new Date().getFullYear();
  dateRange.value = [`${year}-01-01`, `${year}-12-31`];
  
  fetchAvailableDates();
}

/** 获取可用日期 */
function fetchAvailableDates() {
  if (!currentPlot.value) return;
  
  dateLoading.value = true;
  const [startDate, endDate] = dateRange.value;
  
  getPlotDates({
    plotId: currentPlot.value.plotId,
    startDate,
    endDate
  }).then(response => {
    // 将日期数组转换为对象数组，并统计每个日期的任务数
    const dates = response.result || [];
    dateList.value = dates.map(date => {
      // 统计该日期的任务数
      const taskCount = taskList.value.filter(task => {
        // 这里需要重新获取完整任务列表来统计
        return true; // 暂时显示为1
      }).length || 1;
      return { date, taskCount };
    });
    dateLoading.value = false;
  }).catch(() => {
    dateLoading.value = false;
  });
}

/** 查看任务详情 */
function viewTaskDetail(taskId) {
  // 获取任务详情并显示对话框
  getResult(taskId).then(response => {
    taskDetail.value = response.result;
    detailDialogVisible.value = true;
  }).catch(() => {
    ElMessage.error("获取任务详情失败");
  });
}

/** 任务行点击 */
function handleTaskRowClick(row) {
  viewTaskDetail(row.taskId);
}

/** 查看日期的任务列表 */
function viewDateTasks(date) {
  if (!currentPlot.value) return;
  
  // 先获取该地块的所有任务
  taskLoading.value = true;
  getPlotTasks(currentPlot.value.plotId).then(response => {
    const allTasks = response.result.rows || [];
    
    // 筛选该日期的任务（比较实际日期 foundDate）
    const filteredTasks = allTasks.filter(task => {
      // 如果有实际日期，使用实际日期比较；否则使用目标日期（兼容旧数据）
      const taskDate = task.foundDate || task.targetDate;
      return taskDate === date;
    });
    
    taskLoading.value = false;
    
    if (filteredTasks.length > 0) {
      // 如果有任务，显示在任务对话框中
      taskList.value = filteredTasks;
      taskDialogVisible.value = true;
      dateDialogVisible.value = false; // 关闭日期对话框
    } else {
      // 如果没有任务，显示提示
      ElMessage.warning(`${date} 没有找到相关任务`);
    }
  }).catch(() => {
    taskLoading.value = false;
    ElMessage.error('获取任务列表失败');
  });
}

/** 日期行点击 */
function handleDateRowClick(row) {
  viewDateTasks(row.date);
}

/** 获取状态类型 */
function getStatusType(status) {
  const statusMap = {
    '0': 'info',
    '1': 'warning',
    '2': 'success',
    '3': 'danger',
    '4': 'info'
  };
  return statusMap[status];
}

/** 获取状态文本 */
function getStatusText(status) {
  const statusMap = {
    '0': '待处理',
    '1': '处理中',
    '2': '成功',
    '3': '失败',
    '4': '已取消'
  };
  return statusMap[status];
}

/** 获取缓存命中率颜色 */
function getHitRateColor(rate) {
  if (rate >= 80) return '#67C23A';
  if (rate >= 50) return '#E6A23C';
  return '#F56C6C';
}

/** 获取图片URL */
function getImageUrl(path) {
  return path;
}

/** 切换监测状态 */
async function handleToggleStatus(row) {
  const statusText = row.monitorStatus === 1 ? '开启' : '关闭';
  try {
    await ElMessageBox.confirm(
      `确认${statusText}地块"${row.plotName}"的监测吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    );
    
    await toggleMonitorStatus(row.plotId, row.monitorStatus);
    ElMessage.success(`已${statusText}监测`);
    getList();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败');
      // 恢复原状态
      row.monitorStatus = row.monitorStatus === 1 ? 0 : 1;
    } else {
      // 用户取消，恢复原状态
      row.monitorStatus = row.monitorStatus === 1 ? 0 : 1;
    }
  }
}

/** 获取作物类型名称 */
function getCropTypeName(cropType) {
  const crop = cropTypeOptions.find(item => item.value === cropType);
  return crop ? crop.label : cropType;
}

/** 行政区管控 */
function handleRegionControl() {
  regionControlDialogRef.value.open();
}

// 监听作物类型变化，自动填充监测周期
watch(() => form.value.cropType, (newVal) => {
  if (newVal) {
    const crop = cropTypeOptions.find(item => item.value === newVal);
    if (crop) {
      const [start, end] = crop.period.split(' ~ ');
      form.value.monitorStartDate = start;
      form.value.monitorEndDate = end;
    }
  }
});

getList();
getAppList();
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

.task-detail {
  padding: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.mb-3 {
  margin-bottom: 20px;
}

.mr-2 {
  margin-right: 8px;
}

.text-gray {
  color: #909399;
}

.help-text {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

.text-center {
  text-align: center;
}

.ml-2 {
  margin-left: 8px;
}

.model-card {
  height: 100%;
  transition: all 0.3s;
  padding: 0;
  overflow: hidden;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  }
}

.model-image-container {
  width: 100%;
  height: 200px;
  overflow: hidden;
  background-color: #f5f7fa;
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
  background-color: #f5f7fa;
  color: #909399;
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
  margin-bottom: 12px;
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
  color: #64748b;
}

.grade-proportion {
  color: #1e293b;
  font-weight: 500;
}
</style>
