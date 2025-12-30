#!/usr/bin/env bash

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR="$SCRIPTS_DIR/../mediaplayer"

echo "Building Mediaplayer..."

cd "$PROJECT_DIR" || { echo "Project directory not found!"; exit 1; }

go build -o "$SCRIPTS_DIR/mediaplayer" cmd/mediaplayer/main.go

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Binary located at: $SCRIPTS_DIR/mediaplayer"
else
    echo "Build failed."
    exit 1
fi
