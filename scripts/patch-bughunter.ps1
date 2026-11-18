# ============================================================
# patch-bughunter.ps1 — Patch agentic-bug-hunter agar kompatibel
# dengan gateway OpenAI-compatible yang menambahkan sentinel SSE
# ("data: [DONE]") pada respons non-streaming.
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
# ============================================================
# Masalah: banyak gateway (mis. 9router) mengirim `data: [DONE]`
# di akhir body walau request bukan streaming. `r.json()` lalu gagal
# dengan JSONDecodeError "Extra data: line 1 column N".
# Solusi : (1) kirim "stream": false eksplisit; (2) potong sentinel
# sebelum parsing. Idempoten — aman dijalankan berulang.
#
# Cara pakai:  .\scripts\patch-bughunter.ps1

$ErrorActionPreference = 'Stop'

$brain = Join-Path $env:APPDATA 'uv\tools\agentic-bug-hunter\Lib\site-packages\bughunter\brain.py'

if (-not (Test-Path $brain)) {
    Write-Host "[X] brain.py tidak ditemukan: $brain" -ForegroundColor Red
    Write-Host '    Install dulu: uv tool install --force "git+https://github.com/awarexone/Agentic-Bug-Hunter.git"' -ForegroundColor Yellow
    exit 1
}

$raw = Get-Content $brain -Raw -Encoding UTF8

# Sudah dipatch? (cari penanda unik)
if ($raw -match 'data: \[DONE\]') {
    Write-Host '[=] brain.py sudah dipatch — tidak ada perubahan.' -ForegroundColor Green
    exit 0
}

$target = @'
        body = {"model": m, "max_tokens": max_tokens, "temperature": temperature,
                "messages": [{"role": "system", "content": system},
                             {"role": "user",   "content": user}]}
'@

$replacement = @'
        body = {"model": m, "max_tokens": max_tokens, "temperature": temperature,
                "stream": False,
                "messages": [{"role": "system", "content": system},
                             {"role": "user",   "content": user}]}
'@

if (-not $raw.Contains($target)) {
    Write-Host '[X] Pola target tidak ketemu — versi brain.py berubah. Patch manual diperlukan.' -ForegroundColor Red
    exit 1
}

$raw = $raw.Replace($target, $replacement)

$parseTarget = '        return r.json()["choices"][0]["message"]["content"].strip()'
$parseReplacement = @'
        # Some OpenAI-compatible gateways append an SSE sentinel ("data: [DONE]")
        # even to non-streaming responses, which makes a plain r.json() fail with
        # "Extra data". Recover the first JSON document before the sentinel.
        text = r.text.strip()
        sentinel = text.find("data: [DONE]")
        if sentinel != -1:
            text = text[:sentinel].strip()
        return _json.loads(text)["choices"][0]["message"]["content"].strip()
'@

if (-not $raw.Contains($parseTarget)) {
    Write-Host '[X] Pola parser tidak ketemu — patch manual diperlukan.' -ForegroundColor Red
    exit 1
}

$raw = $raw.Replace($parseTarget, $parseReplacement)

Copy-Item $brain "$brain.bak" -Force
Set-Content -Path $brain -Value $raw -Encoding UTF8 -NoNewline

Write-Host '[OK] brain.py berhasil dipatch.' -ForegroundColor Green
Write-Host "     Backup: $brain.bak" -ForegroundColor DarkGray
