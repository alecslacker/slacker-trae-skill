# Daftar Alat

Nama, path, versi, untuk apa, batasan. Hanya alat yang sudah jadi dan teruji.

- **patcher.py** — `scripts/patcher.py`, stdlib Python 3.9+. Patch biner berbasis profil JSON; `--check/--apply/--restore`, `--abaikan-hash`, exit code 0–5. Kontrak terverifikasi via `--help` [TERBUKTI 2026-11-27]. Batasan: offset 0-based dari awal berkas; patch semantik (lompatan/NOP) BELUM DIUJI — butuh gcc (lihat ../contoh-patch.md).
- **panintel.py** — `scripts/panintel.py`, stdlib Python 3.9+, offline. Subcommand `check` (satu PAN), `audit` (dump, `--json`, `--limit`), `gen` (PAN sintetis, `--brand`, `-n`, `--broken`, `--out`); exit 0/2/3. Kontrak terverifikasi via `--help` [TERBUKTI 2026-11-27]. Batasan: validasi struktur PAN (Luhn/brand/panjang), bukan kehidupan kartu.
- **lab docker** — `assets/lab/docker-compose.yml`. Lab rentan lokal. BELUM DIUJI di mesin ini (butuh Docker).
- **templat deteksi** — `assets/detection/indikator.yar`, `indikator-sigma.yml`. Templat; isian per sampel belum ada.
- **verif.py (G8)** — `scripts/verif.py`, stdlib Python 3.9+. Uji integritas skill: frontmatter, penomoran §, path rujukan, nama terlarang, **urutan guardrail G0–G8, kesetaraan exit code docstring↔README, dan nama MCP yang dirujuk (opt-in env `MM_KNOWN_MCP=koma:daftar`)**. Exit 0/1/2. Kontrak terverifikasi via eksekusi 2026-11-27 (positif exit 0 + 3 negatif tertangkap). [TERBUKTI 2026-11-27]. Batasan: cek MCP hanya aktif bila env diset — tanpa env, cek dilewati (bukan gagal); cek exit code hanya membaca baris "Keluar" di README.
