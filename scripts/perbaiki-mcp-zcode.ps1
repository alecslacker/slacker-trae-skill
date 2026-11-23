# perbaiki-mcp-zcode.ps1 - perbaiki command MCP Z Code agar spawn-able di Windows
# Akar masalah: npx/uvx adalah shell-script POSIX (bukan exe Win32). Z Code desktop
# spawn langsung tanpa shell -> "%1 is not a valid Win32 application" -> loading terus.
# Solusi: pakai wrapper .cmd (npx.cmd / uvx.exe) + path absolut yang resolve akurat.
# Author: Mas Wondho - Duta Corpora Indonesia (DCI)
$ErrorActionPreference = 'Stop'
$node = 'C:\laragon\bin\nodejs\node-v26.13.0-win-x64\node.exe'
$p = Join-Path $HOME '.zcode\cli\config.json'

# Resolve path nyata tiap launcher
$npxCmd   = (Get-Command npx.cmd  -ErrorAction SilentlyContinue).Source
$pythonExe = (Get-Command python  -ErrorAction SilentlyContinue).Source
$uvxExe    = (Get-Command uvx     -ErrorAction SilentlyContinue).Source
"resolve: npx.cmd=$npxCmd | python=$pythonExe | uvx=$uvxExe"

$raw = Get-Content $p -Raw -Encoding UTF8
# Normalisasi "command": "npx"  -> "npx.cmd" (jangan sentuh npx di dalam args)
$raw = $raw -replace '"command":\s*"npx"', ('"command": "' + $npxCmd.Replace('\','\\') + '"')
$raw = $raw -replace '"command":\s*"python"', ('"command": "' + $pythonExe.Replace('\','\\') + '"')
$raw = $raw -replace '"command":\s*"uvx"', ('"command": "' + $uvxExe.Replace('\','\\') + '"')
Set-Content -Path $p -Value $raw -Encoding UTF8

# Validasi
& $node -e "const c=JSON.parse(require('fs').readFileSync(process.env.USERPROFILE+'/.zcode/cli/config.json','utf8').replace(/^\uFEFF/,'')); for(const [k,v] of Object.entries(c.mcp.servers)){ if(v.command) console.log(k.padEnd(20), '->', v.command); }"
