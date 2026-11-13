---
name: wordpress-dev
description: Pengembangan plugin WordPress, WooCommerce, dan addon Elementor yang aman — HPOS, payment gateway, widget, hardening, audit kerentanan. Panggil saat menulis atau meninjau kode WordPress, WooCommerce, atau Elementor. Jangan dipakai untuk framework lain.
user-invocable: true
---

# WordPress Development & Security

**Pengumuman saat dipakai:** "Saya memakai skill wordpress-dev: konvensi WordPress resmi, gate keamanan validate-sanitize-escape, dan standar tampilan anti-datar."

Skill ini berdiri di dua kaki: membangun yang benar, dan membuktikan bahwa yang dibangun tidak bisa dieksploitasi.

## Prasyarat Mutlak

1. Deteksi target sebelum menulis kode: baca `wp-includes/version.php` (`$wp_version`), header `Requires at least` / `Requires PHP` di file plugin, dan `composer.json` bila ada.
2. Fakta versi (per 13 November 2026) — jangan asumsikan dari ingatan:
   - Stabil terakhir: WordPress 7.1.4 (28 Oktober 2026, rilis keamanan). 7.2 masih beta. [yakin tinggi, sumber resmi]
   - WordPress 7.0 menghentikan dukungan PHP 7.2/7.3; minimum didukung 7.4, minimum direkomendasikan 8.3. [yakin tinggi, Make WordPress Core]
   - WordPress 7.x menyebut MySQL 8.0+ pada kebutuhan host; verifikasi ulang di server target. [yakin sedang, blog vendor]
   - WooCommerce terakhir 11.3.0; minimum WordPress 7.0, PHP 7.4 (8.0+ direkomendasikan), MySQL 5.5.5+ / MariaDB 10.1+. [yakin tinggi, halaman plugin resmi]
   - Elementor addon wajib memuat header `Requires Plugins: elementor` dan `Elementor tested up to`; cek `did_action( 'elementor/loaded' )` serta `ELEMENTOR_VERSION` sebelum init. [yakin tinggi, dokumentasi developer Elementor]
3. Jangan memakai API yang lebih baru dari versi target. Cek dokumentasi resmi (`developer.wordpress.org/reference`, `developer.woocommerce.com`, `developers.elementor.com`) dan penanda "Available since".
4. WooCommerce dan Elementor bukan library biasa: perlakukan sebagai platform dengan siklus rilis sendiri. Baca changelog dan deprecation sebelum menyentuh API-nya.
5. Dilarang mengedit core WordPress, core WooCommerce, atau core Elementor. Perubahan tema lewat child theme; perubahan lintas situs lewat mu-plugin.

## Aturan Rumah (wajib)

- Prefix semua simbol global: `dci_`, namespace `DCI\`, konstanta `DCI_`. Slug plugin `dci-<nama>`.
- Komentar kode Bahasa Indonesia.
- Header file utama memuat:

```php
/**
 * Author: Duta Corpora Indonesia
 * Developer: Mas Wondho — Duta Corpora Indonesia
 * Copyright © <tahun> Duta Corpora Indonesia
 */
```

- Tanpa `Author URI` / tautan apa pun di header. Kontak dan kredit ditulis sebagai teks biasa.
- Footer dokumen/artefak: `Copyright © <tahun> Duta Corpora Indonesia — All rights reserved`.
- Lisensi GPLv2+ agar kompatibel dengan core.
- Satu file boleh memuat header plugin; file lain tidak.

## Dokumentasi Rilis (wajib)

Setiap plugin/theme/addon WAJIB menyertakan dua berkas dan keduanya diperbarui setiap rilis — tidak ada rilis tanpa entri changelog.

### readme.txt

Wajib memakai format WordPress.org agar Plugin Check dan direktori membaca metadata dengan benar:

```text
=== Nama Plugin ===
Contributors: dutacorpora
Tags: woocommerce, elementor
Requires at least: 7.0
Tested up to: 7.1
Requires PHP: 7.4
Stable tag: 1.0.0
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Deskripsi singkat plugin.

