# GEE 地块行政区管控功能 - 前端实施指南

## 📋 前端需要添加的功能

### ✅ 已创建的文件

#### 1. API 接口文件（3个）

```
src/api/gee/
├── plot.js          # 地块API（已扩展）
├── region.js        # 行政区管控API（新增）
└── crop.js          # 作物类型API（新增）
```

#### 2. 组件文件（1个）

```
src/views/gee/plot/components/
└── RegionControlDialog.vue  # 行政区管控对话框组件（新增）
```

---

## 🔧 需要修改的现有文件

### 1. 地块列表页面

**文件：** `src/views/gee/plot/index.vue`

需要添加的功能：
- ✅ 显示行政区信息列（省/市/区）
- ✅ 显示作物类型列
- ✅ 显示监测周期列
- ✅ 监测状态开关（Switch组件）
- ✅ 行政区管控按钮
- ✅ 搜索栏添加监测状态和作物类型筛选

**参考代码片段：**

```vue
<template>
  <!-- 在表格中添加新列 -->
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
      <el-tag v-if="scope.row.cropType" type="success">
        {{ getCropTypeName(scope.row.cropType) }}
      </el-tag>
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
</template>

<script setup>
import { toggleMonitorStatus } from '@/api/gee/plot'
import { cropTypeOptions } from '@/api/gee/crop'
import RegionControlDialog from './components/RegionControlDialog.vue'

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
  } catch (error) {
    // 恢复原状态
    row.monitorStatus = row.monitorStatus === 1 ? 0 : 1
  }
}

// 行政区管控
const regionControlDialog = ref(null)
const handleRegionControl = () => {
  regionControlDialog.value.open()
}
</script>
```

---

### 2. 地块新增/编辑表单

**文件：** `src/views/gee/plot/components/PlotForm.vue` 或类似文件

需要添加的字段：
- ✅ 作物类型选择（cropType）
- ✅ 行政区代码输入（adcode，可选）
- ✅ 监测周期设置（monitorStartDate, monitorEndDate）
- ✅ 自动更新开关（autoUpdate）

**参考代码片段：**

```vue
<template>
  <el-form :model="form" :rules="rules" ref="formRef">
    <!-- 现有字段... -->
    
    <!-- 新增字段 -->
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

    <el-form-item label="行政区代码" prop="adcode">
      <el-input
        v-model="form.adcode"
        placeholder="可选，留空则自动识别"
        clearable
      />
      <div class="help-text">如：410100（郑州市市辖区）</div>
    </el-form-item>

    <el-form-item label="监测周期">
      <el-col :span="11">
        <el-input v-model="form.monitorStartDate" placeholder="MM-DD" />
      </el-col>
      <el-col :span="2" class="text-center">
        <span>~</span>
      </el-col>
      <el-col :span="11">
        <el-input v-model="form.monitorEndDate" placeholder="MM-DD" />
      </el-col>
      <div class="help-text">格式：MM-DD，如：04-01</div>
    </el-form-item>

    <el-form-item label="自动更新">
      <el-switch v-model="form.autoUpdate" />
      <span class="ml-2">启用后将参与每日自动更新</span>
    </el-form-item>
  </el-form>
</template>

<script setup>
import { cropTypeOptions } from '@/api/gee/crop'
import { createPlot } from '@/api/gee/plot'

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

// 提交表单
const submitForm = async () => {
  const valid = await formRef.value.validate()
  if (!valid) return
  
  const response = await createPlot(form)
  if (response.isSuccess) {
    ElMessage.success('创建成功')
    // 自动识别的行政区信息会在后端返回
  }
}
</script>
```

---

### 3. 行政区管控页面（可选）

如果需要独立的行政区管控页面，可以使用已创建的：
- `src/views/gee/regions/index.vue`（如果已存在，需要更新）

或者在地块列表页面中集成 `RegionControlDialog` 组件。

---

## 🎨 UI 设计建议

### 1. 地块列表页面布局

```
┌─────────────────────────────────────────────────────────┐
│  搜索栏                                                  │
│  [地块名称] [监测状态▼] [作物类型▼] [搜索] [重置]      │
├─────────────────────────────────────────────────────────┤
│  操作按钮                                                │
│  [+ 新增地块] [⚙️ 行政区管控]                           │
├─────────────────────────────────────────────────────────┤
│  地块列表表格                                            │
│  ┌────┬────────┬──────────┬────┬────┬────┬────┬────┐  │
│  │ID  │地块名称│行政区    │作物│周期│状态│更新│操作│  │
│  ├────┼────────┼──────────┼────┼────┼────┼────┼────┤  │
│  │001 │地块A   │河南/郑州 │玉米│04-09│🟢  │是  │... │  │
│  │002 │地块B   │河南/洛阳 │水稻│05-10│🔴  │否  │... │  │
│  └────┴────────┴──────────┴────┴────┴────┴────┴────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2. 监测状态开关

使用 `el-switch` 组件：
- 🟢 绿色 = 监测开启
- ⚪ 灰色 = 监测关闭
- 点击时弹出确认框

### 3. 行政区信息显示

```
河南省 / 郑州市 / 中原区
```

如果未识别：
```
未识别（灰色文字）
```

### 4. 作物类型标签

使用 `el-tag` 组件：
- 玉米 🌽 （绿色）
- 水稻 🌾 （蓝色）
- 小麦 🌾 （黄色）

---

## 📡 API 调用示例

### 1. 创建地块（自动识别行政区）

```javascript
import { createPlot } from '@/api/gee/plot'

