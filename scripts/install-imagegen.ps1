#requires -Version 7
<#
  install-imagegen.ps1 — memasang runtime dci-imagegen ke ~/.9router/mcp/dci-imagegen
  Author: Mas Wondho — Duta Corpora Indonesia (DCI)
  Copyright © 2026 Duta Corpora Indonesia

  Bawaan: DRY-RUN. Tambahkan -Apply untuk menyalin dan memasang dependensi (npm ci, versi terkunci).
  Salinan runtime tunggal ini dipakai bersama semua agent. Tidak ada kredensial yang disalin.
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$Tujuan = (Join-Path $HOME '.9router\mcp\dci-imagegen'),
    [string]$Node = 'C:\nvm4w\nodejs\node.exe'
)
$ErrorActionPreference = 'Stop'

$sumber = Join-Path (Split-Path -Parent $PSScriptRoot) 'mcp\dci-imagegen'
foreach ($p in @('package.json', 'package-lock.json', 'src\index.js')) {
    if (-not (Test-Path (Join-Path $sumber $p))) { throw "Berkas sumber tidak ditemukan: $(Join-Path $sumber $p)" }
}
if (-not (Test-Path $Node)) { throw "Node.js tidak ditemukan di $Node" }
$npmCli = Join-Path (Split-Path $Node) 'node_modules\npm\bin\npm-cli.js'
if (-not (Test-Path $npmCli)) { throw "npm-cli.js tidak ditemukan di samping Node: $npmCli" }

Write-Host "Sumber : $sumber"
Write-Host "Tujuan : $Tujuan"
if (-not $Apply) {
    Write-Host 'DRY-RUN: tidak ada yang diubah. Jalankan dengan -Apply untuk memasang.' -ForegroundColor Yellow
    return
}

New-Item -ItemType Directory -Force -Path $Tujuan | Out-Null
$srcTujuan = Join-Path $Tujuan 'src'
if (Test-Path $srcTujuan) { Remove-Item $srcTujuan -Recurse -Force }
Copy-Item (Join-Path $sumber 'src') $srcTujuan -Recurse
Copy-Item (Join-Path $sumber 'package.json') $Tujuan -Force
Copy-Item (Join-Path $sumber 'package-lock.json') $Tujuan -Force

Push-Location $Tujuan
try {
    & $Node $npmCli ci --omit=dev --no-audit --no-fund 2>&1 | ForEach-Object { "  npm: $_" }
    if ($LASTEXITCODE -ne 0) { throw "npm ci gagal (kode $LASTEXITCODE)" }
    # Muat modul server tanpa menjalankannya: membuktikan SDK dan zod terpasang dan kode bisa dibaca.
    $cek = & $Node --input-type=module -e "const m = await import('./src/server.js'); console.log(typeof m.buatServer)" 2>&1
    if ($LASTEXITCODE -ne 0 -or "$cek".Trim() -ne 'function') { throw "Verifikasi muat modul gagal: $cek" }
} finally {
    Pop-Location
}
Write-Host "Terpasang: $Tujuan" -ForegroundColor Green
Write-Host "Titik masuk untuk config agent: $(Join-Path $srcTujuan 'index.js')"
