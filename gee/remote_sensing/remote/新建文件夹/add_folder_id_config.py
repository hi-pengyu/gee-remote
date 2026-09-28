"""添加 GEE Drive 相关配置到数据库"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.config import config_manager

# 配置项
FOLDER_ID = '1rM94Jyv-IVQR5D6XDKxAKNlTTmOmI7oV'  # 从测试脚本中找到的有文件的那个文件夹
TOKEN_PATH = 'token/token.json'  # Drive 认证文件路径

print("=" * 60)
print("添加 GEE Drive 相关配置")
print("=" * 60)

configs = [
    {
        'key': 'GEE_DRIVE_FOLDER_ID',
        'value': FOLDER_ID,
        'description': 'Google Drive 文件夹ID（优先使用ID而不是名称，避免同名文件夹问题）'
    },
    {
        'key': 'GEE_DRIVE_TOKEN_PATH',
        'value': TOKEN_PATH,
        'description': 'Google Drive 服务账号认证文件路径（相对于项目根目录）'
    }
]

print("\n将添加以下配置:\n")
for cfg in configs:
    print(f"  {cfg['key']}: {cfg['value']}")
    print(f"    说明: {cfg['description']}\n")

# 添加配置
all_success = True
for cfg in configs:
    success = config_manager.set(
        key=cfg['key'],
        value=cfg['value'],
        config_type='string',
        group='gee',
        description=cfg['description'],
        updated_by='system'
    )
    
    if success:
        print(f"✅ {cfg['key']} 配置已添加")
    else:
        print(f"❌ {cfg['key']} 配置添加失败")
        all_success = False

if all_success:
    print("\n✅ 所有配置已添加成功！")
    
    # 发布重载消息
    config_manager.publish_reload("添加了 GEE Drive 相关配置")
    
    # 显示当前配置
    print("\n当前 Drive 相关配置:")
    all_configs = config_manager.get_all()
    for key in ['GEE_DRIVE_FOLDER', 'GEE_DRIVE_FOLDER_ID', 'GEE_DRIVE_TOKEN_PATH']:
        if key in all_configs:
            print(f"  {key}: {all_configs[key]}")
else:
    print("\n❌ 部分配置添加失败！")

print("\n" + "=" * 60)
print("完成！")
print("=" * 60)
print("\n提示:")
print("  1. 配置已写入数据库，所有GEE服务实例会自动重载")
print("  2. 如果有多个GEE账户，可以为每个账户配置不同的:")
print("     - GEE_DRIVE_FOLDER_ID: 对应的Drive文件夹ID")
print("     - GEE_DRIVE_TOKEN_PATH: 对应的认证文件路径")
print("=" * 60)

