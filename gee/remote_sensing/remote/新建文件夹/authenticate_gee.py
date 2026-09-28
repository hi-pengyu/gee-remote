#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
GEE 用户认证工具
用于在本地浏览器中完成认证，生成 credentials 文件
"""

import ee

print("=" * 80)
print("🔐 GEE 用户认证工具")
print("=" * 80)
print()
print("这个脚本会:")
print("1. 在浏览器中打开 Google 认证页面")
print("2. 你登录并授权后，会生成一个 credentials 文件")
print("3. 将这个文件复制到服务器上即可使用")
print()
print("=" * 80)
print()

try:
    # 使用用户认证方式初始化
    # 这会在浏览器中打开认证页面
    ee.Authenticate()
    
    print("\n✅ 认证成功！")
    print()
    print("Credentials 文件已保存到:")
    print("Windows: C:\\Users\\<你的用户名>\\.config\\earthengine\\credentials")
    print("Linux/Mac: ~/.config/earthengine/credentials")
    print()
    print("请将这个文件复制到服务器的以下位置:")
    print("F:\\gee\\remote\\token\\ee_credentials")
    print()
    
    # 测试初始化
    ee.Initialize(project='<REDACTED_GCP_PROJECT_ID>')
    print("✅ GEE 初始化成功！")
    
    # 简单测试
    print("\n🧪 测试查询...")
    collection = ee.ImageCollection('COPERNICUS/S2_SR') \
        .filterDate('2024-01-01', '2024-01-31') \
        .limit(1)
    count = collection.size().getInfo()
    print(f"✅ 测试成功！找到 {count} 张影像")
    
    print("\n" + "=" * 80)
    print("✅ 所有测试通过！现在可以将 credentials 文件复制到服务器了")
    print("=" * 80)
    
except Exception as e:
    print(f"\n❌ 错误: {e}")
    print("\n请确保:")
    print("1. 已安装 earthengine-api: pip install earthengine-api")
    print("2. 网络连接正常")
    print("3. 可以访问 Google 服务")
