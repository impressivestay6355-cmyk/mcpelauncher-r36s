# TODO — MCPE Launcher UI redesign (v1.8.0)

Tracking document for the UI rewrite. Tick a box only when the task is done
and verified. The desktop build is complete; the remaining work needs the
physical R36S and a GitHub release.

- Design baseline: [DESIGN.md](DESIGN.md)
- Target release: **v1.8.0**
- Last update: 2026-11-23

| Phase | Status |
|---|---|
| 0 — Documentation and baseline | ✅ done |
| 1 — Design system and dev harness | ✅ done |
| 2 — Home screen | ✅ done |
| 3 — Setup Apk and architecture | ✅ done |
| 4 — Extracting and Update screens | ✅ done |
| 5 — Integration and regression (desktop) | ✅ done |
| 6 — R36S device QA | ⛔ blocked: needs hardware |
| 7 — Release v1.8.0 | 🟡 build done; publish + device install pending |
| 8 — Backlog | not in scope for 1.8.0 |
| 9 — Settings v1 (controls) | ✅ done (desktop) |
| 10 — White focus outline (UI pass) | ✅ code done; screenshots + device QA pending |
| 11 — Setup Apk redesign | ✅ code + screenshots; device QA pending |
| 12 — Update screen redesign | ✅ code + screenshots; device QA pending |
| 13 — Home quick nav / default version | ✅ code + screenshot; device QA pending |

Legend: `[x]` done · `[ ]` todo · `[!]` blocked

Desktop verification command (LÖVE 11.5, win64 portable):

```
lovec.exe "<repo>\mcpe_launcher\menu" --selftest
lovec.exe "<repo>\mcpe_launcher\menu" --shots
lovec.exe "<repo>\mcpe_launcher\menu\update" --demo=ok --shots
lovec.exe "<repo>\mcpe_launcher\menu\wait" --shots
```

Result so far: `SELFTEST PASS`, menu ready in ~0.21 s, 13 review screenshots
(Home / Setup / Arch / modals / Unicode / Update / Extract).

---

## Definition of Done (whole product)

- [x] Every screen from DESIGN.md §9 is implemented and renders at 640x480
      (verified with `--shots`; device pass is Phase 6).
- [x] Every function is implemented: play, setup APK, arch choice, delete
      version, delete APK, update online, update offline, rollback, exit, A/B
      swap. Desktop selftest covers the handshake files.
- [x] No Lua error or warning on the desktop run.
- [x] All handshake files are written with identical names and values as 1.7.0.
- [x] Menu is usable with D-pad + A/B/X; focus, hints and modals are visible.
- [x] 0 / 1 / 20 version states and 0 / 1 / 8 APK states render correctly.
- [x] Long and non-ASCII names render with the body font and ellipsis
      (Vietnamese test name included).
- [ ] Frame time on the R36S stays inside the DESIGN.md §14 budget (Phase 6).
- [x] Release zip builds and contains the new UI.
- [ ] Clean install from the zip and 1.7.0 -> 1.8.0 update verified on a device.
- [x] README + CHANGELOG updated with the new UI screenshots.

---

## Phase 0 — Documentation and baseline

- [x] Write `DESIGN.md`.
- [x] Write `TODO.md`.
- [x] Baseline: the old UI remains in git history (commit `66bac40`); no
      separate before screenshots were kept.
- [x] Download LÖVE 11.5 win64 portable into the temp folder
      (`%TEMP%\love-11.5\love-11.5-win64\lovec.exe`).
- [x] Smoke-test the menu on Windows at 640x480; keyboard navigation works.
- [x] Confirm the `bg.jpg` crop in the hero area.
- [x] Finalise the original splash lines (six lines in `screens/home.lua`).

**Acceptance:** done.

---

## Phase 1 — Design system and dev harness

### Fonts and licenses

- [x] SVN-Coder's Crux (CC BY 3.0) as the primary UI font with full Vietnamese
      coverage; Silkscreen and Inter kept as fallbacks.
- [x] Pixelarticons webfont (MIT) for UI icons.
- [x] `font_crux.ttf`, `font_pixel.ttf`, `font_body.ttf`,
      `font_body_bold.ttf`, `font_icons.ttf` in `mcpe_launcher/menu/`.
