#!/usr/bin/env bash
set -euo pipefail

clear
if [ -d ArchRice14 ]; then
    echo "ArchRice14 already exists, pulling latest..."
    cd ArchRice14
    git pull
else
    git clone https://github.com/Yel0w08/ArchRice14.git
    cd ArchRice14
fi

echo "Setting up the install scripts..."
chmod +x PostDLscriptsSetup.sh
./PostDLscriptsSetup.sh

echo "Executing install.sh"
./install.sh
