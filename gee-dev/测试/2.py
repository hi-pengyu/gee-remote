# -*- coding: utf-8 -*-
import base64
import hmac
import json
import os
import time
import random
import string
import urllib.parse
import datetime
import warnings
import wave
import requests

# 忽略SSL警告（生产环境建议开启验证）
warnings.filterwarnings("ignore", category=requests.packages.urllib3.exceptions.InsecureRequestWarning)

# --- 配置区域 (请在此处填入你的讯飞开放平台信息) ---
APP_ID = "ea0a277b"  # 示例: "37f3f2b5"
API_KEY = "19af30c21d8ba51e9b22a5cba8a2caaa"  # 示例: "a296be0df88f701ec2e4882be7727568"
API_SECRET = "ZGM5NTkxMTdmYWQ0NzBjYmI2Mjc5N2Qw"  # 示例: "moI5WkopgjL1EL5Y..."
AUDIO_PATH = r"F:\gee-简单版\测试\123.wav"  # 你的本地WAV音频文件路径
# ------------------------------------------------

# 讯飞API地址
LFASR_HOST = "https://office-api-ist-dx.iflyaisol.com"
API_UPLOAD = "/v2/upload"
API_GET_RESULT = "/v2/getResult"


def parse_order_result(api_response):
    """
    解析完整的API响应，提取orderResult中的所有w字段内容并拼接
    """
    try:
        # 1. 检查最外层 Code
        if str(api_response.get('code')) != "000000":
            print(f"API返回错误: {api_response.get('descInfo')}")
            return ""

        # 2. 获取 orderResult 字符串
        content = api_response.get('content', {})
        order_result_str = content.get('orderResult', '{}')

        # 如果还在处理中或者结果为空
        if not order_result_str:
            return ""

        # 3. 解析内部嵌套的 JSON
        # 讯飞返回的 orderResult 是一个被转义的 JSON 字符串，需要二次解析
        try:
            order_result = json.loads(order_result_str)
        except json.JSONDecodeError:
            # 有时候可能会因为转义符问题导致直接loads失败，尝试简单的清洗
            import re
            cleaned_str = re.sub(r'\\\\', r'\\', order_result_str)
            order_result = json.loads(cleaned_str)

        w_values = []

        # 4. 遍历 lattice -> json_1best -> st -> rt -> ws -> cw -> w
        if 'lattice' in order_result:
            for lattice_item in order_result['lattice']:
                if 'json_1best' in lattice_item:
                    # 三次解析：json_1best 也是一个 JSON 字符串
                    json_1best = json.loads(lattice_item['json_1best'])

                    if 'st' in json_1best and 'rt' in json_1best['st']:
                        for rt_item in json_1best['st']['rt']:
                            if 'ws' in rt_item:
                                for ws_item in rt_item['ws']:
                                    if 'cw' in ws_item:
                                        for cw_item in ws_item['cw']:
                                            if 'w' in cw_item:
                                                w_values.append(cw_item['w'])

        return ''.join(w_values)

    except Exception as e:
        print(f"解析结果时出错: {e}")
        return ""


