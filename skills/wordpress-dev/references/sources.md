# Sumber Faktual

Semua diakses 13 November 2026. Skill ini menyimpang dari ingatan training data; bila umur sumber lebih dari tiga bulan, verifikasi ulang sebelum dipakai.

## Sumber Resmi WordPress

| Topik | URL | Keyakinan |
|---|---|---|
| Prinsip keamanan, escape-late, validasi lebih baik dari sanitasi | https://developer.wordpress.org/apis/security/ | Tinggi — handbook resmi |
| Escaping per konteks + helper i18n | https://developer.wordpress.org/apis/security/escaping/ | Tinggi |
| Fungsi sanitasi | https://developer.wordpress.org/apis/security/sanitizing/ | Tinggi |
| Nonce, masa hidup 12–24 jam, nonce bukan otorisasi | https://developer.wordpress.org/apis/security/nonces/ | Tinggi |
| Cek kapabilitas + contoh IDOR | https://developer.wordpress.org/plugins/security/checking-user-capabilities/ | Tinggi |
| Struktur plugin, hook aktivasi, header | https://developer.wordpress.org/plugins/plugin-basics/ | Tinggi |
| Prefix, guard ABSPATH, struktur folder | https://developer.wordpress.org/plugins/plugin-basics/best-practices/ | Tinggi |
| `dbDelta` dan aturan formatnya | https://developer.wordpress.org/plugins/creating-tables-with-plugins/ | Tinggi |
| Autentikasi REST, nonce `wp_rest`, Application Passwords sejak 5.6 | https://developer.wordpress.org/rest-api/using-the-rest-api/authentication/ | Tinggi |
| `permission_callback` wajib sejak 5.5 | https://developer.wordpress.org/reference/functions/register_rest_route/ | Tinggi |
| `$wpdb->prepare`, placeholder `%i` sejak 6.2, `esc_like` | https://developer.wordpress.org/reference/classes/wpdb/prepare/ | Tinggi |
| Hardening: permission, wp-admin, user DB | https://developer.wordpress.org/advanced-administration/security/hardening/ | Tinggi |
| 2FA | https://developer.wordpress.org/advanced-administration/security/mfa/ | Tinggi |
| Proses perbaikan kerentanan plugin | https://developer.wordpress.org/plugins/wordpress-org/plugin-security/ | Tinggi |
| Keamanan i18n, kompilasi `.mo` sendiri | https://developer.wordpress.org/plugins/internationalization/security/ | Tinggi |
| Pelaporan isu tema | https://developer.wordpress.org/themes/theme-security/theme-security-issues/ | Tinggi |
| PHP Coding Standards, Yoda, prefix, tab | https://developer.wordpress.org/coding-standards/wordpress-coding-standards/php/ | Tinggi |
| `block.json`, `apiVersion` 3 sejak 6.3 | https://developer.wordpress.org/block-editor/reference-guides/block-api/block-metadata/ | Tinggi |
| `wp_handle_upload` dan override MIME | https://developer.wordpress.org/reference/functions/wp_handle_upload/ | Tinggi |
| `wp_check_filetype_and_ext` | https://developer.wordpress.org/reference/functions/wp_check_filetype_and_ext/ | Tinggi |
| Pernyataan keamanan proyek, 43% web, white paper | https://wordpress.org/about/security/ | Tinggi |
| Kinerja dan pembaruan inti | https://wordpress.org/news/category/releases/ | Tinggi |

## Fakta Versi

| Fakta | Sumber | Keyakinan |
|---|---|---|
| WordPress stabil 7.1.4, rilis keamanan 28 Oktober 2026 | https://wordpress.org/news/2026/10/wordpress-7-1-4/ | Tinggi |
| WordPress 7.2 masih beta (Beta 4, 3 November 2026) | https://wordpress.org/news/2026/11/wordpress-7-2-beta-4/ | Tinggi |
| Dukungan PHP 7.2/7.3 dihentikan di 7.0; minimum didukung 7.4; minimum direkomendasikan 8.3 | https://make.wordpress.org/core/tag/php/ | Tinggi |
| MySQL 8.0+ disebut sebagai kebutuhan host WordPress 7 | https://mysites.guru/blog/wordpress-7-requirements.pdf | Sedang — blog vendor |
| Auto-update keamanan plugin sejak 3.7 | https://developer.wordpress.org/plugins/wordpress-org/plugin-security/ | Tinggi |
| Plugin Check versi 2.1.0, perintah `wp plugin check` | https://wordpress.org/plugins/plugin-check/ | Tinggi |

