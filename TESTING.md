# Testing

## Hardware / firmware

| System | Status |
|---|---|
| DarkOS (and forks) | ✅ Supported |
| ArkOS4Clones (latest builds) | ✅ Supported |
| Rocknix (2026 latest builds) | ⚠️ Should work, not fully tested |
| Classic ArkOS / older ArkOS4Clones | ❌ Not supported (GLIBC 2.30 too old) |

## Minecraft Bedrock APK versions

| Version | Status | Notes |
|---|---|---|
| 1.2.x+ | ✅ Working | Minimum supported baseline |
| 1.17.x | ⚠️ Working with caveat | Crashes if WiFi is active — disable WiFi before launch |
| Other versions | ❓ Untested | Reports welcome, see CONTRIBUTING.md |

## How to report a test result

Open an issue using the bug report template with:
- Console/firmware + build date
- Minecraft APK version tested
- Result: works / crashes / graphical issue / input issue
- Log output from `mcpe_launcher/mcpelauncher/mcpelauncher-client-settings.txt`
  directory if a crash occurred

## Known limitations (not bugs)

- Xbox Live / online multiplayer: disabled on purpose (prevents auth-related
  crashes). Local LAN multiplayer works.
- No on-screen keyboard: edit usernames/world names from a PC via
  `mcpe_launcher/mcpelauncher/mcpelauncher/games/com.mojang/`.
