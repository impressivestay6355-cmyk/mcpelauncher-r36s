# MCPE Launcher R36S — Minecraft Bedrock for retro handhelds

Native port of McpeLauncher, a Minecraft Bedrock Edition launcher, for the
R36S and other Linux retro handhelds (ArkOS, dArkOS, ROCKNIX, AurKnix, muOS,
AmberELEC, Knulli), built for the Ports menu.

The menu is a controller-first, pixel-art launcher: framed cards, a pinned
Setup / Update / Exit row, coloured action buttons, the Crux pixel font and
1-bit icons. No touchscreen or mouse is required.

Built on top of [minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest) (GPL-3.0) — the open-source Bedrock launcher for Linux this project packages
and adapts for handheld hardware. All credit for the core launcher and
reverse-engineering work goes to that project; see [CREDITS.md](CREDITS.md).

**No game files are included.** You must supply your own legally owned
Minecraft Bedrock Edition APK.
See [GETTING-APKS.md](GETTING-APKS.md) for how to get the APK from your own
Google Play purchase.

**Not affiliated with, sponsored by, or endorsed by Mojang Studios or
Microsoft.** "Minecraft" is a trademark of its respective owners.

**Forks and derivatives:** this project is not affiliated with any fork or
third-party build. Only use APKs you legally own.

## Get the game

Minecraft Bedrock is not included. Buy it on Google Play, then follow the
guide to extract the APK from your own purchase. This project does not host or
link to APK downloads.

