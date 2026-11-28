# USER PROFILE — MAS WONDHO
> Diperbarui total: 2026-09-03 • +§9 Spesifikasi PC 2026-11-24. Struktur tematik (bukan kronologis) agar efisien dibaca tiap sesi.

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
- **Total 437<!--skill-count:437--> skill terpasang.** Komponen utama:
  - Blog engine claude-blog v2.2.0 (32 skill blog*, 5 agents) — trigger: tulis blog, audit SEO, topic cluster.
  - DevOps-Security 163 skill (BagelHole, MIT) — trigger: k8s, vault, hardening, compliance. Script .sh Linux-only.
  - Marketing-Skills v2.5.1 (Cesarjoquin): 45 skill (copywriting, cro, ai-seo, analytics, launch, emails, dst) + folder `marketing-tools` (REGISTRY.md pendamping utk link ../../tools/). CLI npm/Redis TIDAK diinstall — hanya markdown.
  - playwright-best-practices (currents-dev): 1 skill + 57 referensi 8 kategori (E2E, a11y, visual, i18n, Electron) — trigger: test Playwright, flaky test, E2E.
  - prd-builder v2: PRD 8 section (Design System anti-slop M012) + Design Spec (Sequential 7-step + Edge State + AI Test gate).
  - design-taste-frontend v2.1.5: PEMIMPIN arah desain frontend/landing page (deal direction dari library 247 situs + inspector real-browser; lihat skills/_TASTE-SKILLS-INTEGRASI.md).
  - antislop family (6): -copywriting (tulisan), -code (komentar/kode), -human (a11y), -layoutmobile (reflow) — WAJIB per domain; core & -ui tidak lagi menyetir arah desain (keputusan 2026-10-30).
  - Jalur gambar: 9router production lewat REST /v1/images/generations (model uji OK: cx/gpt-image-2.6-sunburst). URL + key di ~/.9router/env (netral lintas agent, izin hanya akun Mas Wondho, jangan di-commit); MCP dci-imagegen terpasang di TRAE, TRAE SOLO, ZCode, Claude Code (Codex tidak); terbukti jalan di TRAE (rencana: .trae/documents/plan-dci-imagegen.md). Output ke <project>/generated-images, n=1 default, memakai kuota ChatGPT. BytePlus/Seedream sudah dihapus 2026-11-24.
  - mastermind: repo pribadi Mas Wondho; persona keamanan internal ber-atribusi "Alecs — Slackercode Family". Alecs/Slackercoder = alter ego Mas Wondho di repo ini (BUKAN orang lain, BUKAN DCI). Alat recon/scanner/fuzzer/kit phishing/checker/malware ringan + analisis modus & laporan intelijen-polisi. 8 guardrail, default dry-run, bukti dari eksekusi; reversing diserahkan ke REA.
- MCP aktif: Context7 (WAJIB cek library), zai-vision (analisis gambar/screenshot user), zread, sequential-thinking, integrated_browser, playwright, desktop-commander, everything-search, Figma_AI_Bridge, shadcn-ui, Google_Maps, Time, needmcp, ssh-admin, testsprite, Cloudflare.
- Katalog skill: daftar `available_skills` (otomatis ter-inject TRAE tiap sesi) + `skills/INVENTORY.md` di repo (auto-generated) + Skill Auto-Invocation Protocol (identifikasi domain → invoke SEBELUM kerja manual).

## 6. Aturan & Protokol Aktif
- **Rules Slackercoder**: padanan lengkap tersinkron di `trae-rules.md` (repo) — dua jalur protokol, pembagian peran desain (taste pimpin UI, antislop per domain), Anti-Typo Triple-Gate, Context7, Graphify. Status: TERPASTE ke Settings Rules TRAE 2026-10-30 (versi aktif = versi repo).
- Context7 = sumber kebenaran pertama untuk library eksternal (override training data).
- Graphify (peta codebase lokal, binary `C:\Users\alecs\.local\bin`): `graphify-out/` = sumber kebenaran pertama struktur/arsitektur kode; belum ada → /graphify-build (`--code-only` wajib, tanpa API key); setelah edit signifikan → /graphify-update. Jangan commit/edit manual graphify-out.
- Anti-Typo Triple-Gate: Struktur → Identifier → Semantik.
- Memory: native TRAE, path resmi `~/.trae/memory/` (user_profile global + projects/<kunci>/project_memory); maks 20 entri, 400 char/entri, >15 = pangkas; DILARANG memory di folder project; aturan konkret > abstrak.

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

## 9. Spesifikasi PC Utama (WMI, 2026-11-24)
### M-HW1 — Core
i7-9700KF (8C/8T, LGA1151) • MSI MAG Z390 TOMAHAWK (MS-7B18), BIOS 1.D0 (2024-08) • RTX 2070 8GB (PCIe 3.0 x16, power limit 157W) • RAM 32GB = 4×8GB Corsair Vengeance LPX DDR4-2666 C16 (CMW16GX4M2A2666C16), 4 slot penuh, max 64GB • PSU & casing belum tercatat (cek fisik). Slot PCIe: 1× x16 CPU + 1× x16 (x4 chipset).
### M-HW2 — Storage & OS
Win10 Pro 22H2 (19045, EOL Okt-2025). C: 970 PRO 512GB NVMe (satu-satunya M.2, 71GB bebas) • D: 860 PRO 512GB SATA (105GB) • F: Intel 545s 256GB SATA (203GB) • E: Seagate 1TB HDD (263GB) • H: WD Elements 500GB USB.
### M-HW3 — Rencana upgrade LLM lokal (budget Rp 35jt) — BELUM DIPUTUSKAN
Target Mas Wondho: huihui-ai/Huihui-DeepSeek-V4.1-Flash-1017-abliterated-GGUF = 552B MoE + 196B Engram; GGUF terkecil UD-IQ1_S 233GB, IQ1_M 250GB. TIDAK feasible di 35jt: RDIMM 32GB copotan Rp 3,12jt/keping → 384GB = Rp 37jt; Mac M5 Ultra 512GB ~Rp 160jt+. Alternatif: model ≤35B (3090 24GB bekas Rp 12–15jt + PSU 1200W Rp 2,7–4,3jt), sewa cloud, atau budget Rp 45jt+. Mas Wondho memilih melupakan model ini.
### M-HW4 — Rencana CPU/RAM (2026-11-24)
i9-9900K/KF didukung (BIOS 7B18v1D terbaru, LGA1151 gen-9). Saran: 9900K bekas ~Rp3,5jt, jual 9700KF ~Rp2–2,5jt; hindari ES/QS & 9900KS. Target RAM 64GB belum tercapai (lihat M-HW6).
### M-HW5 — Clock CPU 9700KF
Task Manager/WMI 3,60GHz=base; perf counter 127%→≈4,57GHz aktual. Biarkan Auto; Turbo/SpeedStep/SpeedShift/C-States ON, Balanced. Pakai HWiNFO untuk clock.
### M-HW6 — RAM T-Force 3600 (2026-11-24)
Terpasang 4×8GB TEAMGROUP-UD4-3600 = 32GB (bukan 64GB). Auto 2400 @1,2V = JEDEC normal. Set 3600 manual gagal karena tegangan/timing XMP tidak ikut; aktifkan A-XMP Profile 1 (1,35V CL18). 4-DIMM 3600 di Z390 berat → 3200 lebih realistis. Update: XMP aktif tapi turun 2667 @1,25V = training fallback, BUKAN batas mobo (spec MSI 4400OC/128GB); coba 3200 1,35V atau 2-DIMM A2/B2.
