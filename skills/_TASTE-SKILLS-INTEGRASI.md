# TASTE SKILL — Catatan Integrasi dengan Ekosistem Kita

> 1 skill: [design-taste-frontend](https://github.com/Leonxlnx/taste-skill) (MIT, **v2.5.1**, commit f6b7657 2026-11-07).
> Jalur migrasi: 13 skill v1 (prefix `taste-*`) → v2.1.5 (2026-10-30) → **v2.5.1 (2026-11-21)**.
> Migrasi v2.5.1: folder skill di repo upstream ganti nama jadi `taste-skill/`, TAPI frontmatter `name` tetap `design-taste-frontend` — semua referensi di rules/PRD tidak perlu diubah. Isi membengkak 36 file (2.5 MB) → 1631 file (35 MB) karena library arah desain kini berupa asset CSS/JS/HTML besar (system.css 104 KB, backgrounds, components). `full-output-enforcement` tetap skill mandiri.

## Identitas v2.5.1

- Nama skill: `design-taste-frontend` (folder lokal `design-taste-frontend/`; repo upstream memakai `skills/taste-skill/`)
- Kemampuan baru sejak v2.1.5: deskripsi level "figma.com & x.ai sebagai bar", 9 house rules eksplisit yang menang atas semua isi skill, Stop-hook gate (Claude Code: jalankan `scripts/gate.mjs` otomatis saat Stop), aset background/component library siap pakai
- Dependencies: Node **22+** (kita 26.13.0 — aman) + Chrome/Edge/Chromium; ffmpeg opsional
- Tanpa Stop-hook (TRAE/ZCode/Codex): gate tetap bisa dijalankan manual `node scripts/gate.mjs` setelah build; tanpa Chrome, bagian library + rules tetap terbaca normal

## Header Integrasi

SKILL.md memuat blok `[TASTE] / [RELASI] / [ATURAN]` di bawah frontmatter (konvensi sama sejak v1). Prinsip resolusi konflik tetap: untuk **arah desain frontend/landing page**, `design-taste-frontend` adalah PEMIMPIN (deal direction → build → gate via inspector real-browser); antislop-* tidak menyetir arah desain. Antislop wajib di domain non-desain-arah: copywriting, code, human (a11y), layoutmobile. Konstrain brand eksplisit di PRD Section 8 / DESIGN.md menang atas keduanya.

## Konflik yang Berlaku Terus

1. **Font serif**: taste-skill membanned Fraunces/Instrument Serif sebagai default; prd-builder merekomendasikan Instrument Serif untuk vibe editorial. Resolusi: user pilih vibe via PRD → prd-builder menang; tanpa arah eksplisit → ikuti taste-skill.
2. **Inter/Geist**: taste-skill mengizinkan Inter untuk gaya neutral; antislop-ui menganggapnya *tell* bawaan AI. Resolusi: font apa pun boleh asal ada alasan brand tertulis (aturan kita).
3. **Pipeline image generation**: skill imagegen-* v1 tidak pernah dimigrasi. Prinsip tetap: 1 section = 1 gambar fresh, jangan kompres/crop.

## Catatan Operasional v2.5.1

- **Ukuran 35 MB**: agen WAJIB baca selektif — SKILL.md + references yang relevan saja. DILARANG dump library/assets ke konteks. Library CSS/JS dipakai saat build, bukan dibaca utuh.
- **Stop-hook hanya efektif di Claude Code** (frontmatter `hooks.Stop`). Di TRAE/ZCode, disiplinkan gate manual via aturan di AGENTS.md/trae-rules.md.
- **Update berikutnya**: tetap lewat `scripts/check-upstream.ps1` (entri manifest `design-taste-frontend`, metode `latest_commit`).
