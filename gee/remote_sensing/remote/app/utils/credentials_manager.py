"""GEE Credentials 管理服务"""
import os
import base64
from app.config import config_manager


class CredentialsManager:
    """管理 GEE 用户认证凭证"""
    
    CREDENTIALS_PATH = 'token/ee_credentials'
    
    @classmethod
    def sync_from_database(cls):
        """从数据库同步 credentials 到本地文件"""
        try:
            # 从数据库读取 credentials（base64 编码）
            credentials_b64 = config_manager.get('GEE_USER_CREDENTIALS')
            
            if not credentials_b64:
                print("⚠️  数据库中未找到 GEE_USER_CREDENTIALS 配置")
                return False
            
            # Base64 解码
            credentials_content = base64.b64decode(credentials_b64).decode('utf-8')
            
            # 确保目录存在
            os.makedirs(os.path.dirname(cls.CREDENTIALS_PATH), exist_ok=True)
            
            # 写入文件
            with open(cls.CREDENTIALS_PATH, 'w', encoding='utf-8') as f:
                f.write(credentials_content)
            
            print(f"✅ GEE 用户凭证已从数据库同步到: {cls.CREDENTIALS_PATH}")
            return True
            
        except Exception as e:
            print(f"❌ 同步 GEE 凭证失败: {e}")
            return False
    
    @classmethod
    def upload_to_database(cls, credentials_file_path: str):
        """
        将本地 credentials 文件上传到数据库
        
        Args:
            credentials_file_path: 本地 credentials 文件路径
        """
        try:
            # 读取文件内容
            with open(credentials_file_path, 'r', encoding='utf-8') as f:
                credentials_content = f.read()
            
            # Base64 编码
            credentials_b64 = base64.b64encode(credentials_content.encode('utf-8')).decode('utf-8')
            
            # 保存到数据库
            conn = config_manager._get_connection()
            try:
                cursor = conn.cursor()
                cursor.execute('''
                    INSERT INTO gee_config (config_key, config_value, config_type, config_group, description, is_enabled)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    ON CONFLICT (config_key) DO UPDATE 
                    SET config_value = EXCLUDED.config_value, 
                        updated_at = CURRENT_TIMESTAMP
                ''', (
                    'GEE_USER_CREDENTIALS',
                    credentials_b64,
                    'string',
                    'gee',
                    'GEE 用户认证凭证（Base64 编码）',
                    True
                ))
                conn.commit()
                print(f"✅ GEE 凭证已上传到数据库")
                return True
            finally:
                config_manager._put_connection(conn)
                
        except Exception as e:
            print(f"❌ 上传 GEE 凭证失败: {e}")
            return False


def sync_credentials_on_startup():
    """Worker 启动时同步凭证"""
    print("\n" + "=" * 80)
    print("🔄 同步 GEE 用户凭证...")
    print("=" * 80)
    
    success = CredentialsManager.sync_from_database()
    
    if success:
        print("✅ GEE 凭证同步完成")
    else:
        print("⚠️  GEE 凭证同步失败，将尝试使用服务账号认证")
    
    print("=" * 80 + "\n")
    
    return success


if __name__ == "__main__":
    # 用于手动上传 credentials
    import sys
    
    if len(sys.argv) < 2:
        print("用法: python credentials_manager.py <credentials_file_path>")
        print("示例: python credentials_manager.py C:\\Users\\YourName\\.config\\earthengine\\credentials")
        sys.exit(1)
    
    credentials_file = sys.argv[1]
    
    if not os.path.exists(credentials_file):
        print(f"❌ 文件不存在: {credentials_file}")
        sys.exit(1)
    
    print(f"📤 上传 credentials 到数据库...")
    print(f"   文件: {credentials_file}")
    
    if CredentialsManager.upload_to_database(credentials_file):
        print("\n✅ 上传成功！")
        print("\n现在可以重启 Celery worker，它会自动从数据库下载凭证")
    else:
        print("\n❌ 上传失败")
        sys.exit(1)
