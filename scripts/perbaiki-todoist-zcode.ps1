# perbaiki-todoist-zcode.ps1 - perbaiki format Todoist di config Z Code
# Masalah: command berisi spasi ("npx -y paket") - harus "npx" + args terpisah.
# Author: Mas Wondho - Duta Corpora Indonesia (DCI)
$ErrorActionPreference = 'Stop'
$p = Join-Path $HOME '.zcode\cli\config.json'
$raw = Get-Content $p -Raw
$lama = '"command": "npx -y @abhiz123/todoist-mcp-server",'
$baru = '"command": "npx",`r`n        "args": [`r`n          "-y",`r`n          "@abhiz123/todoist-mcp-server"`r`n        ],'
if ($raw.Contains($lama)) {
    $raw = $raw.Replace($lama, $baru)
    Set-Content -Path $p -Value $raw -Encoding UTF8
    'FIXED: Todoist command dipecah jadi command+args'
} else {
    'SKIP: pola lama tidak ditemukan (mungkin sudah benar)'
}
# Validasi
& 'C:\laragon\bin\nodejs\node-v26.13.0-win-x64\node.exe' -e "const c=JSON.parse(require('fs').readFileSync(process.env.USERPROFILE+'/.zcode/cli/config.json','utf8').replace(/^\uFEFF/,'')); const t=c.mcp.servers.Todoist; console.log('Todoist command:', t.command, '| args:', JSON.stringify(t.args)); console.log('config VALID,', Object.keys(c.mcp.servers).length, 'server')"
