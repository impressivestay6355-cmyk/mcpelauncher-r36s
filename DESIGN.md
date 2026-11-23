# Design — MCPE Launcher UI (v1.8.0)

Status: **agreed baseline** (2026-11-22)
Scope: LÖVE menu UI (`mcpe_launcher/menu/`), plus the extraction and update
screens (`menu/wait/`, `menu/update/`). The in-game HUD and virtual keyboard
live inside the `mcpelauncher-client` binary and are **out of scope**.

This document is the single source of truth for the redesign. If code and
this file disagree, this file wins until it is updated on purpose.

---

## 1. Goals

1. Look like a modern Minecraft launcher, not a generic file list.
2. Stay readable on a 3.5" 640x480 panel at arm's length.
3. Be fully operable with a D-pad and four face buttons.
4. Keep every existing behaviour and file handshake intact.
5. Stay cheap enough for an RK3326: no shaders, no blur, no per-frame I/O.

## 2. Hard constraints

| Constraint | Value |
|---|---|
| Resolution | 640x480, 4:3, fullscreen (windowed only in dev) |
| Input | D-pad, A (confirm), B (back), X (delete); no touch, no mouse |
| Runtime | LÖVE 11.5, LuaJIT, OpenGL ES 2.0 class GPU |
| Hardware | RK3326 / Cortex-A35, 1 GB RAM class |
| Fonts | OFL only. **Never** ship Mojang's Minecraft font |
| Assets | `menu/bg.jpg` (already in repo) + procedural pixel icons |
| Handshake | `selected_version.txt`, `setup_apk_selected.txt`, `setup_apk_arch.txt`, `update_request.txt`, `version.txt`, `default_version.txt` |
| Process layout | 3 LÖVE game dirs (`menu`, `menu/wait`, `menu/update`) — bash `pkill -f "$GAMEDIR/menu/wait"` depends on it |

## 3. Design principles

- **Console first.** Every action reachable with D-pad + A/B/X. Footer hints
  are always visible.
- **Chrome vs. data.** Pixel font is used only for static English UI chrome.
  All user data (version names, APK filenames, paths, messages) uses the body
  font so any Unicode (Vietnamese, Cyrillic, CJK) renders.
- **One strong accent.** Green means "go / selected". Blue, orange, yellow and
  red are reserved for specific actions and never used decoratively.
- **Depth by bevel, not by shadow.** 2 px hard light top/left + 2 px hard
  dark bottom/right + 1 px border and a 1 px dark outline. No soft shadows,
  no gradients except the hero image fade.
- **Pixel first.** Square corners, hard colour bands, 1-bit icons and pixel
  labels; smooth sans is reserved for user data that needs Unicode.
- **Quiet motion.** Only focus, press, progress and one indeterminate spinner.
  Nothing animates in the background.
- **Never lie.** No fake "online" badges, no fake play-time. Show only data the
  menu can actually read.

## 4. Visual direction

Hybrid of Millida's modern pixel launcher and Bedrock's blocky material:

- charcoal background, pixel-block cards with hard bevels;
- saturated teal/blue/crimson action buttons with a hard pixel sunburst;
- white pixel labels plus readable sans for user data;
- hero card with the grayscale pixel texture, heavily dimmed;
- pixel-art icons drawn from a 24 px icon font and thresholded to 1-bit;
- a small rotated splash line on the Home screen for flavour.

## 5. Color tokens

Use these exact values. `LÖVE` colors are floats in `[0,1]` (`hex / 255`).

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#0D0D10` | screen background |
| `bgDeep` | `#08080A` | modal scrim base, icon wells |
| `panel` | `#17171C` | card / panel fill |
| `panelAlt` | `#1F1F26` | raised row, info panel |
| `panelHi` | `#26262E` | pressed / hover fill |
| `line` | `#34343E` | 1 px borders |
| `lineSoft` | `#2A2A32` | separators |
| `lineStrong` | `#4A4A57` | disabled borders, chips |
| `text` | `#ECECF1` | primary text |
| `textDim` | `#9A9AA8` | secondary text |
| `textMuted` | `#6E6E7C` | non-essential meta only |
| `green` | `#63C93F` | primary action, success |
| `greenHi` | `#8EE86B` | green bevel top, success text |
| `greenDeep` | `#2E6F1C` | green border / bottom bevel |
| `greenInk` | `#0F2408` | text on green |
| `tintGreen` | `#19230F` | green badge fill |
| `blue` | `#3F8FD8` | update accents |
| `blueDeep` | `#275F93` | update border |
| `tintBlue` | `#101A24` | update card fill |
| `orange` | `#C9802F` | setup accents (legacy) |
| `tintOrange` | `#221A10` | setup card fill (legacy) |
| `setup` | `#1F8A70` | Setup action fill |
| `setupHi` | `#33A98A` | Setup border / rays |
| `update` | `#1E6FA8` | Update action fill |
| `updateHi` | `#2E8FCF` | Update border / rays |
| `exit` | `#A61B3F` | Exit action fill |
| `exitHi` | `#C42F57` | Exit border / rays |
| `red` | `#B8493F` | destructive action |
| `redDeep` | `#7D2F28` | destructive border |
| `tintRed` | `#221111` | destructive card fill |
| `yellow` | `#E9C64A` | splash text, warning |
| `white` | `#FFFFFF` | hero version, modal title |

