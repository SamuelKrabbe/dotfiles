#!usr/bin/env zsh

BUCKET="backup-test-001b"
TEST_FOLDER="test_images"
SOURCE="$HOME/Downloads/$TEST_FOLDER"

mkdir -p "$SOURCE"

# Download 100 random images
echo "Downloading images..."
for i in {1..100}; do
    curl -s -L -o "$SOURCE/img_$i.jpg" https://picsum.photos/200/300
done
echo "Downloaded $(ls -1 "$SOURCE" | wc -l) images..."

# Upload to S3
if [ -d "$SOURCE" ]; then
    echo "Uploading $TEST_FOLDER to s3://$BUCKET/$TEST_FOLDER ..."
    aws s3 sync "$SOURCE" "s3://$BUCKET/$TEST_FOLDER"
else
    echo "Folder $TEST_FOLDER not found."
fi

echo "Backup test finished."
