# Question Bank — Bank Pertanyaan Adaptive PRD Builder

File ini berisi semua pertanyaan guided untuk Phase 1 (PRD Builder). Setiap section memiliki:
- **Pertanyaan wajib** — HARUS ditanyakan
- **Pertanyaan kondisional** — muncul berdasarkan jawaban sebelumnya
- **Branching logic** — arah pertanyaan selanjutnya
- **Format AskUserQuestion** — opsi interaktif untuk setiap pertanyaan

**Aturan eksekusi**: Tanyakan SATU pertanyaan per giliran menggunakan tool `AskUserQuestion`. Setelah jawaban, tentukan pertanyaan berikutnya berdasarkan branching logic.

---

## Cara Baca Format AskUserQuestion di File Ini

Setiap pertanyaan di bawah sudah disertai blok `AskUserQuestion` yang bisa langsung dieksekusi. Formatnya:

```
**AskUserQuestion:**
question: "[Teks pertanyaan yang muncul di kartu]"
header: "[Label chip, maks 12 karakter]"
multiSelect: false
options:
  - label: "[Opsi 1]"
    description: "[Penjelasan opsi 1]"
  - label: "[Opsi 2]"
    description: "[Penjelasan opsi 2]"
  - label: "[Opsi 3]"
    description: "[Penjelasan opsi 3]"
```

**Pengecualian**: Pertanyaan bertanda `[CHAT BIASA]` boleh ditanyakan sebagai teks biasa karena jawabannya bersifat naratif panjang.

---

---

## Section 1: Overview

**Tujuan section**: Memahami gambaran besar — apa aplikasinya, untuk siapa, dan kenapa perlu dibuat.

### Q1.1 — Deskripsi Satu Kalimat (Wajib) `[CHAT BIASA]`

**Tujuan**: Memastikan kita dan user punya pemahaman yang sama tentang apa yang dibangun.

**Pertanyaan**:
> "Kalau dalam satu kalimat, aplikasi ini bikin apa untuk siapa?
> Contoh: 'Sebuah aplikasi yang membantu pemilik warung mencatat penjualan harian dari HP mereka.'"

💡 **Tips**: Bayangkan kamu lagi pitch ide ke teman di kedai kopi. Satu kalimat, langsung jelas.

**AskUserQuestion**: Tidak pakai (jawaban naratif, user perlu mengetik bebas)

**Branching**:
- Jika jawaban mengandung kata "untuk" → lanjut Q1.2
- Jika tidak jelas siapa penggunanya → tanya ulang: "Siapa orang yang akan paling sering pakai aplikasi ini?"

---

### Q1.2 — Target Pengguna (Wajib)

**Tujuan**: Menentukan siapa end-user. Ini memengaruhi semua keputusan desain dan fitur.

**AskUserQuestion:**
```
question: "Siapa orang yang akan paling sering memakai aplikasi ini?"
header: "Target User"
multiSelect: false
options:
  - label: "Pemilik UMKM / Usaha kecil"
    description: "Usaha 1-10 karyawan, mungkin belum terlalu digital"
  - label: "Karyawan perusahaan"
    description: "Digunakan internal di organisasi/perusahaan"
  - label: "Konsumen publik"
    description: "Siapa saja bisa mendaftar dan pakai, seperti e-commerce atau sosial media"
  - label: "Admin / Operator"
    description: "Tim internal yang mengelola data atau operasional"
```

**Branching**:
- Jika ada >1 tipe user → tanya Q1.2b
- Jika 1 tipe user → lanjut Q1.3

### Q1.2b — Prioritas Pengguna (Kondisional)

**Tujuan**: Kalau ada beberapa tipe user, tentukan mana yang paling penting dulu.

**Pertanyaan**:
> "Dari tipe pengguna yang kamu sebut, mana yang PALING penting dilayani duluan di versi pertama?
> Aplikasi sukses biasanya fokus ke 1 tipe user dulu sebelum expand."

---

### Q1.3 — Masalah yang Dipecahkan (Wajib)

**Tujuan**: Memahami motivasi. Tanpa masalah yang jelas, fitur akan kacau.

**Pertanyaan**:
> "Saat ini, masalah apa yang dialami pengguna tanpa aplikasi ini?
> Apa yang susah atau merepotkan bagi mereka?
>
> Contoh: 'Pemilik warung sering lupa catat utang pelanggan karena cuma pakai buku tulis.'

💡 **Tips**: Pikirkan apa yang user lakukan SEKARANG (sebelum aplikasi ini ada). Apa keluhannya?

---

### Q1.4 — Solusi Utama (Wajib)

**Tujuan**: Menyambungkan masalah ke solusi yang ditawarkan aplikasi.

**Pertanyaan**:
> "Aplikasi ini menyelesaikan masalah tadi dengan cara apa?
> Apa yang user BISA LAKUKAN dengan aplikasi ini yang sebelumnya tidak bisa?
>
> Contoh: 'User bisa catat penjualan dari HP, lihat laporan otomatis tiap akhir bulan, dan terima pembayaran QRIS.'"

---

### Q1.5 — Platform (Kondisional, tanya sekali di awal)

