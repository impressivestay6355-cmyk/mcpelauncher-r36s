==================================================
  MCPE Launcher for RK3326 consoles
==================================================

REQUIREMENTS
- RK3326-based console (tested on R36S)
- Compatible with DarkOS and its forks
- Compatible with the latest ArkOS4Clones builds
- Should work with the latest 2026 Rocknix builds (not fully tested)
- NOT SUPPORTED: classic ArkOS / older ArkOS4Clones builds
  (outdated GLIBC 2.30 kernel)
- Minecraft Bedrock Edition APK (armeabi-v7a / ARM32)
  NOT included. You must provide your own legally obtained APK.

LEGAL NOTICE
This port does not include any Minecraft game files.
All game content must be provided by the user from a legally
owned copy of Minecraft Bedrock Edition for Android.
This port is not affiliated with, sponsored by, or endorsed by
Mojang Studios, Microsoft, or Xbox. "Minecraft" is a trademark
of its respective owners.

--------------------------------------------------
SUPPORTED VERSIONS
--------------------------------------------------

Any ARM32 (armeabi-v7a) APK from version 1.2 onwards
(when Minecraft transitioned from Pocket Edition to Bedrock Edition).

Note: Not all versions have been tested. Some versions may not
work correctly.

KNOWN ISSUE: version 1.17 crashes if the internet/WiFi connection
is active. Disable WiFi before launching this version.

--------------------------------------------------
FIRST TIME SETUP
--------------------------------------------------

1. Extract the zip and copy the following into your
   /roms/ports/ folder:
     - mcpe_launcher/   (folder)
     - McpeLauncher.sh
     - SetupMcpe.sh

2. Place your Minecraft ARM32 APK file inside:
   /roms/ports/mcpe_launcher/

   The APK filename will become the version name shown
   in the selection menu. Example:
     1.16.101.apk  -> shown as "1.16.101"
     Minecraft 1.17.41.01.apk -> shown as "Minecraft 1.17.41.01"

3. Run SetupMcpe.sh from the Ports section in EmulationStation.
   This will extract game files from the APK automatically.

4. IMPORTANT: After setup is complete, delete or move the APK
   from the mcpe_launcher folder. If left there, it may cause
   conflicts when adding another version later.

5. To add another version, place the new APK in the
   mcpe_launcher folder, run SetupMcpe.sh again, then
   delete the APK.

--------------------------------------------------
LAUNCHING THE GAME
--------------------------------------------------

Run McpeLauncher.sh from the Ports section in EmulationStation.
A version selection menu will appear.
Select your version and the game will start.

--------------------------------------------------
NOTES
--------------------------------------------------

- Online multiplayer (Xbox Live) is NOT supported.
  Network is force-disabled internally to prevent crashes
  caused by Xbox Live authentication attempts.

- Local LAN multiplayer IS available.

- There is NO virtual keyboard. If you need to change
  your username or world names, you can do so by editing
  the game save files directly from a PC.
  Save data is located in:
  /roms/ports/mcpe_launcher/mcpelauncher/mcpelauncher/games/com.mojang/

--------------------------------------------------
CREDITS
--------------------------------------------------

Launcher binary based on:
  https://github.com/minecraft-linux/mcpelauncher-manifest

Port scripts and configuration by: ImpressiveStay

Full credits and third-party components: see CREDITS.md
on the project's GitHub page.
