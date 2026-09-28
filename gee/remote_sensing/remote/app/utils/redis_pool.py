"""Redis 连接池管理"""
from redis import ConnectionPool, Redis
from typing import Optional
import os


class RedisPoolManager:
    """Redis 连接池管理器（单例）"""
    
    _pool: Optional[ConnectionPool] = None
    
    @classmethod
    def get_pool(cls, 
                 host: str = None,
                 port: int = None,
                 db: int = None,
                 password: str = None) -> ConnectionPool:
        """
        获取 Redis 连接池单例
        
        Args:
            host: Redis 主机
            port: Redis 端口
            db: Redis 数据库编号
            password: Redis 密码
        
        Returns:
            ConnectionPool 实例
        """
        if cls._pool is None:
            # 从环境变量或参数获取配置
            redis_host = host or os.getenv('REDIS_HOST', '<REDACTED_REDIS_HOST>')
            redis_port = port or int(os.getenv('REDIS_PORT', 6379))
            redis_db = db or int(os.getenv('REDIS_DB', 3))
            redis_password = password or os.getenv('REDIS_PASSWORD', '<REDACTED_REDIS_PASSWORD>')
            
            cls._pool = ConnectionPool(
                host=redis_host,
                port=redis_port,
                db=redis_db,
                password=redis_password if redis_password else None,
                decode_responses=True,
                max_connections=50,  # 最大连接数
                socket_connect_timeout=5,  # 连接超时
                socket_timeout=5,  # 读写超时
                retry_on_timeout=True,  # 超时重试
                health_check_interval=30  # 健康检查间隔（秒）
            )
            
            print(f"✅ Redis 连接池已创建")
            print(f"   Host: {redis_host}:{redis_port}")
            print(f"   DB: {redis_db}")
            print(f"   Max Connections: 50")
        
        return cls._pool
    
    @classmethod
    def get_client(cls,
                   host: str = None,
                   port: int = None,
                   db: int = None,
                   password: str = None) -> Redis:
        """
        获取 Redis 客户端（使用连接池）
        
        Returns:
            Redis 客户端实例
        """
        pool = cls.get_pool(host, port, db, password)
        return Redis(connection_pool=pool)
    
    @classmethod
    def get_pool_stats(cls) -> dict:
        """
        获取连接池统计信息
        
        Returns:
            连接池状态字典
        """
        if cls._pool is None:
            return {
                "initialized": False,
                "message": "连接池未初始化"
            }
        
        # ConnectionPool 的内部状态
        pool = cls._pool
        
        return {
            "initialized": True,
            "max_connections": pool.max_connections,
            "connection_kwargs": {
                "host": pool.connection_kwargs.get('host'),
                "port": pool.connection_kwargs.get('port'),
                "db": pool.connection_kwargs.get('db'),
            },
            # 注意：redis-py 的 ConnectionPool 不直接暴露当前连接数
            # 需要通过 _created_connections 和 _available_connections 推算
            # 但这些是私有属性，不建议在生产环境使用
        }


# 便捷函数
def get_redis_client(**kwargs) -> Redis:
    """获取 Redis 客户端（便捷函数）"""
    return RedisPoolManager.get_client(**kwargs)


def get_redis_pool(**kwargs) -> ConnectionPool:
    """获取 Redis 连接池（便捷函数）"""
    return RedisPoolManager.get_pool(**kwargs)