**Tujuan**: Menentukan medium aplikasi. Ini memengaruhi arsitektur dan tech stack.

**AskUserQuestion:**
```
question: "Aplikasi ini akan diakses lewat mana?"
header: "Platform"
multiSelect: false
options:
  - label: "Website (Browser)"
    description: "Dibuka lewat browser HP atau komputer, tidak perlu install"
  - label: "Mobile App (Install)"
    description: "Diinstall di HP — Android dan/atau iOS"
  - label: "Desktop App"
    description: "Diinstall di komputer (Windows/Mac/Linux)"
  - label: "Kombinasi"
    description: "Web + mobile app, atau web + desktop, dll"
```

💡 **Tips**: Untuk mulai, pilih satu. Lebih mudah expand kemudian daripada bangun semuanya sekaligus.

---

## Section 2: Requirements

**Tujuan section**: Membedakan mana yang HARUS ada (versi pertama) vs yang bisa nanti. Mencegah scope creep.

### Q2.1 — Must-Have vs Nice-to-Have (Wajib)

**Tujuan**: Membantu user memprioritaskan. Awam cenderung mau semuanya sekaligus.

**AskUserQuestion:**
```
question: "Untuk versi pertama, gimana cara kamu memisahkan fitur wajib dan fitur yang bisa ditunda?"
header: "Prioritas"
multiSelect: false
options:
  - label: "Saya sudah tau mana yang wajib"
    description: "Saya punya daftar fitur yang HARUS ada dan yang bisa nanti"
  - label: "Bantu saya pisahkan"
    description: "Saya punya banyak ide tapi bingung mana yang duluan — bantu saya prioritas"
  - label: "Semuanya penting menurut saya"
    description: "Semua fitur yang saya pikirkan rasanya harus ada semua"
```

💡 **Tips**: Kurangi, jangan tambah. Versi pertama yang sederhana tapi jalan lebih baik daripada versi "lengkap" yang tidak selesai-selesai.

---

### Q2.2 — Login & Autentikasi (Wajib)

**Tujuan**: Auth adalah fondasi. Hampir semua aplikasi butuh ini.

**AskUserQuestion:**
```
question: "Apakah pengguna perlu login sebelum bisa menggunakan aplikasi?"
header: "Login"
multiSelect: false
options:
  - label: "Wajib login dulu"
    description: "Tidak bisa akses fitur apapun tanpa login terlebih dahulu"
  - label: "Sebagian perlu login"
    description: "Beberapa fitur bisa diakses tanpa login, fitur tertentu perlu login"
  - label: "Tidak perlu login"
    description: "Semua fitur bisa digunakan tanpa perlu buat akun / login"
```

**Jika user pilih login wajib atau sebagian, tanya lanjutan:**

**AskUserQuestion:**
```
question: "Mau pakai cara login apa?"
header: "Cara Login"
multiSelect: true
options:
  - label: "Email + Password"
    description: "Cara klasik — daftar pakai email, login pakai password"
  - label: "Google / Social login"
    description: "Login cepat pakai akun Google, Facebook, atau lainnya"
  - label: "Nomor HP + OTP"
    description: "Login pakai nomor HP, verifikasi via SMS / WhatsApp OTP"
  - label: "Belum kepikiran"
    description: "Serahkan rekomendasi ke saya berdasarkan jenis aplikasinya"
```

---

### Q2.3 — Multi-user / Role (Kondisional)

**Tujuan**: Menentukan apakah ada konsep role/permission.

**Tanya JIKA** Q1.2 menyebutkan >1 tipe user.

**Pertanyaan**:
> "Apakah ada perbedaan akses antar tipe pengguna?
> Contoh: Admin bisa lihat semua data, user biasa hanya lihat datanya sendiri.
>
> - Ya, ada beberapa role (sebutkan)
> - Tidak, semua pengguna sama
> - Belum kepikiran"

---

### Q2.4 — Non-Functional Requirements (Wajib, sederhana)

**Tujuan**: Performance, skala, keamanan — tapi disederhanakan untuk awam.

**AskUserQuestion:**
```
question: "Perkiraan berapa banyak pengguna di bulan pertama?"
header: "Skala User"
multiSelect: false
options:
  - label: "< 100 orang"
    description: "Penggunaan terbatas, mungkin hanya tim kecil atau beta tester"
  - label: "100 - 1.000 orang"
    description: "Pengguna awal yang cukup untuk validate ide"
  - label: "1.000 - 10.000 orang"
    description: "Pengguna cukup banyak, perlu infrastruktur yang solid"
  - label: "> 10.000 orang"
    description: "Besar sejak awal, perlu arsitektur yang scalable"
```

**Jika user jawab > 1000, tanya lanjutan:**

**AskUserQuestion:**
```
question: "Apakah ada data sensitif yang perlu dilindungi?"
header: "Data Sensitif"
multiSelect: true
options:
  - label: "Ada data finansial"
    description: "Transaksi, harga, nomor rekening, dll"
  - label: "Ada data pribadi (PII)"
    description: "KTP, alamat, nomor HP, data medis, dll"
  - label: "Tidak ada data sensitif"
    description: "Data bersifat umum dan tidak berisiko jika bocor"
```

