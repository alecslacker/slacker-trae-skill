# verify-taste-sync.ps1 — Verifikasi silang 13 skill taste-* + full-output-enforcement
# Bandingkan repo (sumber kebenaran) dengan TRAE, Claude, ZCode:
#   - jumlah folder skill
#   - jumlah file per folder taste
#   - MD5 gabungan isi file per folder taste (deterministik)

$ErrorActionPreference = 'Stop'
$src    = 'C:\Users\alecs\AppData\Roaming\TRAE SOLO\ModularData\ai-agent\work-mode-projects\6a95030fe42ad49f5c0c5663\trae-skills\skills'
$targets = [ordered]@{
    'TRAE ' = (Join-Path $HOME '.trae\skills')
    'CLAUDE'= (Join-Path $HOME '.claude\skills')
    'ZCODE' = (Join-Path $HOME '.zcode\skills')
}

$tasteNames = (Get-ChildItem $src -Directory |
    Where-Object { $_.Name -like 'taste-*' -or $_.Name -eq 'full-output-enforcement' }).Name

# Hitung sidik jari folder: gabungan (path relatif + MD5 file), lalu MD5-kan
function Get-FolderFingerprint([string]$folder) {
    if (-not (Test-Path $folder)) { return $null }
    $files = Get-ChildItem $folder -Recurse -File -Force -ErrorAction SilentlyContinue |
        Sort-Object FullName
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($folder.Length).TrimStart('\')
        $md5 = (Get-FileHash $f.FullName -Algorithm MD5).Hash
        $parts.Add("$rel|$md5")
    }
    $joined = [string]::Join("`n", $parts)
    $bytes  = [System.Text.Encoding]::UTF8.GetBytes($joined)
    $hash   = [System.Security.Cryptography.MD5]::Create().ComputeHash($bytes)
    return @{
        Hash  = ([System.BitConverter]::ToString($hash) -replace '-','')
        Files = $files.Count
    }
}

Write-Output "=== VERIFIKASI SINKRON TASTE-SKILLS ==="
Write-Output ""

# 1. Jumlah folder skill total
Write-Output "JUMLAH FOLDER SKILL:"
Write-Output ("  {0,-8} {1}" -f 'REPO', (Get-ChildItem $src -Directory).Count)
foreach ($k in $targets.Keys) {
    $p = $targets[$k]
    $c = if (Test-Path $p) { (Get-ChildItem $p -Directory).Count } else { 'N/A' }
    Write-Output ("  {0,-8} {1}" -f $k, $c)
}
Write-Output ""

# 2. Sidik jari per folder taste
Write-Output "SIDIK JARI PER FOLDER (repo vs target):"
$header = "  {0,-26} {1,-8} {2,-34} {3,-34} {4,-34}"
Write-Output ($header -f 'FOLDER','FILE','REPO','TRAE','CLAUDE/ZCODE')
Write-Output ("  " + ('-' * 132))

$mismatch = 0
foreach ($n in ($tasteNames | Sort-Object)) {
    $ref = Get-FolderFingerprint (Join-Path $src $n)
    $fRef = $ref.Files
    $hRef = $ref.Hash

    $cols = @()
    foreach ($k in $targets.Keys) {
        $fp = Get-FolderFingerprint (Join-Path $targets[$k] $n)
        if ($null -eq $fp) { $cols += 'HILANG'; $mismatch++ ; continue }
        if ($fp.Hash -eq $hRef) { $cols += 'OK' } else { $cols += "BEDA($($fp.Files)f)"; $mismatch++ }
    }
    Write-Output ("  {0,-26} {1,-8} {2,-34} {3,-34} {4,-34}" -f $n, $fRef, $hRef.Substring(0,12), $cols[0], "$($cols[1]) / $($cols[2])")
}

Write-Output ""
if ($mismatch -eq 0) {
    Write-Host "HASIL: SEMUA COCOK — 13 folder identik di repo, TRAE, Claude, ZCode." -ForegroundColor Green
} else {
    Write-Host "HASIL: ADA $mismatch KETIDAKCOCOKAN. Perlu perbaikan." -ForegroundColor Yellow
}
