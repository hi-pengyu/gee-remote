"""验证GEE Drive配置"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.config import settings

print("=" * 60)
print("GEE Drive 配置验证")
print("=" * 60)

# 检查Drive Token
print("\n1. 检查 Drive Token 配置:")
token_json = getattr(settings, 'GEE_DRIVE_TOKEN_JSON', None)

if token_json:
    print("   ✅ GEE_DRIVE_TOKEN_JSON 已配置")
    if isinstance(token_json, dict):
        print(f"   项目ID: {token_json.get('project_id', 'N/A')}")
        print(f"   服务账号: {token_json.get('client_email', 'N/A')}")
        print(f"   类型: {token_json.get('type', 'N/A')}")
    else:
        print(f"   ⚠️  Token类型: {type(token_json)}")
else:
    print("   ❌ GEE_DRIVE_TOKEN_JSON 未配置")
    print("   请运行: python import_drive_token.py")

# 检查文件夹ID
print("\n2. 检查 Drive 文件夹ID配置:")
folder_id = getattr(settings, 'GEE_DRIVE_FOLDER_ID', None)

if folder_id:
    print(f"   ✅ GEE_DRIVE_FOLDER_ID 已配置")
    print(f"   文件夹ID: {folder_id}")
else:
    print("   ❌ GEE_DRIVE_FOLDER_ID 未配置")
    print("   将使用文件夹名称搜索（可能有同名问题）")
    folder_name = getattr(settings, 'GEE_DRIVE_FOLDER', 'GEE_Exports')
    print(f"   文件夹名称: {folder_name}")

# 检查GEE项目ID
print("\n3. 检查 GEE 项目ID配置:")
project_id = getattr(settings, 'GEE_PROJECT_ID', None)

if project_id:
    print(f"   ✅ GEE_PROJECT_ID 已配置")
    print(f"   项目ID: {project_id}")
else:
    print("   ❌ GEE_PROJECT_ID 未配置")

# 总结
print("\n" + "=" * 60)
print("配置总结:")
print("=" * 60)

all_ok = True

if not token_json:
    print("❌ Drive Token 未配置")
    all_ok = False
else:
    print("✅ Drive Token 已配置")

if not folder_id:
    print("⚠️  Drive 文件夹ID 未配置（建议配置）")
else:
    print("✅ Drive 文件夹ID 已配置")

if not project_id:
    print("❌ GEE 项目ID 未配置")
    all_ok = False
else:
    print("✅ GEE 项目ID 已配置")

print("=" * 60)

if all_ok and folder_id:
    print("\n✅ 所有配置完整，可以正常使用！")
elif all_ok:
    print("\n⚠️  基本配置完整，但建议配置文件夹ID")
else:
    print("\n❌ 配置不完整，请先运行:")
    print("   python import_drive_token.py")

print("\n" + "=" * 60)