Contrast: `text` on `panel` ≈ 14:1, `textDim` on `panel` ≈ 6:1, `greenHi` on
`tintGreen` ≈ 8:1. `textMuted` is **not** allowed for interactive labels.

Selection is never signalled by color alone: focused elements get a 2 px white
ring with a 2 px background gap. Green is reserved for actions, success and
semantic badges; it is no longer used for focus.

## 6. Typography

| Role | Font | Size | Weight | Case |
|---|---|---|---|---|
| App title | Minecraft F2D | 12 | bold* | UPPER |
| Section header | Minecraft F2D | 11 | bold* | UPPER |
| Badge / chip | Minecraft F2D | 11 | bold* | UPPER |
| Splash | Minecraft F2D | 11 | bold* | sentence |
| Keycap | Minecraft F2D | 9 | regular | UPPER |
| Primary button | Minecraft F2D | 12 / 18 | bold* | UPPER |
| Hero version | Minecraft F2D | 18 | bold* | as-is |
| Card title | Minecraft F2D | 12 | bold* | as-is |
| Action title | Minecraft F2D | 11 | bold* | UPPER |
| Action subtitle | Minecraft F2D | 11 | bold* | sentence |
| File name | Minecraft F2D | 11 | regular | as-is |
| Body | Minecraft F2D | 11 | regular | sentence |
| Meta | Minecraft F2D | 11 | regular | sentence |
| Footer hint | Minecraft F2D | 11 | bold* | sentence |
| Section count | Minecraft F2D | 11 | bold* | UPPER |
| Modal title | Minecraft F2D | 12 | bold* | UPPER |

`bold*` means faux bold: the same glyph is drawn twice, 1 px apart. Minecraft F2D
has one weight, and this keeps 11/12 px labels from looking thin on the handheld.

Rules:

- **Minecraft F2D is the primary UI font.** Crux is attached as a per-glyph
  fallback, so missing glyphs and any unmapped Vietnamese characters still
  render. Silkscreen and Inter remain fallbacks if a font file is missing.
- Pixel sizes: **9, 11, 12, 18**. Always nearest-neighbour filtering.
- Line height: 1.0; explicit line spacing (11/13/14/16 px) is used for wrapped
  paragraphs.
- Truncate to one line with `...` when a card is too narrow. The full value is
  always visible in the details panel or hero card.
- Faux bold is for headings, chips and key labels, never for long paragraphs.
- Never go below 11 px.

Font files (bundled):

- `font_minecraft.otf` - Minecraft F2D by “ygygfu”, **OFL-1.1** (primary).
- `font_crux.ttf` - SVN-Coder's Crux by NAL, **CC BY 3.0** (per-glyph fallback).
- `font_pixel.ttf` - Silkscreen, OFL-1.1 (pixel fallback).
- `font_body.ttf`, `font_body_bold.ttf` - Inter, OFL-1.1 (body fallback).
- `font_icons.ttf` - Pixelarticons, MIT (icons).
- License texts in `licenses/`, listed in `THIRD_PARTY_NOTICES.md`.

## 7. Layout

Base unit: **4 px**. Use the scale 2 / 4 / 6 / 8 / 12 / 16 / 20 / 24 / 32.

| Region | Value |
|---|---|
| Screen | 640 x 480 |
| Side margin | 16 |
| Header height | 46 |
| Hero top / height | 58 / 102 |
| Section label top / height | 170 / 18 |
| Card grid top | 192 |
| Grid columns / gap / row height | 3 / 7 / 76 |
| Footer height | 32 (top border 1 px) |
| Corners | square (pixel); no rounded or diagonal corners |
| Bevel | 2 px hard top highlight, 2 px hard bottom shadow, 1 px border + 1 px dark outline |
| Focus ring | 2 px white ring + 2 px background gap |