**Tanya juga:**

**AskUserQuestion:**
```
question: "Apakah aplikasi perlu bisa jalan tanpa internet (offline)?"
header: "Offline"
multiSelect: false
options:
  - label: "Perlu offline"
    description: "Harus bisa dipakai tanpa internet, data sync saat online lagi"
  - label: "Tidak perlu"
    description: "Selalu butuh koneksi internet, data tersimpan online"
  - label: "Sebagian offline"
    description: "Fitur tertentu bisa offline, tapi fitur utama butuh online"
```

---

### Q2.5 — Out of Scope (Wajib)

**Tujuan**: Eksplisit nyatakan apa yang TIDAK akan dibuat. Sama pentingnya dengan yang akan dibuat.

**Pertanyaan**:
> "Hal apa yang kamu pikir TIDAK akan ada di aplikasi ini?
> Atau hal yang orang sering minta tapi kamu tidak mau masukkan?
>
> Contoh: 'Tidak ada live chat', 'Tidak ada integrasi media sosial', 'Tidak ada fitur pembayaran internal'"

💡 **Tips**: Menulis apa yang TIDAK ada sama pentingnya dengan menulis apa yang ada. Mencegah ekspektasi tidak realistis.

---

## Section 3: Core Features

**Tujuan section**: Identifikasi 3-7 fitur utama yang menjadi alasan orang pakai aplikasi.

### Q3.1 — Fitur Wajib (Wajib)

**Tujuan**: Mendapatkan daftar fitur inti dari user.

**Pertanyaan**:
> "Sebutkan 3 sampai 7 fitur UTAMA yang harus ada di versi pertama.
> Format: 'User bisa [melakukan apa]'
>
> Contoh untuk aplikasi catatan warung:
> 1. User bisa mencatat penjualan harian
> 2. User bisa melihat laporan laba rugi mingguan
> 3. User bisa mencatat utang piutang pelanggan
> 4. User bisa menerima pembayaran QRIS"

💡 **Tips**: Mulai dari kata kerja. Fokus pada APA yang user bisa lakukan, bukan BAGAIMANA.

---

### Q3.2 — Detail per Fitur (Wajib)

**Tujuan**: Setiap fitur butuh detail agar bisa diimplementasi.

**Untuk SETIAP fitur yang disebut Q3.1, tanya**:

> "Untuk fitur '[nama fitur]', tolong jelaskan sedikit:
> - Apa yang user lakukan step by step?
> - Apa hasil yang user lihat setelah pakai fitur ini?
> - Apakah ada batasan? (contoh: maksimal 10 item per transaksi)"

**Branching**: Setelah detail semua fitur, lanjut Q3.3.

---

### Q3.3 — Fitur Pendukung (Kondisional)

**Tujuan**: Fitur yang BAGUS dimiliki tapi bukan alasan utama orang pakai.

**Pertanyaan**:
> "Selain fitur utama tadi, ada fitur pendukung yang kamu mau?
> Contoh: notifikasi, pencarian, filter, export data, dark mode
>
> Kalau ada, mana yang penting dan mana yang hanya 'nice to have'?"

---

### Q3.4 — Notifikasi & Komunikasi (Kondisional)

**Tanya JIKA** aplikasi melibatkan transaksi, pesan, atau update berkala.

**Pertanyaan**:
> "Apakah aplikasi perlu mengirim notifikasi atau pesan ke pengguna?
> - Push notification di HP
> - Email otomatis
> - WhatsApp/SMS
> - Tidak perlu
>
> Kalau ya, event apa yang trigger notifikasi?
> Contoh: 'Kirim email saat transaksi berhasil', 'Push notif saat ada pesanan baru'"

---

## Section 4: User Flow

**Tujuan section**: Bayangkan pengguna memakai aplikasi dari awal sampai tujuan tercapai.

### Q4.1 — First-Time User Experience (Wajib)

**Tujuan**: Onboarding adalah kesan pertama. Sering diabaikan tapi krusial.

**Pertanyaan**:
> "Bayangkan user baru pertama kali buka aplikasi.
> Langkah apa yang dia lalui dari buka sampai bisa pakai?
>
> Contoh:
> 1. User buka aplikasi → lihat layar welcome
> 2. User daftar akun (email + password)
> 3. User isi profil dasar (nama, jenis usaha)
> 4. User lihat dashboard kosong + tutorial singkat
> 5. User mulai catat transaksi pertama"

💡 **Tips**: Pikirkan pengalaman kamu pertama kali pakai aplikasi baru. Apa yang membantu? Apa yang bikin bingung?

---

### Q4.2 — Happy Path — Alur Utama (Wajib)

**Tujuan**: Alur yang paling sering dilakukan user. Ini jantung aplikasi.

**Pertanyaan**:
> "Apa alur utama yang paling sering dilakukan user?
> Dari buka aplikasi sampai selesai dengan sukses.
>
> Contoh untuk aplikasi warung:
> 1. User buka aplikasi → langsung ke dashboard
> 2. User klik 'Catat Penjualan'
> 3. User pilih produk / input manual
> 4. User masukkan jumlah
> 5. Sistem hitung total
> 6. User pilih metode bayar (tunai/QRIS)
> 7. Transaksi tersimpan, stok terupdate
> 8. User kembali ke dashboard, lihat penjualan hari ini"

