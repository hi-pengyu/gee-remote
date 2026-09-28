# PostgreSQL Database Design for GEE Callback Data

本文档描述了如何设计 PostgreSQL 数据库表来存储 GEE 服务的 callback 数据。

## 1. 需求分析

根据 `CALLBACK_AND_MODELS_SUMMARY.md`，回调数据主要包含两种状态：**成功** 和 **失败**。

### 成功数据示例
```json
{
  "task_id": "abc123-def456",
  "status": "success",
  "timestamp": "2025-11-11T10:32:15.123456",
  "result": {
    "success": true,
    "file_name": "workflow_...",
    "tif_path": "/path/to/file.tif",
    "result_path": "/path/to/result.json",
    "metadata": {
      "found_date": "2025-09-21",
      "cloud_cover": 3.5,
      "model_type": ["agb"],
      "processing_time_seconds": 125.3
    }
  }
}
```

### 失败数据示例
```json
{
  "task_id": "abc123-def456",
  "status": "failure",
  "timestamp": "2025-11-11T10:31:00.123456",
  "error": "GEE export failed: Invalid coordinates"
}
```

## 2. 数据库表设计

建议设计一张主表 `gee_tasks` 来存储任务记录，利用 PostgreSQL 的 `JSONB` 类型来灵活存储结果数据。

### 表结构: `gee_tasks`

| 字段名 | 类型 | 约束 | 说明 |
| :--- | :--- | :--- | :--- |
| `id` | `BIGSERIAL` | PRIMARY KEY | 自增主键 |
| `task_id` | `VARCHAR(64)` | UNIQUE, NOT NULL | Celery 任务 ID |
| `status` | `VARCHAR(20)` | NOT NULL | 任务状态 (success, failure, pending) |
| `model_type` | `VARCHAR(50)` | NULL | 模型类型 (如 agb, zg, all) |
| `target_date` | `DATE` | NULL | 目标日期 |
| `result_data` | `JSONB` | NULL | 完整的结果 JSON (包含文件路径、元数据等) |
| `error_message` | `TEXT` | NULL | 错误信息 |
| `created_at` | `TIMESTAMP` | DEFAULT NOW() | 记录创建时间 |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW() | 记录更新时间 |
| `callback_received_at` | `TIMESTAMP` | NULL | 收到回调的时间 |

### SQL 建表语句

```sql
-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建任务表
CREATE TABLE IF NOT EXISTS gee_tasks (
    id BIGSERIAL PRIMARY KEY,
    task_id VARCHAR(64) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'processing', 'success', 'failure')),
    
    -- 核心业务字段 (可选，从回调中提取以便查询)
    model_type VARCHAR(50),
    target_date DATE,
    
    -- 结果存储 (使用 JSONB 存储灵活结构)
    result_data JSONB,
    
    -- 错误信息
    error_message TEXT,
    
    -- 时间字段
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    callback_received_at TIMESTAMP WITH TIME ZONE
);

-- 创建索引以加速查询
CREATE INDEX idx_gee_tasks_task_id ON gee_tasks(task_id);
CREATE INDEX idx_gee_tasks_status ON gee_tasks(status);
CREATE INDEX idx_gee_tasks_created_at ON gee_tasks(created_at);
-- 如果经常查询 JSONB 内部字段，可以创建 GIN 索引
CREATE INDEX idx_gee_tasks_result_data ON gee_tasks USING GIN (result_data);

-- 应用触发器
CREATE TRIGGER update_gee_tasks_modtime
    BEFORE UPDATE ON gee_tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## 3. Python 代码示例 (SQLAlchemy)

如果你使用 Python (FastAPI/Flask) 来接收回调并存入数据库，可以使用 SQLAlchemy。

### 定义模型

```python
from sqlalchemy import Column, Integer, String, DateTime, Text, Date
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.sql import func
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class GeeTask(Base):
    __tablename__ = 'gee_tasks'

    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(String(64), unique=True, nullable=False, index=True)
    status = Column(String(20), nullable=False, index=True)
    
    model_type = Column(String(50), nullable=True)
    target_date = Column(Date, nullable=True)
    
    result_data = Column(JSONB, nullable=True)
    error_message = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    callback_received_at = Column(DateTime(timezone=True), nullable=True)
```

### 插入/更新数据的逻辑

```python
from datetime import datetime
from sqlalchemy.orm import Session

def handle_callback(db: Session, callback_data: dict):
    """
    处理回调数据并存入数据库
    """
    task_id = callback_data.get("task_id")
    status = callback_data.get("status")
    timestamp_str = callback_data.get("timestamp")
    
    # 尝试查找现有记录 (如果任务提交时已经创建了记录)
    task_record = db.query(GeeTask).filter(GeeTask.task_id == task_id).first()
    
    if not task_record:
        # 如果没有记录，则创建新记录
        task_record = GeeTask(task_id=task_id)
        db.add(task_record)
    
    # 更新状态和时间
    task_record.status = status
    task_record.callback_received_at = datetime.fromisoformat(timestamp_str) if timestamp_str else datetime.now()
    
    if status == "success":
        result = callback_data.get("result", {})
        task_record.result_data = result
        
        # 尝试从 result 中提取元数据填充到列中 (方便查询)
        metadata = result.get("metadata", {})
        if "found_date" in metadata:
            task_record.target_date = datetime.strptime(metadata["found_date"], "%Y-%m-%d").date()
        
        # model_type 可能是列表或字符串
        m_type = metadata.get("model_type")
        if isinstance(m_type, list):
            task_record.model_type = ",".join(m_type)
        else:
            task_record.model_type = str(m_type)
            
    elif status == "failure":
        task_record.error_message = callback_data.get("error")
    
    db.commit()
    db.refresh(task_record)
    return task_record
```

## 4. 扩展建议

1.  **空间数据**: 如果需要基于地理位置查询任务，可以添加 PostGIS 支持：
    ```sql
    -- 添加 geometry 列
    ALTER TABLE gee_tasks ADD COLUMN geom GEOMETRY(Polygon, 4326);
    ```
2.  **分区**: 如果数据量非常大（百万级），可以考虑按 `created_at` 进行表分区（Partitioning）。
3.  **定期清理**: 建议设置定期任务清理过期的 `result_data` 或归档旧数据。
