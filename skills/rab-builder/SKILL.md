---
name: rab-builder
description: "Pandu membuat RAB (Rencana Anggaran Biaya) dari rancangan sistem yang sudah ada PRD/desainnya, dihitung dengan metode vibe coding berlangganan AI (z.ai Coding Plan Max $80/bulan). Invoke saat user bilang 'buat RAB', 'hitung biaya pembuatan', 'estimasi biaya sistem/aplikasi', atau setelah PRD selesai dan mau dianggarkan. Do not use untuk RAB konstruksi/fisik atau biaya operasional murni tanpa pembuatan."
---

# RAB Builder — Rencana Anggaran Biaya Sistem (Metode Vibe Coding)

Skill ini menghitung biaya PEMBUATAN sebuah sistem/aplikasi berdasarkan rancangan yang sudah ada. Premis biaya: pengerjaan pakai **metode vibe coding** (operator + AI agent) dengan AI utama **z.ai Coding Plan Max ($80/bulan)** — bukan tarif jam-manusia tradisional.

## Prinsip Inti

1. **Rancangan dulu, RAB kemudian** — RAB dihitung DARI desain rancangan (PRD prd-builder / DESIGN.md / deskripsi), bukan dari nol. Bila belum ada rancangan, arahkan ke `prd-builder` dulu.
2. **Vibe coding economics (INTERNAL SAJA)** — biaya utama = langganan AI × durasi, bukan gaji developer × jam. Durasi ditentukan jumlah & kompleksitas fitur. Ini BASIS HITUNG internal; ke klien tampil sebagai "biaya pengembangan sistem" profesional — DILARANG menyebut vibe coding, AI, z.ai, atau harga langganan model di dokumen klien (lihat Hard Rules).
3. **Harga jangan basi** — harga langganan stabil boleh dari katalog (`references/price-catalog.md`); harga yang berubah cepat (hosting promo, fee payment, kurs) WAJIB diverifikasi live saat RAB dibuat.
4. **Semua angka punya jejak** — tiap item biaya menyertakan asumsi (durasi, tier, jumlah unit). Ubah asumsi = angka ikut berubah, jadi asumsi wajib eksplisit.
5. **Satu pertanyaan per giliran** — pakai `AskUserQuestion` untuk pertanyaan pilihan (pola prd-builder).
6. **Output ke `.trae/documents/`** — `rab-[nama-proyek].md` (versi kerja lengkap) dan `penawaran-[nama-aplikasi]-[nama-klien].md` (versi klien, bila diminta).

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

## Alur 5 Fase (3.5 opsional bila klien belum tentu)

### Fase 0 — Identitas Klien & Aplikasi (Wajib Pertama)

Dokumen RAB disesuaikan dengan nama aplikasi dan nama klien. Kumpulkan:

1. **Nama aplikasi/sistem** (chat biasa): "Sistem/aplikasi ini mau dinamai apa?" — pakai untuk judul dokumen & seluruh penyebutan. Belum ada nama → gunakan nama proyek internal, tandai `[NAMA APLIKASI]` sebagai placeholder yang wajib dikonfirmasi sebelum final.
2. **Nama klien** + bentuknya (chat biasa): "Untuk klien siapa? (sebutkan bentuk lengkap: PT/CV/perorangan/instansi)" — pakai di judul, intro, dan penjumlahan akhir.
3. **Jenis dokumen** (`AskUserQuestion`):
   - **RAB internal** — kerja lengkap: semua komponen + asumsi + jejak harga (tidak dikirim ke klien)
   - **Penawaran klien** — dokumen resmi: kop PT, intro, judul per klien, komponen biaya klien-facing (metode & AI internal TIDAK tampil)
   - **Keduanya** — hitung sekali (internal), render dua output
4. Simpan jawaban; seluruh fase berikutnya otomatis memakai nama ini.

Basis identitas perusahaan (kop, intro, kredibilitas) ambil dari `references/company-profile.md` — jangan karang data PT.

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