== Description ==
Apa yang dilakukan plugin, fitur utama, kebutuhan (WooCommerce/Elementor bila ada), dan siapa yang dibuat olehnya.

== Installation ==
1. Unggah folder plugin ke /wp-content/plugins/ lalu aktifkan.

== Frequently Asked Questions ==
= Pertanyaan umum? =
Jawaban singkat.

== Changelog ==
= 1.0.0 =
* Rilis perdana.

Copyright © 2026 Duta Corpora Indonesia — dibuat oleh Mas Wondho.
```

- `Stable tag` harus sama dengan `Version` di header plugin.
- `Tested up to` diisi setelah benar-benar diuji — jangan menebak.
- Tanpa tautan berlebihan; atribusi sebagai teks biasa.
- Bagian `Changelog` mencantumkan setiap versi, terbaru di atas, format `= X.Y.Z =` + poin perubahan.

### CHANGELOG.md

Memakai gaya Keep a Changelog + SemVer. Ini sumber kebenaran untuk dokumen, sedangkan `readme.txt` adalah ringkasannya untuk direktori WordPress.org.

```markdown
# Changelog

Semua perubahan tercatat di sini. Format mengikuti Keep a Changelog; versi memakai SemVer.

## [1.1.0] - 2026-12-01

### Added
- Widget hero untuk Elementor.

### Fixed
- Query order kini aman saat HPOS nonaktif.

### Security
- Memperketat escaping atribut pada kontrol custom.

## [1.0.0] - 2026-11-13

### Added
- Rilis perdana.

---
Copyright © 2026 Duta Corpora Indonesia — All rights reserved. Dibuat oleh Mas Wondho.
```

Kategori tetap: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. Entri keamanan merinci kelas kerentanan tanpa membocorkan langkah eksploitasi.

### Aturan disiplin

- Rilis baru = nomor versi naik (SemVer: patch untuk fix, minor untuk fitur, mayor untuk breaking) + entri di kedua berkas pada commit yang sama.
- Versi header plugin, `Stable tag`, dan entri changelog terbaru harus konsisten — tolak rilis bila tidak cocok.
- Saat fix keamanan, catat versi patch dan sumber laporan (tanpa data pribadi pelapor).
- Untuk plugin di WordPress.org, pertahankan entri changelog di `readme.txt` minimal 5 versi terakhir.

## GitHub Ready (wajib)

Repo plugin/theme/addon harus siap dibuka publik: tidak ada secret, tidak ada artefak build, dan siapa pun bisa membangun dari sumber.

### Struktur repo

```text
dci-nama-plugin/
├─ dci-nama-plugin.php        # header + bootstrap
├─ uninstall.php
├─ readme.txt                 # format WordPress.org
├─ CHANGELOG.md
├─ README.md                  # tampilan GitHub (bisa menerjemahkan readme.txt)
├─ LICENSE                    # GPLv2+
├─ .gitignore
├─ .distignore                # daftar file yang dikecualikan saat build zip
├─ .editorconfig
├─ composer.json              # autoload + dev deps (wpcs, phpunit)
├─ composer.lock
├─ package.json               # bila pakai build JS (block/Elementor)
├─ package-lock.json
├─ phpcs.xml.dist
├─ phpunit.xml.dist
├─ .github/workflows/ci.yml   # PHPCS + PHPUnit di setiap push/PR
├─ includes/  admin/  public/  languages/
└─ assets/    (screenshot + banner untuk WordPress.org)
```

### README.md vs readme.txt

- `readme.txt` = format WordPress.org (Plugin Check membacanya).
- `README.md` = tampilan GitHub. Boleh lebih kaya: badge CI, screenshot, tabel fitur, catatan kontribusi. Isi harus konsisten dengan readme.txt.
- Keduanya mencantumkan atribusi: `Duta Corpora Indonesia — developer: Mas Wondho` tanpa tautan.

### .gitignore minimal

```gitignore
# Dependensi
node_modules/
vendor/

# Artefak build
*.zip
dist/
build/

# Environment & secret
.env
.env.*
!.env.example

# Log & cache
*.log
.phpunit.result.cache
.phpunit.cache/
.phpcs-cache
.parcel-cache/

