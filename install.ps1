# F1 Race Engineer - installer.
# Run from Win+R or PowerShell:
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/TrulyAsleep/F1RaceEngineer-dist/main/install.ps1 | iex"
# Re-run any time to update to the newest release on your branch.
#   Live (default): the newest tagged release.
#   Beta:           set $env:F1RE_BRANCH = 'beta' first - the newest build, prereleases included.
# It never downgrades: a newer install is left alone unless $env:F1RE_FORCE = '1'.
#
# This is the source copy (installer\install.ps1 in the app repo). The served copy is
# dist\install.ps1 here and install.ps1 on the dist repo's main branch: copy this file
# over both when it changes, or the one-liner keeps running the old one.

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
if ($ver -and (Test-Path -LiteralPath $AppExe) -and -not $env:F1RE_FORCE) {
  try {
    $have = [version](Get-Item -LiteralPath $AppExe).VersionInfo.FileVersion
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
Write-Host ('  Downloading ' + $(if ($ver) { 'v' + $ver } else { 'the newest release' }) + ' (about 60 MB)...')
Invoke-WebRequest -Uri $ZipUrl -OutFile $tmp -UseBasicParsing

# 5. Install into %LOCALAPPDATA%\Programs\F1RaceEngineer. The release layout is one exe
#    plus Dashboard\, Plugins\, SimHubPlugin\ and release.trulyasleep, nothing else.
#    Same order as the in-app updater's swap script (Core's UpdateScript, the one list):
#    the zip is extracted to a stage folder FIRST, so a bad download changes nothing;
#    only when the exe is in the stage does the old install get cleared - the whole
#    folder if it will go, and then, for a file the wipe could not take (something still
#    holding it), the block that clears everything an older loose-layout install (0.3.0:
#    246 runtime DLLs, json, pdb, xml, createdump.exe, runtimes\ and 13 language folders
#    in the install root) could have left - and the stage is copied over what remains.
#    Every path is taken literally (-LiteralPath, .NET calls, items piped by their own
#    path): the install folder sits under the user profile, and a user name with [ ] in
#    it turns a -Path into a wildcard that matches nothing (Expand-Archive and New-Item
#    then fail outright), which is how the old script could wipe and not reinstall.
$stage = Join-Path $env:TEMP ('f1re_stage_' + [guid]::NewGuid().ToString('N'))
Write-Host '  Extracting...'
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($tmp, $stage)
Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath (Join-Path $stage 'F1RaceEngineer.App.exe'))) {
  Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
  throw 'The download is not a F1 Race Engineer release (no F1RaceEngineer.App.exe inside) - nothing was changed.'
}
if (Test-Path -LiteralPath $Install) { Remove-Item -LiteralPath $Install -Recurse -Force -ErrorAction SilentlyContinue }
[System.IO.Directory]::CreateDirectory($Install) | Out-Null
# Clear what an older loose-layout install left behind (the single-file layout has none of these).
foreach ($f in '*.dll','*.json','*.pdb','*.xml','createdump.exe') {
  Get-ChildItem -LiteralPath $Install -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $f } | Remove-Item -Force -ErrorAction SilentlyContinue
}
foreach ($d in 'runtimes','cs','de','es','fr','it','ja','ko','pl','pt-BR','ru','tr','zh-Hans','zh-Hant') {
  Remove-Item -LiteralPath (Join-Path $Install $d) -Recurse -Force -ErrorAction SilentlyContinue
}
# The manifest lists the plugins this version ships and the loader refuses any other: replace the set whole.
Get-ChildItem -LiteralPath (Join-Path $Install 'Plugins') -Filter *.dll -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
# The wizard installer's Apps & features entry points at an uninstaller that lives in
# that folder - drop the entry so only this install's remains.
Remove-Item -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{8E9C4B21-5A7D-4E3F-9B12-A1C3D5E7F901}_is1' -Recurse -Force -ErrorAction SilentlyContinue
# Items piped from Get-ChildItem copy by their literal path; a folder copied onto an existing one merges.
Get-ChildItem -LiteralPath $stage -Force | Copy-Item -Destination $Install -Recurse -Force
Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue

if (-not (Test-Path -LiteralPath $AppExe)) { throw ('Install looks incomplete - ' + $AppExe + ' is missing.') }

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
try { $exeVer = (Get-Item -LiteralPath $AppExe).VersionInfo.ProductVersion; if ($exeVer) { $ver = $exeVer.Trim() } } catch { }

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
