curl -fsS https://dl.brave.com/install.sh | sh
sudo pacman -S vlc
sudo pacman -S git
sudo pacman -S kitty   
sudo pacman -S --needed git base-devel
sudo pacman -S fastfetch
sudo pacman -S tree
sudo pacman -S 7zip
sudo pacman -S flatpak
sudo pacman -S pamac-gtk
sudo flatpak install flathub
flatpak install flathub
flatpak install flathub com.valvesoftware.Steam


git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si   
