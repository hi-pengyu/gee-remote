# 前端文件清单 - GEE 地块行政区管控功能

## ✅ 已创建的文件（4个）

### 1. API 接口层

```
src/api/gee/
├── plot.js          ✅ 已创建/更新
│   └── 新增功能：toggleMonitorStatus() - 切换地块监测状态
│
├── region.js        ✅ 新创建
│   ├── pauseRegion() - 暂停行政区监测
│   ├── resumeRegion() - 恢复行政区监测
│   ├── getPausedRegions() - 获取暂停列表
│   └── getRegionStats() - 获取行政区统计
│
└── crop.js          ✅ 新创建
    ├── getCropTypes() - 获取作物类型列表
    └── cropTypeOptions - 作物类型选项（前端常量）
```

### 2. 组件层

```
src/views/gee/plot/components/
└── RegionControlDialog.vue  ✅ 新创建
    ├── 暂停管理标签页
    ├── 暂停列表标签页
    ├── 影响范围预览
    └── 行政区代码说明
```

### 3. 文档

```
ruoyi-fastapi-frontend/
└── FRONTEND_IMPLEMENTATION_GUIDE.md  ✅ 新创建
    ├── 实施指南
    ├── API 调用示例
    ├── UI 设计建议
    └── 常见问题解答
```

---

## 📝 需要手动修改的现有文件

### 1. 地块列表页面

**文件：** `src/views/gee/plot/index.vue`

**需要添加的内容：**

#### 1.1 导入新的API和组件
```javascript
import { toggleMonitorStatus } from '@/api/gee/plot'
import { cropTypeOptions } from '@/api/gee/crop'
import RegionControlDialog from './components/RegionControlDialog.vue'
```

#### 1.2 添加搜索栏字段
```vue
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
```

#### 1.3 添加行政区管控按钮
```vue
<el-col :span="1.5">
  <el-button type="warning" icon="Setting" @click="handleRegionControl">
    行政区管控
  </el-button>
</el-col>
```

#### 1.4 添加表格列
```vue
<!-- 行政区列 -->
<el-table-column label="行政区" align="center" min-width="200">
  <template #default="scope">
    <span v-if="scope.row.province">
      {{ scope.row.province }} / {{ scope.row.city }} / {{ scope.row.district }}
    </span>
    <span v-else class="text-gray">未识别</span>
  </template>
</el-table-column>

<!-- 作物类型列 -->
<el-table-column label="作物类型" align="center" width="100">
  <template #default="scope">
    <el-tag v-if="scope.row.cropType" type="success">
      {{ getCropTypeName(scope.row.cropType) }}
    </el-tag>
    <span v-else class="text-gray">-</span>
  </template>
</el-table-column>

<!-- 监测周期列 -->
<el-table-column label="监测周期" align="center" width="150">
  <template #default="scope">
    <span v-if="scope.row.monitorStartDate && scope.row.monitorEndDate">
      {{ scope.row.monitorStartDate }} ~ {{ scope.row.monitorEndDate }}
    </span>
    <span v-else class="text-gray">全年</span>
  </template>
</el-table-column>

<!-- 监测状态列（开关） -->
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

<!-- 自动更新列 -->
<el-table-column label="自动更新" align="center" width="100">
  <template #default="scope">
    <el-tag :type="scope.row.autoUpdate ? 'success' : 'info'">
      {{ scope.row.autoUpdate ? '是' : '否' }}
    </el-tag>
  </template>
</el-table-column>
```

#### 1.5 添加方法
```javascript
// 切换监测状态
const handleToggleStatus = async (row) => {
  const statusText = row.monitorStatus === 1 ? '开启' : '关闭'
  try {
    await ElMessageBox.confirm(
      `确认${statusText}地块"${row.plotName}"的监测吗？`,
      '提示',
      { type: 'warning' }
    )
    
    await toggleMonitorStatus(row.plotId, row.monitorStatus)
    ElMessage.success(`已${statusText}监测`)
    getList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
      row.monitorStatus = row.monitorStatus === 1 ? 0 : 1
    } else {
      row.monitorStatus = row.monitorStatus === 1 ? 0 : 1
    }
  }
}

// 获取作物类型名称
const getCropTypeName = (cropType) => {
  const crop = cropTypeOptions.find(item => item.value === cropType)
  return crop ? crop.label : cropType
}

// 行政区管控
const regionControlDialog = ref(null)
const handleRegionControl = () => {
  regionControlDialog.value.open()
}
```

#### 1.6 添加组件引用
```vue
<template>
  <!-- 现有内容... -->
  
  <!-- 行政区管控对话框 -->
  <RegionControlDialog ref="regionControlDialog" @refresh="getList" />
</template>
```

---

### 2. 地块新增/编辑表单

**文件：** `src/views/gee/plot/components/PlotForm.vue` 或类似文件

