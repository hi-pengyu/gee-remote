"""预测服务 - 使用本地预测模块"""
import os
import json
import pandas as pd
from typing import Dict, Optional
from datetime import datetime
from app.config import settings
from app.utils.logger import celery_logger
from app.services.local_predictor import get_predictor, ModelType
from app.services.visualization_service import VisualizationService, MODEL_NAMES


class PredictionService:
    """预测服务类 - 使用本地预测模块"""
    
    def __init__(self):
        """初始化预测服务"""
        celery_logger.info("预测服务初始化（使用本地模型）")
        self.visualization_service = VisualizationService()
    
    def predict_from_dataframe(
        self,
        df: pd.DataFrame,
        model_type: str,
        file_name: str,
        tif_path: str = None,
        geo_bounds: Dict = None
    ) -> Dict:
        """
        使用本地模型进行预测（直接接收DataFrame）

        Args:
            df: 包含遥感数据的DataFrame
            model_type: 模型类型（agb, k, n, p, zg, hsl, spad）
            file_name: 用于保存结果的文件名
            tif_path: 原始TIF文件路径（可选，用于生成GeoTIFF）
            geo_bounds: 地理坐标边界（可选）

        Returns:
            {
                'success': bool,
                'result_path': str,
                'result_count': int,
                'message': str (optional),
                'indices': dict (植被指数)
            }
        """
        celery_logger.info(f"[Predict] 开始本地预测: {model_type}")
        celery_logger.info(f"[Predict] 数据行数: {len(df)}")
        
        try:
            # 获取预测器
            predictor = get_predictor(model_type)
            
            # 执行预测
            celery_logger.info(f"[Predict] 使用模型: {predictor.model_name}")
            result = predictor.predict(df)
            
            # 构建返回结果
            result_data = {
                "status": result["status"],
                "model": model_type,
                "timestamp": datetime.now().isoformat(),
                "metadata": result.get("metadata", {})
            }
            
            # 根据预测状态处理结果
            if result["status"] == "success":
                # 预测成功，构建结果列表
                predictions = result["predictions"]
                data_df = result["data"]
                
                result_data["results"] = [{
                    "X": int(row['X']),
                    "Y": int(row['Y']),
                    "prediction": round(float(pred), 4)
                } for (_, row), pred in zip(data_df.iterrows(), predictions)]
                
                result_data["indices"] = result.get("indices", {})
                result_count = len(predictions)
                
                celery_logger.info(f"[Predict] ✓ 预测成功！结果数量: {result_count}")
                
            elif result["status"] == "warning":
                # 预测警告（例如数据验证失败），返回植被指数
                result_data["message"] = result.get("message", "数据验证警告")
                result_data["indices"] = result.get("indices", {})
                result_data["results"] = []
                result_count = 0
                
                celery_logger.warning(f"[Predict] ⚠ 预测警告: {result_data['message']}")
                
            else:
                # 预测失败
                result_data["message"] = result.get("message", "预测失败")
                result_data["indices"] = result.get("indices", {})
                result_data["results"] = []
                result_count = 0
                
                celery_logger.error(f"[Predict] ✗ 预测失败: {result_data['message']}")
            
            # 保存预测结果到JSON文件
            result_filename = f"prediction_{model_type}_{file_name}.json"
            result_path = os.path.join(settings.STORAGE_RESULTS_DIR, result_filename)
            
            with open(result_path, 'w', encoding='utf-8') as f:
                json.dump(result_data, f, ensure_ascii=False, indent=2)
            
            celery_logger.info(f"[Predict] 结果保存至: {result_path}")

            # 生成可视化图像（仅当预测成功时）
            visualization_result = None
            grade_colors = None
            if result["status"] == "success" and result_count > 0:
                celery_logger.info(f"[Predict] 开始生成可视化图像（PNG和GeoTIFF）...")
                vis_full_result = self.visualization_service.create_colored_map(
                    json_path=result_path,
                    model_type=model_type,
                    method='quantile',
                    tif_path=tif_path,  # 传递TIF路径
                    geo_bounds=geo_bounds  # 传递地理坐标
                    # proportions 参数已移除，将使用模型特定的默认比例
                )
                if vis_full_result.get('success'):
                    celery_logger.info(f"[Predict] ✓ 可视化图像已生成: {vis_full_result['image_path']}")
                    if vis_full_result.get('tif_path'):
                        celery_logger.info(f"[Predict] ✓ GeoTIFF已生成: {vis_full_result['tif_path']}")

                    # 从可视化统计中获取实际的等级像素分布
                    stats = vis_full_result.get('statistics', {})
                    grade_pixel_counts = stats.get('grade_pixel_counts', {})
                    total_pixels = stats.get('valid_pixels', 0)

                    # 使用实际统计生成 grade_colors
                    from app.services.visualization_service import VisualizationService
                    grade_colors = VisualizationService.get_grade_colors_from_stats(
                        model_type=model_type,
                        grade_pixel_counts=grade_pixel_counts,
                        total_pixels=total_pixels
                    )

                    # 精简可视化结果，只保留必要字段
                    visualization_result = {
                        'success': True,
                        'image_path': vis_full_result['image_path'],
                        'tif_path': vis_full_result.get('tif_path')  # 添加GeoTIFF路径
                    }
                else:
                    celery_logger.warning(f"[Predict] 可视化生成失败: {vis_full_result.get('message')}")
                    # 可视化失败时使用理论比例
                    from app.services.visualization_service import VisualizationService
                    grade_colors = VisualizationService.get_grade_colors(model_type)
                    visualization_result = {
                        'success': False,
                        'message': vis_full_result.get('message', '可视化生成失败')
                    }
            else:
                # 预测失败或无结果时使用理论比例
                from app.services.visualization_service import VisualizationService
                grade_colors = VisualizationService.get_grade_colors(model_type)

            # 准备返回的 prediction_result，移除 results 和 features 字段
            return_result_data = {
                "status": result_data["status"],
                "model": result_data["model"],
                # "timestamp": result_data["timestamp"],
                # "metadata": result_data.get("metadata", {}),
                # "indices": result_data.get("indices", {})
                # 不包含 results 和 features
            }

            # 如果有 message，也包含进去
            if "message" in result_data:
                return_result_data["message"] = result_data["message"]

            return {
                'success': result["status"] == "success",
                'model_name': MODEL_NAMES.get(model_type, model_type.upper()),  # 添加模型中文名
                'grade_colors': grade_colors,  # 使用实际统计的分级颜色
                'result_path': result_path,
                # 'result_count': result_count,
                # 'prediction_result': return_result_data,  # 返回精简版（不含results和features）
                # 'indices': result_data.get("indices", {}),
                'visualization': visualization_result  # 添加可视化结果
            }
            
        except ValueError as e:
            # 模型类型不支持或数据验证错误
            celery_logger.error(f"[Predict] 验证错误: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'result_count': 0
            }
        except Exception as e:
            celery_logger.error(f"[Predict] 预测失败: {str(e)}", exc_info=True)
            return {
                'success': False,
                'message': f'预测失败: {str(e)}',
                'result_count': 0
            }
    
    def predict(
        self,
        csv_path: str,
        model_type: str
    ) -> Dict:
        """
        从CSV文件进行预测（兼容旧接口）
        
        Args:
            csv_path: CSV 文件路径
            model_type: 模型类型
            
        Returns:
            {
                'success': bool,
                'result_path': str,
                'result_count': int
            }
        """
        celery_logger.info(f"[Predict] 从CSV文件预测: {csv_path}")
        
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"CSV 文件不存在: {csv_path}")
        
        # 读取CSV
        df = pd.read_csv(csv_path)
        
        # 提取文件名（不含扩展名）
        file_name = os.path.splitext(os.path.basename(csv_path))[0]
        
        # 调用DataFrame预测方法
        return self.predict_from_dataframe(df, model_type, file_name)

    def predict_all_models(
        self,
        df: pd.DataFrame,
        file_name: str,
        tif_path: str = None,
        geo_bounds: Dict = None
    ) -> Dict:
        """
        使用所有可用模型进行预测

        Args:
            df: 包含遥感数据的DataFrame
            file_name: 用于保存结果的文件名基础
            tif_path: 原始TIF文件路径（可选，用于生成GeoTIFF）
            geo_bounds: 地理坐标边界（可选）

        Returns:
            {
                'success': bool,
                'all_models_results': {
                    'zg': {...},
                    'agb': {...},
                    'hsl': {...},
                    'spad': {...},
                    'n': {...},
                    'p': {...},
                    'k': {...}
                },
                'total_predictions': int,
                'successful_models': list,
                'failed_models': list
            }
        """
        celery_logger.info("[Predict All] 开始运行所有模型预测")
        celery_logger.info(f"[Predict All] 数据行数: {len(df)}")

        all_results = {}
        successful_models = []
        failed_models = []
        total_predictions = 0

        # 遍历所有可用模型
        for model_type in settings.AVAILABLE_MODELS:
            celery_logger.info(f"[Predict All] 正在运行模型: {model_type}")

            try:
                # 调用单个模型预测
                result = self.predict_from_dataframe(
                    df=df,
                    model_type=model_type,
                    file_name=file_name,
                    tif_path=tif_path,  # 传递TIF路径
                    geo_bounds=geo_bounds  # 传递地理坐标
                )

                # 保存结果
                all_results[model_type] = result

                # 统计成功/失败
                if result.get('success', False):
                    successful_models.append(model_type)
                    total_predictions += result.get('result_count', 0)
                    celery_logger.info(f"[Predict All] ✓ 模型 {model_type} 预测成功")
                else:
                    failed_models.append(model_type)
                    celery_logger.warning(f"[Predict All] ✗ 模型 {model_type} 预测失败")

            except Exception as e:
                celery_logger.error(f"[Predict All] 模型 {model_type} 预测异常: {str(e)}", exc_info=True)
                failed_models.append(model_type)
                all_results[model_type] = {
                    'success': False,
                    'message': f'预测异常: {str(e)}',
                    'result_count': 0
                }

        # 汇总结果
        celery_logger.info(f"[Predict All] ===== 预测完成 =====")
        celery_logger.info(f"[Predict All] 成功模型数: {len(successful_models)}/{len(settings.AVAILABLE_MODELS)}")
        celery_logger.info(f"[Predict All] 成功模型: {', '.join(successful_models)}")
        if failed_models:
            celery_logger.warning(f"[Predict All] 失败模型: {', '.join(failed_models)}")
        celery_logger.info(f"[Predict All] 总预测数量: {total_predictions}")

        # 统计可视化成功数量
        visualization_success_count = sum(
            1 for result in all_results.values()
            if result.get('visualization', {}).get('success', False)
        )
        celery_logger.info(f"[Predict All] 可视化成功数: {visualization_success_count}/{len(successful_models)}")

        return {
            'success': len(successful_models) > 0,  # 至少有一个模型成功即为成功
            'all_models_results': all_results,
            'total_predictions': total_predictions,
            'successful_models': successful_models,
            'failed_models': failed_models,
            'models_count': {
                'total': len(settings.AVAILABLE_MODELS),
                'successful': len(successful_models),
                'failed': len(failed_models)
            },
            'visualization_count': {
                'successful': visualization_success_count,
                'total': len(successful_models)
            }
        }
