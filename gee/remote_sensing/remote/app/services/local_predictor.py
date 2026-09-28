"""
本地预测模块 - 不再调用外部API，直接使用本地模型

从原 api.py 提取的预测器逻辑，适配到本地使用
"""
import os
import time
import logging
from typing import Dict, Optional
from enum import Enum
import traceback

import pandas as pd
import numpy as np
import joblib
from sklearn.preprocessing import StandardScaler


logger = logging.getLogger(__name__)


# ==================== 模型配置 ====================
MODEL_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "model")


class ModelType(str, Enum):
    """模型类型枚举"""
    ZG = "zg"
    AGB = "agb"
    HSL = "hsl"
    SPAD = "spad"
    N = "n"
    P = "p"
    K = "k"


# ==================== 基础预测器 ====================
class BasePredictor:
    """基础预测器类"""
    _instances = {}

    @classmethod
    def get_instance(cls, model_type: ModelType):
        """单例模式获取预测器实例"""
        if model_type not in cls._instances:
            cls._instances[model_type] = cls._load_model(model_type)
        return cls._instances[model_type]

    @staticmethod
    def _load_model(model_type: ModelType):
        """加载对应类型的模型"""
        model_map = {
            ModelType.ZG: ZGPredictor,
            ModelType.AGB: AGBPredictor,
            ModelType.HSL: HSLPredictor,
            ModelType.SPAD: SPADPredictor,
            ModelType.N: NPredictor,
            ModelType.P: PPredictor,
            ModelType.K: KPredictor
        }
        return model_map[model_type]()

    def __init__(self, model_path: str, model_name: str):
        """初始化预测器"""
        self.model_name = model_name
        self.model_path = os.path.join(MODEL_DIR, model_path)
        
        try:
            if not os.path.exists(self.model_path):
                raise FileNotFoundError(f"模型文件不存在: {self.model_path}")
            
            saved_data = joblib.load(self.model_path)
            self.model = saved_data["model"]
            self.scaler = saved_data["scaler"]
            self.feature_order = saved_data.get("feature_order", [])
            self.required_columns = set()
            logger.info(f"{model_name} 模型加载成功: {self.model_path}")
        except Exception as e:
            logger.error(f"模型加载失败 | 模型:{model_name} 路径:{self.model_path} 错误:{str(e)}\n{traceback.format_exc()}")
            raise RuntimeError(f"{model_name} 模型初始化失败: {str(e)}")

    def validate_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """验证数据"""
        # 检查必要列
        missing = self.required_columns - set(df.columns)
        if missing:
            raise ValueError(f"缺少必要列: {missing}")
        
        # 类型转换
        df = df[list(self.required_columns)].copy()
        for col in self.required_columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')
        
        # 空值检查
        if df.isnull().values.any():
            invalid_count = df.isnull().any(axis=1).sum()
            logger.warning(f"数据包含空值 | 无效行数:{invalid_count} 总行数:{len(df)}")
            raise ValueError(f"数据包含空值/无效值，无效行数: {invalid_count}")
        
        return df

    def prepare_features(self, df: pd.DataFrame) -> np.ndarray:
        """准备特征数据"""
        features = self._calculate_features(df)
        if self.feature_order:
            features = features[self.feature_order]
        return self.scaler.transform(features)

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """计算特征（子类实现）"""
        raise NotImplementedError

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        """计算错误情况下需要返回的特定指数（子类实现）"""
        raise NotImplementedError

    def predict(self, df: pd.DataFrame) -> Dict:
        """执行预测"""
        try:
            validated_df = self.validate_data(df)
            
            try:
                features = self.prepare_features(validated_df)
            except (ValueError, FloatingPointError) as fe:
                if "contains infinity" in str(fe) or "too large" in str(fe):
                    logger.warning(f"数值计算异常，返回植被指数 | 模型:{self.model_name} 错误:{str(fe)}")
                    return {
                        "status": "warning",
                        "message": str(fe),
                        "indices": self.calculate_error_indices(df),
                        "data": df,
                        "predictions": None
                    }
                raise

            start_time = time.time()
            predictions = self.model.predict(features)
            predict_time = time.time() - start_time

            logger.info(
                f"预测完成 | 模型:{self.model_name} "
                f"样本数:{len(features)} "
                f"耗时:{predict_time:.4f}s"
            )

            return {
                "status": "success",
                "data": validated_df,
                "predictions": predictions,
                "indices": self.calculate_error_indices(validated_df),
                "metadata": {
                    "samples": len(features),
                    "features": self.feature_order,
                    "predict_time": predict_time
                }
            }

        except ValueError as ve:
            logger.warning(f"数据验证失败，返回植被指数 | 模型:{self.model_name} 错误:{str(ve)}")
            return {
                "status": "warning",
                "message": str(ve),
                "indices": self.calculate_error_indices(df),
                "data": df,
                "predictions": None
            }
        except Exception as e:
            logger.error(f"预测失败 | 模型:{self.model_name} 错误:{str(e)}\n{traceback.format_exc()}")
            return {
                "status": "error",
                "message": str(e),
                "indices": self.calculate_error_indices(df) if hasattr(self, 'calculate_error_indices') else {},
                "data": df,
                "predictions": None
            }


