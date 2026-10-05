# Changelog

## v1.6.0 — Older versions support + keyboard fix

- Added 0.12+ P.E. support
- Fix virtual keyboard input for older versions (like 1.2) and newer versions (post-1.21).
- Fix black and corrupted skins on versions like 1.1.0.

## v1.5.1 — Gui fix

- Fixed the tiny GUI on 1.17 and newer,if it still looks small on devices with bigger screens, you can change it in the game settings

## v1.5.0 — Xbox Live sign in update

- Added Xbox Live sign in with a code: sign in from your phone or PC at
  `microsoft.com/link`, no browser needed on the console
- Works on ARM32 and ARM64
- The sign in is saved, no need to repeat it every time

## v1.4.1 — Added Knulli support

- Added Knulli compatibility
- Added an extraction log: `mcpe_launcher/setup_log.txt`

## v1.4.0 — Multi-CFW Update + Bug Fixes

- Added muOS compatibility
- Added AmberELEC compatibility
- Tested on AurKnix
- Fixed ARM32 crash at ~70% loading on versions 1.18+
- Added a loading bar while extracting the APK
- Fixed the menu closing when the port is opened for the first time with no versions or APKs

## v1.3.1 — Keyboard toggle fix

- SELECT now opens and closes the on-screen keyboard

## v1.3.0 — Major Update: Arm64 + more Compatibility

- Added ArkOS and ArkOS4Clones compatibility
- Added full ARM64 APK support (alongside ARM32)
- If an APK contains both architectures, you can choose which one to extract
- Added on-screen virtual keyboard (Minecraft-themed, custom font)
- Some multiplayer servers without login work
- Versions can now be deleted directly from the menu
- Fixed crash on some versions when internet connection is active (e.g. 1.17)

## v1.2.0 — Rocknix Compatibility

- Added Rocknix compatibility.

## v1.1.0 — Menu Update: Setup Apk + Delete Apk

- Added Setup Apk menu flow.
- Added ability to delete installed versions.

## v1.0.0 — Initial release

- First public release: mcpelauncher port for RK3326/R36S.
- LAN multiplayer support.
- Xbox Live force-disabled to avoid authentication-related crashes.
