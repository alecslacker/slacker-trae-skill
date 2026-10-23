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

**Skala premi skema langganan (per tenor)**:

| Tenor | Premi | Keterangan |
|-------|-------|------------|
| 6 bulan | +25% | MINIMUM tenor — di bawah ini skema kehilangan fungsi (cicilan sama berat dengan bayar sekali) |
| 12 bulan | +20% | DEFAULT — cicilan ringan, recurring setahun penuh |
| 18-24 bulan | +15% | terbaik utk recurring revenue; tawarkan aktif ke klien |

- Rumus bulanan: `bulanan = ceil((nilai_jual + premi%) / tenor)` — pembulatan ke ribuan terdekat.
- Klausul wajib dokumen: hosting di server DCI + domain atas nama DCI selama tenor; migrasi penuh ke klien setelah lunas (tenor habis atau pelunasan dini, premi sisa dihapus).

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

## B. Infrastruktur Produksi — ACUAN: Tencent Cloud Lighthouse (standar stack Slackercoder)

> Server modal memakai Tencent Cloud Lighthouse (region Jakarta/Singapore). Karakter Lighthouse: harga flat all-in (CPU+RAM+SSD+traffic), sering ada promo tahun pertama jauh lebih murah — harga promo JANGAN dipakai untuk proyeksi tahunan; proyeksi pakai harga normal (renewal).

| Paket Lighthouse | Spec | Harga normal | Cocok untuk | Status | dicek |
|------------------|------|--------------|-------------|--------|-------|
| Starter | 2 vCPU / 2 GB / 40 GB SSD | ≈ $4-5/bulan (Jakarta/Singapore) | MVP kecil, landing+app ringan, 1 aplikasi | VERIFIKASI LIVE | 2026-10-23 |
| General | 2 vCPU / 4 GB / 60 GB SSD | ≈ $6-8/bulan | Aplikasi sedang multi-user, 2-3 app dalam 1 server | VERIFIKASI LIVE | 2026-10-23 |
| Besar | 4 vCPU / 8 GB / 100+ GB SSD | ≈ $15-25/bulan | App besar/traffic tinggi, DB terpisah | VERIFIKASI LIVE | 2026-10-23 |

- Node terdekat user Indonesia: **Jakarta** (latensi terbaik); Singapore alternatif bila butuh stabilitas regional.
- Catatan multi-tenant: 1 Lighthouse General bisa menampung 2-3 aplikasi klien kecil via aaPanel + OpenLiteSpeed → di RAB skema langganan, server bisa dialokasikan per klien (dedicated, harga penuh) atau shared (alokasi proporsional) — sebutkan eksplisit per proyek.

| Item | Harga | Per | Status | dicek |
|------|-------|-----|--------|-------|
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
