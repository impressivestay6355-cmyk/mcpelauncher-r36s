#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
elif [ -d "$SCRIPT_DIR/PortMaster" ]; then
  controlfolder="$SCRIPT_DIR/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
source "$controlfolder/device_info.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

if [ -d "$SCRIPT_DIR/mcpe_launcher" ]; then
  GAMEDIR="$SCRIPT_DIR/mcpe_launcher"
elif [ -d "/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/roms/ports/mcpe_launcher"
elif [ -d "/roms2/ports/mcpe_launcher" ]; then
  GAMEDIR="/roms2/ports/mcpe_launcher"
elif [ -d "/storage/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/storage/roms/ports/mcpe_launcher"
elif [ -d "/storage/roms2/ports/mcpe_launcher" ]; then
  GAMEDIR="/storage/roms2/ports/mcpe_launcher"
elif [ -d "/sdcard/ports/mcpe_launcher" ]; then
  GAMEDIR="/sdcard/ports/mcpe_launcher"
elif [ -d "/mnt/mmc/ports/mcpe_launcher" ]; then
  GAMEDIR="/mnt/mmc/ports/mcpe_launcher"
else
  GAMEDIR="$(cd "$(dirname "$0")" && pwd)"
fi

cd "$GAMEDIR"
LOGFILE="$GAMEDIR/log.txt"
exec > "$LOGFILE" 2>&1
set -x

VERSIONS=($(ls "$GAMEDIR/versions/" 2>/dev/null | sort -V))
if [ ${#VERSIONS[@]} -eq 0 ]; then exit 1; fi

rm -f "$GAMEDIR/menu/selected_version.txt"

export MCPE_GAMEDIR="$GAMEDIR"

source $controlfolder/runtimes/love_11.5/love.txt
$GPTOKEYB "love.${DEVICE_ARCH}" &
SDL_AUDIODRIVER=dummy $LOVE_RUN "$GAMEDIR/menu"
$ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null

MCVER=$(cat "$GAMEDIR/menu/selected_version.txt" 2>/dev/null)
if [ -z "$MCVER" ]; then exit 0; fi

export XDG_DATA_HOME="$GAMEDIR/mcpelauncher"
$ESUDO mkdir -p "$GAMEDIR/mcpelauncher/mcpelauncher/games/com.mojang"
$ESUDO chmod -R 777 "$GAMEDIR/mcpelauncher"

$ESUDO systemctl stop oga_events || true
$ESUDO pkill -f plymouth || true

sync
echo 3 | $ESUDO tee /proc/sys/vm/drop_caches > /dev/null
echo 10 | $ESUDO tee /proc/sys/vm/swappiness > /dev/null 2>&1 || true
echo deadline | $ESUDO tee /sys/block/mmcblk0/queue/scheduler > /dev/null 2>&1 || true
echo mq-deadline | $ESUDO tee /sys/block/mmcblk0/queue/scheduler > /dev/null 2>&1 || true
$ESUDO renice -10 $$ > /dev/null 2>&1 || true

export OPENSSL_armcap=0
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export MALLOC_CHECK_=0
export MESA_GL_VERSION_OVERRIDE=2.0
export MESA_GLES_VERSION_OVERRIDE=2.0
export LIBGL_ES=2
export vblank_mode=0
export SDL_RENDER_VSYNC=0
export MCPELAUNCHER_DATA_DIR="$GAMEDIR/mcpelauncher/mcpelauncher"
export SDL_VIDEO_KMSDRM_DOUBLE_BUFFER=1
export MESA_GLSL_CACHE_DISABLE=0
export MESA_GLSL_CACHE_DIR="$GAMEDIR/.mesa_cache"
mkdir -p "$GAMEDIR/.mesa_cache"
export PAN_MESA_DEBUG=noaff,deqp
export MALLOC_MMAP_THRESHOLD_=131072
export MALLOC_TRIM_THRESHOLD_=131072
export SDL_JOYSTICK_HIDAPI=0
export SDL_JOYSTICK_DEADZONE=12000
export SDL_VIDEODRIVER=kmsdrm
export SDL_VIDEO_KMSDRM_CARD_INDEX=0
export XDG_RUNTIME_DIR=/tmp/kmsdrm_runtime

$ESUDO mkdir -p /tmp/kmsdrm_runtime
$ESUDO chmod 700 /tmp/kmsdrm_runtime
$ESUDO chmod 666 /dev/dri/card0 /dev/dri/renderD128 /dev/tty0 /dev/tty1 2>/dev/null

export LD_LIBRARY_PATH="$GAMEDIR/versions/$MCVER/lib/armeabi-v7a:$GAMEDIR/versions/$MCVER/lib/native/armeabi-v7a:$GAMEDIR/lib/armeabi-v7a:$GAMEDIR/lib/armhf-system:$GAMEDIR/lib/native/armeabi-v7a:/usr/lib/arm-linux-gnueabihf:/lib/arm-linux-gnueabihf:/usr/lib32:/lib32:/usr/lib:/lib"

ulimit -c unlimited
export SDL_AUDIODRIVER=alsa
BIN_PATH="$GAMEDIR/mcpelauncher/mcpelauncher-client"
$ESUDO chmod +x "$BIN_PATH"

$ESUDO killall -9 gptokeyb 2>/dev/null
sleep 0.2

if [ -f "$GAMEDIR/mcpelauncher.gptk" ]; then
  $GPTOKEYB "mcpelauncher-client" -c "$GAMEDIR/mcpelauncher.gptk" &
elif [ -f "$GAMEDIR/mcpelauncher-client.gptk" ]; then
  $GPTOKEYB "mcpelauncher-client" -c "$GAMEDIR/mcpelauncher-client.gptk" &
else
  $GPTOKEYB "mcpelauncher-client" &
fi

printf "\033c" >/dev/tty1
$ESUDO bash -c "rm -rf /root/.local/share/mcpelauncher && mkdir -p /root/.local/share && ln -sfn '$GAMEDIR/mcpelauncher/mcpelauncher' /root/.local/share/mcpelauncher && '$BIN_PATH' -dg '$GAMEDIR/versions/$MCVER'"

$ESUDO killall -9 gptokeyb 2>/dev/null
$ESUDO systemctl restart oga_events &
printf "\033c" >/dev/tty0