---

### Q4.3 — Alur Sekunder (Kondisional)

**Tujuan**: Selain alur utama, apa alur lain yang sering dipakai?

**Pertanyaan**:
> "Selain alur utama tadi, ada alur lain yang cukup sering dipakai?
> Contoh: cek laporan, kelola produk, ubah pengaturan, invite anggota tim"

---

### Q4.4 — Error & Edge Case (Wajib)

**Tujuan**: Apa yang terjadi ketika hal tidak sesuai rencana.

**Pertanyaan**:
> "Beberapa skenario ketika hal tidak berjalan mulus — apa yang seharusnya terjadi?
> 1. User isi form tapi koneksi internet putus di tengah?
> 2. User input data salah (contoh: harga negatif, tanggal lampau)?
> 3. User mau batal di tengah proses?
> 4. User lupa password?
>
> Tidak perlu detail teknis. Cukup: apa yang user LIHAT dan BISA LAKUKAN."

💡 **Tips**: Pikirkan 3-5 skenario yang paling mungkin terjadi. Ini mencegah frustrasi pengguna.

### Q4.5 — Edge State per Fitur (Wajib — Anti-Slop)

**Tujuan**: Setiap layar punya kondisi kosong, loading, dan error yang HIDUP — bukan teks generik "No data" atau "Something went wrong". Ini pembeda aplikasi terasa handcrafted vs template.

**Pertanyaan**:
> "Bayangkan fitur utama tadi dalam 3 kondisi:
> 1. **Kosong** — user baru, belum ada data sama sekali. Apa yang dia lihat? Apa yang bisa dia lakukan dari situ?
>    (Contoh baik: 'Belum ada proyek. Mulai dari template atau buat dari nol.' + tombol aksi)
>    (Contoh buruk: 'No data found')
> 2. **Menunggu** — data sedang dimuat. Spinner polos atau tampilan lain?
> 3. **Gagal** — data gagal dimuat. Apa pesan yang membantu user mengatasi?"

💡 **Tips**: Format jawaban per fitur: `[Fitur] kosong → [pesan + aksi] / menunggu → [tampilan] / gagal → [pesan + aksi]`. Agent akan bantu polish kata-katanya supaya natural dalam Bahasa Indonesia.

---

## Section 5: Architecture

**Tujuan section**: Struktur sistem di balik layar. Disederhanakan untuk non-teknis.

### Q5.1 — Integrasi Pihak Ketiga (Wajib)

**Tujuan**: Apakah aplikasi butuh connect ke service lain?

**Pertanyaan**:
> "Apakah aplikasi perlu terhubung dengan service/platform lain?
> Contoh:
> - Payment gateway (Midtrans, Xendit, Stripe)
> - Google Maps (untuk lokasi)
> - Media sosial (login, share)
> - Email service (kirim email otomatis)
> - Cloud storage (simpan file/gambar)
> - Tidak ada

💡 **Tips**: Kalau ragu, sebutkan saja idenya. Detail teknisnya bisa dikonfirmasi nanti.

---

### Q5.2 — Tipe Aplikasi (Wajib)

**Tujuan**: Menentukan arsitektur dasar.

**AskUserQuestion:**
```
question: "Bagaimana aplikasi ini menyimpan data dan bisa diakses?"
header: "Tipe App"
multiSelect: false
options:
  - label: "Online (Cloud)"
    description: "Data tersimpan online, bisa diakses dari mana saja dengan internet"
  - label: "Offline (Local)"
    description: "Data tersimpan di device/user, bisa dipakai tanpa internet"
  - label: "Hybrid (Online + Offline)"
    description: "Utama online, tapi bisa tetap jalan saat offline sementara"
```

💡 **Tips**: Kalau bingung, aplikasi yang dipakai BANYAK ORANG BERSAMAAN biasanya cloud-based (online).

---

### Q5.3 — Admin/Dashboard Backend (Kondisional)

**Tanya JIKA** Q1.2 menyebutkan admin/operator.

**Pertanyaan**:
> "Apakah perlu dashboard khusus untuk admin/manager?
> Yang bisa:
> - Lihat semua data pengguna
> - Kelola pengguna (tambah, hapus, suspend)
> - Lihat laporan agregat
> - Konfigurasi sistem

---

### Q5.4 — Skala & Performance (Sederhana)

**Tujuan**: Ekspektasi beban sistem.

**Pertanyaan**:
> "Dalam setahun ke depan, berapa perkiraan:
> - Jumlah pengguna aktif: ___ orang
> - Data per pengguna per hari: ___ (contoh: 5 transaksi, 10 posting)
>
> Ini untuk memastikan sistem cukup kuat dari awal."

---

## Section 6: Database Schema

**Tujuan section**: Identifikasi data apa yang perlu disimpan. Disederhanakan jadi "informasi apa yang aplikasi ingat".

### Q6.1 — Entitas Utama (Wajib)

