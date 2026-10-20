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
sudo pacman -S --noconfirm --needed hyprland xorg-xwayland sddm hyprlock pyside6

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

# --- Install the riced lock screen + shell chooser + session scripts ----------
echo "=== Installing riced lock screen and shell chooser ==="
mkdir -p "$HOME/.config/hypr"
cp -f "$(dirname "$0")/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
cp -f "$(dirname "$0")/hypr/lock-session.sh" "$HOME/.config/hypr/lock-session.sh"
chmod +x "$HOME/.config/hypr/lock-session.sh"
cp -f "$(dirname "$0")/hypr/shell-chooser.py" "$HOME/.config/hypr/shell-chooser.py"
chmod +x "$HOME/.config/hypr/shell-chooser.py"

# Session entry scripts (SDDM will only show stock Hyprland; chooser handles shell pick)
mkdir -p "$HOME/hyperland-sessions"
cp -f "$(dirname "$0")/sessions/"*.sh "$HOME/"
chmod +x "$HOME"/hyperland-*.sh

# --- Install caelestia user config, noctalia settings, uwsm env, qtengine colors ---
echo "=== Installing caelestia/noctalia/uwsm/qtengine configs ==="
mkdir -p "$HOME/.config/caelestia" "$HOME/.config/uwsm" "$HOME/.config/qtengine"
mkdir -p "$HOME/.local/state/noctalia"
cp -f "$(dirname "$0")/caelestia/shell.json" "$HOME/.config/caelestia/shell.json"
cp -f "$(dirname "$0")/caelestia/hypr-user.lua" "$HOME/.config/caelestia/hypr-user.lua"
cp -f "$(dirname "$0")/caelestia/hypr-vars.lua" "$HOME/.config/caelestia/hypr-vars.lua"
cp -f "$(dirname "$0")/noctalia/settings.toml" "$HOME/.local/state/noctalia/settings.toml"
cp -f "$(dirname "$0")/uwsm/env-hyprland" "$HOME/.config/uwsm/env-hyprland"
cp -f "$(dirname "$0")/qtengine/caelestia.colors" "$HOME/.config/qtengine/caelestia.colors"
