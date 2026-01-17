#!/usr/bin/env python3

# With CLI -> aws s3 sync s3://your-bucket-name /path/to/restore-folder

import os
import sys
import threading
import boto3
from boto3.s3.transfer import TransferConfig

if len(sys.argv) != 3:
    print("Usage: python download_all.py bucket-name /path/to/destination")
    sys.exit(1)

bucket = sys.argv[1]
dest_root = os.path.abspath(sys.argv[2])
os.makedirs(dest_root, exist_ok=True)
s3 = boto3.client('s3')

config = TransferConfig(multipart_threshold=8 * 1024 * 1024,
                        multipart_chunksize=64 * 1024 * 1024,
                        max_concurrency=10)

# list objects and download
paginator = s3.get_paginator('list_objects_v2')
for page in paginator.paginate(Bucket=bucket):
    for obj in page.get('Contents', []):
        key = obj['Key']
        local_path = os.path.join(dest_root, *key.split('/'))
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        print(f"Downloading s3://{bucket}/{key} -> {local_path}")
        try:
            s3.download_file(bucket, key, local_path, Config=config)
        except Exception as e:
            print(f"FAILED: {key}: {e}")
