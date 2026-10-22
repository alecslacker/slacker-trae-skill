# install-rea.ps1 — Setup REA (Reverse Engineer Anything) lengkap di komputer mana pun
# Sumber kebenaran: repo GitHub slacker-trae-skill (bagian dari trae-skills).
# Idempoten: aman dijalankan berulang; komponen yang sudah ada & valid dilewati.
#
# Yang dipasang (semua ke C:\tools, tanpa admin):
#   1. rea-agents        : npm global (butuh Node >= 22.19 / 24.11 / 26)
#   2. JDK 21 (Temurin)  : portable zip -> C:\tools\jdk-21
#   3. Ghidra 12.1.4     : zip -> C:\tools\ghidra_12.1.4_PUBLIC   (versi diverifikasi REA — jangan ganti 12.2+ sebelum REA mendukung)
#   4. JAR jadx-headless-mcp 0.7.1 -> C:\tools\jadx-headless-mcp-0.7.1-all.jar (analisis APK Android; SHA-256 diverifikasi)
#   5. Env user permanen : GHIDRA_INSTALL_DIR, JAVA_HOME, REA_ANALYSIS_PROVIDER, REA_JADX_MCP_JAR
#   6. Registrasi MCP rea: Claude Code + Codex + ZCode (via setup resmi REA; backup *.rea.backup otomatis)
#   7. Skill             : sudah ada di repo skills/reverse-engineer-anything (distribusi via sync-*.ps1, BUKAN via rea setup)
#
# Pemakaian:
#   .\scripts\install-rea.ps1          # install/refresh semua
#   .\scripts\install-rea.ps1 -Doctor  # hanya cek kesehatan (rea doctor), tanpa install
#
# Update versi di kemudian hari: edit $ReaVersion / $GhidraVersion / $JadxVersion + URL di bawah,
# lalu commit + push — komputer lain tinggal git pull lalu jalankan ulang script ini.

param(
    [switch]$Doctor  # hanya jalankan rea doctor, lewati install
)

$ErrorActionPreference = 'Stop'

# --- Versi terpasang (SATU sumber kebenaran — update di sini lalu push) ---
$ReaVersion   = '6.7.0'
$GhidraUrl    = 'https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip'
$GhidraDir    = 'ghidra_12.1.4_PUBLIC'
$JadxUrl      = 'https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar'
$JadxSha256   = '6E5EACF500B64292BFB73C49797C1958F6EE44646E43E868039AE7FEB573FF75'   # dari halaman release upstream
$JdkUrl       = 'https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk'

$ToolsDir = 'C:\tools'
foreach ($p in @($ToolsDir)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }

function Get-UserEnv([string]$name) { [Environment]::GetEnvironmentVariable($name, 'User') }
function Set-UserEnvIfMissing([string]$name, [string]$value) {
    $cur = Get-UserEnv $name
    if ($cur -ne $value) {
        [Environment]::SetEnvironmentVariable($name, $value, 'User')
        Write-Host "ENV  : $name = $value (user, permanen)"
    }
    Set-Item -Path ("Env:\" + $name) -Value $value   # sesi ini juga
}

if ($Doctor) {
    Write-Host '=== MODE DOCTOR (tanpa install) ==='
    rea doctor
    exit $LASTEXITCODE
}

# --- 0. Node.js check ---
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error 'Node.js belum terpasang. Install Node LTS >= 24.11 dulu: https://nodejs.org'
}
$nodeVer = (node --version)
Write-Host "Node : $nodeVer"

# --- 1. rea-agents (npm global) ---
$reaInstalled = $false
try { $reaInstalled = ((rea --version 2>$null) -match $ReaVersion) } catch {}
if ($reaInstalled) {
    Write-Host "REA  : rea-agents $ReaVersion sudah terpasang — lewati"
} else {
    Write-Host "REA  : install rea-agents@$ReaVersion (npm global)..."
    npm install --global rea-agents
}