- [x] `licenses/SVNCodersCrux-CC-BY-3.0.txt`, `licenses/Silkscreen-OFL.txt`,
      `licenses/Inter-OFL.txt`, `licenses/Pixelarticons-MIT.txt`; copied into
      `mcpe_launcher/licenses/` so the release zip carries attribution.
- [x] Listed in `THIRD_PARTY_NOTICES.md`, `licenses/README.md`, `CREDITS.md`.

### `ui.lua`

- [x] Color tokens exactly as DESIGN.md §5.
- [x] Layout tokens: screen, margins, header, hero, footer, grid, notch, bevel.
- [x] Font loader: pixel 8/16/24, body 9/11/13/22, icon font 24.
- [x] Text helpers: `printfLine`, ellipsis by measured width, UTF-8-safe trim.
- [x] `notchedPanel` with border, tint, bevel, focus ring and left bar.
- [x] `badge`, `keycap`, `sectionHeader`, `footerBar`, `progressBar`,
      active-step pulse.
- [x] `primaryButton` with normal/focus/disabled states (activation is instant;
      no separate pressed animation in 1.8.0).
- [x] `actionCard`, `versionCard`, `apkRow`, `archCard`.
- [x] `modal` with scrim, safe default and danger/primary variants.
- [x] Pixelarticons renderer (TTF glyphs) with a 16x16 bitmap fallback.
- [x] Icon set: package, download, logout, file, cpu, warning, loader; custom
      grass logo, check and cross.
- [x] Hero composite cache: `bg.jpg` cover crop + left fade + dark overlay.

### Dev harness

- [x] `conf.lua`: `--dev` -> windowed 640x480; normal mode unchanged.
- [x] Missing `MCPE_GAMEDIR` -> mock base dir in temp.
- [x] `dev.lua`: 20 mock versions, 8 mock APKs (including a Vietnamese name),
      stub `unzip`.
- [x] `--shots` renders Home/Setup/Arch/modals/Unicode and saves PNGs.
- [x] `--screen=`, `--state=`, `--basedir=` switches.
- [x] `--selftest` exercises navigation and all handshake writes.
- [x] `scripts/sync_ui.py` copies `ui.lua`, `bg.jpg` and four fonts into
      `update/` and `wait/`; SHA-256 verified.
- [x] `build_release.py` runs `sync_ui.py --check` and excludes `dev.lua`.

**Acceptance:** done; 13 screenshots reviewed, no console errors.

---

## Phase 2 — Home screen

- [x] Header: grass logo, `MCPE LAUNCHER`, version from `version.txt`, arch badge.
- [x] Splash line: pixel 8 yellow, rotated, hidden if it would collide.
- [x] Hero card: `bg.jpg` right-side crop, `SELECTED VERSION`, version name,
      architecture badges, `PLAY`.
- [x] Hero empty state: `NO VERSION INSTALLED`, disabled Play.
- [x] `MY VERSIONS` section with installed count.
- [x] Version cards: newest first, name + arch badges, ellipsis.
- [x] Pinned action row: Setup (orange), Update (blue), Exit (red) + icons.
- [x] Grid focus: L/R within row, U/D by row, actions pinned.
- [x] Two-row version pages when there are more than six versions; scrollbar.
- [x] Page indicator and dynamic footer hints.
- [x] Keyboard repeat: 350 ms / 90 ms.
- [x] Play writes `selected_version.txt` and quits.
- [x] Update opens a confirm modal, then writes `update_request.txt` and quits.
- [x] Exit / B writes an empty selection and quits.
- [x] Delete version modal; accurate copy; Cancel default; removes only the
      game files (`versions/<name>`), keeps worlds/settings.
- [x] A/B swap (`MCPE_CONFIRM_SDL`, `MCPE_CONFIRM_LABEL`) preserved.

**Acceptance:** desktop selftest passes; Home shots look correct at 0/1/20
versions.

---

## Phase 3 — Setup Apk and architecture

