# GEE 模块接口文档

该文档基于当前代码库分析生成，主要包含 GEE 相关业务模块的接口。

## 访问在线文档
如果后端服务已启动，可以直接访问以下地址获取交互式文档：
- **Swagger UI**: http://localhost:9099/docs
- **ReDoc**: http://localhost:9099/redoc
- **OpenAPI JSON**: http://localhost:9099/openapi.json

## GEE 接口详情

### 1. 任务管理 (Task)
**前缀**: `/gee/task`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取任务列表 |
| `POST` | `/` | 创建GEE任务 |
| `GET` | `/{task_id}` | 获取任务详情 |
| `POST` | `/{task_id}/cancel` | 取消任务 |
| `GET` | `/{task_id}/log` | 获取任务日志 |

### 2. 统计分析 (Stats)
**前缀**: `/gee/stats`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/dashboard` | 获取仪表盘统计 |
| `GET` | `/trend` | 获取趋势统计 |
| `GET` | `/performance` | 获取性能统计 |

### 3. 任务结果 (Result)
**前缀**: `/gee/result`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取结果列表 |
| `GET` | `/detail/{task_id}` | 获取结果详情 |
| `GET` | `/predictions/{task_id}` | 获取预测结果详情 |

### 4. 地块管理 (Plot)
**前缀**: `/gee/plot`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取地块列表 |
| `POST` | `/` | 创建地块 |
| `GET` | `/{plot_id}` | 获取地块详情 |
| `PUT` | `/{plot_id}` | 更新地块信息 |
| `DELETE` | `/{plot_id}` | 删除地块 |
| `GET` | `/{plot_id}/tasks` | 获取地块关联任务 |
| `GET` | `/{plot_id}/dates` | 获取地块可用日期 |

### 5. 瓦片优化 (Optimization)
**前缀**: `/gee/optimization`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `POST` | `/calculate` | 计算优化参数 |
| `POST` | `/trigger` | 触发优化任务 |
| `POST` | `/calculate-and-save` | 计算并保存 |
| `POST` | `/history` | 获取历史记录 |
| `GET` | `/history/{result_id}` | 获取特定历史详情 |

### 6. 自定义区域 (Custom Region)
**前缀**: `/gee/custom-region`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取区域列表 |
| `POST` | `/` | 创建区域 |
| `GET` | `/{region_id}` | 获取区域详情 |
| `PUT` | `/{region_id}` | 更新区域 |
| `DELETE` | `/{region_id}` | 删除区域 |

### 7. 配置管理 (Config)
**前缀**: `/gee/config`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取配置列表 |
| `GET` | `/groups` | 获取配置分组 |
| `GET` | `/{config_key}` | 获取指定配置 |
| `PUT` | `/{config_key}` | 更新配置 |
| `POST` | `/reload` | 重载配置 |

### 8. 缓存管理 (Cache)
**前缀**: `/gee/cache`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取缓存列表 |
| `GET` | `/stats` | 获取缓存统计 |
| `DELETE` | `/{tile_ids}` | 删除缓存 |
| `POST` | `/prefetch` | 预取缓存 |
| `GET` | `/hot` | 获取热点缓存 |
| `POST` | `/cleanup` | 清理缓存 |

### 9. 应用管理 (App)
**前缀**: `/gee/app`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/list` | 获取应用列表 |
| `POST` | `/` | 创建应用 |
| `GET` | `/{app_id}` | 获取应用详情 |
| `PUT` | `/{app_id}` | 更新应用 |
| `DELETE` | `/{app_id}` | 删除应用 |
| `POST` | `/{app_id}/regenerate-key` | 重新生成密钥 |
| `GET` | `/callback` | 应用回调接口 |

### 10. 账号池管理 (Accounts)
**前缀**: `/gee/accounts`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `GET` | `/` | 获取账号列表 |
| `GET` | `/stats` | 获取账号统计 |
| `GET` | `/{account_id}` | 获取账号详情 |

### 11. 每日更新 (Daily Update)
**前缀**: `/gee/daily-update`

| 方法 | 路径 | 描述 |
| :--- | :--- | :--- |
| `POST` | `/trigger` | 触发每日更新 |

## 请求说明
1. **Base URL**: `/dev-api` (开发环境)
2. **认证**: 多数接口需要 `Authorization: Bearer <token>` 或 `X-App-Key`
3. **格式**: 请求和响应通常为 JSON 格式

## 响应示例 (通用)
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": { ... }
}
```
