# Rencana Implementasi: dci-imagegen

> Author: Mas Wondho — Duta Corpora Indonesia (DCI)
> Tanggal: 2026-11-24 | Status: DISETUJUI Mas Wondho (2026-11-24). Eksekusi per task dengan checkpoint KERJAKAN/LANJUT
> Desain acuan: `design-dci-imagegen.md` (sudah disetujui)

## Overview

MCP server `dci-imagegen` (Node 26, SDK MCP 1.32.2 + zod 4.6.7) agar TRAE, TRAE SOLO, Claude Code, dan ZCode bisa membuat serta mengedit gambar lewat 9router milik DCI. Kode sudah ditulis dan dibuktikan di folder staging. Rencana ini memindahkannya ke repo, memasangnya, lalu mengujinya dengan gambar nyata.

## Context7 Pre-Check

| Library | Versi | Hasil verifikasi |
|---|---|---|
| `@modelcontextprotocol/sdk` | 1.32.2 (sama dengan versi terbaru di npm) | `McpServer.registerTool`, `StdioServerTransport`, `isError`, notifikasi progres: sesuai dokumentasi Context7, dan dibuktikan lewat uji stdio sungguhan |
| `zod` | 4.6.7 (peer dependency SDK: `^3.25 \|\| ^4.0`) | Skema `inputSchema` terkonversi benar ke JSON Schema |

## Skill yang Digunakan

- `brainstorming` dan `writing-plans`: rancangan dan rencana ini.
- `verification-before-completion`: setiap task berakhir dengan bukti yang dijalankan, bukan klaim.
- `git-commit`: dipakai hanya bila Mas Wondho meminta commit.

## Bukti yang Sudah Ada (di staging, sebelum rencana ini)

| Pemeriksaan | Hasil |
|---|---|
| `npm ci` lalu `npm test` dari salinan bersih | 39 tes: 38 lulus, 1 dilewati, 0 gagal |
| Uji mutasi: 12 kontrol keamanan dirusak satu per satu | 12 dari 12 tertangkap tes |
| `register-imagegen.ps1` pada config sintetis (6 bentuk) | Tambah, ulang, hapus: kembali persis byte per byte |
| Runtime hasil `install-imagegen.ps1` dijalankan klien MCP | 2 tool terdaftar, galat kredensial berupa pesan jelas |
| `list_image_models` ke 9router produksi | 9 model terbaca, key tidak muncul di keluaran |
| Claude Code memulai server ini (proyek sementara) | Status Connected dalam 0,7 detik |

## Berkas dan Tanggung Jawabnya

Sumber: `C:\Users\alecs\.trae\work\dci-imagegen-staging` (20 berkas + `MANIFEST.sha256.txt`). Hash tiap berkas ada di manifest; jangkar manifest `10DB3246BE2EEC14`.

| Berkas | Tanggung jawab |
|---|---|
| `mcp/dci-imagegen/src/index.js` | Titik masuk stdio |
| `.../src/server.js` | Dua tool, skema zod, deskripsi tool, progres |
| `.../src/generate.js` | Batas jumlah, varian paralel (maks 2), simpan eksklusif |
| `.../src/router-client.js` | Klien HTTP ke 9router, pemetaan galat |
| `.../src/config.js` | Baca `~/.9router/env`, wajib https |
| `.../src/images.js` | Kenali gambar dari byte, baca gambar referensi |
| `.../src/folders.js` | Tentukan folder hasil |
| `.../src/errors.js` | Galat Indonesia dan penyensoran key |
| `.../test/*` (5 berkas) | 39 tes dengan 9router palsu |
| `.../scripts/panggil.mjs` | Pemanggil manual untuk uji nyata |
| `.../scripts/uji-mutasi.ps1` | Uji mutasi kontrol keamanan |
| `scripts/install-imagegen.ps1` | Pasang runtime ke `~/.9router/mcp/dci-imagegen` |
| `scripts/register-imagegen.ps1` | Daftarkan ke 4 agent (dry-run bawaan) |
| `scripts/uji-register.ps1` | Uji pemasang pada config sintetis |

## Task

Setiap task berakhir di checkpoint. Mas Wondho mengetik `KERJAKAN` atau `LANJUT`, dan saya hanya mengerjakan satu task.

### Task 1 — Salin ke repo dan buktikan identik
- Salin `mcp/` dan `scripts/` dari staging ke `f:\Project\trae-skill`. Folder `mcp/` belum ada di repo dan tidak ada berkas yang bentrok.
- Jalankan `npm ci` lalu `npm test` dari repo.
- Hitung ulang hash tiap berkas dan cocokkan dengan manifest.
- Tidak ada commit.
- **Bukti selesai:** 0 berkas berbeda dari manifest, 38 tes lulus.

### Task 2 — Pindahkan kredensial ke `~/.9router/env`
- Buat `~/.9router/env` dari isi `~/.trae/9router.env`, tanpa menampilkan key.
- Kunci izin folder `~/.9router` ke akun Mas Wondho saja (`icacls`, pola sudah diuji).
- Verifikasi pemuat kredensial membaca berkas baru (hanya host dan panjang key yang dicetak).
- Hapus `~/.trae/9router.env` hanya setelah verifikasi lolos.
- **Bukti selesai:** pemuat berhasil dari lokasi baru, berkas lama tidak ada, key tidak pernah tercetak.

