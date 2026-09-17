---
description: Perbarui knowledge graph Graphify secara incremental setelah perubahan kode
---

# Tugas
Perbarui knowledge graph Graphify project saat ini setelah perubahan kode — hanya memproses file yang berubah, tidak build ulang dari nol. Ini menjaga peta tetap akurat dan hemat token.

# Langkah-langkah
1. **Siapkan PATH (Windows/PowerShell):**
   ```
   $env:PATH = 'C:\Users\alecs\.local\bin;' + $env:PATH
   ```

2. **Pastikan direktori benar:** direktori project yang sudah punya folder `graphify-out/`. Jika `graphify-out/` belum ada, beri tahu user untuk menjalankan `/graphify-build` dulu.

3. **Jalankan update:**
   ```
   graphify update .
   ```

4. **Cek hasil:**
   - Pastikan perintah selesai tanpa error.
   - Jika ada file/folder baru yang signifikan, update bisa saja butuh pembangunan ulang parsial — ikuti saran dari output.

5. **Laporkan singkat kepada user dalam Bahasa Indonesia:** berapa file yang diperbarui (dari log), status sukses/gagal, dan reminder bahwa peta sekarang sudah sinkron dengan kode terbaru.

# Catatan
- `graphify update` hanya memproses perubahan — jauh lebih cepat dari `graphify build`.
- Jika user menyebut "graph-nya jadul/tidak cocok dengan kode", jalankan langkah ini lebih dulu sebelum menjawab pertanyaan arsitektur.
