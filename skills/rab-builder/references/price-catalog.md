# Katalog Harga — rab-builder

> Harga referensi untuk komponen RAB. Setiap entri punya `dicek` (tanggal terakhir diverifikasi).
> Aturan: tanggal cek > 3 bulan ATAU bertanda **VERIFIKASI LIVE** → WAJIB verifikasi ulang via WebSearch sebelum dipakai di RAB.
> Jangan pernah mengarang harga yang tidak ada di katalog ini tanpa verifikasi live.

## E. Jasa Pengembang (solo — Mas Wondho, full vibe coding: ide + prompt + verifikasi)

> Dua angka BERBEDA dengan peran berbeda — jangan dicampur:
> **Harga pokok internal** = tarif × jam (kecil, karena AI yang menulis kode) → dasar RAB internal.
> **Harga paket nilai** = harga jual ke klien → dasar penawaran. Selisih = margin.

**Harga pokok internal** (basis: peran manusia = ide, prompting, review, verifikasi — bukan koding manual):

| Parameter | Nilai | Catatan |
|-----------|-------|---------|
| Jam kerja efektif | 40 jam/minggu (8 × 5) | sesi prompting + review + verifikasi + komunikasi klien |
| Tarif harga pokok | Rp75.000/jam | USER-OVERRIDABLE per RAB — peran prompter/verifier, bukan developer manual; angka pokok boleh kecil karena volume jual ditentukan paket nilai |
| Total pokok contoh | MVP 3 hari (24 jam): Rp1,8 jt · Sedang 1,5 bln (60 jam): Rp4,5 jt · Besar 1 bln (160 jam): Rp12 jt | turun otomatis karena durasi vibe coding pendek |

**Harga paket nilai (harga jual ke klien — dasar penawaran)**:

| Kategori | Durasi kerja (Fase 2) | Harga jual | Catatan |
|----------|------------------------|------------|---------|
| MVP kecil | 2-4 hari | Rp15-25 juta | positioning: "sistem siap pakai dalam hitungan hari" |
| Aplikasi sedang | 1-2 minggu | Rp30-60 juta | |
| Aplikasi besar | 3-6 minggu | Rp80-150 juta | |
| Enterprise | 2-3 bulan | nego khusus (mulai Rp150 juta) | |

- Aturan: harga jual = paket nilai (kecuali user override). Harga pokok TIDAK pernah ditampilkan ke klien.
- Bila user minta diskon: batas sehat = jangan di bawah 2× harga pokok tanpa persetujuan eksplisit (tetap ada buffer rework).
- Kecepatan vibe coding = daya saing utama: klien dibayar per hasil, kita selesai cepat → margin sehat + kapasitas proyek paralel lebih banyak per bulan.

## G. Overhead Operasional (alokasi ke proyek)

| Item | Nilai | Per | Status | dicek |
|------|-------|-----|--------|-------|
| Listrik | Rp400.000 | bulan | FIX (input user 2026-10-23) | 2026-10-23 |
| Internet | Rp350.000 | bulan | FIX (input user 2026-10-23) | 2026-10-23 |

- Alokasi: prorata durasi proyek; bila paralel N proyek → bagi rata, catat eksplisit.
- Total overhead: Rp750.000/bulan penuh.

## A. AI Tooling (metode vibe coding — INTERNAL SAJA)

| Item | Harga | Per | Status | dicek |
|------|-------|-----|--------|-------|
| z.ai Coding Plan Max | $80 | bulan | STABIL (langganan user) | 2026-10-23 |
| z.ai Coding Plan Lite | $19 | bulan | VERIFIKASI LIVE | 2026-10-23 |
| z.ai Coding Plan Pro | $40 | bulan | VERIFIKASI LIVE | 2026-10-23 |

- Plan Max = plan utama user. Lite/Pro dicantumkan sebagai pembanding bila user pertimbangkan downgrade/upgrade.
- Konversi prorata: 1 bulan = 4.33 minggu → $80/bulan ≈ $18.5/minggu.

## B. Infrastruktur Produksi (standar stack Slackercoder: Ubuntu + OpenLiteSpeed + aaPanel)

| Item | Harga | Per | Status | dicek |
|------|-------|-----|--------|-------|
| VPS kecil (1-2 GB RAM, 1 vCPU) — contoh Vultr/Hetzner CX22 class | $4-6 | bulan | VERIFIKASI LIVE (harga provider berubah) | 2026-10-23 |
| VPS sedang (4 GB RAM, 2 vCPU) — app produksi multi-user | $8-15 | bulan | VERIFIKASI LIVE | 2026-10-23 |
| VPS besar (8 GB RAM+) — traffic tinggi/enterprise | $20-40 | bulan | VERIFIKASI LIVE | 2026-10-23 |
| Domain .com | $10-15 | tahun | VERIFIKASI LIVE (registrar berbeda-beda) | 2026-10-23 |
| Domain .id | Rp150rb-500rb | tahun | VERIFIKASI LIVE | 2026-10-23 |
| SSL Let's Encrypt | $0 | — | STABIL (standar stack) | 2026-10-23 |
| Cloudflare Free (DNS+CDN) | $0 | — | STABIL | 2026-10-23 |

## C. Layanan Pihak Ketiga (free tier vs berbayar)

| Item | Free tier | Berbayar | Status | dicek |
|------|-----------|----------|--------|-------|
| Supabase (Postgres) | 2 project, 500MB | $25/bulan Pro | VERIFIKASI LIVE | 2026-10-23 |
| Neon (Postgres) | 0.5GB | $19/bulan Scale | VERIFIKASI LIVE | 2026-10-23 |
| Resend (email transaksional) | 3.000 email/bln | $20/bulan (50rb) | VERIFIKASI LIVE | 2026-10-23 |
| Cloudinary (media) | 25 credit/bln | $33-89/bulan | VERIFIKASI LIVE | 2026-10-23 |
| Vercel hosting | hobby free (non-komersial) | $20/bulan Pro | VERIFIKASI LIVE | 2026-10-23 |
| Upstash Redis | 10k cmd/hari | $5-10/bulan | VERIFIKASI LIVE | 2026-10-23 |

## D. Payment Gateway (fee — catatan operasional, BUKAN biaya tetap RAB)

| Item | Fee | Status | dicek |
|------|-----|--------|-------|
| Midtrans | ~2.9% + Rp2.000/qris; kartu lebih tinggi | VERIFIKASI LIVE | 2026-10-23 |
| Xendit | ~1.5-2% tergantung metode | VERIFIKASI LIVE | 2026-10-23 |
| Stripe (international) | ~2.9% + $0.30 | VERIFIKASI LIVE | 2026-10-23 |

## E. Kurs

USD→IDR: **VERIFIKASI LIVE SETIAP RAB** — kurs bergerak harian. Ambil kurs tengah (BI/Google), tulis nilai + tanggal di dokumen RAB. Jangan hardcode angka lama.

## Catatan Pemeliharaan Katalog

- Katalog ini diperbarui manual saat skill dipakai dan harga diverifikasi — update tanggal `dicek` setelah verifikasi.
- Harga VERIFIKASI LIVE yang sudah diverifikasi hari itu boleh langsung dipakai (update tanggalnya).
- Temukan harga berubah signifikan (>20%) → update baris katalog di commit yang sama dengan RAB terkait.
