# sync-zcode.ps1 — Sinkron repo trae-skills ke Z Code (~/.zcode)
# Sumber kebenaran: folder repo. Target: C:\Users\<user>\.zcode\
# - Skills  : repo/skills -> ~/.zcode/skills          (standar SKILL.md, sama seperti Claude)
# - Aturan  : repo/zcode/AGENTS.md -> ~/.zcode/AGENTS.md (dibaca ZCode setiap sesi)
# - Commands: repo/zcode/commands -> ~/.zcode/commands
# - MCP     : salin mcpServers dari ~/.claude.json (kurasi aktif, tanpa mysql) -> ~/.zcode/cli/config.json
# Aman dijalankan berulang (idempoten). Backup config otomatis. ZCode desktop sebaiknya ditutup saat sync.

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
$ZcodeConfig = Join-Path $DstZcode 'cli\config.json'
$ClaudeJson = Join-Path $HOME '.claude.json'

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

# --- 2. AGENTS.md global (dibaca ZCode setiap sesi) ---
Copy-Item (Join-Path $SrcZcode 'AGENTS.md') (Join-Path $DstZcode 'AGENTS.md') -Force

# --- 3. Commands ---
if (-not (Test-Path $DstCommands)) { New-Item -ItemType Directory -Path $DstCommands | Out-Null }
Copy-Item (Join-Path $SrcZcode 'commands\*.md') $DstCommands -Force
$cmdCount = (Get-ChildItem $DstCommands -Filter *.md).Count

# --- 4. MCP: salin mcpServers kurasi dari ~/.claude.json -> ~/.zcode/cli/config.json ---
$mcpCount = 0
if ((Test-Path $ClaudeJson) -and (Test-Path $ZcodeConfig)) {
    $claude = Get-Content $ClaudeJson -Raw | ConvertFrom-Json
    $mcp = $claude.mcpServers
    if ($mcp) {
        Copy-Item $ZcodeConfig "$ZcodeConfig.bak" -Force
        $cfg = Get-Content $ZcodeConfig -Raw | ConvertFrom-Json
        # Tulis DUA format kunci (terverifikasi dari kode sumber ZCode v2):
        #  - "mcpServers" (flat)      : dibaca agent CLI tertanam (kompatibilitas lama)
        #  - "mcp.servers"  (nested)  : dibaca UI Settings -> MCP Servers v2
        $cfg | Add-Member -NotePropertyName mcpServers -NotePropertyValue $mcp -Force
        $nested = [pscustomobject]@{ servers = $mcp }
        $cfg | Add-Member -NotePropertyName mcp -NotePropertyValue $nested -Force
        # TULIS TANPA BOM — parser JSON Node (ZCode) menolak UTF-8 BOM (Set-Content UTF8 di PS5.1 menyisipkan BOM)
        $json = $cfg | ConvertTo-Json -Depth 12
        [System.IO.File]::WriteAllText($ZcodeConfig, $json, (New-Object System.Text.UTF8Encoding($false)))
        $mcpCount = ($mcp.PSObject.Properties | Measure-Object).Count
    }
} else {
    Write-Host "LEWATI MCP: ~/.claude.json atau config ZCode tidak ditemukan"
}

# --- Laporan ---
Write-Host ""
Write-Host "=== SINKRON Z CODE SELESAI ===" -ForegroundColor Green
Write-Host "Skills   : $skillCount folder -> $DstSkills"
Write-Host "AGENTS.md: diperbarui (persona Slackercoder + hemat token)"
Write-Host "Commands : $cmdCount file -> $DstCommands"
Write-Host "MCP      : $mcpCount server -> $ZcodeConfig (backup: config.json.bak)"
if ($mcpCount -gt 0) {
    Write-Host ""
    Write-Host "Catatan: buka ZCode -> Settings -> MCP Servers untuk melihat & mengaktifkan."
    Write-Host "Jika tidak muncul, klik ikon Import di halaman MCP (sumber: Claude Code)."
}