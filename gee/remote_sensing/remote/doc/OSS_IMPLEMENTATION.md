# 阿里云OSS上传功能说明

## ✅ 功能概述

自动将处理完成的TIF文件和PNG可视化图片上传到阿里云OSS（对象存储服务），并在上传成功后删除本地文件以节省磁盘空间。

---

## 🏗️ 工作流程

```
GEE下载影像 → 数据处理 → 预测 → 生成PNG
                                      ↓
                            [OSS上传功能（可选）]
                                      ↓
            上传TIF文件到OSS → 上传PNG文件到OSS
                                      ↓
                        上传成功 → 删除本地文件 (可选)
                                      ↓
                    返回OSS URL给业务端
```

---

## ⚙️ 配置说明

### 1. 环境变量配置

在 `.env` 文件中添加以下配置：

```bash
# 阿里云OSS配置
OSS_ACCESS_KEY_ID=your-oss-access-key-id
OSS_ACCESS_KEY_SECRET=your-oss-access-key-secret
OSS_ENDPOINT=oss-cn-hangzhou.aliyuncs.com
OSS_BUCKET_NAME=your-bucket-name
OSS_ENABLE_UPLOAD=true
OSS_DELETE_LOCAL=true
```

### 2. 配置项说明

| 配置项 | 说明 | 示例值 | 必填 |
|--------|------|--------|------|
| `OSS_ACCESS_KEY_ID` | 阿里云AccessKey ID | `LTAI5t...` | 是 |
| `OSS_ACCESS_KEY_SECRET` | 阿里云AccessKey Secret | `mKxY...` | 是 |
| `OSS_ENDPOINT` | OSS区域节点 | `oss-cn-hangzhou.aliyuncs.com` | 是 |
| `OSS_BUCKET_NAME` | OSS Bucket名称 | `my-gee-bucket` | 是 |
| `OSS_ENABLE_UPLOAD` | 是否启用OSS上传 | `true`/`false` | 否（默认false） |
| `OSS_DELETE_LOCAL` | 上传成功后是否删除本地文件 | `true`/`false` | 否（默认true） |

### 3. 区域节点（Endpoint）

常用的阿里云OSS区域节点：

| 地域 | Endpoint |
|------|----------|
| 杭州 | `oss-cn-hangzhou.aliyuncs.com` |
| 上海 | `oss-cn-shanghai.aliyuncs.com` |
| 北京 | `oss-cn-beijing.aliyuncs.com` |
| 深圳 | `oss-cn-shenzhen.aliyuncs.com` |
| 香港 | `oss-cn-hongkong.aliyuncs.com` |