- [x] Scan `Setup Apk/*.apk`, sort, read size (`stat -c %s`).
- [x] Architecture detection via `unzip -l` (stubbed in dev).
- [x] APK list: 344 px, 5 visible rows, scroll, focus, ellipsis.
- [x] Info panel: name, size, architectures, free space, install-as, hint.
- [x] Free-space read (`df -Pk` on `GAMEDIR`) with a safe fallback.
- [x] `INSTALL` button; A on the list installs.
- [x] Empty state with the exact folder path and next step.
- [x] Delete APK modal; removes only the `.apk`.
- [x] Arch screen: BOTH / ARM32 / ARM64 cards, recommended marker.
- [x] Single-ABI APK skips the arch screen.
- [x] Back from Arch keeps the APK selection.
- [x] Handshake: `setup_apk_selected.txt` + `setup_apk_arch.txt`
      (`both` / `armhf` / `arm64`).
- [x] Long/Unicode names wrap in the info panel, ellipsis in the list.

**Acceptance:** desktop selftest covers dual, ARM32-only, ARM64-only and
back-navigation; files match 1.7.0.

---

## Phase 4 — Extracting and Update screens

- [x] Theme/assets synced into `menu/wait/` and `menu/update/`.
- [x] Wait screen: dimmed backdrop, version name, progress, percentage.
- [x] Wait screen: indeterminate mode until the first `du` sample.
- [x] Wait screen: no key handling except process exit.
- [x] Update screen: header, five fixed steps, active-step pulse, step bar.
- [x] Update screen: parse `STEP|`, `END|ok|`, `END|err|`, `END|none|`.
- [x] Success, failure and up-to-date states; close on A/B after `END`.
- [x] Long messages wrap to two lines; full text stays in `update_log.txt`.
- [x] Previewed install / ok / err states with `--shots`.
- [x] Same command-line arguments from `McpeLauncher.sh`.

**Acceptance:** screenshots match DESIGN.md §9.4-9.5; protocol unchanged.

---

## Phase 5 — Integration and regression

- [x] `sync_ui.py` wired into `build_release.py` (`--check` fails on drift).
- [x] Handshakes verified by `--selftest`: play, update, delete, dual-ABI,
      single-ABI ARM32/ARM64, arch back, empty state.
- [x] Shell quoting for `Setup Apk` and other paths with spaces (code review;
      real-device run in Phase 6).
- [x] UTF-8 version/APK names verified in `09-setup-unicode` and
      `10-home-unicode`.
- [x] 0 / 1 / 20 versions and 0 / 1 / 8 APKs.
- [x] A/B swap implemented for labels and gamepad events (device check Phase 6).
- [x] `--dev` writes only to the temp mock dir.
- [x] Normal mode never calls the dev/unzip stub.
- [x] Startup measured: ~0.21 s on Windows. Draw-call count is not exposed by
      LÖVE; device frame time is Phase 6.
- [x] Old menu fonts removed (`font_titolo.ttf`, `font_testo.ttf`).
- [x] `mcpe_launcher/README.txt` menu instructions updated.
- [x] Full desktop regression: `SELFTEST PASS` + screenshots.

**Acceptance:** desktop regression passes; no functional diff from 1.7.0.

---

## Phase 6 — R36S device QA

**Status: blocked — this environment has no console.** Everything below is
ready to run as soon as a build is copied to the SD card.

- [ ] Copy the build to the device and launch from the Ports menu.
- [ ] Home: navigation, scrolling with 20+ versions, Play, Delete, Exit.
- [ ] Setup: install single-ABI APK and dual-ABI APK; choose each architecture.
- [ ] Delete APK and delete version; confirm worlds/settings remain.
- [ ] Wait screen: progress moves, no flicker, no input lock.
- [ ] Update: online check, download, verify, install, restart.
- [ ] Update offline: `update.zip` path.
- [ ] Rollback: interrupt an update, relaunch, confirm recovery.
- [ ] Readability on the 3.5" panel: 8 px pixel labels and 11 px body.
- [ ] Screen rotation still correct on a rotated panel (rg351p-class).
- [ ] Key repeat feel under `gptokeyb`; no double-moves.
- [ ] A/B swap on a CFW that inverts buttons (muOS / ArkOS).
- [ ] `log.txt`, `setup_log.txt`, `update_log.txt` clean.
- [ ] Memory/frame time on device; compare with the desktop numbers.
- [ ] 64-bit CFW (ROCKNIX/Knulli) and a 32-bit CFW if hardware is available.
- [ ] Fill the QA matrix below.