```
0        16                                        624   640
+---------+-----------------------------------------+----+
| HEADER 46                                              |
+---------+-----------------------------------------+----+
|         | HERO 102                                |    |
|         +-----------------------------------------+    |
|         | SECTION 18                              |    |
|         +-----------------------------------------+    |
|         | GRID 3 x 76 (2 rows visible = 242)      |    |
+---------+-----------------------------------------+----+
| FOOTER 32                                              |
+--------------------------------------------------------+
```

The Home screen shows up to two rows of version cards plus a pinned action row
(Setup / Update / Exit). The version grid scrolls in two-row pages when there
are more than six versions; the action row never scrolls and is always visible.
If there are no versions the action row moves up to y=192; with one row of
versions it sits at y=268, otherwise at y=358. A 2 px scrollbar appears at
x=628 only when the version list needs scrolling.

## 8. Components

### 8.1 Panel / card

Square pixel rectangle with three layers:

1. 1 px dark outline (`bgDeep`);
2. 1 px border (`line`, or the accent border when focused);
3. 1 px inset panel fill (`panel` / tint) with a 2 px hard top highlight
   (`lineSoft`) and a 2 px hard bottom shadow (`bgDeep`).

Focus adds a 2 px white ring and a 2 px background gap. There is no left bar,
no green border and no fill tint. The panel border stays `line` when focused.
No rounded corners, no diagonal cuts, no soft shadow.

### 8.2 Primary button (`PLAY`, `INSTALL`, `UPDATE`)

- Height 52 (hero) or 42 (panel), min width 140.
- Fill: flat `green` with a 4 px `greenHi` top band and a 4 px `greenDeep`
  bottom band; 1 px `greenHi` border and 1 px `bgDeep` outline.
- Label: pixel 12 (18 px on the 52 px hero button), white, followed by a crisp
  pixel arrow on the right. The label and arrow are centred as one group, not
  left-aligned. The arrow is drawn in Lua so it stays 1-bit at every size.
- Pressed: move content down 1 px, swap highlight to the bottom edge.
- Disabled (no version selected): fill `panelAlt`, border `line`, label
  `textMuted`. Never hide the button; show it disabled.

### 8.3 Action card (Setup / Update / Exit)

- 76 px tall, icon 24 px on the left, two text lines on the right.
- Saturated Millida colours: Setup `#1F8A70`, Update `#1E6FA8`, Exit `#A61B3F`,
  with a 1 px lighter border (`setupHi` / `updateHi` / `exitHi`) and a 1 px
  `bgDeep` outline.
- Hard pixel sunburst: 10 alternating lighter rays from the icon area, plus a
  4 px light top band and a 4 px dark bottom band. No soft gradient.
- Title: pixel 11 white with a 1 px dark shadow; subtitle: pixel 11 white at
  80%; icon: 1-bit white with a 1 px dark shadow.
- Focus: white 2 px ring + 2 px background gap.

### 8.4 Version card

- Title: pixel 12, one line, ellipsis.
- Bottom row: architecture badges (`ARM64`, `ARM32`) at 8 px pixel.
- No fake timestamps or playtime.
- Focused: 2 px white ring with a 2 px background gap; the card fill, title and
  badges do not change. The ARM64 badge is always green.
- Delete-armed state is **not** drawn on the card; deletion always opens the
  modal, so the card has no red state.

### 8.5 Badge / chip

1 px border, 3 px vertical padding, 8 px pixel font, uppercase, **square
corners**. Variants: neutral (`lineStrong` border, `textDim`), green, blue,
orange, red. Used for architecture, version, step state.

### 8.6 Section header

Pixel 8 uppercase, `text` at 80% brightness, tracking 1, plus a right-aligned
8 px count (`4 INSTALLED`). A 1 px `lineSoft` rule is optional and only used
when the section sits directly above a list without cards (never on Home).

### 8.7 Footer

32 px, `#101014`, 1 px top border. Left: key hints
`[A] PLAY   [X] DELETE   [B] BACK`, pixel 8, keycaps 16x16. Right: page
indicator (`1 / 7`) in pixel 8 `textMuted`. On screens with no actions, the
left side becomes a status note and the right side may show a safety note.

### 8.8 Modal

