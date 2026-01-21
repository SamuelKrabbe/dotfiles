#!/usr/bin/env bash
set -e

echo "Setting up DeepCool AG400 Digital..."

# =========================
# Config
# =========================
VERSION="v0.10.2-alpha"
BIN_NAME="deepcool-digital-linux"
DOWNLOAD_URL="https://github.com/Nortank12/deepcool-digital-linux/releases/download/${VERSION}/${BIN_NAME}"

BIN_DST="/usr/local/bin/${BIN_NAME}"
SERVICE_DST="/etc/systemd/system/${BIN_NAME}.service"

if ! command -v curl &>/dev/null; then
    echo "Command curl not found, installing..."
    sudo pacman -S --noconfirm curl
fi

# =========================
# Download binary
# =========================
echo "Downloading DeepCool binary (${VERSION})..."
curl -L "$DOWNLOAD_URL" -o "/tmp/${BIN_NAME}"

# =========================
# Install binary
# =========================
echo "Installing binary to ${BIN_DST}..."
sudo install -m 755 "/tmp/${BIN_NAME}" "$BIN_DST"
rm -f "/tmp/${BIN_NAME}"

# =========================
# Install systemd service
# =========================
echo "Installing systemd service..."
sudo tee "$SERVICE_DST" >/dev/null <<EOF
[Unit]
Description=DeepCool AG400 Digital CPU Info Display
After=multi-user.target

[Service]
Type=simple
ExecStart=${BIN_DST}
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

# =========================
# Enable service
# =========================
echo "Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable ${BIN_NAME}.service
sudo systemctl restart ${BIN_NAME}.service

echo "DeepCool AG400 setup complete."