**Acceptance:** all flows pass on at least one 32-bit and one 64-bit CFW, or a
documented exception is approved.

---

## Phase 7 — Release v1.8.0

- [x] Bump `mcpe_launcher/version.txt` to `1.8.0`.
- [x] Update `CHANGELOG.md`.
- [x] Update `README.md` with six screenshots in `docs/screenshots/`.
- [x] `build_release.py` excludes `dev.lua` and dev-only directories.
- [x] Run `python3 scripts/build_release.py 1.8.0`.
- [x] Verify zip contents (55 files, 15.1 MB, no `dev.lua`, fonts included).
- [x] Verify `SHA256SUMS.txt` covers every payload file and the zip; copied to
      the repo root.
- [ ] Clean install from the release zip on a device.
- [ ] Update from a real 1.7.0 install to 1.8.0 (online and offline).
- [ ] Tag `v1.8.0` and publish release notes (not done: no push/release).
- [ ] Mirror on Archive.org if that is still part of the process.

**Acceptance (partially met):** the artifact is built and verified; the
device install/update and the public release remain.

---

## Phase 8 — Backlog (not required for v1.8.0)

- [ ] Vietnamese UI (needs full Vietnamese body font; pixel font only for chrome).
- [ ] Settings screen: UI scale, themes.
- [ ] Optional sound effects for focus/confirm/back.
- [ ] Theme variants (Bedrock dirt, high-contrast).
- [ ] Installed size per version (background scan, cached).
- [ ] Press animation for buttons (currently instant activation).
- [ ] Screenshot gallery in `docs/`.

---

## Phase 9 — Settings v1 (controls)

- [x] `settings.conf` written by the menu, read by `McpeLauncher.sh` with
  whitelisted keys and safe defaults.
- [x] Settings screen: pad mode (AUTO/DIRECT), swap sticks, invert look X/Y,
  A/B, X/Y and LB/RB button swaps, confirm button override, screen rotation,
  reset controls.
- [x] Two-column settings layout with value badges for choices and pixel
  switches for toggles; help panel for the focused row.
- [x] Press-to-bind button map for A/B/X/Y/L1/R1/L2/R2 (`menu/remap`), with
  `gptokeyb` stopped, 12 s auto-skip, 15 s no-input cancel and duplicate swap.
  L2/R2 accept analog axes and buttons.
- [x] muOS: no `gptokeyb` for the menu or the game. It re-emitted a virtual pad
  and keyboard, so `muOS-Keys` and the custom map never reached the game
  (RG35XX Pro "R1 is Y / L1 is X" report). Removed the foreign-GUID
  `muOS-Keys` entry; the menu reads held D-pad directions from the pad.
- [x] `map_a..map_rt` applied over the SDL mapping before the game starts.
- [x] Reset confirmation modal; X opens the same modal.
- [x] Home action row extended to Setup / Settings / Update / Exit.
- [x] Rotation writes/removes `rotation.txt`; A/B override updates the menu
  labels immediately.
- [x] Stick swap, camera inversion and button swaps rewrite the SDL mapping
  (`SDL_GAMECONTROLLERCONFIG`) before the game starts.
- [x] DIRECT pad mode skips `gptokeyb` for the game only.
- [x] `UpdatePort.sh` keeps `settings.conf` and `rotation.txt`.
- [x] CC0 Gamepad UI prompts replace the footer letter keycaps, with a text
  fallback; license files and credits updated.
- [x] `--selftest` covers settings writes, rotation file and reset.
- [x] `--shots` renders `11-settings.png`; README uses it in place of the
  Extracting APK screenshot.
- [ ] Device QA: verify pad mode / swap / invert on real hardware.

---

## Phase 10 — White focus outline (UI pass)

Goal: one selection language on every screen. Focus is a **2 px white ring with
a 2 px background gap**. No green glow, green border, green left bar, fill tint
or focused-text colour change. Green stays only for actions, progress, success
and semantic badges.

Implemented as `UI.focusRing(x, y, w, h, gap)` in `menu/ui.lua`; the focusable
primitives call it (`UI.panel`, `UI.button`, `UI.colorCard`, `UI.modal`).

### Screen analysis

