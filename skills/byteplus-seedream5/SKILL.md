---
name: byteplus-seedream5
description: >
  Generate gambar dengan kombinasi Dola-Seedream-5.0-pro + Dola-Seedream-5.0-lite
  langsung via API BytePlus ModelArk (bypass MCP byteplus-image yang terkunci
  Seedream 4.x). Pro untuk kualitas maksimal (precise editing, layer control,
  teks multibahasa termasuk Indonesia), Lite untuk resolusi hingga 4K, batch,
  dan hemat. Gunakan saat user minta "generate image seedream", "gambar dola
  pro", "5.0 lite", atau gambar apapun yang butuh kualitas tinggi.
license: MIT
metadata:
  version: "2.0.0"
  author: Slackercoder (untuk Mas Wondho)
user-invokable: true
argument-hint: "[prompt] --model pro|lite|4.5 --size 2K --out <folder>"
---

# BytePlus Seedream 5.0 — Dola Pro + Dola Lite

Skill standalone yang memanggil API BytePlus ModelArk langsung. Dibuat karena
MCP `byteplus-image` hanya mendukung Seedream 4.x (validasi enum server).

Kombinasi aktif akun Mas Wondho (diverifikasi konsol + API 2026-08-31):
**Dola-Seedream-5.0-pro** dan **Dola-Seedream-5.0-lite**.

## Model yang Didukung

| Mode | Model ID | Resolusi | Harga | Kapan dipakai |
|------|----------|----------|-------|---------------|
| `pro` (default) | `dola-seedream-5-0-pro-260628` | 1K, 1.5K, 2K | $0.045/gbr | **Kualitas maksimal**: precise editing, layer decomposition (16 layer), koordinat bbox, infographic, **teks multibahasa native termasuk Bahasa Indonesia** |
| `lite` | `seedream-5-0-260128` | 2K, 3K, 4K | $0.035/gbr | **Resolusi tertinggi + hemat**: estetika terbaru, konsistensi karakter antar gambar, batch output (1-15), web-connected retrieval |
| `4.5` | `seedream-4-5-251128` | 2K, 4K | $0.04/gbr | Opsi cadangan; text rendering klasik |

> Catatan: ID API Dola-Lite memakai nama `seedream-5-0-260128` (tanpa prefix
> dola) — nama "Dola-Seedream-5.0-lite" hanya branding UI konsol. Alias
> `seedream-5-0-lite-260128` otomatis dipetakan script.

## Strategi Kombinasi (Hasil Maksimal)

1. **Default `pro`** untuk kualitas terbaik — reasoning terkuat, patuh instruksi
   kompleks, komposisi paling presisi.
2. **`lite`** saat butuh: resolusi 3K/4K, batch banyak gambar konsisten
   (karakter/produk sama), atau hemat biaya ($0.035 vs $0.045).
3. **Teks dalam gambar** (poster, infografis, banner Bahasa Indonesia) → `pro`
   (dukungan 14 bahasa native, Indonesia termasuk).
4. **Edit presisi / pisah layer** → hanya `pro` yang mendukung interactive
   editing (bbox, point) dan layer decomposition.
5. **Workflow produksi**: konsep & final via `pro`; varian resolusi besar / set
   gambar konsisten via `lite`.

## Prasyarat

API key sudah diset user-level di registry Windows (`ARK_API_KEY`).
Untuk sesi terminal baru, ambil dulu dari registry:

```powershell
$env:ARK_API_KEY = [Environment]::GetEnvironmentVariable('ARK_API_KEY','User')
```

Security note: key TIDAK pernah disimpan di file kode/skill. Script membaca
dari env dan tidak pernah mencetak isi key.

## Cara Pakai

Jalankan dengan `C:\Python312\python.exe`:

```powershell
$py = 'C:\Python312\python.exe'
$s  = 'C:\Users\alecs\.trae\skills\byteplus-seedream5\scripts\seedream5_generate.py'
$env:ARK_API_KEY = [Environment]::GetEnvironmentVariable('ARK_API_KEY','User')

# Kualitas maksimal - Dola Pro (default), 2K
& $py $s --prompt "majestic Borobudur temple at golden sunrise, warm mist, cinematic photography, rich amber and emerald tones" --model pro --size 2K

# Resolusi 4K + hemat - Dola Lite
& $py $s --prompt "..." --model lite --size 4K

# Batch 3 gambar konsisten via lite
& $py $s --prompt "..." --model lite --size 2K --count 3 --seed 42

# Cek model yang terakses akun
& $py $s --list-live
```

## Prompt Engineering (sesuai karakter Indonesia/Jawa)

Struktur prompt: `[SUBJEK] + [LINGKUNGAN] + [PENCAHAYAAN] + [GAYA] + [DETAIL]`

- Untuk konten Mas Wondho: komposisi premium & teliti. Tema Nusantara (batik, candi,
  pemandangan Jawa, kehidupan desa) hanya bila cocok kontennya atau diminta — bukan default semua gambar.
- `pro` memahami Bahasa Indonesia native — teks dalam gambar (poster, heading)
  bisa langsung ditulis Indonesia: `text "Semangat Gotong Royong"`.
- Sebutkan hex code warna untuk konsistensi palet antar gambar.

## Parameter Script

| Argumen | Default | Keterangan |
|---------|---------|------------|
| `--prompt` | wajib | Deskripsi gambar (3-2000 karakter) |
| `--model` | `pro` | `pro` \| `lite` \| `4.5` \| model ID lengkap |
| `--size` | 2K | pro: 1K/1.5K/2K; lite: 2K/3K/4K; 4.5: 2K/4K |
| `--count` | 1 | Jumlah gambar (1-15; batch paling optimal di lite) |
| `--out` | `~/Pictures/byteplus-seedream5` | Folder penyimpanan |
| `--seed` | random | Reproducible |
| `--watermark` | false | Watermark ByteDance |
| `--timeout` | 120 | Detik |
| `--list-models` | — | Daftar model statis |
| `--list-live` | — | Daftar model dari akun (butuh key) |

## Error yang Mungkin

| Gejala | Penyebab | Solusi |
|--------|----------|--------|
| `ARK_API_KEY tidak ditemukan` | env belum di-load | Ambil dari registry (lihat Prasyarat) |
| HTTP 401 | Key salah/kadaluarsa | Regenerate di konsol |
| HTTP 404 / model not found | ID model beda di akun | `--list-live` lalu pakai ID asli |
| HTTP 402 / 429 | Saldo habis / rate limit | Cek saldo & kuota di konsol |
| `size tidak didukung` | Resolusi di luar kemampuan model | Pro max 2K; gunakan lite untuk 3K/4K |

## Related

- MCP `byteplus-image` — Seedream 4.5/4.0 via MCP (kuota gratis 200 gambar),
  tetap berguna untuk kebutuhan hemat tanpa set env.
- Konsol: https://console.byteplus.com/ark/region:ap-southeast-1/model
- Docs resmi: https://docs.byteplus.com/en/docs/ModelArk/2582774 (5.0 pro tutorial),
  https://docs.byteplus.com/en/docs/ModelArk/1824121 (text-to-image).