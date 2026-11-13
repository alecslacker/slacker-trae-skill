# Elementor — Pengembangan Addon yang Aman

Elementor adalah platform dengan API sendiri. Dua kesalahan paling umum: memanggil API sebelum Elementor siap, dan menganggap setting widget sebagai data tepercaya.

## 1. Struktur Addon

```text
dci-elementor-addon/
├─ dci-elementor-addon.php
├─ widgets/
│  └─ class-dci-hero.php
├─ assets/
│  ├─ css/
│  └─ js/
└─ languages/
```

Header minimal:

```php
/**
 * Plugin Name: DCI Elementor Addon
 * Description: Widget hero untuk DCI.
 * Version: 1.0.0
 * Author: Duta Corpora Indonesia
 * Developer: Mas Wondho — Duta Corpora Indonesia
 * Copyright © 2026 Duta Corpora Indonesia
 * Text Domain: dci-elementor-addon
 * Requires Plugins: elementor
 * Elementor tested up to: 3.30.0
 * Elementor Pro tested up to: 3.30.0
 */
```

- `Requires Plugins: elementor` membuat WordPress menangani ketergantungan. Tetap siapkan gate runtime.
- `Elementor tested up to` adalah deklarasi, bukan jaminan. Perbarui setelah uji nyata.
- Jangan mengedit core Elementor atau addon pihak lain; perluas via hook/filter.

## 2. Gate Kompatibilitas

```php
final class DCI_Addon {
	const MINIMUM_ELEMENTOR = '3.20.0';
	const MINIMUM_PHP       = '7.4';

	public function __construct() {
		if ( $this->is_compatible() ) {
			add_action( 'elementor/widgets/register', array( $this, 'register_widgets' ) );
		}
	}

	private function is_compatible(): bool {
		if ( ! did_action( 'elementor/loaded' ) ) {
			add_action( 'admin_notices', array( $this, 'notice_missing_elementor' ) );
			return false;
		}
		if ( ! version_compare( ELEMENTOR_VERSION, self::MINIMUM_ELEMENTOR, '>=' ) ) {
			add_action( 'admin_notices', array( $this, 'notice_minimum_version' ) );
			return false;
		}
		if ( version_compare( PHP_VERSION, self::MINIMUM_PHP, '<' ) ) {
			add_action( 'admin_notices', array( $this, 'notice_minimum_php' ) );
			return false;
		}
		return true;
	}
}
```

- Jangan memanggil `\Elementor\...` sebelum `elementor/loaded`.
- Notice memakai `esc_html__()` dan `wp_kses_post()`, bukan HTML mentah.
- Bila gagal, addon berhenti dengan rapi; jangan fatal.

## 3. Registrasi Widget

```php
public function register_widgets( $widgets_manager ): void {
	require_once __DIR__ . '/widgets/class-dci-hero.php';
	$widgets_manager->register( new \DCI_Hero_Widget() );
}
```

- Hook resmi: `elementor/widgets/register`.
- Nama widget unik dan snake_case; beri prefix.
- Kategori: daftarkan lewat `elementor/elements/categories_registered` dan `$elements_manager->add_category()`.

## 4. Kerangka Widget

```php
class DCI_Hero_Widget extends \Elementor\Widget_Base {
	public function get_name(): string {
		return 'dci_hero';
	}

	public function get_title(): string {
		return esc_html__( 'DCI Hero', 'dci-elementor-addon' );
	}

	public function get_icon(): string {
		return 'eicon-image';
	}

	public function get_categories(): array {
		return array( 'dci' );
	}

	public function get_keywords(): array {
		return array( 'hero', 'banner' );
	}

	protected function register_controls(): void {
		// Section dan kontrol.
	}

	protected function render(): void {
		// Output frontend.
	}

	protected function content_template(): void {
		// Preview editor (JS template).
	}
}
```

- Method yang dipakai di dokumentasi resmi adalah `register_controls()`, bukan `_register_controls()`.
- `content_template()` opsional, tetapi tanpanya preview editor kosong.
- Widget berat sebaiknya mendukung Element Caching dan mendeklarasikan `is_dynamic_content()` dengan benar.

## 5. Kontrol

```php
$this->start_controls_section(
	'section_konten',
	array(
		'label' => esc_html__( 'Konten', 'dci-elementor-addon' ),
		'tab'   => \Elementor\Controls_Manager::TAB_CONTENT,
	)
);

$this->add_control(
	'judul',
	array(
		'label'       => esc_html__( 'Judul', 'dci-elementor-addon' ),
		'type'        => \Elementor\Controls_Manager::TEXT,
		'default'     => esc_html__( 'Judul hero', 'dci-elementor-addon' ),
		'label_block' => true,
	)
);

$this->end_controls_section();
```

- Selalu bungkus dengan `start_controls_section()`/`end_controls_section()`.
- Label, placeholder, opsi memakai `esc_html__()`.
- Select/choose memberi allowlist nilai; jangan menerima nilai bebas bila hanya beberapa yang valid.
- Style memakai `selectors`:

```php
'selectors' => array(
	'{{WRAPPER}} .dci-hero__judul' => 'color: {{VALUE}};',
),
```

- Untuk tipografi, shadow, background, border gunakan group control (`Group_Control_Typography`, `Group_Control_Box_Shadow`, dst) agar konsisten dan responsif.

## 6. Render dan Escaping

