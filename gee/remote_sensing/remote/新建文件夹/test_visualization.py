"""测试可视化功能的独立脚本"""
import sys
import os

# 确保能导入项目模块
sys.path.insert(0, os.path.dirname(__file__))

from app.services.visualization_service import VisualizationService
from app.config import create_storage_dirs

# 创建必要的目录
create_storage_dirs()

def test_visualization():
    """测试可视化功能"""
    print("=" * 60)
    print("测试可视化功能")
    print("=" * 60)

    # 输入JSON文件路径（请根据实际情况修改）
    json_file = input("请输入预测JSON文件路径 (或按回车使用默认): ").strip()

    if not json_file:
        # 查找最近的预测文件
        import glob
        results_dir = "./storage/results"
        json_files = glob.glob(os.path.join(results_dir, "prediction_*.json"))
        if json_files:
            json_file = max(json_files, key=os.path.getmtime)
            print(f"使用最近的预测文件: {json_file}")
        else:
            print("❌ 没有找到预测文件")
            return

    if not os.path.exists(json_file):
        print(f"❌ 文件不存在: {json_file}")
        return

    # 检测模型类型（从文件名提取）
    basename = os.path.basename(json_file)
    model_type = None
    for model in ['zg', 'agb', 'hsl', 'spad', 'n', 'p', 'k']:
        if f'_{model}_' in basename or basename.startswith(f'prediction_{model}'):
            model_type = model
            break

    if not model_type:
        print("可用模型: zg, agb, hsl, spad, n, p, k")
        model_type = input("请输入模型类型: ").strip().lower()

    print(f"\n使用模型: {model_type}")
    print(f"输入文件: {json_file}")

    # 创建可视化服务
    vis_service = VisualizationService()

    # 生成可视化
    print("\n开始生成可视化图像...")
    print("使用模型特定的分级比例:")
    if model_type in ['n', 'p', 'k', 'zg']:
        print("  15%-20%-30%-20%-15%")
    else:
        print("  15%-20%-40%-15%-10%")

    result = vis_service.create_colored_map(
        json_path=json_file,
        model_type=model_type,
        method='quantile'
        # proportions 将自动使用模型特定的默认值
    )

    if result.get('success'):
        print("\n✓ 可视化生成成功！")
        print(f"图像路径: {result['image_path']}")
        print(f"图像尺寸: {result['width']} x {result['height']}")
        print("\n统计信息:")
        stats = result['statistics']
        print(f"  最小值: {stats['min']:.4f}")
        print(f"  最大值: {stats['max']:.4f}")
        print(f"  平均值: {stats['mean']:.4f}")
        print(f"  有效像素: {stats['valid_pixels']:,}")
        print(f"  分级阈值: {stats['breaks']}")
    else:
        print(f"\n❌ 可视化生成失败: {result.get('message')}")

if __name__ == "__main__":
    test_visualization()
