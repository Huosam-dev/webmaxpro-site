# download-fonts.ps1 - Downloads all fonts for WebMaxPro and creates fonts.css
# Run: powershell -ExecutionPolicy Bypass -File "download-fonts.ps1"

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$fontsDir   = Join-Path $projectDir "fonts"
New-Item -ItemType Directory -Force -Path $fontsDir | Out-Null
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'

function Get-WF($url, $filename) {
    $dest = Join-Path $fontsDir $filename
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    $kb = [math]::Round((Get-Item $dest).Length / 1024, 1)
    Write-Host "  $filename  ($kb KB)"
}

# ── Cormorant Garamond ───────────────────────────────────────────────────────
Write-Host "`nCormorant Garamond..."
Get-WF "https://fonts.gstatic.com/s/cormorantgaramond/v21/co3bmX5slCNuHLi8bLeY9MK7whWMhyjYp3tKgS4.woff2" "cormorant-garamond-normal-ext.woff2"
Get-WF "https://fonts.gstatic.com/s/cormorantgaramond/v21/co3bmX5slCNuHLi8bLeY9MK7whWMhyjYqXtK.woff2"     "cormorant-garamond-normal.woff2"
Get-WF "https://fonts.gstatic.com/s/cormorantgaramond/v21/co3smX5slCNuHLi8bLeY9MK7whWMhyjYrGFEsdtdc62E6zd58jD-htM8Efs.woff2" "cormorant-garamond-italic-ext.woff2"
Get-WF "https://fonts.gstatic.com/s/cormorantgaramond/v21/co3smX5slCNuHLi8bLeY9MK7whWMhyjYrGFEsdtdc62E6zd58jD-iNM8.woff2"    "cormorant-garamond-italic.woff2"

# ── Montserrat ───────────────────────────────────────────────────────────────
Write-Host "Montserrat..."
Get-WF "https://fonts.gstatic.com/s/montserrat/v31/JTUSjIg1_i6t8kCHKm459Wdhyzbi.woff2" "montserrat-normal-ext.woff2"
Get-WF "https://fonts.gstatic.com/s/montserrat/v31/JTUSjIg1_i6t8kCHKm459Wlhyw.woff2"   "montserrat-normal.woff2"

# ── IBM Plex Arabic (dynamic – fetches real URLs from Google Fonts) ──────────
Write-Host "IBM Plex Arabic..."
$arabicCss = (Invoke-WebRequest -Uri 'https://fonts.googleapis.com/css2?family=IBM+Plex+Arabic:wght@400;600;700&display=swap' -UserAgent $ua -UseBasicParsing).Content
$pattern   = '(?s)/\*\s*(arabic|latin)\s*\*/\s*@font-face\s*\{([^}]+)\}'
$matches2  = [regex]::Matches($arabicCss, $pattern)
$seenUrls  = @{}
$arabicEntries = ""
foreach ($m in $matches2) {
    $subset = $m.Groups[1].Value.Trim()
    $body   = $m.Groups[2].Value
    $wt     = [regex]::Match($body, 'font-weight:\s*(\d+)').Groups[1].Value
    $url    = [regex]::Match($body, 'url\(([^)]+\.woff2)\)').Groups[1].Value
    $range  = [regex]::Match($body, 'unicode-range:\s*([^;]+)').Groups[1].Value.Trim()
    $slug   = if ($subset -eq 'arabic') { 'ar' } else { 'latin' }
    $fname  = "ibm-plex-arabic-$wt-$slug.woff2"
    if (-not $seenUrls.ContainsKey($url)) {
        Get-WF $url $fname
        $seenUrls[$url] = $fname
    } else {
        $fname = $seenUrls[$url]
    }
    $arabicEntries += "@font-face {`n  font-family: 'IBM Plex Arabic';`n  font-style: normal;`n  font-weight: $wt;`n  font-display: optional;`n  src: url('/fonts/$fname') format('woff2');`n  unicode-range: $range;`n}`n"
}

# ── Write fonts.css ──────────────────────────────────────────────────────────
$static = @'
/* Cormorant Garamond – latin-ext (covers NL/DE special chars) */
@font-face {
  font-family: 'Cormorant Garamond';
  font-style: normal;
  font-weight: 400 700;
  font-display: optional;
  src: url('/fonts/cormorant-garamond-normal-ext.woff2') format('woff2');
  unicode-range: U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF, U+0304, U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF, U+2020, U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF;
}
/* Cormorant Garamond – latin */
@font-face {
  font-family: 'Cormorant Garamond';
  font-style: normal;
  font-weight: 400 700;
  font-display: optional;
  src: url('/fonts/cormorant-garamond-normal.woff2') format('woff2');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}
/* Cormorant Garamond italic – latin-ext */
@font-face {
  font-family: 'Cormorant Garamond';
  font-style: italic;
  font-weight: 400;
  font-display: optional;
  src: url('/fonts/cormorant-garamond-italic-ext.woff2') format('woff2');
  unicode-range: U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF, U+0304, U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF, U+2020, U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF;
}
/* Cormorant Garamond italic – latin */
@font-face {
  font-family: 'Cormorant Garamond';
  font-style: italic;
  font-weight: 400;
  font-display: optional;
  src: url('/fonts/cormorant-garamond-italic.woff2') format('woff2');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

/* Montserrat – latin-ext */
@font-face {
  font-family: 'Montserrat';
  font-style: normal;
  font-weight: 400 600;
  font-display: optional;
  src: url('/fonts/montserrat-normal-ext.woff2') format('woff2');
  unicode-range: U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF, U+0304, U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF, U+2020, U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF;
}
/* Montserrat – latin */
@font-face {
  font-family: 'Montserrat';
  font-style: normal;
  font-weight: 400 600;
  font-display: optional;
  src: url('/fonts/montserrat-normal.woff2') format('woff2');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

'@

$full = $static + "/* IBM Plex Arabic */`n" + $arabicEntries
$cssPath = Join-Path $projectDir "fonts.css"
$full | Set-Content -Path $cssPath -Encoding UTF8
Write-Host "`nfonts.css written to: $cssPath"
Write-Host "`nAll done! Now run: git add fonts/ fonts.css"
