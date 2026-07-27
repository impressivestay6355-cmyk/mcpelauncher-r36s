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

- `font_titolo.ttf` — "Minecraft Evenings" by Allison James / Chequered Ink (2013). License: **Public Domain**, "free for all use" per the designer — see [FontSpace listing](https://www.fontspace.com/minecraft-evenings-font-f17735). (The copyright string embedded in the font file itself still reads "All Rights Reserved"; that is outdated relative to the current published license.)
- `font_testo.ttf` — "Minecraft" font family, listed on [FontSpace](https://www.fontspace.com/minecraft-font-f28180) as designed by JDGraphics (2017), License: **Public Domain**. The copy bundled here carries internal metadata naming "CraftronGaming" instead — a common redistribution mismatch for this font, not a different, more restrictive font.

Both are used under their published Public Domain / free-for-all-use terms.
If either designer disputes this, open an issue and the font will be
removed promptly.

## Menu background

`bg.jpg` — AI-generated image (ChatGPT), not a screenshot or third-party
asset.

## Trademark notice

"Minecraft" is a trademark of Mojang Studios / Microsoft. This project is
not affiliated with, sponsored by, or endorsed by Mojang Studios or
Microsoft. See [LEGAL.md](LEGAL.md) for the full notice.