# ==================== 具体模型实现 ====================

class ZGPredictor(BasePredictor):
    """株高预测模型"""
    def __init__(self):
        super().__init__("zg_reg_model.pkl", "ZG")
        self.required_columns = {'X', 'Y', 'B02', 'B03', 'B04', 'B08', 'B8A', 'B11'}

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df['NDWI'] = (df['B08'] - df['B11']) / (df['B08'] + df['B11'] + 0.00001)
        df['VARI'] = (df['B03'] - df['B04']) / (df['B03'] + df['B04'] - df['B02'] + 0.00001)
        return pd.DataFrame({
            'narrow_nir': df['B8A'],
            'nir': df['B08'],
            'ndwi': df['NDWI'],
            'swir': df['B11'],
            'vari': df['VARI']
        })

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            return {
                "NDWI": float(((df['B08'] - df['B11']) / (df['B08'] + df['B11'] + 0.00001)).mean()),
            }
        except Exception as e:
            logger.error(f"计算ZG模型指数失败: {str(e)}")
            return {"error": "Failed to calculate indices"}


class AGBPredictor(BasePredictor):
    """生物量预测模型"""
    def __init__(self):
        super().__init__("agb_reg_model.pkl", "AGB")
        self.required_columns = {'X', 'Y', 'B02', 'B03', 'B04', 'B08', 'B11'}

    def validate_data(self, df: pd.DataFrame) -> pd.DataFrame:
        df = super().validate_data(df)
        # 值域验证
        for band in ['B02', 'B03', 'B04', 'B08', 'B11']:
            df = df[df[band].between(0, 1)]
        return df

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df['ri'] = (df['B08'] - df['B03']) / (df['B08'] + df['B03'])
        df['gndvi'] = (df['B08'] - df['B03']) / (df['B08'] + df['B03'])
        df['dvi'] = (df['B08'] - df['B04'])
        df['evi'] = (2.5 * (df['B08'] - df['B04'])) / \
                    (df['B08'] + 6 * (df['B04']) + 1 - 7.5 * (df['B02'] + 0.000001))
        df['msi'] = (df['B11']) / (df['B08'] + 0.000001)
        return pd.DataFrame({
            'ri': df['ri'],
            'gndvi': df['gndvi'],
            'dvi': df['dvi'],
            'evi': df['evi'],
            'msi': df['msi']
        })

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            return {
                "RI": float(((df['B08']) / (df['B03'])-1).mean()),
            }
        except Exception as e:
            logger.error(f"计算AGB模型指数失败: {str(e)}")
            return {"error": "Failed to calculate indices"}


class HSLPredictor(BasePredictor):
    """叶绿素预测模型"""
    def __init__(self):
        super().__init__("hsl_reg_model.pkl", "HSL")
        self.required_columns = {'X', 'Y', 'B01', 'B8A', 'B11', 'B12', 'B06'}

    def validate_data(self, df: pd.DataFrame) -> pd.DataFrame:
        df = super().validate_data(df)
        for col in ['B01', 'B8A', 'B11', 'B12', 'B06']:
            df = df[df[col].between(0, 1)]
        return df

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        return pd.DataFrame({
            'narrow_nir': df['B8A'],
            'swir': df['B11'],
            'coastal_aerosol': df['B01'],
            'swir.1': df['B12'],
            'vegetation_red_edge.2': df['B06']
        })

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            return {
                "NDII": float(((df['B8A'] - df['B11']) / (df['B8A'] + df['B11'])).mean()),
            }
        except Exception as e:
            logger.error(f"计算HSL模型指数失败: {str(e)}")
            return {"error": "Failed to calculate indices"}


class SPADPredictor(BasePredictor):
    """SPAD预测模型"""
    def __init__(self):
        super().__init__("spad_reg_model.pkl", "SPAD")
        self.required_columns = {'X', 'Y', 'B01', 'B02', 'B05', 'B08', 'B11'}
        self.feature_order = ['swir', 'vegetation_red_edge', 'ndwi', 'msi', 'nir']

    def validate_data(self, df: pd.DataFrame) -> pd.DataFrame:
        df = super().validate_data(df)
        for band in ['B01', 'B02', 'B05', 'B08', 'B11']:
            df = df[df[band].between(0, 1)]
        return df

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df['ndwi'] = (df['B08'] - df['B11']) / (df['B08'] + df['B11'])
        df['msi'] = df['B11'] / df['B08']
        return pd.DataFrame({
            'swir': df['B11'],
            'vegetation_red_edge': df['B05'],
            'ndwi': df['ndwi'],
            'msi': df['msi'],
            'nir': df['B08']
        })[self.feature_order]

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            return {
                "MSI": float((df['B11'] / df['B08']).mean())
            }
        except Exception as e:
            logger.error(f"计算SPAD模型指数失败: {str(e)}")
            return {"error": "Failed to calculate indices"}


