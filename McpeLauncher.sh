#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

MCPE_SELF="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$MCPE_SELF")"
MCPE_SCRIPT_DIR="$SCRIPT_DIR"
MCPE_ORIG_XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR"
MCPE_IS_BATO=0
[ -f "/usr/share/batocera/batocera.version" ] && MCPE_IS_BATO=1
[ -f "/usr/share/knulli/knulli.version" ] && MCPE_IS_BATO=1
[ -x "/usr/bin/knulli-version" ] && MCPE_IS_BATO=1

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
elif [ "$MCPE_IS_BATO" = 1 ] && [ -d "/userdata/system/.local/share/PortMaster/" ]; then
  controlfolder="/userdata/system/.local/share/PortMaster"
elif [ -d "$SCRIPT_DIR/PortMaster" ]; then
  controlfolder="$SCRIPT_DIR/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
source "$controlfolder/device_info.txt"

mcpe_select_utf8_locale() {
  local candidate charmap
  for candidate in "${LC_ALL:-}" "${LC_CTYPE:-}" "${LANG:-}" \
                   C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8; do
    [ -n "$candidate" ] || continue
    if command -v locale >/dev/null 2>&1; then
      charmap="$(LC_ALL="$candidate" locale charmap 2>/dev/null || true)"
      case "$(printf '%s' "$charmap" | tr '[:lower:]' '[:upper:]')" in
        UTF-8|UTF8) ;;
        *) continue ;;
      esac
    else
      case "$candidate" in C.UTF-8|C.utf8) ;; *) continue ;; esac
    fi
    MCPE_LANG_RESOLVED="$candidate"
    return 0
  done
  MCPE_LANG_RESOLVED=C
}
mcpe_select_utf8_locale
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls
[ "$MCPE_IS_BATO" = 1 ] && SCRIPT_DIR="$MCPE_SCRIPT_DIR"

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
elif [ -d "/mnt/sdcard/ports/mcpe_launcher" ]; then
  GAMEDIR="/mnt/sdcard/ports/mcpe_launcher"
elif [ -d "/mnt/mmc/ports/mcpe_launcher" ]; then
  GAMEDIR="/mnt/mmc/ports/mcpe_launcher"
