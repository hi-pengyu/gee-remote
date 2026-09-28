"""测试回调机制"""
import time
import requests
from flask import Flask, request, jsonify
import threading

# 创建简单的回调接收服务器
app = Flask(__name__)

received_callbacks = []

@app.route('/callback', methods=['POST'])
def receive_callback():
    """接收回调通知"""
    data = request.get_json()
    print("\n" + "="*60)
    print("📨 收到回调通知！")
    print("="*60)
    print(f"任务ID: {data.get('task_id')}")
    print(f"状态: {data.get('status')}")
    print(f"时间戳: {data.get('timestamp')}")

    if data.get('status') == 'success':
        print(f"\n✅ 任务成功！")
        result = data.get('result', {})
        print(f"文件名: {result.get('file_name')}")
        print(f"TIF路径: {result.get('tif_path')}")
        if result.get('all_models'):
            print(f"模型数量: {len(result.get('all_models_results', []))}")
        else:
            print(f"模型类型: {result.get('metadata', {}).get('model_type')}")
    else:
        print(f"\n❌ 任务失败！")
        print(f"错误信息: {data.get('error')}")

    print("="*60 + "\n")

    received_callbacks.append(data)
    return jsonify({"status": "ok", "message": "回调已接收"})

def run_flask_server():
    """在后台运行Flask服务器"""
    app.run(host='0.0.0.0', port=5001, debug=False)

def test_callback_with_real_workflow():
    """测试真实工作流的回调"""
    print("\n🚀 测试1: 使用真实工作流测试回调")
    print("="*60)

    # 提交任务，附带回调URL
    response = requests.post("http://localhost:8000/api/v1/workflow/run", json={
        "aoi_coords": [
            [86.038, 44.552],
            [86.039, 44.553],
            [86.040, 44.554]
        ],
        "target_date": "2025-09-21",
        "model_type": "agb",
        "callback_url": "http://localhost:5001/callback"
    })

    if response.status_code == 202:
        task_data = response.json()
        task_id = task_data['task_id']
        print(f"✓ 任务已提交: {task_id}")
        print(f"消息: {task_data['message']}")
        print("\n⏳ 等待任务完成和回调通知...\n")

        # 轮询任务状态
        while True:
            time.sleep(5)
            status_response = requests.get(f"http://localhost:8000/api/v1/tasks/{task_id}")
            status_data = status_response.json()

            print(f"进度: {status_data.get('progress', 0)}% - {status_data.get('current_step', '处理中...')}")

            if status_data['status'] in ['success', 'failure']:
                print(f"\n任务结束，状态: {status_data['status']}")
                break

        # 等待一会儿确保回调已发送
        time.sleep(3)

        if received_callbacks:
            print(f"\n✅ 回调测试成功！收到 {len(received_callbacks)} 个回调")
        else:
            print("\n⚠️  未收到回调通知")
    else:
        print(f"❌ 任务提交失败: {response.status_code}")
        print(response.text)

def test_callback_api_query():
    """测试算法查询接口"""
    print("\n🚀 测试2: 查询可用算法")
    print("="*60)

    response = requests.get("http://localhost:8000/api/v1/models")

    if response.status_code == 200:
        data = response.json()
        print(f"✓ 查询成功！")
        print(f"总数: {data['total']}")
        print(f"支持all模式: {data['support_all']}\n")

        print("可用模型:")
        for model in data['models']:
            print(f"  • {model['code']:6} - {model['name']:12} ({model['description']}) [{model['unit']}]")

        print(f"\n提示: {data['message']}")
        print("\n✅ 算法查询接口测试通过！")
    else:
        print(f"❌ 查询失败: {response.status_code}")
        print(response.text)

def test_without_callback():
    """测试不使用回调的情况（兼容性测试）"""
    print("\n🚀 测试3: 不使用回调（兼容性测试）")
    print("="*60)

    response = requests.post("http://localhost:8000/api/v1/workflow/run", json={
        "aoi_coords": [
            [86.038, 44.552],
            [86.039, 44.553]
        ],
        "target_date": "2025-09-21",
        "model_type": "agb"
        # 不提供callback_url
    })

    if response.status_code == 202:
        task_data = response.json()
        print(f"✓ 任务已提交（无回调）: {task_data['task_id']}")
        print(f"消息: {task_data['message']}")
        print("\n✅ 兼容性测试通过！原有逻辑正常工作")
    else:
        print(f"❌ 任务提交失败: {response.status_code}")

if __name__ == "__main__":
    print("="*60)
    print("🧪 回调机制测试套件")
    print("="*60)

    # 启动Flask回调接收服务器
    print("\n启动回调接收服务器 (http://localhost:5001)...")
    flask_thread = threading.Thread(target=run_flask_server, daemon=True)
    flask_thread.start()
    time.sleep(2)  # 等待服务器启动

    print("✓ 回调服务器已启动\n")

    try:
        # 测试1: 算法查询接口
        test_callback_api_query()

        # 测试2: 不使用回调的兼容性测试
        test_without_callback()

        # 测试3: 使用回调的真实工作流（耗时较长，可选）
        print("\n" + "="*60)
        user_input = input("是否测试真实工作流的回调？(需要1-2分钟) [y/N]: ")
        if user_input.lower() == 'y':
            test_callback_with_real_workflow()
        else:
            print("跳过真实工作流测试")

        print("\n" + "="*60)
        print("✅ 所有测试完成！")
        print("="*60)

    except KeyboardInterrupt:
        print("\n\n测试中断")
    except Exception as e:
        print(f"\n❌ 测试失败: {e}")
        import traceback
        traceback.print_exc()
