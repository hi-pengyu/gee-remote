#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
GEE 用户认证测试脚本
用于测试用户认证并生成 Base64 编码的 credentials，用于添加到后台账号池
"""

import json
import ee
import base64
import os
import sys
from datetime import datetime

print("=" * 80)
print("🔐 GEE 用户认证工具")
print("=" * 80)
print()

# 默认 credentials 路径
if os.name == 'nt':  # Windows
    DEFAULT_CREDENTIALS_PATH = os.path.expanduser(r"~\.config\earthengine\credentials")
else:  # Linux/Mac
    DEFAULT_CREDENTIALS_PATH = os.path.expanduser("~/.config/earthengine/credentials")

def test_gee_auth():
    """测试 GEE 认证并生成配置"""
    try:
        print(f"检查 Credentials 文件: {DEFAULT_CREDENTIALS_PATH}")
        
        if not os.path.exists(DEFAULT_CREDENTIALS_PATH):
            print("❌ 文件不存在，开始手动认证...")
            print("   浏览器将打开 Google 认证页面，请登录并授权")
            # 强制认证
            ee.Authenticate()
            print("\n✅ 认证成功！Credentials 文件已生成。")
        else:
            print("✅ 发现现有 Credentials 文件。")
            
        # 测试初始化
        print("\n📋 正在测试 GEE 初始化 (Project: <REDACTED_GCP_PROJECT_ID>)...")
        try:
            ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
            print("✅ GEE 初始化成功！")
        except Exception as e:
            print(f"⚠️ 初始化失败: {e}")
            print("尝试重新认证...")
            ee.Authenticate()
            ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
            print("✅ GEE 初始化成功！")
        
        # 简单测试
        print("\n📋 测试数据查询...")
        try:
            collection = ee.ImageCollection('COPERNICUS/S2_SR') \
                .filterDate('2024-01-01', '2024-01-31') \
                .limit(1)
            count = collection.size().getInfo()
            print(f"✅ 测试成功！找到 {count} 张影像")
        except Exception as e:
            print(f"❌ 数据查询失败: {e}")
            return False
        
        # 读取并编码
        print("\n" + "=" * 80)
        print("📋 生成配置信息")
        print("=" * 80)
        
        with open(DEFAULT_CREDENTIALS_PATH, 'r', encoding='utf-8') as f:
            credentials_content = f.read()
        
        # Base64 编码
        credentials_b64 = base64.b64encode(credentials_content.encode('utf-8')).decode('utf-8')
        
        print(f"\n✅ Credentials Base64 编码 (请复制以下内容到后台 'Credentials' 字段):")
        print("-" * 20 + " 开始复制 " + "-" * 20)
        print(credentials_b64)
        print("-" * 20 + " 结束复制 " + "-" * 20)
        
        # 也可以生成一个 SQL 文件备用
        sql_file = "insert_account.sql"
        with open(sql_file, 'w', encoding='utf-8') as f:
            f.write("-- 插入 GEE 账号 SQL\n")
            f.write(f"-- 生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write("INSERT INTO gee_accounts (account_name, project_id, credentials_json, priority, description)\n")
            f.write("VALUES (\n")
            f.write("    'My User Account',\n")
            f.write("    '<REDACTED_GCP_PROJECT_ID>',\n")
            f.write(f"    '{credentials_b64}',\n")
            f.write("    100,\n")
            f.write("    '自动生成的本地用户认证账号'\n")
            f.write(");\n")
            
        print(f"\n💡 已生成 SQL 备份文件: {os.path.abspath(sql_file)}")
        print("   (如果不想使用后台界面，可以直接在数据库执行此 SQL)")
        
        return True

    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_gee_auth()
