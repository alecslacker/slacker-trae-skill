# RENCANA: MCP `dci-tts` — Pembuat Suara (TTS) via 9router

Author: Mas Wondho — Duta Corpora Indonesia (DCI)
Tanggal: 2026-11-24 · Status: SELESAI 2026-11-25 (Task 1-5 lulus; bug output_dir ditemukan di Task 4, diperbaiki + tes regresi; total 30 tes)

## Overview

Server MCP stdio Node.js yang mengubah teks menjadi audio MP3 lewat endpoint `/v1/audio/speech` milik 9router produksi. Pola identik dengan `dci-imagegen` yang sudah terbukti: kredensial dibaca server sendiri dari `~/.9router/env`, output ke folder project, dry-run di semua skrip, header branding DCI, komentar Bahasa Indonesia.

**Keputusan desain yang sudah disetujui Mas Wondho:**
- **Fleksibel**: tool menerima nama suara bebas (`edge-tts/...`, `google-tts/...`, dan provider premium yang kelak tersambung di dashboard) — tidak perlu update MCP saat provider baru ditambah.
- **Batch**: satu panggilan bisa membuat banyak MP3 sekaligus (maks 10) untuk voice over per adegan.
- **Folder hasil**: `<project>/generated-audio`.

## Latar Fakta (terbukti via uji API 2026-11-24)

| Fakta | Sumber |
|---|---|
| `POST /v1/audio/speech` dengan `{model, input}` → MP3 biner (`audio/mp3`) | Uji nyata: `google-tts/id`, `edge-tts/id-ID-ArdiNeural`, `id-ID-GadisNeural` — semuanya 200 OK |
| Suara gratis terbukti: `edge-tts/id-ID-ArdiNeural` (pria), `id-ID-GadisNeural` (wanita), `google-tts/id` (klasik, datar) | Uji nyata hari ini |
| TTS berkuota (Gemini/OpenAI/ElevenLabs) ditolak server — koneksi provider TTS belum ada di dashboard | Uji nyata; pesan "does not support TTS via this route" / "No credentials" |
| `GET /v1/models/tts` mengembalikan daftar kosong di server ini | Uji nyata — jadi MCP TIDAK memvalidasi suara ke daftar model (berbeda dari imagegen); kegagalan suara ditangkap saat panggilan pertama |
| Batas karakter teks TTS praktis: Google Edge ± beberapa ribu karakter per permintaan | Dok provider; MCP membatasi 5000 char per adegan agar aman [Medium confidence] |
| Suara tidak tersedia/biru → HTTP 400 dari server | Pola umum; dipetakan ke pesan Indonesia yang jelas |

## Perbedaan penting dari dci-imagegen

1. **Tidak ada pra-validasi suara** (daftar `/v1/models/tts` kosong) → panggil langsung, error 400 dipetakan dengan saran suara alternatif.
2. **Batch default = seluruh array sekaligus, paralel 2** (suara gratis, tidak menguras kuota — konfirmasi hanya untuk batch di atas 6 adegan).
3. **`input` wajib 3–5000 karakter per adegan**; naskah lebih panjang harus dipecah agent sebelum memanggil.
4. **Tidak ada parameter quality/model opsional rumit** — hanya `voice`, `segments`, `output_dir`, `confirmed`.

## Struktur Berkas

```
mcp/dci-tts/
├── package.json          name dci-tts, type module, node >=22
├── package-lock.json     dikunci: @modelcontextprotocol/sdk 1.32.2, zod 4.6.7
├── src/
│   ├── index.js          titik masuk stdio (hanya protokol MCP ke stdout)
│   ├── server.js         definisi tool `text_to_speech` + `list_free_voices`
│   ├── config.js         baca ~/.9router/env (uraiTeksEnv; BOM/kutip/komentar; https wajib)
│   ├── router-client.js  klien HTTP: POST /v1/audio/speech (biner), GET /v1/models/info
│   ├── speech.js         orkestrasi batch: validasi, paralel 2, simpan eksklusif
│   ├── audio.js          kenali jenis berkas dari byte (mp3/wav/ogg) — JANGAN percaya extension
│   ├── folders.js        tentukan folder hasil: output_dir → CLAUDE/ZCODE_PROJECT_DIR → cwd → ~/Music/dci-tts (cadangan)
│   └── errors.js         DciError + sensor() + petakanGalatHttp (pola imagegen)
├── scripts/panggil.mjs   pemanggil manual tanpa agent
└── test/
    ├── helpers.js        stub fetch + berkas env sementara (key palsu sk-uji-...)
    ├── config-errors.test.js
    ├── speech.test.js    validasi, batch, paralel, gagal per-adegan
    ├── audio-folders.test.js
    └── server-stdio.test.js  daftar tool + panggilan end-to-end via Client
```