# --- 2. JDK 21 (portable zip) ---
if (Test-Path 'C:\tools\jdk-21\bin\java.exe') {
    Write-Host 'JDK  : C:\tools\jdk-21 sudah ada — lewati'
} else {
    Write-Host 'JDK  : unduh Temurin 21 (zip portable)...'
    $jdkZip = Join-Path $ToolsDir 'jdk21.zip'
    curl.exe -L --retry 5 --retry-delay 5 -o $jdkZip $JdkUrl
    Expand-Archive -Path $jdkZip -DestinationPath (Join-Path $ToolsDir 'jdk-tmp') -Force
    $dir = Get-ChildItem (Join-Path $ToolsDir 'jdk-tmp') -Directory | Select-Object -First 1
    Move-Item $dir.FullName 'C:\tools\jdk-21'
    Remove-Item (Join-Path $ToolsDir 'jdk-tmp') -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $jdkZip -Force -ErrorAction SilentlyContinue
    Write-Host 'JDK  : terpasang di C:\tools\jdk-21'
}

# --- 3. Ghidra 12.1.4 ---
if (Test-Path (Join-Path $ToolsDir "$GhidraDir\support\analyzeHeadless.bat")) {
    Write-Host "GHIDRA: $ToolsDir\$GhidraDir sudah ada — lewati"
} else {
    Write-Host 'GHIDRA: unduh Ghidra 12.1.4 (~543 MB, sabar)...'
    $gZip = Join-Path $ToolsDir 'ghidra.zip'
    curl.exe -L --retry 5 --retry-delay 5 -o $gZip $GhidraUrl
    Expand-Archive -Path $gZip -DestinationPath $ToolsDir -Force
    Remove-Item $gZip -Force
    Write-Host "GHIDRA: terpasang di $ToolsDir\$GhidraDir"
}

# --- 4. JAR JADX (analisis APK) ---
$jadxPath = Join-Path $ToolsDir 'jadx-headless-mcp-0.7.1-all.jar'
$jadxOk = $false
if (Test-Path $jadxPath) {
    $h = (Get-FileHash $jadxPath -Algorithm SHA256).Hash
    if ($h -eq $JadxSha256) { $jadxOk = $true; Write-Host 'JADX : JAR sudah ada & SHA-256 cocok — lewati' }
    else { Write-Host 'JADX : JAR ada tapi hash BEDA — unduh ulang'; Remove-Item $jadxPath -Force }
}
if (-not $jadxOk) {
    Write-Host 'JADX : unduh jadx-headless-mcp 0.7.1 (~40 MB)...'
    curl.exe -L --retry 5 --retry-delay 5 -o $jadxPath $JadxUrl
    $h = (Get-FileHash $jadxPath -Algorithm SHA256).Hash
    if ($h -ne $JadxSha256) { Write-Error "JADX : SHA-256 TIDAK COCOK (dapat $h). File bisa korup — hapus & ulangi." }
    Write-Host 'JADX : SHA-256 terverifikasi'
}

# --- 5. Env permanen ---
Set-UserEnvIfMissing 'GHIDRA_INSTALL_DIR'  (Join-Path $ToolsDir $GhidraDir)
Set-UserEnvIfMissing 'JAVA_HOME'           'C:\tools\jdk-21'
Set-UserEnvIfMissing 'REA_ANALYSIS_PROVIDER' 'ghidra'
Set-UserEnvIfMissing 'REA_JADX_MCP_JAR'    $jadxPath

# --- 6. Registrasi MCP ke agent (setup resmi REA; --skill=false karena skill
#        didistribusikan lewat repo trae-skills + sync-*.ps1, bukan rea setup) ---
Write-Host 'MCP  : registrasi rea ke Claude Code + Codex + ZCode...'
rea setup --client claude_code --client codex --client zcode --skill=false --yes

# --- 7. Doctor akhir ---
Write-Host ''
Write-Host '=== VERIFIKASI AKHIR (rea doctor) ===' -ForegroundColor Cyan
rea doctor

Write-Host ''
Write-Host '=== INSTALL REA SELESAI ===' -ForegroundColor Green
Write-Host 'Skill reverse-engineer-anything: distribusi via repo (sync-claude/sync-zcode/sync-codex + install.ps1).'
Write-Host 'Restart Claude Code / Codex / Z Code agar MCP terbaru terbaca.'