# OS & editor
.DS_Store
Thumbs.db
.idea/
.vscode/*
!.vscode/extensions.json

# WordPress lokal
wp-config.php
wp-content/
```

Aturan tambahan:

- `composer.lock` dan `package-lock.json` di-commit — build harus bisa direproduksi.
- `vendor/` dan `node_modules/` tidak di-commit. Distribusi zip dibangun lewat CI (`composer install --no-dev --optimize-autoloader`), bukan dari commit artefak.
- Secret hanya di `.env` yang di-ignore; sediakan `.env.example` berisi placeholder.
- Jadwal `.distignore` saat menambah alat dev agar zip rilis tetap bersih.

### .distignore

Dipakai `wp dist-archive` atau script build untuk mengecualikan file non-produksi:

```text
.git
.github
node_modules
vendor
tests
*.zip
*.log
CHANGELOG.md
README.md
.gitignore
.distignore
.editorconfig
composer.json
composer.lock
package.json
package-lock.json
phpcs.xml.dist
phpunit.xml.dist
```

### CI minimal (GitHub Actions)

- Job lint: `composer install` → `vendor/bin/phpcs --standard=WordPress-Extra`.
- Job test: `composer install` → PHPUnit (wajib untuk logika inti).
- Job build (opsional, saat tag `X.Y.Z`): pasang dependensi tanpa dev, buat zip via `wp dist-archive` atau script, lampirkan ke GitHub Release.
- CI gagal = tidak ada merge dan tidak ada rilis.

### Tag dan release

- Tag git `X.Y.Z` mengikuti versi plugin dan entri changelog.
- GitHub Release menyertakan zip hasil build + catatan dari entri changelog versi tersebut.
- Jangan pernah meng-commit zip, dump database, atau backup.

Templat lengkap semua berkas (`.gitignore`, `.distignore`, `.editorconfig`, composer, CI): [references/github-ready.md](references/github-ready.md).

## Standar Tampilan (wajib)

Rujukan detail: [references/design.md](references/design.md).

Tampilan datar (flat) dilarang. Setiap antarmuka harus punya kedalaman, hierarki, dan state yang jelas — termasuk halaman toko dan widget Elementor.

- **Kedalaman berlapis.** Gunakan permukaan bertingkat (surface, raised, overlay) dengan shadow lembut, border halus, dan gradient tipis. Jangan menumpuk semua elemen di satu bidang datar.
- **Hierarki tipografi.** Skala ukuran dan bobot eksplisit; judul, isi, label, dan meta tidak boleh tampak setara.
- **Ruang bernapas.** Spacing berbasis skala (4/8/12/16/24/32/48/64), bukan angka acak.
- **State nyata.** Hover, focus-visible, active, disabled, loading, empty, dan error punya perlakuan visual berbeda. Fokus keyboard wajib terlihat.
- **Warna bertingkat.** Palet dengan tint/shade untuk kedalaman; gradient halus pada aksen, bukan pelangi. Kontras teks minimal 4.5:1, target 7:1 untuk teks utama.
- **Gerak bermakna.** Transisi 150–250 ms dengan easing konsisten; hormati `prefers-reduced-motion`.
- **Konsisten.** Token warna, radius, shadow, dan spacing didefinisikan sekali (CSS variable / `theme.json`), bukan diulang per widget.
- **Responsif sejak awal.** Aman dari 320 px; uji reflow, bukan sekadar "tidak meluber".
- **Bukan template default.** Jangan biarkan tampilan WooCommerce atau Elementor apa adanya; sesuaikan lewat hook, `theme.json`, dan style widget.
- **Aksesibilitas.** Label form nyata, `alt` bermakna, urutan fokus logis, target sentuh minimal 44×44 px.

Visual yang hanya "berfungsi" belum selesai. Uji dengan mata, bukan hanya dengan tes.

## Arsitektur Plugin

- Guard setiap file yang punya kode di luar class/function:

```php
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}
```

- Struktur resmi: file utama + `uninstall.php` di root, sisanya di `includes/`, `admin/`, `public/`, `assets/`, `languages/`.
- Pisahkan kode admin dan publik dengan `is_admin()`, tetapi tetap cek kapabilitas — `is_admin()` bukan bukti user login.
- Hook pakai named function/method, bukan closure, agar bisa `remove_action`. Prioritas eksplisit bila mengubah perilaku pihak lain.
- Utamakan class/namespace untuk menghindari tabrakan. Pada snippet gaya WooCommerce, bungkus fungsi dengan `function_exists()` sesuai coding standards WooCommerce; pada plugin berbasis class, guard `class_exists()` cukup.
- Aktivasi menyiapkan opsi/tabel; deaktivasi membersihkan data sementara; `uninstall.php` menghapus semua data permanen dan dijaga `WP_UNINSTALL_PLUGIN`.
- Asset: `wp_enqueue_script`/`wp_enqueue_style` dengan dependensi dan versi. Jangan memuat CDN di admin. Data ke JS lewat `wp_localize_script` atau `wp_add_inline_script` — WordPress meng-escape-nya.
- Block: daftarkan lewat `block.json` (`apiVersion` 3, `textdomain`, `render`/`render_callback`), build dengan `@wordpress/scripts`, terjemahan skrip lewat `wp_set_script_translations`.
- Theme: child theme untuk modifikasi, escape di template, `wp_head`/`wp_footer`/`wp_body_open` wajib ada, pengaturan tema lewat Customizer/`theme.json` dengan sanitize callback. Tema blok memakai `theme.json` dan `templates/`, bukan hardcode style.

## Database

- Utamakan post meta / term meta / user meta. Tabel sendiri hanya untuk data yang benar-benar bertambah besar.
- Buat tabel lewat `dbDelta()` di hook aktivasi, dengan `$wpdb->get_charset_collate()`. Ikuti aturan formatnya: satu field per baris, dua spasi sebelum definisi `PRIMARY KEY`, kata kunci `KEY`, tanpa backtick, tipe lowercase, panjang eksplisit.
- Simpan opsi versi skema; jalankan upgrade di `plugins_loaded` bila versi berbeda. Hook aktivasi tidak berjalan saat update plugin.
- Query dinamis wajib `$wpdb->prepare()`. Placeholder tidak boleh dikutip; identifier pakai `%i` (WordPress 6.2+); wildcard `LIKE` lewat `esc_like()` dan `%%`.
- Operasi tulis memakai `$wpdb->insert/update/delete`, bukan SQL rakitan.
- Jangan query di dalam loop; pakai `WP_Query` dengan `fields`, `no_found_rows`, dan meta query yang tepat.

## WooCommerce

Rujukan mendalam: [references/woocommerce.md](references/woocommerce.md).

### Data order dan HPOS

- Sejak WooCommerce 8.2, High-Performance Order Storage (HPOS) aktif default untuk instalasi baru. HPOS menyimpan order di tabel `*_wc_orders`, `*_wc_order_addresses`, `*_wc_order_operational_data`, `*_wc_orders_meta`.
- WooCommerce 10.7 (April 2026) mematikan sinkronisasi baca default. [yakin sedang, laporan vendor] Konsekuensinya: baca/tulis order lewat `wp_postmeta` bisa basi atau hilang.
- Semua akses order wajib lewat CRUD: `wc_get_order()`, `wc_get_orders()`, `WC_Order_Query`, `$order->get_meta()`, `$order->update_meta_data()`, lalu `$order->save()`.
- Jangan `WP_Query` bertipe `shop_order` untuk data order. Jangan `get_post_meta( $order_id, ... )`.
- Deteksi kondisi: `OrderUtil::custom_orders_table_usage_is_enabled()` dan `OrderUtil::is_order()`. Jangan akses kelas `Internal\` tanpa `class_exists()`.
- Plugin yang menyentuh order wajib mendeklarasikan kompatibilitas di file utama:

```php
add_action( 'before_woocommerce_init', function () {
	if ( class_exists( \Automattic\WooCommerce\Utilities\FeaturesUtil::class ) ) {
		\Automattic\WooCommerce\Utilities\FeaturesUtil::declare_compatibility( 'custom_order_tables', __FILE__, true );
	}
} );
```

- Bila mendukung checkout blok, deklarasikan `cart_checkout_blocks` dengan pola yang sama.

### Query dan performa

- `wc_get_orders()` mendukung `limit`, `offset`, `paginate`, `status`, `customer`, `date_created`, `meta_query` dan `field_query`. `meta_query`/`field_query`/`date_query` hanya berlaku saat HPOS aktif.
- Selalu batasi hasil dan pakai `return => 'ids'` bila hanya butuh ID.
- Pekerjaan berat (sinkron stok, impor, pengingat) masuk Action Scheduler (`as_enqueue_async_action`, `as_schedule_recurring_action`), bukan request langsung.
- Cache query mahal dengan transient/object cache dan invalidasi saat order berubah.

### Payment gateway

- Gateway adalah plugin terpisah: kelas turunan `WC_Payment_Gateway`, didaftarkan lewat filter `woocommerce_payment_gateways` pada `plugins_loaded`.
- Isi konstruktor: `id`, `method_title`, `method_description`, `has_fields`, `init_form_fields()`, `init_settings()`, lalu hook simpan `woocommerce_update_options_payment_gateways_{id}`.
- `process_payment( $order_id )` mengembalikan `array( 'result' => 'success', 'redirect' => ... )` atau `'failure'`; sukses nyata memakai `$order->payment_complete( $transaction_id )`.
- Idempoten: simpan transaction/payment intent ID sebelum menunggu hasil, cek status ke provider sebelum menagih ulang. Pakai idempotency key provider.
- Status: `pending`/`failed` bila masih bisa dibayar, `on-hold` bila provider sudah menerima tetapi belum konfirmasi. Jangan biarkan status kustom menggantung.
- Gateway langsung (card fields di checkout) butuh `has_fields = true`, `payment_fields()`, `validate_fields()`, HTTPS, dan kepatuhan PCI.
- Checkout blok memakai jalur integrasi terpisah (payment method integration), bukan sekadar `WC_Payment_Gateway`.

### Template dan hook

- Override template lewat folder `woocommerce/` di theme; jangan edit file plugin. Sinkronkan saat WooCommerce naik versi.
- `wc_get_template()` dan filter `woocommerce_locate_template` untuk pencarian kustom.
- Gunakan hook (`woocommerce_before_shop_loop`, `woocommerce_checkout_fields`, `woocommerce_order_status_changed`) alih-alih menimpa markup.
- Escaping tetap berlaku di template WooCommerce; harga, nama produk, dan alamat adalah data tak tepercaya.

### Keamanan WooCommerce

- Kapabilitas: `manage_woocommerce` untuk setting toko, `edit_shop_orders`/`edit_shop_order` + ID untuk order, `manage_product_terms` untuk kategori produk.
- Order adalah data pribadi: batasi `wc_get_order()` berdasarkan pemilik (`$order->get_customer_id()` / `get_billing_email()`).
- Webhook: verifikasi signature provider, batasi metode, dan idempotenkan pemrosesan.
- REST API WooCommerce memakai consumer key/secret; kirim hanya via HTTPS, simpan di server.
- Jangan log nomor kartu, CVC, atau token mentah. Jangan simpan data kartu bila gateway sudah menanganinya.

## Elementor

Rujukan mendalam: [references/elementor.md](references/elementor.md).

- Addon adalah plugin WordPress biasa. Header wajib `Requires Plugins: elementor`; sertakan `Elementor tested up to` dan `Elementor Pro tested up to` bila diuji.
- Gerbang kompatibilitas di awal: `did_action( 'elementor/loaded' )`, `version_compare( ELEMENTOR_VERSION, MINIMUM, '>=' )`, versi PHP. Tampilkan `admin_notices` dan hentikan init bila gagal.
- Jangan memanggil API Elementor sebelum `elementor/loaded`.
- Widget: kelas turunan `\Elementor\Widget_Base`, daftarkan lewat `elementor/widgets/register`. Wajib `get_name()` (unik, snake_case), `get_title()` (di-escape), `get_icon()`, `get_categories()`, `get_keywords()`.
- Kontrol didefinisikan di `register_controls()` memakai `Controls_Manager`; bungkus dengan section, pakai `esc_html__()` untuk label, dan `selectors` dengan `{{WRAPPER}}`/`{{VALUE}}` untuk style.
- Render: `render()` untuk frontend, `content_template()` untuk preview editor. Ambil setting dengan `get_settings_for_display()`.
- Output dinamis wajib di-escape: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()` sesuai konteks. `add_render_attribute()`/`get_render_attribute_string()` membantu atribut, bukan menggantikan escaping teks.
- Asset: daftarkan handle via `wp_register_script/style`, deklarasikan di `get_script_depends()`/`get_style_depends()`. Handle yang tidak terdaftar tidak berefek. Asset khusus panel editor lewat `elementor/editor/before_enqueue_scripts`.
- Kategori widget lewat `elementor/elements/categories_registered` + `$elements_manager->add_category()`.
- Dynamic tag lewat `elementor/dynamic_tags/register`; gunakan `is_dynamic_content()` agar caching tidak salah.
- Widget yang berat atau bergantung pada request sebaiknya mendukung Element Caching dan tidak memaksa render ulang.
- Jangan mengedit core Elementor; perluas lewat hook dan filter resmi.
- Uji dengan Elementor versi terbaru dan, bila ada, Elementor Pro (butuh developer license). Catat versi yang diuji di header dan changelog.
- Ikuti deprecation Elementor; jalankan Elementor Deprecated Code Detector sebelum rilis.

## Keamanan — Gate Wajib

Alur: **validasi → sanitasi → escape sedapat mungkin di output**. Nonce membuktikan niat, bukan identitas atau hak akses.

### Kapabilitas dan nonce

- Setiap aksi tulis: `current_user_can()` dengan kapabilitas paling sempit (`edit_post` + ID, `manage_options`, `upload_files`). Kapabilitas meta butuh `map_meta_cap()`.
- Form: `wp_nonce_field()` + `check_admin_referer()`. AJAX: `check_ajax_referer()`. Konteks lain: `wp_verify_nonce()` dan perlakukan hasil `!== false` (mengembalikan tick 1/2).
- Nonce berumur 12–24 jam dan tidak berlaku sebagai otorisasi. Tamu memakai nonce sama (user ID 0); tangani lewat filter `nonce_user_logged_out` untuk aksi kritis.

### Escaping per konteks

| Konteks | Fungsi |
|---|---|
| Teks HTML | `esc_html()`, `esc_html__()`, `esc_html_e()` |
| Atribut | `esc_attr()`, `esc_attr__()`, `esc_attr_e()` |
| URL atribut | `esc_url()`; simpan DB pakai `esc_url_raw()` |
| Inline JS | `esc_js()`; data terstruktur `wp_json_encode()` |
| Textarea | `esc_textarea()` |
| HTML terbatas | `wp_kses_post()`, `wp_kses()` dengan allowlist |
| XML | `esc_xml()` |

Escape di titik echo, bukan saat menyimpan. String terjemahan diperlakukan sebagai input tidak tepercaya.

### Sanitasi input

`sanitize_text_field()`, `sanitize_textarea_field()`, `sanitize_key()`, `sanitize_email()`, `sanitize_url()`, `absint()`, `sanitize_file_name()`, `sanitize_hex_color()`, `sanitize_mime_type()`. Validasi allowlist lebih baik daripada sanitasi: tolak nilai di luar daftar sebelum menyentuh database.

### REST dan AJAX

- `permission_callback` wajib sejak WordPress 5.5; endpoint publik memakai `__return_true`, sisanya cek kapabilitas.
- Setiap argumen punya `validate_callback` dan `sanitize_callback` di `args`.
- Autentikasi cookie butuh header `X-WP-Nonce` beraksi `wp_rest`; tanpa itu user dianggap 0. Integrasi server-ke-server memakai Application Passwords (WordPress 5.6+), bukan plugin Basic Auth di produksi.
- AJAX lama: `check_ajax_referer()` + cek kapabilitas + `wp_send_json_success()/wp_send_json_error()`. Endpoint baru condong ke REST.

### Upload dan file

- Cek kapabilitas `upload_files`; SVG/ZIP butuh `unfiltered_upload`.
- Pakai `wp_handle_upload()` dengan `mimes` dan `test_type`, atau `media_handle_upload()`.
- Verifikasi tipe nyata dengan `wp_check_filetype_and_ext()`, bukan `$_FILES['type']`.
- Nama file lewat `sanitize_file_name()` dan `wp_unique_filename()`. Simpan di uploads, bukan folder plugin.
- Path dinamis: `validate_file()` dan `realpath()` terhadap `ABSPATH`.

### HTTP, redirect, serialisasi, i18n

- Request keluar ke host tak dikenal: `wp_safe_remote_get/post()` (memvalidasi host, memblokir IP privat). `wp_remote_*` hanya untuk host internal tepercaya.
- Redirect: `wp_safe_redirect()` lalu `exit`.
- Jangan `unserialize()` input user tanpa `allowed_classes`.
- File `.mo` dari penerjemah dikompilasi sendiri (`msgfmt`), jangan pakai kiriman pihak lain.
- URL di string terjemahan pakai placeholder `%s`, bukan URL literal.

### Secret dan wp-config

- Kunci hanya di `wp-config.php`/`.env`; jangan pernah hardcode, jangan cetak, jangan commit.
- Salt dari `https://api.wordpress.org/secret-key/1.1/salt/`. Rotasi salt memaksa logout semua sesi.

## Hardening Instalasi

- Core, plugin, tema selalu versi terbaru. Auto-update keamanan aktif (tersedia sejak 3.7). Hanya pasang dari WordPress.org atau vendor tepercaya; hapus plugin/tema tak terpakai.
- `wp-config.php`: `DISALLOW_FILE_EDIT`, `FORCE_SSL_ADMIN`, `WP_DEBUG false` di produksi, `WP_DEBUG_LOG` ke luar webroot bila perlu debug. `DISALLOW_FILE_MODS` hanya bila update dikelola manual.
- Prefix tabel unik, satu database per situs, user DB hanya SELECT/INSERT/UPDATE/DELETE. Beri hak DDL sementara saat upgrade skema.
- Permission: direktori 755, file 644, `wp-config.php` 600, owner akun user (bukan web server) kecuali `wp-content/uploads`.
- 2FA untuk semua admin, password kuat, rate limit login, HTTPS penuh + HSTS.
- Matikan XML-RPC bila tak dipakai; batasi enumerasi user via REST bila perlu; `wp-cron` diganti cron sistem pada trafik tinggi.
- Backup rutin + uji restore, logging, monitoring file, dan WAF.
- Verifikasi integritas: `wp core verify-checksums`, `wp plugin verify-checksums <slug>`. Pindai dengan WPScan, Wordfence, atau Patchstack.
- Insiden: isolasi, ganti salt, reset password, pasang ulang core/plugin dari sumber resmi, audit user/opsi/cron, cari `eval`/`base64_decode`/file baru.

## Verifikasi Sebelum Klaim Selesai

Rincian perintah dan matriks uji ada di [references/verification.md](references/verification.md).

- `WP_DEBUG` + `WP_DEBUG_LOG` menyala saat uji; `debug.log` bersih dari notice/deprecated.
- PHPCS dengan standard `WordPress` + `WordPress-Extra` + `PHPCompatibilityWP`.
- `wp plugin check <slug>` (Plugin Check) tanpa temuan kategori repo.
- PHPUnit via `wp-env`/`wp scaffold plugin-tests` untuk logika inti.
- Uji manual per peran: tamu, subscriber, editor, admin; nonce kedaluwarsa; ID tidak valid; MIME spoof; request lintas-situs.
- WooCommerce: uji dengan HPOS aktif dan nonaktif, retry `process_payment` (tidak dobel tagih), webhook signature salah, akses order milik orang lain.
- Elementor: uji tanpa Elementor aktif (notice muncul, tidak fatal), di bawah versi minimum, widget di frontend dan preview editor, cache widget dinamis.
- Tanpa `var_dump`, `print_r`, `dd`, `console.log` tersisa.

## Anti-Pola yang Dilarang

- `$_POST`/`$_GET` dipakai langsung tanpa sanitasi atau nonce.
- `current_user_can()` diganti `is_admin()`; nonce dianggap otorisasi.
- SQL dengan interpolasi variabel; `prepare()` tanpa placeholder atau dengan placeholder dikutip.
- Echo tanpa escape, atau escape saat menyimpan lalu echo mentah.
- `extract()`, `eval()`, `unserialize()` input user, `@` menutupi error.
- Menulis file di folder plugin saat runtime; menyimpan data di luar uploads/DB.
- Query di loop, `SELECT *`, `posts_per_page => -1` tanpa alasan.
- Endpoint REST tanpa `permission_callback`; upload tanpa cek MIME nyata.
- Memuat jQuery/CDN ganda, atau mendaftarkan ulang handle core.
- WooCommerce: `get_post_meta`/`update_post_meta` untuk order, `WP_Query` bertipe `shop_order`, `new WC_Order()` tanpa `wc_get_order()`, gateway tanpa transaction ID atau idempotency, menimpa template plugin langsung.
- Elementor: widget tanpa `Requires Plugins: elementor` atau cek versi, echo `get_settings_for_display()` mentah, dependency handle yang tidak terdaftar, mengedit core Elementor.

## Quality Checklist

- [ ] Versi WordPress, PHP, dan MySQL target tercatat; API dicek ke dokumentasi resmi.
- [ ] Prefix `dci_`/`DCI\` konsisten; guard `ABSPATH` ada.
- [ ] Aktivasi, deaktivasi, dan `uninstall.php` lengkap serta bersih.
- [ ] Setiap aksi tulis punya cek kapabilitas + nonce.
- [ ] Escaping sesuai konteks di setiap output; string terjemahan di-escape.
- [ ] Input divalidasi allowlist atau disanitasi sesuai tipe.
- [ ] Query memakai `prepare()`; `LIKE` memakai `esc_like()`.
- [ ] REST punya `permission_callback` dan sanitize/validate callback.
- [ ] Upload memverifikasi MIME nyata; nama file disanitasi.
- [ ] Request keluar memakai `wp_safe_remote_*`; redirect `wp_safe_redirect()`.
- [ ] Asset di-enqueue, bukan di-inline; versi cache-busting ada.
- [ ] Secret tidak hardcode; wp-config mengikuti baseline hardening.
- [ ] PHPCS, Plugin Check, dan uji per peran lulus.
- [ ] WooCommerce: akses order via CRUD, kompatibilitas HPOS dideklarasikan, gateway idempoten, template di-override lewat theme.
- [ ] Elementor: `Requires Plugins` dan gate versi ada, kontrol dan render di-escape, dependency terdaftar, uji editor + frontend.
- [ ] Visual: token desain konsisten, elevasi berlapis, state hover/focus/disabled/loading/empty/error ada, kontras dan target sentuh lolos.
- [ ] `readme.txt` + `CHANGELOG.md` ada; versi header, `Stable tag`, dan changelog terkini konsisten.
- [ ] GitHub-ready: `.gitignore` + `.distignore` benar, lockfile di-commit, tanpa secret/artefak di riwayat, CI lint+test hijau.
- [ ] Dokumentasi menyebut kebutuhan versi, hook, dan langkah upgrade skema.

## Referensi

- Taksonomi kerentanan dan pola perbaikan: [references/security.md](references/security.md)
- Standar tampilan anti-datar dan token desain: [references/design.md](references/design.md)
- Templat `readme.txt` dan `CHANGELOG.md`: [references/release-docs.md](references/release-docs.md)
- Templat repo GitHub-ready (gitignore, distignore, CI): [references/github-ready.md](references/github-ready.md)
- WooCommerce (HPOS, gateway, query, kompatibilitas): [references/woocommerce.md](references/woocommerce.md)
- Elementor (addon, widget, kontrol, render, aset): [references/elementor.md](references/elementor.md)
- Perintah verifikasi dan matriks uji: [references/verification.md](references/verification.md)
- Sumber faktual + tanggal akses: [references/sources.md](references/sources.md)
