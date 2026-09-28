# Getting your Minecraft Bedrock APK

## Step 0 — Legally buy Minecraft on Google Play

Before anything else, **legally buy Minecraft on the Google Play Store**
with your own Google account:
https://play.google.com/store/apps/details?id=com.mojang.minecraftpe

All the methods below only work with a Google account that owns Minecraft.

---

**No game files are included in this project.** You must use an APK of
Minecraft Bedrock Edition for Android that you legally own, bought on
Google Play with your own Google account.

This project does not host, link to or distribute Minecraft APKs, and it does
not bypass any purchase or license check.

**NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH
MOJANG OR MICROSOFT.**

There are three ways to get the APK from your own purchase:

| Method | Versions you can get | Needs |
|---|---|---|
| 1. Aurora Store | Any version still served by Google Play | Android device + Google account that owns Minecraft |
| 2. mcbedrock-get (PC) | Any version still served by Google Play | Windows PC + Google account that owns Minecraft |
| 3. Backup from your phone | Only the version installed on the phone | Android phone with Minecraft installed from Google Play |

Methods 1 and 2 use unofficial Google Play clients: they only download what
your account owns, but using them may go against Google Play's terms of
service. Method 3 uses only the official Google Play app.

---

## Which architecture do I need?

| Console firmware | APK architecture |
|---|---|
| 64-bit (aarch64) | `arm64-v8a` (recommended) or `armeabi-v7a` |
| 32-bit (armhf) | `armeabi-v7a` |

If an APK contains both architectures, the port lets you choose which one to
install.

---

## Method 1 — Aurora Store (Android)

Use this to get a specific version, as long as your Google account owns
Minecraft.

1. Install **Aurora Store** and **AntiSplit M** on an Android device.
2. In Aurora Store, sign in with the **Google account that bought
   Minecraft**.
3. Search for **Minecraft**, open it and choose **Manual download**.
4. Enter the version code of the version you want. Each version and
   architecture has its own code, listed in
   [version_codes.txt](version_codes.txt) (`arm32` = `armeabi-v7a`,
   `arm64` = `arm64-v8a`).
5. When the download finishes, go to **Downloads** in Aurora Store, tap
   Minecraft and choose **Export**.
6. Open AntiSplit M, tap **Select split APK to merge**, choose the exported
   file and wait. You now have a single `.apk`.

If the account does not own Minecraft, the download will not work.

---

## Method 2 — mcbedrock-get (Windows PC)

**mcbedrock-get** is a third-party Windows helper (not part of this project)
that downloads Minecraft from Google Play with your own account, using
minecraft-linux's `gplaydl`.

- Download: https://github.com/DankMiimer/mcbedrock-get/releases/latest
- It installs Ubuntu inside Windows (WSL) and builds `gplaydl`
  (about 2 GB of disk space). Read its own instructions before using it.

1. Run `mcbedrock-get.exe` and follow its setup step.
2. Sign in on Google's page with the **Google account that bought
   Minecraft**.
3. Choose the architecture (`armeabi-v7a` or `arm64-v8a`) and the version.
4. It downloads a set of split APK files. Copy them to an Android device and
   merge them into a single `.apk` with **AntiSplit M** (put all files of the
   set in one `.zip` and select it as the split APK to merge).

Support for this tool is provided by its own author, not by this project.

---

## Method 3 — Backup from your own Android phone

Use this if Minecraft is already installed on your phone from Google Play.

- You get **only the version currently installed on the phone**. To get a
  different version you need Method 1 or 2.
- You get **only the architecture of your phone** (almost always
  `arm64-v8a`; some phones also include `armeabi-v7a`). If your console
  runs a 32-bit firmware and the backup has no `armeabi-v7a`, use Method 1
  or 2.
- Google Play installs Minecraft as a **split APK** (a base APK plus separate
  parts). The port needs a single APK, so the parts must be merged.

### With an app (no PC)

1. Install an APK backup app that supports split APKs (for example
   *SAI* or *ML Manager*).
2. Back up **Minecraft**. You will get an `.apks` / `.xapk` / `.zip` file.
3. Install **AntiSplit M**, tap **Select split APK to merge**, choose the
   backup file and wait. You now have a single `.apk`.

### With ADB (PC)

```
adb shell pm path com.mojang.minecraftpe
```

Pull every path listed (base APK and all `split_*.apk` files):

```
adb pull /data/app/.../base.apk
adb pull /data/app/.../split_config.arm64_v8a.apk
```

Then merge them into a single APK with **AntiSplit M** (or another split
APK merger).

---

## Installing the APK in the port

1. Copy the `.apk` into `mcpe_launcher/Setup Apk/` on the console.
   The file name becomes the version name shown in the menu.
2. Start **McpeLauncher** from the Ports menu, choose **Setup Apk** and
   select the APK.
3. Wait for the extraction to finish; the version then appears in the main
   list.

---

## Troubleshooting

- **The APK is not accepted / no libraries found:** the file is probably a
  single part of a split APK. Merge all parts with AntiSplit M first.
- **Wrong architecture:** a 32-bit firmware needs an `armeabi-v7a` APK.
- **The download says the app must be purchased:** you are signed in with an
  account that does not own Minecraft.

Do not share APKs or attach them to issues. See
[CONTRIBUTING.md](CONTRIBUTING.md).
