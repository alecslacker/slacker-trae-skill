# Taksonomi Kerentanan WordPress

Plugin dan tema adalah permukaan serang utama. Data industri 2026 menempatkan plugin pada sekitar 97% kerentanan baru, tema 2,8%, core 0,2% [yakin sedang — agregasi vendor, bukan data resmi WordPress]. Karena itu kode pihak ketiga diperlakukan sebagai batas kepercayaan utama.

Urutan pertahanan selalu: validasi (tolak), sanitasi (bersihkan), escape (amankan output), otorisasi (kapabilitas), dan nonce (niat). Melewatkan satu lapis cukup untuk menghasilkan temuan.

## 1. XSS (OWASP A03)

Sumber: atribut shortcode, widget, setting, meta, parameter URL, respons API pihak ketiga, string terjemahan.

```php
// Salah.
echo '<div class="' . $atts['class'] . '">' . $atts['teks'] . '</div>';

// Benar.
echo '<div class="' . esc_attr( $atts['class'] ) . '">' . esc_html( $atts['teks'] ) . '</div>';
```

Aturan:

- `shortcode_atts()` hanya memberi default, bukan keamanan.
- HTML kaya pakai `wp_kses_post()` atau `wp_kses()` dengan allowlist tag/atribut.
- `href`/`src` selalu `esc_url()`. `javascript:` dan `data:text/html` lolos `esc_attr()`, tidak lolos `esc_url()`.
- Atribut `data-*` berisi JSON memakai `esc_attr( wp_json_encode( $data ) )`.
- Nonce yang dicetak di atribut juga di-escape dengan `esc_attr()`.
- Tema: escape di `header.php`, `footer.php`, `searchform.php`, komentar, dan setiap template tag.

## 2. SQL Injection (OWASP A03)

```php
// Salah: interpolasi.
$wpdb->get_results( "SELECT * FROM {$wpdb->prefix}dci_log WHERE user = '$user'" );

// Benar: placeholder tanpa kutip.
$wpdb->get_results(
	$wpdb->prepare( 'SELECT * FROM %i WHERE user = %s', $wpdb->prefix . 'dci_log', $user )
);
```

- `%i` (identifier) tersedia sejak WordPress 6.2; sebelumnya saring nama tabel dengan allowlist.
- `LIKE` butuh `'%' . $wpdb->esc_like( $term ) . '%'` sebagai satu argumen dan `%%` untuk persen literal.
- `ORDER BY` dan `LIMIT` tidak bisa di-placeholder sebagai identifier; pakai allowlist kolom dan `absint()` untuk limit.
- `prepare()` mengembalikan `null`/string kosong bila placeholder dan argumen tidak cocok — cek hasilnya.
- `$wpdb->insert/update/delete` otomatis meng-escape nilai, tetapi tetap batasi kolom yang boleh ditulis.

## 3. CSRF (OWASP A01/A04)

- Form admin: `wp_nonce_field( 'dci_aksi_' . $id )` lalu `check_admin_referer( 'dci_aksi_' . $id )`.
- AJAX: `check_ajax_referer( 'dci_aksi' )` sebelum logika apa pun.
- REST cookie: nonce `wp_rest` dikirim via `X-WP-Nonce`; tanpa itu user dianggap anonim.
- Nonce spesifik per objek (`aksi_123`) lebih kuat daripada nonce generik.
- Nonce bukan otorisasi: selalu pasangkan dengan `current_user_can()`.
- Aksi GET yang mengubah data (trash, delete, toggle) tetap butuh nonce.

## 4. Broken Access Control dan IDOR (OWASP A01)

```php
// Salah: hanya cek login.
if ( is_user_logged_in() ) {
	wp_delete_post( absint( $_POST['post_id'] ) );
}

// Benar: kapabilitas meta + nonce.
check_admin_referer( 'dci_hapus' );
$post_id = absint( $_POST['post_id'] ?? 0 );
if ( ! $post_id || ! current_user_can( 'delete_post', $post_id ) ) {
	wp_die( esc_html__( 'Tidak berhak.', 'dci-plugin' ) );
}
```

- `manage_options` hanya untuk setting global; operasi per objek pakai kapabilitas meta (`edit_post`, `delete_post`).
- `is_admin()` menandakan area admin, bukan hak akses.
- REST: `permission_callback` mengembalikan `true`, `WP_Error`, atau hasil `current_user_can()`. Jangan mengandalkan `callback` untuk otorisasi.
- AJAX `admin-ajax.php` bisa dipanggil pengguna tanpa hak; cek kapabilitas di dalam handler.
- Menu admin bisa disembunyikan, tetapi handler tetap harus memeriksa hak.

## 5. Eskalasi Hak Istimewa

- Jangan menulis `role`/`capabilities` dari input user tanpa allowlist.
- `update_option()` dengan array massal bisa menimpa opsi sensitif (`users_can_register`, `default_role`, `siteurl`); batasi key.
- Cek `manage_options` sebelum menyimpan setting; gunakan Settings API dengan `sanitize_callback` per opsi.
- Hati-hati `add_cap()` pada role berbagi: perubahan menetap setelah plugin dihapus.
- Multisite: `manage_network_options` berbeda dari `manage_options`; jangan campur.

## 6. Unggahan File

