#!/usr/bin/env bash
set -euo pipefail

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

echo "=== Installing Brave ==="
curl -fsS https://dl.brave.com/install.sh | sh

echo "=== Adding Flathub and installing Flatpak apps ==="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --noninteractive --assumeyes flathub com.valvesoftware.Steam

echo "=== Installing yay (AUR helper) ==="
if ! command -v yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
else
    echo "yay already installed, skipping."
fi

echo "=== Install complete ==="