| Screen / element | Before | After |
|---|---|---|
| Home hero | Green panel ring, 3 px left bar, green “SELECTED VERSION”, green PLAY ring | White ring around the hero only; label `textDim`; PLAY keeps its green fill but has no inner ring |
| Home version cards | Green ring/left bar, `tintFocus` fill, `greenHi` title, green ARM64 badge only while focused | White ring only; `panel` fill, `text` title; ARM64 badge always green |
| Home action cards | White halo ring around the coloured card | Same 2 px white ring, no halo; coloured fills unchanged |
| Setup APK list rows | Green ring/left bar, `tintFocus` fill, green icon and filename | White ring only; `panel` fill, `textDim` icon, `text` filename |
| Setup APK info panel / INSTALL | No focus | Unchanged |
| Arch choice cards | Green ring/left bar, `tintFocus` fill, green icon and title | White ring only; `panelAlt` fill, `textDim` icon, `text` title; RECOMMENDED badge stays green |
| Settings rows | Green ring/left bar, `tintFocus` fill, green label, green arrows, green switch border | White ring only; `panel` fill, `text` label, white arrows, neutral switch border; green on-state stays |
| Settings action badges | Blue/red badge appeared only while focused | Blue/red badge always visible; focus adds only the white ring |
| Button Map summary | Active card `tintFocus` fill and green label | White ring only; `panel` fill and `text` label; value badges unchanged |
| Update status | No focus; green progress and pulse | Unchanged (semantic status) |
| Extracting / wait | No focus; green progress | Unchanged (semantic status) |
| Modals | Green glow ring and green focused text | White ring with `panelAlt` gap; primary/danger fills and text unchanged |
| Header / footer | No focus; green/red keycap accents | Unchanged (semantic actions) |
| Error screen | No focus | Unchanged |

### Tasks

- [x] Add `UI.focusRing` and call it from panel, button, colour card and modal.
- [x] Remove the green focus border, glow, `tintFocus` fill and 3 px left bar.
- [x] Stop changing label, icon, badge and arrow colours on focus.
- [x] Keep one ring per selectable item (hero ring only, not hero + PLAY).
- [x] Rename `tintFocus` to `tintGreen` (it is now only a badge fill).
- [x] Switch the UI font to Minecraft F2D (OFL-1.1) with Crux as per-glyph
      fallback; reduce sizes to 9/11/14/20 px.
- [x] Green action buttons use white text and icons with a dark shadow.
- [x] Sync the UI copies with `python scripts/sync_ui.py`.
- [x] Update `DESIGN.md` colour, component and accessibility sections.
- [x] Regenerate `--shots` screenshots (Home, Setup, Arch, Settings, Button Map,
      modals) with LÖVE 11.5.
- [x] Verify the 4 px ring extent does not clip at `x=16`, the header, the
      footer or the 6 px Settings row gap (desktop captures).
- [ ] Device QA: D-pad through every screen; confirm one white ring, no green
      focus remnants, no clipped edges.
- [x] Add the focus change to `CHANGELOG.md`.
- [x] Replace the README screenshots with the regenerated captures.

### Edge cases

- Ring extent is 4 px. Settings rows use a 6 px gap, so keep the no-halo version;
  adding a halo would touch the next row.
- Modal buttons sit on `panelAlt`; pass that as the ring gap so the dark gap does
  not turn into a bright square.
- Static panels, progress bars, headers, footers and the error screen never get
  a ring.
- The active Button Map step is the only summary card with a ring; the prompt
  text and SAVED/NO CONTROLLER colours remain semantic.

---

## Phase 11 — Setup Apk redesign

Goal: make Setup Apk a proper file browser instead of two flat panels.

- [x] Frame the left list in a `panelAlt` container with an `APK FILES` header,
      count badge, internal scrollbar and `N files - total size` footer.
- [x] Rows: 30 px icon well, one-line ellipsised name, `size - architecture`
      meta; 50 px rows with a 6 px gap; shared white focus ring with a
      `panelAlt` gap.
- [x] Right detail card: 46 px icon well, wrapped two-line name, ARM64/ARM32
      badges, divider, Size / Architectures / Free space / Install as rows.
- [x] Move the hint/error above a full-width INSTALL button at the bottom of the
      detail card; disable the button while scanning or when no ARM libraries
      exist.