### Fase 3.5 — Skema Pembayaran (sesuai kemampuan klien)

Satu proyek, tiga cara bayar. Tanyakan via `AskUserQuestion` ("Skema mana yang cocok dengan kemampuan klien ini?"), boleh tampilkan simulasi ringkas tiap opsi sebagai description. Agent WAJIB menampilkan simulasi sebelum klien memilih.

| Skema | Cocok untuk | Struktur |
|-------|-------------|----------|
| **One-time** | Klien beranggaran penuh (instansi/korporasi dengan dana siap) | 100% nilai proyek: DP 50% awal + 50% serah terima (2 transaksi). Termasuk garansi bug 30 hari |
| **Termin bertahap** | Klien menengah — arus kas terbatas tapi proyek tetap sekali bayar | Nilai proyek dipecah 3-5 termin mengikuti milestone PRD (mis. 30/40/30 atau 25/25/25/25). Tiap termin = milestone terverifikasi. Total = sama dengan one-time (tanpa bunga) |
| **Langganan bulanan** | Klien kecil/UMKM — modal terbatas, tapi butuh sistem berkelanjutan | Uang muka kecil (default 1× biaya bulanan) + bulanan tetap selama tenor. Tenor default 12 bulan; total = nilai proyek + premi langganan (default +15-25% sebagai kompensasi penundaan kas & risiko). SUDAH TERMASUK pemeliharaan aktif selama tenor (nilai tambah nyata, bukan sekadar cicilan) |

**Aturan simulasi** (WAJIB tampilkan sebelum user pilih):
- Hitung ketiganya dari total Fase 3 (konversi IDR pakai kurs aktif)
- Langganan: `bulanan = ceil((nilai + premi) / tenor)` — pembulatan ke ribuan; tulis total bayar + selisih vs one-time (biaya skema)
- Termin: susun % + nominal + milestone pengikat per termin
- Tampilkan ketiganya berdampingan → user memilih berdasarkan kemampuan klien, bukan agent memutuskan

**Catatan skema**:
- Skema langganan selalu dilampiri klausul berhenti/pelunasan dini: sisa tenor dibayar sekaligus tanpa premi berjalan (discount premi sisa), sistem tetap milik klien setelah lunas
- Boleh kombinasi (mis. termin 2x untuk pengembangan + langganan bulanan untuk maintenance pasca serah terima) — tawarkan bila user ragu
- Pilihan skema tercatat di project memory (M-entry) karena memengaruhi penagihan berulang

**Gate Fase 3.5**: skema terpilih + simulasi final dikonfirmasi user sebelum generate dokumen.

### Fase 4 — Generate Dokumen

Render sesuai jenis dokumen dari Fase 0 (data hitungan sama):

1. **RAB internal** (`rab-[nama-proyek].md`): pakai template `references/rab-template.md` Section lengkap — termasuk komponen A (AI tooling), asumsi, jejak harga. Untuk kerja internal, bukan klien.
2. **Penawaran klien** (`penawaran-[nama-aplikasi]-[nama-klien].md`): pakai bagian "Dokumen Penawaran Klien" di template yang sama — kop PT, judul "RAB Pengembangan [Nama Aplikasi] untuk [Nama Klien]", intro wajib (lihat bawah), komponen biaya klien-facing (biaya pengembangan sistem terintegrasi — breakdown tanpa sebut metode/AI), infrastruktur, layanan pihak ketiga, total IDR, syarat & ketentuan, rekening korporasi.

**Intro wajib dokumen klien** (pola, personalisasi per klien — basis dari `references/company-profile.md`):
- Paragraf 1: siapa kami (PT Duta Corpora Indonesia — 1 kalimat kredibilitas) + untuk apa dokumen ini (RAB pengembangan [Nama Aplikasi] untuk [Nama Klien])
- Paragraf 2: 1-2 kalimat tentang aplikasi yang dianggarkan (dari PRD Overview) + klaim kredibilitas YANG RELEVAN dengan segmen klien (bank → BPD Jatim; desa/pemerintahan → SID Blitar; filantropi → LAZISNU; dst)

