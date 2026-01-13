#!/usr/bin/env bash

echo "Checking for Docker installation..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
    exit 0
fi

echo "Installing Docker Engine..."
sudo pacman -Syu

sudo pacman -S docker docker-buildx docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER

if ! systemctl is-active --quiet docker.socket; then
    echo "Starting Docker socket..."
    if sudo systemctl start docker.socket; then
        sudo systemctl enable docker.socket
        echo "Docker socket started."
    else
        echo "Failed to start Docker socket."
        exit 1
    fi
else
    echo "Docker socket is already running."
fi

echo "Testing Docker..."
if docker run --rm hello-world >/dev/null 2>&1; then
    echo "Docker is working properly."
else
    echo "Docker is running, but test container failed."
    echo "Try running 'docker run hello-world' manually for details."
    exit 1
fi

echo "Docker Engine installed successfully!"
