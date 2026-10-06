# sync-zcode.ps1 — Sinkron repo trae-skills ke Z Code (~/.zcode)
# Sumber kebenaran: folder repo. Target: C:\Users\<user>\.zcode\
# - Skills  : repo/skills -> ~/.zcode/skills          (standar SKILL.md, sama seperti Claude)
# - Aturan  : repo/zcode/AGENTS.md -> ~/.zcode/AGENTS.md (dibaca ZCode setiap sesi)
# - Commands: repo/zcode/commands -> ~/.zcode/commands
# - MCP     : TIDAK disentuh — config Z Code (~/.zcode/cli/config.json) dikelola langsung
#             (hasil audit 2026-10-06: satu blok kanonik "mcp.servers" berisi 8 server;
#             penyalinan dari ~/.claude.json dihapus karena menimpa kurasi Z Code dan
#             dual-write flat+nested membuat dua set API key yang drift).
# Aman dijalankan berulang (idempoten). ZCode desktop sebaiknya ditutup saat sync.

param(
    [switch]$Mirror  # Hapus skill di ~/.zcode/skills yang tidak ada di repo
)

$ErrorActionPreference = 'Stop'

# --- Lokasi ---
$RepoRoot = Split-Path -Parent $PSScriptRoot
$SrcSkills = Join-Path $RepoRoot 'skills'
$SrcZcode = Join-Path $RepoRoot 'zcode'
$DstZcode = Join-Path $HOME '.zcode'
$DstSkills = Join-Path $DstZcode 'skills'
$DstCommands = Join-Path $DstZcode 'commands'

foreach ($p in @($SrcSkills, $SrcZcode)) {
    if (-not (Test-Path $p)) { Write-Error "Folder sumber tidak ditemukan: $p" }
}
if (-not (Test-Path $DstZcode)) {
    New-Item -ItemType Directory -Path $DstZcode | Out-Null
    Write-Host "Dibuat: $DstZcode"
}

# --- 1. Skills: repo/skills -> ~/.zcode/skills ---
# CATATAN: robocopy DIGANTI dengan Copy-Item per-folder (robocopy /E sempat HANG
# pada 302 skill: CPU ~0.09, tidak bergerak >9 menit). Copy-Item terbukti stabil.
if (-not (Test-Path $DstSkills)) { New-Item -ItemType Directory -Path $DstSkills | Out-Null }

$okCount = 0
$failList = @()
foreach ($d in (Get-ChildItem $SrcSkills -Directory)) {
    $dstFolder = Join-Path $DstSkills $d.Name
    # PENTING: hapus folder tujuan dulu. Tanpa ini, Copy-Item -Recurse saat folder
    # tujuan SUDAH ADA akan membuat folder BERSARANG (nama\nama\SKILL.md).
    if (Test-Path $dstFolder) { Remove-Item $dstFolder -Recurse -Force -ErrorAction SilentlyContinue }
    Copy-Item $d.FullName $dstFolder -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path (Join-Path $dstFolder 'SKILL.md')) { $okCount++ } else { $failList += $d.Name }
}
# Bersihkan artefak yang tidak perlu di target
Get-ChildItem $DstSkills -Recurse -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('__pycache__', '.venv', 'node_modules', '.git') } |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

if ($failList.Count -gt 0) { Write-Warning "Skill tanpa SKILL.md setelah salin: $($failList -join ', ')" }

if ($Mirror) {
    $repoList = (Get-ChildItem $SrcSkills -Directory).Name
    Get-ChildItem $DstSkills -Directory | Where-Object { $repoList -notcontains $_.Name } | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
        Write-Host "Mirror: dihapus $($_.Name)"
    }
}
$skillCount = (Get-ChildItem $DstSkills -Directory).Count

# --- 2. AGENTS.md global (dibaca ZCode setiap sesi) + BEST-PRACTICE.md (referensi) ---
Copy-Item (Join-Path $SrcZcode 'AGENTS.md') (Join-Path $DstZcode 'AGENTS.md') -Force
Copy-Item (Join-Path $SrcZcode 'BEST-PRACTICE.md') (Join-Path $DstZcode 'BEST-PRACTICE.md') -Force

# --- 3. Commands ---
if (-not (Test-Path $DstCommands)) { New-Item -ItemType Directory -Path $DstCommands | Out-Null }
Copy-Item (Join-Path $SrcZcode 'commands\*.md') $DstCommands -Force
$cmdCount = (Get-ChildItem $DstCommands -Filter *.md).Count

# --- 4. MCP: TIDAK DISINKRONKAN ---
# Sejak audit MCP 2026-10-06, config Z Code (~/.zcode/cli/config.json) adalah sumber
# kebenarannya sendiri: satu blok kanonik "mcp.servers" berisi 8 server aktif
# (context7, zai-mcp-server, playwright, Figma AI Bridge, shadcn-ui, byteplus-image,
# publora, ssh-admin via wrapper). web-reader & needmcp dihapus lewat Settings 2026-10-07
# dan DILARANG dipasang ulang (web-reader: WebFetch cukup; needmcp: bug vendor protocolVersion).
# Step lama (salin mcpServers dari ~/.claude.json + dual-write dua blok) DIHAPUS karena:
#  - menimpa kurasi Z Code dengan daftar 17 server era Claude Code;
#  - dual-write flat "mcpServers" + nested "mcp.servers" membuat dua set API key yang drift.

# --- Laporan ---
Write-Host ""
Write-Host "=== SINKRON Z CODE SELESAI ===" -ForegroundColor Green
Write-Host "Skills   : $skillCount folder -> $DstSkills"
Write-Host "AGENTS.md: diperbarui (persona Slackercoder + hemat token)"
Write-Host "Commands : $cmdCount file -> $DstCommands"
Write-Host "MCP      : tidak disentuh (dikelola langsung di Z Code sejak audit 2026-10-06)"