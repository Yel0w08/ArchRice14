echo runing PostDLscriptsSetup.sh..
chmod +x PostDLscriptsSetup.sh
./PostDLscriptsSetup.sh
echo executing installApps.sh...
./installApps.sh

read -rp "Do you want to install  hyperland ? [y/N] " answer

case "$answer" in
    y|Y|yes|YES)
./installhyprdots.sh
        ;;
    *)
esac
        ;;
esac