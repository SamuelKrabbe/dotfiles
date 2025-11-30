#!/usr/bin/env bash

# -------------------------------------------------
# Git commit script for dotfiles with enforced tags
# -------------------------------------------------

cd "$(dirname "$0")" || exit

# Function to show help
show_help() {
    echo "Usage: update-dotfiles -m \"<tag>: <message>\""
    echo ""
    echo "Commit message must start with one of the following tags followed by a message:"
    echo "  feat:      New feature"
    echo "  docs:      Documentation"
    echo "  style:     Code style or formatting"
    echo "  refactor:  Code refactoring"
    echo "  perf:      Performance improvement"
    echo "  test:      Adding or fixing tests"
    echo "  chore:     Maintenance tasks"
    echo ""
    echo "Examples:"
    echo "  update-dotfiles -m \"feat: add new Alacritty theme\""
    echo "  update-dotfiles          # will prompt for message interactively"
}

# Check if user asked for help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Pull latest changes
git pull origin main

# Add all changes (respect .gitignore)
git add -A

# Extract commit message
if [[ "$1" == "-m" && -n "$2" ]]; then
    commit_message="$2"
else
    read -rp "Enter commit message (tag: message): " commit_message
fi

# Validate commit message
# Must start with one of the allowed tags AND have at least one non-space character after ":"
if [[ ! "$commit_message" =~ ^(feat|docs|style|refactor|perf|test|chore):[[:space:]]*[^[:space:]]+ ]]; then
    echo "Error: Commit message must start with a valid tag and contain a non-empty message."
    show_help
    exit 1
fi

# Commit and push
git commit -m "$commit_message"
git push origin main

echo "Dotfiles updated successfully!"
