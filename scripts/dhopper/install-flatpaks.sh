FLATPAKS=(
  discord
  # spotify
  # google-chrome
)

# Check if flatpak is installed
if ! command -v flatpak &> /dev/null; then
  echo "Flatpak not found."

  if [[ "$INSTALL_FLATPAK" == true ]]; then
    echo "Installing Flatpak..."
    sudo pacman -S --needed flatpak
  else
    echo "Skipping Flatpak installation."
    return 0 2>/dev/null || exit 0
  fi
fi

# Ensure Flathub exists
if ! flatpak remote-list | grep -q flathub; then
  echo "Adding Flathub remote..."
  flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Flatpaks
for pak in "${FLATPAKS[@]}"; do
  if ! flatpak list | grep -qi "$pak"; then
    echo "Installing Flatpak: $pak"
    flatpak install -y flathub "$pak"
  else
    echo "Flatpak already installed: $pak"
  fi
done
