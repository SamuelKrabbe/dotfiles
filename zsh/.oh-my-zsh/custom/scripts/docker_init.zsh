#!/usr/bin/env zsh

set -e

INSTALL_SCRIPT="$HOME/.oh-my-zsh/custom/scripts/docker_install.zsh"

# Check if Docker exists
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker not found. Running installer..."
    if [[ -f "$INSTALL_SCRIPT" ]]; then
        zsh "$INSTALL_SCRIPT"
        exit 0
    else
        echo "Installer script not found at $INSTALL_SCRIPT"
        exit 1
    fi
fi

# Start Docker if not running
if ! systemctl is-active --quiet docker; then
    echo "Starting Docker service..."
    if sudo systemctl start docker; then
        echo "Docker service started."
    else
        echo "Failed to start Docker service."
        exit 1
    fi
else
    echo "Docker is already running."
fi

# Test Docker
echo "Testing Docker..."
if sudo docker run --rm hello-world >/dev/null 2>&1; then
    echo "Docker is working properly."
else
    echo "Docker is running, but test container failed."
    echo "Try running 'sudo docker run hello-world' manually for details."
    exit 1
fi