### Task 3 — Pasang runtime
- `scripts\install-imagegen.ps1` dry-run, lalu `-Apply`, ke `~/.9router/mcp/dci-imagegen`.
- Jalankan server hasil instalasi lewat klien MCP nyata.
- **Bukti selesai:** dua tool terdaftar, `list_image_models` ke produksi berhasil dari runtime terpasang.

### Task 4 — Uji nyata, maksimal 5 gambar (memakai kuota ChatGPT)
Menjawab lima hal yang belum terverifikasi di desain:

| Gambar | Perintah | Yang dijawab |
|---|---|---|
| 1 | Logo, `n=1`, `size` tidak diisi | Waktu, ukuran piksel, folder tujuan |
| 2-4 | `n=3` varian, satu permintaan | Varian paralel dan progres |
| 5 | Edit, acuan `hasil-tes-9router/logo-dci-sunburst.png`, ganti warna emas | Field `images` berfungsi atau tidak (hal a) |

- Sebelum menjalankan, saya sebutkan model, jumlah, dan perkiraan kuota, lalu menunggu persetujuan Mas Wondho.
- Parameter `aspect`/`size` tidak diuji di sini (hal b). Hanya dicatat penyebab 1774x887.
- **Bukti selesai:** 5 berkas gambar valid, hasil edit dilihat langsung, laporan jujur bila edit gagal.

### Task 5 — Daftarkan ke 4 agent
- Dry-run seluruh agent, tampilkan perubahan ke Mas Wondho.
- Setelah disetujui: `register-imagegen.ps1 -Apply`.
- Verifikasi: JSON valid, server lain identik, `claude mcp get dci-imagegen` berstatus Connected.
- Mas Wondho me-restart TRAE, TRAE SOLO, dan ZCode.
- **Bukti selesai:** 4 agent terdaftar, tidak ada server lain yang berubah.

### Task 6 — Uji per agent (maksimal 4 gambar)
- Satu panggilan `n=1` per agent: Claude Code, TRAE, TRAE SOLO, ZCode.
- Periksa: tool terlihat, file masuk folder project yang benar (hal d), batas waktu tool cukup (hal c).
- Bila batas waktu terlalu sempit di suatu agent, saya laporkan dan usulkan pola dua langkah. Tidak diubah tanpa persetujuan.
- **Bukti selesai:** 4 berkas gambar di folder project masing-masing.

### Task 7 — Dokumentasi dan memory
- Perbarui `README.md` (tabel isi repo, bagian "Yang TIDAK ikut tersinkron").
- Perbarui `CHANGELOG.md`.
- Perbarui `memory/user_profile.md` dan memory proyek (jalur gambar baru, lokasi kredensial baru).
- Tambahkan baris `dci-imagegen` di bagian MCP pada `trae-rules.md`, `zcode/AGENTS.md`, `codex/AGENTS.md`, `claude/CLAUDE.md`. Keputusan menambah ke file aturan saya tanyakan ke Mas Wondho dulu.
- Tidak ada commit sampai Mas Wondho meminta.

## Risiko dan Mitigasi

| Risiko | Mitigasi |
|---|---|
| Kuota ChatGPT habis oleh pengujian | Tetap di batas 5 + 4 gambar, persetujuan sebelum tiap uji nyata |
| Edit gambar ditolak 9router | Edit ditandai tidak tersedia dengan alasan terukur, tidak dipalsukan |
| Batas waktu tool terlalu sempit di sebagian agent | Progres MCP sudah dikirim; fallback pola dua langkah diusulkan, bukan dipasang diam-diam |
| Config agent rusak saat didaftarkan | Dry-run dulu, validasi sebelum tulis, pembalikan persis lewat `-Hapus` |
| Key terbawa ke repo | Staging dan repo dipindai: 0 berkas memuat key atau host produksi. `.env` dan `~/.9router` di luar repo |
| `collect.ps1` men-commit lalu push semua perubahan (`git add -A`) | Jangan menjalankan `collect.ps1` sebelum Mas Wondho memeriksa `git status`. Folder `.trae/`, `mcp/`, `hasil-tes-9router/` akan ikut |
| Komputer bermasalah lagi di tengah jalan | Staging utuh bermanifest; tiap task mandiri dan bisa diulang |

## Di Luar Cakupan

Logo ke SVG, resize atau WebP, referensi lewat URL, ganti model otomatis, pemasangan di Codex, parameter `aspect`.

## Catatan Jujur

- Task 4 dan 6 memakai kuota ChatGPT di 9router. Saya tidak menjalankannya tanpa persetujuan.
- ZCode akan punya dua jalur gambar (plugin bawaan Z.ai dan `dci-imagegen`). Deskripsi tool menyebut "GPT Image lewat 9router milik DCI" agar agent bisa membedakannya.
- Gambar acuan yang dikirim ke server hanya diperiksa jenisnya (PNG, JPEG, WEBP asli), bukan lokasinya. Gambar sensitif tetap bisa terkirim bila agent terkena prompt injection. Hal ini sudah dicatat di dokumen desain.

---
Copyright © 2026 Duta Corpora Indonesia — All rights reserved
