#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ -d "$SCRIPT_DIR/versions" ] && [ -d "$SCRIPT_DIR/menu" ]; then
  GAMEDIR="$SCRIPT_DIR"
elif [ -d "/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/roms/ports/mcpe_launcher"
elif [ -d "/storage/roms/ports/mcpe_launcher" ]; then
  GAMEDIR="/storage/roms/ports/mcpe_launcher"
elif [ -d "/sdcard/ports/mcpe_launcher" ]; then
  GAMEDIR="/sdcard/ports/mcpe_launcher"
elif [ -d "/mnt/mmc/ports/mcpe_launcher" ]; then
  GAMEDIR="/mnt/mmc/ports/mcpe_launcher"
else
  GAMEDIR="$SCRIPT_DIR"
fi

APKDIR="$GAMEDIR/Setup Apk"
mkdir -p "$APKDIR"

banner() {
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
  echo " $1"
  echo "========================================="
  exec >&3
  exec 3>&-
}

if [ -n "$1" ]; then
  if [ -f "$1" ]; then
    APK="$1"
  else
    APK="$APKDIR/$1"
  fi
else
  APK=$(ls "$APKDIR"/*.apk 2>/dev/null | head -1)
  if [ -z "$APK" ]; then
    APK=$(ls "$GAMEDIR"/*.apk 2>/dev/null | head -1)
  fi
fi

banner "Extracting APK... Please wait..."

if [ -z "$APK" ] || [ ! -f "$APK" ]; then
  banner "ERROR: APK not found"
  exit 1
fi
if ! unzip -t "$APK" > /dev/null 2>&1; then
  banner "ERROR: invalid APK file"
  exit 1
fi
if ! unzip -l "$APK" | grep -q "lib/armeabi-v7a"; then
  banner "ERROR: unsupported APK (no armeabi-v7a lib)"
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
trap 'rm -rf "$TMPDIR"' EXIT

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

banner "Setup completed successfully!"
