#!/usr/bin/env python3
"""
Reproducible release packager for mcpelauncher-r36s.

Zips the runtime payload (mcpe_launcher/, McpeLauncher.sh)
into a release archive and writes SHA256SUMS.txt for every packaged file.

Usage:
    python3 scripts/build_release.py 1.7.0

Output:
    dist/McpeLauncher-Port.zip
    dist/SHA256SUMS.txt
"""
import hashlib
import subprocess
import sys
import time
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PAYLOAD_PATHS = [
    "mcpe_launcher",
    "McpeLauncher.sh",
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "CREDITS.md",
]
DIST_DIR = REPO_ROOT / "dist"
# Desktop-only helpers and captured output must never ship to a console.
EXCLUDE_REL = {
    Path("mcpe_launcher/menu/dev.lua"),
}
EXCLUDE_PARTS = {"__pycache__", "shots", ".git"}


def iter_payload_files():
    for rel in PAYLOAD_PATHS:
        p = REPO_ROOT / rel
        if p.is_file():
            yield p
        elif p.is_dir():
            for f in sorted(p.rglob("*")):
                if not f.is_file():
                    continue
                if f.relative_to(REPO_ROOT) in EXCLUDE_REL:
                    continue
                if any(part in EXCLUDE_PARTS for part in f.parts):
                    continue
                yield f
        else:
            print(f"warning: missing payload path {rel}", file=sys.stderr)


def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def add_file(zf: zipfile.ZipFile, path: Path, arcname: str) -> str:
    """Write one payload file with Unix permissions and LF text files."""
    data = path.read_bytes()
    mode = 0o644
    if path.suffix in {".sh", ".lua", ".txt", ".md", ".py", ".json", ".yml", ".yaml"} \
            or path.name == "LICENSE":
        data = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    if path.suffix == ".sh":
        mode = 0o755
    info = zipfile.ZipInfo(arcname, date_time=time.localtime(path.stat().st_mtime)[:6])
    info.create_system = 3  # Unix, so unzip honours the mode
    info.external_attr = (mode | 0o100000) << 16
    info.compress_type = zipfile.ZIP_DEFLATED
    zf.writestr(info, data)
    return hashlib.sha256(data).hexdigest()


def main():
    if len(sys.argv) != 2:
        print("usage: build_release.py <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    sync = REPO_ROOT / "scripts" / "sync_ui.py"
    if sync.is_file():
        subprocess.run([sys.executable, str(sync), "--check"], check=True)
    DIST_DIR.mkdir(exist_ok=True)
    zip_path = DIST_DIR / "McpeLauncher-Port.zip"
    (REPO_ROOT / "mcpe_launcher" / "version.txt").write_bytes((version + "\n").encode("utf-8"))
    sums_path = DIST_DIR / "SHA256SUMS.txt"

    files = list(iter_payload_files())
    if not files:
        print("error: no payload files found", file=sys.stderr)
        sys.exit(1)

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf, \
            sums_path.open("w", newline="\n") as sums:
        for f in files:
            arcname = f.relative_to(REPO_ROOT).as_posix()
            digest = add_file(zf, f, arcname)
            sums.write(f"{digest}  {arcname}\n")
    with sums_path.open("a", newline="\n") as sums:
        sums.write(f"{sha256_of(zip_path)}  {zip_path.name}\n")

    print(f"built {zip_path} ({len(files)} files)")
    print(f"wrote {sums_path}")
    print("attach both to the GitHub release.")


if __name__ == "__main__":
    main()
