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
4. **Segmen pasar klien** (`AskUserQuestion`) — menentukan kolom harga jual (katalog paket nilai punya 2 kolom):
   - **Lokal Blitar/Jatim** — UMKM, desa, lembaga daerah, sekolah, usaha lokal (harga pasar lokal, harga-sensitif)
   - **Korporasi nasional** — bank, BUMN, lembaga nasional, perusahaan besar (harga nasional)
   - **Lainnya/ragu** → tanyakan skala organisasi + lokasi; default lokal bila berbasis Blitar/Jatim
5. Simpan jawaban; seluruh fase berikutnya otomatis memakai nama + segmen ini.

Basis identitas perusahaan (kop, intro, kredibilitas) ambil dari `references/company-profile.md` — jangan karang data PT.

### Fase 1 — Pahami Stack dari Rancangan

**Deteksi dulu bentuk rancangan, lalu panggil perangkat yang tepat** (jangan baca manual bila ada tool yang lebih tepat):

| Bentuk rancangan | Perangkat | Cara |
|------------------|-----------|------|
| **PRD dari prd-builder** (`prd-[nama].md` di `.trae/documents/`) | Baca langsung | Format terstandar: Section 3 (Features), 5 (Architecture), 7 (Tech Stack), 8 (Design System untuk skala UI). Plus `DESIGN.md`, `plan-`, `wireframe-` bila ada |
| **Project/codebase existing** (sudah ada kode, minta RAB/replikasi) | **Graphify** | Cek `graphify-out/` → ada: pahami struktur dari GRAPH_REPORT.md + graph.json (hemat token, DILARANG grep massal); tidak ada: jalankan `graphify . --code-only` dulu (proyek besar 3-15 menit → konfirmasi user). Detail file kode mentah hanya untuk yang biaya-relevan (dependency berbayar di composer.json/package.json, integrasi API) |
| **Codebase besar/arsitektur kompleks** | Agent `project-analyzer` | Bila Graphify tidak cukup (multi-repo, monorepo raksasa) — konfirmasi dulu ke user sebelum delegate, output di-review |
| **Belum ada rancangan sama sekali** | Redirect `prd-builder` | "RAB butuh rancangan sebagai basis. Mau kita rancang dulu (prd-builder), atau RAB kasar dari deskripsi?" — bila paksa deskripsi verbal, catat kena faktor durasi (Fase 2) |
| **Deskripsi verbal user** | Tanya terstruktur | Inti: fitur apa saja (jumlah = kategori Fase 2), platform, role, integrasi (apapun yang berbayar), ekspektasi timeline |

Ekstrak ke **Tabel Stack** (tampilkan ke user untuk konfirmasi):

| Lapisan | Teknologi/Layanan | Biaya-relevan? |
|---------|-------------------|----------------|
| Frontend | [mis. Next.js + Tailwind + shadcn/ui] | build-time saja |
| Backend | [mis. Laravel / Next.js API] | — |
| Database | [mis. PostgreSQL Supabase / MySQL VPS] | tier free/berbayar? |
| Auth | [mis. Better Auth / Sanctum] | — |
| Integrasi | [mis. Midtrans, Resend, Cloudinary] | fee/subscription? |
| Hosting produksi | [Tencent Lighthouse / Vercel] | $/bulan, spec (katalog §B) |
| Domain | [.com/.id] | $/tahun |
| Aset visual | [Seedream via plan existing / desainer] | bila perlu |

**Gate Fase 1**: tabel stack dikonfirmasi user sebelum lanjut. Setiap integrasi BERBAYAR wajib teridentifikasi di sini — yang lolos fase ini masuk RAB; yang tidak, tidak dihitung.

### Fase 2 — Estimasi Durasi Vibe Coding

Klasifikasikan scope dari jumlah fitur (PRD Section 3) dan kompleksitas:

**Premis durasi**: pengerjaan FULL vibe coding — Mas Wondho hanya memberi ide, arah, dan prompt; AI yang menulis seluruh kode. Kecepatan botleneck BUKAN mengetik kode, melainkan: loop prompt→review→koreksi (manusia memverifikasi hasil), kejelasan PRD (prompt dari rancangan yang jelas = iterasi sedikit), dan kompleksitas verifikasi (QA, integrasi, edge case tetap butuh ketelitian manusia).

