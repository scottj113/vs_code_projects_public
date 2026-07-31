# Generates and contrast-validates the 12 palettes, then writes them into
# northern-lights.html between the PALETTES markers.
#
#   light : white | beige        dark : blue | slate
#   levels: 1 lightest -> 3 darkest, within the chosen family
#
# Only the background ramps and the base hues below are hand-authored. Every
# value whose job is "stay readable against that background" -- fg, accent,
# border, border-strong, fg-faint and all nine syntax tokens -- is auto-tuned
# until it clears its contrast target. Hand-picking these produced 24 failures
# on the first attempt, so: validate, don't eyeball.
#
# PowerShell only. No node, no npm.
#
#   .\tools\Build-Palettes.ps1            # validate + report, write nothing
#   .\tools\Build-Palettes.ps1 -Write     # validate + inject into the viewer

[CmdletBinding()]
param(
  [switch] $Write
)

$ErrorActionPreference = 'Stop'
$viewer = Join-Path (Split-Path -Parent $PSScriptRoot) 'distro\northern-lights.html'

# ---------------------------------------------------------------- colour math
function ConvertFrom-Hex([string] $h) {
  if ($h -notmatch '^#[0-9a-fA-F]{6}$') { throw "bad hex: $h" }
  $n = [Convert]::ToInt32($h.Substring(1), 16)
  return @((($n -shr 16) -band 255), (($n -shr 8) -band 255), ($n -band 255))
}
function ConvertTo-Hex([int[]] $rgb) {
  $c = $rgb | ForEach-Object { [Math]::Max(0, [Math]::Min(255, $_)) }
  return '#{0:x2}{1:x2}{2:x2}' -f $c[0], $c[1], $c[2]
}
function Get-Channel([double] $c) {
  $c = $c / 255.0
  if ($c -le 0.03928) { return $c / 12.92 }
  return [Math]::Pow((($c + 0.055) / 1.055), 2.4)
}
function Get-Luminance([string] $h) {
  $rgb = ConvertFrom-Hex $h
  return 0.2126 * (Get-Channel $rgb[0]) + 0.7152 * (Get-Channel $rgb[1]) + 0.0722 * (Get-Channel $rgb[2])
}
function Get-Contrast([string] $a, [string] $b) {
  $x = Get-Luminance $a; $y = Get-Luminance $b
  if ($x -lt $y) { $t = $x; $x = $y; $y = $t }
  return ($x + 0.05) / ($y + 0.05)
}
# CIE L*: perceptual lightness. Only used to report how big the depth steps feel.
function Get-Lstar([string] $h) {
  $y = Get-Luminance $h
  if ($y -gt 0.008856) { return 116 * [Math]::Pow($y, 1.0/3.0) - 16 }
  return 903.3 * $y
}

# Walk a colour toward black or white until it clears $target against every bg.
function Resolve-Tuned([string] $colour, [string[]] $backgrounds, [double] $target) {
  $rgb = ConvertFrom-Hex $colour
  # Lighten if the colour already sits above its background, else darken.
  $lighten = (Get-Luminance $colour) -gt (Get-Luminance $backgrounds[0])
  for ($i = 0; $i -lt 160; $i++) {
    $cur = ConvertTo-Hex $rgb
    $ok = $true
    foreach ($bg in $backgrounds) { if ((Get-Contrast $cur $bg) -lt $target) { $ok = $false; break } }
    if ($ok) { return $cur }
    $step = if ($lighten) { 2 } else { -2 }
    # Each element MUST be parenthesised: PowerShell's comma binds tighter than
    # "+", so `a + $s, b + $s` parses as `a + ($s, b) + $s` and builds arrays.
    $rgb = @(($rgb[0] + $step), ($rgb[1] + $step), ($rgb[2] + $step))
    if ($rgb[0] -le 0 -and $rgb[1] -le 0 -and $rgb[2] -le 0) { break }
    if ($rgb[0] -ge 255 -and $rgb[1] -ge 255 -and $rgb[2] -ge 255) { break }
  }
  return ConvertTo-Hex $rgb
}

