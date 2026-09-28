"""测试脚本：列出 Google Drive 文件夹中的所有文件"""
from pydrive2.auth import GoogleAuth
from pydrive2.drive import GoogleDrive
import sys
import os

# 添加项目路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.config import settings


def authenticate_gdrive() -> GoogleDrive:
    """Google Drive 认证"""
    print("=" * 60)
    print("开始 Google Drive 认证...")
    print("=" * 60)
    
    # 显式定义设置
    settings_dict = {
        "client_config_backend": "service",
        "service_config": {
            "client_json_file_path": r'token/token.json',
        },
        "oauth_scope": [
            "https://www.googleapis.com/auth/drive"
        ]
    }
    
    print(f"使用认证文件: {settings_dict['service_config']['client_json_file_path']}")
    
    # 检查文件是否存在
    token_path = settings_dict['service_config']['client_json_file_path']
    if not os.path.exists(token_path):
        print(f"❌ 错误：认证文件不存在: {token_path}")
        print(f"   当前工作目录: {os.getcwd()}")
        print(f"   绝对路径应该是: {os.path.abspath(token_path)}")
        sys.exit(1)
    
    gauth = GoogleAuth(settings=settings_dict)
    gauth.ServiceAuth()
    
    drive = GoogleDrive(gauth)
    print("✓ Google Drive 认证成功！\n")
    
    return drive


def list_all_folders(drive: GoogleDrive):
    """列出所有文件夹"""
    print("=" * 60)
    print("列出所有文件夹...")
    print("=" * 60)
    
    folder_list = drive.ListFile({
        'q': "mimeType='application/vnd.google-apps.folder' and trashed=false"
    }).GetList()
    
    print(f"找到 {len(folder_list)} 个文件夹:\n")
    for i, folder in enumerate(folder_list, 1):
        print(f"{i}. 📁 {folder['title']}")
        print(f"   ID: {folder['id']}")
        print(f"   创建时间: {folder.get('createdDate', 'N/A')}")
        print()
    
    return folder_list


def list_files_in_all_folders(drive: GoogleDrive, folder_name: str):
    """列出所有同名文件夹中的文件"""
    print("=" * 60)
    print(f"搜索所有名为 '{folder_name}' 的文件夹")
    print("=" * 60)
    
    # 查找所有同名文件夹
    folder_list = drive.ListFile({
        'q': f"title='{folder_name}' and "
             f"mimeType='application/vnd.google-apps.folder' and trashed=false"
    }).GetList()
    
    if not folder_list:
        print(f"❌ 未找到文件夹: {folder_name}")
        print("\n提示：请检查文件夹名称是否正确")
        return
    
    print(f"✓ 找到 {len(folder_list)} 个同名文件夹\n")
    
    # 按创建时间排序（最新的在前）
    folder_list.sort(key=lambda x: x.get('createdDate', ''), reverse=True)
    
    total_files = 0
    
    # 遍历每个文件夹
    for idx, folder in enumerate(folder_list, 1):
        folder_id = folder['id']
        
        print("=" * 60)
        print(f"文件夹 #{idx}: {folder['title']}")
        print("=" * 60)
        print(f"ID: {folder_id}")
        print(f"创建时间: {folder.get('createdDate', 'N/A')}")
        print(f"修改时间: {folder.get('modifiedDate', 'N/A')}\n")
        
        # 列出文件夹中的所有文件
        file_list = drive.ListFile({
            'q': f"'{folder_id}' in parents and trashed=false"
        }).GetList()
        
        if not file_list:
            print("⚠️  此文件夹为空\n")
            continue
        
        print(f"📊 找到 {len(file_list)} 个文件:\n")
        total_files += len(file_list)
        
        # 按修改时间排序（最新的在前）
        file_list.sort(key=lambda x: x.get('modifiedDate', ''), reverse=True)
        
        for i, file in enumerate(file_list, 1):
            file_type = "📁" if file['mimeType'] == 'application/vnd.google-apps.folder' else "📄"
            
            print(f"  {i}. {file_type} {file['title']}")
            print(f"     ID: {file['id']}")
            
            # 显示文件大小（如果有）
            if 'fileSize' in file:
                size_mb = int(file['fileSize']) / (1024 * 1024)
                print(f"     大小: {size_mb:.2f} MB")
            
            print(f"     修改时间: {file.get('modifiedDate', 'N/A')}")
            
            # 如果是 .tif 文件，特别标注
            if file['title'].endswith('.tif'):
                print(f"     ⭐ TIF 文件")
            
            print()
    
    print("=" * 60)
    print(f"总计: {len(folder_list)} 个文件夹，{total_files} 个文件")
    print("=" * 60)


def search_files_by_pattern(drive: GoogleDrive, folder_name: str, pattern: str):
    """在文件夹中搜索匹配模式的文件"""
    print("=" * 60)
    print(f"在文件夹 '{folder_name}' 中搜索: {pattern}")
    print("=" * 60)
    
    # 查找文件夹
    folder_list = drive.ListFile({
        'q': f"title='{folder_name}' and "
             f"mimeType='application/vnd.google-apps.folder' and trashed=false"
    }).GetList()
    
    if not folder_list:
        print(f"❌ 未找到文件夹: {folder_name}")
        return
    
    folder_id = folder_list[0]['id']
    
    # 搜索文件
    file_list = drive.ListFile({
        'q': f"'{folder_id}' in parents and trashed=false"
    }).GetList()
    
    # 过滤匹配的文件
    matching_files = [f for f in file_list if pattern.lower() in f['title'].lower()]
    
    if not matching_files:
        print(f"❌ 未找到匹配 '{pattern}' 的文件")
        return
    
    print(f"✓ 找到 {len(matching_files)} 个匹配的文件:\n")
    
    for i, file in enumerate(matching_files, 1):
        print(f"{i}. {file['title']}")
        print(f"   ID: {file['id']}")
        print(f"   修改时间: {file.get('modifiedDate', 'N/A')}")
        print()


def main():
    """主函数"""
    print("\n" + "=" * 60)
    print("Google Drive 文件列表测试工具")
    print("=" * 60 + "\n")
    
    # 从配置读取文件夹名称
    try:
        folder_name = settings.GEE_DRIVE_FOLDER
        print(f"配置的 GEE 文件夹: {folder_name}\n")
    except Exception as e:
        print(f"⚠️  无法读取配置: {e}")
        folder_name = "GEE_Exports"  # 默认值
        print(f"使用默认文件夹名: {folder_name}\n")
    
    # 认证
    try:
        drive = authenticate_gdrive()
    except Exception as e:
        print(f"❌ 认证失败: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    
    # 列出所有文件夹
    try:
        all_folders = list_all_folders(drive)
    except Exception as e:
        print(f"❌ 列出文件夹失败: {e}")
        import traceback
        traceback.print_exc()
    
    # 列出目标文件夹中的文件
    try:
        list_files_in_all_folders(drive, folder_name)
    except Exception as e:
        print(f"❌ 列出文件失败: {e}")
        import traceback
        traceback.print_exc()
    
    # 可选：搜索特定模式的文件
    print("\n" + "=" * 60)
    search_pattern = input("输入搜索关键词（直接回车跳过）: ").strip()
    if search_pattern:
        try:
            search_files_by_pattern(drive, folder_name, search_pattern)
        except Exception as e:
            print(f"❌ 搜索失败: {e}")
            import traceback
            traceback.print_exc()
    
    print("\n" + "=" * 60)
    print("测试完成！")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    main()
