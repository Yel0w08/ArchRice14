#!/usr/bin/env bash
set -euo pipefail

clear

enable_service() {
    local svc="$1"
    if command -v rc-update >/dev/null 2>&1; then
        rc-update add "$svc" default
    elif command -v systemctl >/dev/null 2>&1; then
        systemctl enable "$svc"
    else
        echo "ERROR: no rc-update or systemctl found, cannot enable '$svc'." >&2
        return 1
    fi
}

echo "=== Installing Hyprland ==="
sudo pacman -S --noconfirm --needed hyprland xorg-xwayland sddm

if command -v rc-update >/dev/null 2>&1 && rc-update show 2>/dev/null | grep -qE '(^|[[:space:]])sddm([[:space:]]|$)'; then
    echo "SDDM already enabled, skipping."
elif command -v systemctl >/dev/null 2>&1 && systemctl is-enabled --quiet sddm 2>/dev/null; then
    echo "SDDM already enabled, skipping."
else
    enable_service sddm
fi

read -rp "Do you want to install Caelestia dotfiles? [y/N] " answerfordots

case "$answerfordots" in
    y|Y|yes|YES)
        if [ "$(id -u)" -eq 0 ]; then
            echo "ERROR: run as your normal user, not root, so makepkg works." >&2
            exit 1
        fi
        yay -S --needed --noconfirm caelestia-cli
        caelestia install
        ;;
    *)
        echo "Skipping Caelestia dotfiles install."
        ;;
esac
