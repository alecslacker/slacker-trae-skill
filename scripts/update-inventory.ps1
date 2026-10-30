# update-inventory.ps1 — Regenerasi skills/INVENTORY.md (inventaris sumber skill)
# Klasifikasi 3 sumber, urutan prioritas:
#   1. Repo GitHub eksternal  — tercatat di upstream-manifest.json (paling spesifik)
#   2. Plugin resmi TRAE      — nama skill ditemukan di ~/.trae/plugins/trae-remote-official/*/skills
#   3. Kurasi pack / internal — sisanya (skill pack terkurasi + buatan sendiri)
# Dipanggil oleh collect.ps1 (step 2.6); bisa juga dijalankan langsung.
# Idempoten: selalu menimpa INVENTORY.md dengan hasil hitung terkini.

$ErrorActionPreference = 'Stop'
$RepoRoot   = Split-Path -Parent $PSScriptRoot
$RepoSkills = Join-Path $RepoRoot 'skills'

# --- 1. Peta skill -> plugin TRAE lokal ---------------------------------------
$PluginMap = @{}
$PluginsRoot = Join-Path $env:USERPROFILE '.trae\plugins\trae-remote-official'
if (Test-Path $PluginsRoot) {
    Get-ChildItem $PluginsRoot -Directory | ForEach-Object {
        $plug = $_.Name
        Get-ChildItem $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $skDir = Join-Path $_.FullName 'skills'
            if (Test-Path $skDir) {
                Get-ChildItem $skDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    if (-not $PluginMap.ContainsKey($_.Name)) { $PluginMap[$_.Name] = $plug }
                }
            }
        }
    }
}

# --- 2. Peta skill -> repo GitHub eksternal (dari manifest) --------------------
$GhMap = @{}
$ManifestPath = Join-Path $RepoRoot 'upstream-manifest.json'
if (Test-Path $ManifestPath) {
    $Manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($e in $Manifest.entries) {
        $label = '{0} ({1}, dicek {2})' -f $e.repo, $e.upstream_terakhir, $e.terakhir_dicek
        foreach ($f in (@($e.folder) + @($e.juga_mencakup))) {
            if ($f -and -not $GhMap.ContainsKey($f)) { $GhMap[$f] = $label }
        }
    }
}

# --- 3. Klasifikasi skill repo -------------------------------------------------
$AllSk    = Get-ChildItem $RepoSkills -Directory | Sort-Object Name
$GhList   = @($AllSk | Where-Object { $GhMap.ContainsKey($_.Name) })
$PlugList = @($AllSk | Where-Object { -not $GhMap.ContainsKey($_.Name) -and $PluginMap.ContainsKey($_.Name) })
$KurList  = @($AllSk | Where-Object { -not $GhMap.ContainsKey($_.Name) -and -not $PluginMap.ContainsKey($_.Name) })

# --- 4. Susun dokumen ----------------------------------------------------------
$GhBlock = foreach ($grp in ($GhList | Group-Object { $GhMap[$_.Name] } | Sort-Object Name)) {
    "### $($grp.Name)"
    ""
    ($grp.Group | ForEach-Object { "- $($_.Name)" })
    ""
}
$PlugBlock = foreach ($s in $PlugList) { "- $($s.Name) — $($PluginMap[$s.Name])" }

$Inv = @"
# SKILL INVENTORY — $($AllSk.Count) Skill (Auto-Generated)

> **JANGAN EDIT MANUAL** — di-regenerate oleh scripts/update-inventory.ps1
> (dipanggil otomatis oleh collect.ps1 step 2.6) tiap ada skill tambah/kurang.
> Sumber data: folder skills/ + plugin TRAE lokal (~/.trae/plugins/trae-remote-official)
> + upstream-manifest.json.
> Cek update skill GitHub eksternal: .\scripts\check-upstream.ps1

Diperbarui: $(Get-Date -Format 'yyyy-MM-dd') | Total: **$($AllSk.Count)** skill

## Ringkasan Sumber

| Sumber | Jumlah | Cara update |
|---|---|---|
| Kurasi pack / internal | $($KurList.Count) | Manual — skill standalone terkurasi + buatan sendiri |
| Plugin resmi TRAE | $($PlugList.Count) | `scripts/export-plugins.ps1` (-Force untuk timpa) |
| Repo GitHub eksternal | $($GhList.Count) | `scripts/check-upstream.ps1` |

## Kurasi Pack / Internal ($($KurList.Count))

$($KurList.Name -join ', ')

## Plugin Resmi TRAE ($($PlugList.Count))

Dihasilkan export-plugins.ps1 dari ~/.trae/plugins/trae-remote-official/ (plugin terikat MCP
TRAE-only tidak diekspor; format: nama skill — plugin asal).

$($PlugBlock -join "`n")

## Repo GitHub Eksternal ($($GhList.Count))

Sumber + versi tercatat di upstream-manifest.json. Keluarga skill dikelompokkan per repo asal.

$($GhBlock -join "`n")
"@

Set-Content -Path (Join-Path $RepoSkills 'INVENTORY.md') -Value $Inv -Encoding UTF8
Write-Host ("INVENTORY.md: total {0} = kurasi {1} + plugin {2} + github {3}" -f $AllSk.Count, $KurList.Count, $PlugList.Count, $GhList.Count)
