# Third-party notices

## mcpelauncher

The bundled `mcpelauncher-client` binary and its supporting libraries are
unmodified upstream code from
[minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest),
licensed under GPL-3.0. No patches are applied by this port. Build metadata
embedded in the binary references upstream commits `4b88525` and `c535dc1`;
corresponding source is available at those commits, satisfying GPL-3.0 §6.

See [CREDITS.md](CREDITS.md) for the full list of upstream projects and
components (menu UI, gamepad input, graphics libraries) bundled in
`mcpe_launcher/`.

## Bundled system libraries

`mcpe_launcher/lib/armhf-system/` bundles glibc-adjacent shared libraries
(libssl, libcrypto, libatomic, libpthread, etc.) required for compatibility
with older console firmware. These are unmodified upstream builds,
distributed under their respective open-source licenses (OpenSSL/Apache-2.0,
GPL/LGPL as applicable).

If you rebuild or update any bundled binary, update the commit references
in [LEGAL.md](LEGAL.md) accordingly.
