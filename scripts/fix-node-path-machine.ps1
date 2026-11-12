# fix-node-path-machine.ps1 - hapus entri Node standalone dari PATH Machine
# Tujuan: Laragon node-v26.13.0 (PATH User) menjadi Node utama.
# Author: Mas Wondho - Duta Corpora Indonesia (DCI)
$ErrorActionPreference = 'Stop'
$log = "$env:TEMP\node-path-fix-result.txt"
try {
    $p = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $before = ($p -split ';') | Where-Object { $_ -match 'node' }
    # Buang entri C:\Program Files\nodejs (dengan/tanpa trailing backslash)
    $parts = $p -split ';' | Where-Object { $_ -and ($_.TrimEnd('\') -ne 'C:\Program Files\nodejs') }
    [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'Machine')
    $after = ([Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';') | Where-Object { $_ -match 'node' }
    "SEBELUM: $($before -join ' | ')" | Out-File $log -Encoding ASCII
    "SESUDAH: $($after -join ' | ')"  | Out-File $log -Append -Encoding ASCII
    "STATUS: OK" | Out-File $log -Append -Encoding ASCII
} catch {
    "STATUS: GAGAL - $($_.Exception.Message)" | Out-File $log -Encoding ASCII
}
