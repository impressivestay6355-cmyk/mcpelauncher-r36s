#!/usr/bin/env python3
"""
Reproducible release packager for mcpelauncher-r36s.

Zips the runtime payload (mcpe_launcher/, McpeLauncher.sh)
into a release archive and writes SHA256SUMS.txt for every packaged file.

Usage:
    python3 scripts/build_release.py 1.1.0

Output:
    dist/mcpelauncher-r36s-1.1.0.zip
    dist/SHA256SUMS.txt
"""
import hashlib
import sys
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PAYLOAD_PATHS = ["mcpe_launcher", "McpeLauncher.sh"]
DIST_DIR = REPO_ROOT / "dist"


def iter_payload_files():
    for rel in PAYLOAD_PATHS:
        p = REPO_ROOT / rel
        if p.is_file():
            yield p
        elif p.is_dir():
            for f in sorted(p.rglob("*")):
                if f.is_file():
                    yield f
        else:
            print(f"warning: missing payload path {rel}", file=sys.stderr)


def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    if len(sys.argv) != 2:
        print("usage: build_release.py <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    DIST_DIR.mkdir(exist_ok=True)
    zip_path = DIST_DIR / f"mcpelauncher-r36s-{version}.zip"
    sums_path = DIST_DIR / "SHA256SUMS.txt"

    files = list(iter_payload_files())
    if not files:
        print("error: no payload files found", file=sys.stderr)
        sys.exit(1)

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf, \
            sums_path.open("w") as sums:
        for f in files:
            arcname = f.relative_to(REPO_ROOT)
            zf.write(f, arcname)
            sums.write(f"{sha256_of(f)}  {arcname.as_posix()}\n")

    print(f"built {zip_path} ({len(files)} files)")
    print(f"wrote {sums_path}")
    print("attach both to the GitHub release.")


if __name__ == "__main__":
    main()