Runtime terpasang di `~/.9router/mcp/dci-tts` (satu salinan untuk semua agent). Kode sumber di repo `mcp/dci-tts/`.

## Tool 1 — `text_to_speech`

| Param | Tipe | Aturan |
|---|---|---|
| `voice` | string, wajib | ID suara, contoh `edge-tts/id-ID-ArdiNeural`, `google-tts/id`. Dipakai apa adanya. |
| `segments` | string ATAU array string, wajib | Satu naskah, atau naskah per adegan (maks 10 elemen; tiap elemen 3–5000 char). String tunggal = 1 adegan. |
| `output_dir` | string opsional | Path absolut; bila kosong → `<project>/generated-audio`. |
| `confirmed` | boolean opsional | Wajib true bila total adegan > 6. |

Hasil: teks ringkas + JSON `{folder, berhasil: [{nomor, path, voice, detik, ukuran_kb}], gagal: [{nomor, alasan}], folder_cadangan}`. Deskripsi tool memuat ATURAN pemakaian (folder `generated-audio`, suara Ardi/Gadis gratis, >6 adegan wajib konfirmasi) seperti pola imagegen.

## Tool 2 — `list_free_voices`

Mengembalikan daftar statis suara gratis terbukti + contoh format provider lain (edge-tts/id-ID-GadisNeural, google-tts/id, dst) TANPA memanggil server — hemat dan tidak bergantung endpoint `/v1/audio/voices` yang kadang 502.

## Tasks (checkpoint per task, tunggu KERJAKAN/LANJUT)

| # | Isi | Verifikasi |
|---|---|---|
| 1 | Tulis semua kode + tes di **staging** `C:\Users\alecs\.trae\work\dci-tts-staging`, `npm install`, jalankan `npm test` sampai semua lulus | Semua tes lulus; 0 key asli di staging |
| 2 | Salin ke repo `mcp/dci-tts/` + tulis `scripts/install-tts.ps1` dan `register-tts.ps1` (parameter identik imagegen: `-Apply`, `-Hapus`, `-Agen`, `-Node`, dry-run bawaan) | Dry-run kedua skrip keluar tanpa error |
| 3 | `install-tts.ps1 -Apply` (npm ci di runtime) + `register-tts.ps1 -Apply` ke TRAE, TRAE SOLO, ZCode, Claude Code. Validasi JSON config sebelum & sesudah | `claude mcp list` Connected; config valid |
| 4 | Uji nyata di TRAE: 1 panggilan `text_to_speech`, suara Ardi, naskah 2 kalimat → MP3 masuk `generated-audio` | Berkas MP3 valid (header FF F3), durasi terbaca ffprobe |
| 5 | README (bagian MCP TTS), CHANGELOG, baris rules di `trae-rules.md`/`zcode/AGENTS.md`/`claude/CLAUDE.md`, memory, lalu commit + push (izin commit ditanya dulu) | `git status` bersih setelah push |

## Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| `/v1/models/tts` kosong → tidak bisa pra-validasi suara | Panggil langsung; 400 dipetakan dengan pesan yang menyebut contoh suara valid |
| Endpoint daftar suara sering 502 | `list_free_voices` statis, tidak menyentuh server |
| Agent mengirim naskah ribuan karakter | Validasi 5000 char per adegan di server, pesan menyarankan pemecahan |
| Teks berisi karakter aneh yang membuat TTS gagal | Gagal per-adegan tercatat di `gagal[]`, batch lanjut |
| Suara premium kelak beda format | Tool fleksibel menerima suara apa pun; tidak ada asumsi provider |
| Kuota terpakai tak disengaja bila provider premium nanti aktif | >6 adegan wajib `confirmed=true`; deskripsi tool memuat peringatan kuota |
| Key bocor ke repo | Kredensial hanya di `~/.9router/env`; `sensor()` di errors; scan sebelum commit |

## Di Luar Cakupan

Penggabungan audio ke video (ffmpeg tetap manual/via agent), merakit SSML, voice cloning, mengubah kecepatan/pitch, streaming audio, endpoint `/v1/audio/translations`.

## Catatan Jujur

- Suara gratis Ardi/Gadis sudah terbukti; TTS berkuota belum bisa dipakai sampai Mas Wondho menyambung provider TTS di dashboard 9router. MCP tetap siap memakainya begitu tersambung (tanpa perubahan kode).
- Batas 5000 char adalah angka konservatif dari praktik umum, bukan batas resmi 9router [Medium confidence].

Copyright © 2026 Duta Corpora Indonesia — All rights reserved
