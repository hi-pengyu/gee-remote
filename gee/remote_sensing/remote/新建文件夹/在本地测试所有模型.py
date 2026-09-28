"""
本地预测功能测试脚本

测试本地预测模块的功能
"""
import pandas as pd
import numpy as np
import os
import sys

# 添加项目根目录到路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.local_predictor import get_predictor, ModelType, initialize_all_models


def create_test_data(num_samples=100):
    """创建测试数据"""
    print(f"📊 创建 {num_samples} 个测试样本...")
    
    # 生成随机的遥感数据（模拟Sentinel-2波段值）
    data = {
        'X': np.arange(num_samples),
        'Y': np.arange(num_samples),
        'B01': np.random.uniform(0.01, 0.2, num_samples),  # Coastal aerosol
        'B02': np.random.uniform(0.02, 0.3, num_samples),  # Blue
        'B03': np.random.uniform(0.03, 0.4, num_samples),  # Green
        'B04': np.random.uniform(0.02, 0.3, num_samples),  # Red
        'B05': np.random.uniform(0.05, 0.5, num_samples),  # Vegetation Red Edge 1
        'B06': np.random.uniform(0.05, 0.5, num_samples),  # Vegetation Red Edge 2
        'B08': np.random.uniform(0.2, 0.8, num_samples),   # NIR
        'B8A': np.random.uniform(0.2, 0.8, num_samples),   # Narrow NIR
        'B09': np.random.uniform(0.01, 0.1, num_samples),  # Water vapour
        'B11': np.random.uniform(0.1, 0.4, num_samples),   # SWIR 1
        'B12': np.random.uniform(0.05, 0.3, num_samples),  # SWIR 2
    }
    
    return pd.DataFrame(data)


def test_single_model(model_type_str: str):
    """测试单个模型"""
    print("\n" + "=" * 80)
    print(f"🧪 测试模型: {model_type_str.upper()}")
    print("=" * 80)
    
    try:
        # 获取预测器
        predictor = get_predictor(model_type_str)
        print(f"✓ 模型加载成功: {predictor.model_name}")
        print(f"  模型路径: {predictor.model_path}")
        print(f"  需要的列: {predictor.required_columns}")
        print(f"  特征顺序: {predictor.feature_order}")
        
        # 创建测试数据
        test_df = create_test_data(num_samples=50)
        
        # 执行预测
        print("\n🔮 开始预测...")
        result = predictor.predict(test_df)
        
        # 显示结果
        print(f"\n📋 预测结果:")
        print(f"  状态: {result['status']}")
        
        if result['status'] == 'success':
            predictions = result['predictions']
            print(f"  预测数量: {len(predictions)}")
            print(f"  预测值范围: [{predictions.min():.4f}, {predictions.max():.4f}]")
            print(f"  预测值均值: {predictions.mean():.4f}")
            print(f"  预测耗时: {result['metadata'].get('predict_time', 0):.4f}s")
            
            # 显示前5个预测结果
            print(f"\n  前5个预测值:")
            for i, pred in enumerate(predictions[:5], 1):
                print(f"    {i}. {pred:.4f}")
        
        # 显示植被指数
        if 'indices' in result:
            print(f"\n📈 植被指数:")
            for key, value in result['indices'].items():
                print(f"  {key}: {value:.4f}")
        
        if result['status'] != 'success':
            print(f"\n⚠️  状态信息: {result.get('message', 'N/A')}")
        
        print(f"\n✅ {model_type_str.upper()} 模型测试完成")
        return True
        
    except FileNotFoundError as e:
        print(f"❌ 模型文件未找到: {e}")
        print(f"   请确保模型文件存在于 model/ 目录")
        return False
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        import traceback
        print(traceback.format_exc())
        return False


def test_all_models():
    """测试所有模型"""
    print("=" * 80)
    print("🚀 开始测试所有模型")
    print("=" * 80)
    
    models = ['zg', 'agb', 'hsl', 'spad', 'n', 'p', 'k']
    results = {}
    
    for model_type in models:
        success = test_single_model(model_type)
        results[model_type] = success
    
    # 总结
    print("\n" + "=" * 80)
    print("📊 测试总结")
    print("=" * 80)
    
    success_count = sum(results.values())
    total_count = len(results)
    
    for model_type, success in results.items():
        status = "✅ 成功" if success else "❌ 失败"
        print(f"  {model_type.upper():6s}: {status}")
    
    print(f"\n总计: {success_count}/{total_count} 个模型测试成功")
    
    if success_count == total_count:
        print("\n🎉 所有模型测试通过！")
    else:
        print(f"\n⚠️  {total_count - success_count} 个模型测试失败")
        print("   请检查：")
        print("   1. 模型文件是否存在于 model/ 目录")
        print("   2. 模型文件格式是否正确")
        print("   3. 模型文件名是否匹配")


def test_prediction_service():
    """测试预测服务"""
    print("\n" + "=" * 80)
    print("🧪 测试预测服务")
    print("=" * 80)
    
    from app.services.prediction_service import PredictionService
    
    service = PredictionService()
    test_df = create_test_data(num_samples=30)
    
    print("\n测试 predict_from_dataframe 方法...")
    result = service.predict_from_dataframe(
        df=test_df,
        model_type='agb',
        file_name='test_prediction'
    )
    
    print(f"\n结果:")
    print(f"  成功: {result['success']}")
    print(f"  结果数量: {result['result_count']}")
    
    if result.get('result_path'):
        print(f"  结果文件: {result['result_path']}")
        if os.path.exists(result['result_path']):
            print(f"  ✓ 结果文件已保存")
    
    print("\n✅ 预测服务测试完成")


def main():
    """主测试函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='本地预测模块测试')
    parser.add_argument('--model', type=str, help='测试单个模型 (zg, agb, hsl, spad, n, p, k)')
    parser.add_argument('--all', action='store_true', help='测试所有模型')
    parser.add_argument('--service', action='store_true', help='测试预测服务')
    parser.add_argument('--init', action='store_true', help='初始化所有模型')
    
    args = parser.parse_args()
    
    # 检查model文件夹是否存在
    model_dir = os.path.join(os.path.dirname(__file__), 'model')
    if not os.path.exists(model_dir):
        print(f"❌ 错误: model/ 文件夹不存在")
        print(f"   请创建 model/ 文件夹并放置模型文件")
        return
    
    if args.init:
        print("🔄 初始化所有模型...")
        initialize_all_models()
    elif args.model:
        test_single_model(args.model)
    elif args.all:
        test_all_models()
    elif args.service:
        test_prediction_service()
    else:
        # 默认测试一个模型
        print("💡 提示: 使用 --all 测试所有模型，或 --model <模型名> 测试单个模型")
        print("   例如: python test_local_prediction.py --model agb")
        print()
        test_single_model('agb')


if __name__ == "__main__":
    main()

