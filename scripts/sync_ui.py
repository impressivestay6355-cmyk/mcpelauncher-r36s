#!/usr/bin/env python3
"""Keep the design system identical in the three LÖVE game directories.

`menu/update` and `menu/wait` are separate LÖVE games (the bash launcher runs
them as separate processes), so they need their own copies of ui.lua and the
shared assets. This script copies them and verifies SHA-256.

Usage:
    python3 scripts/sync_ui.py          # copy and verify
    python3 scripts/sync_ui.py --check  # verify only, exit 1 on drift
"""
import hashlib
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MENU = ROOT / "mcpe_launcher" / "menu"
TARGETS = [MENU / "update", MENU / "wait", MENU / "remap"]
PAYLOAD = [
    "ui.lua",
    "gamepad.png",
    "bg.jpg",
    "icon.png",
    "font_pixel.ttf",
    "font_body.ttf",
    "font_body_bold.ttf",
    "font_crux.ttf",
    "font_minecraft.otf",
    "font_icons.ttf",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    check_only = "--check" in sys.argv[1:]
    missing = [name for name in PAYLOAD if not (MENU / name).is_file()]
    if missing:
        print("missing in menu/: " + ", ".join(missing), file=sys.stderr)
        return 1

    drift = []
    for target in TARGETS:
        target.mkdir(parents=True, exist_ok=True)
        for name in PAYLOAD:
            src = MENU / name
            dst = target / name
            if check_only:
                if not dst.is_file() or sha256(src) != sha256(dst):
                    drift.append(f"{dst.relative_to(ROOT)}")
            else:
                shutil.copy2(src, dst)
                if sha256(src) != sha256(dst):
                    drift.append(f"{dst.relative_to(ROOT)}")

    if drift:
        print("ui drift: " + ", ".join(drift), file=sys.stderr)
        return 1
    print("ui in sync: " + ", ".join(p.name for p in TARGETS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
