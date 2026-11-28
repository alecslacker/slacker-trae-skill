# CHANGELOG — Mastermind

Seluruh perubahan yang layak dilaporkan pada skill Mastermind tercatat di sini, dibaca dari riwayat commit repo dan entri `references/buku-besar/` (satu sumber kebenaran per fakta).

Format mengikuti **Keep a Changelog**; tanggal `YYYY-MM-DD`; hash commit dirujuk penuh. Repo ini tidak memakai tag versi — tanggal + hash commit adalah penanda versi. Label `[TERBUKTI]` mengikuti doktrin §6 SKILL.md: hanya untuk yang dieksekusi, bukan dibaca.

Author: Alecs — Slackercode Family
Copyright © 2026 Alecs (Slackercode Family)

---

## [2026-11-29] — README keseluruhan + sinkron 5 lokasi agen

### Ditambah

- Seksi **Pasang** di `README.md`: tabel 5 lokasi pemasangan skill (ZCode `~/.zcode/skills`, `.agents`, TRAE `~/.trae/skills`, Claude `~/.claude/skills`, Hermes `~/Hermes-Kerja/skills-dci`) + doktrin "semua agen membaca berkas yang sama" (satu sumber kebenaran, G8) + perintah sinkronisasi `git archive main | tar -x -C <lokasi>`.
- Blok `scripts/vpn.py` di `README.md`: paragraf sifat **per-operasi** (nyala hanya selama operasi, route kembali normal saat `disconnect`, jangan dibiarkan menyala berhari-hari) + siklus lazim `connect` → operasi → `status` → `disconnect`.
- Baris `scripts/vpn.py` di tabel **Status uji**: TERUJI live (2026-11-28).
- Entri buku besar `operasi.md` untuk pembaruan ini.

### Diubah

- Kelima lokasi agen ternyata masih state prap-VPN (4 lokasi tak tersinkron sejak `1b9eb03`); kini **identik dengan `main`**. Verifikasi `[TERBUKTI]`: `verif.py` exit 0 di 6 lokasi (repo + 5 salinan) + smoke test `vpn.py profiles` lulus di lokasi ZCode.

### Commit

`52e13da`, `ce24fb8`

---

## [2026-11-28] — `scripts/vpn.py`: egress terkontrol

### Ditambah

- `scripts/vpn.py` (stdlib Python 3.9+, Windows) — kendali OpenVPN Connect desktop: subcommand `profiles` / `status` / `connect <id|nama>` / `disconnect`; exit 0 tujuan tercapai, 1 masalah lingkungan, 2 keadaan tak berubah/bertentangan.
- Routing `SKILL.md` §3.1 (baris "Aktivitas butuh egress terkontrol"), kit standar §3.3 ("Egress terkontrol"), OPSEC §11 (egress = VPN config user; tanpa VPN = IP asli, dicatat di laporan), §13 (daftar alat).
- `README.md`: tabel prasyarat (+ baris OpenVPN Connect), blok `scripts/vpn.py` di "Alat siap pakai".
- Entri buku besar `alat.md` + `operasi.md`.

### Keputusan teknis [TERBUKTI dari `resources/app.asar` + uji live]

- Trigger connect app = flag `--connect-shortcut=<id>`, disconnect = `--disconnect-shortcut`; dibaca `app.commandLine` → app **wajib dilaunch segar** (process lama di-kill dulu). URI `openvpn://` hanya membuka app, tidak auto-connect.
- "Terhubung" ditentukan dari IPv4 **non-link-local** di adapter TUN — state app `connectorActive`/`connectedProfile` persisten/stale dan tidak boleh jadi acuan. Adapter TAP tetap "Up" saat mati (IP APIPA 169.254.x); pencocokan via deskripsi "OpenVPN Connect", bukan nama adapter.
- Uji live: connect → TUN `192.168.219.5` + default route via tunnel (`103.187.146.110:10794`), disconnect → terputus.

### Commit

`8bfec8f`

---

## [2026-11-27] — Doktrin ke-segala-gaan, G8, verif.py, pembaruan vektor

### Ditambah

