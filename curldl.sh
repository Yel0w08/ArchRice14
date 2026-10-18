#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Yel0w08/ArchRice14.git"
REPO_DIR="ArchRice14"

if ! command -v git >/dev/null 2>&1; then
    sudo pacman -Sy --needed --noconfirm git
fi

if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Repo already present, pulling latest..."
    git -C "$REPO_DIR" pull --ff-only
fi

cd "$REPO_DIR"
chmod +x ./*.sh
exec ./install.sh
