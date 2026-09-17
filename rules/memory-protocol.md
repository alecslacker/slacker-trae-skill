# Memory Protocol — Sambungan Antar Sesi (IRIT TOKEN)

> Tujuan: ganti sesi = tetap nyambung, biaya minimum. Baca 1× di awal, tulis hanya saat perlu.
> Pemasangan: salin ke `~/.trae/user_rules/` (User Rules TRAE tersimpan lokal per komputer).

## BACA — sekali di awal sesi baru (diam-diam, jangan dump isinya ke chat)

1. Baca `~/.trae/memory/user_profile.md` (profil & preferensi global user).
2. Baca `<folder-project>/.trae/memory/project_memory.md` jika ada (folder project = workspace yang terbuka).
3. Kalau project memory ADA → buka respons pertama dengan ringkasan 2–3 kalimat ("Sesi terakhir kita sampai X, output sudah Y, berikutnya Z") lalu tanya: lanjut atau mulai hal baru?
4. Kalau TIDAK ADA → mulai normal, jangan sebut memory sama sekali.

## TULIS — sparse, hanya fakta yang berguna di sesi berikutnya

Simpan saat checkpoint/konfirmasi (bukan setiap giliran):
- Keputusan teknis penting: stack final, arsitektur, pilihan library, integrasi pihak ketiga.
- Preferensi user baru yang dikonfirmasi eksplisit.
- Checkpoint progress: fase selesai, file output, task berikutnya, blocker aktif.
- Bug + workaround yang sudah ditemukan (agar tidak diulang di sesi lain).

## FORMAT & BATAS (inti dari irit token)

- Satu entri = `## [YYYY-MM-DD] Judul Singkat` + isi maksimal 400 karakter.
- Maksimal 20 entri per file. Penuh → merge/hapus entri obsolete — JANGAN buat file baru.
- Update entri lama lebih baik daripada append duplikat.
- DILARANG menyimpan: transcript chat, secret/token/password, hal yang sudah ada di user_profile.md.

## Larangan Ekstra

- Jangan baca ulang memory berkali-kali dalam satu sesi (1× cukup — konteks sudah menempel di percakapan).
- Jangan tampilkan isi mentah memory ke user — selalu ringkas.
- File memory project hanya satu: `.trae/memory/project_memory.md` di root project — tidak per folders tambahan.
