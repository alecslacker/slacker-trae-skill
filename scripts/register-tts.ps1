#requires -Version 7
<#
  register-tts.ps1 — mendaftarkan MCP "dci-tts" ke config agent (TRAE, TRAE SOLO, ZCode, Claude Code).
  Author: Mas Wondho — Duta Corpora Indonesia (DCI)
  Copyright © 2026 Duta Corpora Indonesia

  Bawaan: DRY-RUN (hanya menampilkan rencana). -Apply menulis. -Hapus membalik pendaftaran.
  Cara kerja: menyisipkan/membuang SATU blok teks di config JSON, bukan serialisasi ulang, sehingga isi,
  urutan, dan format server lain tidak berubah. Setiap hasil divalidasi sebelum ditulis (JSON sah, server lain
  utuh). Penulisan atomik. Tidak ada salinan cadangan yang menggandakan rahasia server lain; pembalikan
  lewat -Hapus. Aplikasi yang sedang berjalan perlu direstart agar membaca config baru.
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$Hapus,
    [ValidateSet('trae', 'traesolo', 'zcode', 'claude')]
    [string[]]$Agen = @('trae', 'traesolo', 'zcode', 'claude'),
    [string]$Node = 'C:\nvm4w\nodejs\node.exe',
    [string]$Entri = (Join-Path $HOME '.9router\mcp\dci-tts\src\index.js'),
    [string]$TraeConfig = (Join-Path $env:APPDATA 'Trae\User\mcp.json'),
    [string]$TraeSoloConfig = (Join-Path $env:APPDATA 'TRAE SOLO\User\mcp.json'),
    [string]$ZcodeConfig = (Join-Path $HOME '.zcode\cli\config.json')
)
$ErrorActionPreference = 'Stop'
$NamaServer = 'dci-tts'

