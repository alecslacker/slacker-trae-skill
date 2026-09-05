# Contoh PRD: WarungPintar

> **Contoh ini** menunjukkan hasil akhir yang dihasilkan oleh skill `prd-builder` setelah user menjawab semua pertanyaan guided.

---

# PRD: WarungPintar

> **Status**: DRAFT
> **Tanggal**: 2026-08-12
> **Versi**: 1.0

---

## 1. Overview

### Deskripsi
Sebuah aplikasi web yang membantu pemilik warung mencatat penjualan harian, melihat laporan laba rugi, dan mengelola stok produk dari HP atau komputer mereka.

### Target Pengguna
| Tipe Pengguna | Deskripsi | Prioritas |
|---------------|-----------|-----------|
| Pemilik Warung | Pemilik UMKM usia 30-55 tahun, terbiasa pakai WhatsApp tapi belum pernah pakai aplikasi kasir | Primer |
| Karyawan Warung | Anak muda yang bantu jaga warung, terbiasa dengan smartphone | Sekunder |

### Masalah yang Dipecahkan
Saat ini pemilik warung mencatat penjualan di buku tulis atau mengandalkan ingatan. Akibatnya:
- Sering lupa catat utang pelanggan
- Tidak tahu pasti berapa laba rugi sebenarnya
- Stok habis tanpa diketahui
- Susah melacak tren penjualan

### Solusi yang Ditawarkan
- Catat penjualan dalam <30 detik langsung dari HP
- Laporan laba rugi otomatis tiap akhir bulan
- Stok terupdate otomatis setiap transaksi
- Pengingat utang piutang yang jatuh tempo

### Platform
Website (mobile-first, bisa dibuka dari browser HP)

---

## 2. Requirements

### Must-Have (Versi 1)
- Login dengan email + password
- Dashboard ringkasan harian
- Catat penjualan (produk dari katalog atau manual)
- Kelola produk (CRUD katalog)
- Laporan laba rugi sederhana (mingguan & bulanan)
- Pencatatan utang piutang

### Nice-to-Have (Versi 2+)
- Pembayaran QRIS
- Multi-cabang
- Notifikasi WhatsApp otomatis
- Export laporan ke PDF/Excel
- Integrasi supplier

### Autentikasi
- Email + password
- Opsi: login dengan Google (versi 2)
- Reset password via email

### Role & Akses
| Role | Akses |
|------|-------|
| Pemilik (Owner) | Semua fitur, termasuk laporan finansial |
| Karyawan (Staff) | Catat penjualan, lihat produk. TIDAK bisa lihat laporan laba rugi |

### Non-Functional
| Aspek | Target |
|-------|--------|
| Estimasi pengguna bulan 1 | < 100 orang |
| Data sensitif | Ya (data finansial, kontak pelanggan) |
| Mode offline | Tidak (cloud-based) |

### Out of Scope
- Tidak ada payment gateway internal di versi 1
- Tidak ada integrasi media sosial
- Tidak ada live chat
- Tidak ada aplikasi native (install dari Play Store/App Store)

---

## 3. Core Features

### Fitur Utama

#### F1: Dashboard Ringkasan
- **User story**: Sebagai pemilik warung, saya ingin melihat ringkasan penjualan hari ini saat buka aplikasi, supaya tahu performa harian.
- **Alur**: User login → otomatis diarahkan ke dashboard
- **Output**: Kartu ringkasan (penjualan hari ini, jumlah transaksi, produk terlaris, utang jatuh tempo)
- **Prioritas**: Must-have

#### F2: Catat Penjualan
- **User story**: Sebagai pemilik/karyawan warung, saya ingin mencatat penjualan dengan cepat, supaya tidak mengganggu antrian pelanggan.
- **Alur**: Klik "Catat Penjualan" → pilih produk dari katalog (atau input manual) → masukkan jumlah → sistem hitung total → pilih metode bayar (tunai/utang) → simpan
- **Output**: Struk digital, stok terupdate, masuk ke laporan
- **Prioritas**: Must-have

#### F3: Kelola Produk (Katalog)
- **User story**: Sebagai pemilik warung, saya ingin mengelola daftar produk dan harganya, supaya saat catat penjualan tinggal pilih.
- **Alur**: Buka menu Produk → tambah/edit/hapus produk → set nama, harga, stok awal
- **Output**: Daftar produk yang bisa dipilih saat catat penjualan
- **Prioritas**: Must-have

