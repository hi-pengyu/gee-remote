# 回调机制实现文档

## ✅ 完成功能

### 1. **算法查询接口**
新增 `GET /api/v1/models` 接口，用于查询所有可用的预测模型。

#### 请求示例
```bash
curl http://localhost:8000/api/v1/models
```

#### 响应示例
```json
{
  "total": 7,
  "models": [
    {
      "code": "zg",
      "name": "株高",
      "description": "株高预测模型",
      "unit": "cm"
    },
    {
      "code": "agb",
      "name": "地上生物量",
      "description": "地上生物量预测模型",
      "unit": "g/m²"
    },
    {
      "code": "hsl",
      "name": "叶绿素含量",
      "description": "叶绿素含量预测模型",
      "unit": "mg/g"
    },
    {
      "code": "spad",
      "name": "SPAD值",
      "description": "SPAD值预测模型",
      "unit": "SPAD"
    },
    {
      "code": "n",
      "name": "氮含量",
      "description": "氮含量预测模型",
      "unit": "%"
    },
    {
      "code": "p",
      "name": "磷含量",
      "description": "磷含量预测模型",
      "unit": "%"
    },
    {
      "code": "k",
      "name": "钾含量",
      "description": "钾含量预测模型",
      "unit": "%"
    }
  ],
  "support_all": true,
  "message": "使用 model_type='all' 可以一次运行所有模型"
}
```

---

### 2. **回调机制**

#### 工作流程
```
客户端 → 业务端(提供callback_url) → GEE服务 → (处理1-2分钟) → POST callback_url ← GEE服务
                                                                              ↓
                                                                          业务端存储
                                                                              ↓
                                                                            客户端
```

#### 如何使用

##### 提交任务时提供 `callback_url`
```bash
curl -X POST http://localhost:8000/api/v1/workflow/run \
  -H "Content-Type: application/json" \
  -d '{
    "aoi_coords": [[86.038, 44.552], [86.039, 44.553]],
    "target_date": "2025-09-21",
    "model_type": "agb",
    "callback_url": "https://your-business-api.com/gee-callback"
  }'
```

##### 响应（立即返回）
```json
{
  "task_id": "abc123-def456-ghi789",
  "status": "pending",
  "message": "完整工作流任务已提交（模型: agb），正在队列中等待处理",
  "created_at": "2025-11-11T10:30:00"
}
```

---

#### 回调通知格式

##### 成功时的回调
当任务成功完成后，GEE服务会向 `callback_url` 发送 POST 请求：

```json
{
  "task_id": "abc123-def456-ghi789",
  "status": "success",
  "timestamp": "2025-11-11T10:32:15.123456",
  "result": {
    "success": true,
    "file_name": "workflow_2025-09-21_20251111_103000",
    "tif_path": "f:\\gee\\storage\\tif\\workflow_2025-09-21_20251111_103000.tif",
    "result_path": "f:\\gee\\storage\\results\\workflow_2025-09-21_20251111_103000_agb.json",
    "metadata": {
      "found_date": "2025-09-21",
      "cloud_cover": 3.5,
      "image_count": 1,
      "total_pixels": 150000,
      "valid_pixels": 148500,
      "geo_bounds": {
        "west": 86.038,
        "south": 44.552,
        "east": 86.040,
        "north": 44.554
      },
      "result_count": 148500,
      "model_type": ["agb"],
      "prediction_success": true,
      "indices": {
        "NDVI": { "min": 0.25, "max": 0.85, "mean": 0.65 },
        "EVI": { "min": 0.20, "max": 0.75, "mean": 0.55 }
      },
      "processing_time_seconds": 125.3
    }
  }
}
```

##### 失败时的回调
```json
{
  "task_id": "abc123-def456-ghi789",
  "status": "failure",
  "timestamp": "2025-11-11T10:31:00.123456",
  "error": "GEE export failed: Invalid coordinates"
}
```

##### 使用 `model_type='all'` 时的回调
```json
{
  "task_id": "abc123-def456-ghi789",
  "status": "success",
  "timestamp": "2025-11-11T10:35:00.123456",
  "result": {
    "success": true,
    "file_name": "workflow_2025-09-21_20251111_103000",
    "tif_path": "f:\\gee\\storage\\tif\\workflow_2025-09-21_20251111_103000.tif",
    "all_models": true,
    "all_models_results": [
      {
        "model_type": "zg",
        "success": true,
        "result_path": "...\\workflow_2025-09-21_20251111_103000_zg.json",
        "result_count": 148500
      },
      {
        "model_type": "agb",
        "success": true,
        "result_path": "...\\workflow_2025-09-21_20251111_103000_agb.json",
        "result_count": 148500
      }
      // ... 其他5个模型
    ],
    "metadata": {
      "found_date": "2025-09-21",
      "cloud_cover": 3.5,
      "image_count": 1,
      "total_pixels": 150000,
      "valid_pixels": 148500,
      "total_predictions": 1039500,
      "model_type": ["zg", "agb", "hsl", "spad", "n", "p", "k"],
      "models_count": {
        "total": 7,
        "successful": 7,
        "failed": 0
      },
      "successful_models": ["zg", "agb", "hsl", "spad", "n", "p", "k"],
      "failed_models": [],
      "processing_time_seconds": 145.8
    }
  }
}
```

---

#### 业务端回调接收示例

