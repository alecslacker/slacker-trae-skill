# sync-claude.ps1 — Sinkron repo trae-skills ke Claude Code CLI (~/.claude)
# Sumber kebenaran: folder repo. Target: C:\Users\<user>\.claude\
# Aman dijalankan berulang (idempoten). Tidak menyentuh agents/, rules/, memory/, plugins/.

param(
    [switch]$Mirror  # Hapus skill di ~/.claude/skills yang tidak ada di repo
)

$ErrorActionPreference = 'Stop'

# --- Lokasi ---
$RepoRoot = Split-Path -Parent $PSScriptRoot
$SrcSkills = Join-Path $RepoRoot 'skills'
$SrcClaude = Join-Path $RepoRoot 'claude'
$DstClaude = Join-Path $HOME '.claude'
$DstSkills = Join-Path $DstClaude 'skills'
$DstCommands = Join-Path $DstClaude 'commands'

foreach ($p in @($SrcSkills, $SrcClaude)) {
    if (-not (Test-Path $p)) { Write-Error "Folder sumber tidak ditemukan: $p" }
}
if (-not (Test-Path $DstClaude)) {
    New-Item -ItemType Directory -Path $DstClaude | Out-Null
    Write-Host "Dibuat: $DstClaude"
}

# --- 1. Skills: repo/skills -> ~/.claude/skills ---
# CATATAN: robocopy DIGANTI dengan Copy-Item per-folder.
# Alasan: robocopy /E /NFL pada 302 skill (1307 file, 34 MB) sempat HANG
# (CPU ~0.09, tidak bergerak >9 menit). Copy-Item per-folder terbukti stabil
# dan sekaligus memberi hitungan sukses/gagal yang jelas.
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
    # Hapus folder skill lokal yang tidak ada di repo
    $repoList = (Get-ChildItem $SrcSkills -Directory).Name
    Get-ChildItem $DstSkills -Directory | Where-Object { $repoList -notcontains $_.Name } | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
        Write-Host "Mirror: dihapus $($_.Name)"
    }
}
$skillCount = (Get-ChildItem $DstSkills -Directory).Count

# --- 2. CLAUDE.md global ---
Copy-Item (Join-Path $SrcClaude 'CLAUDE.md') (Join-Path $DstClaude 'CLAUDE.md') -Force

# --- 3. Commands ---
if (-not (Test-Path $DstCommands)) { New-Item -ItemType Directory -Path $DstCommands | Out-Null }
Copy-Item (Join-Path $SrcClaude 'commands\*.md') $DstCommands -Force
$cmdCount = (Get-ChildItem $DstCommands -Filter *.md).Count

# --- 4. settings.json: merge template + pertahankan token/plugin/mcp lokal ---
$TplPath = Join-Path $SrcClaude 'settings.template.json'
$SetPath = Join-Path $DstClaude 'settings.json'
$tpl = Get-Content $TplPath -Raw | ConvertFrom-Json

if (Test-Path $SetPath) {
    $cur = Get-Content $SetPath -Raw | ConvertFrom-Json
    # Pertahankan token lokal; fallback token lama bila template kosong
    $oldToken = $cur.env.ANTHROPIC_AUTH_TOKEN
    if (-not $tpl.env.ANTHROPIC_AUTH_TOKEN -and $oldToken) {
        $tpl.env | Add-Member -NotePropertyName ANTHROPIC_AUTH_TOKEN -NotePropertyValue $oldToken -Force
    }
    # Pertahankan enabledPlugins & mcpServers lokal (tidak dikelola repo)
    if ($cur.PSObject.Properties['enabledPlugins']) {
        $tpl | Add-Member -NotePropertyName enabledPlugins -NotePropertyValue $cur.enabledPlugins -Force
    }
    if ($cur.PSObject.Properties['mcpServers']) {
        $tpl | Add-Member -NotePropertyName mcpServers -NotePropertyValue $cur.mcpServers -Force
    }
    Copy-Item $SetPath "$SetPath.bak" -Force
}
$tpl | ConvertTo-Json -Depth 10 | Set-Content -Path $SetPath -Encoding UTF8

# --- Laporan ---
Write-Host ""
Write-Host "=== SINKRON CLAUDE CODE SELESAI ===" -ForegroundColor Green
Write-Host "Skills   : $skillCount folder -> $DstSkills"
Write-Host "CLAUDE.md: diperbarui"
Write-Host "Commands : $cmdCount file -> $DstCommands"
Write-Host "Settings : digabung (token & plugin lokal dipertahankan; backup: settings.json.bak)"
Write-Host ""
Write-Host "Model    : Sonnet/Opus = glm-5.3[1m] | Haiku = glm-5.3-flash[1m]"
Write-Host "Endpoint : https://api.z.ai/api/anthropic"
