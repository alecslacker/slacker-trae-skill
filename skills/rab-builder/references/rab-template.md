# Template Dokumen — rab-builder

Dua template dalam satu file: **A. RAB Internal** (kerja, semua detail) dan **B. Dokumen Penawaran Klien** (resmi, tanpa detail metode internal).

**Lokasi output**: `.trae/documents/` — internal: `rab-[nama-proyek].md`; klien: `penawaran-[nama-aplikasi]-[nama-klien].md`

---

## A. Template RAB Internal

> TIDAK dikirim ke klien. Berisi basis hitung lengkap termasuk metode internal.

```markdown
# RAB INTERNAL: [Nama Proyek]

> **Status**: DRAFT / FINAL · **Tanggal**: [YYYY-MM-DD]
> **Basis**: PRD [nama] v[x] · Metode internal: vibe coding, z.ai Coding Plan Max ($80/bln)
> **Klien**: [Nama Klien] · **Aplikasi**: [Nama Aplikasi]
> **Kurs**: 1 USD = Rp[X.XXX] ([sumber], [tanggal])

## 1. Ringkasan

| | USD | IDR |
|---|-----|-----|
| **Total** | **$X.XXX** | **RpXX.XXX.XXX** |

Durasi: [X minggu] · Kategori: [MVP/sedang/besar/enterprise] · Contingency [15%] · Infra produksi dihitung [3 bulan pertama]

## 2. Stack yang Dianggarkan (Fase 1)

| Lapisan | Teknologi | Keterangan biaya |
|---------|-----------|------------------|
| [dari tabel stack terkonfirmasi] | | |

## 3. Rincian Biaya

### A. AI Tooling (internal — jangan tampil ke klien)
| Item | Unit | Qty | Harga | Subtotal |
|------|------|-----|-------|----------|
| z.ai Coding Plan Max | bulan | [X] | $80 | $[X] |

### B. Infrastruktur Development
| Item | Subtotal |
|------|----------|
| Staging (Laragon lokal) | $0 |

### C. Server Produksi & Domain ([3] bulan pertama — DIPISAH)
| Komp | Item | Unit | Qty | Harga | Subtotal |
|------|------|------|-----|-------|----------|
| C1 | VPS/server produksi [spec] | bulan | 3 | $[X] | $[X] |
| C2 | Domain [nama] (hapus bila klien punya domain sendiri) | tahun | 1 | $[X] | $[X] |
| — | SSL Let's Encrypt | — | — | $0 | $0 |

### D. Layanan Pihak Ketiga
| Item | Periode | Subtotal |
|------|---------|----------|
| [mis. Resend Pro] | [3 bln] | $[X] |

### E. Jasa Pengembang (solo 8 jam/hari × 5 hari/minggu)
| Parameter | Nilai |
|-----------|-------|
| Total jam kerja | [X minggu] × 40 jam = [X] jam |
| Tarif | Rp[X]/jam (default katalog Rp150.000 — atau paket: [sebutkan bila dipakai]) |
| **Subtotal jasa** | **Rp[X]** |

### F. Contingency (15% dari A+E): $[X] / Rp[X]

### G. Overhead Operasional (prorata [X bulan])
| Item | Per bulan | Durasi | Subtotal |
|------|-----------|--------|----------|
| Listrik | Rp400.000 | [X bln] | Rp[X] |
| Internet | Rp350.000 | [X bln] | Rp[X] |

### TOTAL: A $[X] + B $0 + C1 $[X] + C2 $[X] + D $[X] + E Rp[X] + F Rp[X] + G Rp[X] = **$[X] + Rp[X]** (gabung kurs: Rp[total])

## 4. Asumsi
- Durasi [X minggu] — basis: [fitur + faktor pengali]
- [Asumsi per item]

## 5. Catatan Operasional Pasca-RAB
- Biaya bulanan berjalan: [VPS + layanan = $X/bln]
- Fee payment gateway per transaksi: [X%] — catatan, bukan biaya tetap

## 6. Jejak Harga
| Item | Harga | Dicek | Sumber |
|------|-------|-------|--------|
| z.ai Plan Max | $80/bln | [tgl] | langganan |
| [item live] | [$X] | [tgl] | [sumber] |
| Kurs | Rp[X]/USD | [tgl] | [sumber] |
```

---

