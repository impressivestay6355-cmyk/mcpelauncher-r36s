# McpeLauncher-Port — RK3326 (R36S)

Native port of a Minecraft Bedrock Edition launcher for RK3326-based
retro handhelds, built for the EmulationStation Ports menu.

Built on top of [minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest) (GPL-3.0) — the open-source Bedrock launcher for Linux this project packages
and adapts for handheld hardware. All credit for the core launcher and
reverse-engineering work goes to that project; see [CREDITS.md](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/blob/main/CREDITS.md).

**No game files are included.** You must supply your own legally owned
Minecraft Bedrock Edition APK.

**Not affiliated with, sponsored by, or endorsed by Mojang Studios or
Microsoft.** "Minecraft" is a trademark of its respective owners.

## Download

- Releases: [github.com/impressivestay6355-cmyk/mcpelauncher-r36s/releases](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/releases)
- Also mirrored on Archive.org.

## Compatibility

| System                       | Status        |
| ----------------------------- | ------------- |
| ArkOS                        | ✅ Supported  |
| ArkOS4Clones                 | ✅ Supported  |
| DarkOS (and forks)           | ✅ Supported  |
| Rocknix                      | ✅ Supported  |

- Both armhf (32-bit) and aarch64 (64-bit) builds included, auto-detected.
- ARM64 (arm64-v8a) APKs fully supported and tested.

## Requirements

- RK3326-based console (tested on R36S)
- Minecraft Bedrock Edition APK (ARM32 and/or ARM64) — not included, bring your own
- APKs work from version 1.2 onwards

## Quick start

1. Extract the release zip into `/roms/ports/`:
   - `mcpe_launcher/` folder
   - `McpeLauncher.sh`
2. Place your APK(s) in `mcpe_launcher/Setup Apk/` (the filename becomes
   the version name shown in the menu).
3. Run `McpeLauncher.sh` from the Ports section, choose **Setup Apk** and
   select the apk to configure. Multiple versions can be configured
   individually without touching the others.
4. Once configured, the version appears in the main list, ready to play.

## Multiplayer

- **Local LAN**: working.
- **Servers that don't require Microsoft login**: may work.
- **Xbox Live access**: not available.

## Known issues

- Not every APK version has been tested yet.

## Features

- On-screen virtual keyboard for text input (username, chat, world names)
- Multiple Minecraft versions installable side by side, each deletable
  from the main menu

## Contributing

Bug reports and compatibility reports are welcome — see [CONTRIBUTING.md](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/blob/main/CONTRIBUTING.md).

## Credits

- Launcher binary based on [mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest)
- Virtual keyboard: thanks to [D-Antonio](https://github.com/D-Antonio)

See [CREDITS.md](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/blob/main/CREDITS.md) for the full list of upstream projects and
third-party components.

## Legal

See [LEGAL.md](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/blob/main/LEGAL.md) for the full legal and trademark notice.

## License

GPL-3.0 — see [LICENSE](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/blob/main/LICENSE). This port inherits the license of the
upstream launcher it's built on.