- Verifikasi tipe nyata: `wp_check_filetype_and_ext( $file, $name, $mimes )`, bukan `$_FILES['type']`.
- Tolak ekstensi ganda (`shell.php.jpg`) dengan memaksa ekstensi hasil verifikasi.
- Nama file: `sanitize_file_name()` + `wp_unique_filename()`.
- Simpan di `wp_upload_dir()`, jangan di folder plugin (ditimpa saat update).
- SVG: sanitasi (mis. enqueue `wp_enqueue_script('wp-dom-ready')`? tidak; gunakan sanitizer library) dan batasi agar tidak menyimpan skrip.
- `.htaccess` di folder upload untuk mematikan eksekusi PHP bila server mendukung.
- Batasi ukuran; `wp_handle_upload` dengan `test_size` dan `test_type` aktif.

## 7. Path Traversal dan Include Dinamis

```php
$file = sanitize_file_name( wp_unslash( $_GET['file'] ?? '' ) );
$path = realpath( DCI_PATH . 'views/' . $file );
if ( ! $path || str_starts_with( $path, realpath( DCI_PATH . 'views' ) ) === false ) {
	return;
}
require $path;
```

- `validate_file()` menolak `..`, drive letter, dan skema URL.
- Selalu bandingkan hasil `realpath()` dengan direktori basis.
- Jangan `include` URL kecuali `allow_url_include` aktif dan host tepercaya.

## 8. SSRF

```php
// Ke host dari input user.
$res = wp_safe_remote_get( esc_url_raw( $url ), array( 'timeout' => 8 ) );
```

- `wp_safe_remote_*` memvalidasi skema, memblokir host privat, dan mengikuti redirect dengan pemeriksaan.
- `wp_remote_*` hanya untuk host internal tepercaya (bisa diarahkan ke `169.254.169.254`).
- Batasi ukuran respons dan waktu; jangan echo body mentah tanpa escape.
- Periksa `is_wp_error()` dan kode status.

## 9. Open Redirect dan Header Injection

- `wp_safe_redirect( $url )` (allowlist host internal) atau `wp_redirect( esc_url_raw( $url ) )` bila host eksternal disengaja, lalu `exit`.
- Header kustom: bersihkan CR/LF dengan `sanitize_text_field()`.
- `wp_mail()` dengan alamat dari input: validasi `sanitize_email()` dan `is_email()`.

## 10. Object Injection dan Deserialisasi

- `maybe_unserialize()` untuk data internal; untuk input user pakai `unserialize( $raw, array( 'allowed_classes' => array( 'DCI_Data' ) ) )`.
- Jangan menyimpan objek PHP di opsi yang dapat diubah user tanpa batas kelas.
- Transient/cache: anggap isinya bisa berasal dari pihak ketiga; validasi bentuk sebelum dipakai.

## 11. Kebocoran Informasi

- `WP_DEBUG` mati di produksi; `WP_DEBUG_DISPLAY` mati; log ke file di luar webroot.
- Jangan tampilkan stack trace/`$wpdb->last_error` ke pengunjung.
- `readme.txt` jangan memuat changelog yang membocorkan detail kerentanan sebelum patch tersedia.
- Batasi `?rest_route=/wp/v2/users` bila enumerasi jadi masalah; aktifkan 2FA dan rate limit login.

## 12. Internationalization

- String terjemahan = input tidak tepercaya: `esc_html_e()`, `esc_attr__()`, bukan `_e()` mentah.
- URL dalam string pakai placeholder `%s`.
- `.mo` dikompilasi sendiri dari `.po` (`msgfmt -cv -o out.mo in.po`).
- Text domain harus sama dengan slug; jangan memakai domain core.

## 13. Data Pribadi

- Daftarkan hook `wp_privacy_personal_data_exporters` dan `wp_privacy_personal_data_erasers` untuk data pengguna yang disimpan plugin.
- Sebut tujuan, retensi, dan pihak ketiga di saran teks kebijakan privasi.
- Jangan mengirim data pribadi ke layanan eksternal tanpa persetujuan dan tanpa opsi opt-out.

## 14. Rantai Pasok

- Kunci versi dependensi composer/npm; commit lockfile.
- Tinjau `uninstall.php` dan `vendor/` sebelum rilis.
- Pastikan tidak ada kode eval/base64 obfuscation tanpa sumber.
- Untuk rilis ke WordPress.org, jalankan Plugin Check dan sediakan changelog + naikkan versi SemVer.

## Format Laporan Temuan

Setiap temuan memuat: judul, lokasi `file:baris`, kelas kerentanan, bukti alur data (source → sink), dampak, tingkat keparahan (Kritis/Tinggi/Sedang/Rendah), perbaikan konkret, dan cara verifikasi. Jangan menulis "aman" tanpa bukti uji.

| Tingkat | Kriteria |
|---|---|
| Kritis | Eksekusi kode, ambil alih admin, SQLi tanpa autentikasi, bypass otorisasi data sensitif |
| Tinggi | XSS tersimpan, IDOR data privat, upload berbahaya, SSRF ke metadata |
| Sedang | CSRF pada aksi penting, kebocoran informasi terbatas, deserialisasi terbatas |
| Rendah | Header injection, open redirect, enumerasi tanpa dampak langsung |
