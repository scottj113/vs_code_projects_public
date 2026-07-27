# Packages distro/ into a zip ready to email, upload, or attach to a release.
#
#   .\tools\Build-Distro.ps1              # verify + zip to the project folder
#   .\tools\Build-Distro.ps1 -Verify      # verify only, write nothing
#   .\tools\Build-Distro.ps1 -Out C:\tmp  # zip somewhere else
#
# There is no build step -- distro/ holds the actual files that ship, so this
# only checks and compresses. The check matters: the package must contain
# nothing executable, because the people most likely to need this tool are on
# locked-down machines where a .cmd or .ps1 is stripped by an email gateway or
# blocked by policy once Mark-of-the-Web is on it.
#
# PowerShell only. No node, no npm.

[CmdletBinding()]
param(
  [string] $Out,
  [switch] $Verify
)

$ErrorActionPreference = 'Stop'
$proj   = Split-Path -Parent $PSScriptRoot
$distro = Join-Path $proj 'distro'
if (-not $Out) { $Out = $proj }

$expected = @(
  'md_to_html_viewer.html'
  'README.md'
  'LICENSE'
  'vendor\mermaid.min.js'
)
# Launcher types: a mail gateway strips these, and Windows runs them on a
# double-click. ".js" is deliberately NOT here -- vendor/mermaid.min.js is a
# web asset the page loads, not something anyone launches -- but it is
# confined to vendor/ below so a stray script cannot sneak in as one.
$launcher = '\.(cmd|bat|ps1|psm1|exe|com|scr|vbs|vbe|jse|wsf|wsh|msi|msp|lnk|reg|hta|jar|pif)$'

$files = Get-ChildItem $distro -Recurse -File
$rel = @($files | ForEach-Object { $_.FullName.Substring($distro.Length + 1) })

$problems = @()
foreach ($want in $expected) {
  if ($rel -notcontains $want) { $problems += "missing: $want" }
}
foreach ($r in $rel) {
  if ($r -match $launcher) { $problems += "LAUNCHER IN PACKAGE: $r" }
  if ($r -match '\.js$' -and $r -notlike 'vendor\*') {
    $problems += "loose .js outside vendor/: $r"
  }
}
foreach ($e in ($rel | Where-Object { $expected -notcontains $_ })) {
  $problems += "unexpected file: $e"
}

'contents:'
foreach ($r in ($rel | Sort-Object)) {
  $size = ($files | Where-Object { $_.FullName.EndsWith($r) } | Select-Object -First 1).Length
  '  {0,-28} {1,10:N0} bytes' -f $r, $size
}

# The viewer must not reference anything outside the package. Inline script
# BODIES are stripped first, keeping the opening tags so <script src=...> is
# still seen: the app's own JavaScript builds HTML by concatenation, and those
# fragments look exactly like real src="..." attributes to a regex.
$html = [IO.File]::ReadAllText((Join-Path $distro 'md_to_html_viewer.html'))
$markup = [regex]::Replace($html, '(?s)(<script\b[^>]*>).*?(</script>)', '$1$2')

# Written by open-md.cmd or the VS Code task at run time, into a staging copy.
# Its absence here is intentional -- the tag carries an onerror guard.
$optional = @('md-bootstrap.js')

$srcs = @([regex]::Matches($markup, '(?:src|href)="([^"]+)"') |
  ForEach-Object { $_.Groups[1].Value } |
  Where-Object { $_ -notmatch '^(data:|#|https?:|mailto:)' } |
  Sort-Object -Unique)
''
'package references:'
if ($srcs) {
  foreach ($s in $srcs) {
    $target = Join-Path $distro ($s -replace '/', '\')
    $state = if (Test-Path $target) { 'bundled' }
             elseif ($optional -contains $s) { 'optional, created at run time' }
             else { $problems += "reference not in package: $s"; 'MISSING' }
    '  {0,-24} {1}' -f $s, $state
  }
} else { '  (none)' }

''
if ($problems.Count) {
  "FAILED ($($problems.Count)):"
  $problems | ForEach-Object { "  $_" }
  exit 1
}
'OK - package is self-contained and contains nothing executable'

if ($Verify) { ''; 'Verify only; no zip written.'; exit 0 }

$zip = Join-Path $Out 'md_to_html_viewer.zip'
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $distro '*') -DestinationPath $zip
''
'wrote {0} ({1:N0} bytes)' -f $zip, (Get-Item $zip).Length
