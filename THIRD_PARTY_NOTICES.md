# Third-party notices

## mcpelauncher

The bundled `mcpelauncher-client` binaries (armhf and arm64) are built from
[minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest),
licensed under GPL-3.0, at upstream commits manifest `91220f0` and
`mcpelauncher-client` `7890498`, **with patches applied by this port**.
The complete corresponding source (patches, added files, build scripts) is
available on request per GPL-3.0 §6(b). See [LEGAL.md](LEGAL.md).

See [CREDITS.md](CREDITS.md) for the full list of upstream projects and
components (menu UI, gamepad input, graphics libraries) bundled in
`mcpe_launcher/`.

## Statically linked libraries

The launcher binaries statically include the following open-source
components, each under its own license:

- SDL3 (zlib license) — with port patches for the Mali fbdev backend and
  GPIO gamepad detection
- Dear ImGui (MIT)
- curl (curl license, MIT-style)
- OpenSSL 1.1.1w (OpenSSL / SSLeay license)
- zlib (zlib license)
- libpng (libpng license)
- LLVM libc++ (Apache-2.0 with LLVM exception)

Full license texts are in the [licenses](licenses/) folder.

## Bundled system libraries

`mcpe_launcher/lib/armhf-system/` bundles glibc-adjacent shared libraries
(libssl, libcrypto, libatomic, libpthread, etc.) required for compatibility
with older console firmware. These are unmodified upstream builds,
distributed under their respective open-source licenses (OpenSSL/Apache-2.0,
GPL/LGPL as applicable).

If you rebuild or update any bundled binary, update the commit references
in [LEGAL.md](LEGAL.md) and this file accordingly.