elif [ "$MCPE_IS_BATO" = 1 ] && [ -d "/userdata/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/userdata/roms/ports/mcpe_launcher"
elif [ "$MCPE_IS_BATO" = 1 ] && [ -n "$directory" ] && [ -d "/$directory/ports/mcpe_launcher" ]; then
  GAMEDIR="/$directory/ports/mcpe_launcher"
else
  GAMEDIR="$(cd "$(dirname "$0")" && pwd)"
fi

cd "$GAMEDIR"
LOGFILE="$GAMEDIR/log.txt"
exec > "$LOGFILE" 2>&1
set -x

mkdir -p "$GAMEDIR/Setup Apk" "$GAMEDIR/Import Skins"

mcpe_detect_confirm() {
  local style="" inv=0 okname okid guid sa sb f cfg="" inp="" line
  MCPE_CONFIRM_SDL=a
  MCPE_CONFIRM_LABEL=A
  case "$CFW_NAME" in
    [Aa][Rr][Kk]*|[Dd][Aa][Rr][Kk]*|TheRA|RetroOZ) style=fcamod ;;
    [Aa]mber*|EmuELEC|351ELEC) style=emuelec ;;
    [Rr][Oo][Cc][Kk][Nn][Ii][Xx]|JELOS|[Kk]nulli|Batocera*|REG*) style=batocera ;;
    [Mm][Uu][Oo][Ss])
      if [ "$(cat /opt/muos/config/settings/advanced/swap 2>/dev/null)" = "1" ]; then
        MCPE_CONFIRM_SDL=b
        MCPE_CONFIRM_LABEL=B
      fi
      return 0 ;;
    *) [ "$MCPE_IS_BATO" = 1 ] && style=batocera ;;
  esac
  [ -n "$style" ] || return 0
  for f in "$HOME/.emulationstation/es_settings.cfg" /home/ark/.emulationstation/es_settings.cfg /storage/.emulationstation/es_settings.cfg /storage/.config/emulationstation/es_settings.cfg /userdata/system/configs/emulationstation/es_settings.cfg; do
    [ -f "$f" ] && { cfg="$f"; break; }
  done
  [ -n "$cfg" ] && grep -q 'name="InvertButtons"[[:space:]]*value="true"' "$cfg" && inv=1
  if [ "$style" = batocera ]; then
    [ "$inv" = 1 ] && okname=a || okname=b
  else
    [ "$inv" = 1 ] && okname=b || okname=a
  fi
  [ "$okname" = b ] && MCPE_CONFIRM_LABEL=B
  if [ "$style" = batocera ]; then
    [ "$okname" = b ] && MCPE_CONFIRM_SDL=a || MCPE_CONFIRM_SDL=b
  else
    MCPE_CONFIRM_SDL=$okname
  fi
  for f in "$HOME/.emulationstation/es_input.cfg" /home/ark/.emulationstation/es_input.cfg /etc/emulationstation/es_input.cfg /storage/.emulationstation/es_input.cfg /storage/.config/emulationstation/es_input.cfg /userdata/system/configs/emulationstation/es_input.cfg; do
    [ -f "$f" ] && { inp="$f"; break; }
  done
  [ -n "$inp" ] || return 0
  while read -r guid okid; do
    [ -n "$guid" ] && [ -n "$okid" ] || continue
    line="$(printf '%s\n' "$sdl_controllerconfig" | grep -i -m1 "^$guid,")"
    [ -z "$line" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ] && line="$(grep -i -m1 "^$guid," "$SDL_GAMECONTROLLERCONFIG_FILE" 2>/dev/null)"
    [ -n "$line" ] || continue
    sa="$(printf '%s' "$line" | grep -o ',a:b[0-9]*' | head -n1 | sed 's/.*:b//')"
    sb="$(printf '%s' "$line" | grep -o ',b:b[0-9]*' | head -n1 | sed 's/.*:b//')"
    if [ "$okid" = "$sa" ]; then
      MCPE_CONFIRM_SDL=a
      return 0
    elif [ "$okid" = "$sb" ]; then
      MCPE_CONFIRM_SDL=b
      return 0
    fi
  done < <(awk -v want="$okname" '
    /<inputConfig/ { g=""; j=0; if ($0 ~ /type="joystick"/) j=1; if (match($0, /deviceGUID="[^"]*"/)) g=substr($0, RSTART+12, RLENGTH-13) }
    j && /<input / && $0 ~ ("name=\"" want "\"") && /type="button"/ { if (match($0, /id="[0-9]+"/)) print g, substr($0, RSTART+4, RLENGTH-5) }
  ' "$inp")
  return 0
}
{ set +x; } 2>/dev/null
mcpe_detect_confirm
set -x
export MCPE_CONFIRM_SDL MCPE_CONFIRM_LABEL

MCPE_SETTINGS="$GAMEDIR/settings.conf"
mcpe_setting() {
  local v
  v="$(grep -m1 "^[[:space:]]*$1[[:space:]]*=" "$MCPE_SETTINGS" 2>/dev/null | cut -d= -f2- | tr -d '\r[:space:]')"
  printf '%s' "${v:-$2}"
}

MCPE_RESTORE_LIST=""
mcpe_sys_set() {
  local cur
  [ -f "$1" ] || return 1
  cur="$(cat "$1" 2>/dev/null)"
  [ -n "$cur" ] || return 1
  [ "$cur" = "$2" ] && return 0
  echo "$2" | $ESUDO tee "$1" > /dev/null 2>&1 || return 1
  MCPE_RESTORE_LIST="$1|$cur
$MCPE_RESTORE_LIST"
  [ "$(cat "$1" 2>/dev/null)" = "$2" ]
}

mcpe_perf_apply() {
  local gov f d n m hz gpu found=0
  gov="$(mcpe_setting cpu_governor default)"
  gpu="$(mcpe_setting gpu_boost 0)"
  case "$gpu" in *[!0-9]*|"") gpu=0 ;; esac
  case "$gov" in *[!a-z0-9_]*|"") gov=default ;; esac
  if [ "$gov" != default ]; then
    for f in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor; do
      [ -f "$f" ] || continue
      found=1
      grep -qw "$gov" "${f%/*}/scaling_available_governors" 2>/dev/null && mcpe_sys_set "$f" "$gov"
    done
    if [ "$found" = 0 ]; then
      for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$f" ] || continue
        grep -qw "$gov" "${f%/*}/scaling_available_governors" 2>/dev/null && mcpe_sys_set "$f" "$gov"
      done
    fi
  fi
  for d in /sys/class/devfreq/*; do
    [ -f "$d/governor" ] || continue
    n="$(basename "$d" | tr '[:upper:]' '[:lower:]')"
    case "$n" in
      *gpu*|*mali*)
        [ "$gpu" != 0 ] || continue
        grep -qw performance "$d/available_governors" 2>/dev/null || continue
        if [ "$gpu" != 1 ]; then
          hz=""
          for f in $(cat "$d/available_frequencies" 2>/dev/null); do
            case "$f" in *[!0-9]*|"") continue ;; esac
            if [ "$f" -ge 1000000 ]; then m=$(( (f + 500000) / 1000000 )); else m=$(( (f + 500) / 1000 )); fi
            [ "$m" = "$gpu" ] && hz="$f"
          done
          [ -n "$hz" ] || continue
          m="$(cat "$d/min_freq" 2>/dev/null)"
          case "$m" in ""|*[!0-9]*) ;; *) [ "$m" -gt "$hz" ] && mcpe_sys_set "$d/min_freq" "$hz" ;; esac
          mcpe_sys_set "$d/max_freq" "$hz"
        fi
        mcpe_sys_set "$d/governor" performance
        continue ;;
      *dmc*) [ "$(mcpe_setting ram_boost 0)" = 1 ] || continue ;;
      *) continue ;;
    esac
    grep -qw performance "$d/available_governors" 2>/dev/null && mcpe_sys_set "$d/governor" performance
  done
  printf 'MCPE perf: cpu=%s gpu=%s ram=%s changed:\n%s\n' "$gov" "$gpu" "$(mcpe_setting ram_boost 0)" "$MCPE_RESTORE_LIST"
}

MCPE_ZRAM_ID=""
MCPE_ZRAM_HOT=0
MCPE_ZRAM_MOD=0
mcpe_zram_drop() {
  echo 1 | $ESUDO tee "/sys/block/zram$1/reset" > /dev/null 2>&1
  [ "$MCPE_ZRAM_HOT" = 1 ] && echo "$1" | $ESUDO tee /sys/class/zram-control/hot_remove > /dev/null 2>&1
  [ "$MCPE_ZRAM_MOD" = 1 ] && $ESUDO modprobe -r zram > /dev/null 2>&1
  MCPE_ZRAM_HOT=0
  MCPE_ZRAM_MOD=0
}

mcpe_zram_start() {
  local total n="" algo i size
  size="$(mcpe_setting zram 0)"
  case "$size" in ""|0|*[!0-9]*) return 0 ;; esac
  grep -q zram /proc/swaps 2>/dev/null && { echo "MCPE zram: already active"; return 0; }
  command -v mkswap > /dev/null 2>&1 && command -v swapon > /dev/null 2>&1 || { echo "MCPE zram: no mkswap/swapon"; return 0; }
  total="$(awk '/^MemTotal:/{print int($2/1024)}' /proc/meminfo 2>/dev/null)"
  [ -n "$total" ] && [ "$total" -gt 0 ] 2>/dev/null || return 0
  if [ "$size" = 1 ]; then size=$((total / 2)); elif [ "$size" -gt $((total * 2)) ]; then size=$((total * 2)); fi
  if [ ! -e /sys/block/zram0 ] && [ ! -e /sys/class/zram-control/hot_add ]; then
    $ESUDO modprobe zram > /dev/null 2>&1 && MCPE_ZRAM_MOD=1
  fi
  if [ -e /sys/block/zram0/disksize ] && [ "$(cat /sys/block/zram0/disksize 2>/dev/null)" = 0 ]; then
    n=0
  elif [ -e /sys/class/zram-control/hot_add ]; then
    n="$($ESUDO cat /sys/class/zram-control/hot_add 2>/dev/null)"
    [ -n "$n" ] && MCPE_ZRAM_HOT=1
  fi
  if [ -z "$n" ]; then
    echo "MCPE zram: not supported"
    [ "$MCPE_ZRAM_MOD" = 1 ] && $ESUDO modprobe -r zram > /dev/null 2>&1
    MCPE_ZRAM_MOD=0
    return 0
  fi
  for algo in lz4 lzo-rle lzo; do
    if grep -qw "$algo" "/sys/block/zram$n/comp_algorithm" 2>/dev/null; then
      echo "$algo" | $ESUDO tee "/sys/block/zram$n/comp_algorithm" > /dev/null 2>&1
      break
    fi
  done
  if ! echo $((size * 1024 * 1024)) | $ESUDO tee "/sys/block/zram$n/disksize" > /dev/null 2>&1; then
    mcpe_zram_drop "$n"
    return 0
  fi
  i=0
  while [ ! -b "/dev/zram$n" ] && [ "$i" -lt 20 ]; do sleep 0.1; i=$((i + 1)); done
  if $ESUDO mkswap "/dev/zram$n" > /dev/null 2>&1 && { $ESUDO swapon -p 100 "/dev/zram$n" > /dev/null 2>&1 || $ESUDO swapon "/dev/zram$n" > /dev/null 2>&1; }; then
    MCPE_ZRAM_ID="$n"
    echo "MCPE zram: /dev/zram$n ${size}MB"
  else
    echo "MCPE zram: swapon failed"
    mcpe_zram_drop "$n"
  fi
}

mcpe_perf_restore() {
  local line f v
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    f="${line%%|*}"
    v="${line#*|}"
    echo "$v" | $ESUDO tee "$f" > /dev/null 2>&1
  done <<< "$MCPE_RESTORE_LIST"
  MCPE_RESTORE_LIST=""
  if [ -n "$MCPE_ZRAM_ID" ]; then
    $ESUDO swapoff "/dev/zram$MCPE_ZRAM_ID" > /dev/null 2>&1 && mcpe_zram_drop "$MCPE_ZRAM_ID"
    MCPE_ZRAM_ID=""
  fi
}

mcpe_game_ab() {
  local extra=""
  [ "$(mcpe_setting game_ab normal)" = swapped ] || return 0
  if [ -n "$SDL_GAMECONTROLLERCONFIG_FILE" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ]; then
    extra="$(awk -F, 'FNR == NR { if ($0 ~ /^N: Name="/) { n = $0; sub(/^N: Name="/, "", n); sub(/"[[:space:]]*$/, "", n); want[n] = 1 } next } ($2 in want)' /proc/bus/input/devices "$SDL_GAMECONTROLLERCONFIG_FILE" 2>/dev/null)"
  fi
  SDL_GAMECONTROLLERCONFIG="$(printf '%s\n%s\n' "$extra" "$SDL_GAMECONTROLLERCONFIG" | awk -F, -v OFS=, '
    length($1) == 32 && $1 !~ /[^0-9a-fA-F]/ {
      ia = 0; ib = 0
      for (i = 3; i <= NF; i++) { if ($i ~ /^a:/) ia = i; else if ($i ~ /^b:/) ib = i }
      if (ia && ib) { va = substr($ia, 3); $ia = "a:" substr($ib, 3); $ib = "b:" va }
      print
    }')"
  export SDL_GAMECONTROLLERCONFIG
  MCPE_GAME_AB=1
  echo "MCPE game A/B swapped"
}

if [ -z "$DEVICE_ARCH" ]; then
  case "$(uname -m)" in
    aarch64|arm64) DEVICE_ARCH=aarch64 ;;
    *) DEVICE_ARCH=armhf ;;
  esac
fi
export DEVICE_ARCH

export MCPE_GAMEDIR="$GAMEDIR"
if [ "$MCPE_IS_BATO" = 1 ] && [ ! -f "$controlfolder/runtimes/love_11.5/love.txt" ]; then
  for f in "$controlfolder/libs/love_11.5/love.txt" "/userdata/system/.local/share/PortMaster/runtimes/love_11.5/love.txt" "/userdata/roms/ports/PortMaster/runtimes/love_11.5/love.txt"; do
    if [ -f "$f" ]; then source "$f"; break; fi
  done
else
  source $controlfolder/runtimes/love_11.5/love.txt
fi

ARCH_DIR="armhf"
ANDROID_ABI="armeabi-v7a"
if [ "$DEVICE_ARCH" = "aarch64" ]; then
  ARCH_DIR="arm64"
  ANDROID_ABI="arm64-v8a"
fi

if [ -f "$GAMEDIR/.update_rollback/.journal" ]; then
  MCPE_REC="$GAMEDIR/UpdatePort.sh"
  [ -f "$MCPE_REC" ] || MCPE_REC="$GAMEDIR/.update_rollback/UpdatePort.sh"
  if [ -f "$MCPE_REC" ]; then
    cp -f "$MCPE_REC" "/tmp/mcpe_recover_$$.sh"
    bash "/tmp/mcpe_recover_$$.sh" "$GAMEDIR" "$MCPE_SELF" "/tmp/mcpe_update_status.txt" --recover
    rm -f "/tmp/mcpe_recover_$$.sh" "/tmp/mcpe_update_status.txt"
    [ -f "$GAMEDIR/.update_rollback/.journal" ] || exec bash "$MCPE_SELF"
  fi
fi

MCVER=""
while true; do
  VER_COUNT=$(ls "$GAMEDIR/versions/" 2>/dev/null | wc -l)
  APK_COUNT=$(ls "$GAMEDIR/Setup Apk"/*.apk 2>/dev/null | wc -l)

  rm -f "$GAMEDIR/menu/selected_version.txt" "$GAMEDIR/menu/setup_apk_selected.txt" "$GAMEDIR/menu/setup_apk_arch.txt" "$GAMEDIR/menu/update_request.txt"

  if [ "$MCPE_IS_BATO" = 1 ]; then
    type pm_platform_helper >/dev/null 2>&1 && [ -n "$LOVE_BINARY" ] && pm_platform_helper "$LOVE_BINARY" >/dev/null 2>&1
    MCPE_LOVE_NAME="$(basename "${LOVE_BINARY:-love.${DEVICE_ARCH}}")"
    $GPTOKEYB "$MCPE_LOVE_NAME" &
  else
    $GPTOKEYB "love.${DEVICE_ARCH}" &
  fi
  SDL_AUDIODRIVER=dummy $LOVE_RUN "$GAMEDIR/menu"
  $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null

  if [ -f "$GAMEDIR/menu/update_request.txt" ]; then
    rm -f "$GAMEDIR/menu/update_request.txt"
    MCPE_ENTRY="$MCPE_SELF"
    MCPE_UPD_STATUS="/tmp/mcpe_update_status.txt"
    MCPE_UPD_TMP="/tmp/mcpe_update_$$.sh"
    rm -f "$MCPE_UPD_STATUS"
    echo "STEP|Checking for updates..." > "$MCPE_UPD_STATUS"
    cp -f "$GAMEDIR/UpdatePort.sh" "$MCPE_UPD_TMP"
    $LOVE_RUN "$GAMEDIR/menu/update" "$MCPE_UPD_STATUS" >/dev/null 2>&1 &
    MCPE_UPD_PID=$!
    bash "$MCPE_UPD_TMP" "$GAMEDIR" "$MCPE_ENTRY" "$MCPE_UPD_STATUS" 2>&1 | tee -a "$GAMEDIR/update_log.txt"
    wait "$MCPE_UPD_PID" 2>/dev/null
    rm -f "$MCPE_UPD_TMP"
    if grep -q '^END|ok|' "$MCPE_UPD_STATUS" 2>/dev/null; then
      rm -f "$MCPE_UPD_STATUS"
      exec bash "$MCPE_ENTRY"
    fi
    rm -f "$MCPE_UPD_STATUS"
    continue
  fi

  APKSEL=$(cat "$GAMEDIR/menu/setup_apk_selected.txt" 2>/dev/null)
  if [ -n "$APKSEL" ]; then
    ARCHSEL=$(cat "$GAMEDIR/menu/setup_apk_arch.txt" 2>/dev/null)
    MCPE_WAIT_DIR="$GAMEDIR/versions/$(basename "$APKSEL" .apk)"
    case "$ARCHSEL" in
      armhf) MCPE_WAIT_PAT='^(lib/armeabi-v7a/|assets/)' ;;
      arm64) MCPE_WAIT_PAT='^(lib/arm64-v8a/|assets/)' ;;
      *) MCPE_WAIT_PAT='^(lib/armeabi-v7a/|lib/arm64-v8a/|assets/)' ;;
    esac
    MCPE_WAIT_KB=$(unzip -l "$GAMEDIR/Setup Apk/$APKSEL" 2>/dev/null | awk -v p="$MCPE_WAIT_PAT" '$4 ~ p {s+=$1} END{print int(s/1024)}')
    $LOVE_RUN "$GAMEDIR/menu/wait" "$MCPE_WAIT_DIR" "${MCPE_WAIT_KB:-0}" >/dev/null 2>&1 &
    WAIT_PID=$!
    if command -v tee >/dev/null 2>&1; then
      { echo "===== $(date) APK=$APKSEL ARCH=${ARCHSEL:-auto}"; bash -x "$GAMEDIR/SetupMcpe.sh" "$GAMEDIR/Setup Apk/$APKSEL" "$ARCHSEL" 2>&1; echo "===== exit=$?"; } | tee -a "$GAMEDIR/setup_log.txt"
    else
      bash "$GAMEDIR/SetupMcpe.sh" "$GAMEDIR/Setup Apk/$APKSEL" "$ARCHSEL"
    fi
    kill "$WAIT_PID" 2>/dev/null
    $ESUDO pkill -f "$GAMEDIR/menu/wait" 2>/dev/null
    sleep 0.5
    $ESUDO pkill -9 -f "$GAMEDIR/menu/wait" 2>/dev/null
    wait "$WAIT_PID" 2>/dev/null
    continue
  fi

  MCVER=$(cat "$GAMEDIR/menu/selected_version.txt" 2>/dev/null)
  break
done

if [ -z "$MCVER" ]; then exit 0; fi

if [ "$(mcpe_setting menu_ab auto)" = swapped ]; then
  [ "$MCPE_CONFIRM_SDL" = b ] && MCPE_CONFIRM_SDL=a || MCPE_CONFIRM_SDL=b
  [ "$MCPE_CONFIRM_LABEL" = B ] && MCPE_CONFIRM_LABEL=A || MCPE_CONFIRM_LABEL=B
  export MCPE_CONFIRM_SDL MCPE_CONFIRM_LABEL
fi

VER_HAS_ARMHF=0
[ -n "$(ls -A "$GAMEDIR/versions/$MCVER/lib/armeabi-v7a" 2>/dev/null)" ] && VER_HAS_ARMHF=1
VER_HAS_ARM64=0
[ -n "$(ls -A "$GAMEDIR/versions/$MCVER/lib/arm64-v8a" 2>/dev/null)" ] && VER_HAS_ARM64=1

if [ "$ARCH_DIR" = "arm64" ] && [ "$VER_HAS_ARM64" -eq 0 ] && [ "$VER_HAS_ARMHF" -eq 1 ]; then
  ARCH_DIR="armhf"
  ANDROID_ABI="armeabi-v7a"
elif [ "$ARCH_DIR" = "armhf" ] && [ "$VER_HAS_ARMHF" -eq 0 ] && [ "$VER_HAS_ARM64" -eq 1 ]; then
  ARCH_DIR="arm64"
  ANDROID_ABI="arm64-v8a"
fi

export XDG_DATA_HOME="$GAMEDIR/mcpelauncher"
$ESUDO mkdir -p "$GAMEDIR/mcpelauncher/mcpelauncher/games/com.mojang"
$ESUDO chmod -R 777 "$GAMEDIR/mcpelauncher"

IS_DARKOS=0
case "$CFW_NAME" in
  [Dd][Aa][Rr][Kk]*) IS_DARKOS=1 ;;
esac

trap 'mcpe_perf_restore' EXIT
mcpe_zram_start

sync
echo 3 | $ESUDO tee /proc/sys/vm/drop_caches > /dev/null
if [ "$(awk 'NR>1{n++} END{print n+0}' /proc/swaps 2>/dev/null)" -gt 0 ]; then
  echo 100 | $ESUDO tee /proc/sys/vm/swappiness > /dev/null 2>&1 || true
  echo 0 | $ESUDO tee /proc/sys/vm/page-cluster > /dev/null 2>&1 || true
else
  echo 10 | $ESUDO tee /proc/sys/vm/swappiness > /dev/null 2>&1 || true
fi
$ESUDO renice -10 $$ > /dev/null 2>&1 || true

if [ "$IS_DARKOS" -eq 1 ]; then
  $ESUDO systemctl stop oga_events || true
  $ESUDO pkill -f plymouth || true
  [ -e /sys/block/mmcblk0/queue/scheduler ] && echo deadline | $ESUDO tee /sys/block/mmcblk0/queue/scheduler > /dev/null 2>&1 || true
  [ -e /sys/block/mmcblk0/queue/scheduler ] && echo mq-deadline | $ESUDO tee /sys/block/mmcblk0/queue/scheduler > /dev/null 2>&1 || true
fi

export OPENSSL_armcap=0
{ set +x; } 2>/dev/null
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
mcpe_pad_fix() {
  local extra user=""
  [ "$MCPE_IS_BATO" = 1 ] || return 0
  extra="$(awk '
    function hex32(s) { return length(s) == 32 && s !~ /[^0-9a-fA-F]/ }
    function key(g) { g = tolower(g); return substr(g, 1, 4) "0000" substr(g, 9) }
    FNR == NR {
      if ($0 ~ /^N: Name=/) { nm = $0; sub(/^N: Name="/, "", nm); sub(/"[[:space:]]*$/, "", nm) }
      if ($0 ~ /^B: KEY=/ && nm != "") {
        s = $0; sub(/^B: KEY=/, "", s)
        nw = split(s, w, " ")
        nc = 0
        for (i = nw; i >= 1; i--) {
          base = (nw - i) * 64
          L = length(w[i])
          for (q = 0; q < L; q++) {
            d = index("0123456789abcdef", tolower(substr(w[i], L - q, 1))) - 1
            for (b = 0; b < 4; b++) if (int(d / (2 ^ b)) % 2 == 1) c[++nc] = base + q * 4 + b
          }
        }
        for (i = 1; i <= nc; i++) for (j = i + 1; j <= nc; j++) if (c[j] < c[i]) { t = c[i]; c[i] = c[j]; c[j] = t }
        k = 0
        for (i = 1; i <= nc; i++) if (c[i] >= 288) pos[c[i]] = k++
        for (i = 1; i <= nc; i++) if (c[i] < 288) pos[c[i]] = k++
        for (i = 1; i <= nc; i++) { m[nm, i - 1] = pos[c[i]]; if (pos[c[i]] != i - 1) diff[nm] = 1 }
        has[nm] = 1
        nm = ""
      }
      next
    }
    {
      n = split($0, p, ",")
      if (!hex32(p[1])) next
      if ((p[2] in has) && (p[2] in diff)) {
        out = p[1]
        for (i = 2; i <= n; i++) {
          f = p[i]
          if (i > 2 && match(f, /:b[0-9]+$/)) {
            id = substr(f, RSTART + 2) + 0
            if ((p[2], id) in m) f = substr(f, 1, RSTART) "b" m[p[2], id]
          }
          out = out "," f
        }
        print out
        fixed[key(p[1])] = 1
        next
      }
      k = key(p[1])
      seen[k] = 1
      if (substr(tolower(p[1]), 5, 4) == "0000" && $0 !~ /,crc:[0-9a-fA-F]+/) plain[k] = 1
      else { nl++; line[nl] = $0; lk[nl] = k }
    }
    END {
      for (i = 1; i <= nl; i++) {
        k = lk[i]
        if ((k in plain) || (k in done) || (k in fixed)) continue
        done[k] = 1
        l = line[i]
        sub(/^[^,]*/, k, l)
        gsub(/,crc:[0-9a-fA-F]+/, "", l)
        print l
      }
    }
  ' /proc/bus/input/devices <(printf '%s\n' "$SDL_GAMECONTROLLERCONFIG") 2>/dev/null)"
  [ -f "$GAMEDIR/gamecontrollerdb.txt" ] && user="$(grep -v '^[[:space:]]*#' "$GAMEDIR/gamecontrollerdb.txt" | grep ',')"
  extra="$(printf '%s\n%s\n' "$extra" "$user" | grep ',')"
  [ -n "$extra" ] || return 0
  printf 'MCPE pad mappings added:\n%s\n' "$extra"
  export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG:+$SDL_GAMECONTROLLERCONFIG
}$extra"
}
mcpe_pad_fix
set -x
export MALLOC_CHECK_=0
export MESA_GL_VERSION_OVERRIDE=2.0
export MESA_GLES_VERSION_OVERRIDE=2.0
export LIBGL_ES=2
export vblank_mode=0
export SDL_RENDER_VSYNC=0
export MCPELAUNCHER_DATA_DIR="$GAMEDIR/mcpelauncher/mcpelauncher"
export MCPE_IMPORT_SKINS_DIR="$GAMEDIR/Import Skins"
MCPE_SCREEN_ROTATION=""
[ -f "$GAMEDIR/rotation.txt" ] && MCPE_SCREEN_ROTATION="$(head -n1 "$GAMEDIR/rotation.txt" | tr -dc '0-9')"
MCPE_SCREEN_ROTATION_HINT=""
case "$DISPLAY_ORIENTATION" in
  90) MCPE_SCREEN_ROTATION_HINT=270 ;;
  270) MCPE_SCREEN_ROTATION_HINT=90 ;;
