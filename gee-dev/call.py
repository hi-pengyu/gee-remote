import requests
import json

# --- 配置 ---
API_URL = "http://<REDACTED_API_HOST>:32011/predict"
CSV_PATH = "input_for_api.csv"
YOUR_API_KEY = "admin"  # 替换成你的 API Key
MODEL_TO_RUN = ("zg")  # 选择你要运行的模型 (agb, k, n, ...)

# ----------------

print(f"正在调用模型: {MODEL_TO_RUN}...")

# 1. 设置查询参数 (选择模型)
params = {
    'model_type': MODEL_TO_RUN
}

# 2. 设置请求头 (API Key)
headers = {
    'X-API-Key': YOUR_API_KEY
}

# 3. 打开 CSV 文件并发送
try:
    with open(CSV_PATH, 'rb') as f:
        files = {
            'file': (CSV_PATH, f, 'text/csv')
        }

        response = requests.post(
            API_URL,
            params=params,
            headers=headers,
            files=files
        )

    # 4. 处理响应
    if response.status_code == 200:
        result = response.json()
        print("API 调用成功！")
        print(f"状态: {result.get('status')}")

        if result.get('status') == 'success':
            print(f"成功预测了 {len(result.get('results', []))} 个点")
            # 你可以在这里保存 result['results']
            with open(f"prediction_{MODEL_TO_RUN}.json", "w") as out_f:
                json.dump(result, out_f, indent=2)
            print(f"结果已保存到 prediction_{MODEL_TO_RUN}.json")

        elif result.get('status') == 'warning':
            print(f"警告: {result.get('message')}")
            print(f"返回的指数: {result.get('indices')}")

    else:
        print(f"API 调用失败，状态码: {response.status_code}")
        print(f"错误详情: {response.text}")

except requests.exceptions.ConnectionError:
    print("错误：无法连接到 API。请确保 api.py 正在 127.0.0.1:8001 运行。")
except FileNotFoundError:
    print(f"错误：找不到 CSV 文件: {CSV_PATH}。请先运行 prepare_data.py。")