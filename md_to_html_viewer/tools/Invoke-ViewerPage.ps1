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
  [int]    $BudgetMs = 45000
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
# Edge logs unrelated noise (profile sync, GPU) to stderr. In Windows
# PowerShell each stderr line becomes an ErrorRecord, which under
# ErrorActionPreference='Stop' would abort a perfectly good run -- so relax it
# just around the launch.
$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
  & $edge --headless=new --disable-gpu --no-first-run --no-default-browser-check `
          "--user-data-dir=$(Join-Path $env:TEMP "mdv-$Name-profile")" `
          "--virtual-time-budget=$BudgetMs" --dump-dom $url 2>$null |
    Out-File -FilePath $dump -Encoding utf8
} finally {
  $ErrorActionPreference = $prev
}

# Do NOT slice the dump at "<body": the mermaid bundle's minified text contains
# that string. The probe element is matched directly instead.
$dom = [IO.File]::ReadAllText($dump)
$m = [regex]::Match($dom, '(?s)<pre id="probe">(.*?)</pre>')
if (-not $m.Success) { return "probe element not found (dump: $dump)" }
$text = $m.Groups[1].Value.Trim()
if (-not $text) { return "probe present but EMPTY - harness never ran (dump: $dump)" }
return $text