esac
export MCPE_SCREEN_ROTATION MCPE_SCREEN_ROTATION_HINT
export SDL_VIDEO_KMSDRM_DOUBLE_BUFFER=1
export MESA_GLSL_CACHE_DISABLE=0
export MESA_GLSL_CACHE_DIR="$GAMEDIR/.mesa_cache"
mkdir -p "$GAMEDIR/.mesa_cache"
export PAN_MESA_DEBUG=noaff,deqp
export MALLOC_MMAP_THRESHOLD_=131072
export MALLOC_TRIM_THRESHOLD_=131072
export SDL_JOYSTICK_HIDAPI=0
export SDL_JOYSTICK_DEADZONE=12000
case "$CFW_NAME" in
  [Mm][Uu][Oo][Ss])
    is_ancestor=0
    p=$$
    while [ "$p" -gt 1 ]; do
      p=$(sed 's/.*) //' /proc/$p/stat 2>/dev/null | awk '{print $2}')
      [ -z "$p" ] && break
      if grep -q frontend.sh /proc/$p/cmdline 2>/dev/null; then
        is_ancestor=1
        break
      fi
    done
    [ "$is_ancestor" -eq 0 ] && pkill -f frontend.sh 2>/dev/null
    pkill -f muxlaunch 2>/dev/null
    sleep 0.3
    { set +x; } 2>/dev/null
    if grep -q 'N: Name="muOS-Keys"' /proc/bus/input/devices 2>/dev/null; then
      MUOS_KEYS_MAP="19000000010000000100000000010000,muOS-Keys,crc:a64c,a:b1,b:b0,x:b2,y:b3,leftstick:b9,rightstick:b8,leftshoulder:b10,rightshoulder:b11,lefttrigger:b4,righttrigger:b5,back:b6,start:b7,guide:b12,dpup:h0.1,dpright:h0.2,dpdown:h0.4,dpleft:h0.8,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
      export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG:+$SDL_GAMECONTROLLERCONFIG
}$MUOS_KEYS_MAP"
    fi
    set -x
    ;;
