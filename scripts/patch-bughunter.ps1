# ============================================================
# patch-bughunter.ps1 — Patch kompatibilitas agentic-bug-hunter
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
# ============================================================
# Toolkit ini dirancang untuk POSIX/Linux. Supaya jalan baik di Windows
# maupun di belakang gateway OpenAI-compatible (mis. 9router), ada 4 patch:
#
#   1. brain.py  — kirim "stream": false eksplisit
#                  (gateway tertentu menambah SSE sentinel "data: [DONE]"
#                   pada respons non-streaming -> JSONDecodeError "Extra data")
#   2. brain.py  — potong sentinel sebelum json.loads (jaring pengaman)
#   3. brain.py  — retry otomatis bila content kosong karena model
#                  reasoning-heavy menghabiskan budget di reasoning tokens
#   4. engine.py — resolve bash ke Git Bash, bukan stub WSL
#                  (C:\Program Files\WSL\bash.exe gagal tanpa distro)
#
# Idempoten: aman dijalankan berulang. Setiap patch diperiksa dulu.
# Jalankan ulang setelah `uv tool install --force` / update toolkit.
#
# Cara pakai:  .\scripts\patch-bughunter.ps1

$ErrorActionPreference = 'Stop'

$sitePkgs = Join-Path $env:APPDATA 'uv\tools\agentic-bug-hunter\Lib\site-packages\bughunter'
$brain  = Join-Path $sitePkgs 'brain.py'
$engine = Join-Path $sitePkgs 'engine.py'

foreach ($f in @($brain, $engine)) {
    if (-not (Test-Path $f)) {
        Write-Host "[X] Tidak ditemukan: $f" -ForegroundColor Red
        Write-Host '    Install dulu:' -ForegroundColor Yellow
        Write-Host '    uv tool install --force "git+https://github.com/awarexone/Agentic-Bug-Hunter.git"' -ForegroundColor Yellow
        exit 1
    }
}

$applied = 0
$skipped = 0

# ---------- Patch 1+2: brain.py stream + sentinel + retry reasoning ----------
$raw = Get-Content $brain -Raw -Encoding UTF8

if ($raw -match '_parse_completion') {
    Write-Host '[=] brain.py — sudah dipatch (stream/sentinel/retry).' -ForegroundColor Green
    $skipped++
} else {
    $oldBlock = @'
        r.raise_for_status()
        return r.json()["choices"][0]["message"]["content"].strip()
'@

    $newBlock = @'
        r.raise_for_status()
        payload = self._parse_completion(r)
        content = (payload["choices"][0]["message"].get("content") or "").strip()
        # Reasoning-first models spend the whole budget on hidden reasoning tokens
        # and return an empty `content` with finish_reason=length. Retry with a
        # larger budget so the answer actually lands in `content`.
        attempts = 0
        while not content and attempts < 2:
            attempts += 1
            budget_used = payload.get("usage", {}).get("completion_tokens") or max_tokens
            body["max_tokens"] = max(int(budget_used * 3), max_tokens * 3, 4000)
            r = self._http.post(f"{base}/chat/completions",
                                data=_json.dumps(body), timeout=180)
            r.raise_for_status()
            payload = self._parse_completion(r)
            content = (payload["choices"][0]["message"].get("content") or "").strip()
        return content

    @staticmethod
    def _parse_completion(r) -> dict:
        import json as _json
        # Some OpenAI-compatible gateways append an SSE sentinel ("data: [DONE]")
        # even to non-streaming responses, which makes a plain r.json() fail with
        # "Extra data". Recover the first JSON document before the sentinel.
        text = r.text.strip()
        sentinel = text.find("data: [DONE]")
        if sentinel != -1:
            text = text[:sentinel].strip()
        return _json.loads(text)
'@

    if (-not $raw.Contains($oldBlock)) {
        Write-Host '[X] brain.py — pola parser tidak ketemu. Versi berubah; patch manual.' -ForegroundColor Red
        exit 1
    }
    $raw = $raw.Replace($oldBlock, $newBlock)

    # Tambah "stream": False pada body request
    $oldBody = @'
        body = {"model": m, "max_tokens": max_tokens, "temperature": temperature,
                "messages": [{"role": "system", "content": system},
'@
    $newBody = @'
        body = {"model": m, "max_tokens": max_tokens, "temperature": temperature,
                "stream": False,
                "messages": [{"role": "system", "content": system},
'@
    if ($raw.Contains($oldBody)) {
        $raw = $raw.Replace($oldBody, $newBody)
    } else {
        Write-Host '[X] brain.py — pola body tidak ketemu; patch manual.' -ForegroundColor Red
        exit 1
    }

    Copy-Item $brain "$brain.bak" -Force
    Set-Content -Path $brain -Value $raw -Encoding UTF8 -NoNewline
    Write-Host '[OK] brain.py — stream:false + sentinel guard + retry reasoning.' -ForegroundColor Green
    $applied++
}

# ---------- Patch 3: engine.py resolve bash (hindari stub WSL) ----------
$eng = Get-Content $engine -Raw -Encoding UTF8

if ($eng -match '_resolve_bash') {
    Write-Host '[=] engine.py — sudah dipatch (bash resolver).' -ForegroundColor Green
    $skipped++
} else {
    $anchor = @'
def _run_shell(cmd: list[str], cwd: str | None = None, timeout: int = 3600,
'@

    $resolver = @'
def _resolve_bash() -> str:
    """Return a usable bash executable.

    On Windows, `bash` on PATH often resolves to the WSL stub installed by
    C:\Program Files\WSL\, which fails unless a WSL distribution is
    installed. Prefer Git Bash when present so the .sh tooling runs without
    a Linux subsystem. Honours BUGHUNTER_BASH when set explicitly.
    """
    override = os.environ.get("BUGHUNTER_BASH", "").strip()
    if override and Path(override).exists():
        return override
    if os.name == "nt":
        for candidate in (
            r"C:\Program Files\Git\bin\bash.exe",
            r"C:\Program Files\Git\usr\bin\bash.exe",
            r"C:\Program Files (x86)\Git\bin\bash.exe",
        ):
            if Path(candidate).exists():
                return candidate
    return "bash"


def _run_shell(cmd: list[str], cwd: str | None = None, timeout: int = 3600,
'@

    if (-not $eng.Contains($anchor)) {
        Write-Host '[X] engine.py — anchor _run_shell tidak ketemu; patch manual.' -ForegroundColor Red
        exit 1
    }
    $eng = $eng.Replace($anchor, $resolver)

    # Alihkan seluruh pemanggilan bash ke resolver
    $count = ([regex]::Matches($eng, '_run_shell\(\["bash",')).Count
    $eng = $eng -replace '_run_shell\(\["bash",', '_run_shell([_resolve_bash(),'

    Copy-Item $engine "$engine.bak" -Force
    Set-Content -Path $engine -Value $eng -Encoding UTF8 -NoNewline
    Write-Host "[OK] engine.py — bash resolver (mengganti $count pemanggilan)." -ForegroundColor Green
    $applied++
}

Write-Host ''
Write-Host "Selesai: $applied patch diterapkan, $skipped sudah ada." -ForegroundColor Cyan
Write-Host 'Verifikasi: bughunter --no-banner status' -ForegroundColor DarkGray