3. **Anti-typo check** (pola 4-cek prd-builder) + hitung ulang aritmetika subtotal/total
4. Simpan ke `.trae/documents/`
5. Tawarkan: update `project_memory`, export PDF/docx, revisi asumsi

**Konversi komponen internal → tampilan klien**:

| Internal (RAB kerja) | Tampilan di dokumen klien |
|----------------------|---------------------------|
| A. AI Tooling (z.ai $80 × durasi) | "Biaya Pengembangan Sistem [Nama Aplikasi]" (satu angka profesional) |
| B. Infra dev $0 | (tidak tampil) |
| C. Infra produksi | "Infrastruktur & Penyelenggaraan" (VPS, domain — tetap rinci, itu biaya nyata klien) |
| D. Layanan pihak ketiga | tetap rinci |
| E. SDM $0 | (tidak tampil) |
| F. Contingency | boleh masuk ke biaya pengembangan atau baris "Cadangan Operasional" |

---

## Integrasi

| Dari/Ke | Perilaku |
|---------|----------|
| `prd-builder` | Sumber utama input (PRD Section 3/5/7/8). Setelah PRD Phase 1 selesai, prd-builder boleh menawarkan chain ke skill ini |
| `project memory` | Simpan ringkasan RAB (total, durasi, kurs, tanggal) sebagai entri MXXX setelah user setuju |
| Klien/penawaran | Export via skill `docx`/`pdf`/`html-report`; untuk proposal pakai `consulting-analysis` |

## Hard Rules

- DILARANG menyebut vibe coding, AI, z.ai, harga langganan model, atau "metode pengerjaan internal" di dokumen klien — itu basis hitung internal; di dokumen klien tampil sebagai "Biaya Pengembangan Sistem"
- DILARANG generate dokumen klien tanpa: (1) nama aplikasi + nama klien di judul, (2) intro 2 paragraf (siapa kami + konteks aplikasi & kredibilitas relevan), (3) kop PT dari company-profile.md
- DILARANG mengarang data PT Duta Corpora Indonesia — semua identitas/klaim dari `references/company-profile.md` saja
- DILARANG menghitung RAB tanpa tabel stack yang dikonfirmasi (Fase 1 gate)
- DILARANG memakai harga dari katalog yang bertanda VERIFIKASI LIVE atau tanggal cek > 3 bulan tanpa verifikasi ulang (WebSearch)
- DILARANG menyembunyikan asumsi — durasi, tier, unit, kurs wajib tertulis di dokumen internal; di dokumen klien, asumsi durasi tampil sebagai "estimasi waktu pengerjaan"
- DILARANG memasukkan fee per-transaksi (payment gateway) sebagai biaya tetap — itu catatan operasional
- DILARANG menawarkan skema pembayaran tanpa simulasi angka ketiganya (one-time vs termin vs langganan) — user memilih berdasarkan angka, bukan narasi
- DILARANG skema langganan tanpa klausul pelunasan dini + kejelasan kepemilikan sistem setelah lunas
- DILARANG premi langganan > 25% tanpa persetujuan eksplisit user (keadilan harga vs klien kecil)
- WAJIB skema termin mengikat milestone terverifikasi (PRD) per termin — tidak ada termin tanpa deliverable
- WAJIB catat skema terpilih ke project memory
- DILARANG mengasumsikan SDM berbayar — default solo $0, kecuali user menyatakan
- WAJIB hitung ulang aritmetika subtotal/total sebelum simpan file
- WAJIB tulis kurs + tanggal kurs bila menampilkan IDR
- WAJIB pakai nama aplikasi & nama klien konsisten di seluruh dokumen (1 konsep = 1 nama)
- Satu pertanyaan per giliran; pertanyaan pilihan pakai `AskUserQuestion`
