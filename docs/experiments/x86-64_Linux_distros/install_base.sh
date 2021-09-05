# common logic between winlink_express_install and vara_install 
set -e

# If WINE binary is set, use it; otherwise, use "wine" from PATH
export WINE="${WINE:-`which wine`}"
# If WINETRICKS binary is set, use it; otherwise, use "winetricks" from PATH
export WINETRICKS="${WINETRICKS:-`which winetricks`}"
# If WINEPREFIX is set, use it; otherwise, use ~/.local/share/wineprefixes/winlink
# (default value matches "winetricks prefix=winlink")
export WINEPREFIX="${WINEPREFIX:-${HOME}/.local/share/wineprefixes/winlink}"
# If XDG_CACHE_HOME is set, use it; otherwise, use ~/.cache
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

export BOX86_NOBANNER=1
export WINEARCH=win32

# Check prerequisites
if ! command -v $WINE &> /dev/null ; then
    echo "wine is not installed"
    exit 1
else
    echo -e "WINE is\t\t"`which ${WINE}`"\t"`${WINE} --version`
fi
if ! command -v $WINETRICKS &> /dev/null ; then
    echo "winetricks is not installed"
    exit 1
else
    echo -e "WINETRICKS is\t"`which ${WINETRICKS}`"\t"`${WINETRICKS} --version | awk '{print $1}'`
fi
echo -e "WINEPREFIX is \t${WINEPREFIX}"

# Clear cached downloads older than a day
export DOWNLOAD_CACHE=${XDG_CACHE_HOME}/winlink
mkdir -p ${DOWNLOAD_CACHE}
find ${DOWNLOAD_CACHE} -mtime +1 -exec rm {} \;

if ! xhost >& /dev/null ; then 
  echo "No X window session, this script must be run with a GUI"
  exit 1
fi
