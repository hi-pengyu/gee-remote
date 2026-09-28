"""配置管理服务 - 从数据库动态加载配置"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from typing import Any, Dict, List, Optional
import json
import os
import redis
import threading
from functools import lru_cache


class ConfigManager:
    """配置管理器 - 从数据库读取配置"""
    
    _pool = None
    _config_cache = {}
    _cache_initialized = False
    _redis_client = None
    _pubsub_thread = None
    
    def __init__(self):
        """初始化配置管理器"""
        if ConfigManager._pool is None:
            # 数据库配置从环境变量读取（这是唯一不从数据库读取的配置）
            ConfigManager._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=5,
                host=os.environ.get('DB_HOST'),
                port=int(os.environ.get('DB_PORT', 5432)),
                user=os.environ.get('DB_USER'),
                password=os.environ.get('DB_PASSWORD'),
                database=os.environ.get('DB_DATABASE')
            )
        
        # 初始化Redis客户端用于配置热重载
        if ConfigManager._redis_client is None:
            try:
                from app.utils.redis_pool import get_redis_client
                
                ConfigManager._redis_client = get_redis_client(
                    host=os.environ.get('REDIS_HOST'),
                    port=int(os.environ.get('REDIS_PORT', 6379)),
                    db=int(os.environ.get('REDIS_DB', 0)),
                    password=os.environ.get('REDIS_PASSWORD')
                )
                
                # 启动配置重载监听
                self._start_reload_listener()
            except Exception as e:
                print(f"⚠️  Redis连接失败，配置热重载功能不可用: {e}")
    
    def _start_reload_listener(self):
        """启动Redis订阅监听配置重载消息"""
        if ConfigManager._pubsub_thread is None:
            try:
                pubsub = ConfigManager._redis_client.pubsub()
                pubsub.subscribe('gee_config_reload')
                
                def listen_for_reload():
                    """监听配置重载消息"""
                    print("🔊 配置热重载监听已启动")
                    for message in pubsub.listen():
                        if message['type'] == 'message':
                            print(f"📢 收到配置重载消息: {message['data']}")
                            self._reload_configs()
                
                ConfigManager._pubsub_thread = threading.Thread(
                    target=listen_for_reload,
                    daemon=True
                )
                ConfigManager._pubsub_thread.start()
            except Exception as e:
                print(f"⚠️  配置重载监听启动失败: {e}")
    
    def _get_connection(self):
        """获取数据库连接"""
        return ConfigManager._pool.getconn()
    
    def _put_connection(self, conn):
        """归还数据库连接"""
        ConfigManager._pool.putconn(conn)
    
    def _load_all_configs(self) -> Dict[str, Any]:
        """从数据库加载所有配置"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT config_key, config_value, config_type 
                FROM gee_config 
                WHERE is_enabled = TRUE
            ''')
            
            configs = {}
            for row in cursor.fetchall():
                key, value, config_type = row
                configs[key] = self._parse_value(value, config_type)
            
            cursor.close()
            return configs
        finally:
            self._put_connection(conn)
    
    def _parse_value(self, value: str, config_type: str) -> Any:
        """解析配置值"""
        if value is None:
            return None
        
        try:
            if config_type == 'int':
                return int(value)
            elif config_type == 'float':
                return float(value)
            elif config_type == 'bool':
                return value.lower() in ('true', '1', 'yes', 'on')
            elif config_type == 'json':
                return json.loads(value)
            else:  # string
                return value
        except (ValueError, json.JSONDecodeError) as e:
            print(f"⚠️  配置解析错误 [{config_type}] {value}: {e}")
            return value
    
    def initialize_cache(self):
        """初始化配置缓存"""
        if not ConfigManager._cache_initialized:
            ConfigManager._config_cache = self._load_all_configs()
            ConfigManager._cache_initialized = True
            print(f"✅ 配置已从数据库加载 ({len(ConfigManager._config_cache)} 项)")
    
    def get(self, key: str, default: Any = None) -> Any:
        """获取配置值"""
        if not ConfigManager._cache_initialized:
            self.initialize_cache()
        return ConfigManager._config_cache.get(key, default)
    
    def get_by_group(self, group: str) -> Dict[str, Any]:
        """获取指定分组的所有配置"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT config_key, config_value, config_type 
                FROM gee_config 
                WHERE config_group = %s AND is_enabled = TRUE
            ''', (group,))
            
            configs = {}
            for row in cursor.fetchall():
                key, value, config_type = row
                configs[key] = self._parse_value(value, config_type)
            
            cursor.close()
            return configs
        finally:
            self._put_connection(conn)
    
    def set(self, key: str, value: Any, config_type: str = 'string', 
            group: str = 'system', description: str = None, updated_by: str = 'system'):
        """设置配置值"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 转换值为字符串
            if config_type == 'json':
                value_str = json.dumps(value)
            elif config_type == 'bool':
                value_str = 'true' if value else 'false'
            else:
                value_str = str(value)
            
            # 更新或插入
            cursor.execute('''
                INSERT INTO gee_config (config_key, config_value, config_type, config_group, description, updated_by)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (config_key) DO UPDATE SET
                    config_value = EXCLUDED.config_value,
                    config_type = EXCLUDED.config_type,
                    config_group = EXCLUDED.config_group,
                    description = EXCLUDED.description,
                    updated_by = EXCLUDED.updated_by,
                    updated_at = CURRENT_TIMESTAMP
            ''', (key, value_str, config_type, group, description, updated_by))
            
            conn.commit()
            cursor.close()
            
            # 更新缓存
            ConfigManager._config_cache[key] = value
            
            # 发布配置更新消息
            self._publish_reload_message(f"配置已更新: {key}")
            
            return True
        except Exception as e:
            conn.rollback()
            print(f"❌ 配置更新失败: {e}")
            return False
        finally:
            self._put_connection(conn)
    
    def _reload_configs(self):
        """重新加载配置（内部方法）"""
        try:
            ConfigManager._config_cache = self._load_all_configs()
            print(f"🔄 配置已热重载 ({len(ConfigManager._config_cache)} 项)")
        except Exception as e:
            print(f"❌ 配置重载失败: {e}")
    
    def reload(self):
        """重新加载配置（公共方法）"""
        self._reload_configs()
        print(f"🔄 配置已重新加载 ({len(ConfigManager._config_cache)} 项)")
    
    def publish_reload(self, message: str = "配置重载请求"):
        """发布配置重载消息到所有GEE服务实例"""
        self._publish_reload_message(message)
    
    def _publish_reload_message(self, message: str):
        """发布配置重载消息"""
        if ConfigManager._redis_client:
            try:
                ConfigManager._redis_client.publish('gee_config_reload', message)
                print(f"📤 配置重载消息已发布: {message}")
            except Exception as e:
                print(f"⚠️  配置重载消息发布失败: {e}")
    
    def get_all(self) -> Dict[str, Any]:
        """获取所有配置"""
        if not ConfigManager._cache_initialized:
            self.initialize_cache()
        return ConfigManager._config_cache.copy()


# 全局配置管理器实例
config_manager = ConfigManager()


# 兼容旧代码的配置类
class DynamicSettings:
    """动态配置类 - 从数据库读取"""
    
    def __init__(self):
        """初始化时加载配置"""
        config_manager.initialize_cache()
    
    def __getattr__(self, name: str) -> Any:
        """动态获取配置属性"""
        # 数据库配置直接从环境变量读取
        if name.startswith('DB_'):
            env_map = {
                'DB_HOST': os.environ.get('DB_HOST'),
                'DB_PORT': int(os.environ.get('DB_PORT', 5432)),
                'DB_USER': os.environ.get('DB_USER'),
                'DB_PASSWORD': os.environ.get('DB_PASSWORD'),
                'DB_DATABASE': os.environ.get('DB_DATABASE'),
                'DB_SCHEMA': os.environ.get('DB_SCHEMA', 'public'),
            }
            return env_map.get(name)

        if name.startswith('REDIS_') or name.startswith('CELERY_'):
            redis_host = os.environ.get('REDIS_HOST')
            redis_port = os.environ.get('REDIS_PORT', '6379')
            redis_db = os.environ.get('REDIS_DB', '0')
            redis_password = os.environ.get('REDIS_PASSWORD')
            
            # 构建连接URL
            redis_url = f"redis://:<REDACTED_REDIS_PASSWORD>@{redis_host}:{redis_port}/{redis_db}" if redis_password else f"redis://{redis_host}:{redis_port}/{redis_db}"
            
            env_map = {
                'REDIS_HOST': redis_host,
                'REDIS_PORT': int(redis_port),
                'REDIS_DB': int(redis_db),
                'REDIS_PASSWORD': redis_password,
                'CELERY_BROKER_URL': os.environ.get('CELERY_BROKER_URL', redis_url),
                'CELERY_RESULT_BACKEND': os.environ.get('CELERY_RESULT_BACKEND', redis_url),
            }
            if name in env_map:
                return env_map.get(name)
        
        if name.startswith('OSS_'):
            return os.environ.get(name)
        
        # 其他配置从数据库读取
        value = config_manager.get(name)
        if value is None:
            # 如果数据库中没有，返回默认值
            defaults = {
                'APP_NAME': 'GEE FastAPI Service',
                'APP_VERSION': '1.0.0',
                'DEBUG': False,
            }
            return defaults.get(name)
        return value
    
    def reload(self):
        """重新加载配置"""
        config_manager.reload()


# 全局配置实例
settings = DynamicSettings()


def create_storage_dirs():
    """创建必要的存储目录"""
    dirs = [
        settings.STORAGE_TIF_DIR,
        settings.STORAGE_CSV_DIR,
        settings.STORAGE_RESULTS_DIR,
        settings.STORAGE_LOGS_DIR,
        os.path.join(settings.STORAGE_RESULTS_DIR, "images"),
        settings.TILE_STORAGE_PATH,
        os.path.join(settings.TILE_STORAGE_PATH, "crops"),
    ]
    for dir_path in dirs:
        if dir_path:
            os.makedirs(dir_path, exist_ok=True)
    print(f"✅ 存储目录已创建/验证")
