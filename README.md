# F1 Race Engineer

A voice race-engineer app for **F1 26** — live tyre, ERS, fuel, strategy and weather calls from the
game's telemetry, plus a Discord-linked driver community with XP and a leaderboard.

> **Beta.** Windows 10/11 only. Invite-only while it's in testing.

## Install (or update)

Paste this into **Win + R** (or any PowerShell window) and press Enter:

```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/install.ps1 | iex"
```

It downloads the latest build (~68 MB, self-contained — no .NET install needed), unpacks it to
`%LOCALAPPDATA%\Programs\F1RaceEngineer`, adds Start-Menu + Desktop shortcuts, and launches.
**Re-run the same line any time to update** — though once installed, the app can also update itself
from **Settings → Check for updates**.

## First run

1. **SmartScreen**: the app isn't code-signed yet, so Windows may show *"Windows protected your
   PC"* → click **More info → Run anyway**. Normal for a beta.
2. Open the **Discord** page → **Sign in with Discord**.
3. Copy **your join key** and paste it into the server's verify channel to get your Verified Driver
   role. The key is tied to your PC and reserved to your Discord account.

## What's in this repo

This is the **distribution + auto-update** repo only — just the installer script and the released
builds. The app source lives elsewhere.

- [`install.ps1`](install.ps1) — the installer/updater the one-liner runs.
- [Releases](../../releases) — each tagged build with `F1RaceEngineer.zip` attached. The app checks
  the newest release to offer in-app updates.