# ------------------------------------------------------------- authored input
$LightTokens = [ordered]@{
  'tok-com' = '#6b7684'; 'tok-str' = '#0f7038'; 'tok-num' = '#9a4a2c'
  'tok-kw'  = '#8a1fa0'; 'tok-bin' = '#1553ad'; 'tok-fn'  = '#6229b8'
  'tok-tag' = '#ab1f1f'; 'tok-atr' = '#8a4a22'; 'tok-pun' = '#525b66'
}
$DarkTokens = [ordered]@{
  'tok-com' = '#8792a0'; 'tok-str' = '#84cf9c'; 'tok-num' = '#e8a97f'
  'tok-kw'  = '#dda0ec'; 'tok-bin' = '#8fbaff'; 'tok-fn'  = '#c6abff'
  'tok-tag' = '#ff9f9f'; 'tok-atr' = '#e8c684'; 'tok-pun' = '#a3adb9'
}
$ShadowLight = '0 1px 2px rgba(16,22,26,.06), 0 8px 24px rgba(16,22,26,.10)'
$ShadowDark  = '0 1px 2px rgba(0,0,0,.40), 0 8px 24px rgba(0,0,0,.50)'
$FilterDim   = 'grayscale(.85) brightness(.86) contrast(1.06)'

# Backgrounds and base hues only. Everything else is derived above.
$Palettes = [ordered]@{
  'white-1' = @{ mode='light'; bg='#ffffff'; 'bg-sunk'='#fbfbfc'; 'bg-raised'='#ffffff'
    fg='#1b1f24'; 'fg-muted'='#59626d'; 'fg-faint'='#7b8590'
    border='#e2e5ea'; 'border-strong'='#c4cad2'; accent='#2f6feb'
    'accent-soft'='#e8f0fe'; 'code-bg'='#f5f6f8' }
  'white-2' = @{ mode='light'; bg='#f2f4f6'; 'bg-sunk'='#e8eaee'; 'bg-raised'='#f7f8fa'
    fg='#171b20'; 'fg-muted'='#4f5862'; 'fg-faint'='#6e7883'
    border='#cfd4db'; 'border-strong'='#aab2bc'; accent='#2963d4'
    'accent-soft'='#dbe6fa'; 'code-bg'='#e0e3e8' }
  'white-3' = @{ mode='light'; bg='#dde1e6'; 'bg-sunk'='#d0d5dc'; 'bg-raised'='#e7eaee'
    fg='#12161a'; 'fg-muted'='#454e58'; 'fg-faint'='#636c77'
    border='#b4bcc5'; 'border-strong'='#8f99a4'; accent='#22579f'
    'accent-soft'='#c6d4e9'; 'code-bg'='#c7cdd5' }

  # Beige rides on warm ivory neutrals: #F0EEE6 as the signature
  # ground, manilla beneath it, book-cloth terracotta for links.
  'beige-1' = @{ mode='light'; bg='#faf9f5'; 'bg-sunk'='#f5f3ec'; 'bg-raised'='#faf9f5'
    fg='#191917'; 'fg-muted'='#5c574c'; 'fg-faint'='#837c6d'
    border='#e6e2d5'; 'border-strong'='#cec7b4'; accent='#cc785c'
    'accent-soft'='#efe9dd'; 'code-bg'='#f0eee6' }
  'beige-2' = @{ mode='light'; bg='#f0eee6'; 'bg-sunk'='#e9e5d8'; 'bg-raised'='#f5f3ec'
    fg='#191917'; 'fg-muted'='#565144'; 'fg-faint'='#7b7364'
    border='#d8d1bd'; 'border-strong'='#bdb49b'; accent='#c06a4c'
    'accent-soft'='#e3dccb'; 'code-bg'='#e3dfd1' }
  'beige-3' = @{ mode='light'; bg='#e2ddcc'; 'bg-sunk'='#d9d2bc'; 'bg-raised'='#eae6d9'
    fg='#171612'; 'fg-muted'='#4c473b'; 'fg-faint'='#6c6555'
    border='#c2b99e'; 'border-strong'='#a49982'; accent='#b35d40'
    'accent-soft'='#cdc5ab'; 'code-bg'='#cfc7ae' }

  # Blue mirrors slate's depth ramp so the two dark families behave alike.
  # It used to bottom out near black (L* 1.5); lifting the darkest step meant
  # re-spacing the whole family, since blue-1 already sat at the old target.
  'blue-1' = @{ mode='dark'; bg='#2b3450'; 'bg-sunk'='#262f45'; 'bg-raised'='#323c58'
    fg='#e2e8f4'; 'fg-muted'='#a9b6cd'; 'fg-faint'='#8794ad'
    border='#3f4b69'; 'border-strong'='#55648a'; accent='#8ab4ff'
    'accent-soft'='#303b58'; 'code-bg'='#283044' }
  'blue-2' = @{ mode='dark'; bg='#202840'; 'bg-sunk'='#1c2338'; 'bg-raised'='#26304a'
    fg='#dee5f2'; 'fg-muted'='#a2afc7'; 'fg-faint'='#7f8da7'
    border='#33405e'; 'border-strong'='#49587c'; accent='#8ab4ff'
    'accent-soft'='#26304a'; 'code-bg'='#1e2539' }
  'blue-3' = @{ mode='dark'; bg='#161d2f'; 'bg-sunk'='#131928'; 'bg-raised'='#1b2338'
    fg='#dbe2f0'; 'fg-muted'='#9dabc4'; 'fg-faint'='#7a88a3'
    border='#2a3450'; 'border-strong'='#3f4d6d'; accent='#8fb7ff'
    'accent-soft'='#1c2439'; 'code-bg'='#151b2b' }

  # Slate: a lifted blue-grey that stays visibly grey at its darkest instead of
  # collapsing to black the way a neutral grey ramp does.
  'slate-1' = @{ mode='dark'; bg='#303845'; 'bg-sunk'='#2b323e'; 'bg-raised'='#39424f'
    fg='#e6e9ee'; 'fg-muted'='#aeb7c3'; 'fg-faint'='#8c96a4'
    border='#464f5f'; 'border-strong'='#5d687b'; accent='#8fb7f7'
    'accent-soft'='#353f50'; 'code-bg'='#2d3441' }
  'slate-2' = @{ mode='dark'; bg='#262c36'; 'bg-sunk'='#21262f'; 'bg-raised'='#2e3540'
    fg='#e3e6ec'; 'fg-muted'='#a8b1be'; 'fg-faint'='#86909f'
    border='#3a4350'; 'border-strong'='#515b6c'; accent='#8fb7f7'
    'accent-soft'='#2b3340'; 'code-bg'='#232936' }
  'slate-3' = @{ mode='dark'; bg='#1b2028'; 'bg-sunk'='#171b22'; 'bg-raised'='#222732'
    fg='#dfe3ea'; 'fg-muted'='#a1aab8'; 'fg-faint'='#7f8999'
    border='#2f3743'; 'border-strong'='#46515f'; accent='#93b9f8'
    'accent-soft'='#212833'; 'code-bg'='#191e26' }
}

