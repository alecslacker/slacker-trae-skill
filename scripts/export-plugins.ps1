# export-plugins.ps1 — Ekspor skill dari plugin TRAE resmi -> repo/skills
# Sumber: C:\Users\<user>\.trae\plugins\trae-remote-official\<plugin>\<versi>\skills\<skill>
# Target: repo/skills/<skill>  (repo = satu-satunya sumber kebenaran; sync ke agent lewat sync-*.ps1)
#
# LINGKUPAN Tier 3: SEMUA plugin KECUALI yang terikat MCP/CLI TRAE-only (lark, cloudflare,
# hyperframes, codex-obsidian, x-twitter-scraper) — salin itu = dead weight di agent lain.
# Plugin superpowers & dev-skills: hanya skill yang BELUM ada di repo (standalone duplikat dilewati).
# Posisi: skip-if-exists (skill repo tidak pernah ditimpa). Idempoten. Tidak menghapus apa pun.

param(
    [switch]$Force  # Timpa skill yang sudah ada di repo (default: skip-if-exists)
)

$ErrorActionPreference = 'Stop'
$pluginsRoot = Join-Path $HOME '.trae\plugins\trae-remote-official'
$RepoRoot    = Split-Path -Parent $PSScriptRoot
$DstSkills   = Join-Path $RepoRoot 'skills'

if (-not (Test-Path $pluginsRoot)) { Write-Error "Folder plugin tidak ditemukan: $pluginsRoot" }
if (-not (Test-Path $DstSkills))   { Write-Error "Folder repo/skills tidak ditemukan: $DstSkills" }

# Plugin yang DILEWATI — terikat MCP/CLI yang tidak ada di Claude/ZCode/Codex
$skipPlugins = @('lark', 'cloudflare', 'hyperframes', 'codex-obsidian', 'x-twitter-scraper')

$exported = 0; $skippedExisting = 0; $skippedDup = 0; $invalid = @()
$log = New-Object System.Collections.Generic.List[string]

foreach ($plug in (Get-ChildItem $pluginsRoot -Directory | Sort-Object Name)) {
    if ($plug.Name -in $skipPlugins) { continue }

    foreach ($ver in (Get-ChildItem $plug.FullName -Directory -ErrorAction SilentlyContinue)) {
        $skDir = Join-Path $ver.FullName 'skills'
        if (-not (Test-Path $skDir)) { continue }

        foreach ($sk in (Get-ChildItem $skDir -Directory -ErrorAction SilentlyContinue)) {
            $name = $sk.Name

            # _shared & folder non-skill (tanpa SKILL.md) dilewati — bukan skill mandiri
            $skillMd = Join-Path $sk.FullName 'SKILL.md'
            if (-not (Test-Path $skillMd)) { $log.Add("LEWATI (tanpa SKILL.md): $plug/$name"); continue }
            if ($name -like '_*')          { $log.Add("LEWATI (internal):    $plug/$name"); continue }

            # Validasi frontmatter minimal: name & description
            $head = (Get-Content $skillMd -TotalCount 12 -ErrorAction SilentlyContinue) -join "`n"
            if ($head -notmatch '(?s)^---.*?name:.*?description:') {
                $invalid += "$plug/$name"; $log.Add("INVALID frontmatter: $plug/$name"); continue
            }

            $dst = Join-Path $DstSkills $name
            if ((Test-Path $dst) -and -not $Force) {
                # Sudah ada di repo (standalone atau hasil export sebelumnya) — repo menang
                $skippedExisting++; $log.Add("SKIP (sudah ada):   $name  [$plug]"); continue
            }
            if ((Test-Path $dst) -and $Force) {
                $log.Add("FORCE timpa:        $name  [$plug]")
            }

            if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
            Copy-Item $sk.FullName $dst -Recurse -Force
            $exported++; $log.Add("EXPORT:             $name  [$plug]")
        }
    }
}

# --- Laporan ---
$report = Join-Path $RepoRoot '.trae\documents'
if (-not (Test-Path $report)) { New-Item -ItemType Directory -Path $report | Out-Null }
$logPath = Join-Path $report 'export-plugins-log.txt'
$log | Set-Content $logPath -Encoding UTF8

Write-Host ""
Write-Host "=== EXPORT PLUGIN -> REPO SELESAI ===" -ForegroundColor Green
Write-Host "Diekspor        : $exported skill"
Write-Host "Skip (sudah ada): $skippedExisting skill (repo menang; pakai -Force untuk timpa)"
Write-Host "Frontmatter jtg : $($invalid.Count)  $($invalid -join ', ')"
Write-Host "Plugin dilewati : $($skipPlugins -join ', ')"
Write-Host "Log detail      : $logPath"
Write-Host "Total repo      : $((Get-ChildItem $DstSkills -Directory).Count) folder skill"
Write-Host ""
Write-Host "Lanjutkan dengan: .\scripts\sync-claude.ps1 ; .\scripts\sync-zcode.ps1 ; .\scripts\sync-codex.ps1"
