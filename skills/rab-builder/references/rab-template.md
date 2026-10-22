# Template Dokumen RAB — rab-builder

**Nama file output**: `rab-[nama-proyek].md` di `.trae/documents/`

---

```markdown
# RAB: [Nama Proyek]

> **Status**: DRAFT / FINAL
> **Tanggal**: [YYYY-MM-DD]
> **Basis**: PRD [nama] v[x] · Metode: Vibe Coding · AI: z.ai Coding Plan Max ($80/bln)
> **Kurs**: 1 USD = Rp[X.XXX] ([sumber], [tanggal])

---

## 1. Ringkasan

| | USD | IDR |
|---|-----|-----|
| **Total RAB** | **$X.XXX** | **RpXX.XXX.XXX** |

Durasi pengerjaan: [X minggu/bulan] · Kategori: [MVP kecil/sedang/besar/enterprise]
Contingency: [15%] · Periode infra produksi dihitung: [3 bulan pertama]

## 2. Stack yang Dianggarkan (hasil Fase 1)

| Lapisan | Teknologi | Keterangan biaya |
|---------|-----------|------------------|
| Frontend | [X] | build-time |
| Backend | [X] | — |
| Database | [X] | [tier] |
| [dst dari tabel stack] | | |

## 3. Rincian Biaya

### A. AI Tooling (vibe coding)

| Item | Unit | Qty | Harga Satuan | Subtotal |
|------|------|-----|--------------|----------|
| z.ai Coding Plan Max | bulan | [durasi bln] | $80 | $X |

### B. Infrastruktur Development

| Item | Subtotal |
|------|----------|
| Staging (Laragon lokal) | $0 |

### C. Infrastruktur Produksi (3 bulan pertama)

| Item | Unit | Qty | Harga | Subtotal |
|------|------|-----|-------|----------|
| VPS [spec] | bulan | 3 | $[X] | $[X] |
| Domain [nama] | tahun | 1 | $[X] | $[X] |
| SSL Let's Encrypt | — | — | $0 | $0 |

### D. Layanan Pihak Ketiga

| Item | Periode | Subtotal |
|------|---------|----------|
| [mis. Resend Pro] | [3 bln] | $[X] |

### E. SDM/Operator

| Item | Subtotal |
|------|----------|
| Solo vibe coding | $0 |

### F. Contingency (15% dari A+E)

| | $[X] |

### TOTAL

| Kategori | USD |
|----------|-----|
| A. AI Tooling | $[X] |
| B. Infra Dev | $0 |
| C. Infra Produksi | $[X] |
| D. Pihak Ketiga | $[X] |
| E. SDM | $[X] |
| F. Contingency | $[X] |
| **TOTAL** | **$[X]** |

## 4. Asumsi (ubah ini = angka berubah)

- Durasi: [X minggu] — basis: [jumlah fitur, faktor pengali yang diterapkan]
- Periode infra produksi dihitung: [3 bulan] (setelahnya = biaya operasional bulanan)
- [Asumsi lain per item]

## 5. Catatan Operasional Pasca-RAB (bukan bagian total)

- Biaya bulanan berjalan setelah periode RAB: [VPS $X + domain prorata + layanan $X = $X/bln]
- Fee payment gateway per transaksi: [X% + RpX] — mengikuti volume penjualan
- Maintenance/iterasi lanjutan: [kesepakatan terpisah]

## 6. Jejak Harga (verifikasi)

| Item | Harga dipakai | Dicek | Sumber |
|------|---------------|-------|--------|
| z.ai Plan Max | $80/bln | [tgl] | langganan user |
| [item VERIFIKASI LIVE] | [$X] | [tgl] | [URL/sumber] |
| Kurs | Rp[X]/USD | [tgl] | [sumber] |
```

---

## Aturan Pengisian Template

1. **Aritmetika WAJIB benar** — hitung ulang tiap subtotal dan total sebelum simpan (Hard Rule).
2. Semua `[placeholder]` terganti — DILARANG ada yang tersisa di final.
3. Tabel ID kolom konsisten — format uang seragam ($X atau RpX.XXX, pilih satu gaya per kolom).
4. Section 5 memisahkan biaya RAB vs biaya operasional — jangan dicampur ke total.
5. Status DRAFT → FINAL hanya setelah user konfirmasi.