class NPredictor(BasePredictor):
    """氮含量预测模型"""
    def __init__(self):
        super().__init__("N_reg_model.pkl", "N")
        self.required_columns = {'X', 'Y', 'B01', 'B02', 'B03', 'B04', 'B08'}

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df['atsavi'] = (df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)
        df['osavi'] = (df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)
        return pd.DataFrame({
            'atsavi': df['atsavi'],
            'osavi': df['osavi'],
            'coastal_aerosol': df['B01'],
            'blue': df['B02'],
            'green': df['B03']
        })

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            return {
                "ATSAVI": float(((df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)).mean()),
            }
        except Exception as e:
            logger.error(f"计算N模型指数失败: {str(e)}")
            return {"error": "Failed to calculate indices"}


class PPredictor(BasePredictor):
    """磷含量预测模型"""
    def __init__(self):
        super().__init__("P_reg_model.pkl", "P")
        self.required_columns = {'X', 'Y', 'B01', 'B02', 'B03', 'B04', 'B08'}

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df['atsavi'] = (df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)
        df['osavi'] = (df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)
        return pd.DataFrame({
            'atsavi': df['atsavi'],
            'osavi': df['osavi'],
            'coastal_aerosol': df['B01'],
            'blue': df['B02'],
            'green': df['B03']
        })

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            return {
                "ATSAVI": float(((df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)).mean()),
                "OSAVI": float(((df['B08'] - df['B04']) / (df['B08'] + df['B04'] + 0.16)).mean())
            }
        except Exception as e:
            logger.error(f"计算P模型指数失败: {str(e)}")
            return {"error": "Failed to calculate indices"}


class KPredictor(BasePredictor):
    """钾含量预测模型"""
    def __init__(self):
        super().__init__("K_reg_model.pkl", "K")
        self.required_columns = {'X', 'Y', 'B01', 'B02', 'B04', 'B06', 'B08', 'B09'}

    def _calculate_features(self, df: pd.DataFrame) -> pd.DataFrame:
        try:
            # 安全计算EVI，防止数值溢出
            with np.errstate(all='ignore'):
                df['evi'] = 2.5 * (df['B08'] - df['B04']) / \
                            (df['B08'] + 6 * df['B04'] - 7 * df['B02'] + 1.0)
                # 处理可能的无限值或NaN
                df['evi'] = np.nan_to_num(df['evi'], nan=0.0, posinf=1.0, neginf=-1.0)

            return pd.DataFrame({
                'evi': df['evi'],
                'nir': df['B08'],
                'coastal_aerosol': df['B01'],
                'water_vapour': df['B09'],
                'vegetation_red_edge.1': df['B06']
            })
        except Exception as e:
            logger.error(f"特征计算失败，使用安全模式 | 模型:K 错误:{str(e)}")
            return self._calculate_safe_features(df)

    def _calculate_safe_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """安全模式下的特征计算"""
        try:
            with np.errstate(all='ignore'):
                evi = 2.5 * (df['B08'] - df['B04']) / \
                      (df['B08'] + 6 * df['B04'] - 7 * df['B02'] + 1.0)
                evi = np.nan_to_num(evi, nan=0.0, posinf=1.0, neginf=-1.0)
            return pd.DataFrame({'evi': evi})
        except Exception as e:
            logger.error(f"安全特征计算失败 | 模型:K 错误:{str(e)}")
            return pd.DataFrame({'evi': np.zeros(len(df))})

    def calculate_error_indices(self, df: pd.DataFrame) -> Dict[str, float]:
        try:
            with np.errstate(all='ignore'):
                evi = 2.5 * (df['B08'] - df['B04']) / \
                      (df['B08'] + 6 * df['B04'] - 7 * df['B02'] + 1.0)
                evi = np.nan_to_num(evi, nan=0.0, posinf=1.0, neginf=-1.0)
            return {
                "EVI": float(evi.mean())
            }
        except Exception as e:
            logger.error(f"计算K模型指数失败: {str(e)}")
            return {"EVI": 0.0}


# ==================== 辅助函数 ====================

def initialize_all_models():
    """初始化所有模型（可选，用于服务启动时预加载）"""
    logger.info("开始初始化所有预测模型...")
    for model_type in ModelType:
        try:
            BasePredictor.get_instance(model_type)
            logger.info(f"✓ {model_type.value.upper()} 模型初始化成功")
        except Exception as e:
            logger.error(f"✗ {model_type.value.upper()} 模型初始化失败: {str(e)}")
    logger.info("模型初始化完成")


def get_predictor(model_type: str) -> BasePredictor:
    """获取预测器实例"""
    try:
        model_enum = ModelType(model_type.lower())
        return BasePredictor.get_instance(model_enum)
    except ValueError:
        available_models = [mt.value for mt in ModelType]
        raise ValueError(f"不支持的模型类型: {model_type}. 可用模型: {available_models}")

