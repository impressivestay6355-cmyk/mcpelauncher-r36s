# McpeLauncher R36S — Minecraft Bedrock for retro handhelds

Native port of McpeLauncher, a Minecraft Bedrock Edition launcher, for
the R36S and other Linux retro handhelds (ArkOS, dArkOS, ROCKNIX,
AurKnix, muOS, AmberELEC, Knulli), built for the Ports menu.

Built on top of [minecraft-linux/mcpelauncher-manifest](https://github.com/minecraft-linux/mcpelauncher-manifest) (GPL-3.0) — the open-source Bedrock launcher for Linux this project packages
and adapts for handheld hardware. All credit for the core launcher and
reverse-engineering work goes to that project; see [CREDITS.md](https://github.com/impressivestay6355-cmyk/mcpelauncher-r36s/blob/main/CREDITS.md).

**No game files are included.** You must supply your own legally owned
Minecraft Bedrock Edition APK.
See [GETTING-APKS.md](GETTING-APKS.md) for how to get the APK from your own
Google Play purchase.

**Not affiliated with, sponsored by, or endorsed by Mojang Studios or
Microsoft.** "Minecraft" is a trademark of its respective owners.

**Forks and derivatives:** this project is not affiliated with any fork or
third-party build. Only use APKs you legally own.

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
| AurKnix                      | ✅ Supported  |
| muOS                         | ✅ Supported  |
| AmberELEC                    | ✅ Supported  |
| Knulli                       | ✅ Supported  |

- Both armhf (32-bit) and aarch64 (64-bit) builds included, auto-detected.
- ARM64 (arm64-v8a) APKs fully supported and tested.

## Requirements

- A console running one of the supported systems above (e.g. R36S, RG351MP,
  RG35XX Plus and similar consoles), tested on R36S
- Minecraft Bedrock Edition APK (ARM32 and/or ARM64) — not included, bring your own
- APKs work from version 0.12 onwards

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

## Known issues

- Not every APK version has been tested yet.
- Versions older than 0.12 are not supported.

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
