#requires -Version 7
<#
  uji-register.ps1 — menguji register-imagegen.ps1 pada config SINTETIS (tidak menyentuh config agent asli).
  Author: Mas Wondho — Duta Corpora Indonesia (DCI)
  Copyright © 2026 Duta Corpora Indonesia

  Kode keluar 0 bila semua pemeriksaan lolos.
#>
$ErrorActionPreference = 'Stop'
$reg = Join-Path $PSScriptRoot 'register-imagegen.ps1'
$u = Join-Path $env:TEMP ('dci-uji-register-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $u | Out-Null
$entri = Join-Path $u 'runtime\src\index.js'
New-Item -ItemType Directory -Force -Path (Split-Path $entri) | Out-Null
'x' | Set-Content $entri
$gagal = New-Object System.Collections.Generic.List[string]
$utf8 = New-Object System.Text.UTF8Encoding($false)
$utf8bom = New-Object System.Text.UTF8Encoding($true)

function Cek([string]$nama, [bool]$ok) {
    if ($ok) { Write-Host "  OK    $nama" -ForegroundColor Green } else { Write-Host "  GAGAL $nama" -ForegroundColor Red; $gagal.Add($nama) }
}
function Hash([string]$f) { (Get-FileHash $f -Algorithm MD5).Hash }
function Tulis([string]$nama, [string]$isi, $enc = $utf8) { $p = Join-Path $u $nama; [IO.File]::WriteAllText($p, $isi, $enc); $p }
function Reg([string]$berkas, [string]$agen, [string]$ekstra = '') {
    $cfg = if ($agen -eq 'zcode') { '-ZcodeConfig' } elseif ($agen -eq 'traesolo') { '-TraeSoloConfig' } else { '-TraeConfig' }
    $cmd = "& '$reg' -Agen $agen -Entri '$entri' $cfg '$berkas' $ekstra"
    $o = & pwsh -NoProfile -Command $cmd 2>&1 | ForEach-Object { "$_" }
    [pscustomobject]@{ Exit = $LASTEXITCODE; Teks = ($o -join ' ') }
}

# Bentuk config meniru yang asli: server berbasis command, berbasis url/headers, dan sebuah rahasia (nilai samaran).
$trae = @'
{
  "mcpServers": {
    "context7": {
      "url": "https://mcp.example/mcp",
      "headers": { "CONTEXT7_API_KEY": "kunci-palsu-1" }
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "Time": {
      "command": "uvx.exe",
      "args": ["mcp-server-time"],
      "env": { "TZ": "Asia/Jakarta" },
      "fromGalleryId": "x"
    }
  }
}
'@
$zcode = @'
{
  "mcp": {
    "servers": {
      "context7": { "type": "stdio", "command": "node.exe", "args": ["a.js"], "env": { "CONTEXT7_API_KEY": "kunci-palsu-2" } },
      "rea": { "command": "node.exe", "args": ["b.js"] }
    }
  },
  "plugins": { "x@y": true }
}
'@

Write-Host '1. Dry-run tidak mengubah apa pun'
$tr = Tulis 'trae.json' $trae; $zc = Tulis 'zcode.json' $zcode
$h = @{ trae = Hash $tr; zcode = Hash $zc }
$r = Reg $tr 'trae'; Cek 'dry-run trae menyebut DRY-RUN' ($r.Teks -match 'DRY-RUN: akan ditambahkan')
$r = Reg $zc 'zcode'; Cek 'dry-run zcode menyebut DRY-RUN' ($r.Teks -match 'DRY-RUN: akan ditambahkan')
Cek 'berkas tak berubah' ((Hash $tr) -eq $h.trae -and (Hash $zc) -eq $h.zcode)

Write-Host '2. Apply: server baru ada, server lain utuh'
$r = Reg $tr 'trae' '-Apply'; Cek 'apply trae sukses' ($r.Exit -eq 0 -and $r.Teks -match 'terpasang')
$o = [IO.File]::ReadAllText($tr) | ConvertFrom-Json -AsHashtable
Cek 'trae: dci-imagegen ada tanpa field type' ($o.mcpServers.Contains('dci-imagegen') -and -not $o.mcpServers['dci-imagegen'].Contains('type'))
Cek 'trae: 3 server lama utuh' (($o.mcpServers.Keys | Where-Object { $_ -ne 'dci-imagegen' }).Count -eq 3 -and $o.mcpServers.context7.headers.CONTEXT7_API_KEY -eq 'kunci-palsu-1' -and $o.mcpServers.Time.fromGalleryId -eq 'x')
$r = Reg $zc 'zcode' '-Apply'; Cek 'apply zcode sukses' ($r.Exit -eq 0)
$o = [IO.File]::ReadAllText($zc) | ConvertFrom-Json -AsHashtable
Cek 'zcode: dci-imagegen bertipe stdio di mcp.servers' ($o.mcp.servers['dci-imagegen'].type -eq 'stdio')
Cek 'zcode: bagian plugins utuh' ($o.plugins['x@y'] -eq $true -and $o.mcp.servers.context7.env.CONTEXT7_API_KEY -eq 'kunci-palsu-2')
Cek 'command memakai path Node absolut' ($o.mcp.servers['dci-imagegen'].command -match '^[A-Za-z]:\\')

Write-Host '3. Idempoten dan pembalikan persis'
$setelah = @{ trae = Hash $tr; zcode = Hash $zc }
$null = Reg $tr 'trae' '-Apply'; $null = Reg $zc 'zcode' '-Apply'
Cek 'apply kedua tidak mengubah apa pun' ((Hash $tr) -eq $setelah.trae -and (Hash $zc) -eq $setelah.zcode)
$r = Reg $tr 'trae'; Cek 'dry-run sesudah terpasang: "sudah terpasang"' ($r.Teks -match 'sudah terpasang')
$null = Reg $tr 'trae' '-Apply -Hapus'; $null = Reg $zc 'zcode' '-Apply -Hapus'
Cek 'hapus mengembalikan trae PERSIS (byte per byte)' ((Hash $tr) -eq $h.trae)
Cek 'hapus mengembalikan zcode PERSIS (byte per byte)' ((Hash $zc) -eq $h.zcode)
$r = Reg $tr 'trae' '-Apply -Hapus'; Cek 'hapus saat tidak ada: "sudah bersih"' ($r.Exit -eq 0 -and $r.Teks -match 'sudah bersih')

Write-Host '4. Kasus tepi'
$k = Tulis 'kosong.json' "{`n  `"mcpServers`": {}`n}`n"; $hk = Hash $k
$null = Reg $k 'trae' '-Apply'; $null = Reg $k 'trae' '-Apply -Hapus'
Cek 'wadah kosong: tambah lalu hapus kembali persis' ((Hash $k) -eq $hk)
$k2 = Tulis 'kosong-crlf.json' "{`r`n  `"mcpServers`": {}`r`n}`r`n"; $hk2 = Hash $k2
$null = Reg $k2 'trae' '-Apply'; $null = Reg $k2 'trae' '-Apply -Hapus'
Cek 'wadah kosong CRLF: kembali persis' ((Hash $k2) -eq $hk2)
$k3 = Tulis 'satu-baris.json' '{"mcpServers":{}}'; $hk3 = Hash $k3
$null = Reg $k3 'trae' '-Apply'; $null = Reg $k3 'trae' '-Apply -Hapus'
Cek 'JSON satu baris: kembali persis' ((Hash $k3) -eq $hk3)
$b = Tulis 'bom.json' "{`r`n  `"mcpServers`": {`r`n    `"a`": { `"command`": `"x`" }`r`n  }`r`n}`r`n" $utf8bom; $hb = Hash $b
$null = Reg $b 'trae' '-Apply'
$bytes = [IO.File]::ReadAllBytes($b); $teks = [Text.Encoding]::UTF8.GetString($bytes)
Cek 'BOM tetap ada' ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
Cek 'CRLF konsisten (tidak ada LF sendirian)' (-not [regex]::IsMatch($teks, '(?<!\r)\n'))
$null = Reg $b 'trae' '-Apply -Hapus'; Cek 'BOM+CRLF: kembali persis' ((Hash $b) -eq $hb)

Write-Host '5. Penolakan aman (file tidak boleh berubah)'
$tw = Tulis 'tanpa-wadah.json' "{`n  `"lain`": 1`n}`n"; $htw = Hash $tw
$r = Reg $tw 'trae' '-Apply'; Cek 'tanpa wadah: GAGAL, exit 1, file utuh' ($r.Exit -eq 1 -and $r.Teks -match 'GAGAL' -and (Hash $tw) -eq $htw)
$rk = Tulis 'rusak.json' '{ ini bukan json'; $hr = Hash $rk
$r = Reg $rk 'trae' '-Apply'; Cek 'JSON rusak: GAGAL, exit 1, file utuh' ($r.Exit -eq 1 -and (Hash $rk) -eq $hr)
$r = Reg (Join-Path $u 'tidak-ada.json') 'trae' '-Apply'; Cek 'berkas tidak ada: dilewati, exit 0' ($r.Exit -eq 0 -and $r.Teks -match 'dilewati')
$hk = Hash $k
$p = Start-Process pwsh -ArgumentList '-NoProfile', '-Command', "& '$reg' -Agen trae -Entri '$u\tidak\ada.js' -TraeConfig '$k' -Apply" -Wait -PassThru -NoNewWindow -RedirectStandardError (Join-Path $u 'e.txt') -RedirectStandardOutput (Join-Path $u 'o.txt')
Cek 'apply tanpa runtime terpasang: exit 1, config utuh' ($p.ExitCode -eq 1 -and (Hash $k) -eq $hk)

Write-Host '6. Claude Code: dry-run memakai perintah claude dan tidak menulis'
$adaClaude = [bool](Get-Command claude -ErrorAction SilentlyContinue)
$sudahTerdaftar = $false
if ($adaClaude) { & claude mcp get dci-imagegen *> $null; $sudahTerdaftar = ($LASTEXITCODE -eq 0) }
if (-not $adaClaude) { Write-Host '  SKIP  claude tidak ada di PATH' -ForegroundColor Yellow }
elseif ($sudahTerdaftar) {
    # Pendaftaran Claude Code memakai --scope user (global), tidak bisa dialihkan ke folder uji.
    Write-Host '  SKIP  dci-imagegen sudah terdaftar di Claude Code mesin ini; uji dry-run hanya bermakna sebelum pendaftaran' -ForegroundColor Yellow
} else {
    $r = & pwsh -NoProfile -Command "& '$reg' -Agen claude -Entri '$entri'" 2>&1 | ForEach-Object { "$_" }
    $teks = $r -join ' '
    Cek 'dry-run claude menampilkan perintah claude mcp add' ($teks -match 'claude mcp add --scope user dci-imagegen')
    & claude mcp get dci-imagegen *> $null
    Cek 'dry-run tidak mendaftarkan apa pun di Claude Code' ($LASTEXITCODE -ne 0)
}

Remove-Item $u -Recurse -Force
if ($gagal.Count -gt 0) { Write-Host "`n$($gagal.Count) pemeriksaan GAGAL." -ForegroundColor Red; exit 1 }
Write-Host "`nSemua pemeriksaan lolos." -ForegroundColor Green
