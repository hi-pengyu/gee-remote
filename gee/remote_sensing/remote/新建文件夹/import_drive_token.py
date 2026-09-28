"""将 Drive Token 从文件读取并存入数据库"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.config import config_manager

# Token文件路径
TOKEN_FILE = 'token/token.json'
FOLDER_ID = '1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV'

print("=" * 60)
print("将 Drive Token 存入数据库")
print("=" * 60)

# 读取token文件
print(f"\n读取token文件: {TOKEN_FILE}")

if not os.path.exists(TOKEN_FILE):
    print(f"❌ 文件不存在: {TOKEN_FILE}")
    sys.exit(1)

try:
    with open(TOKEN_FILE, 'r', encoding='utf-8') as f:
        token_json = json.load(f)
    
    print(f"✓ Token文件读取成功")
    print(f"  项目ID: {token_json.get('project_id', 'N/A')}")
    print(f"  服务账号: {token_json.get('client_email', 'N/A')}")
    
except Exception as e:
    print(f"❌ 读取token文件失败: {e}")
    sys.exit(1)

# 存入数据库
print("\n将token存入数据库...")

configs = [
    {
        'key': 'GEE_DRIVE_TOKEN_JSON',
        'value': token_json,
        'type': 'json',
        'description': 'Google Drive 服务账号认证Token（JSON格式）'
    },
    {
        'key': 'GEE_DRIVE_FOLDER_ID',
        'value': FOLDER_ID,
        'type': 'string',
        'description': 'Google Drive 文件夹ID（优先使用ID而不是名称，避免同名文件夹问题）'
    }
]

all_success = True
for cfg in configs:
    success = config_manager.set(
        key=cfg['key'],
        value=cfg['value'],
        config_type=cfg['type'],
        group='gee',
        description=cfg['description'],
        updated_by='system'
    )
    
    if success:
        if cfg['type'] == 'json':
            print(f"✅ {cfg['key']} 已存入（JSON对象）")
        else:
            print(f"✅ {cfg['key']}: {cfg['value']}")
    else:
        print(f"❌ {cfg['key']} 存入失败")
        all_success = False

if all_success:
    print("\n✅ 所有配置已成功存入数据库！")
    
    # 发布重载消息
    config_manager.publish_reload("更新了 Drive Token 配置")
    
    # 显示当前配置
    print("\n当前 Drive 相关配置:")
    all_configs = config_manager.get_all()
    
    for key in ['GEE_DRIVE_FOLDER', 'GEE_DRIVE_FOLDER_ID', 'GEE_DRIVE_TOKEN_JSON']:
        if key in all_configs:
            if key == 'GEE_DRIVE_TOKEN_JSON':
                token_data = all_configs[key]
                print(f"  {key}:")
                print(f"    项目ID: {token_data.get('project_id', 'N/A')}")
                print(f"    服务账号: {token_data.get('client_email', 'N/A')}")
            else:
                print(f"  {key}: {all_configs[key]}")
else:
    print("\n❌ 部分配置存入失败！")

print("\n" + "=" * 60)
print("完成！")
print("=" * 60)
print("\n说明:")
print("  1. Token已加密存储在数据库中")
print("  2. 不再需要 token/token.json 文件")
print("  3. 所有GEE服务实例会自动重载配置")
print("  4. 如需更换token，重新运行此脚本即可")
print("=" * 60)
