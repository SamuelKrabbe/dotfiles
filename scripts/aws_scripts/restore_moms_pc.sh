#!/usr/bin/env bash

# --- Variables ---
BUCKET="moms-windows10-backup-2025-001b"
DEST="$HOME"
FOLDERS=("Documents" "Pictures" "Videos" "Desktop" "Music")  # Optional: specify only the folders you backed up

echo "Starting restore from s3://$BUCKET to $DEST ..."

for folder in "${FOLDERS[@]}"; do
    SRC_PATH="s3://$BUCKET/$folder"
    DEST_PATH="$DEST/$folder"

    mkdir -p "$DEST_PATH"

    echo "Restoring $folder ..."
    aws s3 sync "$SRC_PATH" "$DEST_PATH"
done

echo "Restore finished."
