# ============================================================
# collect.ps1 — Kumpulkan skill lokal ke repo + push ke GitHub
# ============================================================
# Cara pakai (di komputer yang PUNYA skill baru/diubah):
#   1. Jalankan dari root repo hasil clone:  .\scripts\collect.ps1
#   2. Script akan:
#      a. Copy skill dari ~/.trae/skills  -> repo/skills   (skill baru & berubah)
#      b. Copy memory dari ~/.trae/memory -> repo/memory
#      c. Git add + commit + push
#
# Opsi:
#   .\scripts\collect.ps1 -Message "tambah skill X"   # pesan commit custom
#   .\scripts\collect.psı -NoPush                     # commit saja tanpa push

param(
    [string]$Message = '',
    [switch]$NoPush
)

$ErrorActionPreference = 'Stop'

# --- Konfigurasi path -------------------------------------------------------
$repoRoot   = Split-Path $PSScriptRoot -Parent
$repoSkills = Join-Path $repoRoot 'skills'
$repoMemory = Join-Path $repoRoot 'memory'
$skillsDir  = Join-Path $env:USERPROFILE '.trae\skills'
$memoryDir  = Join-Path $env:USERPROFILE '.trae\memory'

Write-Host '================================================' -ForegroundColor Cyan
Write-Host ' SLACKER TRAE SKILL — Pengumpul (lokal -> repo -> GitHub)' -ForegroundColor Cyan
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ''

# --- Validasi ----------------------------------------------------------------
if (-not (Test-Path $skillsDir)) {
    Write-Host "[X] Folder skill lokal tidak ditemukan: $skillsDir" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
    Write-Host '[X] Ini bukan repo git. Clone dulu repo dari GitHub, lalu jalankan dari dalamnya.' -ForegroundColor Red
    exit 1
}

# --- Copy skills lokal -> repo ------------------------------------------------
Write-Host '[1/3] Sinkron skill lokal -> repo...' -ForegroundColor Cyan
robocopy $skillsDir $repoSkills /E /XD __pycache__ .venv node_modules skills-backup* /XF *.pyc /NFL /NDL /NJH /NP | Out-Null
if ($LASTEXITCODE -gt 7) { Write-Host '[X] Copy skill gagal.' -ForegroundColor Red; exit 1 }
Write-Host '    OK' -ForegroundColor Green

# --- Copy memory lokal -> repo --------------------------------------------------
if (Test-Path $memoryDir) {
    Write-Host '[2/3] Sinkron memory -> repo...' -ForegroundColor Cyan
    Get-ChildItem $memoryDir -File | ForEach-Object { Copy-Item $_.FullName $repoMemory -Force }
    Write-Host '    OK' -ForegroundColor Green
} else {
    Write-Host '[2/3] Memory lokal tidak ada — lewati.' -ForegroundColor DarkGray
}

# --- Git commit -------------------------------------------------------------------
Write-Host '[3/3] Git commit...' -ForegroundColor Cyan
git -C $repoRoot add -A 2>&1 | Out-Null

$status = git -C $repoRoot status --porcelain
if (-not $status) {
    Write-Host '    Tidak ada perubahan — sudah sinkron.' -ForegroundColor Yellow
    exit 0
}

if (-not $Message) {
    $changed = ($status | Measure-Object -Line).Lines
    $Message = "sync: $changed perubahan skill/memory dari $env:COMPUTERNAME ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
}
git -C $repoRoot commit -m $Message 2>&1 | Out-Null
Write-Host "    Commit: $Message" -ForegroundColor Green

# --- Push ------------------------------------------------------------------------
if (-not $NoPush) {
    Write-Host '    Push ke GitHub...' -ForegroundColor Cyan
    git -C $repoRoot push 2>&1 | ForEach-Object { Write-Host "    $_" }
    if ($LASTEXITCODE -eq 0) {
        Write-Host '    Push OK.' -ForegroundColor Green
    } else {
        Write-Host '    [!] Push gagal — cek koneksi/remote. Jalankan manual: git push' -ForegroundColor Yellow
    }
} else {
    Write-Host '    (-NoPush — push dilewati, jalankan git push manual nanti)' -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'Selesai! Di komputer lain: git pull lalu .\scripts\install.ps1' -ForegroundColor Green
