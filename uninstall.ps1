# F1 Race Engineer - uninstaller.
# Run from Win+R or a PowerShell window:
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/uninstall.ps1 | iex"
#
# Removes the app + shortcuts. Your settings, Discord sign-in and join key are KEPT
# unless you download this script and run it with the  -PurgeData  switch.

param([switch]$PurgeData)

$ErrorActionPreference = 'Stop'

$Install = Join-Path $env:LOCALAPPDATA 'Programs\F1RaceEngineer'
$Data    = Join-Path $env:LOCALAPPDATA 'F1RaceEngineer'

Write-Host ''
Write-Host '  F1 RACE ENGINEER - uninstalling' -ForegroundColor Cyan
Write-Host ''

# 1. Close a running copy so its files are not locked.
Get-Process F1RaceEngineer.App -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 600

# 2. Remove the program files.
if (Test-Path $Install) {
  Remove-Item $Install -Recurse -Force
  Write-Host '  Removed program files.'
} else {
  Write-Host ('  No install found at ' + $Install)
}

# 3. Remove Start Menu + Desktop shortcuts (both the app and the uninstall link).
foreach ($dir in @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))) {
  foreach ($name in @('F1 Race Engineer.lnk', 'Uninstall F1 Race Engineer.lnk')) {
    $lnk = Join-Path $dir $name
    if (Test-Path $lnk) { Remove-Item $lnk -Force -ErrorAction SilentlyContinue }
  }
}
Write-Host '  Removed shortcuts.'

# 4. Remove any "Apps & features" entries for this app (the one-liner install's own
#    entry and, if present, a setup.exe / Inno entry - matched by display name).
$uninstBase = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
Get-ChildItem $uninstBase -ErrorAction SilentlyContinue | ForEach-Object {
  $dn = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).DisplayName
  if ($dn -eq 'F1 Race Engineer') { Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue }
}

# 5. User data - kept unless -PurgeData was passed.
if ($PurgeData) {
  if (Test-Path $Data) {
    Remove-Item $Data -Recurse -Force
    Write-Host '  Removed your settings, Discord sign-in and join key.' -ForegroundColor Yellow
  }
} elseif (Test-Path $Data) {
  Write-Host ''
  Write-Host '  Your settings, Discord sign-in and join key were kept at:' -ForegroundColor DarkGray
  Write-Host ('    ' + $Data) -ForegroundColor DarkGray
  Write-Host '  To remove those too, download this script and run:  .\uninstall.ps1 -PurgeData' -ForegroundColor DarkGray
}

Write-Host ''
Write-Host '  Done - F1 Race Engineer has been uninstalled.' -ForegroundColor Green
Write-Host ''