| Kategori | Ciri | Durasi vibe coding (full AI) |
|----------|------|------------------------------|
| **Prototip/MVP kecil** | 3-5 fitur CRUD sederhana, 1 role, tanpa pembayaran | 2-4 hari |
| **Aplikasi sedang** | 6-10 fitur, auth multi-role, 1-2 integrasi (pembayaran/email) | 1-2 minggu |
| **Aplikasi besar** | 10+ fitur, multi-role kompleks, integrasi banyak, laporan/analitik | 3-6 minggu |
| **Sistem enterprise** | multi-modul, migrasi data, SLA, audit | 2-3 bulan (pecah per modul) |

**Faktor pengali durasi** (jumlahkan bila relevan, sebutkan eksplisit):
- Desain custom tinggi (bukan shadcn default): +15-25% (iterasi prompt visual lebih banyak, bukan jam koding)
- Migrasi data dari sistem lama: +15-25% (verifikasi & mapping data tetap kerja teliti)
- Integrasi pembayaran + webhook + rekonsiliasi: +10-20% (pengujian end-to-end wajib)
- Kurang dari PRD lengkap (hanya deskripsi): +20-30% (prompt ambigu = iterasi balik banyak)

**Konsekuensi ekonomi (WAJIB dipahami, JANGAN keliru)**: durasi pendek menurunkan HARGA POKOK internal (jasa = jam × tarif mengecil, langganan AI prorata mengecil) — tapi HARGA JUAL ke klien TIDAK ikut turun otomatis, karena dokumen klien memakai harga paket berbasis NILAI (katalog: MVP Rp15-25jt dst.), bukan tarif jam. Selisihnya = margin. RAB internal mencatat harga pokok yang jujur; penawaran klien memakai harga paket — dua angka berbeda itu disengaja dan sehat.

**Gate Fase 2**: tampilkan kategori + durasi + faktor → konfirmasi user. Durasi inilah yang mengalikan biaya langganan AI dan jam jasa.

### Fase 3 — Susun Komponen Biaya

Hitung per kategori (harga dari `references/price-catalog.md`, verifikasi live bila katalog menandai "VERIFIKASI LIVE" atau tanggal cek > 3 bulan):

**A. AI Tooling (vibe coding)** — WAJIB
- z.ai Coding Plan Max: $80/bulan, prorata per minggu ($80 × durasi_minggu / 4.33)
- Lain-lain bila user sebut (mis. Seedream plan untuk aset)

**B. Infrastruktur Development**
- Staging: default $0 (Laragon lokal / free tier) kecuali user minta VPS khusus
- Tooling: $0 (repo GitHub private free, CI free tier)

**C. Server Produksi & Domain — DIPISAH TEGAS (periode awal, default 3 bulan pertama, konfirmasi user)**
- **C1. Server/VPS produksi — acuan Tencent Cloud Lighthouse** (katalog §B): Starter 2C/2GB ≈ $4-5/bulan (MVP), General 2C/4GB ≈ $6-8/bulan (app sedang / multi-tenant 2-3 app via aaPanel), Besar 4C/8GB ≈ $15-25/bulan. Region default Jakarta. SSL Let's Encrypt $0; backup storage bila perlu. Ke skema langganan: pilih dedicated (harga penuh per klien) atau shared (alokasi proporsional) — sebutkan eksplisit
- **C2. Domain**: per tahun, per registrar — item terpisah agar klien bisa pakai domain sendiri / beli sendiri. Selalu tanyakan: "Klien sudah punya domain?" → bila ya, hapus C2 dari RAB

**D. Layanan Pihak Ketiga** (dari tabel stack Fase 1)
- Subscription berbayar (Resend, Cloudinary, dll) selama periode RAB
- Payment gateway: catat fee per transaksi sebagai CATATAN operasional (bukan biaya tetap RAB)