## B. Template Dokumen Penawaran Klien

> Dokumen resmi. Kop dari `company-profile.md`. DILARANG sebut: vibe coding, AI, z.ai, langganan model, "operator". Komponen A+E+F dikonversi jadi "Biaya Pengembangan Sistem".

```markdown
<div align="center">

## PT DUTA CORPORA INDONESIA
### RAB PENGEMBANGAN [NAMA APLIKASI]

**Disusun untuk: [Nama Klien]**

Lingk. Dadapan RT 01 RW 01, Desa Kedungbunder, Kec. Sutojayan, Kab. Blitar, Jawa Timur 66172
Telp. 0895-2000-1337 · halo@dutacorpora.co.id · dutacorpora.co.id

</div>

---

**Nomor**: DCI/RAB/[XX]/[YYYY] · **Tanggal**: [DD Bulan YYYY] · **Berlaku hingga**: [tanggal +30 hari]

## Pendahuluan

[Paragraf 1 — siapa kami + tujuan dokumen. Pola:]
PT Duta Corpora Indonesia adalah perusahaan teknologi informasi berbadan hukum yang telah melayani lebih dari 30 klien lintas segmen dengan lebih dari 110 dokumen transaksi terdokumentasi sejak 2022. Dokumen ini menyajikan Rencana Anggaran Biaya (RAB) pengembangan **[Nama Aplikasi]** untuk **[Nama Klien]**, disusun berdasarkan hasil perancangan sistem yang telah dilakukan.

[Paragraf 2 — konteks aplikasi + kredibilitas relevan segmen klien. Pola:]
[Nama Aplikasi] adalah [1-2 kalimat dari PRD Overview — apa yang dikerjakan, untuk siapa]. Pengalaman kami mengembangkan [kredibilitas relevan: sistem informasi skala institusi / layanan untuk bank pembangunan daerah / sistem informasi desa level kabupaten / dst.] menjadi dasar keyakinan kami bahwa [Nama Aplikasi] dapat diselesaikan dengan standar kualitas yang terdokumentasi dan teruji.

## Ruang Lingkup Pekerjaan

[Ringkas dari PRD Section 3 — fitur utama dalam bahasa klien, 5-8 butir, tanpa istilah teknis internal:]
1. [Fitur 1 — manfaatnya bagi pengguna]
2. [dst.]

Estimasi waktu pengerjaan: [X minggu] sejak [kesepakatan/DP] — mencakup pengembangan, pengujian, dan serah terima.

## Rincian Anggaran Biaya

### 1. Pengembangan Sistem [Nama Aplikasi]
| Komponen | Keterangan | Biaya |
|----------|------------|-------|
| Perancangan & pengembangan sistem | [X] modul sesuai ruang lingkup, termasuk pengujian & serah terima | Rp[X.XXX.XXX] |
| Cadangan operasional | [mis. revisi sesuai masa garansi] | Rp[X.XXX.XXX] |

### 2. Infrastruktur & Penyelenggaraan (per [3] bulan pertama)
| Komponen | Periode | Biaya |
|----------|---------|-------|
| Server produksi [spec fungsional: mis. "server virtual kapasitas memadai untuk 50 pengguna aktif"] | 3 bulan | Rp[X.XXX.XXX] |
| Domain [nama domain] *(bila klien memakai domain sendiri, baris ini dihapus)* | 1 tahun | Rp[X.XXX.XXX] |
| Sertifikat keamanan SSL | — | Rp0 |

### 3. Layanan Pendukung Pihak Ketiga
| Komponen | Periode | Biaya |
|----------|---------|-------|
| [mis. Layanan email transaksional] | 3 bulan | Rp[X.XXX.XXX] |

### Total Anggaran

| No | Komponen | Jumlah |
|----|----------|--------|
| 1 | Pengembangan Sistem [Nama Aplikasi] | Rp[X.XXX.XXX] |
| 2 | Infrastruktur & Penyelenggaraan | Rp[X.XXX.XXX] |
| 3 | Layanan Pendukung | Rp[X.XXX.XXX] |
| | **TOTAL** | **Rp[X.XXX.XXX]** |

*(Terbilang: [jumlah terbilang] rupiah)*

## Ketentuan Pembayaran — Skema [pilih salah satu sesuai Fase 3.5; hapus yang tidak dipakai]

### Skema A — Pembayaran Sekaligus (One-Time)

| Tahap | Pemicu | Jumlah |
|-------|--------|--------|
| DP 50% | Penandatanganan kesepakatan | Rp[X.XXX.XXX] |
| Pelunasan 50% | Serah terima sistem | Rp[X.XXX.XXX] |
| **Total** | | **Rp[X.XXX.XXX]** |

Termasuk garansi perbaikan bug 30 hari pasca serah terima.

### Skema B — Termin Bertahap

| Termin | Milestone (terverifikasi) | Persentase | Jumlah |
|--------|---------------------------|------------|--------|
| 1 | Kick-off & perancangan disetujui | [30]% | Rp[X.XXX.XXX] |
| 2 | [Milestone PRD — mis. modul inti selesai & diuji] | [40]% | Rp[X.XXX.XXX] |
| 3 | Serah terima & pelatihan | [30]% | Rp[X.XXX.XXX] |
| | **Total (sama dengan sekali bayar, tanpa biaya tambahan)** | 100% | **Rp[X.XXX.XXX]** |

Setiap termin ditagih setelah milestone terkait diverifikasi bersama. Garansi bug 30 hari pasca serah terima.

### Skema C — Langganan Bulanan

| Komponen | Nilai |
|----------|-------|
| Uang muka | Rp[X.XXX.XXX] (1× bulanan) — saat penandatanganan |
| Biaya bulanan | Rp[X.XXX.XXX]/bulan, selama [12] bulan |
| Total selama tenor | Rp[X.XXX.XXX] *(selisih Rp[X] vs sekali bayar = biaya fleksibilitas skema)* |

**Termasuk dalam langganan selama tenor**: pengembangan sistem sesuai ruang lingkup, hosting & infrastruktur, serta **pemeliharaan aktif** (pemantauan, pembaruan, perbaikan, dukungan teknis) — sistem terawat penuh tanpa biaya tambahan.

**Ketentuan langganan**:
- Keterlambatan [2] bulan berturut-turut = layanan penanganan data dihentikan sementara hingga tertagih (data tetap aman, tidak dihapus)
- Pelunasan dini: sisa pokok dibayar sekaligus, premi sisa tenor dihapus
- Setelah lunas (tenor habis ATAU pelunasan dini): **sistem menjadi milik penuh [Nama Klien]**; biaya pemeliharaan lanjutan opsional sesuai kesepakatan

### Ketentuan Umum (semua skema)

- Pembayaran via transfer rekening korporasi: **Bank Jatim 1892017774 a.n. PT DUTA CORPORA INDONESIA**
- Invoice resmi & faktur pajak diterbitkan untuk setiap pembayaran/tagihan

## Catatan
- Biaya bulanan berjalan setelah periode ini: Rp[X]/bulan (server + layanan pendukung) — rincian menyusul saat serah terima
- [Bila ada payment gateway: fee transaksi [X%] mengikuti penyedia jasa, tidak termasuk dalam total di atas]
- Garansi perbaikan bug: [30 hari] pasca serah terima

<div align="center">

**PT DUTA CORPORA INDONESIA**

Riswandha Irawan
Founder

</div>
```

---

## Aturan Pengisian Kedua Template

1. **Aritmetika WAJIB benar** — hitung ulang tiap subtotal & total sebelum simpan. Termasuk skema: jumlah termin/seluruh bulanan harus = total anggaran (+premi bila langganan).
2. Semua `[placeholder]` terganti di final — DILARANG tersisa. Skema yang tidak dipakai DIHAPUS dari dokumen final (jangan tiga-tiganya tampil sekaligus kecuali user minta opsi untuk klien).
3. Template klien: jumlah dalam IDR + terbilang; kurs internal tidak perlu tampil ke klien (sudah terkonversi).
4. Nama aplikasi & klien konsisten di seluruh dokumen — persis seperti Fase 0.
5. Nomor dokumen klien format `DCI/RAB/[urut 2 digit]/[tahun]` — tanya user nomor urut bila tidak tahu.
6. Status DRAFT → FINAL hanya setelah konfirmasi user.
7. Skema langganan: total tenor + selisih vs one-time WAJIB tampil (transparansi biaya fleksibilitas); klausul pelunasan dini & kepemilikan tidak boleh dihilangkan.
