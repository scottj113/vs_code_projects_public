# Loads md_to_html_viewer.html in headless Edge with a probe script injected,
# then returns whatever the probe wrote into <pre id="probe">.
#
# Everything runs inside a real browser page, so assertions see real computed
# styles and real DOM behaviour rather than a simulation.
#
# PowerShell + Edge only. No node, no npm.

[CmdletBinding()]
param(
  [Parameter(Mandatory)][string] $Harness,    # HTML/JS injected before </body>
  [string] $Markdown,                          # optional doc, delivered via #md64
  [string] $DocName = 'fixture.md',            # filename the payload declares
  [string] $Name = 'probe',                    # staging dir suffix
  [int]    $BudgetMs = 45000,
  [string[]] $BrowserArgs = @()                # extra Chromium switches
)

$ErrorActionPreference = 'Stop'

$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) {
  $alt = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
  if (Test-Path $alt) { $edge = $alt } else { throw 'No Chromium browser found' }
}

# The shippable package; the viewer has no build step, so this is both the
# source and what gets distributed.
$proj  = Join-Path (Split-Path -Parent $PSScriptRoot) 'distro'
$stage = Join-Path $env:TEMP "mdv-$Name"
$null  = New-Item -ItemType Directory -Force -Path (Join-Path $stage 'vendor')
Copy-Item (Join-Path $proj 'vendor\mermaid.min.js') (Join-Path $stage 'vendor\mermaid.min.js') -Force

# Inject before the LAST </body>. exportHtml() builds a page string containing a
# literal </body>, so matching the first one drops the harness into the middle
# of the app's own JavaScript and the page silently half-loads.
$html  = [IO.File]::ReadAllText((Join-Path $proj 'md_to_html_viewer.html'))
$close = $html.LastIndexOf('</body>')
if ($close -lt 0) { throw 'no closing body tag' }
$page = Join-Path $stage 'page.html'
[IO.File]::WriteAllText($page,
  $html.Substring(0, $close) + $Harness + $html.Substring($close),
  (New-Object Text.UTF8Encoding($false)))

$url = 'file:///' + ($page -replace '\\', '/')
if ($Markdown) {
  $url += '#name=' + [Uri]::EscapeDataString($DocName) +
          '&md64=' + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Markdown))
}

$dump = Join-Path $stage 'dump.html'
$noise = Join-Path $stage 'stderr.txt'

# A run that was interrupted leaves an Edge process holding this profile, and
# the next launch then blocks on the lock forever rather than failing -- an
# afternoon disappears into "the popup test hangs" when nothing is wrong with
# the test. Start from a clean profile every time.
$profileDir = Join-Path $env:TEMP "mdv-$Name-profile"
Remove-Item -Recurse -Force $profileDir -ErrorAction SilentlyContinue

# Start-Process rather than the call operator, for two reasons: stderr goes
# straight to a file, so Windows PowerShell never turns Edge's unrelated GPU
# and profile chatter into ErrorRecords; and the wait can be bounded, so a
# browser that never exits is a failed run instead of a hung one.
$edgeArgs = @(
  '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
  "--user-data-dir=$profileDir", "--virtual-time-budget=$BudgetMs"
) + $BrowserArgs + @('--dump-dom', $url)

$proc = Start-Process -FilePath $edge -ArgumentList $edgeArgs -PassThru -NoNewWindow `
                      -RedirectStandardOutput $dump -RedirectStandardError $noise
# The virtual-time budget is virtual; this ceiling is wall-clock, and only has
# to be generous enough that a healthy run never reaches it.
if (-not $proc.WaitForExit(120000)) {
  try { $proc.Kill() } catch { }
  return "browser did not exit within 120s (dump: $dump)"
}
# WaitForExit(timeout) returns as soon as the process ends, while the redirected
# streams may still be flushing -- reading the dump then fails with a sharing
# violation. The parameterless overload is the one that waits for the handles.
$proc.WaitForExit()

# Chromium's renderer and GPU children inherit the redirected stdout handle and
# outlive the parent by a moment, so ReadAllText hits a sharing violation. The
# dump is complete once the parent exits -- open it in a way that doesn't demand
# exclusive access rather than sleeping and hoping.
$fs = New-Object IO.FileStream($dump, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
try {
  $reader = New-Object IO.StreamReader($fs, [Text.Encoding]::UTF8, $true)
  $dom = $reader.ReadToEnd()
} finally {
  $fs.Dispose()
}

# Do NOT slice the dump at "<body": the mermaid bundle's minified text contains
# that string. The probe element is matched directly instead.
$m = [regex]::Match($dom, '(?s)<pre id="probe">(.*?)</pre>')
if (-not $m.Success) { return "probe element not found (dump: $dump)" }
$text = $m.Groups[1].Value.Trim()
if (-not $text) { return "probe present but EMPTY - harness never ran (dump: $dump)" }
return $text
