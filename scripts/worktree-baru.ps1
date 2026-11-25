# worktree-baru.ps1 — Buat git worktree terisolasi per fitur untuk multi-session TRAE
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
#
# Pemakaian: .\scripts\worktree-baru.ps1 -Fitur "fitur-a"
# Hasil    : folder sibling "..\<repo>-fitur-a\" + branch "fitur-a" + PROMPT-SESI.md (template scope)
# Hapus    : git worktree remove "..\<repo>-fitur-a" lalu git branch -d fitur-a

param(
    [Parameter(Mandatory = $true)]
    [string]$Fitur
)

# Cegah nama fitur mengandung karakter berbahaya untuk path/branch
if ($Fitur -notmatch '^[a-z0-9][a-z0-9-]*$') {
    Write-Error "Nama fitur hanya boleh huruf kecil, angka, dan tanda hubung (contoh: fitur-a)."
    exit 1
}

# Pastikan dijalankan di dalam repo git
git rev-parse --show-toplevel *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Folder ini bukan repo git. Jalankan dari root repo."
    exit 1
}

$repoRoot = (git rev-parse --show-toplevel).Trim()
$repoName = Split-Path $repoRoot -Leaf
$branch   = $Fitur
$worktree = Join-Path (Split-Path $repoRoot -Parent) "$repoName-$Fitur"

# Tolak bila folder/branch sudah ada (jangan menimpa kerjaan sesi lain)
if (Test-Path $worktree) {
    Write-Error "Folder worktree sudah ada: $worktree — pilih nama fitur lain atau hapus dulu."
    exit 1
}
git show-ref --verify --quiet "refs/heads/$branch"
if ($LASTEXITCODE -eq 0) {
    Write-Error "Branch '$branch' sudah ada — pilih nama lain atau hapus branch tersebut."
    exit 1
}

git worktree add $worktree -b $branch
if ($LASTEXITCODE -ne 0) {
    Write-Error "git worktree add gagal."
    exit 1
}

# Template pembatas scope: paste sebagai pesan pertama di sesi TRAE baru di folder worktree
$prompt = @"
## Sesi Terisolasi — $Fitur

Sesi ini HANYA mengerjakan fitur [$Fitur] di workspace [$(Split-Path $worktree -Leaf)].
Branch: $branch. Workspace lain adalah milik sesi lain.

Aturan:
1. Jangan membaca, melanjutkan, atau menanyakan pekerjaan di luar scope fitur [$Fitur].
2. git status / git diff hanya untuk file dalam scope sendiri.
3. Commit per path: git add <path-fitur>, bukan git add .
4. Dokumen dinamai per fitur: plan-$Fitur.md
5. Memory project diberi label: [Fitur $Fitur]
"@

Set-Content -Path (Join-Path $worktree "PROMPT-SESI.md") -Value $prompt -Encoding UTF8

Write-Host ""
Write-Host "Worktree siap : $worktree"
Write-Host "Branch        : $branch"
Write-Host "Langkah       : buka folder tersebut sebagai workspace terpisah di TRAE,"
Write-Host "                lalu paste isi PROMPT-SESI.md sebagai pesan pertama sesinya."
