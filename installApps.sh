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
    flatpak \
    curl \
    rsync \
    which \
    diffutils

echo "=== Installing shell + CLI tools ==="
sudo pacman -S --noconfirm --needed \
    zsh \
    starship \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    bat \
    eza \
    fd \
    fzf \
    ripgrep \
    zoxide \
    tldr \
    lazygit \
    gum \
    tree \
    7zip

echo "=== Installing system utilities ==="
sudo pacman -S --noconfirm --needed \
    btop \
    htop \
    inxi \
    powertop \
    acpi \
    baobab \
    gparted \
    qdirstat \
    usbutils \
    net-tools \
    nmap

echo "=== Installing terminals ==="
sudo pacman -S --noconfirm --needed \
    kitty \
    ghostty \
    alacritty \
    foot \
    konsole

echo "=== Installing media + audio ==="
sudo pacman -S --noconfirm --needed \
    vlc \
    mpv \
    ffmpegthumbs \
    cava \
    pwvucontrol \
    pamixer \
    yt-dlp

echo "=== Installing fonts ==="
sudo pacman -S --noconfirm --needed \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-jetbrains-mono-nerd \
    ttf-iosevka-nerd \
    ttf-font-awesome \
    ttf-liberation

echo "=== Installing wayland/ricing tools ==="
sudo pacman -S --noconfirm --needed \
    waybar \
    rofi \
    dunst \
    swaybg \
    swayidle \
    wlogout \
    wl-clipboard \
    hyprpicker \
    cliphist \
    bemenu \
    picom \
    feh \
    xwayland-satellite

echo "=== Installing apps ==="
sudo pacman -S --noconfirm --needed \
    libreoffice-fresh \
    thunderbird \
    blender \
    kdenlive \
    dolphin \
    nautilus \
    thunar \
    ark \
    file-roller \
    spectacle \
    kate \
    neovim \
    micro \
    gnome-text-editor \
    mousepad \
    falkon \
    epiphany \
    librewolf

echo "=== Installing gaming ==="
sudo pacman -S --noconfirm --needed \
    steam \
    mangohud \
    gamemode \
    lib32-gamemode \
    prismlauncher

echo "=== Installing yay (AUR helper) ==="
if command -v yay >/dev/null 2>&1; then
    echo "yay already installed, skipping."
else
    BUILD_DIR="$(mktemp -d)"
    trap 'rm -rf "$BUILD_DIR"' EXIT
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    ( cd "$BUILD_DIR/yay" && makepkg -si --noconfirm )
fi

echo "=== Installing AUR apps ==="
yay -S --needed --noconfirm \
    helium-browser-bin

echo "=== Adding Flathub and installing Flatpak apps ==="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --noninteractive --assumeyes flathub com.valvesoftware.Steam

echo "=== Install complete ==="
