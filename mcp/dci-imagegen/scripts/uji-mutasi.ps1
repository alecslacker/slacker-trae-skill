#requires -Version 7
<#
  uji-mutasi.ps1 — merusak satu kontrol keamanan/perilaku pada salinan kode, lalu memastikan tes GAGAL.
  Jika sebuah mutasi "lolos diam-diam", berarti kontrol itu belum dijaga tes dan tesnya harus diperkuat.
  Author: Mas Wondho — Duta Corpora Indonesia (DCI)
  Copyright © 2026 Duta Corpora Indonesia

  Tidak mengubah kode asli: bekerja di folder sementara. Kode keluar 0 bila SEMUA mutasi tertangkap.
#>
$ErrorActionPreference = 'Stop'
$src = Split-Path -Parent $PSScriptRoot
$mut = Join-Path $env:TEMP 'dci-imagegen-mutasi'
$hasil = New-Object System.Collections.Generic.List[object]

function Jalankan([string]$nama, [string]$berkas, [string]$cari, [string]$ganti) {
    if (Test-Path $mut) { Remove-Item $mut -Recurse -Force }
    New-Item -ItemType Directory -Path $mut | Out-Null
    Copy-Item (Join-Path $src 'src'), (Join-Path $src 'test'), (Join-Path $src 'package.json') $mut -Recurse
    New-Item -ItemType Junction -Path (Join-Path $mut 'node_modules') -Target (Join-Path $src 'node_modules') | Out-Null
    $f = Join-Path $mut $berkas
    $t = [IO.File]::ReadAllText($f)
    if (-not $t.Contains($cari)) { $hasil.Add([pscustomobject]@{ Mutasi = $nama; Status = 'TIDAK TERPASANG' }); return }
    [IO.File]::WriteAllText($f, $t.Replace($cari, $ganti))
    Push-Location $mut
    $r = & node --test --test-reporter=spec 'test/*.test.js' 2>&1 | ForEach-Object { "$_" }
    Pop-Location
    $gagal = @($r | Where-Object { $_ -match '^ℹ fail (\d+)' } | ForEach-Object { [int]($_ -replace '\D', '') })[0]
    $hasil.Add([pscustomobject]@{ Mutasi = $nama; Status = $(if ($gagal -gt 0) { "TERTANGKAP ($gagal tes gagal)" } else { 'LOLOS DIAM-DIAM' }) })
}

Jalankan 'batas n dilonggarkan (4 -> 40)' 'src\generate.js' 'export const BATAS_LANGSUNG = 4;' 'export const BATAS_LANGSUNG = 40;'
Jalankan 'syarat confirmed dihapus' 'src\generate.js' 'n > BATAS_LANGSUNG && confirmed !== true' 'false'
Jalankan 'penyensoran key dimatikan' 'src\errors.js' "replace(POLA_RAHASIA, '[disensor]')" "replace(POLA_RAHASIA, '`$&')"
Jalankan 'cek byte gambar referensi dimatikan' 'src\images.js' "if (!jenis) throw new DciError('referensi', ``Berkas bukan gambar" "if (false) throw new DciError('referensi', ``Berkas bukan gambar"
Jalankan 'tolak symlink dimatikan' 'src\images.js' 'if (st.isSymbolicLink())' 'if (false)'
Jalankan 'validasi model ke server dimatikan' 'src\generate.js' 'if (!ids.includes(model)) {' 'if (false) {'
Jalankan 'mode tulis eksklusif diganti timpa' 'src\generate.js' "open(path, 'wx')" "open(path, 'w')"
Jalankan 'https wajib dimatikan' 'src\config.js' "u.protocol !== 'https:' && !(u.protocol === 'http:' && lokal)" 'false'
Jalankan 'batas 10 MB referensi dilonggarkan' 'src\images.js' 'if (st.size > MAKS_BYTE_REFERENSI)' 'if (false)'
Jalankan 'tolak path UNC dimatikan' 'src\images.js' "path.startsWith('\\\\')" 'false'
Jalankan 'folder sistem dibolehkan' 'src\folders.js' "if (akarSistem(env).some((x) => berada(abs, x))) return 'folder sistem';" '/* dimatikan */'
Jalankan 'berhenti saat auth gagal dimatikan' 'src\generate.js' "e.code === 'auth' || e.code === 'konfigurasi'" 'false'

if (Test-Path $mut) { Remove-Item $mut -Recurse -Force }
$hasil | Format-Table -AutoSize
$buruk = @($hasil | Where-Object { $_.Status -notlike 'TERTANGKAP*' })
if ($buruk.Count -gt 0) { Write-Host "$($buruk.Count) mutasi tidak tertangkap: perkuat tesnya." -ForegroundColor Red; exit 1 }
Write-Host "Semua $($hasil.Count) mutasi tertangkap." -ForegroundColor Green
