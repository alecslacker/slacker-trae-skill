# Changelog

Semua perubahan penting repo ini didokumentasikan di sini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/); penomoran versi pakai `vY.M.D` (tanggal rilis) selama repo belum memakai git tag.

## [v26.11.27] — 2026-11-27

Total skill: **437** (48 kurasi + 94 plugin + 295 GitHub). Angka ini di 9 dokumen dikelola otomatis via marker `<!--skill-count-->` oleh `collect.ps1`.

### Diubah
- **`antislop` v3.2.32 → v3.2.33** (6 skill): `VERSION`, `SKILL.md` di `antislop-code`, `antislop-copywriting` (+266 baris), `antislop-human`, `antislop-ui`, plus `contrast-mcp.py`. Ekstensi lokal DCI di `antislop-ui/SKILL.md` (blok `local-extension` Liveliness Recipes + baris `Fix` Sterile Default) di-re-apply setelah timpa dan diverifikasi masih ada.
- **`marketingskills` `5b2b400` → `2bf95ed`**: 10 file di `aso`, `customer-research`, `prospecting`, `seo-audit`, `social` (+132/−9 baris). `ads/references/conversion-tracking.md` sengaja dipertahankan meski upstream memindahkannya ke skill terpisah.

### Ditambahkan
- **`mastermind` dari repo resmi `alecslacker/mastermind-skill`** commit `1b9eb03` (2026-11-27): 16 file, termasuk `references/buku-besar/*` dan `scripts/verif.py`. Sebelumnya salinan repo hanya 9 file / 44 KB; ternyata header SKILL.md menunjuk repo resmi sebagai sumber kebenaran. Artefak `graphify-out/` tidak disalin. Klasifikasi inventory berubah dari kurasi internal ke GitHub eksternal (14 entri manifest).

### Dicek, tanpa perubahan
- **`caveman` v4.2.0** (7 skill): 7 `SKILL.md` + README + script identik byte-per-byte dengan v4.1.0; rilis hanya mengubah packaging `bin`/CLI/middleware. Manifest tetap dicatat `v4.2.0`.
- **`taste-skill` `952435f`**: 1631 file identik byte-per-byte; perubahan upstream hanya README/sponsor.
- 7 sumber lain (`ponytail`, `rea`, `logo-design`, `claude-blog`, `DevOps-Security-Agent-Skills`, `anthropics/skills`, `playwright-best-practices`, `remotion`, `Agentic-Bug-Hunter`) status TERBARU — tidak diubah.

## [Belum dirilis] — 2026-11-25

### Ditambahkan
- **MCP `dci-tts`** (`mcp/dci-tts/`): pembuat suara (TTS) lewat 9router `/v1/audio/speech`. Tool `text_to_speech` (teks tunggal atau batch maks 10 adegan paralel 2) dan `list_free_voices` (daftar statis suara gratis). 30 tes lulus. Suara default `edge-tts/id-ID-ArdiNeural` (gratis, noAuth). Kredensial dari `~/.9router/env`.
- `scripts/install-tts.ps1` dan `scripts/register-tts.ps1` (dry-run bawaan, `-Apply`, `-Hapus`). Terdaftar di TRAE, TRAE SOLO, ZCode, Claude Code.
- `.gitignore`: `generated-audio/`.
- README: langkah pasang `dci-tts` di komputer lain.

### Diperbaiki
- Bug Task 4 `dci-tts`: argumen MCP `output_dir` tidak tersambung ke lapisan orkestrasi (`outputDir`), folder tujuan diabaikan diam-diam. Ditemukan lewat uji nyata MCP, diperbaiki, ditambah tes regresi (30 tes).

### Fakta TTS 9router (terverifikasi API 2026-11-24/25)
- Suara gratis terbukti: `edge-tts/id-ID-ArdiNeural`, `id-ID-GadisNeural` (natural), `google-tts/id` (datar). Provider premium (OpenAI/ElevenLabs/Gemini TTS) ditolak server sampai koneksi provider TTS ditambahkan di dashboard 9router.
- `GET /v1/models/tts` kosong di server ini; `/v1/audio/voices` sering 502 — keduanya tidak dipakai MCP.