function Cari-Kurung([string]$t, [int]$buka) {
    $depth = 0; $dalamString = $false; $lolos = $false
    for ($i = $buka; $i -lt $t.Length; $i++) {
        $c = $t[$i]
        if ($dalamString) {
            if ($lolos) { $lolos = $false }
            elseif ($c -eq [char]'\') { $lolos = $true }
            elseif ($c -eq [char]'"') { $dalamString = $false }
        } else {
            if ($c -eq [char]'"') { $dalamString = $true }
            elseif ($c -eq [char]'{') { $depth++ }
            elseif ($c -eq [char]'}') { $depth--; if ($depth -eq 0) { return $i } }
        }
    }
    return -1
}

function Cari-Objek([string]$t, [string]$kunci, [int]$dari = 0, [int]$sampai = -1) {
    if ($sampai -lt 0) { $sampai = $t.Length - 1 }
    if ($sampai -lt $dari) { return $null }
    $m = [regex]::Match($t.Substring($dari, $sampai - $dari + 1), '"' + [regex]::Escape($kunci) + '"\s*:\s*\{')
    if (-not $m.Success) { return $null }
    $buka = $dari + $m.Index + $m.Length - 1
    $tutup = Cari-Kurung $t $buka
    if ($tutup -lt 0 -or $tutup -gt $sampai) { return $null }
    return [pscustomobject]@{ Kunci = $dari + $m.Index; Buka = $buka; Tutup = $tutup }
}

function Cari-Wadah([string]$t, [string]$jalur) {
    $bagian = $jalur -split '\.'
    $dari = 0; $sampai = -1; $objek = $null
    foreach ($b in $bagian) {
        $objek = Cari-Objek $t $b $dari $sampai
        if (-not $objek) { return $null }
        $dari = $objek.Buka; $sampai = $objek.Tutup
    }
    return $objek
}

function Gaya-BarisBaru([string]$t) { if ($t.Contains("`r`n")) { "`r`n" } else { "`n" } }

function Buat-BlokJson([bool]$denganType) {
    $q = { param($s) ($s | ConvertTo-Json -Compress) }
    $baris = @("`"$NamaServer`": {")
    if ($denganType) { $baris += '  "type": "stdio",' }
    $baris += "  `"command`": $(& $q $Node),"
    $baris += "  `"args`": [$(& $q $Entri)]"
    $baris += '}'
    return $baris
}

function Sisipkan-Blok([string]$t, $wadah, [string[]]$baris) {
    $nl = Gaya-BarisBaru $t
    $isi = $t.Substring($wadah.Buka + 1, $wadah.Tutup - $wadah.Buka - 1)
    $m = [regex]::Match($isi, '(?m)^([ \t]+)"')
    $indent = if ($m.Success) { $m.Groups[1].Value } else { '    ' }
    $blok = ($baris | ForEach-Object { $indent + $_ }) -join $nl
    if ($isi.Trim().Length -eq 0) {
        $indentTutup = if ($indent.Length -ge 2) { $indent.Substring(0, $indent.Length - 2) } else { '' }
        return $t.Substring(0, $wadah.Buka + 1) + $nl + $blok + $nl + $indentTutup + $t.Substring($wadah.Tutup)
    }
    $akhir = $wadah.Tutup - 1
    while ($akhir -gt $wadah.Buka -and [char]::IsWhiteSpace($t[$akhir])) { $akhir-- }
    return $t.Substring(0, $akhir + 1) + ',' + $nl + $blok + $t.Substring($akhir + 1)
}

# Membuang anggota; bila wadah menjadi kosong, dilipat kembali menjadi {} agar sama dengan aslinya.
function Buang-Blok([string]$t, $wadah) {
    $r = Buang-BlokMentah $t $wadah
    if ($null -eq $r) { return $null }
    $tutupBaru = $wadah.Tutup - ($t.Length - $r.Length)
    if ($r.Substring($wadah.Buka + 1, $tutupBaru - $wadah.Buka - 1).Trim().Length -eq 0) {
        return $r.Substring(0, $wadah.Buka + 1) + $r.Substring($tutupBaru)
    }
    return $r
}

function Buang-BlokMentah([string]$t, $wadah) {
    $anggota = Cari-Objek $t $NamaServer ($wadah.Buka + 1) ($wadah.Tutup - 1)
    if (-not $anggota) { return $null }
    $mulai = $anggota.Kunci; $akhir = $anggota.Tutup
    $p = $mulai - 1
    while ($p -gt $wadah.Buka -and [char]::IsWhiteSpace($t[$p])) { $p-- }
    if ($t[$p] -eq [char]',') {
        return $t.Remove($p, $akhir - $p + 1)
    }
    # Anggota pertama: buang bersama koma sesudahnya (bila ada) dan spasi pembuka barisnya.
    $q = $akhir + 1
    while ($q -lt $wadah.Tutup -and [char]::IsWhiteSpace($t[$q])) { $q++ }
    $hapusSampai = if ($q -lt $wadah.Tutup -and $t[$q] -eq [char]',') { $q + 1 } else { $akhir + 1 }
    $awal = $mulai
    while ($awal -gt $wadah.Buka + 1 -and ($t[$awal - 1] -eq [char]' ' -or $t[$awal - 1] -eq [char]"`t")) { $awal-- }
    return $t.Remove($awal, $hapusSampai - $awal)
}

function Ambil-Wadah([string]$t, [string]$jalur) {
    $n = $t | ConvertFrom-Json -AsHashtable
    foreach ($k in ($jalur -split '\.')) {
        if ($n -is [System.Collections.IDictionary] -and $n.Contains($k)) { $n = $n[$k] } else { return $null }
    }
    return $n
}

function Sama-Himpunan($a, $b) {
    $a = @($a); $b = @($b)
    if ($a.Count -ne $b.Count) { return $false }
    if ($a.Count -eq 0) { return $true }
    return (@(Compare-Object $a $b).Count -eq 0)
}

# Mengembalikan alasan kegagalan, atau $null bila hasil sah dan server lain utuh.
function Validasi([string]$lama, [string]$baru, [string]$jalur, [bool]$tambah) {
    try { $dBaru = Ambil-Wadah $baru $jalur } catch { return "JSON hasil tidak sah: $($_.Exception.Message)" }
    $dLama = Ambil-Wadah $lama $jalur
    if ($null -eq $dBaru) { return "wadah '$jalur' hilang pada hasil" }
    $kunciLama = @($dLama.Keys | Where-Object { $_ -ne $NamaServer })
    $kunciBaru = @($dBaru.Keys | Where-Object { $_ -ne $NamaServer })
    if (-not (Sama-Himpunan $kunciLama $kunciBaru)) { return 'himpunan server lain berubah' }
    if ($tambah -ne $dBaru.Contains($NamaServer)) { return $(if ($tambah) { 'server baru tidak muncul' } else { 'server masih ada' }) }
    foreach ($k in $kunciLama) {
        if (($dLama[$k] | ConvertTo-Json -Depth 30 -Compress) -ne ($dBaru[$k] | ConvertTo-Json -Depth 30 -Compress)) { return "definisi server '$k' berubah" }
    }
    $oLama = $lama | ConvertFrom-Json -AsHashtable
    $oBaru = $baru | ConvertFrom-Json -AsHashtable
    $akar = ($jalur -split '\.')[0]
    if (-not (Sama-Himpunan @($oLama.Keys) @($oBaru.Keys))) { return 'kunci tingkat atas berubah' }
    foreach ($k in $oLama.Keys) {
        if ($k -eq $akar) { continue }
        if (($oLama[$k] | ConvertTo-Json -Depth 30 -Compress) -ne ($oBaru[$k] | ConvertTo-Json -Depth 30 -Compress)) { return "bagian '$k' berubah" }
    }
    return $null
}

function Proses-Json([string]$label, [string]$berkas, [string]$jalur, [bool]$denganType) {
    $hasil = { param($s) [pscustomobject]@{ Agen = $label; Status = $s; Berkas = $berkas } }
    if (-not (Test-Path -LiteralPath $berkas)) { return & $hasil 'dilewati: berkas config tidak ada' }
    $bytes = [IO.File]::ReadAllBytes($berkas)
    $bom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $t = [Text.Encoding]::UTF8.GetString($bytes)
    if ($bom) { $t = $t.Substring(1) }
    try { $null = Ambil-Wadah $t $jalur } catch { return & $hasil "GAGAL: config bukan JSON sah ($($_.Exception.Message))" }
    $wadah = Cari-Wadah $t $jalur
    if (-not $wadah) { return & $hasil "GAGAL: wadah '$jalur' tidak ditemukan" }
    $ada = (Ambil-Wadah $t $jalur).Contains($NamaServer)

    if ($Hapus) {
        if (-not $ada) { return & $hasil 'tidak ada (sudah bersih)' }
        $baru = Buang-Blok $t $wadah
        if ($null -eq $baru) { return & $hasil 'GAGAL: blok tidak ditemukan di teks' }
    } else {
        if ($ada) { return & $hasil 'sudah terpasang' }
        $baru = Sisipkan-Blok $t $wadah (Buat-BlokJson $denganType)
    }
    $alasan = Validasi $t $baru $jalur (-not $Hapus)
    if ($alasan) { return & $hasil "GAGAL validasi: $alasan (file tidak diubah)" }
    if (-not $Apply) { return & $hasil $(if ($Hapus) { 'DRY-RUN: akan dibuang' } else { 'DRY-RUN: akan ditambahkan' }) }

    $enc = New-Object System.Text.UTF8Encoding($bom)
    $tmp = "$berkas.dci-tmp"
    [IO.File]::WriteAllText($tmp, $baru, $enc)
    Move-Item -LiteralPath $tmp -Destination $berkas -Force
    $cek = [IO.File]::ReadAllText($berkas)
    if ($bom) { $cek = $cek.TrimStart([char]0xFEFF) }
    if (Validasi $t $cek $jalur (-not $Hapus)) { return & $hasil 'GAGAL: verifikasi pasca-tulis tidak lolos, periksa config manual' }
    return & $hasil $(if ($Hapus) { 'dibuang' } else { 'terpasang (restart aplikasi)' })
}

function Proses-Claude {
    $hasil = { param($s) [pscustomobject]@{ Agen = 'claude'; Status = $s; Berkas = '~/.claude.json (lewat perintah claude)' } }
    $c = Get-Command claude -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $c) { return & $hasil 'dilewati: perintah claude tidak ada di PATH' }
    & $c.Source mcp get $NamaServer *> $null
    $ada = ($LASTEXITCODE -eq 0)
    if ($Hapus) {
        if (-not $ada) { return & $hasil 'tidak ada (sudah bersih)' }
        if (-not $Apply) { return & $hasil "DRY-RUN: claude mcp remove $NamaServer --scope user" }
        & $c.Source mcp remove $NamaServer --scope user *> $null
        return & $hasil $(if ($LASTEXITCODE -eq 0) { 'dibuang' } else { "GAGAL: claude mcp remove kode $LASTEXITCODE" })
    }
    if ($ada) { return & $hasil 'sudah terpasang' }
    if (-not $Apply) { return & $hasil "DRY-RUN: claude mcp add --scope user $NamaServer -- `"$Node`" `"$Entri`"" }
    & $c.Source mcp add --scope user $NamaServer -- $Node $Entri *> $null
    return & $hasil $(if ($LASTEXITCODE -eq 0) { 'terpasang (sesi Claude Code baru)' } else { "GAGAL: claude mcp add kode $LASTEXITCODE" })
}

if (-not $Hapus -and $Apply) {
    if (-not (Test-Path -LiteralPath $Node)) { throw "Node.js tidak ditemukan di $Node" }
    if (-not (Test-Path -LiteralPath $Entri)) { throw "Titik masuk belum terpasang: $Entri. Jalankan scripts\install-tts.ps1 -Apply dulu." }
}

$baris = @()
foreach ($a in $Agen) {
    switch ($a) {
        'trae'     { $baris += Proses-Json 'trae' $TraeConfig 'mcpServers' $false }
        'traesolo' { $baris += Proses-Json 'traesolo' $TraeSoloConfig 'mcpServers' $false }
        'zcode'    { $baris += Proses-Json 'zcode' $ZcodeConfig 'mcp.servers' $true }
        'claude'   { $baris += Proses-Claude }
    }
}
if (-not $Apply) { Write-Host 'DRY-RUN: tidak ada yang diubah. Tambahkan -Apply untuk menulis.' -ForegroundColor Yellow }
$baris | Format-Table Agen, Status, Berkas -AutoSize -Wrap
if (@($baris | Where-Object { $_.Status -like 'GAGAL*' }).Count -gt 0) { exit 1 }
