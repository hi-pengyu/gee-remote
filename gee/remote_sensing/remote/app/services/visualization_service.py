"""可视化服务 - 为预测结果生成上色图像"""
import json
import numpy as np
from PIL import Image
import rasterio
from rasterio.transform import from_bounds
import os
from typing import Dict, List, Tuple
from app.config import settings
from app.utils.logger import celery_logger


def hex_to_rgba(hex_color: str, alpha: int = 255) -> List[int]:
    """将 #RRGGBB 格式的 hex 字符串转换为 [R, G, B, A] 列表"""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        raise ValueError("无效的 Hex 颜色代码")
    r, g, b = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return [r, g, b, alpha]


# 每个模型的调色板配置
MODEL_PALETTES = {
    'zg': [  # 株高
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#FF0000"),  # 1: 低
        hex_to_rgba("#EAA1A1"),  # 2: 较低
        hex_to_rgba("#87F27C"),  # 3: 正常
        hex_to_rgba("#268845"),  # 4: 较高
        hex_to_rgba("#024D2E")  # 5: 高
    ],
    'agb': [  # 生物量
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#FFFFE5"),  # 1: 低
        hex_to_rgba("#D2EDA0"),  # 2: 较低
        hex_to_rgba("#85CC7E"),  # 3: 正常
        hex_to_rgba("#268845"),  # 4: 较高
        hex_to_rgba("#004529")  # 5: 高
    ],
    'hsl': [  # 叶绿素
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#F7FCF0"),  # 1: 低
        hex_to_rgba("#C6E9C3"),  # 2: 较低
        hex_to_rgba("#86D0C0"),  # 3: 正常
        hex_to_rgba("#2E90C0"),  # 4: 较高
        hex_to_rgba("#084081")  # 5: 高
    ],
    'spad': [  # SPAD值
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#A2061A"),  # 1: 低
        hex_to_rgba("#F47878"),  # 2: 较低
        hex_to_rgba("#F3EB07"),  # 3: 正常
        hex_to_rgba("#2AE038"),  # 4: 较高
        hex_to_rgba("#1D5604")  # 5: 高
    ],
    'n': [  # 氮含量
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#DFE8C4"),  # 1: 低
        hex_to_rgba("#E9F153"),  # 2: 较低
        hex_to_rgba("#ABF597"),  # 3: 正常
        hex_to_rgba("#08B724"),  # 4: 较高
        hex_to_rgba("#026729")  # 5: 高
    ],
    'p': [  # 磷含量
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#DFE8C4"),  # 1: 低
        hex_to_rgba("#E9F153"),  # 2: 较低
        hex_to_rgba("#ABF597"),  # 3: 正常
        hex_to_rgba("#08B724"),  # 4: 较高
        hex_to_rgba("#026729")  # 5: 高
    ],
    'k': [  # 钾含量
        [0, 0, 0, 0],  # 0: 背景 (完全透明)
        hex_to_rgba("#DFE8C4"),  # 1: 低
        hex_to_rgba("#E9F153"),  # 2: 较低
        hex_to_rgba("#ABF597"),  # 3: 正常
        hex_to_rgba("#08B724"),  # 4: 较高
        hex_to_rgba("#026729")  # 5: 高
    ]
}

# 每个模型的调色板HEX颜色（用于返回JSON）
MODEL_PALETTE_HEX = {
    'zg': ["#FF0000", "#EAA1A1", "#87F27C", "#268845", "#024D2E"],
    'agb': ["#FFFFE5", "#D2EDA0", "#85CC7E", "#268845", "#004529"],
    'hsl': ["#F7FCF0", "#C6E9C3", "#86D0C0", "#2E90C0", "#084081"],
    'spad': ["#A2061A", "#F47878", "#F3EB07", "#2AE038", "#1D5604"],
    'n': ["#DFE8C4", "#E9F153", "#ABF597", "#08B724", "#026729"],
    'p': ["#DFE8C4", "#E9F153", "#ABF597", "#08B724", "#026729"],
    'k': ["#DFE8C4", "#E9F153", "#ABF597", "#08B724", "#026729"],
}

