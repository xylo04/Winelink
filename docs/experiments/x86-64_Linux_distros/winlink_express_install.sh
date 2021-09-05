#!/bin/bash
# prerequisites: apt install wine winetricks
set -e

MYDIR="$(dirname "$(readlink -f "$0")")"
source $MYDIR/install_base.sh

# Find and download Winlink Express (cache for possible re-install)
cd ${DOWNLOAD_CACHE}
if ! compgen -G "Winlink_Express_install_*.zip"  > /dev/null; then
  echo "Downloading Winlink Installer"
  wget -qr -l1 -np -nd --no-use-server-timestamps -A "Winlink_Express_install_*.zip" https://downloads.winlink.org/User%20Programs
fi

# Set up wine prefix with required components
echo "Creating WINEPREFIX and installing deps"
wineboot > /dev/null 2>&1
temp=${WINEPREFIX}/drive_c/Windows/Temp
mkdir -p ${temp}
$WINETRICKS -q win7 > /dev/null 2>&1
$WINETRICKS -q --force dotnet48 > /dev/null 2>&1

# Install Winlink Express (requires GUI)
echo "Installing Winlink Express"
cd ${temp}
cp ${DOWNLOAD_CACHE}/Winlink_Express_install_*.zip ${temp}
unzip -q "Winlink_Express_install_*.zip"
${WINE} Winlink_Express_install.exe > /dev/null 2>&1
rm -rf ${temp}/*
final_exe=$(find ${WINEPREFIX} -name "RMS Express.exe" | xargs -d "\n" readlink -f)

echo
echo "Run command is"
echo -e "WINEPREFIX=\"$WINEPREFIX\" \"$WINE\" \"${final_exe}\""