## Statistik Ekosistem (bukan data resmi)

| Klaim | Sumber | Keyakinan |
|---|---|---|
| Plugin ±97% kerentanan baru, tema 2,8%, core 0,2% | https://blog.webhostmost.com/wordpress-plugin-security-audit-guide-2026/ | Sedang — agregasi vendor |
| Basis data WPScan ±50.773 kerentanan pada 2026 | https://seguridadenwordpress.com/detectar-plugins-vulnerables-wpscan/ | Rendah–sedang — sekunder |
| 107 kerentanan WordPress sepanjang April 2026 | https://seguridadenwordpress.com/sucuri-informe-vulnerabilidades-wordpress-abril-2026/ | Rendah — sekunder |

## Sumber WooCommerce

| Topik | URL | Keyakinan |
|---|---|---|
| HPOS, tabel, sinkronisasi, deklarasi | https://developer.woocommerce.com/docs/features/high-performance-order-storage/ | Tinggi — dokumentasi resmi |
| Recipe book HPOS, audit postmeta, `OrderUtil`, `declare_compatibility` | https://developer.woocommerce.com/docs/features/orders/high-performance-order-storage/recipe-book/ | Tinggi |
| `wc_get_orders()` dan `WC_Order_Query` | https://developer.woocommerce.com/docs/extensions/core-concepts/wc-get-orders/ | Tinggi |
| Payment Gateway API, idempotensi, `payment_complete` | https://developer.woocommerce.com/docs/features/payments/payment-gateway-api/ | Tinggi |
| Deklarasi `cart_checkout_blocks` | https://developer.woocommerce.com/docs/block-development/extensible-blocks/cart-and-checkout-blocks/ | Tinggi |
| Kompatibilitas dan interoperabilitas extension | https://developer.woocommerce.com/docs/best-practices/compatibility | Tinggi |
| Coding standards WooCommerce | https://developer.woocommerce.com/docs/best-practices/coding-standards | Tinggi |
| Versi 11.3.0 + minimum requirement (WP 7.0, PHP 7.4/8.0+, MySQL 5.5.5+ / MariaDB 10.1+) | https://wordpress.org/plugins/woocommerce/ | Tinggi |
| HPOS default sejak 8.2 | https://developer.woocommerce.com/docs/features/high-performance-order-storage/ | Tinggi |
| Sync-on-read dimatikan di 10.7 (April 2026) | https://yoohooplugins.com/woocommerce-hpos-migration-developer-guide-2026/ | Sedang — vendor |

## Sumber Elementor

| Topik | URL | Keyakinan |
|---|---|---|
| Addon pertama, struktur, header `Requires Plugins` | https://developers.elementor.com/docs/getting-started/first-addon/ | Tinggi — dokumentasi resmi |
| Struktur widget dan method wajib | https://developers.elementor.com/docs/widgets/widget-structure/ | Tinggi |
| Registrasi widget via `elementor/widgets/register` | https://developers.elementor.com/docs/managers/registering-widgets/ | Tinggi |
| Kontrol widget | https://developers.elementor.com/docs/widgets/widget-controls/ | Tinggi |
| Render dan `content_template` | https://developers.elementor.com/docs/widgets/widget-rendering/ | Tinggi |
| Escaping atribut + `add_render_attribute` | https://developers.elementor.com/docs/widgets/rendering-html-attribute/ | Tinggi |
| Dependensi script/style | https://developers.elementor.com/docs/widgets/widget-dependencies/ | Tinggi |
| Kategori widget | https://developers.elementor.com/docs/widgets/widget-categories/ | Tinggi |
| Registrasi dynamic tag | https://developers.elementor.com/docs/managers/registering-dynamic-tags/ | Tinggi |
| Gate kompatibilitas versi | https://developers.elementor.com/docs/addons/compatibility/ | Tinggi |
| Best practices addon, detektor deprecation, caching | https://developers.elementor.com/docs/getting-started/best-practices/ | Tinggi |

## Cara Pakai Sumber

- Klaim tingkat tinggi harus bisa ditelusuri ke dua sumber primer di tabel pertama.
- Statistik industri dipakai sebagai konteks prioritas, bukan angka mutlak.
- Bila dokumentasi berubah, perbarui isi skill, bukan menambah catatan kaki.
