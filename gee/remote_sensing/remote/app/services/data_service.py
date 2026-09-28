"""数据处理服务 - TIF 数据处理"""
import rasterio
import pandas as pd
import numpy as np
import os
from typing import Dict, Tuple
from app.config import settings
from app.utils.logger import celery_logger


class DataProcessingService:
    """数据处理服务类 - 从TIF文件提取数据"""
    
    def extract_dataframe_from_tif(self, tif_path: str) -> Tuple[pd.DataFrame, Dict]:
        """
        从 TIF 文件直接提取 DataFrame（不保存CSV）
        
        Args:
            tif_path: TIF文件路径
            
        Returns:
            (DataFrame, metadata_dict)
            - DataFrame: 包含坐标和波段数据
            - metadata: 元数据（像素数、有效像素等）
        """
        celery_logger.info(f"[Data] 开始从TIF提取数据: {tif_path}")
        
        if not os.path.exists(tif_path):
            raise FileNotFoundError(f"TIF 文件不存在: {tif_path}")
        
        with rasterio.open(tif_path) as src:
            # 获取波段数量
            band_count = src.count
            celery_logger.info(f"[Data] 读取 {band_count} 个波段")

            # 波段名称
            band_names = settings.API_BANDS[:band_count]

            if len(band_names) != band_count:
                celery_logger.warning(f"[Data] 期望 {len(settings.API_BANDS)} 个波段，实际 {band_count} 个")

            # 读取所有波段数据
            data_arrays = src.read()
            height = src.height
            width = src.width

            total_pixels = height * width
            celery_logger.info(f"[Data] 影像尺寸: {width} x {height} = {total_pixels:,} 像素")

            # 提取地理坐标边界（左上角和右下角）
            bounds = src.bounds  # (left, bottom, right, top)
            top_left = [bounds.left, bounds.top]  # [经度, 纬度]
            bottom_right = [bounds.right, bounds.bottom]  # [经度, 纬度]

            celery_logger.info(f"[Data] 地理坐标 - 左上: {top_left}, 右下: {bottom_right}")
            
            # 创建坐标网格
            cols, rows = np.meshgrid(np.arange(width), np.arange(height))
            
            # 构建 DataFrame
            df_data = {
                'X': cols.flatten(),
                'Y': rows.flatten()
            }
            
            # 添加波段数据
            for i, band_name in enumerate(band_names):
                df_data[band_name] = data_arrays[i].flatten()
            
            celery_logger.info("[Data] 创建 DataFrame...")
            df = pd.DataFrame(df_data)
            
            # 过滤 NoData 像素（假设 B02 = 0 为无效值）
            original_count = len(df)
            df = df[df['B02'] > 0].reset_index(drop=True)
            valid_count = len(df)
            
            celery_logger.info(f"[Data] 过滤 NoData: {valid_count:,} / {original_count:,} 有效")
            
            if df.empty:
                raise ValueError("过滤后没有有效数据")
            
            metadata = {
                'total_pixels': total_pixels,
                'valid_pixels': valid_count,
                'band_count': band_count,
                'band_names': band_names,
                'image_width': width,
                'image_height': height,
                'geo_bounds': {
                    'top_left': top_left,      # [经度, 纬度]
                    'bottom_right': bottom_right  # [经度, 纬度]
                }
            }
            
            celery_logger.info(f"[Data] ✓ 数据提取完成！有效像素: {valid_count:,}")
            
            return df, metadata
    
    def convert_tif_to_csv(
        self,
        tif_path: str,
        csv_path: str
    ) -> Dict[str, any]:
        """
        将 TIF 文件转换为 CSV（保留此方法以兼容旧代码）
        
        Returns:
            {
                'success': bool,
                'total_pixels': int,
                'valid_pixels': int,
                'csv_path': str
            }
        """
        celery_logger.info(f"[Data] 开始转换: {tif_path} -> {csv_path}")
        
        # 使用新方法提取数据
        df, metadata = self.extract_dataframe_from_tif(tif_path)
        
        # 保存 CSV
        celery_logger.info(f"[Data] 保存 CSV: {csv_path}")
        df.to_csv(csv_path, index=False)
        
        csv_size = os.path.getsize(csv_path)
        celery_logger.info(f"[Data] ✓ CSV 保存完成！大小: {csv_size / 1024 / 1024:.2f} MB")
        
        return {
            'success': True,
            'total_pixels': metadata['total_pixels'],
            'valid_pixels': metadata['valid_pixels'],
            'csv_path': csv_path,
            'csv_size_mb': csv_size / 1024 / 1024
        }

