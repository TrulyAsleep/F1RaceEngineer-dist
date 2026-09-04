# F1 Race Engineer

A voice race-engineer app for **F1 26** (F1 25 + 2026 Season) — strategy, tyre, ERS, fuel and gap
calls made live from the game's telemetry, a live dashboard and lap review, plus a Discord-linked
driver community with XP and a leaderboard. Windows 10/11 only.

## Install (or update)

**Option A — one-liner.** Paste this into **Win + R** (or any PowerShell window) and press Enter:

```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/install.ps1 | iex"
```

**Option B — wizard.** Download **`F1RaceEngineerSetup.exe`** from the [latest release](../../releases/latest)
and run it.

Both install to `%LOCALAPPDATA%\Programs\F1RaceEngineer` (no admin needed) and add Start-Menu +
Desktop shortcuts. The download is ~70 MB, self-contained — **no .NET install required**. Re-run the
one-liner (or a newer setup.exe) to update; once installed, the app can also update itself from
**Settings → General → Check for updates**.

**Beta builds.** Beta access is by signup on the Discord. To install the newest beta with the
one-liner, set the branch first (in the same PowerShell window):

```
$env:F1RE_BRANCH = 'beta'
```

The one-liner never downgrades a newer install; set `$env:F1RE_FORCE = '1'` to reinstall anyway.
Inside the app, Settings → General shows the version and lets a Verified Driver switch between the
Live and Beta update branches.

## First run

1. **SmartScreen**: the app isn't code-signed yet, so Windows may show *"Windows protected your
   PC"* → click **More info → Run anyway**.
2. The first-run setup asks for the telemetry port, a voice and volume. In the game: Settings →
   Telemetry → UDP Telemetry **ON**, port **20777** (the default).
3. Open the **Discord** page → **Sign in with Discord**, then copy **your join key** and paste it
   into the server's verify channel to get your Verified Driver role. The key is tied to your PC
   and reserved to your Discord account.

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
  `F1RaceEngineerSetup.exe` (wizard installer) attached. Prereleases are beta builds.