- Scrim: `rgba(5,5,6,0.72)` over the whole screen.
- Panel: 400 x 160, centered at (120, 160), square pixel corners, `panelAlt`.
- Title: pixel 12 uppercase; body: pixel 11, max 2 lines.
- Buttons: 140 x 36, Cancel (dark, default focus) and Delete/Update (red or
  green). Default focus is always the safe choice.
- B cancels; A activates the focused button; Left/Right switches.

### 8.9 Progress bar

16 px track, `bgDeep` fill, 1 px `line`, 2 px inner padding. Fill is a 8 px
green stripe pattern with a 2 px highlight on top. Percentage right-aligned in
body 11. When total size is unknown, use an indeterminate 30% block sliding
left-to-right (discrete 8 px steps, 12 fps).

### 8.10 Icons

Two sources:

- **Pixelarticons** (MIT) webfont at 24 px for package, download, logout, file,
  cpu, warning and loader. The glyph is rendered once into a 24x24 Canvas and
  its alpha is thresholded to 1-bit, so there is no FreeType anti-aliasing.
  Glyphs are tinted with the action accent or white.
- **Original 16x16 bitmaps** drawn in Lua for the grass-block logo, the update
  step check/cross marks and the footer. These are cached in Canvases with
  nearest filtering.

Pixelarticons is a strict 24x24 grid; only render it at 24 px (or multiples)
so it stays crisp. Icons are never used to carry information alone: every icon
is paired with a label.

## 9. Screens

### 9.1 Home

```
+--------------------------------------------------------+
| [grass] MCPE LAUNCHER   v1.8.0            [ARM64]      |  header
+--------------------------------------------------------+
|  SELECTED VERSION                    ................. |
|  1.21.4                        bg.jpg  .   [ > PLAY ]  |
|  [ARM64] [ARM32]                     ................. |  hero
+--------------------------------------------------------+
| MY VERSIONS                              4 installed   |
| +-------------+ +-------------+ +-------------+        |
| | 1.21.4      | | 1.20.1      | | 1.19.2      |        |
| | [A64][A32]  | | [A64]       | | [A32]       |        |
| +-------------+ +-------------+ +-------------+        |
| +-------------+ +-------------+ +-------------+        |
| | 1.18.30     | | 1.16.221    | | 1.14.60     |        |
| +-------------+ +-------------+ +-------------+        |
| +-------------+ +-------------+ +-------------+        |
| | SETUP APK   | | UPDATE PORT | | EXIT        |  pinned|
| +-------------+ +-------------+ +-------------+        |
+--------------------------------------------------------+
| [A] Play   [X] Delete   [B] Back              1 / 7    |
+--------------------------------------------------------+
```

- Products with no installed versions: hero shows `NO VERSION INSTALLED`,
  Play is disabled, section count `0 installed`, and the first focus is
  `SETUP APK`.
- The splash line (`Now with 200% more blocks!`) is pixel 8 `yellow`, rotated
  -5 degrees, placed in the header between the version chip and the
  architecture badge. One random line per launch from a small original list.
  It is hidden if it would collide with the architecture badge.
- The hero `PLAY` button is the first focusable item when at least one version
  exists. Focus starts there; Down moves into the version grid, Up from the
  first grid row returns to it.
- Down from the last version row moves to the pinned action row in the same
  column (it lands on Exit when that is the only remaining card). Up from the
  action row returns to the last version row in the same column.

### 9.2 Setup Apk

```
+--------------------------------------------------------+
| [grass] SETUP APK                         [8 FILES]    |
+--------------------------------------------------------+
| APKs in mcpe_launcher / Setup Apk / - filename = name  |
| +----------------------------+  +-------------------+ |
| | APK FILES          [8]     |  | SELECTED FILE     | |
| | [apk] Minecraft-1.21.4     |  | [apk] Minecraft-  | |
| |       842 MB - A64 + A32   |  |       1.21.4      | |
| | [apk] Minecraft-1.20.1     |  | [A64] [A32]       | |
| |       712 MB - A32         |  | ----------------- | |
| | ...                        |  | Size      842 MB  | |
| | 8 files - 4.2 GB           |  | Arch   A64 + A32  | |
| +----------------------------+  | Free      4.2 GB  | |
|                                 | Install as 1.21.4 | |
|                                 | hint / error      | |
|                                 | [ > INSTALL ]     | |
|                                 +-------------------+ |
+--------------------------------------------------------+
| [A] Install   [X] Delete   [B] Back           1 / 8    |
+--------------------------------------------------------+
```