完整列表请参考：[阿里云OSS访问域名](https://help.aliyun.com/document_detail/31837.html)

---

## 📦 安装依赖

```bash
pip install oss2==2.18.4
```

或使用项目的 requirements.txt：

```bash
pip install -r requirements.txt
```

---

## 🚀 使用方法

### 1. 自动上传（通过工作流）

OSS上传已集成到完整工作流中，只需启用配置即可自动上传：

```bash
# .env文件
OSS_ENABLE_UPLOAD=true
OSS_DELETE_LOCAL=true
```

提交任务后，系统会自动：
1. 下载GEE影像（TIF文件）
2. 进行数据处理和预测
3. 生成PNG可视化图片
4. **上传TIF和PNG到OSS**
5. **删除本地文件（如果启用）**
6. 返回OSS URL

### 2. 响应格式

启用OSS上传后，任务结果中会包含 `oss_upload` 字段：

```json
{
  "success": true,
  "file_name": "workflow_2025-09-21_...",
  "tif_path": null,  // 本地文件已删除
  "oss_upload": {
    "enabled": true,
    "total_uploaded": 8,  // 1个TIF + 7个PNG
    "total_deleted": 8,   // 已删除的本地文件数
    "tif_url": "https://your-bucket.oss-cn-hangzhou.aliyuncs.com/gee/2025/11/11/workflow_xxx.tif",
    "png_urls": [
      "https://your-bucket.oss-cn-hangzhou.aliyuncs.com/gee/2025/11/11/workflow_xxx_zg.png",
      "https://your-bucket.oss-cn-hangzhou.aliyuncs.com/gee/2025/11/11/workflow_xxx_agb.png",
      // ... 其他5个模型的PNG
    ]
  },
  "metadata": { /* 其他元数据 */ }
}
```

### 3. OSS文件路径结构

上传到OSS的文件按日期分类存储：

```
your-bucket/
└── gee/
    └── 2025/
        └── 11/
            └── 11/
                ├── workflow_2025-09-21_20251111_103000.tif
                ├── workflow_2025-09-21_20251111_103000_zg.png
                ├── workflow_2025-09-21_20251111_103000_agb.png
                ├── workflow_2025-09-21_20251111_103000_hsl.png
                ├── workflow_2025-09-21_20251111_103000_spad.png
                ├── workflow_2025-09-21_20251111_103000_n.png
                ├── workflow_2025-09-21_20251111_103000_p.png
                └── workflow_2025-09-21_20251111_103000_k.png
```

路径格式：`gee/{年}/{月}/{日}/{文件名}`

---

## 🔧 手动使用OSS服务

### 1. 上传单个文件

```python
from app.services.oss_service import OSSService

oss_service = OSSService()

# 上传文件
result = oss_service.upload_file(
    local_file_path="./storage/tif/test.tif",
    delete_local=True  # 上传成功后删除本地文件
)

if result['success']:
    print(f"上传成功！URL: {result['oss_url']}")
    print(f"文件大小: {result['file_size']} bytes")
    print(f"已删除本地文件: {result['deleted_local']}")
else:
    print(f"上传失败: {result['error']}")
```

### 2. 批量上传文件

```python
from app.services.oss_service import OSSService

oss_service = OSSService()

# 批量上传
file_paths = [
    "./storage/tif/image1.tif",
    "./storage/results/images/result1.png",
    "./storage/results/images/result2.png"
]

result = oss_service.upload_files(
    file_paths=file_paths,
    delete_local=True
)

print(f"总数: {result['total']}")
print(f"成功: {result['successful']}")
print(f"失败: {result['failed']}")

for r in result['results']:
    if r['success']:
        print(f"✓ {r['oss_url']}")
    else:
        print(f"✗ {r['local_file_path']}: {r['error']}")
```

### 3. 上传TIF和相关PNG

```python
from app.services.oss_service import OSSService

oss_service = OSSService()

# 上传TIF文件和PNG文件
result = oss_service.upload_tif_and_pngs(
    tif_path="./storage/tif/image.tif",
    png_paths=[
        "./storage/results/images/result_zg.png",
        "./storage/results/images/result_agb.png"
    ],
    delete_local=True
)

print(f"已上传: {result['total_uploaded']} 个文件")
print(f"已删除: {result['total_deleted']} 个本地文件")
print(f"TIF URL: {result['tif_result']['oss_url']}")
print(f"PNG URLs: {[r['oss_url'] for r in result['png_results']]}")
```

### 4. 生成临时访问URL

```python
from app.services.oss_service import OSSService

oss_service = OSSService()

# 生成1小时有效的临时URL
temp_url = oss_service.get_object_url(
    oss_object_key="gee/2025/11/11/workflow_xxx.tif",
    expires=3600  # 1小时
)

print(f"临时URL: {temp_url}")
```

---

## 📊 性能和限制

### 性能指标
- **上传速度**: 取决于网络带宽和文件大小
- **典型TIF文件**: 10-50 MB，上传时间 2-10 秒
- **典型PNG文件**: 1-5 MB，上传时间 < 2 秒
- **并发上传**: 支持批量上传，自动管理连接

### 阿里云OSS限制
- **单文件最大**: 48.8 TB（PUT Object）
- **Bucket数量**: 默认100个
- **带宽**: 无限制（按流量计费）

---

## ⚠️ 注意事项

### 1. OSS权限配置

确保AccessKey具有以下权限：
- `oss:PutObject` - 上传文件
- `oss:GetObject` - 读取文件（生成临时URL时需要）
- `oss:DeleteObject` - 删除文件（如需要）

### 2. Bucket公共访问设置

**推荐设置**：
- **私有（Private）**: 文件不公开，需要通过临时URL访问（更安全）
- **公共读（Public Read）**: 文件可直接通过URL访问（方便但不安全）

### 3. 费用说明

阿里云OSS费用包括：
- **存储费用**: 按实际存储量计费
- **流量费用**: 外网下载流量计费
- **请求费用**: PUT/GET请求次数计费

建议：
- 定期清理不需要的文件
- 使用生命周期规则自动删除过期文件
- 使用CDN加速下载以降低流量费用

### 4. 错误处理

OSS上传失败不会导致任务失败：
- 上传失败会记录日志和警告
- 任务仍会正常完成
- 本地文件不会被删除（如果上传失败）
- 结果中会包含错误信息

示例失败响应：
```json
{
  "oss_upload": {
    "enabled": true,
    "error": "Connection timeout",
    "total_uploaded": 0,
    "total_deleted": 0
  }
}
```

### 5. 安全建议

- **不要**将AccessKey硬编码在代码中
- **使用**环境变量或配置文件存储凭证
- **定期轮换**AccessKey
- **使用**RAM角色（如果在阿里云ECS上运行）
- **启用**Bucket访问日志

---

## 🧪 测试

### 1. 测试OSS连接

```python
from app.services.oss_service import OSSService

try:
    oss_service = OSSService()
    print("✓ OSS连接成功")
except Exception as e:
    print(f"✗ OSS连接失败: {e}")
```

### 2. 测试上传功能

```bash
# 启用OSS上传
export OSS_ENABLE_UPLOAD=true
export OSS_DELETE_LOCAL=false  # 测试时建议先不删除本地文件

# 提交测试任务
curl -X POST http://localhost:8000/api/v1/workflow/run \
  -H "Content-Type: application/json" \
  -d '{
    "aoi_coords": [[86.038, 44.552], [86.040, 44.554]],
    "target_date": "2025-09-21",
    "model_type": "agb"
  }'

# 查询任务结果
curl http://localhost:8000/api/v1/tasks/{task_id}
```

### 3. 验证OSS文件

访问阿里云OSS控制台 → 选择Bucket → 查看 `gee/` 目录下的文件

---

## 🔄 迁移指南

### 从本地存储迁移到OSS

#### 步骤1: 配置OSS
```bash
# .env
OSS_ENABLE_UPLOAD=true
OSS_DELETE_LOCAL=false  # 暂时保留本地文件
```

#### 步骤2: 测试运行
提交几个测试任务，确保OSS上传正常工作

#### 步骤3: 迁移现有文件（可选）
```python
from app.services.oss_service import OSSService
import os

oss_service = OSSService()

# 迁移TIF文件
tif_dir = "./storage/tif"
for file_name in os.listdir(tif_dir):
    if file_name.endswith('.tif'):
        file_path = os.path.join(tif_dir, file_name)
        result = oss_service.upload_file(file_path, delete_local=False)
        if result['success']:
            print(f"✓ {file_name} 已迁移")
```

#### 步骤4: 启用自动删除
```bash
# .env
OSS_DELETE_LOCAL=true  # 启用自动删除本地文件
```

---

## 📚 相关文档

- [阿里云OSS官方文档](https://help.aliyun.com/product/31815.html)
- [oss2 Python SDK文档](https://github.com/aliyun/aliyun-oss-python-sdk)
- [README.md](README.md) - 项目主文档
- [CALLBACK_IMPLEMENTATION.md](CALLBACK_IMPLEMENTATION.md) - 回调机制说明

---

## 🐛 故障排查

### 问题1: 上传失败 - 权限不足

**错误**: `AccessDenied`

**解决**:
- 检查AccessKey是否正确
- 确认AccessKey具有 `oss:PutObject` 权限
- 在阿里云RAM控制台添加权限策略

### 问题2: 上传失败 - Bucket不存在

**错误**: `NoSuchBucket`

**解决**:
- 检查 `OSS_BUCKET_NAME` 配置是否正确
- 确认Bucket已创建
- 检查Endpoint是否匹配Bucket所在区域

### 问题3: 上传失败 - 网络超时

**错误**: `ConnectionTimeout`

**解决**:
- 检查网络连接
- 尝试更换Endpoint（使用内网Endpoint如果在阿里云ECS上）
- 增加超时时间（在代码中修改）

### 问题4: 文件已上传但本地未删除

**解决**:
- 检查日志，查看删除失败原因
- 确认文件权限（是否有删除权限）
- 手动删除本地文件

---

**实施日期**: 2025-11-11
**版本**: 2.7.0
**状态**: ✅ 已完成
