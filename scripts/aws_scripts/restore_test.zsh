#!usr/bin/env zsh

BUCKET="backup-test-001b"
TEST_FOLDER="test_images"
DEST="$HOME/Downloads/$TEST_FOLDER"

mkdir -p "$DEST"

echo "Restoring $TEST_FOLDER from s3://$BUCKET/$TEST_FOLDER to $DEST ..."
aws s3 sync "s3://$BUCKET/$TEST_FOLDER" "$DEST"

echo "Restore finished."
