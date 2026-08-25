# McpeLauncher-Port — for RetroHandhelds (R36S)

Unofficial native port of a Minecraft Bedrock Edition (ARM32 / armeabi-v7a) launcher for retro handhelds, built for the EmulationStation Ports menu.

Built on top of [minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest)
(GPL-3.0) — the open-source Bedrock launcher for Linux this project packages
and adapts for handheld hardware. All credit for the core launcher and
reverse-engineering work goes to that project; see [CREDITS.md](CREDITS.md).

**No game files are included.** You must supply your own legally owned
Minecraft Bedrock Edition ARM32 APK.

**Not affiliated with, sponsored by, or endorsed by Mojang Studios or
Microsoft.** "Minecraft" is a trademark of its respective owners.

## Download

- Releases: `<https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/releases/tag/1.0.0>`
- Also mirrored on Archive.org.

## Compatibility

| System | Status |
|---|---|
| DarkOS (and forks) | ✅ Supported |
| ROCKNIX (latest builds) | ✅ Supported (still in testing phase) |
| ArkOS4Clones (latest builds) | ⚠️ It might work (not tested) |
| Classic ArkOS / older ArkOS4Clones | ❌ Not supported (GLIBC 2.30 too old) |

## Requirements

- RK3326-based console (tested on R36S)
- Minecraft Bedrock Edition **ARM32** APK — not included, bring your own
- APKs work from 1.2. onwards 

## Quick start

1. Extract the release zip into `/roms/ports/`:
   - `mcpe_launcher/` folder
   - `McpeLauncher.sh`
2. Copy your Minecraft ARM32 APK(s) into `mcpe_launcher/Setup Apk/`
   (the filename becomes the version name shown in the menu).
3. Launch `McpeLauncher.sh` from the Ports section. In the menu, select
   **Setup Apk** and pick the APK to configure — repeat for as many
   versions as you want, each is set up independently. APKs can also be
   deleted from that same screen once configured.
4. Pick a version from the menu to play.

## Multiplayer

- **Local LAN**: working.
- **Xbox Live / online**: disabled on purpose, to prevent crashes from
  Xbox Live authentication attempts.

## Known issues

- On ROCKNIX, some Minecraft versions may show the screen slightly skewed/tilted.
- Version 1.17 crashes if WiFi is active — disable it before launching.
- Not every APK version has been tested yet.
- No on-screen keyboard: change username/world names by editing save files
  from a PC (`mcpe_launcher/mcpelauncher/mcpelauncher/games/com.mojang/`).

## Contributing

Bug reports and compatibility reports are welcome — see
[CONTRIBUTING.md](CONTRIBUTING.md).

## Credits

See [CREDITS.md](CREDITS.md) for the full list of upstream projects and
third-party components.

## Legal

See [LEGAL.md](LEGAL.md) for the full legal and trademark notice.

## License

GPL-3.0 — see [LICENSE](LICENSE). This port inherits the license of the
upstream launcher it's built on.



Enjoying the port? Consider supporting my work and future updates by buying me a coffee! Support here: https://ko-fi.com/Impressivestay63