##### Node.js/Express
```javascript
app.post('/gee-callback', async (req, res) => {
  const { task_id, status, timestamp, result, error } = req.body;

  console.log(`收到GEE回调 - 任务: ${task_id}, 状态: ${status}`);

  if (status === 'success') {
    // 存储到数据库
    await db.tasks.update({
      where: { task_id },
      data: {
        status: 'completed',
        result: result,
        completed_at: new Date(timestamp)
      }
    });

    // 通知客户端（如WebSocket、推送通知等）
    notifyClient(task_id, result);

    console.log(`任务 ${task_id} 完成，结果已保存`);
  } else {
    // 记录失败
    await db.tasks.update({
      where: { task_id },
      data: {
        status: 'failed',
        error: error,
        failed_at: new Date(timestamp)
      }
    });

    console.error(`任务 ${task_id} 失败: ${error}`);
  }

  // 返回确认
  res.json({ status: 'ok', message: '回调已接收' });
});
```

##### Python/Flask
```python
from flask import Flask, request, jsonify

@app.route('/gee-callback', methods=['POST'])
def gee_callback():
    data = request.get_json()
    task_id = data['task_id']
    status = data['status']

    if status == 'success':
        result = data['result']
        # 存储到数据库
        db.tasks.update_one(
            {'task_id': task_id},
            {'$set': {
                'status': 'completed',
                'result': result,
                'completed_at': datetime.now()
            }}
        )
        print(f"任务 {task_id} 完成")
    else:
        error = data['error']
        db.tasks.update_one(
            {'task_id': task_id},
            {'$set': {
                'status': 'failed',
                'error': error,
                'failed_at': datetime.now()
            }}
        )
        print(f"任务 {task_id} 失败: {error}")

    return jsonify({'status': 'ok'})
```

---

## 🔑 关键特性

### 兼容性
✅ **完全向后兼容**: `callback_url` 是可选参数，不提供时系统正常工作（原有逻辑）

```bash
# 不使用回调（原有方式）
curl -X POST http://localhost:8000/api/v1/workflow/run \
  -H "Content-Type: application/json" \
  -d '{
    "aoi_coords": [[86.038, 44.552]],
    "target_date": "2025-09-21",
    "model_type": "agb"
  }'
```

### 错误处理
- 回调失败不会导致任务失败
- 超时时间: 30秒
- 自动重试: 不重试（避免重复通知）
- 日志记录: 所有回调尝试都会被记录

### 安全性
- 使用 HTTPS 回调 URL（推荐）
- 超时限制防止挂起
- User-Agent 标识: `GEE-Service-Callback/1.0`

---

## 📝 业务端集成建议

### 方案架构
```
客户端 (App/Web)
     ↓
业务端 API
     ↓ (提交任务，附带callback_url)
GEE服务
     ↓ (处理1-2分钟)
     ↓ (POST callback_url)
业务端 /gee-callback 接收
     ↓ (存储到数据库)
     ↓ (通知客户端)
客户端收到结果
```

### 数据库设计建议
```sql
CREATE TABLE gee_tasks (
    id SERIAL PRIMARY KEY,
    task_id VARCHAR(64) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL, -- pending/processing/completed/failed
    aoi_coords JSON NOT NULL,
    target_date DATE NOT NULL,
    model_type VARCHAR(20) NOT NULL,
    result JSON,
    error TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE INDEX idx_task_id ON gee_tasks(task_id);
CREATE INDEX idx_status ON gee_tasks(status);
CREATE INDEX idx_created_at ON gee_tasks(created_at);
```

### 客户端通知方式

#### 方式1: WebSocket（实时推送）
```javascript
// 业务端在收到回调后
io.emit(`task:${task_id}`, {
  status: 'completed',
  result: result
});

// 客户端监听
socket.on(`task:${task_id}`, (data) => {
  console.log('任务完成！', data.result);
  updateUI(data.result);
});
```

#### 方式2: 客户端轮询
```javascript
// 客户端定时查询
setInterval(async () => {
  const response = await fetch(`/api/tasks/${task_id}`);
  const data = await response.json();
  if (data.status === 'completed') {
    console.log('任务完成！', data.result);
    clearInterval(pollInterval);
  }
}, 5000); // 每5秒查询一次
```

#### 方式3: 推送通知（移动端）
```javascript
// 业务端在收到回调后
await sendPushNotification(userId, {
  title: 'GEE任务完成',
  body: `${model_type}模型预测已完成`,
  data: { task_id, result }
});
```

---

## 🧪 测试

运行测试脚本：
```bash
python test_callback.py
```

测试内容：
1. ✅ 查询可用算法接口
2. ✅ 不使用回调的兼容性测试
3. ✅ 使用回调的真实工作流测试（可选，耗时1-2分钟）

---

## 📊 性能说明

- **回调超时**: 30秒
- **回调重试**: 无（避免重复通知）
- **回调失败处理**: 记录日志，不影响任务结果
- **并发**: 支持多个任务同时回调

---

## ⚠️ 注意事项

### 业务端要求
1. **回调接口必须可访问**: 确保 GEE 服务能访问到回调 URL
2. **快速响应**: 回调接口应在 30 秒内响应
3. **幂等性**: 虽然不重试，但建议设计为幂等（以防未来添加重试）
4. **返回 200**: 业务端应返回 HTTP 200 表示接收成功

### 安全建议
1. **使用 HTTPS**: 生产环境建议使用 HTTPS 回调 URL
2. **验证来源**: 可以通过 User-Agent 或添加签名验证
3. **限流**: 业务端回调接口建议添加限流保护

### 故障处理
如果回调未收到：
1. 检查回调 URL 是否可访问
2. 检查 GEE 服务日志（搜索 "[回调]"）
3. 检查业务端日志是否收到请求
4. 验证回调 URL 格式是否正确

---

## 📚 相关文档

- [README.md](README.md) - 项目主文档
- [CONCURRENCY_CONTROL.md](CONCURRENCY_CONTROL.md) - 并发控制详细说明
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - 实施总结

---

**实施日期**: 2025-11-11
**版本**: 2.6.0
**状态**: ✅ 已完成