- Left: framed list panel, 356 px wide, 5 rows visible (50 px rows, 6 px gap),
  an `APK FILES` header with a count badge, an internal scrollbar and a
  `N files - total size` footer. Rows use a 30 px icon well, a one-line
  ellipsised name and a `size - architecture` meta line.
- Right: detail panel, 240 px wide, from y=82 to y=426. `SELECTED FILE`, a
  46 px icon well with a wrapped 2-line name, architecture badges, a divider,
  Size / Architectures / Free space / Install as rows, a 3-line hint or error,
  and a full-width `INSTALL` button at the bottom.
- The selected list row uses the shared white focus ring; the ring gap is
  `panelAlt` so it matches the framed list.
- APK rows are text-only: no per-APK image, generated sprite or Mojang texture.
- The INSTALL button is disabled while the APK is still being scanned or when
  no ARM libraries are found.
- Empty state replaces both columns: a full-width 608 x 344 panel with a large
  package icon, `NO APK FOUND`, the exact folder path in a dark path badge and
  the next step.
- If the APK has only one architecture, the install goes straight through; if
  both, the arch screen follows.
- Long filenames: one line with ellipsis in the list, two wrapped lines in the
  info panel.

### 9.3 Architecture choice

```
+--------------------------------------------------------+
| [grass] SELECT ARCHITECTURE                            |
+--------------------------------------------------------+
| Which build should be extracted from Minecraft-1.21.4? |
| +-------------+ +-------------+ +-------------+        |
| |   [chip]    | |   [chip]    | |   [chip]    |        |
| |    BOTH     | |    ARM32    | |    ARM64    |        |
| | 32 + 64 bit | |  armeabi-   | |  arm64-v8a  |        |
| | recommended | |  v7a        | |             |        |
| +-------------+ +-------------+ +-------------+        |
+--------------------------------------------------------+
| [A] Extract   [B] Back                                 |
+--------------------------------------------------------+
```

- Three cards 192 x 180, gap 16, starting x=16.
- `BOTH` is default and labelled `recommended`; it is only offered when the APK
  actually contains both ABIs.
- Short explanation per card: what folder is extracted.

### 9.4 Extracting (wait)

- Full-screen `bg.jpg` dimmed 78%, centered panel 460 x 220.
- Title `EXTRACTING APK`, subtitle is the version name (body 11, ellipsis).
- Progress bar from `du -sk`, percentage right-aligned.
- Indeterminate mode until the first `du` sample arrives.
- No input except the OS killing the process; B does nothing.

### 9.5 Update Port

```
+--------------------------------------------------------+
| [grass] UPDATE PORT                    [DO NOT TURN OFF] |
+--------------------------------------------------------+
|                                                          |
|                    [download]                            |
|                  INSTALLING FILES                        |
|             Replacing launcher files...                  |
|       [====================================]             |
|                   STEP 4 OF 5                            |
|             Do not turn off the console.                 |
|                                                          |
+--------------------------------------------------------+
| YOUR VERSIONS, WORLDS AND SIGN-IN ARE KEPT             |
+--------------------------------------------------------+
```

- One centered 520 x 240 card. No step list, no step cards, no second panel.
- 48 px phase icon (download / check / cross), 24 px phase title
  (`INSTALLING FILES`, `UPDATE COMPLETE`, `UP TO DATE`, `UPDATE FAILED`), one
  centered status line, a 440 x 20 progress bar, `STEP 4 OF 5`, and one safety
  line.
- A one-line hint per active step fills the status line (checking, downloading,
  verifying, installing, cleaning); real status messages replace it when present.
- The progress bar reflects the current step (`step / 5`), not bytes. There is
  no fake percentage: the script only reports step changes. Step 2 (download)
  uses the indeterminate animation because the download size is unknown. The bar
  turns red on failure.
- The header chip carries the warning/result (`DO NOT TURN OFF`, `DONE`,
  `UP TO DATE`, `FAILED`); the card line repeats the safe/unsafe instruction.
- Long messages wrap to two lines; the full text stays in `update_log.txt`.
- Success ends with a green check and an `A = OK` footer; failure uses red and
  the rollback is handled by the updater. The screen closes only on A after
  `END`.

### 9.6 Delete modals

Both use the standard modal. Copy must be accurate:

- **Delete version** — "Removes the installed game files for `<name>`. Worlds,
  skins and settings are kept." Buttons: `CANCEL` (default) / `DELETE`.
- **Delete APK** — "Removes `<file>` from Setup Apk. Installed versions are
  kept." Buttons: `CANCEL` (default) / `DELETE`.