**Tujuan**: Identifikasi "benda" utama yang aplikasi simpan.

**Pertanyaan**:
> "Informasi utama apa yang aplikasi ini perlu simpan?
> Bayangkan aplikasi sebagai 'lemari arsip' — apa saja yang masuk ke dalamnya?
>
> Contoh untuk aplikasi warung:
> - Data Pengguna (nama, email, nomor HP, nama usaha)
> - Data Produk (nama produk, harga, stok)
> - Data Transaksi (tanggal, total, metode bayar)
> - Data Pelanggan (nama, kontak, utang)
>
> Sebutkan saja, tidak perlu detail kolomnya."

💡 **Tips**: Setiap "benda" yang punya atribut sendiri biasanya jadi entitas. "User" punya nama+email. "Produk" punya nama+harga. Kalau cuma punya 1 atribut, mungkin bukan entitas terpisah.

---

### Q6.2 — Detail per Entitas (Wajib)

**Tujuan**: Untuk setiap entitas di Q6.1, kumpulkan atributnya.

**Untuk SETIAP entitas, tanya**:

> "Untuk [nama entitas], informasi apa saja yang perlu disimpan?
>
> Contoh untuk 'Data Produk':
> - Nama produk
> - Harga jual
> - Stok tersedia
> - Kategori
> - Foto produk
> - Deskripsi"

---

### Q6.3 — Relasi Antar Entitas (Wajib, disederhanakan)

**Tujuan**: Hubungan antar data.

**Pertanyaan**:
> "Bagaimana hubungan antar data yang kamu sebut?
>
> Pakai pertanyaan ini untuk setiap pasangan:
> - Satu pengguna punya berapa banyak [entitas]? (contoh: 1 user punya banyak produk)
> - Satu [entitas] milik berapa banyak pengguna? (contoh: 1 produk milik 1 user)
>
> Tidak yakin? Sebutkan saja idenya, kita bantu susun."

💡 **Tips**:
- "Satu user punya BANYAK produk" = One-to-Many
- "Satu transaksi bisa punya BANYAK produk, satu produk bisa ada di BANYAK transaksi" = Many-to-Many
- Kalau ragu, gambar di kertas lebih mudah.

---

### Q6.4 — Data yang Perlu Disimpan Permanen vs Sementara (Kondisional)

**Tanya JIKA** ada data yang mungkin sementara (cache, draft, log).

**Pertanyaan**:
> "Apakah ada data yang hanya perlu disimpan sementara?
> Contoh:
> - Draft yang belum disimpan user
> - Notifikasi yang sudah dibaca (bisa dihapus setelah X hari)
> - Log aktivitas (perlu disimpan berapa lama?)
>
> Atau semua data perlu disimpan permanen?"

---

## Section 7: Tech Stack

**Tujuan section**: Pilih teknologi. Sebagian besar akan DIREKOMENDASIKAN berdasarkan jawaban section sebelumnya.

### Q7.1 — Preferensi Teknologi (Wajib)

**Tujuan**: Cek apakah user punya preferensi atau constraint.

**Pertanyaan**:
> "Apakah ada teknologi, bahasa, atau framework spesifik yang kamu ingin pakai atau HINDARI?
> - Punya preferensi (sebutkan)
> - Tidak ada preferensi, rekomendasikan saja yang terbaik
> - Ada yang harus dihindari (sebutkan dan kenapa)"

---

### Q7.2 — Budget & Constraint (Kondisional)

**Tanya JIKA** user non-teknis sepenuhnya.

**Pertanyaan**:
> "Beberapa constraint yang perlu kita tahu:
> 1. Apakah ada budget khusus untuk hosting/infrastruktur per bulan?
>    - Gratis saja yang ada (tier gratis)
>    - Bisa bayar sampai Rp ___ per bulan
>    - Fleksibel, sesuai kebutuhan
> 2. Apakah ada timeline target untuk versi pertama?
>    - Perlu cepat (1-2 bulan)
>    - Wajar (3-6 bulan)
>    - Tidak terburu-buru"

---

### Q7.3 — Konfirmasi Tech Stack (Otomatis)

**Aksi**: Berdasarkan semua jawaban, REKOMENDASIKAN tech stack lengkap.

**Logika rekomendasi**:

| Jika | Rekomendasi |
|------|-------------|
| Website + cloud-based | Frontend: React/Next.js, Backend: Node.js/Express atau Laravel |
| Mobile app Android | React Native / Flutter |
| Mobile app iOS+Android | React Native / Flutter |
| Desktop app | Electron / Tauri |
| Perlu real-time | WebSocket / Socket.io |
| Perlu pembayaran | Midtrans / Xendit (Indonesia), Stripe (international) |
| Perlu maps | Google Maps API / Mapbox |
| Database sederhana | PostgreSQL / MySQL |
| Database cepat + cache | Redis (tambahan) |
| Cloud hosting budget kecil | Vercel / Railway / Vercel + Supabase |
| Cloud hosting enterprise | AWS / GCP |

**Output**: Tampilkan tabel tech stack dengan justifikasi singkat. Tanya: "Tech stack ini oke? Atau ada yang mau diubah?"