esac
{ set +x; } 2>/dev/null
MCPE_GAME_AB=0
mcpe_game_ab
set -x

case "$CFW_NAME" in
  [Dd][Aa][Rr][Kk]*|[Aa][Rr][Kk][Oo][Ss]*)
    [ -z "$SDL_VIDEODRIVER" ] && export SDL_VIDEODRIVER=kmsdrm
    ;;
  [Rr][Oo][Cc][Kk][Nn][Ii][Xx]|[Uu]nofficial[Oo][Ss])
    [ -z "$SDL_VIDEODRIVER" ] && export SDL_VIDEODRIVER=wayland
    ;;
  *)
    if [ -z "$SDL_VIDEODRIVER" ]; then
      if pidof sway >/dev/null 2>&1; then
        export SDL_VIDEODRIVER=wayland
      elif [ -e /dev/dri/card0 ] && [ -n "$(ls -A /sys/class/drm 2>/dev/null)" ]; then
        export SDL_VIDEODRIVER=kmsdrm
        MCPE_AUTO_KMSDRM=1
      elif [ -e /dev/mali ] || [ -e /dev/mali0 ] || [ -e /dev/disp ]; then
        export SDL_VIDEODRIVER=mali
      else
        export SDL_VIDEODRIVER=x11
      fi
    fi
    ;;
