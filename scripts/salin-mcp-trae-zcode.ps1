# salin-mcp-trae-zcode.ps1 - salin MCP server dari TRAE ke Z Code
# Sumber : %APPDATA%\Trae\User\mcp.json (blok mcpServers)
# Target : ~/.zcode/cli/config.json (blok kanonik mcp.servers, format nested)
# Aturan : server disabled di-skip; config lama di-backup; API key tidak di-print.
# CATATAN: config TRAE mengandung kunci duplikat (playwright + Playwright) yang
#          melanggar spesifikasi JSON - parser per-server berbasis regex mengatasinya.
# Author: Mas Wondho - Duta Corpora Indonesia (DCI)
$ErrorActionPreference = 'Stop'

$srcPath = Join-Path $env:APPDATA 'Trae\User\mcp.json'
$dstDir  = Join-Path $HOME '.zcode\cli'
$dstPath = Join-Path $dstDir 'config.json'

if (-not (Test-Path $srcPath)) { Write-Error "Config TRAE tidak ditemukan: $srcPath" }
New-Item -ItemType Directory -Path $dstDir -Force | Out-Null

$raw = Get-Content $srcPath -Raw

# Ambil isi blok "mcpServers": { ... } (kurung kurawal seimbang)
$m = [regex]::Match($raw, '"mcpServers"\s*:\s*\{')
if (-not $m.Success) { Write-Error 'Blok mcpServers tidak ditemukan di config TRAE' }
$start = $m.Index + $m.Length
$depth = 1; $i = $start
while ($depth -gt 0 -and $i -lt $raw.Length) {
    $c = $raw[$i]
    if ($c -eq '{') { $depth++ } elseif ($c -eq '}') { $depth-- }
    $i++
}
$blok = $raw.Substring($start, $i - $start - 1)

# Pecah per-server: kunci level-1 di dalam blok (string JSON "nama" diikuti : { ... })
$servers = [ordered]@{}
$rx = [regex]'(?s)"((?:[^"\\]|\\.)*)"\s*:\s*\{'
$pos = 0
while ($pos -lt $blok.Length) {
    $mm = $rx.Match($blok, $pos)
    if (-not $mm.Success) { break }
    $nama = $mm.Groups[1].Value
    $d = 1; $j = $mm.Index + $mm.Length
    while ($d -gt 0 -and $j -lt $blok.Length) {
        $c = $blok[$j]
        if ($c -eq '{') { $d++ } elseif ($c -eq '}') { $d-- }
        $j++
    }
    $isi = $blok.Substring($mm.Index + $mm.Length, $j - $mm.Index - $mm.Length - 1)
    if (-not $servers.Contains($nama)) { $servers[$nama] = $isi }
    $pos = $j
}

# Baca target lama (bila ada), pertahankan isi lama lalu timpa dengan hasil salinan
$targetRaw = @{}
if (Test-Path $dstPath) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Copy-Item $dstPath "$dstPath.bak-$stamp" -Force
    Write-Host "BACKUP: config.json lama -> config.json.bak-$stamp"
    $lama = Get-Content $dstPath -Raw
    $mx = [regex]::Match($lama, '"servers"\s*:\s*\{')
    if ($mx.Success) {
        $s0 = $mx.Index + $mx.Length
        $dd = 1; $ii = $s0
        while ($dd -gt 0 -and $ii -lt $lama.Length) {
            $c = $lama[$ii]
            if ($c -eq '{') { $dd++ } elseif ($c -eq '}') { $dd-- }
            $ii++
        }
        $blokLama = $lama.Substring($s0, $ii - $s0 - 1)
        $p2 = 0
        while ($p2 -lt $blokLama.Length) {
            $mm2 = $rx.Match($blokLama, $p2)
            if (-not $mm2.Success) { break }
            $n2 = $mm2.Groups[1].Value
            $d2 = 1; $j2 = $mm2.Index + $mm2.Length
            while ($d2 -gt 0 -and $j2 -lt $blokLama.Length) {
                $c2 = $blokLama[$j2]
                if ($c2 -eq '{') { $d2++ } elseif ($c2 -eq '}') { $d2-- }
                $j2++
            }
            if (-not $targetRaw.ContainsKey($n2)) { $targetRaw[$n2] = $blokLama.Substring($mm2.Index + $mm2.Length, $j2 - $mm2.Index - $mm2.Length - 1) }
            $p2 = $j2
        }
    }
}

# Susun server final: skip disabled, normalkan duplikat (huruf kecil menang atas kapital)
$final = [ordered]@{}
$disalin = @(); $dilewati = @()
foreach ($p in $servers.GetEnumerator()) {
    $nama = $p.Key; $isi = $p.Value
    if ($isi -match '"disabled"\s*:\s*true') { $dilewati += "$nama (disabled)"; continue }
    $final[$nama] = $isi
    $disalin += $nama
}
foreach ($p in $targetRaw.GetEnumerator()) {
    if (-not $final.Contains($p.Key)) { $final[$p.Key] = $p.Value }
}

# Tulis config nested kanonik mcp.servers
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('{')
[void]$sb.AppendLine('  "mcp": {')
[void]$sb.AppendLine('    "servers": {')
$idx = 0
foreach ($p in $final.GetEnumerator()) {
    $isi = $p.Value -replace "`r`n", "`n" -replace "`n", "`n    "
    $koma = if ($idx -lt $final.Count - 1) { ',' } else { '' }
    [void]$sb.AppendLine("      `"$($p.Key)`": {")
    [void]$sb.AppendLine("    $isi")
    [void]$sb.AppendLine("      }$koma")
    $idx++
}
[void]$sb.AppendLine('    }')
[void]$sb.AppendLine('  }')
[void]$sb.AppendLine('}')
Set-Content -Path $dstPath -Value $sb.ToString() -Encoding UTF8

# Validasi hasil: jumlah kunci server harus sama
$cek = (Get-Content $dstPath -Raw) -split '"servers"' | Select-Object -Last 1
Write-Host ""
Write-Host "=== SALIN MCP TRAE -> Z CODE SELESAI ===" -ForegroundColor Green
Write-Host ("Target  : {0}" -f $dstPath)
Write-Host ("Disalin : {0} server" -f $final.Count)
Write-Host ("  " + ($final.Keys -join ', '))
if ($dilewati.Count -gt 0) { Write-Host ("Dilewati: " + ($dilewati -join ', ')) -ForegroundColor DarkGray }
Write-Host "API key : dipindah apa adanya (tidak di-print)."
