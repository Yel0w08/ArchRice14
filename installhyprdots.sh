#!/usr/bin/env bash
set -euo pipefail

clear
echo "=== Installing Hyprland ==="
sudo pacman -S --noconfirm hyprland xorg-xwayland sddm
sudo systemctl enable sddm

read -rp "Do you want to install Caelestia dotfiles? [y/N] " answerfordots

case "$answerfordots" in
    y|Y|yes|YES)
        yay -S --noconfirm caelestia-cli
        caelestia install
        ;;
    *)
        echo "Skipping Caelestia dotfiles install."
        ;;
esac