**E. Jasa Pengembang (solo — full vibe coding: ide + prompt + verifikasi)**
- Model kerja: Mas Wondho 8 jam/hari memberi ide, arah, prompt, dan memverifikasi hasil AI; AI menulis seluruh kode
- **Dua angka, dua peran (dari katalog)**: (1) HARGA POKOK internal = tarif_jam (default Rp75.000, peran prompter/verifier) × total jam — komponen RAB internal; (2) HARGA JUAL = paket nilai per kategori (MVP Rp15-25jt dst.) — angka yang masuk dokumen klien sebagai "Biaya Pengembangan Sistem". Selisih = margin, disengaja
- Total jam kerja: 5 hari/minggu × durasi (dari Fase 2, durasi vibe coding yang pendek) × 8 jam
- Harga jual TIDAK dihitung dari jam — jangan pernah tampilkan tarif jam ke klien
- Agent WAJIB tampilkan kedua angka di RAB internal (pokok vs jual + margin %) agar user lihat kesehatan proyek
- Operator tambahan (bila ada): input dari user, jangan diasumsikan

**F. Contingency** — default 15% dari A+E (rework, scope creep, iterasi desain). Konfirmasi user.

**G. Overhead Operasional (alokasi ke proyek)**
- Listrik: Rp400.000/bulan → alokasikan prorata durasi (durasi_bulan × Rp400.000)
- Internet: Rp350.000/bulan → prorata durasi (durasi_bulan × Rp350.000)
- Rumus alokasi: overhead dialokasikan 100% ke satu proyek bila hanya 1 proyek jalan; bila paralel N proyek → bagi rata per proyek, sebutkan pembagian eksplisit
- Overhead masuk harga pokok internal (bobot kecil), TIDAK ditampilkan sebagai baris terpisah ke klien — melebur ke "Biaya Pengembangan Sistem"

**Kurs**: tanya/verifikasi kurs USD→IDR saat RAB dibuat (WebSearch bila user minta IDR dan tidak kasih kurs). Tulis kurs + tanggal di RAB.

**Gate Fase 3**: tampilkan tabel komponen + subtotal → konfirmasi user.

### Fase 3.5 — Skema Pembayaran (sesuai kemampuan klien)

Satu proyek, tiga cara bayar. Tanyakan via `AskUserQuestion` ("Skema mana yang cocok dengan kemampuan klien ini?"), boleh tampilkan simulasi ringkas tiap opsi sebagai description. Agent WAJIB menampilkan simulasi sebelum klien memilih.

| Skema | Cocok untuk | Struktur |
|-------|-------------|----------|
| **One-time** | Klien beranggaran penuh (instansi/korporasi dengan dana siap) | 100% nilai proyek: DP 50% awal + 50% serah terima (2 transaksi). Termasuk garansi bug 30 hari |
| **Termin bertahap** | Klien menengah — arus kas terbatas tapi proyek tetap sekali bayar | Nilai proyek dipecah 3-5 termin mengikuti milestone PRD (mis. 30/40/30 atau 25/25/25/25). Tiap termin = milestone terverifikasi. Total = sama dengan one-time (tanpa bunga) |
| **Langganan bulanan** | Klien kecil/UMKM — modal terbatas, tapi butuh sistem berkelanjutan | Uang muka kecil (default 1× biaya bulanan) + bulanan tetap selama tenor. **Tenor MINIMAL 6 bulan** (di bawah itu cicilannya sama beratnya dengan bayar sekali — skema kehilangan fungsi); **default 12 bulan** (titik manis: cicilan ringan + recurring setahun penuh). Total = nilai proyek + premi langganan sesuai skala tenor (lihat bawah). SUDAH TERMASUK pemeliharaan aktif selama tenor (nilai tambah nyata, bukan sekadar cicilan) |

**Skala premi per tenor** (makin panjang makin murah per bulan — insentif kontrak panjang):

| Tenor | Premi | Catatan |
|-------|-------|---------|
| 6 bulan (MINIMUM) | +25% | tenor pendek = risiko & admin terkonsentrasi |
| 12 bulan (DEFAULT) | +20% | titik manis; ROU klien biasanya baru terasa setelah 3-6 bulan pemakaian |
| 18-24 bulan | +15% | terbaik untuk recurring revenue; tawarkan aktif |