#### F4: Laporan Laba Rugi
- **User story**: Sebagai pemilik warung, saya ingin melihat laporan laba rugi periode tertentu, supaya tahu apakah usaha saya untung atau rugi.
- **Alur**: Buka menu Laporan → pilih periode (mingguan/bulanan) → sistem generate ringkasan
- **Output**: Total pendapatan, total modal, laba bersih, grafik tren
- **Prioritas**: Must-have

#### F5: Utang Piutang
- **User story**: Sebagai pemilik warung, saya ingin mencatat utang piutang pelanggan, supaya tidak lupa siapa berhutang berapa.
- **Alur**: Buka menu Utang → tambah transaksi utang (nama pelanggan, jumlah, jatuh tempo) → sistem ingatkan saat jatuh tempo
- **Output**: Daftar utang piutang, notifikasi jatuh tempo
- **Prioritas**: Must-have

### Fitur Pendukung
- Pencarian produk (Prioritas: Sedang)
- Filter laporan by kategori (Prioritas: Rendah)
- Dark mode (Prioritas: Rendah)

### Notifikasi
- Email saat laporan bulanan tersedia
- Pengingat utang jatuh tempo (dashboard notification)

---

## 4. User Flow

### First-Time User
1. User buka website → lihat halaman landing
2. User klik "Daftar Gratis"
3. User isi: nama, email, password, nama warung
4. Sistem kirim email verifikasi
5. User verifikasi → masuk ke onboarding wizard
6. Wizard: pilih kategori warung, input produk awal (atau skip)
7. User masuk ke dashboard (kosong + panduan tooltip)
8. User catat transaksi pertama

### Happy Path (Alur Utama)
1. User buka aplikasi → login → dashboard
2. User klik "Catat Penjualan"
3. User pilih produk dari katalog (search/filter)
4. User masukkan jumlah per produk
5. Sistem hitung total otomatis
6. User pilih metode: tunai / utang
7. Jika utang → input nama pelanggan + jatuh tempo
8. User konfirmasi → transaksi tersimpan
9. Stok produk terupdate
10. User kembali ke dashboard, lihat penjualan terupdate

### Alur Sekunder
1. **Cek Laporan**: Dashboard → Laporan → Pilih periode → Lihat grafik & angka
2. **Tambah Produk**: Dashboard → Produk → Tambah → Isi form → Simpan
3. **Kelola Utang**: Dashboard → Utang → Lihat daftar / Tambah baru

### Error & Edge Case
| Skenario | Yang Terjadi | Yang User Bisa Lakukan |
|----------|-------------|----------------------|
| Internet putus saat catat penjualan | Form tetap terisi, tombol simpan disable dengan pesan "Koneksi terputus, data akan tersimpan saat online" | Tunggu koneksi kembali, data tidak hilang |
| Input harga negatif atau jumlah 0 | Validasi inline: "Jumlah harus lebih dari 0" | Perbaiki input, tidak bisa simpan sampai valid |
| Stok produk habis saat catat | Warning: "Stok [produk] tersisa X. Lanjutkan?" | Lanjutkan (stok minus) atau ubah jumlah |
| Lupa password | Klik "Lupa password" di halaman login → input email → terima link reset | Reset password via email |

---

## 5. Architecture

### Tipe Aplikasi
Cloud-based web application. Data tersimpan online, bisa diakses dari mana saja.

### Integrasi Pihak Ketiga
| Service | Tujuan | Prioritas |
|---------|--------|-----------|
| Email Service (Resend/Nodemailer) | Kirim email verifikasi & laporan | Wajib |
| Cloudinary / S3 | Simpan foto produk | Opsional (versi 2) |

### Admin Dashboard
Tidak ada dashboard admin terpisah. Owner role di aplikasi utama sudah mencakup semua akses manajemen.

### Skala
- Pengguna aktif target (1 tahun): 500-1000 pemilik warung
- Data per user per hari: 10-30 transaksi

---

## 6. Database Schema

### Entitas Utama

#### E1: User
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| id | UUID | Ya | Primary key |
| name | String | Ya | Nama lengkap |
| email | String | Ya | Unique, untuk login |
| password | String | Ya | Hashed (bcrypt) |
| role | Enum | Ya | 'owner' atau 'staff' |
| warung_name | String | Ya | Nama warung |
| created_at | Timestamp | Ya | Otomatis |

