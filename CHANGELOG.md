# Changelog

## v1.9.1 — Button map fix

- Pass `SDL_GAMECONTROLLERCONFIG` explicitly to the game when it is launched
  through `sudo` (ArkOS, dArkOS and similar CFWs). sudo resets the environment,
  so the custom button map was silently dropped and the game kept SDL's
  built-in mapping — the R36S "I remapped but nothing changed" report.
- The button map also saves the pad's current SDL mapping and uses it when the
  firmware provides no `sdl_controllerconfig`, so the remap still works on
  stripped-down CFW builds.
- Log the final SDL mapping size to `log.txt` so a missing map is easy to spot.

## v1.9.0 — Settings

- Added a Settings screen: pad mode (Auto / Direct), swap sticks, invert the
  camera X/Y, confirm button override (Auto / A / B), A/B, X/Y and LB/RB
  button swaps, and screen rotation (Auto / 0 / 90 / 180 / 270), plus a
  confirmed reset. Toggles use a pixel switch; choices and rotation keep the
  arrow/badge control.
- Added a press-to-bind button map for A, B, X, Y, L1, R1, L2 and R2. It runs
  as a separate screen with `gptokeyb` stopped so raw pad events reach SDL;
  L2/R2 are captured as analog axes or buttons, a step is skipped after 12 s,
  and the screen cancels after 15 s without input. Duplicates swap.
- Fixed two button-map problems: LÖVE reports 1-based button/axis numbers while
  SDL mappings are 0-based, so every captured binding was one input off; and on
  muOS the built-in `muOS-Keys` mapping was added after the custom map, which
  made SDL keep the old controls. The custom map is now applied last.
- `settings.conf` is applied by `McpeLauncher.sh` before the game starts.
  Stick swap and camera inversion rewrite the SDL controller mapping, so no
  game files are modified.
- Direct pad mode skips `gptokeyb` for the game, for pads that repeat input or
  move the camera on their own.
- The home action row is now Setup / Settings / Update / Exit.
- Footer button hints now use the CC0 **Gamepad UI / Controller Prompts Pack**
  by greatdocbrown (A/B/X/Y sprites), with the text keycap kept as a fallback.
- Updating the port now keeps `settings.conf` and `rotation.txt`.

## v1.8.0 — New UI

- Redesigned the whole menu: dark Minecraft-style cards, pixel icons, a green
  accent and a pinned Setup / Update / Exit row.
- Pixel-art pass: square beveled cards, saturated teal/blue/crimson action
  buttons with a hard sunburst, white pixel labels and 1-bit icons.
- Rebuilt the version, Setup Apk and architecture screens. Long and non-ASCII
  names now render correctly and truncate with an ellipsis. Versions are listed
  newest first.
- Deleting a version or an APK, and updating the port, now ask for
  confirmation; Cancel is the default choice.
- Restyled the Extracting APK and Update Port screens. Update progress follows
  the five real steps instead of a fake percentage.
- Bundled SVN-Coder's Crux (CC BY 3.0) as the single pixel UI font, with full
  Vietnamese coverage; Silkscreen and Inter remain fallbacks.
- Added a desktop preview mode for development (`--dev`, `--shots`,
  `--selftest`). It never ships in the release zip.
- Fixed CRLF line endings in `McpeLauncher.sh`, `SetupMcpe.sh` and
  `UpdatePort.sh`, which stopped the port from starting on Linux handhelds
  (bash saw `bash\r` instead of `bash`) and prevented any log from being
  written.
- Added an on-screen error report written to `mcpe_launcher/menu_error.txt`,
  and removed a stencil path that could fail on some Mali drivers. A menu
  problem now shows a readable error instead of a black screen.
- Centred the Play/Install icon+label group, aligned caps-height text in
  buttons/badges/keycaps, and put the header icon, title, version chip, promo
  line and architecture chip on one centre line.
- Header now uses the supplied 21x21 grass-block icon at 26 px.
- No changes to the install/update file protocol: existing versions, worlds,
  skins and sign-in are kept.

## v1.7.0 — OTA Update + Import Skins

- Added Update Port: update the port from the main menu, with automatic rollback if something fails. Offline: copy the release zip as update.zip.
- Added skin import: put .png skins in Import Skins and pick them in game with a preview.
- Support for recent Minecraft versions.
- Fixed architecture detection on systems that don’t report it (some muOS builds).
- Screen fix upside down on some consoles (like the rg351p)

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