**Klausul pengaman tenor panjang (WAJIB di dokumen klien skema C)**: sampai lunas, **aplikasi berjalan di server yang dikelola DCI + domain/akun layanan atas nama DCI**; setelah lunas (tenor habis atau pelunasan dini) → migrasi penuh ke milik klien. Ini menyeimbangkan: klien dapat sistem sejak bulan 1, kita tidak menanggung risiko tagihan 11 bulan tanpa jaminan.

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
| A. AI Tooling (z.ai $80 × durasi) | "Biaya Pengembangan Sistem [Nama Aplikasi]" — digabung dengan E, F, G jadi SATU angka profesional |
| B. Infra dev $0 | (tidak tampil) |
| C1. Server produksi | "Infrastruktur & Penyelenggaraan — Server" (biaya nyata klien, tetap rinci) |
| C2. Domain | "Infrastruktur & Penyelenggaraan — Domain" (baris terpisah; hapus bila klien pakai domain sendiri) |
| D. Layanan pihak ketiga | tetap rinci |
| E. Jasa (pokok = Rp75rb×jam; JUAL = paket nilai) | "Biaya Pengembangan Sistem" diisi HARGA JUAL paket (bukan tarif jam) |
| F. Contingency | melebur ke "Biaya Pengembangan Sistem" (atau baris "Cadangan Operasional") |
| G. Overhead listrik+internet | melebur ke "Biaya Pengembangan Sistem" — DILARANG tampil sebagai baris klien |

**Renewal tahun ke-2+ (WAJIB di setiap RAB berbasis langganan)**: RAB langganan hanya menutup tahun ke-1 — dokumen WAJIB menyertakan proyeksi tahun ke-2 dari katalog (server renewal + domain + tier retainer maintenance Basic/Standar/Pro). Tawarkan dua opsi server: bundled di DCI (satu invoice) atau akun sendiri klien (DCI hanya tagih retainer). Posisi di dokumen: section "Pemeliharaan & Tahun Berikutnya" — bukan bagian total tahun ke-1. Ini juga pintu upsell retainer, backbone recurring DCI.

---

## Integrasi

| Dari/Ke | Perilaku |
|---------|----------|
| `prd-builder` | Sumber utama input (PRD Section 3/5/7/8). Setelah PRD Phase 1 selesai, prd-builder boleh menawarkan chain ke skill ini; sebaliknya RAB tanpa rancangan → redirect ke prd-builder |
| `Graphify` (aturan global) | Untuk project/codebase existing: `graphify-out/` = sumber kebenaran pertama struktur & dependency; belum ada → build `--code-only` dulu |
| Agent `project-analyzer` | Escape hatch codebase besar/multi-repo yang tidak memadai via Graphify — delegate hanya setelah konfirmasi user, output di-review |
| `project memory` | Simpan ringkasan RAB (total, skema pembayaran, durasi, kurs, tanggal) sebagai entri MXXX setelah user setuju |
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
- DILARANG skema langganan dengan tenor di bawah 6 bulan (skema kehilangan fungsi); default 12 bulan
- DILARANG premi di luar skala tenor (6 bln +25% · 12 bln +20% · 18-24 bln +15%) tanpa persetujuan eksplisit user
- WAJIB klausul "hosting di sisi DCI sampai lunas" (server + domain atas nama DCI, migrasi pasca-lunas) pada skema langganan — klien dapat sistem sejak bulan 1, risiko tagihan panjang terlindungi
- WAJIB dokumen berbasis langganan menyertakan section "Pemeliharaan & Tahun Berikutnya" (server renewal + domain + tier retainer dari katalog) — RAB yang berhenti di tahun ke-1 = RAB tidak lengkap
- WAJIB skema termin mengikat milestone terverifikasi (PRD) per termin — tidak ada termin tanpa deliverable
- WAJIB catat skema terpilih ke project memory
- DILARANG mengasumsikan operator tambahan — default solo 8 jam/hari; operator lain hanya bila user menyatakan
- DILARANG menghitung jasa pengembang sebagai $0 — itu komponen harga pokok nyata (tarif × jam); skema diskon/ROI khusus = keputusan user eksplisit, dicatat sebagai margin yang disengaja
- DILARANG menawarkan harga jual di bawah harga pokok (A+E+F+G) tanpa peringatan eksplisit ke user
- WAJIB tanyakan "klien sudah punya domain?" sebelum finalisasi C2
- WAJIB hitung ulang aritmetika subtotal/total sebelum simpan file
- WAJIB tulis kurs + tanggal kurs bila menampilkan IDR
- WAJIB pakai nama aplikasi & nama klien konsisten di seluruh dokumen (1 konsep = 1 nama)
- Satu pertanyaan per giliran; pertanyaan pilihan pakai `AskUserQuestion`
