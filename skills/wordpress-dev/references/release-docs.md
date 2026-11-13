# Templat Dokumentasi Rilis

Setiap plugin/theme/addon memuat `readme.txt` (format WordPress.org) dan `CHANGELOG.md` (Keep a Changelog + SemVer). Rilis tanpa entri changelog di kedua berkas dianggap belum selesai.

## 1.readme.txt

Salin, isi, dan simpan di root plugin.

```text
=== Nama Plugin ===
Contributors: dutacorpora
Tags: woocommerce, elementor, ecommerce
Requires at least: 7.0
Tested up to: 7.1
Requires PHP: 7.4
Stable tag: 1.0.0
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Deskripsi satu kalimat tentang plugin.

== Description ==

* Apa yang dilakukan plugin.
* Fitur utama sebagai daftar.
* Kebutuhan: WooCommerce/Elementor bila ada, versi minimum.
* Dibuat oleh Duta Corpora Indonesia — developer: Mas Wondho.

== Installation ==

1. Unggah folder plugin ke /wp-content/plugins/.
2. Aktifkan lewat menu Plugins.
3. Konfigurasi di menu pengaturan plugin.

== Frequently Asked Questions ==

= Apakah butuh WooCommerce? =
Ya, versi X ke atas.

= Apakah kompatibel dengan HPOS dan checkout blok? =
Ya. Kompatibilitas dideklarasikan di kode dan telah diuji.

== Screenshots ==

1. Tampilan utama.

== Changelog ==

= 1.0.0 =
* Rilis perdana.

Copyright © 2026 Duta Corpora Indonesia — dibuat oleh Mas Wondho.
```

Aturan:

- `Stable tag` = `Version` di header plugin, selalu.
- `Tested up to` diisi setelah uji nyata di versi WordPress tersebut.
- Atribusi sebagai teks biasa, tanpa tautan.
- Entri changelog terbaru di atas; sisakan minimal 5 versi terakhir untuk plugin di WordPress.org.
- Semua teks mengikuti konvensi escaping WordPress.org (tidak ada HTML liar).

## 2. CHANGELOG.md

Sumber kebenaran detail rilis; `readme.txt` adalah ringkasannya.

```markdown
# Changelog

Semua perubahan tercatat di sini.
Format mengikuti Keep a Changelog; versi memakai SemVer.

## [Unreleased]

### Planned
- ...

## [1.1.0] - 2026-12-01

### Added
- Widget hero untuk Elementor.
- Dukungan checkout blok WooCommerce.

### Changed
- Skema tabel versi 2 dengan indeks tambahan.

### Fixed
- Query order aman saat HPOS nonaktif.
- Escaping atribut pada kontrol custom.

### Security
- Memperketat validasi unggahan (CVE pending; kelas: MIME spoofing).

## [1.0.0] - 2026-11-13

### Added
- Rilis perdana.

---

Copyright © 2026 Duta Corpora Indonesia — All rights reserved.
Dibuat oleh Mas Wondho — Duta Corpora Indonesia.
```

Kategori tetap: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## 3. Disiplin Rilis

1. Sebelum rilis: pastikan `Unreleased` berisi semua perubahan; jika kosong, tidak ada yang perlu dirilis.
2. Naikkan versi: patch (fix), minor (fitur/backward-compatible), mayor (breaking).
3. Ganti `## [Unreleased]` menjadi `## [X.Y.Z] - YYYY-MM-DD`.
4. Sinkronkan: `Version` header plugin, `Stable tag` readme, dan entri changelog.
5. Tambahkan ringkasan versi baru di `readme.txt`.
6. Commit kode + kedua berkas dalam satu commit; pesan commit menyebut versi.
7. Tag git `X.Y.Z` setelah commit.

## 4. Entri Keamanan

- Sebut kelas kerentanan (XSS, SQLi, CSRF, IDOR, dll.), lokasi umum, dan versi yang memperbaiki.
- Jangan tulis langkah eksploitasi, payload, atau bukti konsep.
- Kredit pelapor hanya atas persetujuannya, tanpa kontak.
- Fix keamanan = patch version, bahkan bila perubahannya kecil.

## 5. Uji Dokumentasi

- Jalankan Plugin Check: `wp plugin check <slug>` — mismatch `Tested up to` antara header dan readme akan terdeteksi.
- Cocokkan `Version` di header vs `Stable tag` sebelum build zip.
- Baca ulang entri changelog terakhir: bahasa Indonesia, tanpa typo, tanpa istilah internal tim.
- Sinkron dengan GitHub: tag rilis = `Stable tag`; catatan GitHub Release disalin dari entri changelog. Templat repo: [github-ready.md](github-ready.md).