[![Get your APK](https://img.shields.io/badge/Get%20your%20APK-Legal%20guide-63c93f?style=for-the-badge)](GETTING-APKS.md)
[![Minecraft on Google Play](https://img.shields.io/badge/Google%20Play-Minecraft-3f8fd8?style=for-the-badge)](https://play.google.com/store/apps/details?id=com.mojang.minecraftpe)

## Download

- Releases: [github.com/thinhphoenix/mcpelauncher-r36s/releases](https://github.com/thinhphoenix/mcpelauncher-r36s/releases)
- Also mirrored on Archive.org.

## Compatibility

| System                       | Status        |
| ----------------------------- | ------------- |
| ArkOS                        | ✅ Supported  |
| ArkOS4Clones                 | ✅ Supported  |
| dArkOS (and forks)           | ✅ Supported  |
| ROCKNIX                      | ✅ Supported  |
| AurKnix                      | ✅ Supported  |
| muOS                         | ✅ Supported  |
| AmberELEC                    | ✅ Supported  |
| Knulli                       | ✅ Supported  |

- Both armhf (32-bit) and aarch64 (64-bit) builds included, auto-detected.
- ARM64 (arm64-v8a) APKs fully supported and tested.

## Requirements

- A console running one of the supported systems above (e.g. R36S, RG351MP,
  RG35XX Plus and similar consoles), tested on R36S
- PortMaster (the launcher uses its LÖVE runtime and controller mapping)
- Minecraft Bedrock Edition APK (ARM32 and/or ARM64) — not included, bring your own
- APKs work from version 0.12 onwards, including the most recent releases

## Quick start

1. Extract the release zip into the Ports folder:
   - ArkOS / dArkOS / ROCKNIX / muOS: `/roms/ports/`
   - Knulli / Batocera: `/userdata/roms/ports/`

   You must end up with `McpeLauncher.sh` **next to** `mcpe_launcher/`, not
   inside it.
2. Place your APK(s) in `mcpe_launcher/Setup Apk/` (the filename becomes
   the version name shown in the menu).
3. Run `McpeLauncher.sh` from the Ports section, choose **SETUP APK** and
   select the APK to configure. Multiple versions can be configured
   individually without touching the others.
4. Once configured, the version appears in the main list, ready to play.

## Controls

| Input | Action |
|---|---|
| D-pad | move the focus |
| A | play / select / install / confirm |
| B | back; on Home it exits to Ports |
| X | delete a version or an APK (asks for confirmation) |

The launcher detects inverted A/B layouts on some CFWs (muOS, ArkOS and
forks). The footer always shows the real confirm/back labels.

## Screens

| Home | Setup Apk | Architecture |
|---|---|---|
| ![Home](https://raw.githubusercontent.com/thinhphoenix/mcpelauncher-r36s/main/docs/screenshots/home.png) | ![Setup Apk](https://raw.githubusercontent.com/thinhphoenix/mcpelauncher-r36s/main/docs/screenshots/setup-apk.png) | ![Select architecture](https://raw.githubusercontent.com/thinhphoenix/mcpelauncher-r36s/main/docs/screenshots/arch.png) |
| **Update Port** | **Extracting APK** | **No versions yet** |
| ![Update Port](https://raw.githubusercontent.com/thinhphoenix/mcpelauncher-r36s/main/docs/screenshots/update.png) | ![Extracting APK](https://raw.githubusercontent.com/thinhphoenix/mcpelauncher-r36s/main/docs/screenshots/extract.png) | ![Empty state](https://raw.githubusercontent.com/thinhphoenix/mcpelauncher-r36s/main/docs/screenshots/home-empty.png) |

## Import skins

1. Copy your skin `.png` files into `mcpe_launcher/Import Skins/`.
2. In the game, open the skin screen and press **Choose new skin** (or
   **Custom**).
3. Pick the skin from the list, with a preview of the selected one.
   D-pad / left stick to move, LB/RB to change page, confirm to select,
   back to cancel.

## Updating the port

Use **UPDATE PORT** in the main menu (Wi-Fi required). The port checks the
latest GitHub release, downloads it, verifies the file and installs it.

- Your game versions, worlds, settings and sign in are kept.
- If something goes wrong, the previous version is restored automatically.
- No Wi-Fi on the console? Copy the release zip to `mcpe_launcher/update.zip`
  and run **UPDATE PORT**: it will be installed offline.

## Multiplayer

- **Local LAN**: working.
- **Online servers**: working with Xbox Live sign in.
- **Xbox Live sign in**: working.

## Xbox Live sign in

The console has no web browser, so the port uses Microsoft's device code
sign in (the same method used by Minecraft on PlayStation and Switch):

1. Connect the console to the internet and press **Sign In** in the game.
2. A window shows a link (usually `microsoft.com/link`) and a code.
3. On your phone or PC, open the link, enter the code and sign in with your
   Microsoft account.
4. The game signs in by itself and stays signed in next time.

Your password is typed only on Microsoft's website, never on the console.

Servers older than 1.21 need `online-mode=false` to let you join.

On very old versions (below about 1.16) sign in doesn't work anymore.
That's normal: the sign in servers were updated and those versions can't
talk to them now. This happens with Bedrock Edition on every device.

## Developer preview (PC)

The menu is a LÖVE 11.5 game. The release zip does **not** include `dev.lua`,
so run the preview from a checkout:

```bash
# Linux
love mcpe_launcher/menu --dev

# Windows
lovec.exe "mcpe_launcher\menu" --dev
```

- `--dev` — windowed 640×480, mock versions/APKs in the system temp folder,
  no writes to the repo.
- `--shots` — render Home/Setup/Arch/Update states to PNG and exit.
- `--selftest` — exercise navigation and every handshake file, print PASS/FAIL.
- `python scripts/sync_ui.py` — copy `ui.lua`, `bg.jpg`, fonts and icon into
  `menu/update/` and `menu/wait/`; `--check` verifies they match.
- `python scripts/build_release.py 1.8.0` — build
  `dist/McpeLauncher-Port.zip` + `dist/SHA256SUMS.txt`. It checks the UI sync,
  normalises `.sh` files to LF and stores mode `0755`.

## Known issues

- Not every APK version has been tested yet.
- Versions older than 0.12 are not supported.
- If the menu does not start, check `mcpe_launcher/log.txt`,
  `mcpe_launcher/menu_error.txt` and `mcpe_boot.log` (next to
  `McpeLauncher.sh`; falls back to `/tmp/mcpe_boot.log`). Attach those files to
  the bug report.

## Features

- Pixel-art menu: Crux UI font, framed cards, coloured action buttons, 1-bit
  Pixelarticons and a custom grass-block header icon
- Pinned Setup / Update / Exit row with a controller focus ring
- Confirmation dialogs for deleting a version or an APK, and for updating the port
- On-screen virtual keyboard for text input (username, chat, world names)
- Multiple Minecraft versions installable side by side, each deletable
  from the main menu
- Over-the-air port updates from the main menu, with automatic rollback
- Skin import with an in-game picker and preview
- Support for recent Minecraft releases

## Contributing

Bug reports and compatibility reports are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
For UI work, use the developer preview above and attach a `--shots` screenshot
when reporting a visual issue.

## Credits

- Launcher binary based on [mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest)
- Virtual keyboard: thanks to [D-Antonio](https://github.com/D-Antonio)
- UI font: **SVN-Coder's Crux** by NAL, CC BY 3.0
- Icons: **Pixelarticons** by Gerrit Halfmann, MIT
- Header grass-block icon supplied by the project owner

See [CREDITS.md](CREDITS.md) for the full list of upstream projects and
third-party components.

## Legal

See [LEGAL.md](LEGAL.md) for the full legal and trademark notice.

## License

GPL-3.0 — see [LICENSE](LICENSE). This port inherits the license of the
upstream launcher it's built on.