#### E2: Product
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| id | UUID | Ya | Primary key |
| user_id | UUID | Ya | FK ke User (owner) |
| name | String | Ya | Nama produk |
| price | Integer | Ya | Harga jual (rupiah) |
| cost | Integer | Ya | Harga modal (rupiah) |
| stock | Integer | Ya | Stok saat ini |
| category | String | Tidak | Kategori produk |
| created_at | Timestamp | Ya | Otomatis |

#### E3: Transaction
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| id | UUID | Ya | Primary key |
| user_id | UUID | Ya | FK ke User |
| total | Integer | Ya | Total transaksi |
| payment_method | Enum | Ya | 'cash' atau 'debt' |
| created_at | Timestamp | Ya | Otomatis |

#### E4: TransactionItem
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| id | UUID | Ya | Primary key |
| transaction_id | UUID | Ya | FK ke Transaction |
| product_id | UUID | Ya | FK ke Product |
| quantity | Integer | Ya | Jumlah beli |
| subtotal | Integer | Ya | price × quantity |

#### E5: Debt
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| id | UUID | Ya | Primary key |
| user_id | UUID | Ya | FK ke User |
| customer_name | String | Ya | Nama pelanggan |
| amount | Integer | Ya | Jumlah utang |
| due_date | Date | Tidak | Jatuh tempo |
| status | Enum | Ya | 'unpaid' atau 'paid' |
| transaction_id | UUID | Tidak | FK ke Transaction |

### Relasi
| Dari | Ke | Tipe | Catatan |
|------|-----|------|---------|
| User | Product | One-to-Many | Satu user punya banyak produk |
| User | Transaction | One-to-Many | Satu user punya banyak transaksi |
| Transaction | TransactionItem | One-to-Many | Satu transaksi punya banyak item |
| Product | TransactionItem | One-to-Many | Satu produk bisa ada di banyak transaksi |
| User | Debt | One-to-Many | Satu user punya banyak catatan utang |
| Transaction | Debt | One-to-One | Transaksi utang terkait dengan satu debt record |

### Penyimpanan
- Permanen: Semua entitas (User, Product, Transaction, TransactionItem, Debt)
- Tidak ada data sementara yang perlu di-cache di versi 1

---

## 7. Tech Stack

### Frontend
| Komponen | Teknologi | Justifikasi |
|----------|-----------|-------------|
| Framework | Next.js 14+ (App Router) | SSR + SEO friendly, ecosystem matang |
| Styling | Tailwind CSS | Utility-first, cepat iterasi, konsisten |
| State | Zustand + React Query | Lightweight, server state terpisah |
| UI Components | shadcn/ui | Customizable, accessible, terintegrasi Tailwind |

### Backend
| Komponen | Teknologi | Justifikasi |
|----------|-----------|-------------|
| Runtime | Node.js (Next.js API Routes / Route Handlers) | Satu repo dengan frontend, deploy sekali |
| Database | PostgreSQL (Supabase / Neon) | Relational cocok untuk data finansial, free tier cukup |
| Auth | Better Auth | Type-safe, support email+password, OAuth ready |
| ORM | Drizzle ORM | Type-safe, lightweight, migration tool bagus |
| Validation | Zod | Schema validation, terintegrasi Drizzle |

### Infrastruktur
| Komponen | Service | Tier | Estimasi Biaya |
|----------|---------|------|----------------|
| Hosting | Vercel | Free (Hobby) | Rp 0/bulan |
| Database | Supabase | Free (500MB) | Rp 0/bulan |
| Email | Resend | Free (3000/bulan) | Rp 0/bulan |
| Domain | .com | — | ~Rp 150.000/tahun |

**Total estimasi bulan 1-3**: Rp 0 (semua free tier)

### Integrasi
| Service | Provider | Status |
|---------|----------|--------|
| Email | Resend | Akan diintegrasikan (Fase 1) |

### Constraint & Catatan
- Tidak ada preferensi teknologi spesifik
- Budget hosting: gratis untuk mulai, bisa upgrade saat user tumbuh
- Timeline: 3-4 bulan untuk versi 1
- Semua dalam monorepo (frontend + backend di Next.js)

---

> **Status dokumen**: DRAFT — menunggu konfirmasi final.
> Setelah disetujui, lanjut ke Implementation Plan → Task Breakdown → Wireframe.
