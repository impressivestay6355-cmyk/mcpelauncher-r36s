# Testing

## Hardware / firmware

| System | Status |
|---|---|
| ArkOS | ✅ Supported |
| ArkOS4Clones | ✅ Supported |
| DarkOS (and forks) | ✅ Supported |
| Rocknix | ✅ Supported |
| Other OS | ❓ Untested, reports welcome, see CONTRIBUTING.md |

## Minecraft Bedrock APK versions

| Version | Status | Notes |
|---|---|---|
| 1.1.x+ | ✅ Working | Minimum supported baseline |

## How to report a test result

Open an issue using the bug report template with:
- Console/firmware + build date
- Minecraft APK version tested
- Result: works / crashes / graphical issue / input issue
- Log output from `mcpe_launcher/log.txt` if a crash occurred

## Known limitations (not bugs)

- Xbox Live access is not available.
- Local LAN multiplayer works. Servers that don't require Microsoft
  login may also work.
