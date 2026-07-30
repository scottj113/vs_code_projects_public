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

# Embed bootstrap data in HTML before the closing body tag
$bootstrapScript = @"
<script>
window.__MD_BOOTSTRAP__ = $bootstrapJson;
</script>
</body>
</html>
"@

$html = $html -replace '</body>\s*</html>\s*$', $bootstrapScript

# Write temp HTML file
$tempHtml = Join-Path $tempDir "view.html"
Set-Content -Path $tempHtml -Value $html -Encoding UTF8

# Open in default browser
Start-Process $tempHtml
