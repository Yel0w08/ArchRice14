echo "Runing Pacman -Syu"
sudo pacman -Syu
echo "Installing Brave..."
curl -fsS https://dl.brave.com/install.sh | sh

echo "Installing VLC..."
sudo pacman -S vlc

echo "Installing Git..."
sudo pacman -S git

echo "Installing Kitty..."
sudo pacman -S kitty

echo "Installing Git and base-devel..."
sudo pacman -S --needed git base-devel

echo "Installing Fastfetch..."
sudo pacman -S fastfetch

echo "Installing Tree..."
sudo pacman -S tree

echo "Installing 7zip..."
sudo pacman -S 7zip

echo "Installing Flatpak..."
sudo pacman -S flatpak

echo "Installing Pamac GTK..."
sudo pacman -S pamac-gtk

echo "Installing Flathub..."
sudo flatpak install flathub

echo "Installing Flathub..."
flatpak install flathub

echo "Installing Steam..."
flatpak install flathub com.valvesoftware.Steam

echo "Cloning yay..."
git clone https://aur.archlinux.org/yay.git

echo "Entering yay directory..."
cd yay

echo "Building yay..."
makepkg -si
