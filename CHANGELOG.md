# Changelog

Semua perubahan penting repo ini didokumentasikan di sini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/); penomoran versi pakai `vY.M.D` (tanggal rilis) selama repo belum memakai git tag.

## [v26.10.30] — 2026-10-30

Total skill: **384** (39 kurasi + 94 plugin + 251 GitHub). Angka ini di 10 dokumen dikelola otomatis via marker `<!--skill-count-->` oleh `collect.ps1`.

### Ditambahkan
- **INVENTORY.md** (`skills/INVENTORY.md`) — inventaris sumber tiap skill (kurasi / plugin TRAE / repo GitHub), auto-generated oleh `scripts/update-inventory.ps1` (dipanggil `collect.ps1` step 2.6).
- **Mekanisme marker skill-count** — angka total skill di 10 dokumen tersinkron otomatis setiap `collect.ps1` (regex idempoten).
- Skill **gh-cli** (native TRAE) diadopsi ke repo sesuai prinsip TRAE = sumber utama.

### Diubah
- **Update upstream masif**: antislop v3.2.21 → **v3.2.24** (struktur repo berubah — skill kini di subfolder `skills/`; ekstensi lokal antislop-ui *Liveliness Recipes* + patch *Sterile Default* di-re-apply otomatis), claude-blog 32 skill blog-* (commit 3544423), `openclaw-local-mac-mini`, `logo-design` (export_variants.py), REA 6.7.0 → **6.8.0** (skill v42 → v49, tools 207 → 229).
- **Migrasi taste-skill v1 → v2.1.5**: 13 skill `taste-*` lama diganti 1 skill **`design-taste-frontend`** (39 file: library arah desain + real-browser inspector, commit 12af471) di repo + TRAE + Claude + ZCode + Codex. `full-output-enforcement` tetap skill mandiri. Skill `taste-imagegen-*` tidak dimigrasi (konflik dengan `byteplus-seedream5`).
- **Klasifikasi ulang 242 skill** yang selama ini tercatat "kurasi" ke sumber GitHub aslinya — hasil cross-check star list `ai-skills`: claude-blog (32), BagelHole DevOps-Security (163), Cesarjoquin Marketing (45), currents-dev playwright (1).
- `upstream-manifest.json` kini 8 entri; entri Chriss54/multilingual-int (repo 404) diganti claude-blog.
- `verify-sync.ps1` kini memverifikasi `design-taste-frontend` (bukan 13 taste-* lama).
- Node.js 24.12.0 → **26.13.0** (syarat REA ≥ 24.22.1); entri Laragon node-v18 usang dihapus dari PATH User dan Machine.

### Diperbaiki
- `collect.ps1` tidak lagi mati di tengah proses karena warning CRLF/stderr git (`ErrorActionPreference` diturunkan sementara untuk `git add` dan `git push`).
- Marker skill-count di `memory/user_profile.md` kini diperbaiki di sumbernya (`~/.trae/memory`) — sebelumnya perbaikan di repo tertimpa balik oleh collect.

## [v26.10.23] — 2026-10-23

### Ditambahkan
- Skill **rab-builder** — RAB sistem metode vibe coding: skema pembayaran 3 tier, jasa pengembang 8 jam/hari, overhead, acuan modal Tencent Cloud Lighthouse, harga pasar Kab. Blitar, renewal tahun ke-2+.
- Skill **reverse-engineer-anything (REA v6.7.0)** + `scripts/install-rea.ps1` (bootstrap lintas-komputer: rea-agents npm, JDK 21, Ghidra 12.1.4, JAR JADX 0.7.1 tervalidasi SHA-256).
- Ekstensi lokal **Liveliness Recipes** (anti-hambar) pada antislop-ui + antislop upstream v3.2.21.
- Integrasi DESIGN.md: prd-builder + dev-design-context satu arah desain, gate Blandness Test.

## [v26.10.05–07] — 2026-10-07

### Ditambahkan
- Skill **logo-design v1.4.x** (kaankiziltug/logo-design-skill, MIT).
- **Ekspor plugin TRAE resmi** ke repo + semua agent (Tier 3) — 94 skill dari 22 plugin.
- **Integrasi Codex**: AGENTS.md padanan Rules TRAE WORK + sinkronisasi skill.
- Topologi MCP Z Code hasil audit 2026-10-06 (10 server kanonik) + best practice resmi Z Code.

### Diperbaiki
- `verify-sync.ps1` portable (RepoRoot dari lokasi script, bukan path mesin).
- Path graphify portable di command files Z Code.

## [v26.09.30] — 2026-09-30

### Ditambahkan
- **Pemantau update upstream**: `upstream-manifest.json` + `scripts/check-upstream.ps1` (API publik GitHub, tanpa API key).
- antislop diperbarui ke v3.2.19.

## [v26.09.18–19] — 2026-09-19

### Ditambahkan
- **Integrasi keluarga taste-skill v1** (13 skill) + sinkronisasi multi-agent.
- Migrasi **memory native TRAE** + upgrade design token estetika premium.

## [v26.09.05–06] — 2026-09-06

### Ditambahkan
- Repo diinisialisasi: **289 skill TRAE** + memory + script `install.ps1` / `collect.ps1`.
- Branding SLACKER TRAE SKILL (Slackercode Family), README Bahasa Indonesia.
- AGENTS.md + CLAUDE.md (standar FreeBuff) + `.knowledge.md` (distilasi skill inti untuk agent non-TRAE).

### Keamanan
- Placeholder Tailscale authkey dihapus setelah terdeteksi secret scanning.

---

## Catatan Pemeliharaan

- CHANGELOG diperbarui saat rilis/checkpoint besar — entri baru di atas.
- Grup entri mengikuti conventional commits (`feat` → Ditambahkan, `fix` → Diperbaiki, `chore`/`docs`/`refactor` → Diubah).
- Setelah repo mulai memakai git tag, ganti penanda `vY.M.D` menjadi semver (`v1.0.0` dst).