esac

if [ "$SDL_VIDEODRIVER" = "kmsdrm" ]; then
  export SDL_VIDEO_KMSDRM_CARD_INDEX=0
  export SDL_KMSDRM_REQUIRE_DRM_MASTER=0
  export XDG_RUNTIME_DIR=/tmp/kmsdrm_runtime
  $ESUDO mkdir -p /tmp/kmsdrm_runtime
  $ESUDO chmod 700 /tmp/kmsdrm_runtime
  $ESUDO chmod 666 /dev/dri/card0 /dev/dri/renderD128 /dev/tty0 /dev/tty1 2>/dev/null
fi
SWAY_MODE=0
if [ "$SDL_VIDEODRIVER" = "wayland" ]; then
  pidof sway >/dev/null 2>&1 && SWAY_MODE=1
fi

export LD_LIBRARY_PATH="$GAMEDIR/versions/$MCVER/lib/$ANDROID_ABI:$GAMEDIR/versions/$MCVER/lib/native/$ANDROID_ABI:$GAMEDIR/lib/$ANDROID_ABI:$GAMEDIR/lib/armhf-system:$GAMEDIR/lib/native/$ANDROID_ABI:/usr/lib/arm-linux-gnueabihf:/lib/arm-linux-gnueabihf:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu:/usr/lib32:/lib32:/usr/lib:/lib"
if [ "${MCPE_AUTO_KMSDRM:-0}" = 1 ] && [ "$ARCH_DIR" = armhf ] && [ -e /usr/lib32/libgbm.so.1 ]; then
  mkdir -p /tmp/mcpe_gbm32
  ln -sf /usr/lib32/libgbm.so.1 /tmp/mcpe_gbm32/libgbm.so.1
  export LD_LIBRARY_PATH="/tmp/mcpe_gbm32:$LD_LIBRARY_PATH"