# ------------------------------------------------------------------ auto-tune
$tuned = [ordered]@{}
foreach ($name in $Palettes.Keys) {
  $pal = $Palettes[$name]
  $q = @{}
  foreach ($k in $pal.Keys) { $q[$k] = $pal[$k] }
  $q['fg']            = Resolve-Tuned $pal['fg']            @($pal['bg-sunk'], $pal['bg-raised']) 10.0
  $q['accent']        = Resolve-Tuned $pal['accent']        @($pal['bg-sunk'], $pal['bg-raised']) 4.5
  $q['fg-faint']      = Resolve-Tuned $pal['fg-faint']      @($pal['bg-sunk']) 3.0
  # Table rules are the first thing to disappear at either extreme.
  $q['border']        = Resolve-Tuned $pal['border']        @($pal['bg-sunk']) 1.22
  $q['border-strong'] = Resolve-Tuned $pal['border-strong'] @($pal['bg-sunk']) 2.2
  $base = if ($pal['mode'] -eq 'light') { $LightTokens } else { $DarkTokens }
  $tok = [ordered]@{}
  foreach ($t in $base.Keys) { $tok[$t] = Resolve-Tuned $base[$t] @($pal['code-bg']) 4.5 }
  $q['tokens'] = $tok
  $tuned[$name] = $q
}

# ------------------------------------------------------------------- validate
$rules = @(
  @{ fg='fg';            bg='bg-sunk';   min=10.0;  label='body text' }
  @{ fg='fg';            bg='bg-raised'; min=10.0;  label='chrome text' }
  @{ fg='fg';            bg='code-bg';   min=9.0;   label='code text' }
  @{ fg='fg-muted';      bg='bg-sunk';   min=4.5;   label='muted text' }
  @{ fg='fg-muted';      bg='bg-raised'; min=4.5;   label='sidebar links' }
  @{ fg='fg-faint';      bg='bg-sunk';   min=3.0;   label='faint text' }
  @{ fg='accent';        bg='bg-sunk';   min=4.5;   label='links' }
  @{ fg='accent';        bg='bg-raised'; min=4.5;   label='active TOC item' }
  @{ fg='border-strong'; bg='bg-sunk';   min=2.2;   label='button borders' }
  @{ fg='border';        bg='bg-sunk';   min=1.22;  label='TABLE RULES' }
  @{ fg='border';        bg='bg-raised'; min=1.15;  label='rules on chrome' }
  @{ fg='border';        bg='code-bg';   min=1.10;  label='code outline' }
)

