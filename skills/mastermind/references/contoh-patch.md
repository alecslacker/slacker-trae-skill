# Contoh kerja: patch dengan `scripts/patcher.py`

Catatan ini ditulis dari eksekusi nyata pada sesi berjalan, bukan disusun dari teori. Bagian yang belum dijalankan diberi tanda.

## Bukti uji alat [TERBUKTI]

Sasaran: salinan `C:\Windows\System32\curl.exe` (711.736 byte) di direktori sementara.
Patch: offset `542880`, byte `55` (`U`) menjadi `58` (`X`) pada banner `Usage: curl ...`.

| Langkah | Perintah | Hasil |
|---|---|---|
| 1 | `--check` pada berkas asli | `offset 542880 [asli] U -> X`, exit 0 |
| 2 | `--apply` | `terpasang 1 patch`, cadangan `.bak` dibuat, exit 0 |
| 3 | `--apply` diulang | `sudah terpatch`, exit 4, berkas tidak diubah |
| 4 | jalankan `curl.exe --help` | baris jadi `Xsage: curl [options...] <url>` |
| 5 | `--restore` | `dipulihkan`, exit 0 |
| 6 | bandingkan hash | `hash_kembali_sama=True` |

Yang dibuktikan: hash gate, cadangan otomatis, idempoten, verifikasi fungsional, dan pemulihan penuh.
Yang **belum** dibuktikan: patch semantik (lompatan kondisional, NOP) pada biner hasil kompilasi sendiri — butuh `gcc`, tidak tersedia di mesin ini.

## Serah terima REA — sudah dijalankan [TERBUKTI]

Server MCP REA tidak terdaftar di sesi ini, jadi dipakai jalur CLI `rea` 6.8.0 yang memang disediakan skill REA. Provider yang tersedia: `ghidra 12.1.4`; `hopper` = `unsupported_host`, `ida` dan `kuna` = `not_configured`.

Rantai yang dijalankan pada `curl.exe` yang sama:

| Langkah | Perintah | Hasil |
|---|---|---|
| 1 | `rea analyze curl.exe` | profil PE x86_64, evidence `ev_a994bd4c…` |
| 2 | `rea search curl.exe "Usage: curl"` | alamat `0x1400860a0`, evidence `ev_c23dc19d…` |
| 3 | `rea address-to-file-offset curl.exe 0x1400860a0` | **`file_offset: 542880`**, evidence `ev_0af3acaa…` |
| 4 | `rea xrefs --address 0x1400860a0` | perujuk `0x14000eecd`, evidence `ev_7d4a1a2c…` |
| 5 | `rea decompile 0x14000eecd` | `puts("Usage: curl ...")` terlihat di pseudocode, evidence `ev_fc77e6d5…` |
| 6 | offset 542880 masuk profil → `patcher.py --apply` | exit 0, banner berubah jadi `Xsage` |
| 7 | `patcher.py --restore` | banner kembali `Usage` |

Catatan penting: langkah 3 menghasilkan offset **yang sama** dengan yang ditemukan manual (542880). Itu bukti bahwa jalur REA tidak mengarang — hasilnya cocok dengan kenyataan berkas.

Nilai `evidence_id` disitir utuh. Tanpa ID, tafsir tidak bisa dilacak.

## Alur kerja yang benar

1. Bangun target dari sumber, catat perintah build dan simpan hash asli.
2. Petakan titik keputusan lewat REA (decompiler/disassembler). Jangan menebak offset dari pola byte.
3. Tulis profil: satu entri per byte, `catatan` menjelaskan maksud.
4. `--check` → `--apply` → jalankan target → buktikan perilakunya berubah.
5. Simpan profil dan hash ke catatan build. Crack tanpa profil tidak bisa diulang.

## Contoh: `assets/crackme/crackme.c`

Build (jalankan di mesin yang punya `gcc`):

```bash
gcc -O0 -o crackme crackme.c
```

Target: program mencetak `akses ditolak` walau sandi benar. Cari instruksi percabangan setelah `strcmp`, lalu ganti `75` (`jne`) menjadi `EB` (`jmp`) atau tambal hasil perbandingan.

Isi `sha256_asli` di profil dengan hash build sendiri — offset antar build berbeda, jadi `assets/crackme/profil-contoh.json` sengaja memakai offset contoh. Bila hash tidak diisi, pakai `--abaikan-hash`.

Status contoh crackme: **[HIPOTESIS]** — belum dikompilasi di sesi ini.

## Jebakan

- Offset berbeda pada build lain. Selalu cek hash dulu; jangan pakai `--abaikan-hash` tanpa sadar.
- Patch di dalam bagian yang punya checksum (mis. Authenticode) akan merusak tanda tangan. Catat bila target ditandatangani.
- Jangan patch berkas asli di `System32`; bekerja pada salinan.
- Setelah selesai, pulihkan berkas uji. Berkas uji yang tertinggal = sampah (G7).
