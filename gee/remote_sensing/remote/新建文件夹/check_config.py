"""检查当前配置"""
from app.config import settings

print("=" * 60)
print("当前配置检查")
print("=" * 60)
print(f"\nAVAILABLE_MODELS: {settings.AVAILABLE_MODELS}")
print(f"模型数量: {len(settings.AVAILABLE_MODELS)}")
print(f"\n详细列表:")
for i, model in enumerate(settings.AVAILABLE_MODELS, 1):
    print(f"  {i}. {model}")
print("\n" + "=" * 60)
