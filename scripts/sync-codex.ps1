# sync-codex.ps1 — Sinkron repo trae-skills ke Codex (~/.codex + ~/.agents)
# Sumber kebenaran: folder repo. Target:
#   - Skills resmi : repo/skills -> ~/.agents/skills   (path resmi Codex 0.160+, standar agentskills.io)
#   - Skills legacy: repo/skills -> ~/.codex/skills    (jalur lama, disinkronkan juga agar tidak basi;
#                   folder .system = bundled system skills Codex, TIDAK disentuh)
#   - Aturan       : repo/codex/AGENTS.md        -> ~/.codex/AGENTS.md        (dibaca Codex tiap sesi; backup otomatis)
#   - Referensi    : repo/codex/BEST-PRACTICE.md -> ~/.codex/BEST-PRACTICE.md
# Extra skill yang sudah ada di target tapi tidak di repo (mis. gepeto, pinokio di ~/.agents/skills)
# DIPERTAHANKAN — sama seperti pola sync-claude.ps1 (hanya -Mirror yang menghapus).
# Aman dijalankan berulang (idempoten). Codex sebaiknya ditutup saat sync.

param(
    [switch]$Mirror  # Hapus skill di target yang tidak ada di repo (TIDAK menyentuh .system)
)

$ErrorActionPreference = 'Stop'

# --- Lokasi ---
$RepoRoot  = Split-Path -Parent $PSScriptRoot
$SrcSkills = Join-Path $RepoRoot 'skills'
$SrcCodex  = Join-Path $RepoRoot 'codex'
$DstCodexHome  = Join-Path $HOME '.codex'
$DstAgentsSk   = Join-Path $HOME '.agents\skills'   # path resmi user-scope
$DstLegacySk   = Join-Path $HOME '.codex\skills'    # path legacy

foreach ($p in @($SrcSkills, $SrcCodex)) {
    if (-not (Test-Path $p)) { Write-Error "Folder sumber tidak ditemukan: $p" }
}
foreach ($p in @($DstCodexHome)) {
    if (-not (Test-Path $p)) { Write-Error "Folder target tidak ditemukan: $p — pastikan Codex sudah pernah dijalankan" }
}

# --- Fungsi salin skill per-folder (pola terbukti stabil untuk 302 skill) ---
function Copy-Skills([string]$Source, [string]$Target) {
    if (-not (Test-Path $Target)) { New-Item -ItemType Directory -Path $Target | Out-Null }
    $ok = 0; $fail = @()
    foreach ($d in (Get-ChildItem $Source -Directory)) {
        $dstFolder = Join-Path $Target $d.Name
        # PENTING: hapus folder tujuan dulu. Tanpa ini, Copy-Item -Recurse saat folder
        # tujuan SUDAH ADA akan membuat folder BERSARANG (nama\nama\SKILL.md).
        if (Test-Path $dstFolder) { Remove-Item $dstFolder -Recurse -Force -ErrorAction SilentlyContinue }
        Copy-Item $d.FullName $dstFolder -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path (Join-Path $dstFolder 'SKILL.md')) { $ok++ } else { $fail += $d.Name }
    }
    # Bersihkan artefak yang tidak perlu
    Get-ChildItem $Target -Recurse -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @('__pycache__', '.venv', 'node_modules', '.git') } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    if ($fail.Count -gt 0) { Write-Warning "Skill tanpa SKILL.md setelah salin di ${Target}: $($fail -join ', ')" }
    return $ok
}

# --- 1. Skills -> path resmi ~/.agents/skills ---
$okAgents = Copy-Skills $SrcSkills $DstAgentsSk
if ($Mirror) {
    $repoList = (Get-ChildItem $SrcSkills -Directory).Name
    Get-ChildItem $DstAgentsSk -Directory | Where-Object { $repoList -notcontains $_.Name } | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
        Write-Host "Mirror: dihapus $($_.Name)"
    }
}
$countAgents = (Get-ChildItem $DstAgentsSk -Directory).Count

# --- 2. Skills -> path legacy ~/.codex/skills (agar tidak basi; .system dipertahankan otomatis) ---
$okLegacy = Copy-Skills $SrcSkills $DstLegacySk
if ($Mirror) {
    $repoList = (Get-ChildItem $SrcSkills -Directory).Name
    Get-ChildItem $DstLegacySk -Directory | Where-Object { $_.Name -ne '.system' -and $repoList -notcontains $_.Name } | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
        Write-Host "Mirror legacy: dihapus $($_.Name)"
    }
}
$countLegacy = (Get-ChildItem $DstLegacySk -Directory | Where-Object { $_.Name -ne '.system' }).Count

# --- 3. AGENTS.md global (backup otomatis) + BEST-PRACTICE.md ---
$agentsDst = Join-Path $DstCodexHome 'AGENTS.md'
if (Test-Path $agentsDst) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Copy-Item $agentsDst "$agentsDst.bak-$stamp" -Force
    Write-Host "Backup: AGENTS.md.bak-$stamp"
}
Copy-Item (Join-Path $SrcCodex 'AGENTS.md') $agentsDst -Force
Copy-Item (Join-Path $SrcCodex 'BEST-PRACTICE.md') (Join-Path $DstCodexHome 'BEST-PRACTICE.md') -Force

# --- 4. Arsipkan rules .md inert (engine rules hanya membaca *.rules Starlark) ---
$inertMd = Join-Path $DstCodexHome 'rules\slackercoder-rules.md'
if (Test-Path $inertMd) {
    $arsipDir = Join-Path $DstCodexHome 'rules\arsip'
    if (-not (Test-Path $arsipDir)) { New-Item -ItemType Directory -Path $arsipDir | Out-Null }
    Move-Item $inertMd (Join-Path $arsipDir 'slackercoder-rules-v2-inert.md') -Force
    Write-Host "Arsip: rules/slackercoder-rules.md -> rules/arsip/ (file .md tidak dibaca engine rules)"
}

# --- Laporan ---
Write-Host ""
Write-Host "=== SINKRON CODEX SELESAI ===" -ForegroundColor Green
Write-Host "Skills resmi : $okAgents ter-copy, total folder $countAgents -> $DstAgentsSk"
Write-Host "Skills legacy: $okLegacy ter-copy, total folder $countLegacy (+ .system dipertahankan) -> $DstLegacySk"
Write-Host "AGENTS.md    : diperbarui (padanan penuh Rules TRAE WORK) + BEST-PRACTICE.md"
Write-Host ""
Write-Host "Catatan: jalankan ulang sync ini setiap kali repo trae-skills diperbarui."
Write-Host "Verifikasi: .\scripts\verify-sync.ps1"