```php
protected function render(): void {
	$settings = $this->get_settings_for_display();

	if ( empty( $settings['judul'] ) ) {
		return;
	}

	$this->add_render_attribute(
		'wrapper',
		array(
			'class' => array( 'dci-hero', $settings['kelas'] ?? '' ),
		)
	);
	?>
	<div <?php $this->print_render_attribute_string( 'wrapper' ); ?>>
		<h2 class="dci-hero__judul"><?php echo esc_html( $settings['judul'] ); ?></h2>
		<?php if ( ! empty( $settings['tautan']['url'] ) ) : ?>
			<a href="<?php echo esc_url( $settings['tautan']['url'] ); ?>">
				<?php echo esc_html( $settings['teks_tautan'] ); ?>
			</a>
		<?php endif; ?>
	</div>
	<?php
}
```

- `get_settings_for_display()` mengembalikan setting; tidak otomatis meng-escape teks.
- `add_render_attribute()` membantu menyusun atribut, tetapi teks di dalam tag tetap di-escape.
- Media: ID gambar divalidasi `absint()`, URL `esc_url()`, `alt` `esc_attr()`.
- HTML kaya: `wp_kses_post()`.
- Repeater: validasi tiap baris, jangan asumsikan kunci selalu ada.

## 7. Asset dan Dependensi

```php
add_action( 'wp_enqueue_scripts', function () {
	wp_register_script( 'dci-hero', plugins_url( 'assets/js/hero.js', __FILE__ ), array(), '1.0.0', true );
	wp_register_style( 'dci-hero', plugins_url( 'assets/css/hero.css', __FILE__ ), array(), '1.0.0' );
} );
```

```php
public function get_script_depends(): array {
	return array( 'dci-hero' );
}

public function get_style_depends(): array {
	return array( 'dci-hero' );
}
```

- Handle wajib sudah terdaftar; handle tak terdaftar diabaikan.
- Hanya aset widget yang dipakai halaman akan dimuat — jangan enqueue global.
- Asset khusus panel editor: `elementor/editor/before_enqueue_scripts`.
- Bisa memakai pustaka yang sudah didaftarkan Elementor (mis. `swiper`) agar tidak menggandakan versi.

## 8. Dynamic Tag

- Daftarkan lewat `elementor/dynamic_tags/register`.
- Tag membaca sumber data (meta, opsi, ACF); validasi dan escape output di dalam tag.
- Tandai widget yang memakai tag sebagai dynamic content agar cache tidak menyajikan nilai basi.

## 9. Tampilan Widget (anti-datar)

Widget harus tampil selesai sejak pertama dijatuhkan, bukan menunggu disetel manual.

- Isi default kontrol dengan nilai yang sudah enak dilihat: radius, padding, shadow level 2, dan tipografi terukur.
- Sediakan kontrol untuk radius, shadow, dan spacing agar pengguna tidak terkunci pada satu tampilan.
- Gunakan `selectors` + `{{WRAPPER}}`; jangan menyuntik CSS global.
- Permukaan widget memakai elevasi nyata di atas latar: border halus + shadow lembut, bukan kotak rata.
- State hover/focus/active/disabled wajib punya perlakuan; jangan hilangkan outline fokus.
- Hormati container/flexbox; hindari lebar piksel tetap.
- Uji preview editor dan frontend pada 320, 768, 1280 px, plus mode gelap dan `prefers-reduced-motion`.
- Rincian token dan komposisi: [design.md](design.md).

## 10. Keamanan

- Semua setting widget diperlakukan sebagai input user: escape sesuai konteks.
- URL dari kontrol `URL` bisa mengarah ke luar; validasi skema bila perlu dan pakai `esc_url()`.
- Query di dalam widget dibatasi (jumlah, cache) agar editor tidak lambat.
- Dynamic tag yang menampilkan meta harus memeriksa kapabilitas bila meta sensitif.
- Jangan menyimpan data rahasia di setting widget; setting tersimpan sebagai post meta dokumen.
- Template Elementor adalah konten; escape saat dirender, jangan percaya HTML tersimpan.

## 11. Performa

- Dukung Element Caching; jangan paksa render ulang tiap request.
- Gunakan container/flexbox, bukan tumpukan section usang.
- Hindari CSS/JS inline berulang; andalkan file terdaftar.
- Batasi query dan panggilan HTTP di `render()`.

## 12. Deprecation dan Rilis

- Ikuti halaman deprecation Elementor dan jalankan Elementor Deprecated Code Detector.
- Uji di Elementor terbaru; uji Pro bila addon menyentuh fitur Pro (butuh developer license).
- Catat versi yang diuji di header dan changelog.
- Pertimbangkan Patchstack mVDP untuk jalur pelaporan kerentanan.

## 13. Anti-Pola

- Memanggil API Elementor sebelum `elementor/loaded`.
- Widget tanpa `Requires Plugins` atau gate versi.
- `_register_controls()` pada kode baru.
- Echo `get_settings_for_display()` mentah.
- Handle dependensi yang tidak terdaftar.
- Enqueue aset di semua halaman.
- Menyimpan HTML tersimpan tanpa escape saat render.
- Mengedit core Elementor.

## 14. Checklist

- [ ] Header `Requires Plugins`, versi uji, dan text domain benar.
- [ ] Gate `elementor/loaded` + versi + PHP berjalan.
- [ ] Widget terdaftar lewat `elementor/widgets/register`.
- [ ] Kontrol memakai section, label ter-escape, nilai allowlist.
- [ ] Render meng-escape teks, URL, atribut, dan media.
- [ ] `content_template()` tersedia untuk preview.
- [ ] Aset terdaftar dan dideklarasikan via `get_*_depends`.
- [ ] Dynamic tag memakai registrasi resmi dan cache-aware.
- [ ] Uji frontend + editor + Elementor Pro (bila relevan).
- [ ] Tampilan tidak datar; default kontrol, elevasi, dan state visual sudah layak.
- [ ] Deprecated Code Detector bersih.