- **Doktrin ke-segala-gaan** di `SKILL.md` §3: routing permintaan per jenis target + fallback (fallback bukan degradasi), tangga eskalasi **E0–E5** (baca & amati → rekayasa custom), kit standar operasi.
- **Buku besar operasi** `references/buku-besar/` (4 berkas: `operasi.md`, `proteksi.md`, `alat.md`, `jebakan.md`) — memori lintas sesi: baca sebelum operasi, tulis sesudahnya, max 10 baris/entri, label bukti wajib.
- `scripts/verif.py` — uji integritas skill (stdlib): frontmatter, jumlah fence, penomoran §, path rujukan, nama terlarang/penggalan ejaan, keberadaan buku besar + skrip; exit 0/1/2.
- **G8 Anti-Drift Model** — lapis ke-9 guardrail (§4): dok perilaku = kontrak; satu sumber kebenaran per fakta; doktrin > keputusan model; perubahan perilaku wajib tercatat di buku besar; deterministik; model tak mengarang lingkungan. `verif.py` +3 cek G8: urutan G0–G8, kesetaraan exit code docstring↔README, nama MCP via env `MM_KNOWN_MCP` (opt-in).
- **Pembaruan vektor 2024–2026** (§8): MFA fatigue/push approval, OAuth code phishing (PKCE, RFC 7636 [TERDOKUMENTASI IETF]), AI/LLM personalisasi, deepfake vishing, 3DS2 (frictionless ≠ ditolak), kloning QRIS fisik; §8 carding + virtual card/network token; §9 korpus modus ID+INT.
- Inti **skill ponytail** ke §8 ("Bangun bergaya ponytail": tangga 6 langkah + YAGNI).
- Penyebaran `verif.py`: cek path rujukan kini mencari di lokasi pemasangan lazim (`~/.zcode`, `~/.agents`, `~/.trae`, `~/.claude`) + env `MM_SKILL_DIRS`; `.gitignore` diperluas (state sesi agen, artefak riset sementara).

### Diperbaiki

- Integritas: nama MCP di routing, frontmatter tanpa `': '`, klausul sumber kebenaran, batas & sinkron buku besar, 2 baris routing baru; ejaan keluarga disatukan ke **Slackercode Family**; kredit HN-Community dicantumkan.
- `README.md`: exit code `patcher.py` dikoreksi (1 galat), tabel guardrail +G8.
- Tag `[perlu verifikasi]` ditagihkan ke sumber primer: IC3 BEC (PDF resmi: 2023 = 21.489 keluhan > $2,9 M; 2024 = 21.442 keluhan $2,77 M), MFA fatigue (CISA number matching Okt 2022, kasus Uber Sept 2022, MS Authenticator 2022), QRIS (Wagub BI, Xinhua 2026-11-17). Sisa tag: durasi sampel deepfake suara (presisi) + angka kerugian kloning QRIS Indonesia.

### Diubah

- Bullet G8 "model tak mengarang lingkungan" diubah dari salinan §3.1 menjadi penunjuk — G8 melanggar doktrinnya sendiri bila menyalin, bukan menunjuk.
- `QUICKSTART.md` dibuat lalu dihapus (isi relevan sudah tersebar ke `README.md`/`SKILL.md`).

### Commit

`4eaec2b`, `357c728`, `6f2ef86`, `3199f6a`, `0d8b916`, `9caf2dd`, `e734ea5`, `1887ca6`, `1b9eb03`

---

## [2026-11-18] — Rilis awal

### Ditambah

- `SKILL.md` — kontrak persona lengkap (awal 612 baris): identitas, guardrail G0–G7, label bukti `[TERBUKTI]`/`[TERDOKUMENTASI]`/`[HIPOTESIS]`, tingkat eksekusi T0–T3, format laporan.
- `scripts/panintel.py` — triase dump PAN offline (Luhn, tabel prefix BIN, masker, audit, generator data uji).
- `scripts/patcher.py` — patch biner berbasis profil JSON, cadangan `.bak`, `--check`/`--apply`/`--restore`, hash gate.
- `assets/crackme/crackme.c` + `profil-contoh.json` — latihan patch.
- `assets/lab/docker-compose.yml` — lab PHP rentan, versi dipin.
- `assets/detection/indikator.yar` + `indikator-sigma.yml` — templat indikator.
- `references/contoh-patch.md` — alur patch + bukti uji nyata (patch banner `curl.exe` offset 542880, dipulihkan dengan hash identik).
- `README.md`, `LICENSE` (MIT + catatan risiko terpisah di README), `.gitignore`.

### Commit

`9d7d79f`, `0badbab`, `5a6aa2a`, `2934a80`, `a8c529c`

---

## Catatan status saat ini (2026-11-29)

- `main` @ `ce24fb8`; `verif.py` exit 0 di repo + 5 lokasi agen.
- Belum diuji / masih templat: `assets/crackme` (butuh `gcc`), `assets/lab` (butuh Docker), `assets/detection` (belum ke mesin YARA/SIEM), blackhat SEO & dark trading (rancangan, belum ada alat), patch semantik di `patcher.py` (jalur yang masih `[HIPOTESIS]` — butuh build crackme).
