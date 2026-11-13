# Templat Repo GitHub-Ready untuk Plugin WordPress

Semua berkas di bawah ini disalin apa adanya saat memulai repo baru. Sesuaikan nama plugin, slug, dan tahun.

## 1. .gitignore

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

# WordPress lokal (bila repo berada di dalam instalasi WP)
wp-config.php
wp-content/
```

Prinsip:

- Lockfile di-commit (`composer.lock`, `package-lock.json`) agar build dapat direproduksi.
- Dependensi dan artefak tidak pernah masuk repo; zip dibangun CI saat rilis.
- `.env` di-ignore; `.env.example` dengan placeholder di-commit.
- Bila repo plugin berdiri sendiri (bukan di dalam wp-content), hapus dua baris WordPress lokal.

## 2. .distignore

Dipakai `wp dist-archive` untuk membuat zip rilis yang bersih:

```text
.git
.github
node_modules
vendor
tests
bin
*.zip
*.log
.env
.env.*
!.env.example
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

Catatan: `readme.txt` tetap ikut ke dalam zip karena WordPress membacanya.

## 3. .editorconfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = tab
indent_size = 4

[*.{md,json,yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
```

Tab sesuai WordPress Coding Standards; markdown dan JSON memakai spasi.

## 4. composer.json (contoh dev tooling)

```json
{
	"name": "duta-corpora/dci-nama-plugin",
	"description": "Plugin WordPress DCI.",
	"type": "wordpress-plugin",
	"license": "GPL-2.0-or-later",
	"authors": [
		{
			"name": "Duta Corpora Indonesia",
			"email": "dev@dutacorpora.example"
		},
		{
			"name": "Mas Wondho",
			"role": "Developer"
		}
	],
	"require": {
		"php": ">=7.4"
	},
	"require-dev": {
		"php": ">=7.4",
		"wp-coding-standards/wpcs": "^3.1",
		"phpcompatibility/phpcompatibility-wp": "^2.1",
		"dealerdirect/phpcodesniffer-composer-installer": "^1.0",
		"yoast/phpunit-polyfills": "^2.0"
	},
	"config": {
		"allow-plugins": {
			"dealerdirect/phpcodesniffer-composer-installer": true
		}
	},
	"scripts": {
		"lint": "phpcs --standard=WordPress-Extra .",
		"lint:fix": "phpcbf --standard=WordPress-Extra .",
		"test": "phpunit"
	}
}
```

Ganti email dengan email internal; jangan memakai alamat pribadi di repo publik.

## 5. phpcs.xml.dist

```xml
<?xml version="1.0"?>
<ruleset name="DCI Nama Plugin">
	<description>Standar kode DCI berbasis WordPress-Extra.</description>

	<file>.</file>
	<exclude-pattern>/vendor/</exclude-pattern>
	<exclude-pattern>/node_modules/</exclude-pattern>
	<exclude-pattern>/tests/</exclude-pattern>

	<rule ref="WordPress-Extra"/>
	<rule ref="PHPCompatibilityWP"/>

	<config name="testVersion" value="7.4-"/>
	<arg name="extensions" value="php"/>
	<arg name="cache" value=".phpcs-cache"/>
	<arg name="parallel" value="8"/>
	<arg value="sp"/>
</ruleset>
```

## 6. phpunit.xml.dist

```xml
<?xml version="1.0"?>
<phpunit
	bootstrap="tests/bootstrap.php"
	backupGlobals="false"
	colors="true"
	convertErrorsToExceptions="true"
	convertNoticesToExceptions="true"
	convertWarningsToExceptions="true"
>
	<testsuites>
		<testsuite name="unit">
			<directory suffix="Test.php">./tests/</directory>
		</testsuite>
	</testsuites>
	<php>
		<env name="WP_PHPUNIT__TESTS_CONFIG" value="tests/wp-tests-config.php"/>
	</php>
</phpunit>
```

## 7. GitHub Actions — .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
  release:
    types: [published]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: "8.3"
          tools: composer, cs2pr
      - name: Install dependencies
        run: composer install --prefer-dist --no-progress
      - name: PHPCS
        run: vendor/bin/phpcs --report=checkstyle | cs2pr

  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
        ports: ["3306:3306"]
        options: >-
          --health-cmd="mysqladmin ping" --health-interval=10s
          --health-timeout=5s --health-retries=5
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: "8.3"
          tools: composer
      - name: Install dependencies
        run: composer install --prefer-dist --no-progress
      - name: Install WP test suite
        run: bash bin/install-wp-tests.sh wordpress_test root root 127.0.0.1 latest true
      - name: PHPUnit
        run: vendor/bin/phpunit

  build:
    if: github.event_name == 'release'
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: "8.3"
          tools: composer, wp-cli
      - name: Install production dependencies
        run: composer install --no-dev --optimize-autoloader --prefer-dist --no-progress
      - name: Build zip
        run: wp dist-archive . "${{ github.event.release.tag_name }}.zip"
      - name: Attach zip to release
        uses: softprops/action-gh-release@v2
        with:
          files: ${{ github.event.release.tag_name }}.zip
```

Catatan:

- `bin/install-wp-tests.sh` dibuat lewat `wp scaffold plugin-tests`.
- CI merah = tidak merge, tidak rilis.
- Release dibuat setelah tag `X.Y.Z` dan entri changelog siap.

## 8. README.md kerangka

```markdown
# Nama Plugin

Deskripsi singkat. Badge CI di sini bila workflow sudah jalan.

## Fitur
- Fitur 1.
- Fitur 2.

## Kebutuhan
- WordPress 7.0+, PHP 7.4+.
- WooCommerce (bila relevan) — kompatibel HPOS dan checkout blok.
- Elementor (bila relevan) — cek `Requires Plugins`.

## Instalasi
1. Unduh rilis terbaru (zip) dari halaman Releases.
2. Plugins → Add New → Upload Plugin → pilih zip → Activate.

## Pengembangan
```bash
composer install
npm install        # bila pakai build JS
npm run build
composer lint
composer test
```

## Changelog
Lihat [CHANGELOG.md](CHANGELOG.md). Format WordPress.org tersedia di [readme.txt](readme.txt).

## Kredit
Dibuat oleh Duta Corpora Indonesia — developer: Mas Wondho.

Copyright © 2026 Duta Corpora Indonesia — All rights reserved.
```

Tanpa tautan eksternal selain berkas internal repo. Tanpa badge layanan pihak ketiga yang membocorkan repo privat.

## 9. Checklist GitHub-Ready

- [ ] `.gitignore`, `.distignore`, `.editorconfig` ada dan sesuai templat.
- [ ] `LICENSE` GPLv2+, `CHANGELOG.md`, `readme.txt`, `README.md` lengkap dan konsisten.
- [ ] Lockfile di-commit; `vendor/` dan `node_modules/` tidak.
- [ ] Tidak ada `.env`, dump SQL, atau zip di riwayat git.
- [ ] CI lint + test hijau di branch utama.
- [ ] Tag `X.Y.Z` + GitHub Release + zip hasil build.
- [ ] Atribusi `Duta Corpora Indonesia — Mas Wondho` tanpa tautan, di README.md dan readme.txt.
