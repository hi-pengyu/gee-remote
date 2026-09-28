import json
import numpy as np
from osgeo import gdal, osr
import os


def json_to_tif(json_file_path, output_tif_path=None, epsg=4326, pixel_size=1.0):
    """
    将包含 X, Y, prediction 的 JSON 文件转换为 TIF 文件
    
    参数:
        json_file_path: JSON 文件路径
        output_tif_path: 输出 TIF 文件路径（如果为 None，则使用 JSON 文件名）
        epsg: 坐标系统 EPSG 代码（默认 4326 为 WGS84）
        pixel_size: 像素大小（默认 1.0）
    """
    # 读取 JSON 文件
    print(f"正在读取文件: {json_file_path}")
    with open(json_file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 提取结果数组
    results = data.get('results', [])
    model = data.get('model', 'unknown')
    
    if not results:
        print(f"警告: {json_file_path} 中没有找到结果数据")
        return
    
    print(f"模型: {model}, 数据点数量: {len(results)}")
    
    # 提取 X, Y, prediction 数据
    x_coords = [item['X'] for item in results]
    y_coords = [item['Y'] for item in results]
    predictions = [item['prediction'] for item in results]
    
    # 计算栅格范围
    min_x, max_x = min(x_coords), max(x_coords)
    min_y, max_y = min(y_coords), max(y_coords)
    
    print(f"坐标范围: X({min_x}, {max_x}), Y({min_y}, {max_y})")
    
    # 计算栅格尺寸
    width = int(max_x - min_x + 1)
    height = int(max_y - min_y + 1)
    
    print(f"栅格尺寸: {width} x {height}")
    
    # 创建空白栅格数组，用 NaN 填充
    raster_array = np.full((height, width), np.nan, dtype=np.float32)
    
    # 填充预测值
    for item in results:
        x = item['X'] - min_x
        y = item['Y'] - min_y
        raster_array[y, x] = item['prediction']
    
    # 设置输出文件路径
    if output_tif_path is None:
        base_name = os.path.splitext(json_file_path)[0]
        output_tif_path = f"{base_name}.tif"
    
    # 创建 GeoTIFF 文件
    print(f"正在创建 TIF 文件: {output_tif_path}")
    driver = gdal.GetDriverByName('GTiff')
    out_raster = driver.Create(
        output_tif_path,
        width,
        height,
        1,  # 波段数
        gdal.GDT_Float32,
        options=['COMPRESS=LZW']  # 使用 LZW 压缩
    )
    
    # 设置地理转换参数
    # GeoTransform = (左上角X坐标, 像素宽度, 0, 左上角Y坐标, 0, -像素高度)
    # 注意: Y坐标从上到下递减，所以像素高度为负
    geotransform = (min_x - pixel_size/2, pixel_size, 0, 
                   max_y + pixel_size/2, 0, -pixel_size)
    out_raster.SetGeoTransform(geotransform)
    
    # 设置投影
    srs = osr.SpatialReference()
    srs.ImportFromEPSG(epsg)
    out_raster.SetProjection(srs.ExportToWkt())
    
    # 写入数据
    out_band = out_raster.GetRasterBand(1)
    out_band.WriteArray(raster_array)
    
    # 设置 NoData 值
    out_band.SetNoDataValue(np.nan)
    
    # 计算统计信息
    out_band.ComputeStatistics(False)
    
    # 刷新缓存并关闭文件
    out_band.FlushCache()
    out_raster = None
    
    print(f"成功创建文件: {output_tif_path}")
    print(f"预测值范围: {np.nanmin(predictions):.2f} - {np.nanmax(predictions):.2f}")
    print("-" * 50)


def batch_convert_json_to_tif(directory, pattern='prediction_*.json'):
    """
    批量转换目录中的 JSON 文件为 TIF 文件
    
    参数:
        directory: 目录路径
        pattern: 文件匹配模式
    """
    import glob
    
    # 查找所有匹配的 JSON 文件
    search_pattern = os.path.join(directory, pattern)
    json_files = glob.glob(search_pattern)
    
    if not json_files:
        print(f"在 {directory} 中没有找到匹配 {pattern} 的文件")
        return
    
    print(f"找到 {len(json_files)} 个 JSON 文件")
    print("=" * 50)
    
    # 逐个转换
    for json_file in json_files:
        try:
            json_to_tif(json_file)
        except Exception as e:
            print(f"错误: 处理 {json_file} 时出现异常: {str(e)}")
            print("-" * 50)
    
    print("=" * 50)
    print("批量转换完成！")


if __name__ == "__main__":
    # 获取当前脚本所在目录
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 批量转换当前目录下所有 prediction_*.json 文件
    batch_convert_json_to_tif(current_dir)