const formData = {
  appId: 1,
  plotName: '河南玉米地块001',
  geometry: {
    type: 'Polygon',
    coordinates: [[[113.5, 34.5], [113.6, 34.5], ...]]
  },
  cropType: 'corn',  // 可选
  adcode: null       // 留空自动识别
}

const response = await createPlot(formData)
// 后端会自动识别行政区并设置监测周期
```

### 2. 切换地块监测状态

```javascript
import { toggleMonitorStatus } from '@/api/gee/plot'

// 关闭监测
await toggleMonitorStatus(plotId, 0)

// 开启监测
await toggleMonitorStatus(plotId, 1)
```

### 3. 暂停行政区

```javascript
import { pauseRegion } from '@/api/gee/region'

await pauseRegion({
  adcode: '41',  // 河南省
  reason: '极端天气预警'
})
```

### 4. 查看行政区统计

```javascript
import { getRegionStats } from '@/api/gee/region'

const response = await getRegionStats('410100')
// 返回：totalPlots, activePlots, pausedPlots, autoUpdatePlots
```

---

## 🔄 数据流程

### 创建地块流程

```
用户填写表单
    ↓
选择作物类型（可选）
    ↓
提交到后端
    ↓
后端自动识别行政区
    ↓
后端设置默认监测周期
    ↓
返回完整地块信息
    ↓
前端刷新列表
```

### 监测状态切换流程

```
用户点击开关
    ↓
弹出确认框
    ↓
调用 toggleMonitorStatus API
    ↓
后端更新数据库
    ↓
后端记录变更日志
    ↓
返回成功
    ↓
前端显示提示
```

---

## ✅ 实施检查清单

### 必须实现（核心功能）

- [ ] 地块列表显示行政区信息
- [ ] 地块列表显示监测状态开关
- [ ] 监测状态切换功能
- [ ] 地块表单添加作物类型选择
- [ ] 集成行政区管控对话框

### 推荐实现（增强体验）

- [ ] 地块列表添加作物类型筛选
- [ ] 地块列表添加监测状态筛选
- [ ] 地块表单显示监测周期
- [ ] 行政区管控页面（独立页面）
- [ ] 影响范围预览功能

### 可选实现（高级功能）

- [ ] 地图可视化（显示暂停区域）
- [ ] 批量操作（批量开启/关闭）
- [ ] 导出功能（导出地块列表）
- [ ] 统计图表（监测状态分布）

---

## 🎯 快速开始

### 步骤1：复制API文件

已创建的API文件：
- `src/api/gee/plot.js`（已扩展）
- `src/api/gee/region.js`（新增）
- `src/api/gee/crop.js`（新增）

### 步骤2：添加组件

已创建的组件：
- `src/views/gee/plot/components/RegionControlDialog.vue`

### 步骤3：修改现有页面

参考上面的代码片段，修改：
- 地块列表页面（添加新列和功能）
- 地块表单（添加新字段）

### 步骤4：测试

1. 创建地块，检查是否自动识别行政区
2. 切换监测状态，检查是否生效
3. 暂停行政区，检查地块是否被暂停
4. 查看每日更新日志，确认过滤逻辑正确

---

## 📝 注意事项

1. **行政区代码格式**：必须是纯数字，如 `410100`
2. **监测周期格式**：`MM-DD`，如 `04-01`
3. **作物类型**：使用预定义的代码（corn, rice, wheat等）
4. **监测状态**：1=开启，0=关闭
5. **前缀匹配**：暂停"41"会影响所有41开头的地块

---

## 🐛 常见问题

### Q1：行政区信息显示为"未识别"？

**原因：** 后端未配置高德API或PostGIS数据

**解决：** 
1. 配置高德地图API Key
2. 或导入行政区边界数据

### Q2：监测状态开关不生效？

**原因：** API调用失败或权限不足

**解决：**
1. 检查网络请求
2. 检查用户权限
3. 查看后端日志

### Q3：作物类型选择后监测周期没有自动填充？

**原因：** 前端需要监听作物类型变化

**解决：**
```javascript
watch(() => form.cropType, (newVal) => {
  const crop = cropTypeOptions.find(item => item.value === newVal)
  if (crop) {
    form.monitorStartDate = crop.period.split(' ~ ')[0]
    form.monitorEndDate = crop.period.split(' ~ ')[1]
  }
})
```

---

**版本：** 2.0.0  
**更新日期：** 2026-01-26
