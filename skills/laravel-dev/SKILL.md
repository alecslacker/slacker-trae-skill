---
name: laravel-dev
description: "Pengembangan backend PHP Laravel: REST API, Eloquent ORM, migration, queue, autentikasi Sanctum, testing. Panggil saat menulis atau meninjau kode Laravel (termasuk MySQL/MariaDB, form validation, otorisasi, dan keamanan API)."
user-invocable: true
---

# Laravel Development

**Pengumuman saat dipakai:** "Saya memakai skill laravel-dev: konvensi Laravel + verifikasi Context7 sebelum menulis kode."

## Prasyarat Mutlak

1. Context7 WAJIB sebelum memakai API/facade/paket Laravel apa pun: versi Laravel di composer.json proyek vs dokumentasi terbaru, breaking changes, deprecation. Jangan mengandalkan ingatan training data.
2. Deteksi dulu versi proyek: baca composer.json (versi Laravel, PHP, paket) SEBELUM menulis satu baris kode. Konvensi Laravel berbeda antar versi mayor.

## Struktur dan Konvensi Kode

- Controller tipis: hanya orkestrasi (validasi via FormRequest, delegasi ke service/Action class, response via API Resource). Dilarang logika bisnis di controller dan di route closure.
- Validasi input: FormRequest class dengan rules eksplisit dan pesan galat dalam Bahasa Indonesia. Dilarang validasi manual tersebar di controller.
- Response API: API Resource (transformasi terpusat), struktur konsisten (data, meta), kode HTTP semantik (201 created, 422 validation, 401, 403, 404).
- Route: grup dengan middleware dan prefix; API beri prefix versi (misal api/v1); nama route untuk semua endpoint.
- Model Eloquent: $fillable eksplisit (anti mass assignment), $casts untuk tipe, relasi didefinisikan jelas, accessor/mutator untuk transformasi, scope query untuk filter berulang.
- Service/Action class untuk logika bisnis lintas model; event + listener untuk efek samping (notifikasi, logging).

## Database dan Migration

- Setiap perubahan skema lewat migration (jangan ubah skema manual). Migration harus reversibel (down benar-benar membalik).
- ForeignKeyConstraint + index eksplisit untuk kolom yang sering di-query; soft delete atau pola is_active + archived_at sesuai kebutuhan bisnis (pilih satu, konsisten).
- Query: Eloquent atau Query Builder dengan binding parameter. DILARANG raw SQL string yang digabung (injeksi). Hindari N+1: eager loading (with) untuk relasi yang dipakai.
- UUID primary key untuk API publik (jangan expose auto-increment id bila endpoint terbuka luas).

## Autentikasi dan Otorisasi

- API token: Laravel Sanctum (personal access token) atau SPA cookie session, pilih sesuai klien; token punya ability/scope minimal.
- Otorisasi: Policy per model + Gate untuk aksi lintas model; cek di controller, bukan di blade/view saja.
- Rate limiting pada endpoint sensitif (login, reset password, endpoint AI/berbayar).

## Queue, Schedule, Cron

- Pekerjaan lambat (kirim notifikasi, generate PDF, panggil API eksternal) WAJIB ke queue job class, bukan synchronous di request.
- failed_jobs dipantau; job idempoten (aman dijalankan ulang).
- Tugas periodik lewat schedule di routes/console.php atau Kernel; dokumentasikan entri cron server yang dibutuhkan.

## Keamanan

- Secret dan kunci API hanya di .env; tidak pernah hardcode, tidak pernah di-log, tidak pernah dikomit. .env.example berisi placeholder.
- Kolom sensitif (NIK, data medis, dan sejenisnya) dienkripsi (kolom encrypted casts) sebelum disimpan.
- CSRF aktif untuk rute web; API stateless dengan token. Output di-escape (Blade pakai {{ }} otomatis).
- Upload file: validasi mime + ukuran, nama acak, simpan di luar webroot atau storage dengan symlink terkontrol.
- Log: jangan pernah log password, token, atau data pribadi; gunakan channel terpisah untuk audit.

## Testing

- PHPUnit atau Pest (ikut yang sudah ada di proyek). Feature test untuk tiap endpoint (happy path + validasi gagal + unauthorized).
- Database test: sqlite in-memory atau refreshDatabase; factory + seeder untuk data uji.
- Target cakupan: modul inti (autentikasi, otorisasi tenant, uang, data medis) wajib ada test sebelum dinyatakan selesai.

## Anti-Pola yang Dilarang

- dd(), dump(), var_dump(), print_r() tertinggal di kode.
- Logika bisnis di route closure, di middleware, atau di blade.
- Query di loop (N+1), SELECT *, mengambil seluruh tabel lalu filter di PHP.
- Menambal fitur lewat skrip eksternal yang menulis ulang file sumber.
- Mengabaikan kegagalan dengan try-catch kosong.

## Perintah Verifikasi (jalankan sebelum klaim selesai)

- php artisan test (seluruh test hijau).
- php artisan migrate:fresh --seed hanya di lingkungan dev lokal (jangan di staging/produksi).
- php artisan route:list untuk memastikan endpoint terdaftar sesuai rancangan.
- php artisan config:cache && php artisan route:cache && php artisan view:cache lalu pastikan aplikasi tetap jalan (cache config sering membongkar bug env).

## Quality Checklist

- [ ] composer.json dibaca; versi Laravel dan paket dicatat.
- [ ] API/facade baru diverifikasi via Context7 (bukan ingatan).
- [ ] Validasi input di FormRequest; pesan galat Bahasa Indonesia.
- [ ] Response via API Resource; kode HTTP semantik.
- [ ] Migration reversibel; relasi dan index eksplisit.
- [ ] Tidak ada N+1; tidak ada raw SQL tanpa binding.
- [ ] Otorisasi via Policy/Gate; rate limit endpoint sensitif.
- [ ] Pekerjaan lambat di queue; job idempoten.
- [ ] Secret hanya di .env; kolom sensitif terenkripsi.
- [ ] Feature test lulus; tanpa dd/dump/var_dump tersisa.