fi

ulimit -c unlimited
export SDL_AUDIODRIVER=alsa
if [ "$MCPE_IS_BATO" = 1 ]; then
  for s in "${MCPE_ORIG_XDG_RUNTIME_DIR:-/nonexistent}/pulse/native" /var/run/pulse/native /run/pulse/native /run/user/*/pulse/native; do
    if [ -S "$s" ]; then export PULSE_SERVER="unix:$s"; export PULSE_RUNTIME_PATH="$(dirname "$s")"; break; fi
  done
  for s in "${MCPE_ORIG_XDG_RUNTIME_DIR:-/nonexistent}/pipewire-0" /var/run/pipewire-0 /run/pipewire-0 /run/pipewire/pipewire-0 /run/user/*/pipewire-0; do
    if [ -S "$s" ]; then export PIPEWIRE_RUNTIME_DIR="$(dirname "$s")"; break; fi
  done
  if [ "$ARCH_DIR" = armhf ]; then
    [ -d /usr/lib32/spa-0.2 ] && export SPA_PLUGIN_DIR=/usr/lib32/spa-0.2
    [ -d /usr/lib32/pipewire-0.3 ] && export PIPEWIRE_MODULE_DIR=/usr/lib32/pipewire-0.3
    if [ -f /usr/lib32/alsa-lib/libasound_module_pcm_pipewire.so ] && [ -f /usr/share/alsa/alsa.conf ]; then
      {
        cat /usr/share/alsa/alsa.conf
        printf 'pcm_type.!pipewire {\n  lib "/usr/lib32/alsa-lib/libasound_module_pcm_pipewire.so"\n}\n'
        [ -f /usr/lib32/alsa-lib/libasound_module_ctl_pipewire.so ] && printf 'ctl_type.!pipewire {\n  lib "/usr/lib32/alsa-lib/libasound_module_ctl_pipewire.so"\n}\n'
        printf 'pcm.!default {\n  type pipewire\n}\n'
      } > /tmp/mcpe_alsa32.conf
      export ALSA_CONFIG_PATH=/tmp/mcpe_alsa32.conf
    elif command -v pactl >/dev/null 2>&1; then
      MCPE_CARD="$(awk '/^ *[0-9]+ \[/{print $1; exit}' /proc/asound/cards 2>/dev/null)"
      MCPE_CARD="${MCPE_CARD:-0}"
      printf 'pcm.!default {\n  type plug\n  slave.pcm {\n    type hw\n    card %s\n    device 0\n  }\n}\nctl.!default {\n  type hw\n  card %s\n}\n' "$MCPE_CARD" "$MCPE_CARD" > /tmp/mcpe_alsa32.conf
      export ALSA_CONFIG_PATH=/tmp/mcpe_alsa32.conf
      pactl suspend-sink @DEFAULT_SINK@ 1 >/dev/null 2>&1 && MCPE_PA_SUSPENDED=1
      trap 'mcpe_perf_restore; [ "$MCPE_PA_SUSPENDED" = 1 ] && pactl suspend-sink @DEFAULT_SINK@ 0 >/dev/null 2>&1' EXIT
    fi
  fi