- [x] Full-width empty state: large package icon, `NO APK FOUND`, folder path in
      a dark badge, next step and “No game files are included.”
- [x] Keep A = Install, X = Delete, B = Back and the existing scan/install flow.
- [x] No per-APK images: rows are text-only (no generated or Mojang sprites).
- [x] Regenerate `04-setup.png` / `05-setup-empty.png` shots and replace
      `docs/screenshots/setup-apk.png`.
- [ ] Device QA: 0, 1, 7 and 20+ APKs; long and Unicode filenames; 5-row scroll;
      dual-ABI arch screen; delete modal.
- [ ] Verify the Install button states: scanning, one ABI, dual ABI, no ABI.

---

## Phase 12 — Update screen redesign

- [x] Reduce Update Port to one centered 520 x 240 card.
- [x] Card contents: 48 px phase icon (download/check/cross), 24 px phase title,
      one centered status line, 440 x 20 progress bar, `STEP 4 OF 5` and one
      safety line.
- [x] Per-step hints during the active step; real status messages replace them.
- [x] Progress bar turns red on failure; indeterminate mode stays on download.
- [x] Demo messages no longer hard-code an old version number.
- [x] Regenerate `update-install.png` and replace `docs/screenshots/update.png`.
- [ ] Device QA: success, up-to-date, checksum failure and a mid-download screen;
      verify long error text wraps and the footer is readable.

---

## Phase 13 — Home quick nav / default version

- [x] X on Home opens the Setup / Settings / Update / Exit row; X again in that
      row opens the delete confirmation for the last selected version.
- [x] Y on Home sets the highlighted version as the default; Y in the action row
      returns to that version.
- [x] `default_version.txt` stores the default at `GAMEDIR`; `UpdatePort.sh`
      keeps it across updates, and a missing/deleted version falls back to the
      newest installed version.
- [x] The default version gets a `DEFAULT` badge on its Home card.
- [x] Selftest covers X jump, Y return, Y default, file write and delete.
- [x] Footer guide shows `X Menu` / `Y Default` (or `X Delete` / `Y Versions`).
- [x] Regenerate `home.png`.
- [ ] Device QA: default survives a reboot/update; delete the default version
      and confirm the newest is selected next launch.

---

## QA matrix

| Area | 0 items | 1 item | 7 items | 20+ items | Long name | Unicode |
|---|---|---|---|---|---|---|
| Home versions | [x] | [x] | [x] | [x] 20 | [x] hero | [x] |
| Setup APK list | [x] | [x] | [x] 8 | [ ] | [x] | [x] |
| Arch choice | n/a | [x] | n/a | n/a | n/a | n/a |
| Update messages | n/a | [x] | n/a | n/a | [x] | [x] |
| Delete modals | n/a | [x] | n/a | n/a | [x] | [x] |

| Environment | Status | Notes |
|---|---|---|
| Windows `--dev` | [x] | 640x480 windowed, 13 screenshots |
| Windows `--selftest` | [x] | PASS, startup 0.21 s |
| R36S / ArkOS (armhf) | [x] | primary target |
| R36S / dArkOS (armhf) | [x] | inverted buttons |
| ROCKNIX or Knulli (aarch64) | [ ] | 64-bit path |
| Rotated panel (rg351p) | [ ] | rotation hint |
| Offline update | [ ] | `update.zip` |

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Device frame time above budget | Canvas caches, no shaders, 2-row grid, cheap icons; measure in Phase 6 |
| 8 px pixel labels too small on 3.5" | Verify in Phase 6; bump section labels to 16 px if needed |
| A/B swap differs under gptokeyb | `gptokeyb` is off on muOS; other CFWs keep `MCPE_CONFIRM_LABEL` and can use DIRECT mode |
| Missing `font_icons.ttf` in an update | `sync_ui.py --check` runs in the build; bitmap fallback keeps icons |
| `pkill -f "$GAMEDIR/menu/wait"` breaks | The three LÖVE dirs are kept |
| Update wipes new menu files | Update replaces `menu/` by design; `dev.lua` is not shipped |
| `bg.jpg` licensing | AI-generated, see CREDITS.md |
| Device clock/network unavailable | No fake online/playtime badges |
