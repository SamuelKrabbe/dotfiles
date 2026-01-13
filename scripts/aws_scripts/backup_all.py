#!/usr/bin/env python3

# With CLI -> aws s3 sync /path/to/mom-user-folder s3://your-bucket-name --storage-class STANDARD --acl private

import os
import sys
import threading
import math
import boto3
from boto3.s3.transfer import TransferConfig

if len(sys.argv) != 3:
    print("Usage: python upload_all.py /path/to/source bucket-name")
    sys.exit(1)

source_root = os.path.abspath(sys.argv[1])
bucket = sys.argv[2]
s3 = boto3.client('s3')

# Tune multipart thresholds (default is fine; shown for clarity)
config = TransferConfig(multipart_threshold=8 * 1024 * 1024,  # 8MB
                        multipart_chunksize=64 * 1024 * 1024,  # 64MB
                        max_concurrency=10)

class ProgressPercentage:
    def __init__(self, filename):
        self._filename = filename
        self._size = float(os.path.getsize(filename))
        self._seen_so_far = 0
        self._lock = threading.Lock()

    def __call__(self, bytes_amount):
        with self._lock:
            self._seen_so_far += bytes_amount
            pct = (self._seen_so_far / self._size) * 100
            print(f"\r{os.path.basename(self._filename)}  {self._seen_so_far:.0f}/{self._size:.0f} bytes  ({pct:.1f}%)", end='')
            if self._seen_so_far >= self._size:
                print()

for root, dirs, files in os.walk(source_root):
    # Skip system directories if needed; user decision
    rel_root = os.path.relpath(root, source_root)
    for fname in files:
        local_path = os.path.join(root, fname)
        key = os.path.join(rel_root, fname) if rel_root != '.' else fname
        key = key.replace("\\", "/")
        try:
            print(f"Uploading {local_path} -> s3://{bucket}/{key}")
            s3.upload_file(local_path, bucket, key,
                           ExtraArgs={'ServerSideEncryption': 'AES256'},
                           Config=config,
                           Callback=ProgressPercentage(local_path))
        except Exception as e:
            print(f"FAILED: {local_path}: {e}")
