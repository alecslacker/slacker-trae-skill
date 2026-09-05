---
name: html-deck
description: "Membuat presentasi HTML slide 1280x720, keyboard-driven, siap cetak PDF, dalam satu file self-contained. Panggil saat user meminta deck, slide, atau presentasi dalam format HTML."
---

# html-deck

Membangun slide presentasi eksekutif dalam satu file HTML tanpa framework dan tanpa build step. Buka di browser, itu seluruh runtime-nya: navigasi keyboard, layar penuh, dan cetak ke PDF.

Adaptasi lokal dari referensi: cla1redonald/claude-html-deck (kontrak deck, tipe slide, house rules), diintegrasikan dengan skill antislop dan kebutuhan konteks Indonesia.

## Kontrak Teknik (wajib, tanpa kecuali)

- Satu file HTML self-contained: CSS inline di `<style>`, JS navigasi inline di `<script>`. Font boleh Google Fonts dengan fallback lokal. Tanpa CDN wajib.
- Kanvas slide tetap 1280x720 (16:9). Skala ke layar pengguna via CSS transform scale, konten tidak boleh bergantung pada ukuran viewport.
- Satu slide = satu elemen `<section class="slide">`. Urutan DOM = urutan tampil.
- Navigasi keyboard: panah kanan/kiri untuk maju/mundur, Home/End untuk lompat awal/akhir, F untuk layar penuh. Nomor slide tampil di pojok (misal "3 / 14").
- Setiap slide punya `id="slide-N"` sehingga bisa di-share via URL hash (`#slide-3`).
- Print stylesheet `@media print`: satu slide per halaman landscape (`@page { size: landscape }`), warna dipertahankan (`print-color-adjust`).
- Responsif (R-03): skala mengecil rapi di layar sempit; teks slide minimal tetap terbaca.

## Alur Kerja

1. **Brief**: pembaca, durasi (jumlah slide kira-kira menit kali 0.7 untuk presentasi dengan diskusi, kali 1 untuk pitch), palet brand (hex atau design system proyek), bahasa slide.
2. **Outline dulu**: tulis daftar judul slide berurutan sebelum menulis HTML. Satu ide per slide.
3. **Skeleton-first**: kerangka dengan seluruh `<section>` kosong + komentar penanda, lalu isi SATU slide per edit. Jangan satu Write raksasa.
4. **Smoke test**: buka di browser, screenshot SEMUA slide, periksa overflow dan teks terpotong sebelum klaim selesai (R-35 antislop: yang tidak pernah dijalankan bukanlah selesai).

## Tipe Slide (pilih sesuai kebutuhan, jangan campur acak)

- `cover`: judul besar, subjudul, tanggal/pembicara. Slide pembuka wajib.
- `divider`: penanda bab baru, judul section, nomor bab.
- `content`: judul + isi (poin bernomor, dua kolom, atau grid kartu bila memang hierarkinya mendukung).
- `statement`: satu kalimat besar menyaingi pikiran pembaca. Dipakai untuk pembuka dan penutup yang berkesan.
- `kpi`: angka kunci besar (HANYA angka bersumber nyata, R-17 antislop).
- `timeline`: tahapan berurutan (misal roadmap, alur pasien).
- `comparison`: dua kolom "sebelum vs sesudah" atau "opsi A vs B".
- `closing`: satu pesan penutup + langkah berikutnya/kontak.

## House Rules

- Tanpa em dash di seluruh copy slide (R-02 antislop). Pakai koma, titik dua, atau tanda kurung.
- Ikon Lucide inline SVG, bukan emoji. Ikon harus relevan isinya dan alasannya jelas (R-04).
- Visual-first: default ke diagram, chart SVG inline, atau layout berikon. Teks prosa adalah fallback, bukan default. Target isi di bawah 40 kata per slide.
- Klaim kuantitatif yang BISA jadi chart SEBAIKNYA jadi chart (bar, tren sederhana dengan label titik akhir, funnel).
- Angka wajib bersumber; angka dari vendor ditandai sebagai laporan vendor.
- Re-skin via CSS custom properties (`--bg`, `--surface`, `--ink`, `--accent`), jangan mengubah struktur. Palet 2-3 warna inti + 1 aksen (R-29).
- Tipografi: judul dan isi dari design system proyek; hierarki ukuran jelas terlihat dari jarak 2 meter.
- Slide gelap `statement` untuk pembuka dan penutup bila brand mendukung (kontras tetap AA, R-25).

## Verifikasi Akhir (sebelum klaim selesai)

- [ ] Navigasi keyboard berfungsi: panah, Home/End, F.
- [ ] Screenshot tiap slide: tidak ada overflow, tidak ada teks terpotong.
- [ ] Print preview: satu slide per halaman landscape, warna utuh.
- [ ] Semua angka punya sumber; tidak ada statistik rekaan.
- [ ] Tidak ada em dash, tidak ada emoji sebagai ikon, tidak ada lorem ipsum.
- [ ] Tidak ada error konsol saat dibuka.