### Keterbatasan yang diketahui
- ffmpeg (untuk merakit voice over ke video) dipasang lokal via winget `Gyan.FFmpeg` — bukan bagian repo; terminal baru perlu refresh PATH.

## [Belum dirilis] — 2026-11-24

### Ditambahkan
- **MCP `dci-imagegen`** (`mcp/dci-imagegen/`): pembuat gambar/logo lewat 9router produksi dengan model `cx/gpt-image-*` (bawaan `cx/gpt-image-2.6-sunburst`). Tool `generate_image` dan `list_image_models`. 38 tes lulus, 1 dilewati. Kredensial dibaca server dari `~/.9router/env`, tidak lewat env agent.
- `scripts/install-imagegen.ps1` dan `scripts/register-imagegen.ps1` (dry-run bawaan, `-Apply`, `-Hapus`). Terdaftar di TRAE, TRAE SOLO, ZCode, Claude Code. Codex sengaja tidak dipasang.
- Baris `dci-imagegen` di `trae-rules.md`, `zcode/AGENTS.md`, dan bagian "MCP Gambar" di `claude/CLAUDE.md`.
- `.gitignore`: `generated-images/` dan `hasil-tes-9router/`.
- README: panduan pasang di komputer lain dan pola membuat MCP baru berbasis `dci-imagegen`.

### Diubah
- Model Claude Code: Sonnet/Opus `glm-5.3[1m]` → `glm-5.4[1m]` (template, `CLAUDE.md`, README, `sync-claude.ps1`). Haiku tetap `glm-5.3-flash[1m]`. Koefisien kuota GLM-5.4 belum diverifikasi.

### Dihapus
- Seluruh jejak BytePlus: MCP `byteplus-image`, `ARK_API_KEY`, dan key di cadangan config semua agent.

### Keterbatasan yang diketahui
- Ukuran piksel ditentukan model (parameter `size` tampak diabaikan), latar putih tanpa transparansi, mode edit tidak setia pada tata letak, paralel maksimal 2 gambar.
- Uji nyata baru lulus di TRAE. Claude Code, TRAE SOLO, dan ZCode belum diuji.

## [v26.11.23] — 2026-11-23

Total skill: **437** (49 kurasi + 94 plugin + 294 GitHub). Angka ini di 9 dokumen dikelola otomatis via marker `<!--skill-count-->` oleh `collect.ps1`.

### Ditambahkan
- **Keluarga caveman (7)** dari [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) v4.1.0 (Apache-2.0): `caveman`, `ultracave`, `megacave`, `caveman-commit`, `caveman-review`, `caveman-help`, `caveman-compress`. Voice "terse tapi substansi utuh" untuk hemat output token — answer first, tanpa ceremony, negasi dan payload (kode/path/angka/error) verbatim, dasar gaya ASD-STE100. Terbukti via JetBrains A/B (tanpa penurunan kualitas, p=0.82) dan paper Adobe CAVEWOMAN (biaya 1.4–2.4× lebih murah).
- Entri `JuliusBrussee/caveman` di `upstream-manifest.json` (13 entri total).

### Dipilih sengaja
- 17 folder skill caveman lain TIDAK diambil: butuh CLI proxy `@caveman-ai/cli`, Caveman Cloud, atau hooks Claude Code (`caveman-stats`, `cavecrew`, `caveman-setup`, `caveman-discover`, `caveman-evidence-review`, `caveman-manage`, `caveman-optimize`, `caveman-learn`, `generated`, `native`, `migration`, `lean-build`, `investigate-first`, `safe-refactor`, `surgical-patch`, `verify-and-stop`, `caveman-explore`) — tidak berfungsi standalone lintas agent.

## [v26.11.13] — 2026-11-13

Total skill: **390** (41 kurasi + 94 plugin + 255 GitHub). Angka ini di 9 dokumen dikelola otomatis via marker `<!--skill-count-->` oleh `collect.ps1`.