class XfyunAsrClient:
    def __init__(self, appid, access_key_id, access_key_secret, audio_file_path):
        self.appid = appid
        self.access_key_id = access_key_id
        self.access_key_secret = access_key_secret
        self.audio_file_path = self._check_audio_path(audio_file_path)
        self.audio_duration = self._get_wav_duration_ms()
        self.order_id = None
        self.signature_random = self._generate_random_str()
        self.upload_url = ""

    def _check_audio_path(self, path):
        if not os.path.exists(path):
            raise FileNotFoundError(f"音频文件不存在：{path}")
        if not path.lower().endswith(".wav"):
            raise ValueError(f"本代码仅支持WAV格式，你的文件是: {os.path.splitext(path)[1]}")
        return os.path.abspath(path)

    def _generate_random_str(self, length=16):
        return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

    def _get_local_time_with_tz(self):
        """生成符合讯飞要求的带时区时间格式: yyyy-MM-dd'T'HH:mm:ss±HHmm"""
        local_now = datetime.datetime.now()
        # 获取本地时区偏移，例如 +0800
        # python 3.2+ 支持 astimezone() 获取带时区时间
        tz_offset = local_now.astimezone().strftime('%z')
        # 如果系统时区获取失败，默认写死为东八区 +0800 (根据实际情况调整)
        if not tz_offset:
            tz_offset = "+0800"
        return f"{local_now.strftime('%Y-%m-%dT%H:%M:%S')}{tz_offset}"

    def _get_wav_duration_ms(self):
        """使用 wave 库获取时长（毫秒）"""
        try:
            with wave.open(self.audio_file_path, 'rb') as wav_file:
                n_frames = wav_file.getnframes()
                sample_rate = wav_file.getframerate()
                # 必须转换为整数
                return int(round(n_frames / sample_rate * 1000))
        except Exception as e:
            raise Exception(f"读取音频时长失败: {e}")

    def generate_signature(self, params):
        """
        生成鉴权签名
        规则: 排除signature -> 按key排序 -> URL编码key和value -> 拼接 -> HMAC-SHA1 -> Base64
        """
        params_copy = params.copy()
        if "signature" in params_copy:
            del params_copy["signature"]

        # 1. 排序
        sorted_params = sorted(params_copy.items(), key=lambda x: x[0])

        # 2. 构建 BaseString (Key 和 Value 都要 URL 编码)
        base_parts = []
        for k, v in sorted_params:
            if v is not None and str(v) != "":
                encoded_key = urllib.parse.quote(k, safe='')
                encoded_value = urllib.parse.quote(str(v), safe='')
                base_parts.append(f"{encoded_key}={encoded_value}")

        base_string = "&".join(base_parts)

        # 3. HMAC-SHA1 加密
        hmac_obj = hmac.new(
            self.access_key_secret.encode("utf-8"),
            base_string.encode("utf-8"),
            digestmod="sha1"
        )

        # 4. Base64 编码
        signature = base64.b64encode(hmac_obj.digest()).decode("utf-8")
        return signature

    def upload_audio(self):
        print(f"正在上传音频: {os.path.basename(self.audio_file_path)} ...")

        # 准备参数
        file_size = os.path.getsize(self.audio_file_path)
        file_name = os.path.basename(self.audio_file_path)
        date_time = self._get_local_time_with_tz()

        url_params = {
            "appId": self.appid,
            "accessKeyId": self.access_key_id,
            "dateTime": date_time,
            "signatureRandom": self.signature_random,
            "fileSize": str(file_size),
            "fileName": file_name,
            "language": "autodialect",  # 自动识别方言
            "duration": str(self.audio_duration)
        }

        # 生成签名
        signature = self.generate_signature(url_params)

        # 请求头
        headers = {
            "Content-Type": "application/octet-stream",
            "signature": signature
        }

        # 拼接 URL 参数 (Key和Value都需要编码)
        query_str = urllib.parse.urlencode(url_params)
        full_url = f"{LFASR_HOST}{API_UPLOAD}?{query_str}"

        # 读取文件内容
        with open(self.audio_file_path, "rb") as f:
            audio_data = f.read()

        # 发送请求
        try:
            resp = requests.post(full_url, headers=headers, data=audio_data, verify=False)
            resp_json = resp.json()

            if resp_json.get("code") == "000000":
                self.order_id = resp_json["content"]["orderId"]
                estimate_time = resp_json["content"].get("taskEstimateTime", 0)
                print(f"上传成功! 订单ID: {self.order_id}, 预计耗时: {estimate_time}ms")
                return True
            else:
                print(f"上传失败: {resp.text}")
                return False
        except Exception as e:
            print(f"上传请求异常: {e}")
            return False

    def get_result(self):
        if not self.order_id:
            print("没有订单ID，无法查询")
            return None

        print("开始轮询查询结果...")

        # 轮询逻辑
        while True:
            date_time = self._get_local_time_with_tz()

            # 这里的参数必须严格按照文档，resultType 是必须的
            query_params = {
                "appId": self.appid,
                "accessKeyId": self.access_key_id,
                "dateTime": date_time,
                "signatureRandom": self.signature_random,
                "orderId": self.order_id,
                "resultType": "transfer"  # 固定值，表示查询转写结果
            }

            signature = self.generate_signature(query_params)

            headers = {
                "Content-Type": "application/json",
                "signature": signature
            }

            query_str = urllib.parse.urlencode(query_params)
            full_url = f"{LFASR_HOST}{API_GET_RESULT}?{query_str}"

            try:
                # 这里的 body 必须是空 JSON 对象 {}
                resp = requests.post(full_url, headers=headers, json={}, verify=False)
                resp_json = resp.json()

                if resp_json.get("code") != "000000":
                    print(f"查询出错: {resp_json.get('descInfo')}")
                    break

                content = resp_json.get("content", {})
                order_info = content.get("orderInfo", {})
                status = order_info.get("status")

                # status: 3 处理中, 4 已完成, -1 失败
                if status == 4:
                    print("转写完成!")
                    return resp_json
                elif status == -1:
                    print("转写失败!")
                    fail_type = order_info.get("failType")
                    print(f"失败类型: {fail_type}")
                    break
                elif status == 3:
                    print("正在处理中...等待 5 秒后重试")
                    time.sleep(5)
                else:
                    print(f"未知状态: {status}, 等待重试")
                    time.sleep(5)

            except Exception as e:
                print(f"查询请求异常: {e}")
                break
        return None


if __name__ == "__main__":
    # 1. 检查配置是否已填写
    if APP_ID == "你的AppID":
        print("错误：请先在代码顶部的配置区域填入你的 APP_ID, API_KEY, API_SECRET")
        exit()

    try:
        # 2. 初始化客户端
        client = XfyunAsrClient(APP_ID, API_KEY, API_SECRET, AUDIO_PATH)

        # 3. 上传音频
        if client.upload_audio():
            # 4. 获取结果
            full_result = client.get_result()

            if full_result:
                # 5. 解析并打印文本
                text = parse_order_result(full_result)
                print("\n" + "=" * 30)
                print("最终识别文本:")
                print("=" * 30)
                print(text)
                print("=" * 30)

    except FileNotFoundError as e:
        print(f"文件错误: {e}")
    except ValueError as e:
        print(f"格式错误: {e}")
    except Exception as e:
        print(f"运行出错: {e}")