"""紧急修复脚本 - 重置Redis并发信号量和清理任务锁"""
import redis
import sys

# Redis配置
REDIS_HOST = '<REDACTED_REDIS_HOST>'
REDIS_PORT = 6379
REDIS_PASSWORD = '<REDACTED_REDIS_PASSWORD>'
REDIS_DB = 3

print("=" * 60)
print("GEE Remote 紧急修复脚本")
print("=" * 60)

try:
    # 连接Redis
    print(f"\n1. 连接Redis: {REDIS_HOST}:{REDIS_PORT} DB:{REDIS_DB}")
    r = redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        password=REDIS_PASSWORD,
        db=REDIS_DB,
        decode_responses=True
    )
    
    # 测试连接
    r.ping()
    print("   ✅ Redis连接成功")
    
    # 检查当前并发数
    print("\n2. 检查当前并发信号量")
    current_value = r.get('gee_concurrency_semaphore')
    print(f"   当前值: {current_value}")
    
    # 重置并发信号量
    print("\n3. 重置并发信号量为0")
    r.set('gee_concurrency_semaphore', 0)
    new_value = r.get('gee_concurrency_semaphore')
    print(f"   ✅ 已重置为: {new_value}")
    
    # 查找所有GEE任务锁
    print("\n4. 查找GEE任务锁")
    task_keys = r.keys('gee:task:*')
    print(f"   找到 {len(task_keys)} 个任务锁")
    
    if task_keys:
        print("\n   任务锁列表:")
        for key in task_keys[:10]:  # 只显示前10个
            print(f"   - {key}")
        if len(task_keys) > 10:
            print(f"   ... 还有 {len(task_keys) - 10} 个")
        
        # 询问是否删除
        response = input("\n   是否删除所有任务锁? (y/n): ").strip().lower()
        if response == 'y':
            deleted = 0
            for key in task_keys:
                r.delete(key)
                deleted += 1
            print(f"   ✅ 已删除 {deleted} 个任务锁")
        else:
            print("   ⏭️  跳过删除任务锁")
    
    # 查找其他GEE相关的key
    print("\n5. 查找其他GEE相关的key")
    all_gee_keys = r.keys('gee*')
    print(f"   找到 {len(all_gee_keys)} 个GEE相关的key")
    
    if all_gee_keys:
        print("\n   GEE相关key:")
        for key in all_gee_keys[:20]:
            key_type = r.type(key)
            if key_type == 'string':
                value = r.get(key)
                print(f"   - {key}: {value}")
            else:
                print(f"   - {key} ({key_type})")
        if len(all_gee_keys) > 20:
            print(f"   ... 还有 {len(all_gee_keys) - 20} 个")
    
    # 验证修复结果
    print("\n" + "=" * 60)
    print("修复完成！验证结果:")
    print("=" * 60)
    print(f"✅ 并发信号量: {r.get('gee_concurrency_semaphore')}")
    print(f"✅ 任务锁数量: {len(r.keys('gee:task:*'))}")
    print("=" * 60)
    
    print("\n提示:")
    print("  1. 现在可以重启Celery worker")
    print("  2. 并发数将从0开始计数")
    print("  3. 如果问题仍然存在，请检查代码中的并发控制逻辑")
    
except redis.ConnectionError as e:
    print(f"\n❌ Redis连接失败: {e}")
    print("\n请检查:")
    print("  1. Redis服务是否运行")
    print("  2. 主机地址和端口是否正确")
    print("  3. 密码是否正确")
    sys.exit(1)
    
except Exception as e:
    print(f"\n❌ 发生错误: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n" + "=" * 60)
print("脚本执行完成")
print("=" * 60)
