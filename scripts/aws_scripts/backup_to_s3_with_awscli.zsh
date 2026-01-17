
#!/usr/bin/env zsh

BUCKET="my-backup-2025-002b"

# Main personal folders
FOLDERS=(
    "Documents"
    "Pictures"
    "Videos"
    "Desktop"
    "Music"
    "dev"
    "docker-stuff"
    "git-stuff"
)

# Selected .config subfolders
CONFIG_FOLDERS=(
    "alacritty"
    "kitty"
    "nvim"
    "systemd"
)

# Individual files
FILES=(
    ".bashrc"
    ".zshrc"
    ".local/bin/memento-Dei"
    ".oci"
    ".aws"
    ".ssh"
    "installed-packages.txt"
    ".oh-my-zsh/custom"
)

# Upload main folders
for f in $FOLDERS; do
    if [ -d "$HOME/$f" ]; then
        echo "Uploading $f to s3://$BUCKET/$f ..."
        aws s3 sync "$HOME/$f" "s3://$BUCKET/$f"
    else
        echo "Folder $f not found, skipping."
    fi
done

# Upload selected .config folders
for cf in $CONFIG_FOLDERS; do
    if [ -d "$HOME/.config/$cf" ]; then
        echo "Uploading .config/$cf to s3://$BUCKET/.config/$cf ..."
        aws s3 sync "$HOME/.config/$cf" "s3://$BUCKET/.config/$cf"
    else
        echo "Config folder $cf not found, skipping."
    fi
done

# Upload individual files
for file in $FILES; do
    if [ -f "$file" ]; then
        echo "Uploading $file to s3://$BUCKET/ ..."
        aws s3 sync "$HOME/$file" "s3://$BUCKET/$file"
    else
        echo "File $file not found, skipping."
    fi
done

echo "Backup finished."

