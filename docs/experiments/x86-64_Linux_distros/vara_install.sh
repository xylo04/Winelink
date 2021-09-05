#!/bin/bash
# prerequisites: apt install wine winetricks megatools
set -e

MYDIR="$(dirname "$(readlink -f "$0")")"
source $MYDIR/install_base.sh

if ! command -v megadl &> /dev/null ; then
    echo "megatools is not installed"
    exit
fi

# Find and download VARA installer exe's and pdh.dll (cache for possible re-install)
cd ${DOWNLOAD_CACHE}
if ! compgen -G "VARA HF*"  > /dev/null; then
  echo "Downloading VARA HF"
  VARAHFLINK1=$(curl -s https://rosmodem.wordpress.com/ | grep -oP '(?=https://mega.nz).*?(?=" target="_blank" rel="noopener noreferrer">VARA HF v)')
  megadl ${VARAHFLINK1}
fi
if ! compgen -G "VARA FM*"  > /dev/null; then
  echo "Downloading VARA FM"
  VARAFMLINK1=$(curl -s https://rosmodem.wordpress.com/ | grep -oP '(?=https://mega.nz).*?(?=" target="_blank" rel="noopener noreferrer">VARA FM v)')
  megadl ${VARAFMLINK1}
fi
if [ ! -f "nt4pdhdll.exe" ]; then
  echo "Downloading nt4pdhdll.exe"
  wget -q --no-use-server-timestamps http://download.microsoft.com/download/winntsrv40/update/5.0.2195.2668/nt4/en-us/nt4pdhdll.exe
fi

# Set up wine prefix with required components
echo "Creating WINEPREFIX and installing deps"
wineboot > /dev/null 2>&1
temp=${WINEPREFIX}/drive_c/Windows/Temp
mkdir -p ${temp}
$WINETRICKS -q vb6run pdh win7 sound=alsa > /dev/null 2>&1

# Install a particular version of pdh.dll
cd ${temp}
cp ${DOWNLOAD_CACHE}/nt4pdhdll.exe .
unzip -q nt4pdhdll.exe
mv pdh.* ${WINEPREFIX}/drive_c/windows/system32/
rm -rf ${temp}/*

# Install VARAHF and VARAFM (requires GUI)
cd ${temp}
cp ${DOWNLOAD_CACHE}/VARA*.zip ${temp}
unzip -q "VARA*.zip" 2> /dev/null
echo "Installing VARA HF"
${WINE} VARA\ setup*.exe 2> /dev/null
echo "Installing VARA FM"
${WINE} VARA\ FM\ setup*.exe 2> /dev/null
rm -rf ${temp}/*
final_hf_exe=$(find ${WINEPREFIX} -name "VARA.exe" | xargs -d "\n" readlink -f)
final_fm_exe=$(find ${WINEPREFIX} -name "VARAFM.exe" | xargs -d "\n" readlink -f)

echo
echo "Run command is"
echo -e "WINEPREFIX=\"$WINEPREFIX\" \"$WINE\" \"${final_hf_exe}\""
echo -e "WINEPREFIX=\"$WINEPREFIX\" \"$WINE\" \"${final_fm_exe}\""