**需要添加的字段：**

```vue
<template>
  <el-form :model="form" :rules="rules" ref="formRef">
    <!-- 现有字段... -->
    
    <!-- 作物类型 -->
    <el-form-item label="作物类型" prop="cropType">
      <el-select v-model="form.cropType" placeholder="请选择作物类型" clearable>
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

    <!-- 行政区代码（可选） -->
    <el-form-item label="行政区代码" prop="adcode">
      <el-input
        v-model="form.adcode"
        placeholder="可选，留空则自动识别"
        clearable
      />
      <div class="help-text">如：410100（郑州市市辖区），留空则根据坐标自动识别</div>
    </el-form-item>

    <!-- 监测周期 -->
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

    <!-- 自动更新 -->
    <el-form-item label="自动更新">
      <el-switch v-model="form.autoUpdate" />
      <span class="ml-2">启用后将参与每日自动更新</span>
    </el-form-item>
  </el-form>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { createPlot, updatePlot } from '@/api/gee/plot'
import { cropTypeOptions } from '@/api/gee/crop'

const form = reactive({
  appId: null,
  plotName: '',
  geometry: null,
  description: '',
  cropType: null,        // 新增
  adcode: null,          // 新增
  monitorStartDate: null,// 新增
  monitorEndDate: null,  // 新增
  autoUpdate: true       // 新增
})

// 监听作物类型变化，自动填充监测周期
watch(() => form.cropType, (newVal) => {
  if (newVal) {
    const crop = cropTypeOptions.find(item => item.value === newVal)
    if (crop) {
      const [start, end] = crop.period.split(' ~ ')
      form.monitorStartDate = start
      form.monitorEndDate = end
    }
  }
})
</script>

<style scoped>
.help-text {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

.ml-2 {
  margin-left: 8px;
}
</style>
```

---

## 🎨 样式建议

### 全局样式（可选）

```css
/* 灰色文本 */
.text-gray {
  color: #909399;
}

/* 帮助文本 */
.help-text {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

/* 居中文本 */
.text-center {
  text-align: center;
}

/* 左边距 */
.ml-2 {
  margin-left: 8px;
}

/* 下边距 */
.mb-3 {
  margin-bottom: 20px;
}
```

---

## 📋 实施步骤

### 第一步：复制新文件

将以下文件复制到项目中：
- ✅ `src/api/gee/plot.js`（覆盖）
- ✅ `src/api/gee/region.js`（新增）
- ✅ `src/api/gee/crop.js`（新增）
- ✅ `src/views/gee/plot/components/RegionControlDialog.vue`（新增）

### 第二步：修改地块列表页面

参考上面的代码，修改 `src/views/gee/plot/index.vue`：
1. 导入新的API和组件
2. 添加搜索栏字段
3. 添加表格列
4. 添加方法
5. 添加组件引用

### 第三步：修改地块表单

参考上面的代码，修改地块新增/编辑表单：
1. 添加作物类型选择
2. 添加行政区代码输入
3. 添加监测周期设置
4. 添加自动更新开关
5. 添加作物类型监听器

### 第四步：测试

1. 创建地块，检查是否自动识别行政区
2. 切换监测状态，检查是否生效
3. 打开行政区管控对话框，测试暂停/恢复功能
4. 检查作物类型选择是否自动填充监测周期

---

## ✅ 功能检查清单

### 核心功能
- [ ] 地块列表显示行政区信息
- [ ] 地块列表显示作物类型
- [ ] 地块列表显示监测周期
- [ ] 监测状态开关可用
- [ ] 行政区管控对话框可打开
- [ ] 暂停行政区功能可用
- [ ] 恢复行政区功能可用

### 表单功能
- [ ] 作物类型选择可用
- [ ] 选择作物类型后自动填充监测周期
- [ ] 行政区代码输入可用
- [ ] 自动更新开关可用
- [ ] 提交表单时包含新字段

### 用户体验
- [ ] 切换监测状态有确认提示
- [ ] 操作成功有成功提示
- [ ] 操作失败有错误提示
- [ ] 影响范围预览功能可用
- [ ] 行政区代码说明清晰

---

## 🐛 调试建议

### 1. 检查API调用

打开浏览器开发者工具 → Network 标签：
- 检查请求URL是否正确
- 检查请求参数是否完整
- 检查响应状态码和数据

### 2. 检查数据绑定

在Vue DevTools中：
- 检查组件data是否正确
- 检查props传递是否正确
- 检查computed属性是否计算正确

### 3. 检查后端数据

确保后端已经：
- ✅ 执行了数据库升级脚本
- ✅ 重启了FastAPI服务
- ✅ 配置了高德API（可选）

---

**版本：** 2.0.0  
**更新日期：** 2026-01-26  
**状态：** ✅ 已完成
