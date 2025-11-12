#!/usr/bin/env zsh

set -e

echo "Checking for Docker installation..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
    exit 0
fi

echo "Installing Docker Engine..."

# Remove any old versions
sudo dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine || true

# Set up the Docker repo
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker Engine and related tools
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker Engine installed successfully!"
echo "Run 'docker-init' to start and test Docker."
