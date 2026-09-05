---
name: html-report
description: "Membuat dokumen/laporan HTML satu file, self-contained, siap dibaca di browser dan dicetak ke PDF. Panggil saat user meminta laporan, dokumen rancangan, atau ringkasan dalam format HTML yang menarik untuk dibagikan."
---

# html-report

Membangun dokumen HTML satu file yang terasa dirancang oleh desainer profesional, bukan hasil template AI. Untuk laporan, dokumen rancangan proyek, ringkasan riset, atau proposal yang akan dibaca orang lain (klien, atasan, mitra) langsung di browser atau dicetak ke PDF.

Adaptasi lokal dari referensi: youssang-millais/html-report-skill (arsitektur konten vs shell) dan gist laurokirsch (pola skeleton-first), diintegrasikan dengan skill antislop.

## Prinsip Utama

1. Satu file HTML self-contained: seluruh CSS inline di `<style>`, tanpa CDN wajib, tanpa file pendukung. Font boleh dari Google Fonts dengan fallback stack lokal.
2. Konten dulu, lalu kulit: susun outline konten sebelum menulis satu baris CSS.
3. Anti-slop aktif: bila skill antislop tersedia, patuhi aturannya (terutama R-02 tanpa em dash, R-25 kontras AA, R-38 konten jujur).

## Alur Kerja

1. **Brief singkat**: pahami pembaca (siapa, non-teknis atau teknis), tujuan dokumen, dan identitas visual. Bila proyek punya design system (misal token warna dan font), WAJIB memakainya agar dokumen satu bahasa visual dengan produknya.
2. **Outline**: tulis daftar section berurutan (pembuka, isi, penutup) dan pastikan strukturnya logis sebelum coding.
3. **Skeleton-first**: tulis kerangka HTML dengan seluruh section kosong plus komentar penanda `<!-- ISI: nama section -->`, lalu isi SATU section per edit. JANGAN menulis seluruh dokumen dalam satu Write raksasa (risiko output terpotong dan layout patah diam-diam).
4. **Polish**: tipografi, spacing, callout, tabel, lalu header/footer dokumen.
5. **Verifikasi**: buka file di browser (atau screenshot), periksa overflow, cek print preview, baru laporkan selesai.

## Kontrak Wajib

- Elemen `<title>` bermakna, `<html lang="id">`, meta charset UTF-8.
- Header dokumen: judul, subjudul, tanggal, penulis/perusahaan, penerima (bila ada), versi dokumen.
- Daftar isi dengan anchor link ke tiap section (`href="#section-id"`), semua anchor harus benar-benar ada (R-24 antislop: tanpa tautan hantu).
- Footer: identitas pembuat, tahun, status dokumen (DRAFT/FINAL).
- Print stylesheet `@media print`: sembunyikan navigasi, pastikan warna tetap terbaca (`print-color-adjust`), hindari pemenggalan judul dari isinya (`break-inside: avoid` pada kartu/tabel).
- Responsif (R-03): aman di layar 360px sampai desktop; tabel lebar diberi scroll horizontal terkontrol atau penyusunan ulang kolom.

## Sistem Visual

- Layout default: satu kolom, lebar maksimum sekitar 900px, margin otomatis. Daftar isi samping (sidebar statis) hanya bila section mencapai 12 atau lebih.
- Tipografi: pasangkan font display berkarakter untuk judul dengan font teks nyaman untuk isi. Ukuran isi minimal 16px, line-height 1.6-1.7. Skala heading konsisten (h1, h2, h3 dengan hierarki jelas).
- Warna: 2-3 warna inti + 1 aksen dari design system proyek. Netral (putih, hitam, abu) di luar hitungan. Kontras teks minimal AA 4.5:1.
- Elemen pendukung sesuai kebutuhan konten: callout (catatan, peringatan, info) dengan warna semantik, tabel bergaris tipis dengan header tegas, blok kode dengan latar halus, diagram SVG inline sederhana (bila data mendukung), footnote atau daftar sumber.
- Dilarang: gradien biru-ungu default, kartu seragam berjejer tanpa alasan hierarki, badge kapsul kosong makna, statistik rekaan (R-17/R-38), em dash di seluruh teks (pakai koma, titik dua, atau tanda kurung).

## Copywriting

- Bahasa Indonesia natural, bukan terjemahan kaku. Sesuaikan register dengan pembaca (formal untuk klien, lugas untuk internal).
- Setiap angka dan klaim wajib bisa dilacak ke sumber nyata; bila tidak ada data, jangan tampilkan angka.
- Kalimat pembuka tiap section menjawab "apa yang pembaca dapatkan dari section ini".

## Verifikasi Akhir (sebelum klaim selesai)

- [ ] Semua anchor daftar isi menunjuk section yang ada.
- [ ] Tidak ada overflow horizontal di 360px.
- [ ] Print preview rapi (section tidak terpenggal aneh).
- [ ] Kontras teks lolos AA.
- [ ] Tidak ada em dash, tidak ada lorem ipsum, tidak ada TODO.
- [ ] File dibuka di browser tanpa error konsol.