fi
BIN_PATH="$GAMEDIR/mcpelauncher/$ARCH_DIR/mcpelauncher-client"
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

printf "\033c" >"${CUR_TTY:-/dev/tty1}" 2>/dev/null
type pm_platform_helper >/dev/null 2>&1 && pm_platform_helper "$BIN_PATH"
mcpe_perf_apply
MCPE_ENV_EXTRA=()
MCPE_DK_EXTRA=""
if [ "$MCPE_GAME_AB" = 1 ]; then
  MCPE_ENV_EXTRA=("SDL_GAMECONTROLLERCONFIG=$SDL_GAMECONTROLLERCONFIG" "MCPE_GAME_AB=1")
  MCPE_DK_EXTRA="SDL_GAMECONTROLLERCONFIG='${SDL_GAMECONTROLLERCONFIG//\'/}' MCPE_GAME_AB=1 "
fi
mcpe_skin_apply() {
  local src="$1" opt dir hex w=64 h=64 cur last v sep kind tmp done=0
  hex="$(od -An -tx1 -N24 "$src" 2>/dev/null | tr -d ' \n')"
  case "$hex" in
    89504e470d0a1a0a*)
      w=$((16#${hex:32:8}))
      h=$((16#${hex:40:8}))
      if [ "$w" -lt 64 ] || [ "$w" -gt 1024 ] || [ $((w % 64)) -ne 0 ] || { [ "$h" -ne "$w" ] && [ $((h * 2)) -ne "$w" ]; }; then
        echo "MCPE skin: $w x $h not supported"
        return 0
      fi ;;
    "") ;;
    *) echo "MCPE skin: not a png"; return 0 ;;
  esac
  while IFS= read -r opt; do
    [ -f "$opt" ] || continue
    dir="${opt%/*}"
    cur="$(grep -m1 '^game_skintypefull:' "$opt" 2>/dev/null | cut -d: -f2- | tr -d '\r')"
    last="$(grep -m1 '^game_lastcustomskinnew:' "$opt" 2>/dev/null | cut -d: -f2- | tr -d '\r')"
    sep=""
    for v in "$cur" "$last"; do
      case "$v" in
        Standard.*) sep=.; break ;;
        Standard_*) sep=_; break ;;
      esac
    done
    [ -n "$sep" ] || { echo "MCPE skin: unknown format in $opt"; continue; }
    kind=Custom
    [ "$(mcpe_setting skin_arms classic)" = slim ] && [ "$w" != "$((h * 2))" ] && kind=CustomSlim
    $ESUDO cp -f "$src" "$dir/custom.png" 2>/dev/null || { echo "MCPE skin: cannot write $dir/custom.png"; continue; }
    tmp="/tmp/mcpe_options.$$"
    awk -v v="Standard$sep$kind" '
      /^game_skintypefull:/ { print "game_skintypefull:" v; a = 1; next }
      /^game_lastcustomskinnew:/ { print "game_lastcustomskinnew:" v; b = 1; next }
      { print }
      END { if (!a) print "game_skintypefull:" v; if (!b) print "game_lastcustomskinnew:" v }
    ' "$opt" > "$tmp" 2>/dev/null && [ -s "$tmp" ] && $ESUDO cp -f "$tmp" "$opt" 2>/dev/null && done=1
    rm -f "$tmp"
    echo "MCPE skin: $src -> $dir (Standard$sep$kind)"
  done <<< "$(find "$GAMEDIR/mcpelauncher/mcpelauncher" -maxdepth 6 -path '*minecraftpe/options.txt' 2>/dev/null)"
  [ "$done" = 1 ] || echo "MCPE skin: not applied (start the game once first)"
}

