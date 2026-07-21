# F1 Race Engineer

A voice race-engineer app for **F1 26** — live tyre, ERS, fuel, strategy and weather calls from the
game's telemetry, plus a Discord-linked driver community with XP and a leaderboard.

> **Beta.** Windows 10/11 only. Invite-only while it's in testing.

## Install (or update)

**Option A — one-liner.** Paste this into **Win + R** (or any PowerShell window) and press Enter:

```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/install.ps1 | iex"
```

**Option B — wizard.** Download **`F1RaceEngineerSetup.exe`** from the [latest release](../../releases/latest)
and run it.

Both install to `%LOCALAPPDATA%\Programs\F1RaceEngineer` (no admin needed) and add Start-Menu +
Desktop shortcuts. The download is ~68 MB, self-contained — **no .NET install required**. Re-run the
one-liner (or a newer setup.exe) to update; once installed, the app can also update itself from
**Settings → Check for updates**.

## First run

1. **SmartScreen**: the app isn't code-signed yet, so Windows may show *"Windows protected your
   PC"* → click **More info → Run anyway**. Normal for a beta.
2. Open the **Discord** page → **Sign in with Discord**.
3. Copy **your join key** and paste it into the server's verify channel to get your Verified Driver
   role. The key is tied to your PC and reserved to your Discord account.

## Uninstall

- **Windows Settings → Apps → Installed apps → F1 Race Engineer → Uninstall** (both install methods
  register here), or the **"Uninstall F1 Race Engineer"** Start-Menu shortcut.
- **Or the one-liner:**

  ```
  powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/uninstall.ps1 | iex"
  ```

Uninstalling **keeps** your settings, Discord sign-in and join key by default. The setup.exe
uninstaller asks whether to remove them too; the one-liner keeps them unless you download
`uninstall.ps1` and run it with `-PurgeData`.

## What's in this repo

This is the **distribution + auto-update** repo only — the installer scripts and the released builds.
The app source lives elsewhere.

- [`install.ps1`](install.ps1) — the installer/updater the one-liner runs.
- [`uninstall.ps1`](uninstall.ps1) — the uninstaller.
- [Releases](../../releases) — each tagged build with `F1RaceEngineer.zip` (self-contained app) and
  `F1RaceEngineerSetup.exe` (wizard installer) attached.
