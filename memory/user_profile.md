# USER PROFILE — MAS WONDHO
> Diperbarui total: 2026-09-03. Struktur tematik (bukan kronologis) agar efisien dibaca tiap sesi.

## 1. Identitas & Preferensi
- Nama: Mas Wondho — Visionary Founder, Duta Corpora Indonesia (non-teknis).
- Bahasa: Bahasa Indonesia semua komunikasi, komentar kode, dan dokumentasi.
- Estetika: arah visual per-project (vibe + referensi konkret via Design System) — tanpa gaya global wajib; standar craft premium. ("Presisi Nusantara" = nama design system khusus project ts-attendance, bukan mandat global.) Detail desain & kesesuaian wireframe sangat diperhatikan.
- Konten WAJIB berkarakter Indonesia/Jawa: Bahasa natural (bukan terjemahan kaku), nuansa budaya Jawa bila relevan (unggah-ungguh, gotong royong), contoh & referensi lokal. Tingkat tutur Jawa (krama) bila diminta.
- Cara kerja: multi-agent untuk tugas kompleks.

## 2. Domain & Stack
- **Backend utama: Laravel** (preferensi #1 Mas Wondho). Filament untuk admin/CRUD cepat, Livewire 3 untuk UI reaktif PHP-only.
- **Frontend modern: Laravel + Inertia + React + shadcn/ui + Tailwind CSS** — default UI modern/SPA. Livewire untuk UI dinamis sederhana.
- **Database: MySQL/MariaDB** (utama), PostgreSQL (opsi kedua).
- **Server produksi: Ubuntu + OpenLiteSpeed + aaPanel.** Lokal: Laragon (Windows).
- WordPress plugin dev (prefix dci_) & Node.js hanya jika project-nya meminta.

## 3. Tool Utama & Alur Kerja
- IDE utama: TRAE Work untuk coding (bukan CLI tool lain).
- Strategi routing model: model murah/gratis untuk task ringan-menengah, model kuat untuk task kompleks. Mas Wondho sadar sendiri jam penggunaan model — TIDAK perlu diingatkan aturan jam di rules.
- Keyword kontrol: KERJAKAN, LANJUT, ULTRATHINK, KONSUL, SKIP PLAN, REVISION, EXPLAIN, Stop, Undo.

## 4. Langganan AI Aktif
- Z.ai GLM Coding Plan **Max-Monthly Legacy V2**: $80/bln (Max $160 × 50% Migration Discount, harga TERKUNCI — jangan ganti plan), auto-renew aktif.
- Kuota: ~1.600 prompt/5 jam, ~8.000 prompt/minggu (prompt-based; 1 prompt ≈ 15–20 invokasi; repo besar & auto-accept boros lebih cepat).
- Koefisien: GLM-5.3 & GLM-5-Turbo = 3× peak (Sen–Jum 13:00–17:00 WIB), 1× di luar itu & weekend seharian. GLM-4.7 = 1× selalu.
- FAKTA SERVER (terverifikasi API): request "glm-5.2" ke api.z.ai/api/anthropic DI-SERVE sebagai "glm-5.3" — usage selalu tercatat GLM-5.3 walau UI pilih 5.2.
- Spec model: context 1M, max output 128K; GLM-5.3 thinking selalu on (3 level: low/med/high).

## 5. Ecosystem Skills & MCP
- **Total ±288 skill terpasang.** Komponen utama:
  - Blog engine claude-blog v2.2.0 (32 skill blog*, 5 agents) — trigger: tulis blog, audit SEO, topic cluster.
  - DevOps-Security 163 skill (BagelHole, MIT) — trigger: k8s, vault, hardening, compliance. Script .sh Linux-only.
  - Marketing-Skills v2.5.1 (Cesarjoquin): 45 skill (copywriting, cro, ai-seo, analytics, launch, emails, dst) + folder `marketing-tools` (REGISTRY.md pendamping utk link ../../tools/). CLI npm/Redis TIDAK diinstall — hanya markdown.
  - playwright-best-practices (currents-dev): 1 skill + 57 referensi 8 kategori (E2E, a11y, visual, i18n, Electron) — trigger: test Playwright, flaky test, E2E.
  - prd-builder v2: PRD 8 section (Design System anti-slop M012) + Design Spec (Sequential 7-step + Edge State + AI Test gate) + aset Seedream.
  - antislop family (6): antislop core, -ui, -code, -copywriting, -human, -layoutmobile — WAJIB untuk task UI/tulisan.
  - byteplus-seedream5 v2: Dola-Seedream-5.0-pro ($0.045/gbr, default) + lite ($0.035/gbr, 2K-4K). ARK_API_KEY di user-level registry (load: [Environment]::GetEnvironmentVariable('ARK_API_KEY','User')).
- MCP aktif: Context7 (WAJIB cek library), zai-vision (analisis gambar/screenshot user), zread, sequential-thinking, integrated_browser, playwright, desktop-commander, everything-search, Figma_AI_Bridge, shadcn-ui, Google_Maps, Time, byteplus-image, needmcp, ssh-admin, testsprite, Cloudflare.
- Katalog lengkap: `indeks-skills-lengkap.md` (kategori A–P) + Skill Auto-Invocation Protocol (cek indeks → invoke SEBELUM kerja manual).

## 6. Aturan & Protokol Aktif
- **Rules Slackercoder v2** (`rules-slackercoder-v2.md`): ramping ~40% — mapping hanya skill/MCP terpasang; dua jalur protokol (task kecil = ringan, task besar = penuh: plan → checkpoint KERJAKAN/LANJUT → Cross-Check 6 Layer); Anti-AI-Slop diringkas → refer skills antislop*; full file adaptif (>200 baris → patch, full saat diminta). Status: menunggu dipaste ke Settings Rules TRAE.
- Context7 = sumber kebenaran pertama untuk library eksternal (override training data).
- Graphify (peta codebase lokal, binary `C:\Users\alecs\.local\bin`): `graphify-out/` = sumber kebenaran pertama struktur/arsitektur kode; belum ada → /graphify-build (`--code-only` wajib, tanpa API key); setelah edit signifikan → /graphify-update. Jangan commit/edit manual graphify-out.
- Anti-Typo Triple-Gate: Struktur → Identifier → Semantik.
- Memory: maks 20 entri per lapisan, 400 char/entri; pisahkan instruction vs learning memory; aturan konkret > abstrak.

## 7. Catatan Teknis Penting
- Python skill blog: interpreter WAJIB `C:\Python312\python.exe` (3.12.4). "python"/"python3" di PATH TRAE VM = 3.10.11 TIDAK memenuhi syarat 3.11+.
- TRAE IDE tidak punya folder agents eksternal ala Claude Code — integrasi agent = embed .md ke SKILL.md atau delegate via Task tool.
- Environment TRAE: ANTHROPIC_BASE_URL=api.z.ai/api/anthropic (glm-5.2/glm-5/glm-4.5-air mapping).

## 8. Kebiasaan Hemat Kuota (Legacy V2 = per-REQUEST, potong round-trip)
- Kuota dihitung per request/prompt unit, BUKAN token; 1M token hanya plafon context sesi. Lever utama: minimalkan giliran model.
- Model routing: task ringan → GLM-4.7 (koefisien 1× selalu); task berat → GLM-5.3 di luar peak/weekend (peak Sen–Jum 13:00–17:00 WIB = 3×).
- Batch tool call paralel: 3–5 tool call dalam 1 pesan = 1 giliran model, bukan berantai 1-per-1.
- Struktur codebase selalu dari `graphify-out/` dulu (1 baca ≈ ganti 15–20 baca file mentah).
- Eksplorasi berat → delegate subagent (Task tool); main thread terima ringkasan saja, konteks tetap ramping.
- Context7 SEBELUM tulis kode library — cegah siklus error-fix (tiap retry = belasan request).
- Checkpoint adaptif: task menengah yang jelas dieksekusi 2–3 sekaligus per checkpoint KERJAKAN/LANJUT.
- 1 sesi = 1 topik; /clear antar topik. Task input 4 elemen: Goal / Context (file spesifik) / Constraints / Done-when.
- File besar: baca sebagian (offset), bukan utuh; auto-accept bijak saat eksplorasi.
- Instruksi spesifik memangkas invokasi (~18× → ~10×).
