#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ -d "$SCRIPT_DIR/mcpe_launcher" ]; then
  GAMEDIR="$SCRIPT_DIR/mcpe_launcher"
elif [ -d "/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/roms/ports/mcpe_launcher"
elif [ -d "/storage/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/storage/roms/ports/mcpe_launcher"
elif [ -d "/sdcard/ports/mcpe_launcher" ]; then
  GAMEDIR="/sdcard/ports/mcpe_launcher"
elif [ -d "/mnt/mmc/ports/mcpe_launcher" ]; then
  GAMEDIR="/mnt/mmc/ports/mcpe_launcher"
else
  GAMEDIR="$(cd "$(dirname "$0")" && pwd)/mcpe_launcher"
fi

exec 3>&1
exec > /dev/tty1
clear
echo "========================================="
echo "  _    _    _     _    _____  "
echo " | |  | |  / \   (_)  |_   _| "
echo " | |  | | / _ \  | |    | |   "
echo " | |/\| |/ ___ \ | |    | |   "
echo "  \_/\_/_/   \_\_|_|    |_|   "
echo "                              "
echo " Extracting APK... Please wait..."
echo "========================================="
exec >&3
exec 3>&-

APK=$(ls "$GAMEDIR"/*.apk 2>/dev/null | head -1)
if [ -z "$APK" ]; then
  exit 1
fi
if ! unzip -t "$APK" > /dev/null 2>&1; then
  exit 1
fi
if ! unzip -l "$APK" | grep -q "lib/armeabi-v7a"; then
  exit 1
fi

MCVER=$(basename "$APK" .apk)
VERDIR="$GAMEDIR/versions/$MCVER"
if [ -d "$VERDIR" ]; then
  rm -rf "$VERDIR/lib" "$VERDIR/assets"
fi

mkdir -p \
  "$VERDIR/lib/armeabi-v7a" \
  "$VERDIR/lib/arm64-v8a"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

unzip -q "$APK" "lib/armeabi-v7a/*" -d "$TMPDIR" 2>/dev/null || true
unzip -q "$APK" "assets/*" -d "$TMPDIR" 2>/dev/null || true

if [ -d "$TMPDIR/lib/armeabi-v7a" ]; then
  cp "$TMPDIR/lib/armeabi-v7a/"*.so "$VERDIR/lib/armeabi-v7a/" 2>/dev/null || true
fi
if [ -d "$TMPDIR/assets" ]; then
  cp -r "$TMPDIR/assets" "$VERDIR/"
fi

LIBC_SRC="$GAMEDIR/mcpelauncher/lib/armeabi-v7a/libc.so"
LIBM_SRC="$GAMEDIR/mcpelauncher/lib/armeabi-v7a/libm.so"
if [ -f "$LIBM_SRC" ]; then
  cp "$LIBM_SRC" "$VERDIR/lib/armeabi-v7a/libm.so"
fi

if [ -f "$LIBC_SRC" ]; then
  cp "$LIBC_SRC" "$VERDIR/lib/armeabi-v7a/libc.so"
fi

FMOD_SRC="$VERDIR/lib/armeabi-v7a/libfmod.so"
if [ -f "$FMOD_SRC" ]; then
  cp "$FMOD_SRC" "$VERDIR/lib/armeabi-v7a/libfmod.so.12.0"
fi

exec 3>&1
exec > /dev/tty1
clear
echo "Setup completed successfully!"
exec >&3
exec 3>&-