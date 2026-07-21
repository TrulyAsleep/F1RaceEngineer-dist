# F1 Race Engineer - beta installer.
# Run from Win+R or PowerShell:
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/install.ps1 | iex"
# Re-run any time to update to the latest release.

$ErrorActionPreference = 'Stop'

# --- always points at the newest release; no editing needed -----------------
$ZipUrl  = 'https://github.com/TrulyAsleep/F1RaceEngineer-dist/releases/latest/download/F1RaceEngineer.zip'
# ----------------------------------------------------------------------------

$Install = Join-Path $env:LOCALAPPDATA 'Programs\F1RaceEngineer'
$AppExe  = Join-Path $Install 'F1RaceEngineer.App.exe'

Write-Host ''
Write-Host '  F1 RACE ENGINEER - installing' -ForegroundColor Cyan
Write-Host ''

# 1. Close a running copy so its files are not locked.
Get-Process F1RaceEngineer.App -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 600

# 2. Download the app (self-contained - no .NET install needed).
$tmp = Join-Path $env:TEMP ('f1re_' + [guid]::NewGuid().ToString('N') + '.zip')
Write-Host '  Downloading (about 68 MB)...'
Invoke-WebRequest -Uri $ZipUrl -OutFile $tmp -UseBasicParsing

# 3. Fresh install into %LOCALAPPDATA%\Programs\F1RaceEngineer.
if (Test-Path $Install) { Remove-Item $Install -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Install | Out-Null
Write-Host '  Extracting...'
Expand-Archive -Path $tmp -DestinationPath $Install -Force
Remove-Item $tmp -Force

if (-not (Test-Path $AppExe)) { throw ('Install looks incomplete - ' + $AppExe + ' is missing.') }

# 4. Start Menu + Desktop shortcuts.
$shell = New-Object -ComObject WScript.Shell
foreach ($dir in @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))) {
  $lnk = $shell.CreateShortcut((Join-Path $dir 'F1 Race Engineer.lnk'))
  $lnk.TargetPath       = $AppExe
  $lnk.WorkingDirectory = $Install
  $lnk.Description       = 'F1 Race Engineer'
  $lnk.Save()
}

Write-Host ''
Write-Host '  Done - launching F1 Race Engineer.' -ForegroundColor Green
Write-Host '  (Also on your Start Menu and Desktop as "F1 Race Engineer".)'
Write-Host ''
Start-Process $AppExe
