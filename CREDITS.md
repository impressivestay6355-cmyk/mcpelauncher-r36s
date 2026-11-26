# Credits

## Original launcher

This port is built on top of
[minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest)
(GPL-3.0), which provides the core Minecraft Bedrock launcher for Linux. All
credit for the underlying launcher, the decompiled game bridge, and the
reverse-engineering work behind it goes to the mcpelauncher-linux team and
contributors. This repository only adds RK3326/R36S-specific packaging,
scripts, and menu integration.

## This port

RK3326/R36S packaging, scripts, and menu integration by **ImpressiveStay**.

## Third-party components

Bundled shared libraries used by the launcher runtime: `libc++_shared`,
`libgbm`, `libcrypto`/`libssl`, `libatomic`, `libgcc_s`, `libpthread`,
`libdl`, `libm`, `librt`. Each is redistributed under its own open-source
license.

## Fonts

- `font_minecraft.otf` — **Minecraft F2D** by “ygygfu” (Fontstruct). License: **SIL Open Font License 1.1** — see [licenses/MinecraftF2D-OFL.txt](licenses/MinecraftF2D-OFL.txt) and [licenses/MinecraftF2D-README.txt](licenses/MinecraftF2D-README.txt). Primary UI font.
- `font_crux.ttf` — **SVN-Coder's Crux** by NAL (2012). License: **Creative Commons Attribution 3.0** — see [licenses/SVNCodersCrux-CC-BY-3.0.txt](licenses/SVNCodersCrux-CC-BY-3.0.txt). Per-glyph fallback and full Vietnamese coverage.
- `font_pixel.ttf` — [Silkscreen](https://github.com/google/fonts/tree/main/ofl/silkscreen) by Jason Kottke. License: **SIL Open Font License 1.1** — see [licenses/Silkscreen-OFL.txt](licenses/Silkscreen-OFL.txt). Fallback pixel font.
- `font_body.ttf`, `font_body_bold.ttf` — [Inter](https://rsms.me/inter/) by Rasmus Andersson. License: **SIL Open Font License 1.1** — see [licenses/Inter-OFL.txt](licenses/Inter-OFL.txt). Fallback body font.
- `font_icons.ttf` — [Pixelarticons](https://pixelarticons.com/) by Gerrit Halfmann. License: **MIT** — see [licenses/Pixelarticons-MIT.txt](licenses/Pixelarticons-MIT.txt).

## Menu images

- `mcpe_launcher/menu/bg.jpg` — grayscale pixel texture supplied by the project
  owner, not a screenshot or third-party asset. It is used by the main menu,
  Extract APK and Update Port screens.
- `mcpe_launcher/menu/icon.png` — grass-block header icon supplied by the
  project owner for this port.
- `mcpe_launcher/menu/gamepad.png` — A/B/X/Y controller prompts cropped from
  the **Gamepad UI / Controller Prompts Pack** by
  [greatdocbrown](https://greatdocbrown.itch.io/gamepad-ui). License:
  **CC0 1.0** — see [licenses/GamepadUI-CC0.txt](licenses/GamepadUI-CC0.txt).
  Used for the footer button hints.

## Trademark notice

"Minecraft" is a trademark of Mojang Studios / Microsoft. This project is
not affiliated with, sponsored by, or endorsed by Mojang Studios or
Microsoft. See [LEGAL.md](LEGAL.md) for the full notice.
