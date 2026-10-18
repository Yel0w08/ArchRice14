#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: run as your normal user, not root; it will sudo where needed." >&2
    exit 1
fi

clear
echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing core packages ==="
sudo pacman -S --noconfirm --needed \
    git \
    base-devel \
    vlc \
    kitty \
    fastfetch \
    tree \
    7zip \
    flatpak

echo "=== Adding Flathub and installing Flatpak apps ==="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --noninteractive --assumeyes flathub com.valvesoftware.Steam

echo "=== Installing yay (AUR helper) ==="
if command -v yay >/dev/null 2>&1; then
    echo "yay already installed, skipping."
else
    BUILD_DIR="$(mktemp -d)"
    trap 'rm -rf "$BUILD_DIR"' EXIT
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    ( cd "$BUILD_DIR/yay" && makepkg -si --noconfirm )
fi

echo "=== Install complete ==="
