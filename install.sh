#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

clear
chmod +x ./*.sh
./PostDLscriptsSetup.sh

echo "Executing installApps.sh..."
./installApps.sh

read -rp "Do you want to install Hyprland? [y/N] " answer

case "$answer" in
    y|Y|yes|YES)
        ./installhyprdots.sh
        ;;
    *)
        echo "Skipping Hyprland install."
        ;;
esac
