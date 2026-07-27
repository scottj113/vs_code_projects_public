@echo off
REM ---------------------------------------------------------------------------
REM  open-md.cmd  <file.md>
REM
REM  Opens a markdown file in md_to_html_viewer.html with no web server.
REM
REM  Browsers refuse to fetch() a local file from a file:// page, so we stage a
REM  copy of the viewer in %TEMP% next to a generated md-bootstrap.js sidecar.
REM  A classic <script src="..."> DOES load over file://, so the viewer picks
REM  the document up on load. No size limit, unlike a #hash payload.
REM
REM  Set it as the "Open with" target for .md files, or just drag a file onto it.
REM
REM  Uses nothing but Windows PowerShell -- no node, no npm.
REM
REM  Note: arguments are handed over as environment variables and the inline
REM  PowerShell avoids "|" entirely. Windows PowerShell's -Command swallows any
REM  trailing arguments instead of filling $args, and a "|" inside a caret-
REM  continued batch line reaches PowerShell as a literal "^|" parse error.
REM ---------------------------------------------------------------------------
setlocal

if "%~1"=="" (
  echo Usage: open-md.cmd ^<file.md^>
  echo   Or drag a .md file onto this script.
  exit /b 1
)
if not exist "%~f1" (
  echo Not found: %~f1
  exit /b 1
)

set "MDV_SRC=%~f1"
set "MDV_VIEWER=%~dp0..\distro\md_to_html_viewer.html"
set "MDV_VENDOR=%~dp0..\distro\vendor"
set "MDV_STAGE=%TEMP%\md_to_html_viewer"

if not exist "%MDV_VIEWER%" (
  echo Viewer not found next to this script: %MDV_VIEWER%
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$stage=$env:MDV_STAGE; $viewer=$env:MDV_VIEWER; $vendor=$env:MDV_VENDOR; $src=$env:MDV_SRC;" ^
  "$null = New-Item -ItemType Directory -Force -Path $stage;" ^
  "$dest = Join-Path $stage 'view.html';" ^
  "if (-not (Test-Path $dest) -or (Get-Item $viewer).LastWriteTimeUtc -gt (Get-Item $dest).LastWriteTimeUtc) { Copy-Item $viewer $dest -Force }" ^
  "if (Test-Path $vendor) {" ^
  "  $vd = Join-Path $stage 'vendor';" ^
  "  $null = New-Item -ItemType Directory -Force -Path $vd;" ^
  "  foreach ($f in Get-ChildItem $vendor -File) {" ^
  "    $t = Join-Path $vd $f.Name;" ^
  "    if (-not (Test-Path $t) -or $f.LastWriteTimeUtc -gt (Get-Item $t).LastWriteTimeUtc) { Copy-Item $f.FullName $t -Force }" ^
  "  }" ^
  "}" ^
  "$utf8 = New-Object Text.UTF8Encoding($false);" ^
  "$text = [IO.File]::ReadAllText($src, $utf8);" ^
  "$json = ConvertTo-Json -InputObject @{ name = (Split-Path $src -Leaf); path = $src; text = $text } -Compress -Depth 3;" ^
  "[IO.File]::WriteAllText((Join-Path $stage 'md-bootstrap.js'), ('window.__MD_BOOTSTRAP__=' + $json + ';'), $utf8);" ^
  "if ($env:MDV_NOLAUNCH -ne '1') { Start-Process $dest }"

if errorlevel 1 (
  echo Failed to open "%~f1".
  exit /b 1
)
endlocal
