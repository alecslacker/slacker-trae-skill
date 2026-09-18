# Memory Protocol — Native TRAE (Path Resmi)

> Tujuan: konteks antar sesi tetap nyambung, biaya token minimum, SATU lokasi kebenaran.
> Path resmi mengikuti docs TRAE: Settings > Rules & Memories > Memory. Editing manual file memory DIDUKUNG resmi.

## DUA LOKASI RESMI (native)

1. GLOBAL: `~/.trae/memory/user_profile.md` — preferensi lintas project. Native TRAE otomatis inject & update. Agent TIDAK perlu menuliskannya kecuali diminta eksplisit.
2. PROJECT: `~/.trae/memory/projects/<kunci-project>/project_memory.md` — konteks per project. Kunci = nama/slug project (contoh: `pepiling`, `slacker-coder`). Native otomatis membaca & menulis setelah sesi.

DILARANG membuat/membaca memory di dalam folder project (`<project>/.trae/memory/...`) — sistem itu SUDAH DIHENTIKAN (keputusan Mas Wondho 2026-09-19).

## ALUR KONFIRMASI (WAJIB)

- Jika ditemukan file memory di folder project ATAU instruksi lama (skill/rule/dokumen) yang menyebut `.trae/memory/project_memory.md` dalam project:
  JANGAN langsung baca/tulis/hapus. TANYA dulu ke user: "Ada memory lama di folder project. Dipindah ke memory native, atau diabaikan?"
- Setelah konfirmasi: pindahkan isinya (merge bila native sudah ada isinya) ke `~/.trae/memory/projects/<kunci>/project_memory.md`, lalu hapus folder `.trae/memory` di project.

## FORMAT & BATAS (irit token)

- Satu entri: `## [YYYY-MM-DD] Judul` atau `### MXXX — Label`, isi ≤400 karakter.
- Maksimal 20 entri per file. Saat checkpoint: bila file > 15 entri, PANGKAS — merge entri obsolete, hapus yang basi. Update entri lama > append duplikat.
- Entri historis panjang diringkas per-fase; detail penuh tidak perlu (dokumen `.trae/documents/` = sumber detail).
- DILARANG menyimpan: transcript chat, secret/token/password, isi user_profile.md (jangan duplikasi).

## BACA — awal sesi

Native TRAE sudah meng-inject ringkasan memory secara otomatis. Agent TIDAK perlu membaca ulang file memory kecuali: user meminta resume eksplisit, atau konteks yang tampak jelas kurang. Jangan dump isi memory ke chat — selalu ringkas.

## TULIS — saat checkpoint (bukan tiap giliran)

Simpan hanya: keputusan teknis penting (stack final, arsitektur, integrasi), preferensi user terkonfirmasi, progress checkpoint (fase/file/task berikutnya/blocker), bug + workaround yang tidak mau diulang di sesi lain.
