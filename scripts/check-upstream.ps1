# check-upstream.ps1 — Pemantau update skill dari repo upstream GitHub
# Membaca upstream-manifest.json, cek rilis/tag/commit terbaru tiap repo,
# bandingkan dengan "upstream_terakhir" yang tercatat. TANPA API key (endpoint publik).
# Pemakaian:
#   .\scripts\check-upstream.ps1              # cek saja, tampilkan laporan
#   .\scripts\check-upstream.ps1 -UpdateManifest  # sekalian tulis hasil ke manifest

param(
    [switch]$UpdateManifest
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $RepoRoot 'upstream-manifest.json'

if (-not (Test-Path $ManifestPath)) { Write-Error "Manifest tidak ditemukan: $ManifestPath" }
$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json

# Tulis JSON tanpa BOM (parser Node/PS aman)
function Write-ManifestJson($obj, $path) {
    $json = $obj | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding($false)))
}

$hasil = @()
foreach ($e in $manifest.entries) {
    $apiUrl = switch ($e.metode) {
        'latest_tag'    { "https://api.github.com/repos/$($e.repo)/releases/latest" }
        'latest_commit' { "https://api.github.com/repos/$($e.repo)/commits?per_page=1" }
        default         { $null }
    }
    if (-not $apiUrl) { Write-Warning "Metode tidak dikenal: $($e.metode) ($($e.repo))"; continue }

    try {
        $resp = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'slacker-skills-checker' } -TimeoutSec 20
        $terbaru = switch ($e.metode) {
            'latest_tag'    { if ($resp.tag_name) { $resp.tag_name } else { $null } }
            'latest_commit' { $resp[0].sha.Substring(0, 7) + ' (' + $resp[0].commit.committer.date.ToString('yyyy-MM-dd') + ')' }
        }
        $tanggal = switch ($e.metode) {
            'latest_tag'    { ([datetime]$resp.published_at).ToString('yyyy-MM-dd') }
            'latest_commit' { $resp[0].commit.committer.date.ToString('yyyy-MM-dd') }
        }
    }
    catch {
        $hasil += [pscustomobject]@{ Folder=$e.folder; Repo=$e.repo; Upstream='GAGAL AKSES'; Terakhir=$e.upstream_terakhir; Status='PERIKSA MANUAL'; Tanggal='-' }
        continue
    }

    # Bandingkan: beda bila string terbaru TIDAK muncul di catatan lama
    $status = if ($e.upstream_terakhir -and $e.upstream_terakhir.Contains($terbaru)) { 'TERBARU' } else { 'ADA UPDATE' }

    $hasil += [pscustomobject]@{
        Folder    = $e.folder + $(if ($e.juga_mencakup) { " (+$($e.juga_mencakup.Count) skill)" } else { '' })
        Repo      = $e.repo
        Upstream  = $terbaru
        Tanggal   = $tanggal
        Terakhir  = $e.upstream_terakhir
        Status    = $status
    }

    if ($UpdateManifest) {
        $e.upstream_terakhir = $terbaru
        $e.terakhir_dicek = (Get-Date).ToString('yyyy-MM-dd')
    }
}

Write-Output ""
Write-Output "=== LAPORAN PEMANTAUAN SKILL UPSTREAM ($(Get-Date -Format 'yyyy-MM-dd HH:mm')) ==="
$hasil | Format-Table Folder, Repo, Upstream, Tanggal, Status -AutoSize | Out-String -Width 160

$perluUpdate = $hasil | Where-Object { $_.Status -eq 'ADA UPDATE' }
$gagal = $hasil | Where-Object { $_.Status -eq 'PERIKSA MANUAL' }

if ($perluUpdate) {
    Write-Host ">>> ADA UPDATE: $($perluUpdate.Count) sumber. Langkah update:" -ForegroundColor Yellow
    Write-Host "    1. Clone/refresh upstream ke folder kerja" -ForegroundColor Yellow
    Write-Host "    2. Bandingkan SKILL.md lama vs baru (diff) — rilis sering hanya README" -ForegroundColor Yellow
    Write-Host "    3. Salin yang benar-benar berubah ke skills/, jalankan sync-claude/sync-zcode" -ForegroundColor Yellow
    Write-Host "    4. Jalankan ulang script ini dengan -UpdateManifest untuk mencatat" -ForegroundColor Yellow
} elseif ($gagal) {
    Write-Host ">>> Beberapa repo gagal diakses (jaringan/rate limit) — coba lagi nanti." -ForegroundColor Yellow
} else {
    Write-Host ">>> Semua sumber TERBARU. Tidak ada tindakan." -ForegroundColor Green
}

if ($UpdateManifest) {
    Write-ManifestJson $manifest $ManifestPath
    Write-Host "Manifest diperbarui: $ManifestPath" -ForegroundColor Green
}
