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

mkdir -p "$GAMEDIR/Setup Apk"

export MCPE_GAMEDIR="$GAMEDIR"
source $controlfolder/runtimes/love_11.5/love.txt

MCVER=""
while true; do
  VER_COUNT=$(ls "$GAMEDIR/versions/" 2>/dev/null | wc -l)
  APK_COUNT=$(ls "$GAMEDIR/Setup Apk"/*.apk 2>/dev/null | wc -l)
  if [ "$VER_COUNT" -eq 0 ] && [ "$APK_COUNT" -eq 0 ]; then exit 1; fi

  rm -f "$GAMEDIR/menu/selected_version.txt" "$GAMEDIR/menu/setup_apk_selected.txt"

  $GPTOKEYB "love.${DEVICE_ARCH}" &
  SDL_AUDIODRIVER=dummy $LOVE_RUN "$GAMEDIR/menu"
  $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null

  APKSEL=$(cat "$GAMEDIR/menu/setup_apk_selected.txt" 2>/dev/null)
  if [ -n "$APKSEL" ]; then
    bash "$GAMEDIR/SetupMcpe.sh" "$GAMEDIR/Setup Apk/$APKSEL"
    continue
  fi

  MCVER=$(cat "$GAMEDIR/menu/selected_version.txt" 2>/dev/null)
  break
done

if [ -z "$MCVER" ]; then exit 0; fi

export XDG_DATA_HOME="$GAMEDIR/mcpelauncher"
$ESUDO mkdir -p "$GAMEDIR/mcpelauncher/mcpelauncher/games/com.mojang"
$ESUDO chmod -R 777 "$GAMEDIR/mcpelauncher"

IS_DARKOS=0
if [ "$CFW_NAME" = "DARKOS" ] || [ -e /sys/block/mmcblk0 ]; then
  IS_DARKOS=1
fi

sync
echo 3 | $ESUDO tee /proc/sys/vm/drop_caches > /dev/null
echo 10 | $ESUDO tee /proc/sys/vm/swappiness > /dev/null 2>&1 || true
$ESUDO renice -10 $$ > /dev/null 2>&1 || true

if [ "$IS_DARKOS" -eq 1 ]; then
  $ESUDO systemctl stop oga_events || true
  $ESUDO pkill -f plymouth || true
  [ -e /sys/block/mmcblk0/queue/scheduler ] && echo deadline | $ESUDO tee /sys/block/mmcblk0/queue/scheduler > /dev/null 2>&1 || true
  [ -e /sys/block/mmcblk0/queue/scheduler ] && echo mq-deadline | $ESUDO tee /sys/block/mmcblk0/queue/scheduler > /dev/null 2>&1 || true
fi

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
if [ "$IS_DARKOS" -eq 1 ]; then
  export SDL_VIDEODRIVER=kmsdrm
  export SDL_VIDEO_KMSDRM_CARD_INDEX=0
  export XDG_RUNTIME_DIR=/tmp/kmsdrm_runtime
  $ESUDO mkdir -p /tmp/kmsdrm_runtime
  $ESUDO chmod 700 /tmp/kmsdrm_runtime
  $ESUDO chmod 666 /dev/dri/card0 /dev/dri/renderD128 /dev/tty0 /dev/tty1 2>/dev/null
else
  export SDL_VIDEODRIVER=wayland
  SWAY_MODE=0
  pidof sway >/dev/null 2>&1 && SWAY_MODE=1
fi

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
if [ "$IS_DARKOS" -eq 1 ]; then
  $ESUDO bash -c "rm -rf /root/.local/share/mcpelauncher && mkdir -p /root/.local/share && ln -sfn '$GAMEDIR/mcpelauncher/mcpelauncher' /root/.local/share/mcpelauncher && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 '$BIN_PATH' -dg '$GAMEDIR/versions/$MCVER'"
else
  LOCAL_HOME="$GAMEDIR/home"
  mkdir -p "$LOCAL_HOME/.local/share"
  rm -rf "$LOCAL_HOME/.local/share/mcpelauncher"
  ln -sfn "$GAMEDIR/mcpelauncher/mcpelauncher" "$LOCAL_HOME/.local/share/mcpelauncher"

  RES_ARGS=""
  if [ "$SWAY_MODE" -eq 1 ] && command -v swaymsg >/dev/null 2>&1; then
    OUT_JSON="$(swaymsg -t get_outputs 2>/dev/null)"
    DETECTED_W="$(printf '%s' "$OUT_JSON" | grep -m1 '"width":' | grep -Eo '[0-9]+')"
    DETECTED_H="$(printf '%s' "$OUT_JSON" | grep -m1 '"height":' | grep -Eo '[0-9]+')"
    if [ -n "$DETECTED_W" ] && [ -n "$DETECTED_H" ]; then
      RES_ARGS="-ww $DETECTED_W -wh $DETECTED_H"
    fi
  fi

  FOCUS_WATCH_PID=""
  if [ "$SWAY_MODE" -eq 1 ] && command -v swaymsg >/dev/null 2>&1; then
    swaymsg 'for_window [app_id="mcpelauncher-client"] fullscreen enable, border none' >/dev/null 2>&1
    (
      attempts=0
      while [ "$attempts" -lt 300 ]; do
        if swaymsg -t get_tree -r 2>/dev/null | grep -q '"app_id"[[:space:]]*:[[:space:]]*"mcpelauncher-client"'; then
          swaymsg '[app_id="mcpelauncher-client"] focus, fullscreen enable, border none' >/dev/null 2>&1
          break
        fi
        attempts=$((attempts + 1))
        sleep 0.1
      done
    ) &
    FOCUS_WATCH_PID=$!
  fi

  $ESUDO env HOME="$LOCAL_HOME" "$BIN_PATH" -dg "$GAMEDIR/versions/$MCVER" $RES_ARGS

  [ -n "$FOCUS_WATCH_PID" ] && kill "$FOCUS_WATCH_PID" 2>/dev/null
fi

$ESUDO killall -9 gptokeyb 2>/dev/null
if [ "$IS_DARKOS" -eq 1 ]; then
  $ESUDO systemctl restart oga_events &
  printf "\033c" >/dev/tty0
fi