- **Update** — "Update the port to the latest release? Wi-Fi is required, or
  place the release zip in mcpe_launcher/update.zip." Buttons: `CANCEL`
  (default) / `UPDATE`.

### 9.7 Settings

Controller and display options in two columns of five rows (48 px high, 8 px
gap) starting at y=78.

- Header: grass logo, `SETTINGS` and the version badge.
- Column labels: `CONTROLS` (left) and `BUTTONS & DISPLAY` (right) at y=52;
  the row grid starts at y=78 so the labels are not covered by the first row.
- Row: label (pixel 12) on the left; a value badge on the right for choices,
  or a pixel switch for toggles. The focused choice row shows left/right
  arrows; the switch shows a green frame when focused.
- Left column: PAD MODE (AUTO/DIRECT), SWAP STICKS, INVERT LOOK X, INVERT LOOK
  Y, CONFIRM BUTTON (AUTO/A/B).
- Right column: SWAP A/B, SWAP X/Y, SWAP L1/R1, BUTTON MAP (action row),
  SCREEN ROTATION (AUTO/0/90/180/270), RESET CONTROLS (action row).
- A help panel under the grid describes the focused row; the note under it
  says changes apply when the game starts.
- A change is written to `settings.conf` immediately; rotation also writes
  `rotation.txt`. `McpeLauncher.sh` reads the file before the game starts and
  ignores unknown or out-of-range values.
- X opens the same reset confirmation as the RESET row. Reset is never the
  default choice in the modal.
- Footer: Change / Reset / Back, with the button prompts from `gamepad.png`.

### 9.8 Button map (separate app)

`SETTINGS → BUTTON MAP` writes `remap_request.txt` and quits the menu.
`McpeLauncher.sh` stops `gptokeyb`, runs `mcpe_launcher/menu/remap` with the
path to `settings.conf`, then restarts the menu. Reading the pad directly is
the only reliable way to see raw button indices while the firmware is holding
the controller.

