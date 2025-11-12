#!/usr/bin/env bash

# Go to the dotfiles directory
cd "$(dirname "$0")"

git pull origin main

# Add all changes (but respect .gitignore)
git add -A

if [ -z "$1" ]; then
    read -rp "Enter commit message: " commit_message
else
    commit_message="$1"
fi

git commit -m "$commit_message"

git push origin main

echo "Dotfiles updated successfully!"
