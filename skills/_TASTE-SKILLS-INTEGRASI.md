# TASTE SKILL — Catatan Integrasi dengan Ekosistem Kita

> 1 skill: [design-taste-frontend](https://github.com/Leonxlnx/taste-skill) (MIT, **v2.1.5**, commit 12af471 2026-10-25).
> Migrasi dari 13 skill v1 (prefix `taste-*`) pada 2026-10-30 — upstream menggabungkan semuanya jadi 1 skill besar (39 file: library arah desain JSON, script inspeksi real-browser, references, evals).
> `full-output-enforcement` tetap skill mandiri (bukan bagian v2) dan tidak berubah.

## Identitas v2

- Nama skill: `design-taste-frontend` (folder sama dengan nama skill — konvensi upstream, tanpa prefix `taste-` lagi)
- Sumber data: studi 247 situs galeri terkurasi (One Page Love, Awwwards)
- Kemampuan v2: library arah desain (idea/composition/type/palette/photos/section blueprints), real-browser inspector (butuh Node + Chrome), look-and-fix loop pada screenshot, aturan app screens terpisah
- Perbandingan v1: v1 = 13 skill markdown statis; v2 = 1 skill dengan tooling eksekusi. Isi aturan inti sebagian besar sama, difokuskan.

## Header Integrasi

SKILL.md v2 memuat blok di bawah frontmatter (konvensi sama seperti v1):

```
> [TASTE] sumber ...
> [RELASI] KONFLIK PARSIAL — ...
> [ATURAN] aturan kita menang kecuali user eksplisit ...
```

**Prinsip resolusi konflik (tidak berubah dari v1):** aturan kita (`antislop` + `prd-builder` + `AGENTS.md`) **selalu menang** kecuali user eksplisit meminta arah taste-skill.

## Konflik yang Berlaku Terus (dari v1, masih relevan di v2)

1. **Font serif**: taste-skill membanned Fraunces/Instrument Serif sebagai default; prd-builder kita merekomendasikan Instrument Serif untuk vibe editorial. Resolusi: user pilih vibe via PRD → prd-builder menang; tanpa arah eksplisit → ikuti taste-skill.
2. **Inter/Geist**: taste-skill mengizinkan Inter untuk gaya neutral; antislop-ui kita menganggapnya *tell* bawaan AI. Resolusi: font apa pun boleh asal ada alasan brand tertulis (aturan kita).
3. **Pipeline image generation**: skill imagegen-* dari v1 TIDAK ikut dimigrasi (konflik dengan `byteplus-seedream5` kita). Pinjam prinsipnya saja: 1 section = 1 gambar fresh, jangan kompres/crop.

## Catatan Operasional v2

- **Dependencies inspector**: script `scripts/*.mjs` butuh Node (≥18 aman; kita 26.13.0) + Chrome/Chromium lokal. Tanpa Chrome, bagian library + rules tetap terbaca normal sebagai markdown.
- **Ukuran**: SKILL.md ~40 KB + references/ + library/*.json — agen boleh baca selektif per bagian; jangan dump seluruh library ke konteks.
- **Update berikutnya**: tetap lewat `scripts/check-upstream.ps1` (entri manifest `design-taste-frontend`, metode `latest_commit`). Repo tidak pakai tag/release.