---

## Section 8: Design System (Anti-Slop — WAJIB sebelum desain/coding)

**Tujuan section**: Mencegah desain generik ala AI ("AI Slop"). Semua keputusan desain ditetapkan EKSPLISIT di sini — bukan ditebak saat coding. Kalau user tidak tahu jawabannya, tawarkan referensi (cara cepat: "seperti aplikasi X").

**Aturan emas section ini**: Deskripsi verbal menghasilkan output generik; referensi konkret menghasilkan output tertarget. Selalu dorong user ke referensi.

**Output akhir section ini adalah DESIGN TOKENS 3 TINGKAT** (standar industri, sejalan W3C DTCG):

| Tingkat | Apa itu | Contoh | Aturan pakai |
|---------|---------|--------|--------------|
| **1. Primitif** | Nilai mentah palet — punya nama, belum punya makna | `biru-600: #1d4ed8`, `abu-100: #f3f4f6`, `spacing-4: 16px` | DILARANG dipakai langsung di komponen |
| **2. Semantik** | Peran/makna dalam produk — merujuk primitif | `action-primary → biru-600`, `text-body → abu-800`, `surface-card → putih` | Satu-satunya yang boleh dipakai di UI; nilainya swap otomatis saat mode terang/gelap |
| **3. Komponen** | Ikatan ke komponen spesifik | `button-primary-bg → action-primary`, `card-radius → radius-md` | Opsional; hanya untuk komponen yang butuh nilai khusus |

**Kenapa 3 tingkat**: ganti tema = cukup tukar rujukan tingkat 2 (satu tempat); ganti warna brand = sentuh primitif saja; komponen tidak pernah tahu nilai hex — semua konsep "ganti sekali, berubah semua". Ini juga bahasa asli Tailwind (`@theme` → CSS variables) dan shadcn/ui (`--primary`, `--background`).

### Q8.1 — Kepribadian Visual / Vibe (Wajib)

**Tujuan**: Menentukan arah estetika keseluruhan. Ini keputusan paling berdampak — semua detail lain mengikuti.

**AskUserQuestion:**
```
question: "Kalau aplikasi ini adalah orang, kepribadiannya seperti apa? (Ini menentukan nuansa visual keseluruhan)"
header: "Vibe"
multiSelect: false
options:
  - label: "Minimalis premium"
    description: "Tenang, presisi, elegan — seperti Linear.app, Vercel.com, atau Apple. Cocok untuk SaaS/tool profesional"
  - label: "Terpercaya & korporat"
    description: "Serius, aman, berwibawa — seperti Stripe.com. Cocok untuk fintech, B2B, enterprise"
  - label: "Ramah & menyenangkan"
    description: "Hangat, playful, mudah didekati — seperti Duolingo atau Notion. Cocok untuk konsumen umum"
  - label: "Editorial/majalah"
    description: "Berkarakter kuat, tipografi menonjol — seperti Framer atau situs pemenang Awwwards. Cocok untuk konten & kreatif"
```

**Branching**:
- Jawaban apapun → lanjut Q8.2 (konfirmasi via referensi konkret)
- User menyebut aplikasi lain ("seperti Gojek") → catat sebagai referensi utama

### Q8.2 — Referensi Konkret (Wajib)

**Tujuan**: Referensi lebih akurat daripada deskripsi. "Layout seperti Linear" lebih berguna daripada "desain modern".

**Pertanyaan** `[CHAT BIASA]`:
> "Sebutkan 1-3 website/aplikasi yang tampilannya kamu SUKA dan cocok dengan vibe tadi.
> Boleh aplikasi lokal (Gojek, Tokopedia, dll) atau internasional.
>
> Kalau punya screenshot tampilan yang kamu suka, kirim saja — saya bisa analisis detailnya (warna, font, tata letak) langsung dari gambarnya."

**Aksi agent**: Jika user mengirim screenshot → WAJIB analisis via `ui_to_artifact` / `analyze_image` (mcp_zai-vision) untuk ekstrak design tokens, lalu konfirmasi hasil ekstrak ke user.

### Q8.3 — Mode Terang/Gelap (Wajib)

**AskUserQuestion:**
```
question: "Aplikasi ini tampil dalam mode terang, gelap, atau keduanya?"
header: "Mode Warna"
multiSelect: false
options:
  - label: "Terang saja"
    description: "Latar putih/terang — bersih dan familiar. Lebih cepat dikerjakan"
  - label: "Gelap saja"
    description: "Latar gelap — kesan premium, nyaman di mata untuk pemakaian lama"
  - label: "Keduanya + toggle"
    description: "Terang dan gelap, user bisa ganti. Ikuti preferensi sistem. (Effort lebih besar ±20%)"
```

### Q8.4 — Warna Identitas (Wajib)

**Tujuan**: Satu warna utama (primary) + satu aksen. Bukan pelangi.

