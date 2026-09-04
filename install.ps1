# F1 Race Engineer - installer.
# Run from Win+R or PowerShell:
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/install.ps1 | iex"
# Re-run any time to update to the newest release on your branch.
#   Live (default): the newest tagged release.
#   Beta:           set $env:F1RE_BRANCH = 'beta' first - the newest build, prereleases included.
# It never downgrades: a newer install is left alone unless $env:F1RE_FORCE = '1'.

$ErrorActionPreference = 'Stop'

$Repo    = 'TrulyAsleep/F1RaceEngineer-dist'
$Branch  = if ($env:F1RE_BRANCH -and $env:F1RE_BRANCH.ToLower() -eq 'beta') { 'beta' } else { 'live' }
$Install = Join-Path $env:LOCALAPPDATA 'Programs\F1RaceEngineer'
$AppExe  = Join-Path $Install 'F1RaceEngineer.App.exe'
$Api     = @{ 'User-Agent' = 'F1RE-install'; 'Accept' = 'application/vnd.github+json' }

Write-Host ''
Write-Host ("  F1 RACE ENGINEER - installing (" + $Branch + " branch)") -ForegroundColor Cyan
Write-Host ''

# 1. Resolve the release. GitHub's "latest" hides prereleases, which is exactly the
#    Live rule; Beta walks the list (newest first) for the first non-draft release.
$ZipUrl = 'https://github.com/' + $Repo + '/releases/latest/download/F1RaceEngineer.zip'
$ver = ''
try {
  if ($Branch -eq 'beta') {
    $rel = (Invoke-RestMethod ('https://api.github.com/repos/' + $Repo + '/releases?per_page=30') -Headers $Api) |
      Where-Object { -not $_.draft } | Select-Object -First 1
  } else {
    $rel = Invoke-RestMethod ('https://api.github.com/repos/' + $Repo + '/releases/latest') -Headers $Api
  }
  if ($rel) {
    $ver = $rel.tag_name.TrimStart('v','V')
    $zip = $rel.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
    if ($zip) { $ZipUrl = $zip.browser_download_url }
  }
} catch {
  if ($Branch -eq 'beta') { throw 'Could not list releases for the beta branch - try again in a minute.' }
}

# 2. Never downgrade. FileVersion is the numeric core of the version, which is all a
#    downgrade check needs (a beta of the NEXT version still counts as newer).
if ($ver -and (Test-Path $AppExe) -and -not $env:F1RE_FORCE) {
  try {
    $have = [version](Get-Item $AppExe).VersionInfo.FileVersion
    $want = [version](($ver -split '-')[0] + '.0')
    if ($have -gt $want) {
      Write-Host ("  Installed " + $have + " is newer than the " + $Branch + " release " + $ver + " - keeping it.") -ForegroundColor Yellow
      Write-Host "  (Set `$env:F1RE_FORCE = '1' to reinstall anyway, or `$env:F1RE_BRANCH = 'beta' for the newest build.)"
      Write-Host ''
      return
    }
  } catch { }
}

# 3. Close a running copy so its files are not locked.
Get-Process F1RaceEngineer.App -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 600

# 4. Download the app (self-contained - no .NET install needed).
$tmp = Join-Path $env:TEMP ('f1re_' + [guid]::NewGuid().ToString('N') + '.zip')
Write-Host ('  Downloading ' + $(if ($ver) { 'v' + $ver } else { 'the newest release' }) + ' (about 70 MB)...')
Invoke-WebRequest -Uri $ZipUrl -OutFile $tmp -UseBasicParsing

# 5. Fresh install into %LOCALAPPDATA%\Programs\F1RaceEngineer.
if (Test-Path $Install) { Remove-Item $Install -Recurse -Force }
# The wizard installer's Apps & features entry points at an uninstaller that lives in
# that folder - drop the entry so only this install's remains.
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{8E9C4B21-5A7D-4E3F-9B12-A1C3D5E7F901}_is1' -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $Install | Out-Null
Write-Host '  Extracting...'
Expand-Archive -Path $tmp -DestinationPath $Install -Force
Remove-Item $tmp -Force

if (-not (Test-Path $AppExe)) { throw ('Install looks incomplete - ' + $AppExe + ' is missing.') }

# 6. Start Menu + Desktop shortcuts.
$shell = New-Object -ComObject WScript.Shell
foreach ($dir in @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))) {
  $lnk = $shell.CreateShortcut((Join-Path $dir 'F1 Race Engineer.lnk'))
  $lnk.TargetPath       = $AppExe
  $lnk.WorkingDirectory = $Install
  $lnk.Description       = 'F1 Race Engineer'
  $lnk.Save()
}

# 7. Register an uninstaller: a Start Menu "Uninstall" shortcut + a Windows
#    "Apps & features" entry (so it can also be removed from Settings). Both run
#    the uninstall one-liner.
$psExe        = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$UninstallArg = '-NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/uninstall.ps1 | iex"'

$ulnk = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) 'Uninstall F1 Race Engineer.lnk'))
$ulnk.TargetPath       = $psExe
$ulnk.Arguments        = $UninstallArg
$ulnk.WorkingDirectory = $Install
$ulnk.Description       = 'Uninstall F1 Race Engineer'
$ulnk.Save()

# The exe carries the version the app itself reports; prefer it over the tag.
try { $exeVer = (Get-Item $AppExe).VersionInfo.ProductVersion; if ($exeVer) { $ver = $exeVer.Trim() } } catch { }

$reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\F1RaceEngineer'
New-Item -Path $reg -Force | Out-Null
New-ItemProperty -Path $reg -Name 'DisplayName'     -Value 'F1 Race Engineer'             -Force | Out-Null
New-ItemProperty -Path $reg -Name 'Publisher'       -Value 'F1 Race Engineer'             -Force | Out-Null
New-ItemProperty -Path $reg -Name 'DisplayIcon'     -Value $AppExe                        -Force | Out-Null
New-ItemProperty -Path $reg -Name 'InstallLocation' -Value $Install                       -Force | Out-Null
New-ItemProperty -Path $reg -Name 'UninstallString' -Value ($psExe + ' ' + $UninstallArg) -Force | Out-Null
New-ItemProperty -Path $reg -Name 'NoModify' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $reg -Name 'NoRepair' -PropertyType DWord -Value 1 -Force | Out-Null
if ($ver) { New-ItemProperty -Path $reg -Name 'DisplayVersion' -Value $ver -Force | Out-Null }

Write-Host ''
Write-Host '  Done - launching F1 Race Engineer.' -ForegroundColor Green
Write-Host '  (Also on your Start Menu and Desktop as "F1 Race Engineer".)'
Write-Host ''
Start-Process $AppExe
