---
description: Bangun knowledge graph Graphify project saat ini (mode code-only, 100% lokal, tanpa API key)
---

# Tugas
Bangun knowledge graph Graphify untuk project pada direktori kerja saat ini, lalu laporkan hasilnya. Jangan membaca file satu per satu untuk memahami project — cukup jalankan perintah build dan baca outputnya.

# Langkah-langkah
1. **Siapkan PATH (Windows/PowerShell):** jalankan dulu:
   ```
   $env:PATH = 'C:\Users\alecs\.local\bin;' + $env:PATH
   ```
   (Jika perintah `graphify` sudah dikenali, langkah ini boleh dilewati.)

2. **Pastikan direktori benar:** gunakan direktori kerja / folder project yang sedang dibuka (misal `F:\laragon\www\<nama-project>`). Jangan jalankan di drive root atau folder berisi banyak project sekaligus.

3. **Jalankan build:**
   ```
   graphify . --code-only
   ```
   - `--code-only` WAJIB: hanya index kode (AST lokal, gratis, tanpa API key). Tanpa flag ini Graphify meminta API key LLM.
   - Biarkan proses selesai (bisa 3–15 menit untuk project normal). Cek apakah ada error.

4. **Pastikan file visual ada:** setelah selesai, periksa folder `graphify-out/` di direktori project. Jika `graph.html` TIDAK ada (biasanya karena graph > 5000 node), jalankan:
   ```
   graphify export html
   ```

5. **Laporkan ringkasan kepada user dalam Bahasa Indonesia:**
   - Path folder output (`graphify-out/`)
   - Estimasi besar graph (jumlah file kode diproses, jumlah node/komunitas bila tersedia dari log)
   - Ada/tidaknya `graph.html` (peta visual), `GRAPH_REPORT.md`, `graph.json`
   - Catatan warning penting (misal .sql tidak ter-index karena ekstraktor belum diinstall, file rahasia .env dilewati, dll)

# Larangan
- JANGAN jalankan tanpa `--code-only`.
- JANGAN minta API key / pakai backend LLM.
- JANGAN baca-baca file project untuk "memverifikasi" struktur — gunakan output graphify.
- JANGAN jalankan di folder yang berisi banyak project/vendor raksasa sekaligus (sangat lambat).