$failures = @()
foreach ($name in $tuned.Keys) {
  $pal = $tuned[$name]
  $bad = @()
  foreach ($r in $rules) {
    $v = Get-Contrast $pal[$r.fg] $pal[$r.bg]
    if ($v -lt $r.min) { $failures += "$name :: $($r.label) $([Math]::Round($v,2)) < $($r.min)"; $bad += $r.label }
  }
  foreach ($t in $pal['tokens'].Keys) {
    $v = Get-Contrast $pal['tokens'][$t] $pal['code-bg']
    if ($v -lt 4.5) { $failures += "$name :: token $t $([Math]::Round($v,2))"; $bad += $t }
  }
  $body = Get-Contrast $pal['fg'] $pal['bg-sunk']
  $rule = Get-Contrast $pal['border'] $pal['bg-sunk']
  $mark = if ($bad.Count) { 'FAIL' } else { 'ok  ' }
  $extra = if ($bad.Count) { '   ' + ($bad -join ', ') } else { '' }
  '{0}  {1}  body {2,5}:1   table rules {3:N2}:1   L*={4,5:N1}{5}' -f `
    $mark, $name.PadRight(9), [Math]::Round($body,1), $rule, (Get-Lstar $pal['bg-sunk']), $extra
}

''
'=== depth steps (CIE L* of the reading surface) ==='
foreach ($fam in @('white','beige','blue','slate')) {
  $l = @(1,2,3) | ForEach-Object { Get-Lstar $tuned["$fam-$_"]['bg-sunk'] }
  '  {0}  L* {1,5:N1} -> {2,5:N1} -> {3,5:N1}   steps {4:N1}, {5:N1}' -f `
    $fam.PadRight(6), $l[0], $l[1], $l[2], ($l[0]-$l[1]), ($l[1]-$l[2])
}

if ($failures.Count) {
  ''
  "FAILURES ($($failures.Count)):"
  $failures | ForEach-Object { "  $_" }
  exit 1
}
''
'ALL PASS'

# ---------------------------------------------------------------------- emit
$order = @('bg','bg-sunk','bg-raised','fg','fg-muted','fg-faint',
           'border','border-strong','accent','accent-soft','code-bg')
$sb = [Text.StringBuilder]::new()
foreach ($name in $tuned.Keys) {
  $pal = $tuned[$name]
  [void]$sb.AppendLine(":root[data-pal=`"$name`"] {")
  [void]$sb.AppendLine("  color-scheme: $($pal['mode']);")
  foreach ($k in $order) { [void]$sb.AppendLine("  --${k}: $($pal[$k]);") }
  $shadow = if ($pal['mode'] -eq 'light') { $ShadowLight } else { $ShadowDark }
  $filter = if ($pal['mode'] -eq 'light') { 'none' } else { $FilterDim }
  [void]$sb.AppendLine("  --shadow: $shadow;")
  [void]$sb.AppendLine("  --visual-filter: $filter;")
  foreach ($t in $pal['tokens'].Keys) { [void]$sb.AppendLine("  --${t}: $($pal['tokens'][$t]);") }
  [void]$sb.AppendLine('}')
}
$css = $sb.ToString().TrimEnd()

if (-not $Write) { ''; 'Run with -Write to inject into northern-lights.html'; exit 0 }

$startMark = '/* >>> BEGIN GENERATED PALETTES -- tools/Build-Palettes.ps1 -- do not hand-edit <<< */'
$endMark   = '/* >>> END GENERATED PALETTES <<< */'
$html = [IO.File]::ReadAllText($viewer)
$a = $html.IndexOf($startMark)
$b = $html.IndexOf($endMark)
if ($a -lt 0 -or $b -lt 0) { throw "palette markers not found in $viewer" }
$html = $html.Substring(0, $a + $startMark.Length) + "`n" + $css + "`n" + $html.Substring($b)
[IO.File]::WriteAllText($viewer, $html, (New-Object Text.UTF8Encoding($false)))
"Injected $($css.Length) bytes of palette CSS into $(Split-Path -Leaf $viewer)"
