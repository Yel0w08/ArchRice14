cls
echo installing hyperland...
sudo pacman -S hyprland 
cls
echo installing Xorg-xwayland...
sudo pacman -S xorg-xwayland    
cls
echo installing sddm...
sudo pacman -S sddm 
cls
read -rp "Do you want to install  celestia dots ?  [y/N] " answerfordots

case "$answerfordots" in
    y|Y|yes|YES)
yay -S caelestia-cli   
caelestia install   
        ;;
    *)
esac
        ;;
esac

