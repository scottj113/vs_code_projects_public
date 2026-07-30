# Open markdown file in Eye Love Markdown Viewer with editing support
# This script embeds the file content directly in the HTML to avoid browser security restrictions

param(
    [Parameter(Mandatory=$true)]
    [string]$filePath,
    [string]$workspaceFolder
)

# Resolve absolute path
$filePath = Resolve-Path $filePath
$fileName = Split-Path -Leaf $filePath
$fileContent = Get-Content -Path $filePath -Raw -Encoding UTF8

# Find the viewer HTML (probe both the workspace and its parent)
$candidates = @(
    (Join-Path $workspaceFolder "distro\md_to_html_viewer.html"),
    (Join-Path $workspaceFolder "md_to_html_viewer\distro\md_to_html_viewer.html")
)
$viewerHtml = $null
foreach ($path in $candidates) {
    if (Test-Path $path) {
        $viewerHtml = $path
        break
    }
}

if (-not $viewerHtml) {
    Write-Host "Error: Could not find md_to_html_viewer.html in $workspaceFolder or $($candidates[1])" -ForegroundColor Red
    exit 1
}

# Create temp directory
$tempDir = Join-Path $env:TEMP "md_to_html_viewer"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Copy vendor files (Mermaid, etc.) if they exist
$vendorSource = Join-Path (Split-Path -Parent $viewerHtml) "vendor"
if (Test-Path $vendorSource) {
    $vendorDest = Join-Path $tempDir "vendor"
    if (-not (Test-Path $vendorDest)) {
        New-Item -ItemType Directory -Path $vendorDest | Out-Null
    }
    Get-ChildItem -Path $vendorSource -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $vendorDest $_.Name) -Force
    }
}

# Read the viewer HTML
$html = Get-Content -Path $viewerHtml -Raw -Encoding UTF8

# Manually build JSON to avoid PowerShell 5.1's ConvertTo-Json performance issues
# with large strings. All escaping is done safely.
function EscapeJsonString($str) {
    $str = $str -replace '\\', '\\'  # Backslash first
    $str = $str -replace '"', '\"'   # Quotes
    $str = $str -replace "`r`n", '\n'  # Windows newlines
    $str = $str -replace "`r", '\n'    # Mac newlines
    $str = $str -replace "`n", '\n'    # Unix newlines
    $str = $str -replace "`t", '\t'    # Tabs
    return $str
}

$bootstrapJson = @"
{
  "name": "$(EscapeJsonString $fileName)",
  "path": "$(EscapeJsonString $filePath)",
  "text": "$(EscapeJsonString $fileContent)",
  "autoConnect": false
}
"@

# Embed bootstrap data right after <body> opens (before boot function runs)
# This ensures window.__MD_BOOTSTRAP__ is set before the boot() function executes
$bodyStart = $html.IndexOf("<body")
$bodyEnd = $html.IndexOf(">", $bodyStart) + 1

if ($bodyStart -ge 0 -and $bodyEnd -gt $bodyStart) {
    $bootstrapScript = @"

<script>
window.__MD_BOOTSTRAP__ = $bootstrapJson;
</script>

"@
    $html = $html.Substring(0, $bodyEnd) + $bootstrapScript + $html.Substring($bodyEnd)
} else {
    Write-Host "Error: Could not find <body> tag in HTML" -ForegroundColor Red
    exit 1
}

# Write temp HTML file
$tempHtml = Join-Path $tempDir "view.html"
Set-Content -Path $tempHtml -Value $html -Encoding UTF8

# Open in default browser
try {
    Start-Process $tempHtml -ErrorAction Stop
} catch {
    # If Start-Process fails (e.g., no default browser), try via cmd
    try {
        cmd /c start `"$tempHtml`"
    } catch {
        Write-Host "Could not open browser. Open manually: $tempHtml" -ForegroundColor Yellow
    }
}

exit 0
