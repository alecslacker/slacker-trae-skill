# TASTE SKILLS — Catatan Integrasi dengan Ekosistem Kita

> 15 skill dari [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) (MIT, v2 experimental per Sep 2026).
> Ditambahkan: 2026-09-18. Prefix folder `taste-*` agar tidak bentrok dengan skill bawaan kita.

## Cara Membaca Header Tiap Skill

Setiap skill taste-* punya blok catatan di bawah frontmatter dengan format:

```
> [TASTE] sumber: ...
> [RELASI] SEJALAN | KOMPLEMEN | KONFLIK — vs antislop kita
> [ATURAN] cara menyelesaikan bila bertentangan
```

**Prinsip resolusi konflik:** aturan kita (`antislop` + `prd-builder` + `AGENTS.md`) **selalu menang** kecuali user eksplisit meminta arah taste-skill. Alasannya: aturan kita sudah disesuaikan dengan preferensi Mas Wondho & falsafah *contextual purpose-driven*, sedangkan taste-skill sebagian preskriptif (angka pasti, ban absolut).

## Peta 15 Skill

| Folder | Sumber | Relasi | Catatan singkat |
|--------|--------|--------|-----------------|
| `taste-frontend` | taste-skill v2 | KONFLIK PARSIAL | Inti 86 KB; ban serif/Inter absolut → ikuti antislop bila bentrok |
| `taste-frontend-v1` | taste-skill v1 | KONFLIK PARSIAL | Legacy; hanya jika v2 bermasalah |
| `taste-gpt` | gpt-tasteskill | KONFLIK PARSIAL | Varian Codex/GPT; GSAP-heavy |
| `taste-soft` | soft-skill | SEJALAN | Vibe high-end agency; preset untuk PRD Section 8 |
| `taste-minimalist` | minimalist-skill | SEJALAN | Vibe editorial minimalis |
| `taste-brutalist` | brutalist-skill | KOMPLEMEN | Vibe industrial brutalis |
| `taste-redesign` | redesign-skill | SEJALAN | Audit 6 kategori proyek existing — sangat berguna |
| `full-output-enforcement` | output-skill | SEJALAN | Anti-truncation; berlaku semua task |
| `taste-image-to-code` | image-to-code-skill | KOMPLEMEN | Pipeline gambar → analisis → kode |
| `taste-imagegen-web` | imagegen-frontend-web | **KONFLIK** | Asumsi ChatGPT Images; GANTI dengan `byteplus-seedream5` kita |
| `taste-imagegen-mobile` | imagegen-frontend-mobile | **KONFLIK** | Sama seperti di atas |
| `taste-brandkit` | brandkit | SEJALAN | Brand board; gunakan bersama Seedream |
| `taste-stitch` | stitch-skill | SEJALAN | Generator `DESIGN.md` — mengisi lubang di antislop kita |

## 3 Konflik Utama (Wajib Tahu)

### 1. Font serif
- **taste-frontend**: `Fraunces` & `Instrument_Serif` DIBANNED sebagai default
- **Kita (prd-builder §Q8.5)**: Instrument Serif = rekomendasi untuk vibe "Elegan & editorial"
- **Resolusi**: kalau user memilih vibe editorial via PRD, ikuti prd-builder (kita menang). Kalau tidak ada arah eksplisit, ikuti larangan taste-skill.

### 2. Inter / Geist
- **taste-frontend**: Inter boleh untuk "neutral/Linear-style", Geist jadi default pilihan
- **antislop-ui kita**: Inter/Geist = *tell* bawaan AI, butuh alasan brand tertulis
- **Resolusi**: pakai aturan kita — font apa pun boleh **asal ada alasan brand tertulis**.

### 3. Pipeline image generation
- **taste-imagegen-web/mobile**: mengasumsikan ChatGPT Images / Codex image mode
- **Kita**: `byteplus-seedream5` (Dola Pro $0,045/gbr, Lite $0,035/gbr) dengan API key terpasang
- **Resolusi**: DILARANG memakai taste-imagegen-* sebagai instruksi generator. Pinjam **prinsipnya** (1 section = 1 gambar, jangan kompres; generate fresh, jangan crop) lalu eksekusi via Seedream.

## Yang Dipinjam dari taste-skill ke Ekosistem Kita

Beberapa ide kuat yang belum kita miliki (kandidat adopsi bertahap):
1. **Ban palet premium-consumer** (beige `#f5f1ea` + brass `#b08947` + oxblood `#9a2436` + espresso `#1a1714`) — temuan produksi tervalidasi
2. **Verifikasi mekanis** untuk ban eyebrow (hitung `uppercase tracking` vs jumlah section)
3. **Tabel inferensi dial** (vibe → angka) untuk melengkapi prd-builder Q8
4. **Protokol `[PAUSED — X of Y]`** untuk output panjang lintas batas token
5. **Aturan hero** (maks 2 baris headline, subteks ≤20 kata, CTA di atas fold)

## Status

- Semua header sudah dipasang di masing-masing SKILL.md
- Lisensi: MIT (boleh dipakai/dimodifikasi, sertakan atribusi)
- Sumber asli ada di repo `Leonxlnx/taste-skill`; salinan kita tidak menyertakan folder `research/`, `examples/`, `assets/` (bukan bagian skill)
