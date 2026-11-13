# Verifikasi dan Matriks Uji

Klaim "selesai" hanya sah bila perintah di bawah dijalankan pada salinan uji, bukan produksi, dan outputnya dibaca.

## 1. Debug Lokal

Aktifkan hanya di lingkungan uji:

```php
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'SCRIPT_DEBUG', true );
```

Sasaran: `wp-content/debug.log` bersih dari notice, warning, deprecated, dan `_doing_it_wrong()`. Matikan kembali sebelum produksi.

## 2. Standar Kode

```bash
composer require --dev wp-coding-standards/wpcs phpcompatibility/phpcompatibility-wp dealerdirect/phpcodesniffer-composer-installer
vendor/bin/phpcs -p -s . --standard=WordPress-Extra --extensions=php
vendor/bin/phpcs -p . --standard=PHPCompatibilityWP --runtime-set testVersion 7.4-
```

- `WordPress-Extra` mencakup aturan keamanan inti WPCS (escaping, sanitasi, nonce, prefix).
- Test version mengikuti minimum yang dideklarasikan plugin, bukan versi lokal.
- Temuan `WordPress.Security.*` = blocker; sisanya dinilai per kasus.

## 3. Plugin Check

```bash
wp plugin install plugin-check --activate
wp plugin check dci-nama-plugin
wp plugin check /path/ke/plugin
```

Wajib bersih pada kategori "Plugin repo". Kategori lain (aksesibilitas, performa) ditindaklanjuti bila relevan. Untuk pemeriksaan runtime, muat `cli.php` milik Plugin Check via `--require`.

## 4. Integritas dan Pindai

```bash
wp core verify-checksums
wp plugin verify-checksums dci-nama-plugin
wpscan --url https://situs-uji.local --enumerate vp,vt,u --api-token "$WPSCAN_API_TOKEN"
wp cli info
wp cron event list
wp user list --fields=ID,user_login,roles
```

Tinjau juga: plugin/tema tak terpakai, user tanpa 2FA, opsi `autoload` membengkak, dan tugas cron tak dikenal.

## 5. Uji Otomatis

```bash
npx @wordpress/env start
wp scaffold plugin-tests dci-nama-plugin
vendor/bin/phpunit
```

Prioritas kasus otomatis: otorisasi endpoint, sanitasi parameter, perhitungan uang/tanggal, migrasi skema, dan uninstall. `wp-env` membutuhkan Docker. Jangan menjalankan `dbDelta` pada database produksi saat pengujian.

## 6. Matriks Uji Manual

| Kasus | Harapan |
|---|---|
| Tamu membuka endpoint tulis | 401/403, pesan aman |
| Subscriber menembak AJAX admin | Ditolak karena kapabilitas |
| Editor mengubah objek milik orang lain | Lolos hanya bila kapabilitas mengizinkan |
| Nonce kedaluwarsa / dihapus | Ditolak, bukan diproses |
| POST lintas situs tanpa nonce | Ditolak |
| ID objek negatif, nol, string, sangat besar | `absint()` menahan, tidak ada error |
| Unggah `.php.jpg` dan `.svg` berisi skrip | Ditolak atau disanitasi |
| URL eksternal `http://169.254.169.254` | Dicek lewat jalur aman |
| Teks berisi `<script>`, kutip, emoji, RTL | Tampil utuh tanpa eksekusi |
| Payload besar / array bersarang | Tidak fatal, batas jelas |
| Uninstall plugin | Tabel, opsi, transient, dan cron terhapus |

Ulangi matriks pada tema aktif utama dan satu tema blok bawaan. Uji dengan `WP_DEBUG` aktif.

## 7. Uji Khusus WooCommerce

```bash
wp wc hpos verify_data
wp wc order list --user=admin --fields=id,status,total
wp action-scheduler list
```

| Kasus | Harapan |
|---|---|
| HPOS aktif, baca/tulis order | Data konsisten, tidak memakai postmeta |
| HPOS nonaktif (kompatibilitas mode) | Tetap berfungsi |
| Retry `process_payment` order sama | Tidak ada tagihan ganda |
| Webhook signature salah | Ditolak, tidak mengubah status |
| Customer membuka order milik orang lain | Ditolak atau disaring |
| Checkout klasik dan checkout blok | Keduanya berhasil |
| Naik versi WooCommerce di staging | Template dan hook tidak pecah |

Uji dengan gateway sandbox. Jangan pernah memakai kredensial produksi.

## 8. Uji Khusus Elementor

| Kasus | Harapan |
|---|---|
| Elementor nonaktif | Notice jelas, tanpa fatal |
| Elementor di bawah versi minimum | Init berhenti, notice muncul |
| Widget di frontend | Markup dan escaping benar |
| Widget di preview editor | `content_template()` tampil |
| Kontrol berisi `<script>`, kutip, URL eksternal | Aman |
| Halaman tanpa widget | Aset tidak dimuat |
| Widget dinamis + cache | Nilai tidak basi |
| Deprecated Code Detector | Tidak ada temuan baru |

Uji juga dengan Elementor Pro bila addon menyentuh fitur Pro.

## 9. Uji Visual

- Screenshot 320, 768, 1280, 1440 px; periksa reflow, bukan hanya ketiadaan scroll horizontal.
- Cek mode gelap dan `prefers-reduced-motion`.
- Cek state hover, focus-visible, active, disabled, loading, empty, error.
- Navigasi keyboard penuh tanpa mouse; outline fokus terlihat di semua kontrol.
- Ukur kontras teks (minimal 4.5:1) dan target sentuh (44×44 px).
- Bandingkan dengan tampilan default WooCommerce/Elementor: bila hampir sama, desain belum selesai.
- Pastikan tidak ada token warna, radius, atau shadow yang ditulis berulang di luar sumber token.
- Cocokkan `Version` header plugin, `Stable tag` readme.txt, dan entri teratas CHANGELOG.md — bila tidak identik, rilis ditolak.
- Jalankan `wp plugin check <slug>`; mismatch `Tested up to` antara header dan readme.txt terdeteksi di sini.
- Baca entri changelog versi baru: bahasa Indonesia, tanpa typo, tanpa langkah eksploitasi.

## 10. Regresi Keamanan Rilis

- Bandingkan diff dengan rilis sebelumnya; setiap perubahan pola query, nonce, atau kapabilitas diperiksa ulang.
- Catat temuan di changelog tanpa detail eksploitasi berlebihan.
- Untuk rilis keamanan: perubahan seminimal mungkin, versi patch (SemVer), dan patch siap dikirim ke tim plugin WordPress.org.
