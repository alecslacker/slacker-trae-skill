---
name: rab-builder
description: "Pandu membuat RAB (Rencana Anggaran Biaya) dari rancangan sistem yang sudah ada PRD/desainnya, dihitung dengan metode vibe coding berlangganan AI (z.ai Coding Plan Max $80/bulan). Invoke saat user bilang 'buat RAB', 'hitung biaya pembuatan', 'estimasi biaya sistem/aplikasi', atau setelah PRD selesai dan mau dianggarkan. Do not use untuk RAB konstruksi/fisik atau biaya operasional murni tanpa pembuatan."
---

# RAB Builder — Rencana Anggaran Biaya Sistem (Metode Vibe Coding)

Skill ini menghitung biaya PEMBUATAN sebuah sistem/aplikasi berdasarkan rancangan yang sudah ada. Premis biaya: pengerjaan pakai **metode vibe coding** (operator + AI agent) dengan AI utama **z.ai Coding Plan Max ($80/bulan)** — bukan tarif jam-manusia tradisional.

## Prinsip Inti

1. **Rancangan dulu, RAB kemudian** — RAB dihitung DARI desain rancangan (PRD prd-builder / DESIGN.md / deskripsi), bukan dari nol. Bila belum ada rancangan, arahkan ke `prd-builder` dulu.
2. **Vibe coding economics** — biaya utama = langganan AI × durasi, bukan gaji developer × jam. Durasi ditentukan jumlah & kompleksitas fitur.
3. **Harga jangan basi** — harga langganan stabil boleh dari katalog (`references/price-catalog.md`); harga yang berubah cepat (hosting promo, fee payment, kurs) WAJIB diverifikasi live saat RAB dibuat.
4. **Semua angka punya jejak** — tiap item biaya menyertakan asumsi (durasi, tier, jumlah unit). Ubah asumsi = angka ikut berubah, jadi asumsi wajib eksplisit.
5. **Satu pertanyaan per giliran** — pakai `AskUserQuestion` untuk pertanyaan pilihan (pola prd-builder).
6. **Output ke `.trae/documents/`** — `rab-[nama-proyek].md`.

## Kapan Dipakai (Trigger)

**Gunakan ketika:**
- User bilang: "buat RAB", "hitung biaya pembuatan", "estimasi biaya", "berapa modal untuk bikin [aplikasi X]"
- PRD baru selesai (Phase 1 prd-builder) dan user mau tahu anggaran
- User mau proposal/penawaran ke klien berbasis sistem yang sudah dirancang

**JANGAN gunakan ketika:**
- RAB konstruksi/fisik (bangunan, hardware procurement murni)
- User hanya mau biaya operasional bulanan tanpa pembuatan (jawab langsung dari katalog)
- Belum ada rancangan sama sekali → arahkan ke `prd-builder`

---

## Alur 4 Fase

### Fase 1 — Pahami Stack dari Rancangan

Sumber input (urut prioritas):
1. **PRD** (`prd-[nama].md` di `.trae/documents/`) — baca Section 3 (Features), 5 (Architecture), 7 (Tech Stack), 8 (Design System untuk skala UI)
2. **DESIGN.md + dokumen lain** (plan-, wireframe-) bila ada
3. **Deskripsi verbal user** — bila belum ada PRD, tanya inti: fitur apa saja, platform apa, integrasi apa

Ekstrak ke **Tabel Stack** (tampilkan ke user untuk konfirmasi):

| Lapisan | Teknologi/Layanan | Biaya-relevan? |
|---------|-------------------|----------------|
| Frontend | [mis. Next.js + Tailwind + shadcn/ui] | build-time saja |
| Backend | [mis. Laravel / Next.js API] | — |
| Database | [mis. PostgreSQL Supabase / MySQL VPS] | tier free/berbayar? |
| Auth | [mis. Better Auth / Sanctum] | — |
| Integrasi | [mis. Midtrans, Resend, Cloudinary] | fee/subscription? |
| Hosting produksi | [mis. VPS aaPanel / Vercel] | $/bulan, spec |
| Domain | [.com/.id] | $/tahun |
| Aset visual | [Seedream via plan existing / desainer] | bila perlu |

**Gate Fase 1**: tabel stack dikonfirmasi user sebelum lanjut. Setiap integrasi BERBAYAR wajib teridentifikasi di sini — yang lolos fase ini masuk RAB; yang tidak, tidak dihitung.

### Fase 2 — Estimasi Durasi Vibe Coding

Klasifikasikan scope dari jumlah fitur (PRD Section 3) dan kompleksitas:

