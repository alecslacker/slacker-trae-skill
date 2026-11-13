# WooCommerce — Pengembangan yang Aman

WooCommerce terakhir 11.3.0. Minimum WordPress 7.0, PHP 7.4 (8.0+ direkomendasikan), MySQL 5.5.5+ atau MariaDB 10.1+, memori 256 MB dan HTTPS direkomendasikan. [yakin tinggi, halaman plugin resmi]

Aturan dasar: order bukan post. Sejak WooCommerce 8.2, HPOS aktif default untuk instalasi baru, dan sejak 10.7 sinkronisasi baca default dimatikan. Kode yang masih memakai `wp_postmeta` akan tampak benar di satu lingkungan lalu diam-diam gagal di lingkungan lain.

## 1. Datastore Order

```php
// Salah: datastore lama.
$status = get_post_meta( $order_id, '_status', true );
update_post_meta( $order_id, '_dci_flag', '1' );

// Benar: CRUD.
$order = wc_get_order( $order_id );
if ( ! $order ) {
	return;
}
$order->update_meta_data( '_dci_flag', '1' );
$order->save();
```

- `save()` mahal. Kumpulkan perubahan, panggil sekali.
- `$order->get_meta()` mengembalikan nilai tersimpan; jangan baca langsung dari tabel.
- Cek ID: `OrderUtil::is_order( $id, wc_get_order_types() )`.
- Cek mode: `OrderUtil::custom_orders_table_usage_is_enabled()`.
- Jangan bergantung pada `\Automattic\WooCommerce\Internal\...` tanpa `class_exists()`; kelas internal bisa berubah.
- Deklarasi kompatibilitas wajib di file utama plugin:

```php
add_action( 'before_woocommerce_init', function () {
	if ( class_exists( \Automattic\WooCommerce\Utilities\FeaturesUtil::class ) ) {
		\Automattic\WooCommerce\Utilities\FeaturesUtil::declare_compatibility( 'custom_order_tables', __FILE__, true );
	}
} );
```

- Untuk checkout blok, deklarasikan `cart_checkout_blocks` dengan pola sama. Jangan deklarasikan kompatibel sebelum benar-benar diuji.

## 2. Query Order

```php
$ids = wc_get_orders(
	array(
		'status' => array( 'wc-processing' ),
		'limit'  => 50,
		'return' => 'ids',
	)
);
```

- Parameter: `limit`, `offset`, `paged`, `paginate`, `status`, `customer`, `customer_id`, `date_created`, `date_paid`, `total`, `currency`, `payment_method`.
- `meta_query`, `field_query`, `date_query` hanya saat HPOS aktif. Cek dulu.
- Untuk data besar: batch, `return => 'ids'`, dan Action Scheduler.
- Jangan `WP_Query` dengan `post_type => shop_order` untuk field order.
- Dokumentasi resmi menyarankan `wc_get_orders()` atas SQL kustom; bila terpaksa SQL, sadari perbedaan skema HPOS.

## 3. Produk

```php
$product = new WC_Product_Simple();
$product->set_name( sanitize_text_field( $nama ) );
$product->set_regular_price( wc_format_decimal( $harga ) );
$product->set_status( 'publish' );
$product->save();
```

- Baca: `wc_get_product( $id )`; periksa `instanceof WC_Product`.
- Variabel: `WC_Product_Variable` + `WC_Product_Variation`; atur atribut sebelum variasi.
- Simpan ID di option/meta bila perlu; jangan mengandalkan slug.
- Harga memakai `wc_format_decimal()`; mata uang dan pembulatan ikut konfigurasi toko, jangan hardcode.

## 4. Payment Gateway

```php
add_action( 'plugins_loaded', 'dci_init_gateway' );

function dci_init_gateway(): void {
	class DCI_Gateway extends WC_Payment_Gateway {
		public function __construct() {
			$this->id                 = 'dci_gateway';
			$this->method_title       = esc_html__( 'DCI Gateway', 'dci-plugin' );
			$this->method_description = esc_html__( 'Menerima pembayaran via DCI.', 'dci-plugin' );
			$this->has_fields         = true;
			$this->init_form_fields();
			$this->init_settings();
			$this->title = $this->get_option( 'title' );
			add_action(
				'woocommerce_update_options_payment_gateways_' . $this->id,
				array( $this, 'process_admin_options' )
			);
		}
	}
}

add_filter( 'woocommerce_payment_gateways', function ( $methods ) {
	$methods[] = 'DCI_Gateway';
	return $methods;
} );
```

Aturan `process_payment()`:

