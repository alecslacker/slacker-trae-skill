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
    Write-Host '[1/3] Copy skills (MIRROR — identik dengan repo)...' -ForegroundColor Cyan
    robocopy $repoSkills $skillsDir /MIR /E /XD __pycache__ .venv node_modules /XF *.pyc /NFL /NDL /NJH /NP | Out-Null
} else {
    Write-Host '[1/3] Copy skills (merge — skill lokal tidak dihapus)...' -ForegroundColor Cyan
    robocopy $repoSkills $skillsDir /E /XD __pycache__ .venv node_modules /XF *.pyc /NFL /NDL /NJH /NP | Out-Null
}
if ($LASTEXITCODE -gt 7) { Write-Host '[X] Copy skills gagal (robocopy exit code $LASTEXITCODE).' -ForegroundColor Red; exit 1 }

$installed = (Get-ChildItem $skillsDir -Directory).Count
Write-Host "    OK — total $installed folder skill di ~/.trae/skills" -ForegroundColor Green

# --- Copy memory (opsional) ---------------------------------------------------
if (-not $SkipMemory -and (Test-Path $repoMemory)) {
    Write-Host '[2/3] Copy memory (profil preferensi)...' -ForegroundColor Cyan
    # Memory lokal yang sudah ada tetap dipertahankan; file repo menimpa versi lama
    Get-ChildItem $repoMemory -File | ForEach-Object {
        Copy-Item $_.FullName $memoryDir -Force
        Write-Host "    OK — $($_.Name)" -ForegroundColor Green
    }
} else {
    Write-Host '[2/3] Memory dilewati (-SkipMemory / tidak ada).' -ForegroundColor DarkGray
}

# --- Copy rules User Rules TRAE (step 3/3) ------------------------------------
# Rules TRAE per komputer dan tidak ikut sync otomatis oleh TRAE - installer yang
# menyinkronkan. Tiga file: rules utama (konten INTI saja, di bawah garis '---'
# pada trae-rules.md - jangan ikut header "untuk paste"), memory-protocol,
# critical-thinking. Ditulis TANPA BOM (parser TRAE/Z Code menolak BOM).
# Idempoten: nama file lama dipertahankan agar antar komputer konsisten.
$repoRules   = Join-Path $PSScriptRoot '..\rules'
$rulesDir    = Join-Path $traeDir 'user_rules'
Write-Host '[3/3] Copy rules (User Rules TRAE)...' -ForegroundColor Cyan
if (Test-Path $repoRules) {
    New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null

    $utf8TanpaBom = New-Object System.Text.UTF8Encoding($false)

    # 1. Rules utama: ambil konten inti di bawah baris '---' dari trae-rules.md
    $traeRulesPath = Join-Path $PSScriptRoot '..\trae-rules.md'
    if (Test-Path $traeRulesPath) {
        $isiPenuh = [System.IO.File]::ReadAllText($traeRulesPath)
        # Baris '---' pertama yang berdiri sendiri = pembatas header; konten inti setelahnya
        $mGaris = [regex]::Match($isiPenuh, '(?m)^---\s*$')
        $kontenInti = if ($mGaris.Success) { $isiPenuh.Substring($mGaris.Index + $mGaris.Length).TrimStart() } else { $isiPenuh }
        # Cari file rules utama lama (file non-khusus terbesar = rules utama)
        $targetUtama = $null
        Get-ChildItem $rulesDir -Filter 'rule-*.md' -ErrorAction SilentlyContinue | ForEach-Object {
            $isi = [System.IO.File]::ReadAllText($_.FullName)
            if ($isi -match 'RULES SLACKERCODER') { if (-not $targetUtama -or $_.Length -gt $targetUtama.Length) { $targetUtama = $_ } }
        }
        if (-not $targetUtama) { $targetUtama = Join-Path $rulesDir ("rule-" + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() + ".md") } else { $targetUtama = $targetUtama.FullName }
        [System.IO.File]::WriteAllText($targetUtama, $kontenInti, $utf8TanpaBom)
        Write-Host "    OK — rules utama (Slackercoder) -> $(Split-Path $targetUtama -Leaf)" -ForegroundColor Green
    } else {
        Write-Host '    [!] trae-rules.md tidak ada di repo — rules utama dilewati' -ForegroundColor Yellow
    }

    # 2-3. Memory protocol & critical thinking: salin apa adanya, cari file lama by konten
    foreach ($r in @(@('memory-protocol.md','Memory Protocol'), @('critical-thinking.md','Anti-Sycophancy'))) {
        $src = Join-Path $repoRules $r[0]
        if (-not (Test-Path $src)) { Write-Host "    [!] $($r[0]) tidak ada di repo — dilewati" -ForegroundColor Yellow; continue }
        $isiSrc = [System.IO.File]::ReadAllText($src).Trim()
        $target = $null
        Get-ChildItem $rulesDir -Filter 'rule-*.md' -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.FullName -eq $targetUtama) { return }
            if ([System.IO.File]::ReadAllText($_.FullName).Trim() -like "*$($r[1])*") { $target = $_.FullName }
        }
        if (-not $target) { $target = Join-Path $rulesDir ("rule-" + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() + ".md") }
        # Tulis hanya bila konten beda (idempoten, hindari renumber file baru tiap jalan)
        if ((Test-Path $target) -and ([System.IO.File]::ReadAllText($target).Trim() -eq $isiSrc)) {
            Write-Host "    OK — $($r[0]) sudah cocok" -ForegroundColor DarkGray
        } else {
            [System.IO.File]::WriteAllText($target, $isiSrc, $utf8TanpaBom)
            Write-Host "    OK — $($r[0]) -> $(Split-Path $target -Leaf)" -ForegroundColor Green
        }
    }
} else {
    Write-Host '[3/3] Folder rules repo tidak ada — dilewati.' -ForegroundColor DarkGray
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
    Write-Host '               (API key seperti NINEROUTER_KEY TIDAK ikut — set manual per komputer).' -ForegroundColor DarkGray
}
Write-Host ''
Write-Host 'Skill Python (blog) butuh C:\Python312\python.exe — cek README.' -ForegroundColor DarkGray
