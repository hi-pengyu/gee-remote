"""测试从数据库读取 Drive Token 并认证"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.gee_service_pool import GEEService

print("=" * 60)
print("测试 Drive Token 数据库认证")
print("=" * 60)

try:
    # 创建GEE服务实例
    print("\n1. 创建 GEE 服务实例...")
    gee_service = GEEService()
    print("   ✓ GEE 服务初始化成功")
    
    # 测试Drive认证
    print("\n2. 测试 Drive 认证...")
    drive = gee_service.authenticate_gdrive()
    print("   ✓ Drive 认证成功")
    
    # 列出文件夹
    print("\n3. 列出 Drive 文件夹...")
    from app.config import settings
    
    folder_id = settings.GEE_DRIVE_FOLDER_ID
    print(f"   文件夹ID: {folder_id}")
    
    file_list = drive.ListFile({
        'q': f"'{folder_id}' in parents and trashed=false"
    }).GetList()
    
    print(f"   ✓ 找到 {len(file_list)} 个文件")
    
    if file_list:
        print("\n   最近的文件:")
        # 按修改时间排序
        file_list.sort(key=lambda x: x.get('modifiedDate', ''), reverse=True)
        for i, f in enumerate(file_list[:5], 1):
            print(f"   {i}. {f['title']}")
            print(f"      修改时间: {f.get('modifiedDate', 'N/A')}")
    
    print("\n" + "=" * 60)
    print("✅ 测试成功！Drive Token 数据库认证工作正常")
    print("=" * 60)
    
except Exception as e:
    print("\n" + "=" * 60)
    print(f"❌ 测试失败: {e}")
    print("=" * 60)
    import traceback
    traceback.print_exc()