- Kembalikan `array( 'result' => 'success', 'redirect' => $this->get_return_url( $order ) )` hanya setelah provider mengonfirmasi.
- Panggil `$order->payment_complete( $transaction_id )` untuk pembayaran lunas. WooCommerce mengurus stok dan status.
- Gagal: `wc_add_notice( ..., 'error' )` lalu `array( 'result' => 'failure' )`.
- Menunggu konfirmasi: `$order->update_status( \Automattic\WooCommerce\Enums\OrderStatus::ON_HOLD, ... )`.
- Idempoten: simpan ID transaksi lebih dulu, cek status ke provider pada percobaan berikutnya, pakai idempotency key. Tanpa ini, retry checkout bisa menagih dua kali.
- Jangan menandai lunas dari callback frontend saja; verifikasi server-side.
- Webhook: verifikasi signature, idempotenkan berdasarkan ID transaksi, batasi hanya POST.
- Gateway langsung: `has_fields = true`, `payment_fields()`, `validate_fields()`, HTTPS, dan pahami batas PCI. Jangan simpan PAN/CVC.

Integrasi checkout blok berbeda dari gateway klasik: ikuti dokumentasi payment method integration (Block API), daftarkan metode di sisi klien, dan deklarasikan `cart_checkout_blocks`.

## 5. Template

- Override di `theme/woocommerce/...`; jangan edit file plugin.
- Saat WooCommerce naik versi, bandingkan template dengan `woocommerce/templates/` dan sinkronkan.
- `wc_get_template()` untuk memuat template dengan data; filter `woocommerce_locate_template` bila butuh jalur lain.
- Hook lebih stabil daripada override: `woocommerce_before_shop_loop`, `woocommerce_after_shop_loop_item`, `woocommerce_checkout_fields`, `woocommerce_order_status_changed`, `woocommerce_email_order_meta`.
- Escape di template: nama produk `esc_html()`, URL `esc_url()`, deskripsi `wp_kses_post()`.

## 6. Pekerjaan Latar

- Gunakan Action Scheduler: `as_enqueue_async_action()`, `as_schedule_single_action()`, `as_schedule_recurring_action()`.
- Job harus idempoten dan tahan dijalankan ulang.
- Pantau `wp action-scheduler list` / antrean gagal.
- Jangan mengandalkan `wp_cron` untuk proses checkout.

## 7. Tampilan Toko (anti-datar)

Toko tidak boleh terlihat seperti instalasi default.

- Kartu produk: rasio gambar tetap, elevasi saat hover, harga tegas, CTA jelas.
- Grid dan filter memakai hook (`woocommerce_before_shop_loop`, `woocommerce_after_shop_loop_item`) agar override tetap tipis.
- Checkout: label di atas field, state fokus terlihat, ringkasan order sebagai panel raised.
- Notifikasi toko memakai warna semantik dengan ikon, bukan abu seragam.
- Sticky add-to-cart/filter memakai shadow agar terpisah dari konten.
- Token warna, radius, shadow, spacing dari [design.md](design.md); jangan hardcode per template.
- Uji 320/768/1280 px, mode gelap, dan state kosong/loading/error.

## 8. Keamanan

- Kapabilitas: `manage_woocommerce` (setting), `edit_shop_orders` (daftar order), `edit_shop_order` + ID (order tertentu), `manage_product_terms`, `edit_products`.
- Order adalah data pribadi: pastikan pemilik atau kapabilitas sebelum menampilkan.
- Nonce pada setiap aksi order di admin/frontend.
- REST API WooCommerce: consumer key/secret, HTTPS saja, simpan di server; jangan kirim di URL.
- Jangan log data kartu; log ID transaksi dan status saja.
- Batasi jumlah query di halaman checkout; gunakan cache untuk data statis.

## 9. Anti-Pola

- `get_post_meta()`/`update_post_meta()` untuk order.
- `WP_Query` `shop_order` untuk field order.
- `new WC_Order()` tanpa validasi; gunakan `wc_get_order()`.
- `process_payment()` tanpa transaction ID atau pengecekan status.
- Menandai order lunas sebelum provider mengonfirmasi.
- Menimpa template plugin langsung.
- Query `posts_per_page => -1` di halaman toko.
- Menyimpan data kartu sendiri tanpa alasan.

## 10. Checklist

- [ ] Kompatibilitas HPOS dideklarasikan; kode diuji dengan HPOS aktif dan nonaktif.
- [ ] Semua akses order lewat CRUD; `save()` tidak berlebihan.
- [ ] Query memakai `wc_get_orders()` dengan limit.
- [ ] Gateway idempoten dan memverifikasi server-side.
- [ ] Webhook memverifikasi signature.
- [ ] Template di theme; hook dipakai bila cukup.
- [ ] Kapabilitas dan nonce pada setiap aksi.
- [ ] Pekerjaan berat di Action Scheduler.
- [ ] Uji checkout klasik dan blok.
- [ ] Tampilan toko tidak datar; elevasi, state, dan responsif sudah diuji.
