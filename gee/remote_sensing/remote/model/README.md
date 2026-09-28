# 模型文件说明

此文件夹用于存放本地预测模型文件。

## 📂 需要的模型文件

请将以下 `.pkl` 模型文件放置在此目录：

1. **zg_reg_model.pkl** - 株高(ZG)预测模型
2. **agb_reg_model.pkl** - 生物量(AGB)预测模型  
3. **hsl_reg_model.pkl** - 叶绿素(HSL)预测模型
4. **spad_reg_model.pkl** - SPAD预测模型
5. **N_reg_model.pkl** - 氮含量(N)预测模型
6. **P_reg_model.pkl** - 磷含量(P)预测模型
7. **K_reg_model.pkl** - 钾含量(K)预测模型

## 📝 模型文件格式要求

每个模型文件应该是使用 `joblib` 保存的字典，包含以下键：

```python
{
    "model": trained_model,        # 训练好的模型对象
    "scaler": StandardScaler(),    # 标准化器
    "feature_order": [...]         # 特征顺序列表（可选）
}
```

## 🔧 模型训练示例

```python
import joblib
from sklearn.preprocessing import StandardScaler

# 训练好模型后保存
model_data = {
    "model": your_trained_model,
    "scaler": your_fitted_scaler,
    "feature_order": ['feature1', 'feature2', ...]  # 可选
}

joblib.dump(model_data, 'model/agb_reg_model.pkl')
```

## 📊 支持的波段

确保模型训练时使用的波段与以下Sentinel-2波段一致：

- **B01** - Coastal aerosol (443 nm)
- **B02** - Blue (490 nm)
- **B03** - Green (560 nm)
- **B04** - Red (665 nm)
- **B05** - Vegetation Red Edge 1 (705 nm)
- **B06** - Vegetation Red Edge 2 (740 nm)
- **B08** - NIR (842 nm)
- **B8A** - Narrow NIR (865 nm)
- **B09** - Water vapour (945 nm)
- **B11** - SWIR 1 (1610 nm)
- **B12** - SWIR 2 (2190 nm)

## ⚠️ 注意事项

1. 模型文件必须以 `.pkl` 扩展名结尾
2. 文件名必须与上述列表完全一致
3. 确保模型使用的特征与代码中定义的一致
4. 模型文件较大时，不要提交到 Git 仓库（已在 .gitignore 中配置）

## 🚀 启动服务

确保所有模型文件都放置正确后，启动服务时会自动加载：

```bash
# 启动 FastAPI 服务
uvicorn app.main:app --host 0.0.0.0 --port 8000

# 启动 Celery Worker
celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo
```

如果模型加载失败，请检查：
- 模型文件是否存在
- 文件名是否正确
- 模型文件格式是否符合要求