# 每个模型的名称
MODEL_NAMES = {
    'zg': '株高',
    'agb': '生物量',
    'hsl': '叶绿素',
    'spad': 'SPAD',
    'n': '氮含量',
    'p': '磷含量',
    'k': '钾含量'
}

# 每个模型的分级比例配置
MODEL_PROPORTIONS = {
    # n, p, k, zg 使用: 15%-20%-30%-20%-15%
    'n': [0.15, 0.35, 0.65, 0.85],
    'p': [0.15, 0.35, 0.65, 0.85],
    'k': [0.15, 0.35, 0.65, 0.85],
    'zg': [0.15, 0.35, 0.65, 0.85],

    # agb, hsl, spad 使用: 15%-20%-40%-15%-10%
    'agb': [0.15, 0.35, 0.75, 0.90],
    'hsl': [0.15, 0.35, 0.75, 0.90],
    'spad': [0.15, 0.35, 0.75, 0.90],
}


class VisualizationService:
    """可视化服务类"""

    def __init__(self):
        """初始化可视化服务"""
        # 确保图像存储目录存在
        self.image_dir = os.path.join(settings.STORAGE_RESULTS_DIR, "images")
        os.makedirs(self.image_dir, exist_ok=True)
        celery_logger.info(f"[Visualization] 图像存储目录: {self.image_dir}")

    @staticmethod
    def get_grade_colors(model_type: str) -> List[Dict]:
        """
        获取模型的分级颜色配置（理论比例）

        Args:
            model_type: 模型类型

        Returns:
            分级颜色列表
        """
        proportions = MODEL_PROPORTIONS.get(model_type, [0.15, 0.35, 0.65, 0.85])
        colors = MODEL_PALETTE_HEX.get(model_type, MODEL_PALETTE_HEX['agb'])

        # 计算每个等级的实际比例
        prop_list = [proportions[0]]  # 第1级
        prop_list.extend([proportions[i] - proportions[i-1] for i in range(1, len(proportions))])  # 第2-4级
        prop_list.append(1.0 - proportions[-1])  # 第5级

        labels = ["低", "较低", "正常", "较高", "高"]

        return [
            {
                "level": i + 1,
                "label": labels[i],
                "color": colors[i],
                "proportion": round(prop_list[i], 2)
            }
            for i in range(5)
        ]

    @staticmethod
    def get_grade_colors_from_stats(model_type: str, grade_pixel_counts: Dict[int, int], total_pixels: int) -> List[Dict]:
        """
        根据实际上色统计生成分级颜色配置（实际比例）

        Args:
            model_type: 模型类型
            grade_pixel_counts: 各等级的像素数 {1: count1, 2: count2, ...}
            total_pixels: 总有效像素数

        Returns:
            分级颜色列表（包含实际比例）
        """
        colors = MODEL_PALETTE_HEX.get(model_type, MODEL_PALETTE_HEX['agb'])
        labels = ["低", "较低", "正常", "较高", "高"]

        return [
            {
                "level": i + 1,
                "label": labels[i],
                "color": colors[i],
                "proportion": round(grade_pixel_counts.get(i + 1, 0) / total_pixels, 4) if total_pixels > 0 else 0.0
            }
            for i in range(5)
        ]

    def create_colored_map(
        self,
        json_path: str,
        model_type: str,
        method: str = 'quantile',
        proportions: List[float] = None,
        tif_path: str = None,
        geo_bounds: Dict = None
    ) -> Dict:
        """
        为预测结果生成上色图像（PNG和TIF）

        Args:
            json_path: 预测结果JSON文件路径
            model_type: 模型类型（用于选择调色板和分级比例）
            method: 分级方法 ('quantile' 或 'equal_interval')
            proportions: 自定义分级比例，如果为None则使用模型默认比例
            tif_path: 原始TIF文件路径（可选，用于提取地理坐标）
            geo_bounds: 地理坐标边界（可选，格式：{'top_left': [lon, lat], 'bottom_right': [lon, lat]}）

        Returns:
            {
                'success': bool,
                'image_path': str,      # PNG路径
                'tif_path': str,        # GeoTIFF路径
                'width': int,
                'height': int,
                'statistics': dict
            }
        """
        # 使用模型特定的分级比例，如果未指定
        if proportions is None:
            proportions = MODEL_PROPORTIONS.get(model_type, [0.15, 0.35, 0.65, 0.85])

        celery_logger.info(f"[Visualization] 开始为模型 {model_type} 生成可视化图像")
        celery_logger.info(f"[Visualization] 输入文件: {json_path}")
        celery_logger.info(f"[Visualization] 分级比例: {proportions}")

        try:
            # 1. 获取调色板
            palette = MODEL_PALETTES.get(model_type)
            if palette is None:
                celery_logger.warning(f"[Visualization] 未找到模型 {model_type} 的调色板，使用默认")
                palette = MODEL_PALETTES['agb']  # 使用默认调色板

            # 2. 加载JSON数据
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            if data.get('status') != 'success':
                celery_logger.warning(f"[Visualization] JSON状态不是success: {data.get('status')}")
                return {'success': False, 'message': 'JSON状态不是success'}

            results = data.get('results', [])
            if not results:
                celery_logger.warning("[Visualization] JSON中没有results数据")
                return {'success': False, 'message': 'JSON中没有results数据'}

            celery_logger.info(f"[Visualization] 加载了 {len(results)} 个预测点")

            # 3. 重建2D画布
            max_x = max(item['X'] for item in results)
            max_y = max(item['Y'] for item in results)
            width = max_x + 1
            height = max_y + 1

            celery_logger.info(f"[Visualization] 画布尺寸: {width} x {height}")

            raw_prediction_map = np.full((height, width), np.nan, dtype=np.float32)
            for item in results:
                raw_prediction_map[item['Y'], item['X']] = item['prediction']

            # 4. 计算统计信息和阈值
            valid_predictions = raw_prediction_map[~np.isnan(raw_prediction_map)]
            if len(valid_predictions) == 0:
                return {'success': False, 'message': '没有有效预测数据'}

            min_val = float(valid_predictions.min())
            max_val = float(valid_predictions.max())
            mean_val = float(valid_predictions.mean())

            celery_logger.info(f"[Visualization] 统计: Min={min_val:.4f}, Max={max_val:.4f}, Mean={mean_val:.4f}")

            # 5. 根据方法计算阈值
            proportions_np = np.array(proportions)
            if method == 'quantile':
                breaks = np.quantile(valid_predictions, proportions_np)
            elif method == 'equal_interval':
                total_range = max_val - min_val
                breaks = min_val + (total_range * proportions_np)
            else:
                celery_logger.warning(f"[Visualization] 未知分级方法: {method}, 使用quantile")
                breaks = np.quantile(valid_predictions, proportions_np)

            celery_logger.info(f"[Visualization] 阈值: {breaks}")

            # 6. 分级
            graded_map = np.full(raw_prediction_map.shape, 0, dtype=np.uint8)
            valid_indices = ~np.isnan(raw_prediction_map)
            grades = np.digitize(raw_prediction_map[valid_indices], breaks) + 1
            graded_map[valid_indices] = grades

            # 6.5. 统计每个等级的实际像素数
            total_valid_pixels = int(len(valid_predictions))
            grade_pixel_counts = {}
            for grade in range(1, 6):  # 1-5级
                count = int(np.sum(graded_map == grade))
                grade_pixel_counts[grade] = count

            celery_logger.info(f"[Visualization] 各等级像素数: {grade_pixel_counts}")

            # 7. 上色
            color_image = np.zeros((height, width, 4), dtype=np.uint8)
            for grade_value, color in enumerate(palette):
                color_image[graded_map == grade_value] = color

            # 8. 保存PNG
            base_name = os.path.splitext(os.path.basename(json_path))[0]
            png_filename = f"{base_name}_visualization.png"
            png_path = os.path.join(self.image_dir, png_filename)

            img = Image.fromarray(color_image, 'RGBA')
            img.save(png_path)

            celery_logger.info(f"[Visualization] ✓ PNG图像已保存: {png_path}")

            # 9. 保存GeoTIFF（如果提供了地理坐标）
            geotif_path = None
            if geo_bounds is not None or tif_path is not None:
                try:
                    # 优先使用提供的geo_bounds，否则从tif_path读取
                    if geo_bounds is None and tif_path is not None:
                        with rasterio.open(tif_path) as src:
                            bounds = src.bounds
                            geo_bounds = {
                                'top_left': [bounds.left, bounds.top],
                                'bottom_right': [bounds.right, bounds.bottom]
                            }

                    if geo_bounds is not None:
                        geotif_filename = f"{base_name}_visualization.tif"
                        geotif_path = os.path.join(self.image_dir, geotif_filename)

                        # 计算仿射变换
                        top_left = geo_bounds['top_left']
                        bottom_right = geo_bounds['bottom_right']
                        transform = from_bounds(
                            top_left[0], bottom_right[1],  # west, south
                            bottom_right[0], top_left[1],  # east, north
                            width, height
                        )

                        # 保存为GeoTIFF（4波段RGBA）
                        with rasterio.open(
                            geotif_path,
                            'w',
                            driver='GTiff',
                            height=height,
                            width=width,
                            count=4,  # RGBA
                            dtype=rasterio.uint8,
                            crs='EPSG:4326',  # WGS84
                            transform=transform,
                            compress='lzw'
                        ) as dst:
                            # 写入RGBA波段
                            for i in range(4):
                                dst.write(color_image[:, :, i], i + 1)

                        celery_logger.info(f"[Visualization] ✓ GeoTIFF已保存: {geotif_path}")
                except Exception as e:
                    celery_logger.warning(f"[Visualization] GeoTIFF保存失败: {str(e)}")
                    geotif_path = None

            return {
                'success': True,
                'image_path': png_path,
                'tif_path': geotif_path,  # 添加GeoTIFF路径
                'width': int(width),
                'height': int(height),
                'statistics': {
                    'min': min_val,
                    'max': max_val,
                    'mean': mean_val,
                    'valid_pixels': total_valid_pixels,
                    'breaks': breaks.tolist(),
                    'grade_pixel_counts': grade_pixel_counts  # 添加各等级像素数
                }
            }

        except Exception as e:
            celery_logger.error(f"[Visualization] 生成图像失败: {str(e)}", exc_info=True)
            return {
                'success': False,
                'message': f'生成图像失败: {str(e)}'
            }

    def create_colored_map_for_all_models(
        self,
        all_models_results: Dict,
        file_name: str
    ) -> Dict:
        """
        为所有模型的预测结果生成可视化图像

        Args:
            all_models_results: 所有模型的预测结果字典
            file_name: 基础文件名

        Returns:
            {
                'success': bool,
                'visualizations': {
                    'zg': {...},
                    'agb': {...},
                    ...
                }
            }
        """
        celery_logger.info("[Visualization] 开始为所有模型生成可视化图像")

        visualizations = {}
        success_count = 0

        for model_type, result in all_models_results.items():
            if not result.get('success', False):
                celery_logger.warning(f"[Visualization] 跳过失败的模型: {model_type}")
                visualizations[model_type] = {'success': False, 'message': '预测失败'}
                continue

            result_path = result.get('result_path')
            if not result_path or not os.path.exists(result_path):
                celery_logger.warning(f"[Visualization] 模型 {model_type} 的结果文件不存在")
                visualizations[model_type] = {'success': False, 'message': '结果文件不存在'}
                continue

            # 生成可视化
            vis_result = self.create_colored_map(
                json_path=result_path,
                model_type=model_type,
                method='quantile',
                proportions=[0.15, 0.35, 0.65, 0.85]
            )

            visualizations[model_type] = vis_result
            if vis_result.get('success'):
                success_count += 1

        celery_logger.info(f"[Visualization] 完成！成功生成 {success_count}/{len(all_models_results)} 个可视化图像")

        return {
            'success': success_count > 0,
            'visualizations': visualizations,
            'success_count': success_count,
            'total_count': len(all_models_results)
        }