**AskUserQuestion:**
```
question: "Warna identitas utama aplikasi? (Pilih yang paling dekat — bisa di-detail nanti)"
header: "Warna"
multiSelect: false
options:
  - label: "Biru — profesional"
    description: "Kesan tepercaya dan tenang. Aman untuk hampir semua industri"
  - label: "Hijau — tumbuh/sehat"
    description: "Kesan segar, alami, atau finansial (uang). Cocok UMKM, kesehatan, lingkungan"
  - label: "Merah/oranye — berani"
    description: "Kesan energi dan semangat. Memancing aksi. Cocok marketplace, kuliner"
  - label: "Sudah punya brand"
    description: "Ada logo/warna brand sendiri — sebutkan kode warnanya (contoh: #1a5c2e)"
```

**Aksi agent**: Dari jawaban + vibe, agent tetapkan hex code konkret: primary, primary-hover, background surface, text utama, text sekunder, aksen feedback (sukses/warning/error). Tampilkan sebagai tabel design tokens untuk konfirmasi.

### Q8.5 — Kepribadian Tipografi (Wajib, disederhanakan)

**Tujuan**: Awam tidak kenal nama font — tanyakan karakternya, agent petakan ke font konkret.

**AskUserQuestion:**
```
question: "Bentuk huruf yang terasa cocok untuk aplikasi ini?"
header: "Tipografi"
multiSelect: false
options:
  - label: "Tegas & serius"
    description: "Bersudut, presisi, teknikal — kesan professional dan modern"
  - label: "Ramah & bulat"
    description: "Sudut membulat, hangat — kesan dekat dan santai"
  - label: "Elegan & editorial"
    description: "Bertitik serif klasik — kesan premium dan berkarakter"
  - label: "Serbaguna standar"
    description: "Netral, aman, mudah dibaca — prioritas keterbacaan"
```

**Aksi agent**: Petakan ke pasangan font konkret DENGAN KARAKTER. **Aturan anti-slop (R-06)**: font yang jadi "bawaan AI" (Inter, Geist, Space Grotesk, Roboto, Arial, system-ui) TIDAK DILARANG mutlak, tapi **WAJIB punya alasan brand tertulis** — bila pakai hanya karena kebiasaan = FAIL. Prioritaskan font berkarakter dari referensi user. Contoh pemetaan (urutan preferensi, mulai dari yang berkarakter):
- Tegas & serius → Heading: Instrument Sans/Archivo; Body: IBM Plex Sans
- Ramah & bulat → Heading: Quicksand/Nunito; Body: Plus Jakarta Sans
- Elegan & editorial → Heading: Instrument Serif/Fraunces; Body: DM Sans
- Serbaguna standar → Heading: Public Sans; Body: Source Sans 3

**Catatan referensi**: bila referensi user adalah Linear/Vercel (yang memang pakai Inter/Geist), pakai font yang sama adalah keputusan brand yang sah — tulis alasannya ("mengikuti referensi X").

Verifikasi ketersediaan font via Context7/Google Fonts sebelum finalisasi. Tampilkan pasangan font untuk konfirmasi.

### Q8.6 — Sudut & Gerakan (Wajib, singkat)

**AskUserQuestion:**
```
question: "Dua detail kecil yang besar pengaruhnya: sudut elemen dan animasi?"
header: "Sudut&Motion"
multiSelect: false
options:
  - label: "Membulat, gerak halus"
    description: "Sudut membulat (8-16px), animasi lembut — kesan ramah dan santai"
  - label: "Kotak tegas, gerak cepat"
    description: "Sudut kecil (2-6px), animasi responsif — kesan presisi dan professional"
  - label: "Campuran sesuai konteks"
    description: "Serahkan ke agent: tombol/input membulat, kartu lebih tegas, gerak menyesuaikan vibe"
```

**Aksi agent**: Selain menetapkan nilai, tetapkan juga **DOSE CAPS** (batas dosis — aturan antislop R-10..R-13, R-19):
- Radius membulat membedakan kategori elemen (tombol ≠ kartu ≠ modal) — DILARANG semua elemen jadi pill sama besar
- Shadow hanya untuk 1–2 elemen yang perlu "terangkat" — mayoritas elemen tetap flat
- Glass/glow maksimal 1–2 elemen; sisanya matte
- Motion: tetapkan dial 1–3 (1 = hover saja, 2 = +transisi state, 3 = +animasi entrance). DILARANG loop/pulse tanpa henti tanpa tujuan

**Output Section 8**: Design tokens 3 tingkat LENGKAP (lihat tabel tingkat di atas) + typography 6 level + color semantic + spacing 8px scale + radius hierarchy + shadow elevation + motion duration+easing + dose caps + dial — ditampilkan sebagai tabel untuk konfirmasi user, lalu disimpan sebagai M012 dan jadi bagian PRD Section 8 + input utama Phase 4 (Design Spec).

**Gate sebelum konfirmasi** (gagal satu = perbaiki dulu): ceklolos daftar tell antislop-ui — tanpa gradient blue-purple default, tanpa glass/glow berlebih, radius/shadow terdosis, palet maks 2–3 warna inti + 1 aksen, mode terang/gelap punya alasan (bukan sekadar "techy"), tipografi bukan pilihan bawaan tanpa alasan.

---

## Catatan untuk Agent

