#!/usr/bin/env python3
"""批量修复 OSS 中 PBF 文件的元数据"""
import oss2
# 配置
auth = oss2.Auth('<REDACTED_OSS_ACCESS_KEY_ID>', '<REDACTED_OSS_ACCESS_KEY_SECRET>')
bucket = oss2.Bucket(auth, 'https://oss-cn-beijing.aliyuncs.com', 'yxn-app')
# 遍历并修复
count = 0
for obj in oss2.ObjectIterator(bucket, prefix='archive/'):
    if obj.key.endswith('.pbf'):
        count += 1
        # 用 copy_object 覆盖元数据（不设置 Content-Encoding）
        bucket.copy_object(
            bucket.bucket_name, obj.key, obj.key,
            headers={'Content-Type': 'application/vnd.mapbox-vector-tile'}
        )
        if count % 100 == 0:
            print(f"已修复 {count} 个文件...")
print(f"✅ 完成，共修复 {count} 个文件")