MCPE_SKIN_NAME="$(grep -m1 '^[[:space:]]*skin[[:space:]]*=' "$MCPE_SETTINGS" 2>/dev/null | cut -d= -f2- | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
if [ -n "$MCPE_SKIN_NAME" ] && [ "$MCPE_SKIN_NAME" != none ] && [ -f "$MCPE_IMPORT_SKINS_DIR/$MCPE_SKIN_NAME" ]; then
  MCPE_ENV_EXTRA+=("MCPE_SKIN_DEFAULT=$MCPE_SKIN_NAME")
  mcpe_skin_apply "$MCPE_IMPORT_SKINS_DIR/$MCPE_SKIN_NAME"
  case "$MCPE_SKIN_NAME" in
    *[!A-Za-z0-9\ ._+,\(\)-]*) ;;
    *) MCPE_DK_EXTRA="${MCPE_DK_EXTRA}MCPE_SKIN_DEFAULT='$MCPE_SKIN_NAME' " ;;
  esac
fi
if [ "$IS_DARKOS" -eq 1 ]; then
  $ESUDO bash -c "rm -rf /root/.local/share/mcpelauncher && mkdir -p /root/.local/share && ln -sfn '$GAMEDIR/mcpelauncher/mcpelauncher' /root/.local/share/mcpelauncher && ${MCPE_DK_EXTRA}XDG_DATA_HOME='$XDG_DATA_HOME' MCPE_IMPORT_SKINS_DIR='$MCPE_IMPORT_SKINS_DIR' MCPE_SCREEN_ROTATION='$MCPE_SCREEN_ROTATION' MCPE_SCREEN_ROTATION_HINT='$MCPE_SCREEN_ROTATION_HINT' MCPE_CONFIRM_SDL='$MCPE_CONFIRM_SDL' MCPE_CONFIRM_LABEL='$MCPE_CONFIRM_LABEL' LANG=$MCPE_LANG_RESOLVED LC_ALL=$MCPE_LANG_RESOLVED '$BIN_PATH' -dg '$GAMEDIR/versions/$MCVER'"
else
  LOCAL_HOME="$GAMEDIR/home"
  mkdir -p "$LOCAL_HOME/.local/share"
  rm -rf "$LOCAL_HOME/.local/share/mcpelauncher"
  ln -sfn "$GAMEDIR/mcpelauncher/mcpelauncher" "$LOCAL_HOME/.local/share/mcpelauncher"

  RES_ARGS=""
  DETECTED_W=""
  DETECTED_H=""
  if [ "$SWAY_MODE" -eq 1 ] && command -v swaymsg >/dev/null 2>&1; then
    OUT_JSON="$(swaymsg -t get_outputs 2>/dev/null)"
    DETECTED_W="$(printf '%s' "$OUT_JSON" | grep -m1 '"width":' | grep -Eo '[0-9]+')"
    DETECTED_H="$(printf '%s' "$OUT_JSON" | grep -m1 '"height":' | grep -Eo '[0-9]+')"
  fi
  if [ -z "$DETECTED_W" ] || [ -z "$DETECTED_H" ]; then
    case "$DISPLAY_WIDTH" in ''|*[!0-9]*) ;; *) [ "$DISPLAY_WIDTH" -gt 0 ] 2>/dev/null && DETECTED_W="$DISPLAY_WIDTH" ;; esac
    case "$DISPLAY_HEIGHT" in ''|*[!0-9]*) ;; *) [ "$DISPLAY_HEIGHT" -gt 0 ] 2>/dev/null && DETECTED_H="$DISPLAY_HEIGHT" ;; esac
  fi
  if [ -n "$DETECTED_W" ] && [ -n "$DETECTED_H" ]; then
    RES_ARGS="-ww $DETECTED_W -wh $DETECTED_H"
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

  $ESUDO env HOME="$LOCAL_HOME" XDG_DATA_HOME="$XDG_DATA_HOME" MCPE_IMPORT_SKINS_DIR="$MCPE_IMPORT_SKINS_DIR" MCPE_SCREEN_ROTATION="$MCPE_SCREEN_ROTATION" MCPE_SCREEN_ROTATION_HINT="$MCPE_SCREEN_ROTATION_HINT" MCPE_CONFIRM_SDL="$MCPE_CONFIRM_SDL" MCPE_CONFIRM_LABEL="$MCPE_CONFIRM_LABEL" "${MCPE_ENV_EXTRA[@]}" LANG=$MCPE_LANG_RESOLVED LC_ALL=$MCPE_LANG_RESOLVED "$BIN_PATH" -dg "$GAMEDIR/versions/$MCVER" $RES_ARGS

  [ -n "$FOCUS_WATCH_PID" ] && kill "$FOCUS_WATCH_PID" 2>/dev/null
  if [ "$MCPE_PA_SUSPENDED" = 1 ]; then
    pactl suspend-sink @DEFAULT_SINK@ 0 >/dev/null 2>&1
    MCPE_PA_SUSPENDED=0
  fi
fi

$ESUDO killall -9 gptokeyb 2>/dev/null
mcpe_perf_restore
if [ "$IS_DARKOS" -eq 1 ]; then
  $ESUDO systemctl restart oga_events &
  printf "\033c" >/dev/tty0
fi
case "$CFW_NAME" in
  [Mm][Uu][Oo][Ss])
    if [ "${is_ancestor:-1}" -eq 1 ]; then
      :
    elif [ -x /opt/muos/script/mux/frontend.sh ]; then
      setsid /opt/muos/script/mux/frontend.sh launcher </dev/null >/dev/null 2>&1 &
    elif command -v frontend.sh >/dev/null 2>&1; then
      setsid frontend.sh launcher </dev/null >/dev/null 2>&1 &
    fi
    ;;
esac
