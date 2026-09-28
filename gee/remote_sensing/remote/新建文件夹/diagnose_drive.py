"""快速诊断 - 检查Drive文件（从数据库读取配置）"""
import os
import sys

# 添加路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

print("=" * 60)
print("Drive 文件搜索诊断（从数据库读取配置）")
print("=" * 60)

try:
    from app.config import settings
    from pydrive2.auth import GoogleAuth
    from pydrive2.drive import GoogleDrive
    import json
    import tempfile
    
    # 从数据库读取token
    print("\n1. 从数据库读取Token配置...")
    token_json = getattr(settings, 'GEE_DRIVE_TOKEN_JSON', None)
    
    if not token_json:
        print("   ❌ GEE_DRIVE_TOKEN_JSON 未配置")
        print("   请运行: python import_drive_token.py")
        sys.exit(1)
    
    print(f"   ✓ Token已加载")
    print(f"   服务账号: {token_json.get('client_email')}")
    print(f"   项目ID: {token_json.get('project_id')}")
    
    # 读取文件夹ID
    folder_id = getattr(settings, 'GEE_DRIVE_FOLDER_ID', None)
    print(f"\n   文件夹ID配置: {folder_id if folder_id else '未配置'}")
    
    # 认证
    print("\n2. Drive认证...")
    
    # 创建临时文件
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        temp_file = f.name
        json.dump(token_json, f)
    
    try:
        settings_dict = {
            "client_config_backend": "service",
            "service_config": {
                "client_json_file_path": temp_file,
            },
            "oauth_scope": ["https://www.googleapis.com/auth/drive"]
        }
        
        gauth = GoogleAuth(settings=settings_dict)
        gauth.ServiceAuth()
        drive = GoogleDrive(gauth)
        print("   ✓ 认证成功")
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)
    
    # 如果配置了文件夹ID，直接使用
    if folder_id:
        print(f"\n3. 使用配置的文件夹ID: {folder_id}")
        folder_list = [{'id': folder_id, 'title': 'GEE_Exports (配置的ID)'}]
    else:
        # 搜索文件夹
        print("\n3. 搜索 GEE_Exports 文件夹...")
        folder_list = drive.ListFile({
            'q': "title='GEE_Exports' and mimeType='application/vnd.google-apps.folder' and trashed=false"
        }).GetList()
        
        print(f"   找到 {len(folder_list)} 个文件夹")
        
        if not folder_list:
            print("   ❌ 没有找到文件夹")
            sys.exit(1)
    
    # 显示所有文件夹的内容
    for i, folder in enumerate(folder_list, 1):
        print(f"\n   文件夹 #{i}:")
        print(f"   ID: {folder['id']}")
        if 'createdDate' in folder:
            print(f"   创建时间: {folder.get('createdDate', 'N/A')}")
        
        # 列出文件夹中的文件
        files = drive.ListFile({
            'q': f"'{folder['id']}' in parents and trashed=false"
        }).GetList()
        
        print(f"   文件数: {len(files)}")
        
        if files:
            print(f"   最近的10个文件:")
            files.sort(key=lambda x: x.get('modifiedDate', ''), reverse=True)
            for j, f in enumerate(files[:10], 1):
                size_mb = int(f.get('fileSize', 0)) / (1024 * 1024) if 'fileSize' in f else 0
                print(f"     {j}. {f['title']} ({size_mb:.2f} MB)")
                print(f"        修改时间: {f.get('modifiedDate', 'N/A')}")
    
    # 搜索特定文件
    print("\n4. 搜索最新的workflow文件...")
    target_pattern = "workflow_2024-09-21"
    
    for folder in folder_list:
        print(f"\n   在文件夹 {folder['id']} 中搜索 '{target_pattern}'...")
        files = drive.ListFile({
            'q': f"'{folder['id']}' in parents and trashed=false"
        }).GetList()
        
        matching = [f for f in files if target_pattern in f['title']]
        
        if matching:
            print(f"   ✓ 找到 {len(matching)} 个匹配文件:")
            matching.sort(key=lambda x: x.get('modifiedDate', ''), reverse=True)
            for f in matching:
                size_mb = int(f.get('fileSize', 0)) / (1024 * 1024) if 'fileSize' in f else 0
                print(f"     - {f['title']} ({size_mb:.2f} MB)")
                print(f"       ID: {f['id']}")
                print(f"       修改时间: {f.get('modifiedDate', 'N/A')}")
        else:
            print(f"   未找到匹配的文件")
    
    print("\n" + "=" * 60)
    print("诊断完成")
    print("=" * 60)
    
except Exception as e:
    print(f"\n❌ 错误: {e}")
    import traceback
    traceback.print_exc()