1. **Jangan tampilkan file ini ke user**. File ini referensi internal.
2. **Adaptasi pertanyaan** ke konteks jawaban user. Jangan kaku.
3. **Jika user sudah menjawab** sesuatu di section sebelumnya, jangan tanya ulang.
4. **Skip pertanyaan kondisional** yang tidak relevan berdasarkan jawaban sebelumnya.
5. **Boleh tambah pertanyaan follow-up** jika jawaban user membutuhkan klarifikasi.
6. **Bahasa Indonesia** natural di semua pertanyaan.

---

## Project Memory Trigger Points

Saat menjalankan question flow, agent HARUS membaca dan menulis project memory di momen-momen berikut:

| Momen | Aksi Memory | Detail |
|-------|------------|--------|
| **Sebelum Q1.1** | **BACA** project memory | Cek apakah ada M001 (PRD Status). Jika ada, tampilkan ke user dan tanya: "Sesi lalu kita sudah sampai [section/phase]. Lanjut dari situ atau mulai baru?" |
| **Setelah user konfirmasi Section 1** | **TULIS** M002 (Deskripsi) + M003 (Masalah & Solusi) | Ringkas jawaban user, maks 400 karakter per entry |
| **Setelah user konfirmasi Section 2** | **TULIS** M004 (Must-Have) + M005 (Role & Auth) | |
| **Setelah user konfirmasi Section 3** | **TULIS** M006 (Core Features) | |
| **Setelah user konfirmasi Section 4** | **TULIS** M007 (Alur Pengguna) | |
| **Setelah user konfirmasi Section 5** | **TULIS** M008 (Arsitektur) + M009 (Integrasi) | |
| **Setelah user konfirmasi Section 6** | **TULIS** M010 (Database Schema) | |
| **Setelah user konfirmasi Section 7** | **TULIS** M011 (Stack Final) | |
| **Setelah user konfirmasi Section 8** | **TULIS** M012 (Design System: vibe, referensi, warna, font, mode terang/gelap, radius/motion) | Update M001 juga: "PRD selesai (8 section)" |
| **Saat resume sesi** | **BACA** semua entry + tampilkan ringkasan | "Berikut yang sudah kita sepakati di sesi sebelumnya: [ringkasan M002-M012]. Ada yang mau diubah?" |

**Format tulis ke memory**:
```markdown
### M0XX — [Label]
[Ringkasan ≤400 karakter]
```

**Path**: `.trae/memory/project_memory.md`

**PENTING**: Jangan tampilkan proses baca/tulis memory ke user. Cukup tampilkan ringkasan saat resume sesi.

---

## Plugin & MCP Trigger Points

Berikut momen spesifik dalam question flow di mana plugin/MCP bisa dimanfaatkan:

| Saat Ini | Trigger Condition | Tool yang Dipakai | Cara Menawarkan ke User |
|----------|------------------|-------------------|------------------------|
| Setelah Q1.1 (Deskripsi) | User menyebut nama aplikasi lain sebagai referensi | `web_search_prime` + `webReader` | "Boleh saya riset [nama aplikasi] dulu biar kita bisa pelajari fitur-fiturnya?" |
| Setelah Q1.2 (Target User) | User kirim screenshot referensi | `ui_to_artifact` + `analyze_image` (mcp_zai-vision) | "Bagus, saya bisa analisis screenshot ini untuk pelajari pola desainnya." |
| Saat Q3.2 (Detail Fitur) | Fitur yang kompleks atau user ragu | `sequentialthinking` (mcp_sequential-thinking) | "Ini fitur yang cukup kompleks. Mau saya pecah jadi sub-langkah supaya lebih jelas?" |
| Saat Q4.2 (User Flow) | User punya desain Figma | `get_figma_data` (mcp_Figma_AI_Bridge) | "Kalau kamu punya desain di Figma, saya bisa baca langsung component dan layout-nya." |
| Saat Q5.1 (Integrasi) | User butuh riset service pihak ketiga | `web_search_prime` + `webReader` | "Mau saya riset dan bandingkan opsi [service] yang tersedia?" |
| Saat Q5.2 (Arsitektur) | Keputusan arsitektur besar (monolith vs microservice, dll) | `sequentialthinking` + `get_repo_structure` (mcp_zread) | "Ini keputusan penting. Mau saya bandingkan opsi secara terstruktur?" |
| Q7.3 (Tech Stack) — **WAJIB** | Setiap library yang direkomendasikan | `resolve-library-id` → `query-docs` (mcp_context7) | (Auto — tidak perlu tanya user. WAJIB lakukan sebelum rekomendasi.) |
| Setelah semua section selesai | User mau export PRD | `docx` / `pdf` / `pptx` / `html-deck` skill | "PRD sudah jadi. Mau diekspor ke Word, PDF, atau PowerPoint?" |
| Setelah Phase 3 (Tasks) | User mau visualisasi timeline | `gantt-chart-visualization` skill | "Mau saya buatkan timeline Gantt chart dari task breakdown ini?" |
| Setelah Phase 4 (Wireframe) | User mau visualisasi arsitektur | `uml-and-software-architecture-visualization` skill | "Mau saya visualisasikan arsitektur sistem ini dalam diagram?" |
