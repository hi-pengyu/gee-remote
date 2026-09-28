"""
Celery 连接诊断脚本
用于检查 Celery 和 Redis 的连接状态
"""
import redis
from celery import Celery
from app.config import settings

print("=" * 60)
print("🔍 Celery 和 Redis 连接诊断")
print("=" * 60)

# 1. 测试 Redis 连接
print("\n1️⃣ 测试 Redis 连接...")
print(f"   配置: {settings.REDIS_HOST}:{settings.REDIS_PORT}/{settings.REDIS_DB}")
print(f"   密码: {'已设置' if settings.REDIS_PASSWORD else '未设置'}")

try:
    r = redis.Redis(
        host=settings.REDIS_HOST,
        port=settings.REDIS_PORT,
        db=settings.REDIS_DB,
        password=settings.REDIS_PASSWORD,
        socket_connect_timeout=5
    )
    r.ping()
    print("   ✅ Redis 连接成功！")
    
    # 显示 Redis 信息
    info = r.info()
    print(f"   Redis 版本: {info['redis_version']}")
    print(f"   已连接客户端: {info['connected_clients']}")
    
except redis.ConnectionError as e:
    print(f"   ❌ Redis 连接失败: {e}")
    exit(1)
except redis.AuthenticationError as e:
    print(f"   ❌ Redis 认证失败: {e}")
    print("   请检查密码是否正确！")
    exit(1)
except Exception as e:
    print(f"   ❌ 未知错误: {e}")
    exit(1)

# 2. 测试 Celery Broker 连接
print("\n2️⃣ 测试 Celery Broker...")
print(f"   Broker URL: {settings.CELERY_BROKER_URL}")

try:
    # 创建临时 Celery 实例
    app = Celery('test', broker=settings.CELERY_BROKER_URL)
    
    # 检查连接
    conn = app.connection()
    conn.connect()
    print("   ✅ Celery Broker 连接成功！")
    conn.close()
    
except Exception as e:
    print(f"   ❌ Celery Broker 连接失败: {e}")
    exit(1)

# 3. 检查 Celery Workers
print("\n3️⃣ 检查 Celery Workers...")

try:
    from app.celery_app import celery_app
    
    inspect = celery_app.control.inspect(timeout=3)
    
    # 获取活跃的 workers
    active_workers = inspect.active()
    
    if active_workers:
        print(f"   ✅ 找到 {len(active_workers)} 个活跃 Worker:")
        for worker_name, tasks in active_workers.items():
            print(f"      - {worker_name}: {len(tasks)} 个任务运行中")
    else:
        print("   ⚠️  没有找到活跃的 Worker！")
        print("   请确保已启动 Celery Worker:")
        print("   celery -A app.celery_app worker --loglevel=info -Q gee_queue --pool=solo")
    
    # 获取注册的任务
    registered_tasks = inspect.registered()
    if registered_tasks:
        print(f"\n   📋 注册的任务:")
        for worker_name, tasks in registered_tasks.items():
            print(f"      Worker: {worker_name}")
            for task in tasks:
                if 'gee' in task:
                    print(f"         ✓ {task}")
    
except Exception as e:
    print(f"   ⚠️  无法检查 Workers: {e}")
    print("   这可能意味着 Worker 未启动")

# 4. 测试任务提交
print("\n4️⃣ 测试任务提交...")

try:
    from app.tasks.workflow import full_workflow_task
    
    # 提交一个测试任务（不会真正执行，因为参数无效）
    test_coords = [[0, 0], [0, 1], [1, 1], [1, 0], [0, 0]]
    
    print("   提交测试任务...")
    task = full_workflow_task.delay(
        aoi_coords=test_coords,
        target_date="2025-01-01",
        model_type="agb"
    )
    
    print(f"   ✅ 任务提交成功！")
    print(f"   Task ID: {task.id}")
    print(f"   初始状态: {task.state}")
    
    # 等待一下看状态变化
    import time
    time.sleep(2)
    
    print(f"   2秒后状态: {task.state}")
    
    if task.state == 'PENDING':
        print("   ⚠️  任务仍在 PENDING 状态，可能 Worker 没有运行")
    elif task.state == 'STARTED':
        print("   ✅ 任务已被 Worker 接收并开始执行")
        # 取消测试任务
        task.revoke(terminate=True)
        print("   (已取消测试任务)")
    
except Exception as e:
    print(f"   ❌ 任务提交失败: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 60)
print("✅ 诊断完成！")
print("=" * 60)
print("\n💡 如果发现问题：")
print("1. 确保 Redis 正在运行并且密码正确")
print("2. 确保 Celery Worker 已启动:")
print("   celery -A app.celery_app worker --loglevel=debug -Q gee_queue --pool=solo")
print("3. 检查防火墙是否阻止了 Redis 端口")
print("4. 查看 Celery Worker 的日志输出")

