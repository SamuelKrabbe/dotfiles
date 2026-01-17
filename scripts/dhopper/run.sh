#!/usr/bin/env bash

# =========================
# User-configurable flags
# =========================
DEV_ONLY=false
INSTALL_FLATPAK=true

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --dev-only) DEV_ONLY=true ;;
    --no-flatpak) INSTALL_FLATPAK=false ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

clear

source utils.sh

if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

if [[ "$DEV_ONLY" == true ]]; then
  echo "Starting development-only setup..."
else
  echo "Starting full system setup..."
fi

echo "Updating system..."
sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
  echo "Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  if [[ ! -d "yay" ]]; then
    echo "Cloning yay repository..."
  else
    echo "yay directory already exists, removing it..."
    rm -rf yay
  fi

  git clone https://aur.archlinux.org/yay.git

  cd yay
  echo "building yay..."
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

# Install packages by category
if [[ "$DEV_ONLY" == true ]]; then
  # Only install essential development packages
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"

  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"

else
  # Install all packages
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"

  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"

  echo "Installing GUI utilities..."
  install_packages "${UTILS[@]}"

  echo "Installing file managers..."
  install_packages "${FILE_MANAGERS[@]}"

  echo "Installing audio and video packages..."
  install_packages "${AUDIO_VIDEO[@]}"

  echo "Installing screen and recording tools..."
  install_packages "${SCREEN[@]}"

  echo "Installing UX / Wayland helpers..."
  install_packages "${UX[@]}"

  echo "Installing desktop components..."
  install_packages "${DESKTOP[@]}"

  echo "Installing fonts..."
  install_packages "${FONTS[@]}"

  echo "Installing network tools..."
  install_packages "${NETWORK[@]}"

  # Enable services
  echo "Configuring services..."
  for service in "${SERVICES[@]}"; do
    if ! systemctl is-enabled "$service" &> /dev/null; then
      echo "Enabling $service..."
      sudo systemctl enable "$service"
    else
      echo "$service is already enabled"
    fi
  done

  # Some programs just run better as flatpaks (e.g. Discord, Spotify)
  echo "Installing flatpaks..."
  . install-flatpaks.sh
fi

echo "Setup complete! You may want to reboot your system."