- Header: `BUTTON MAP` and a `step / 8` badge.
- Prompt: "PRESS THE PHYSICAL BUTTON FOR" (or "PULL THE PHYSICAL TRIGGER
  FOR" on L2/R2) plus the action label at pixel 24.
- Summary: eight cards (A, B, X, Y, L1, R1, L2, R2) showing `BTN n`, `AXIS n`
  or `--`.
- L2/R2 accept analog axes (`aN`, captured above 0.6 after release) and
  buttons (`bN`), so both trigger styles work.
- Progress bar for the 12 s auto-skip; if no input arrives at all, the screen
  exits after 15 s without touching the file.
- Assigning a physical input that is already used swaps the two actions.
- On success it writes `map_a..map_rt` into `settings.conf` and returns after
  2.5 s. `McpeLauncher.sh` applies the map over the SDL mapping.
- LÖVE reports 1-based button/axis numbers; the screen subtracts one so the
  stored values match SDL's 0-based mapping (`b0`, `a4`, ...).
- The screen also stores the pad's current SDL mapping line in `map_base`.
  `McpeLauncher.sh` uses it as the base when the firmware exposes no
  `sdl_controllerconfig` entry.

## 10. Interaction

| Input | Action |
|---|---|
| D-pad | move focus (grid: L/R ±1, U/D ±3, clamped) |
| A / Enter / Space | activate focused card or button |
| B / Esc | back; on Home = exit to Ports |
| X | delete APK; on Home: open the action row (X again deletes the last selected version); on Settings: reset |
| Y | on Home: set the highlighted version as the default; in the action row: return to that version |
| Home/Start | reserved, not bound |
| F12 (dev) | save screenshot |

- Settings: Up/Down moves between rows, Left/Right changes the value, A cycles
  the value (or opens the reset modal on the RESET row), B returns to Home.
  Toggle rows use a switch; choice rows use a badge with arrows.
- Button map: no navigation; each physical button press (or trigger pull)
  assigns the current action and advances. A 12 s timer skips, 15 s with no
  input cancels.
- Footer keycaps A/B/X/Y use the CC0 Gamepad UI prompts (`gamepad.png`); the
  text keycap remains as a fallback when the image is missing.

- Key repeat: 350 ms initial delay, 90 ms interval, implemented in
  `love.update` with `love.keyboard.isDown` so it also works under
  `gptokeyb` key translation.
- `MCPE_CONFIRM_SDL=a|b` swaps the confirm button; `MCPE_CONFIRM_LABEL=A|B`
  changes every keycap and hint. Footer must always show the real label.
- B never performs a destructive action. Destructive actions require a modal
  and a deliberate A on the red button.
- Focus is remembered when returning from Setup/Apk/Arch to Home, and reset to
  row 1 when the list shrinks below the current index.

## 11. Content and copy

- UI language: English. No l10n in 1.8.0.
- Titles: `MCPE LAUNCHER`, `SETUP APK`, `SELECT ARCHITECTURE`,
  `EXTRACTING APK`, `UPDATE PORT`, `SETTINGS`.
- Buttons: one verb, uppercase, pixel font (`PLAY`, `INSTALL`, `EXTRACT`,
  `UPDATE`, `DELETE`, `CANCEL`).
- Section labels: `MY VERSIONS`, `SELECTED VERSION`.
- Empty states always say what is missing, where it goes, and what to do next.
- Never use Mojang trademarks in copy beyond referring to the user's own APK.
- Error text from scripts is shown verbatim in `UpdatePort`/`SetupMcpe` logs;
  the UI itself does not invent technical claims.
- Path text uses `mcpe_launcher / Setup Apk /` with spaces around slashes for
  readability on small screens.

## 12. Accessibility

- Minimum interactive text size: 11 px (body). 9 px only for non-essential
  meta. 8 px pixel only for uppercase chrome.
- Body text contrast ≥ 4.5:1; large text and focus indicators ≥ 3:1.
- Focus is visible without color: 2 px white ring + 2 px background gap.
- No flashing faster than 3 Hz. The only loop is the 12 fps indeterminate bar
  and the active-step pulse (1.1 s).
- Key hints are always on screen; no hidden modifier combinations.
- Destructive choice is never the default focus.

## 13. Motion

| Event | Duration | Easing |
|---|---|---|
| Focus change | instant | none |
| Button press | 70 ms | instant offset, then back |
| Screen change | 120 ms | fade through `bg` (no slide) |
| Progress fill | 150 ms | ease-out to target |
| Active step pulse | 1100 ms | alpha 1.0 -> 0.45 -> 1.0 |
| Indeterminate bar | 12 fps | discrete 8 px steps |

Disable all easing automatically if the measured frame time exceeds 22 ms for
1 second (low-power fallback): snap colors instead of lerping.

## 14. Performance budget

- 60 fps target, frame budget ≤ 8 ms on RK3326.
- ≤ 200 draw calls per frame, ≤ 4 MB of textures/Canvases.
- All static composition (hero card, background, icon sheets) is cached in
  Canvases and invalidated only on selection change or resize.
- Fonts are created once in `love.load`.
- `io.popen` / `os.execute` only on screen entry or refresh, never per frame.
- No shaders, no blur, no MSAA, no high-DPI.
- Menu startup ≤ 1.5 s.

## 15. Assets and licensing

- `menu/bg.jpg` — grayscale pixel texture supplied by the project owner (see
  CREDITS.md), used by the hero and the wait/update backdrops. No third-party
  game asset is bundled.
- `menu/icon.png` — 21x21 grass-block header icon supplied by the project
  owner; scaled to 26 px with nearest filtering.
- `font_minecraft.otf` — Minecraft F2D by “ygygfu”, OFL-1.1. Primary UI font.
- `font_crux.ttf` — SVN-Coder's Crux by NAL, CC BY 3.0. Per-glyph fallback,
  Latin + Vietnamese.
- `font_pixel.ttf` — Silkscreen, OFL-1.1 (pixel fallback).
- `font_body.ttf`, `font_body_bold.ttf` — Inter, OFL-1.1 (body fallback).
- `font_icons.ttf` — Pixelarticons webfont, MIT. Rendered at 24 px inside
  26-32 px wells; its glyphs are thresholded to 1-bit and tinted per action.
- Icons — Pixelarticons for package/download/logout/file/cpu/warning; the
  grass-block logo and the 16 px check/cross marks are original 16x16 pixel
  art drawn in Lua.
- Add the font licenses (Minecraft F2D, Crux, Silkscreen, Inter) to
  `licenses/` and `THIRD_PARTY_NOTICES.md`.
- Never bundle Mojang's `Minecraft.ttf` / `MinecraftTen.ttf`; Minecraft F2D is
  an independent OFL-licensed fan font, not a Mojang asset.

## 16. Code architecture

```
mcpe_launcher/menu/
  conf.lua            -- fullscreen on device, windowed with --dev
  main.lua            -- arg parsing, dev detection, state machine, input, file I/O
  ui.lua              -- tokens, fonts, primitives, icons, caches
  dev.lua             -- mock data + shot mode (excluded from release)
  screens/home.lua
  screens/apk.lua
  screens/arch.lua
  screens/settings.lua
  remap/              -- separate LÖVE app for press-to-bind
  bg.jpg
  gamepad.png         -- CC0 A/B/X/Y prompts for the footer
  font_pixel.ttf
  font_body.ttf
  font_body_bold.ttf
  font_crux.ttf
  font_minecraft.otf
  font_icons.ttf
  update/             -- ui.lua/bg/fonts synced by scripts/sync_ui.py
  wait/               -- ui.lua/bg/fonts synced by scripts/sync_ui.py
```

- `main.lua` owns all file reads/writes and `love.event.quit(0)`. Screens are
  pure draw + input handlers over an `App` table.
- Keep the 3 game dirs. Do **not** unify them: `McpeLauncher.sh` kills the
  wait screen by path (`pkill -f "$GAMEDIR/menu/wait"`).
- `scripts/sync_ui.py` copies `ui.lua`, `gamepad.png`, `bg.jpg` and the fonts
  into `update/`, `wait/` and `remap/`, then verifies SHA-256 so the copies
  cannot drift.
- `scripts/build_release.py` excludes `dev.lua`, any `shots/` output and
  development-only files from the release zip.

## 17. Windows preview (dev only)

- Download LÖVE 11.5 win64 portable to a temp folder; never commit it.
- Run: `lovec.exe "<repo>\mcpe_launcher\menu" --dev`
- `--dev` behaviour:
  - windowed 640x480, vsync on;
  - `MCPE_GAMEDIR` unset -> mock base dir under the system temp folder;
  - fake versions and APKs generated in temp, never in the repo;
  - `unzip` stubbed to report both ABIs;
  - selection writes go to the mock dir; quitting does not touch the device
    files.
- `--shots` renders Home, Setup, Arch, Wait and Update in their key states and
  writes PNGs to the temp shots folder, then exits.
- `--selftest` runs the navigation and handshake checks without a console and
  prints `SELFTEST PASS` / `SELFTEST FAIL`.
- On a real console no flag is passed, so behaviour is identical to 1.7.0.

## 18. Definition of Done (UI)

A screen is done only when all of these are true:

- renders correctly at 640x480 in `--dev` and on the R36S;
- every control is reachable with D-pad only;
- focus is always visible and never trapped;
- no text overflow, no clipped keycaps, no overlapping splash;
- 0, 1, 7 and 20+ item states look correct;
- long and non-ASCII names render with the body font and ellipsis;
- all handshake files are written with the same values as 1.7.0;
- no Lua errors or warnings in `log.txt`;
- frame time stays within budget on device;
- screenshots for the PR/README are captured from the real build.

## 19. Open decisions

- Splash text list: to be written (5-8 original lines, English, no Mojang
  slogans).
- Whether to keep the `ONLINE` badge: **removed** until the menu actually
  probes connectivity.
- Whether to show installed size per version: deferred; `du` per card is too
  slow on a full SD card.
- Vietnamese UI: deferred to 1.9.0; requires a body font with full Vietnamese
  coverage and a pixel font for static chrome only.

## 20. Change log of this document

| Date | Change |
|---|---|
| 2026-11-22 | Initial baseline: hybrid Millida/Bedrock direction, tokens, screens, input, dev preview |
| 2026-11-22 | Implementation notes: step-based update progress (no fake %), splash in the header, modal title at 16 px, hero Play is a focus target |
| 2026-11-22 | Icons: Pixelarticons (MIT) 24 px webfont for UI icons; original bitmaps kept for the logo and 16 px step marks |
| 2026-11-22 | Pixel pass: square beveled panels, saturated sunburst action buttons (Millida palette), pixel footer/section labels, 1-bit icons |
| 2026-11-22 | Typography: SVN-Coder's Crux (CC BY 3.0) as the single UI font; 13/16/24 px with faux bold; Silkscreen/Inter kept as fallbacks |
| 2026-11-23 | Typography: Minecraft F2D (OFL-1.1) as the primary UI font at 9/11/12/18 px; Crux kept as a per-glyph fallback. Buttons now use white text/icons. |
| 2026-11-23 | Selection: shared 2 px white outline + 2 px gap; removed green focus fill/border/left bar. Setup Apk and Update Port redesigned. |
