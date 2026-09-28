"""测试配置热重载功能"""
import sys
sys.path.insert(0, 'f:/gee')

from app.config import config_manager, settings

print("=" * 60)
print("配置热重载测试")
print("=" * 60)

# 1. 测试配置加载
print("\n1. 测试配置加载:")
print(f"   GEE_PROJECT_ID: {settings.GEE_PROJECT_ID}")
print(f"   GEE_SCALE: {settings.GEE_SCALE}")
print(f"   REDIS_HOST: {settings.REDIS_HOST}")

# 2. 测试Redis连接
print("\n2. 测试Redis连接:")
if config_manager._redis_client:
    try:
        config_manager._redis_client.ping()
        print("   ✅ Redis连接成功")
    except Exception as e:
        print(f"   ❌ Redis连接失败: {e}")
else:
    print("   ❌ Redis客户端未初始化")

# 3. 测试配置监听线程
print("\n3. 测试配置监听线程:")
if config_manager._pubsub_thread:
    if config_manager._pubsub_thread.is_alive():
        print("   ✅ 配置监听线程正在运行")
    else:
        print("   ❌ 配置监听线程已停止")
else:
    print("   ❌ 配置监听线程未启动")

# 4. 测试发布消息
print("\n4. 测试发布配置重载消息:")
try:
    config_manager.publish_reload("测试消息")
    print("   ✅ 消息发布成功")
except Exception as e:
    print(f"   ❌ 消息发布失败: {e}")

# 5. 等待接收消息
print("\n5. 等待接收消息（5秒）...")
import time
time.sleep(5)

print("\n" + "=" * 60)
print("测试完成")
print("=" * 60)