| Kategori | Ciri | Durasi vibe coding |
|----------|------|--------------------|
| **Prototip/MVP kecil** | 3-5 fitur CRUD sederhana, 1 role, tanpa pembayaran | 1-2 minggu |
| **Aplikasi sedang** | 6-10 fitur, auth multi-role, 1-2 integrasi (pembayaran/email) | 3-6 minggu |
| **Aplikasi besar** | 10+ fitur, multi-role kompleks, integrasi banyak, laporan/analitik | 2-3 bulan |
| **Sistem enterprise** | multi-modul, migrasi data, SLA, audit | 3+ bulan (pecah per modul) |

**Faktor pengali durasi** (jumlahkan bila relevan, sebutkan eksplisit):
- Desain custom tinggi (bukan shadcn default): +20-30%
- Migrasi data dari sistem lama: +15-25%
- Integrasi pembayaran + webhook + rekonsiliasi: +10-20%
- Kurang dari PRD lengkap (hanya deskripsi): +25-40% (risiko rework)

**Gate Fase 2**: tampilkan kategori + durasi + faktor → konfirmasi user. Durasi inilah yang mengalikan biaya langganan AI.

### Fase 3 — Susun Komponen Biaya

Hitung per kategori (harga dari `references/price-catalog.md`, verifikasi live bila katalog menandai "VERIFIKASI LIVE" atau tanggal cek > 3 bulan):

**A. AI Tooling (vibe coding)** — WAJIB
- z.ai Coding Plan Max: $80/bulan, prorata per minggu ($80 × durasi_minggu / 4.33)
- Lain-lain bila user sebut (mis. Seedream plan untuk aset)

**B. Infrastruktur Development**
- Staging: default $0 (Laragon lokal / free tier) kecuali user minta VPS khusus
- Tooling: $0 (repo GitHub private free, CI free tier)

**C. Infrastruktur Produksi (periode awal — default 3 bulan pertama, konfirmasi user)**
- VPS prod (spec dari beban estimasi: kecil 1-2GB RAM untuk MVP, 4GB+ untuk app sedang)
- Domain per tahun
- SSL: Let's Encrypt $0 (standar stack kita)
- Backup storage (bila VPS tanpa snapshot gratis)

**D. Layanan Pihak Ketiga** (dari tabel stack Fase 1)
- Subscription berbayar (Resend, Cloudinary, dll) selama periode RAB
- Payment gateway: catat fee per transaksi sebagai CATATAN operasional (bukan biaya tetap RAB)

**E. SDM/Operator** (opsional)
- Solo vibe coding (Mas Wondho sendiri): $0
- Operator tambahan: input dari user, jangan diasumsikan

**F. Contingency** — default 15% dari A+E (rework, scope creep, iterasi desain). Konfirmasi user.

**Kurs**: tanya/verifikasi kurs USD→IDR saat RAB dibuat (WebSearch bila user minta IDR dan tidak kasih kurs). Tulis kurs + tanggal di RAB.

**Gate Fase 3**: tampilkan tabel komponen + subtotal → konfirmasi user.

### Fase 4 — Generate Dokumen RAB

1. Rangkai pakai template `references/rab-template.md`
2. **Anti-typo check** (pola 4-cek prd-builder: ejaan, konsistensi istilah, format tabel, koherensi angka — pastikan subtotal/total aritmetikanya BENAR, hitung ulang)
3. Simpan `rab-[nama-proyek].md` ke `.trae/documents/`
4. Tawarkan: update `project_memory` (ringkasan RAB), export PDF/docx untuk klien, atau revisi asumsi (ubah durasi/kurs → regenerasi otomatis)

---

## Integrasi

| Dari/Ke | Perilaku |
|---------|----------|
| `prd-builder` | Sumber utama input (PRD Section 3/5/7/8). Setelah PRD Phase 1 selesai, prd-builder boleh menawarkan chain ke skill ini |
| `project memory` | Simpan ringkasan RAB (total, durasi, kurs, tanggal) sebagai entri MXXX setelah user setuju |
| Klien/penawaran | Export via skill `docx`/`pdf`/`html-report`; untuk proposal pakai `consulting-analysis` |

## Hard Rules

- DILARANG menghitung RAB tanpa tabel stack yang dikonfirmasi (Fase 1 gate)
- DILARANG memakai harga dari katalog yang bertanda VERIFIKASI LIVE atau tanggal cek > 3 bulan tanpa verifikasi ulang (WebSearch)
- DILARANG menyembunyikan asumsi — durasi, tier, unit, kurs wajib tertulis di dokumen
- DILARANG memasukkan fee per-transaksi (payment gateway) sebagai biaya tetap — itu catatan operasional
- DILARANG mengasumsikan SDM berbayar — default solo $0, kecuali user menyatakan
- WAJIB hitung ulang aritmetika subtotal/total sebelum simpan file
- WAJIB tulis kurs + tanggal kurs bila menampilkan IDR
- Satu pertanyaan per giliran; pertanyaan pilihan pakai `AskUserQuestion`
