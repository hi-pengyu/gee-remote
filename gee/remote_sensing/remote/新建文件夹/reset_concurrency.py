"""
重置GEE并发控制信号量

当任务异常终止时，Redis中的信号量可能没有正确释放，
导致新任务一直等待。此脚本用于重置信号量。
"""
import sys
import os

# 添加项目路径
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.concurrency_control import get_gee_concurrency_control

def main():
    print("=" * 60)
    print("GEE 并发控制信号量重置工具")
    print("=" * 60)
    
    # 获取并发控制器
    concurrency_control = get_gee_concurrency_control()
    
    # 显示当前状态
    current_count = concurrency_control.get_current_count()
    available_slots = concurrency_control.get_available_slots()
    
    print(f"\n当前状态:")
    print(f"  正在执行的任务数: {current_count}")
    print(f"  可用槽位数: {available_slots}")
    print(f"  最大并发数: {concurrency_control.max_concurrent}")
    
    # 询问是否重置
    if current_count > 0:
        print(f"\n⚠️  检测到 {current_count} 个任务占用信号量")
        print("   如果这些任务已经结束但信号量未释放，可以重置")
        
        choice = input("\n是否重置信号量? (y/n): ").strip().lower()
        
        if choice == 'y':
            concurrency_control.reset()
            print("\n✅ 信号量已重置")
            print(f"   当前任务数: {concurrency_control.get_current_count()}")
            print(f"   可用槽位: {concurrency_control.get_available_slots()}")
        else:
            print("\n❌ 取消重置")
    else:
        print("\n✅ 信号量状态正常，无需重置")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
