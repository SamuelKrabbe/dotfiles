#!/usr/bin/env bash

# Go to the dotfiles directory
cd "$(dirname "$0")"

git pull origin main

# Add all changes (but respect .gitignore)
git add -A

# Check for -m option
if [[ "$1" == "-m" && -n "$2" ]]; then
    commit_message="$2"
else
    read -rp "Enter commit message: " commit_message
fi

git commit -m "$commit_message"

git push origin main

echo "Dotfiles updated successfully!"