### Ditambahkan
- Skill **`mastermind`** (persona internal Slackercoder Family, atribusi DCI) — pembangun alat keamanan: recon, scanner, fuzzer, harness PoC, exploit dev, kit phishing, checker massal, malware/implant ringan, plus analisis modus operandi dan laporan intelijen/kepolisian. Memuat 8 guardrail (scope, tier eksekusi, label bukti, safe-by-default, kredensial, cakupan uji, tanpa penolakan, kebersihan), tangga kematangan exploit (PoC → andal → senjata), dan serah terima bukti ke REA.
- Baris `mastermind` di tabel komponen README.

### Diubah
- Tarik 2 commit upstream (fast-forward): 5 skill dokumen-riset (docx/pdf/pptx/xlsx/research-guide) + `scripts/fix-node-path-machine.ps1`.
- Regenerasi `skills/INVENTORY.md`; klasifikasi plugin menyesuaikan keadaan lokal (hotl → superpowers, separateweb-capture & writers-loop tercatat sebagai plugin).

## [v26.11.09] — 2026-11-09

Total skill: **389** (42 kurasi + 92 plugin + 255 GitHub). Angka ini di 9 dokumen dikelola otomatis via marker `<!--skill-count-->` oleh `collect.ps1`.

### Ditambahkan
- **4 skill dokumen dari anthropics/skills**: `docx`, `pdf`, `pptx`, `xlsx` — menutup gap yang sudah lama dirujuk rules (prioritas harian: dokumen → docx/pptx/xlsx/pdf). Salin via sparse-checkout; lisensi source-available tercatat di `upstream-manifest.json`.
- Skill **`research-guide`** (kurasi internal DCI) — protokol riset: hierarki sumber, verifikasi klaim, label keyakinan, anti-fabrication. Menutup gap rujukan rules (riset → research-guide) dan prd-builder chain-guide.
- Entri `anthropics/skills` di `upstream-manifest.json` (9 entri total).

### Diperbaiki
- Angka README plain-text ("302"/"289") yang tertinggal kini sepenuhnya dikelola marker skill-count.

## [v26.10.30] — 2026-10-30

Total skill: **384** (39 kurasi + 94 plugin + 251 GitHub). Angka ini di 10 dokumen dikelola otomatis via marker `<!--skill-count-->` oleh `collect.ps1`.

### Ditambahkan
- **Skill keluarga Ponytail (6)** dari [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.2.0 (MIT): `ponytail`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`, `ponytail-review`. Filosofi "lazy senior dev" kini jadi pembawa resmi prinsip Intentional Minimalism — rules Slackercode merujuk SKILL.md-nya, tidak lagi menduplikasi aturan minimalisme.
- **INVENTORY.md** (`skills/INVENTORY.md`) — inventaris sumber tiap skill (kurasi / plugin TRAE / repo GitHub), auto-generated oleh `scripts/update-inventory.ps1` (dipanggil `collect.ps1` step 2.6).
- **Mekanisme marker skill-count** — angka total skill di 10 dokumen tersinkron otomatis setiap `collect.ps1` (regex idempoten).
- Skill **gh-cli** (native TRAE) diadopsi ke repo sesuai prinsip TRAE = sumber utama.

### Diubah
- **Update upstream masif**: antislop v3.2.21 → **v3.2.24** (struktur repo berubah — skill kini di subfolder `skills/`; ekstensi lokal antislop-ui *Liveliness Recipes* + patch *Sterile Default* di-re-apply otomatis), claude-blog 32 skill blog-* (commit 3544423), `openclaw-local-mac-mini`, `logo-design` (export_variants.py), REA 6.7.0 → **6.8.0** (skill v42 → v49, tools 207 → 229).
- **Migrasi taste-skill v1 → v2.1.5**: 13 skill `taste-*` lama diganti 1 skill **`design-taste-frontend`** (39 file: library arah desain + real-browser inspector, commit 12af471) di repo + TRAE + Claude + ZCode + Codex. `full-output-enforcement` tetap skill mandiri. Skill `taste-imagegen-*` tidak dimigrasi.
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
