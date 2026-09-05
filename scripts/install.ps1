# ============================================================
# install.ps1 — Pasang skills TRAE dari repo ini ke komputer lokal
# ============================================================
# Cara pakai (di komputer BARU):
#   1. Clone repo ini (ataau download ZIP lalu extract)
#   2. Buka PowerShell di folder repo
#   3. Jalankan:  .\scripts\install.ps1
#
# Opsi:
#   .\scripts\install.ps1 -Mirror     # hapus skill lokal yang tidak ada di repo (identik penuh)
#   .\scripts\install.ps1 -SkipMemory # jangan sentuh folder memory
#
# Aman: folder ~/.trae/skills yang sudah ada di-backup dulu otomatis.

param(
    [switch]$Mirror,
    [switch]$SkipMemory
)

$ErrorActionPreference = 'Stop'

# --- Konfigurasi path -------------------------------------------------------
$repoSkills = Join-Path $PSScriptRoot '..\skills'
$repoMemory = Join-Path $PSScriptRoot '..\memory'
$traeDir    = Join-Path $env:USERPROFILE '.trae'
$skillsDir  = Join-Path $traeDir 'skills'
$memoryDir  = Join-Path $traeDir 'memory'
$stamp      = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host '================================================' -ForegroundColor Cyan
Write-Host ' SLACKER TRAE SKILL — Pemasang (Slackercode Family)' -ForegroundColor Cyan
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ''

# --- Validasi repo ----------------------------------------------------------
if (-not (Test-Path (Join-Path $repoSkills 'blog'))) {
    Write-Host "[X] Folder 'skills' repo tidak ditemukan di: $repoSkills" -ForegroundColor Red
    Write-Host '    Pastikan PowerShell dijalankan dari root repo, atau cek hasil clone.' -ForegroundColor Yellow
    exit 1
}

# --- Buat folder tujuan ------------------------------------------------------
New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
if (-not $SkipMemory) { New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null }

# --- Backup skill lama (kalau ada) ------------------------------------------
$existing = Get-ChildItem $skillsDir -Directory -ErrorAction SilentlyContinue
if ($existing.Count -gt 0) {
    $backup = Join-Path $traeDir "skills-backup-$stamp"
    Write-Host "[i] Ada $($existing.Count) folder skill lokal — backup ke:" -ForegroundColor Yellow
    Write-Host "    $backup" -ForegroundColor Yellow
    robocopy $skillsDir $backup /E /NFL /NDL /NJH /NP | Out-Null
    if ($LASTEXITCODE -gt 7) { Write-Host "[X] Backup gagal — instalasi dibatalkan." -ForegroundColor Red; exit 1 }
}

# --- Copy skills -------------------------------------------------------------
Write-Host ''
if ($Mirror) {
    Write-Host '[1/2] Copy skills (MIRROR — identik dengan repo)...' -ForegroundColor Cyan
    robocopy $repoSkills $skillsDir /MIR /E /XD __pycache__ .venv node_modules /XF *.pyc /NFL /NDL /NJH /NP | Out-Null
} else {
    Write-Host '[1/2] Copy skills (merge — skill lokal tidak dihapus)...' -ForegroundColor Cyan
    robocopy $repoSkills $skillsDir /E /XD __pycache__ .venv node_modules /XF *.pyc /NFL /NDL /NJH /NP | Out-Null
}
if ($LASTEXITCODE -gt 7) { Write-Host '[X] Copy skills gagal (robocopy exit code $LASTEXITCODE).' -ForegroundColor Red; exit 1 }

$installed = (Get-ChildItem $skillsDir -Directory).Count
Write-Host "    OK — total $installed folder skill di ~/.trae/skills" -ForegroundColor Green

# --- Copy memory (opsional) ---------------------------------------------------
if (-not $SkipMemory -and (Test-Path $repoMemory)) {
    Write-Host '[2/2] Copy memory (profil preferensi)...' -ForegroundColor Cyan
    # Memory lokal yang sudah ada tetap dipertahankan; file repo menimpa versi lama
    Get-ChildItem $repoMemory -File | ForEach-Object {
        Copy-Item $_.FullName $memoryDir -Force
        Write-Host "    OK — $($_.Name)" -ForegroundColor Green
    }
} else {
    Write-Host '[2/2] Memory dilewati (-SkipMemory / tidak ada).' -ForegroundColor DarkGray
}

# --- Selesai ------------------------------------------------------------------
Write-Host ''
Write-Host '================================================' -ForegroundColor Green
Write-Host ' SELESAI!' -ForegroundColor Green
Write-Host '================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Langkah terakhir (WAJIB agar skills aktif):' -ForegroundColor Yellow
Write-Host '  1. Restart TRAE IDE (tutup total, buka lagi)' -ForegroundColor White
Write-Host '  2. Skills otomatis terbaca dari ~/.trae/skills' -ForegroundColor White
if (-not $SkipMemory) {
    Write-Host ''
    Write-Host 'Catatan memory: profil preferensi tersalin. Sesuaikan bila perlu' -ForegroundColor DarkGray
    Write-Host '               (API key seperti ARK_API_KEY TIDAK ikut — set manual per komputer).' -ForegroundColor DarkGray
}
Write-Host ''
Write-Host 'Skill Python (blog) butuh C:\Python312\python.exe — cek README.' -ForegroundColor DarkGray
