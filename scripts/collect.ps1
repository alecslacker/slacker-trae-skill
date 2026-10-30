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

# --- Sinkron jumlah skill ke semua dokumen ber-marker --------------------------
# Marker: <N><!--skill-count:N--> di dokumen repo. Saat skill ditambah/dihapus,
# angka di SEMUA dokumen otomatis diperbarui di sini — konsistensi terjamin.
Write-Host '[2.5/3] Sinkron jumlah skill -> dokumen...' -ForegroundColor Cyan
$skillTotal = (Get-ChildItem $repoSkills -Directory).Count
$docs = @(
    (Join-Path $repoRoot 'README.md'),
    (Join-Path $repoRoot 'AGENTS.md'),
    (Join-Path $repoRoot '.knowledge.md'),
    (Join-Path $repoRoot 'claude\CLAUDE.md'),
    (Join-Path $repoRoot 'codex\AGENTS.md'),
    (Join-Path $repoRoot 'codex\BEST-PRACTICE.md'),
    (Join-Path $repoRoot 'zcode\AGENTS.md'),
    (Join-Path $repoRoot 'zcode\BEST-PRACTICE.md'),
    (Join-Path $repoRoot 'memory\user_profile.md')
)
$syncedDocs = 0
foreach ($doc in $docs) {
    if (-not (Test-Path $doc)) { continue }
    $content = Get-Content $doc -Raw -Encoding UTF8
    # Ganti angka di dalam marker + angka tampilan di depannya (idempoten)
    $new = [regex]::Replace($content, '\d+<!--skill-count:\d+-->', "$skillTotal<!--skill-count:$skillTotal-->")
    if ($new -ne $content) {
        Set-Content -Path $doc -Value $new -Encoding UTF8 -NoNewline
        Write-Host "    OK — $(Split-Path $doc -Leaf) -> $skillTotal"
    }
    $syncedDocs++
}
Write-Host "    OK — $syncedDocs dokumen dicek, jumlah skill: $skillTotal"

# --- Regenerasi inventaris sumber skill (INVENTORY.md) -------------------------
# Klasifikasi 394 skill per asal: kurasi internal / plugin resmi TRAE / repo GitHub
# eksternal. Detail mekanisme ada di scripts/update-inventory.ps1.
Write-Host '[2.6/3] Regenerasi skills/INVENTORY.md...' -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'update-inventory.ps1')

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
