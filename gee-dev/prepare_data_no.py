import rasterio
import pandas as pd
import numpy as np
import os


def convert_tif_to_csv(tif_path, csv_path):
    """
    读取一个多波段 GeoTIFF，将其像素值转换为 API 兼容的 CSV 文件。
    """
    print(f"正在打开栅格文件: {tif_path}")

    with rasterio.open(tif_path) as src:
        # 检查影像是否与 API 期望的波段名称匹配
        # GEE 导出的波段名称可能是 'B1', 'B2'...
        # 而 rasterio 读取时是按索引 1, 2, 3...
        # 我们假设 GEE 导出的顺序是正确的

        # 示例：假设我们导出的波段顺序是 API 所需的
        # B1, B2, B3, B4, B5, B6, B8, B8A, B9, B11, B12
        # 注意：你需要根据你 main.py 中的 all_bands 列表来调整这个
        band_names = [
            'B01', 'B02', 'B03', 'B04', 'B05', 'B06',
            'B08', 'B8A', 'B09', 'B11', 'B12'
        ]

        if len(band_names) != src.count:
            print(f"警告: 期望 {len(band_names)} 个波段, 但 TIF 文件有 {src.count} 个波段。")
            # 在这里你可能需要更复杂的逻辑来匹配波段
            # 但为简单起见，我们假设前 N 个波段是匹配的
            band_names = band_names[:src.count]

        print(f"读取 {src.count} 个波段...")

        # 读取所有波段数据
        data_arrays = src.read()

        # 获取影像尺寸
        height = src.height
        width = src.width

        # ---------------------------------------------
        # 高效的转换方式 (Raster-to-Tabular)
        # ---------------------------------------------

        # 1. 创建坐标网格 (X=列, Y=行)
        cols, rows = np.meshgrid(np.arange(width), np.arange(height))
        x_flat = cols.flatten()
        y_flat = rows.flatten()

        # 2. 准备一个字典来构建 DataFrame
        df_data = {
            'X': x_flat,
            'Y': y_flat
        }

        # 3. 展平每个波段的数据并添加到字典
        for i, band_name in enumerate(band_names):
            df_data[band_name] = data_arrays[i].flatten()

        print("正在创建 DataFrame...")
        df = pd.DataFrame(df_data)

        # 4. 过滤掉 NoData 像素

        # --- !! 更改点：根据您的要求，已注释掉过滤 !! ---

        # original_pixel_count = len(df)
        # df = df[df['B02'] > 0]  # 这是一个简单的过滤，你可能需要更复杂的
        # print(f"过滤 NoData 像素... 剩余 {len(df)} / {original_pixel_count} 个有效像素")
        #
        # if df.empty:
        #     print("错误：过滤后没有剩余数据。")
        #     return False

        print(f"保留所有 {len(df)} 个像素 (不过滤)。")

        # --- !! 更改结束 !! ---

        # 5. 保存到 CSV
        print(f"正在保存到 CSV: {csv_path}")
        df.to_csv(csv_path, index=False)
        print("CSV 文件创建成功！")
        return True


# --- 执行 ---
if __name__ == "__main__":
    # 假设你 GEE 下载的文件叫这个
    TIF_FILE_PATH = "my_parcel_image_se_target_2025-07-31.tif"

    # 你要生成的 CSV 文件
    CSV_OUTPUT_PATH = "input_for_api.csv"

    if not os.path.exists(TIF_FILE_PATH):
        print(f"错误: 找不到 TIF 文件: {TIF_FILE_PATH}")
    else:
        convert_tif_to_csv(TIF_FILE_PATH, CSV_OUTPUT_PATH)