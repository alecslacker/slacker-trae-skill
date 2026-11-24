# Desain: dci-imagegen (MCP server image generation lintas agent)

> Author: Mas Wondho — Duta Corpora Indonesia (DCI)
> Tanggal: 2026-11-24 | Status: DISETUJUI Mas Wondho (2026-11-24). Rencana implementasi: `plan-dci-imagegen.md`

## 1. Tujuan

Semua agent di mesin ini (TRAE, TRAE SOLO, Claude Code, ZCode) bisa membuat dan mengedit gambar lewat satu tool yang sama, memakai 9router production milik Mas Wondho, dengan hasil sekelas `$imagegen` di Codex.

Latar belakang: BytePlus/Seedream sudah dibersihkan dari semua agent (2026-11-24). Uji 9router sudah berhasil: model `cx/gpt-image-2.6-sunburst`, 28,8 detik, 383 KB, teks logo benar.

## 2. Keputusan Mas Wondho

| Topik | Keputusan |
|---|---|
| Kemampuan | Generate dari teks + edit/referensi gambar + beberapa varian |
| Kuota | Default 1 gambar. Varian 2-4 langsung jalan. Di atas 4 wajib konfirmasi |
| Lokasi kredensial | `~/.9router/env` (netral, bukan milik agent mana pun) |
| Bentuk | MCP server khusus (pendekatan C) |
| Agent gelombang 1 | Claude Code, TRAE + TRAE SOLO, ZCode |
| Folder hasil default | Folder project aktif, subfolder `generated-images/` |

Di luar cakupan: logo ke SVG, resize/WebP, referensi lewat URL, ganti model otomatis, Codex (gelombang berikutnya).

## 3. Arsitektur

```
Agent --stdio--> dci-imagegen (Node 26) --HTTPS--> 9router /v1/images/generations
                      |                                   |
                      +-- baca ~/.9router/env             +-- provider cx/ag (akun ChatGPT/Gemini)
                      +-- simpan PNG ke folder output
```

- Runtime: Node.js v26.13.0 (sudah terpasang, `fetch` bawaan terverifikasi). Tanpa `uv`, jadi tidak ada lagi masalah cache terkunci.
- Dependensi: SDK MCP resmi + `zod`, versi dikunci (`package-lock.json`). API SDK diverifikasi ke Context7 sebelum kode ditulis.
- Sumber di repo: `mcp/dci-imagegen/` (tanpa rahasia). Salinan runtime tunggal: `~/.9router/mcp/dci-imagegen/`, dibuat oleh skrip pemasang.
- Config agent memanggil `C:\nvm4w\nodejs\node.exe` dengan path absolut (pola sama dengan server `rea`), supaya tidak tergantung PATH tiap agent.

## 4. Kontrak tool

### `list_image_models`
Tanpa parameter. Mengambil `/v1/models/image` dan `/v1/models/info` dari server, mengembalikan id, nama, parameter, dan kemampuan (`text2img`, `edit`, `multiImage`).

### `generate_image`

| Parameter | Tipe | Aturan |
|---|---|---|
| `prompt` | string, wajib | 3-4000 karakter |
| `model` | string, opsional | Default `cx/gpt-image-2.6-sunburst`. Harus ada di daftar server, kalau tidak ditolak. Tidak pernah diganti diam-diam |
| `n` | integer, opsional | Default 1. 2-4 langsung jalan. 5-8 hanya bila `confirmed: true`. Di atas 8 ditolak mutlak |
| `reference_images` | string[], opsional | Path lokal, maks 4 file, 10 MB per file. Bila ada, mode edit/multi-referensi |
| `quality` | string, opsional | Diteruskan bila model mendukung (cek `params`) |
| `output_dir` | string, opsional | Path absolut. Lihat bagian 6 |
| `confirmed` | boolean, opsional | Hanya menaikkan batas 4 ke 8. Deskripsi tool menyuruh agent menanyakan ke Mas Wondho dulu |

Hasil: daftar `{path, model, ukuran_px, ukuran_kb, detik}` per gambar, plus `gagal: [{nomor, alasan}]` bila sebagian gagal. Isi gambar tidak dikirim balik ke agent (hemat token).

## 5. Aturan perilaku (dijaga di kode, bukan imbauan)

1. Batas `n` dicek **sebelum** menyentuh 9router. Pelanggaran = ditolak tanpa memakai kuota.
2. Maksimal 2 permintaan paralel. Tiap gambar satu panggilan ke 9router.
3. Kegagalan sebagian dilaporkan per gambar. Yang sukses tetap tersimpan.
4. Tanpa retry otomatis. Error dipetakan ke pesan Indonesia: 401 (key salah), 400 (model/parameter tidak valid), 503 (semua akun tidak tersedia, sertakan `retry-after`), timeout (120 detik per gambar).
5. Nama file dibuat server: `slug-prompt_YYYYMMDD-HHmmss_nomor.ext`. Dibuat dengan mode eksklusif (tidak pernah menimpa file lama). Ekstensi ditentukan dari byte asli (PNG/JPEG/WEBP).
6. Log hanya ke stderr, hanya metadata (model, n, durasi, status). Tidak ada prompt dan tidak ada key.

## 6. Penentuan folder hasil

Server MCP tidak selalu berjalan di folder project (cwd berbeda tiap agent, belum diverifikasi per agent). Urutan:

1. Parameter `output_dir` (agent wajib mengisi path absolut `<project>/generated-images` — ini ditulis di deskripsi tool).
2. Env `CLAUDE_PROJECT_DIR` atau `ZCODE_PROJECT_DIR` bila ada, ditambah `generated-images/`.
3. `cwd` server, **hanya** jika bukan root drive, bukan folder home, dan bukan folder sistem.
4. Cadangan: `~/Pictures/dci-imagegen/`, dan hasil menandai `folder_cadangan: true` agar agent memberi tahu Mas Wondho.

Penjaga: path harus absolut, ditolak jika di bawah `%WINDIR%` atau `Program Files`, dan folder dibuat bila belum ada.

Catatan untuk Mas Wondho: `.gitignore` repo ini belum mengecualikan `generated-images/`. Server tidak mengubah `.gitignore` project mana pun. Tambahkan sendiri di project yang perlu.

## 7. Kredensial dan keamanan

- Format `~/.9router/env`: `NINEROUTER_URL=` dan `NINEROUTER_KEY=`. Dibaca di setiap panggilan, jadi ganti key tidak perlu restart. Env var `NINEROUTER_URL`/`NINEROUTER_KEY` menimpa bila ada.
- Migrasi: isi `~/.trae/9router.env` dipindah ke lokasi baru, izin file dikunci ke akun Mas Wondho, file lama dihapus.
- URL wajib `https` (http hanya untuk `localhost`).
- Key tidak boleh muncul di output tool, log, atau pesan error. Diuji dengan pemindaian.
- `reference_images`: hanya path lokal absolut, isi harus PNG/JPEG/WEBP asli (dicek lewat byte awal, bukan ekstensi). Menolak symlink, UNC, dan file di atas 10 MB. Ini mencegah berkas NON-gambar (kunci, `.env`, dokumen) terkirim ke server. Batasannya: gambar apa pun di disk (misalnya tangkapan layar berisi rahasia) tetap bisa dikirim bila agent terkena prompt injection. Pembatasan ke folder tertentu sengaja tidak dipasang karena akan menghalangi pemakaian normal; yang melindungi adalah kebiasaan agent meminta persetujuan Mas Wondho sebelum memakai gambar sensitif.
- Server tidak menjalankan perintah shell apa pun.

## 8. Pemasangan per agent

Satu skrip `scripts/register-imagegen.ps1` di repo. Default **dry-run**. Mode `-Apply`: sisipkan satu blok teks, validasi (JSON sah, semua server lain identik), tulis atomik, verifikasi ulang pasca-tulis. Idempoten. `-Hapus` membuang blok dan mengembalikan berkas persis seperti semula (terbukti byte per byte pada 6 bentuk config).

Perubahan dari rancangan awal: skrip TIDAK membuat salinan cadangan berkas config. Alasannya, config agent memuat key milik server lain (Z.ai, Figma, Context7, dan lain-lain), dan salinan cadangan akan menggandakan rahasia itu di disk. Pengganti cadangan: pembalikan persis lewat `-Hapus`, ditambah hash MD5 config yang dicatat sebelum `-Apply` (lihat rencana implementasi, Task 6).

| Agent | Berkas config | Cara |
|---|---|---|
| TRAE | `%APPDATA%\Trae\User\mcp.json` | Tambah blok `mcpServers`, divalidasi JSON |
| TRAE SOLO | `%APPDATA%\TRAE SOLO\User\mcp.json` | Sama |
| Claude Code | `~/.claude.json` | Lewat `claude mcp add --scope user` (file ini sering ditulis ulang Claude Code, jangan disunting tangan). Sintaks diverifikasi dengan `claude mcp add --help` |
| ZCode | `~/.zcode/cli/config.json`, `mcp.servers` | Tambah entri, divalidasi JSON |

Catatan ZCode: akan ada dua jalur gambar (plugin bawaan Z.ai yang berbasis Seedream dan `dci-imagegen`). Deskripsi tool `dci-imagegen` menyebut "GPT Image lewat 9router milik DCI" agar agent bisa membedakan.

## 9. Pengujian

**Tahap 1 — tanpa kuota.** Uji otomatis (`node:test`) dengan server 9router palsu: batas `n`, `confirmed`, validasi model, penolakan tanpa panggilan jaringan, key tidak bocor di output/log, pemeriksaan byte gambar, file tidak menimpa, pemetaan error, kegagalan sebagian, penentuan folder.

**Tahap 2 — uji nyata, maksimal 5 gambar:** 1 logo (`n=1`), 1 permintaan 3 varian, 1 edit memakai gambar referensi `hasil-tes-9router/logo-dci-sunburst.png`.

**Tahap 3 — per agent:** tool terlihat, satu panggilan `n=1` menyimpan file di folder yang benar, 4 agent.

## 10. Belum terverifikasi (diuji paling awal)

| # | Hal | Dampak bila gagal |
|---|---|---|
| a | Format field edit di 9router. Dari kode sumber publik 9router (commit 4 Mei 2026): `image` / `images[]` menerima data URL, URL http(s), atau base64 mentah. Server ini mengirim `images` berisi data URL. Server produksi Mas Wondho lebih baru dari snapshot itu (punya model 2.6), jadi tetap diuji nyata | Edit ditandai tidak tersedia, tidak dipalsukan |
| b | Parameter rasio gambar: `size` 1024x1024 menghasilkan 1774x887 pada uji awal. Penyebab belum diketahui | Parameter `aspect` baru disediakan setelah terbukti bekerja |
| c | Batas waktu tool tiap agent. Satu gambar ±29 detik, 4 varian paralel 2 ≈ 1-2 menit. Config `rea` di Codex memakai `tool_timeout_sec = 450`, yang menyiratkan default lebih kecil [Medium confidence]. Terbukti: server mengirim notifikasi progres dan klien SDK memperpanjang batas waktunya (diuji). Belum diketahui apakah Claude Code, TRAE, dan ZCode ikut memperpanjang batas waktu saat menerima progres | Bila terlalu sempit: pola dua langkah (mulai pekerjaan, ambil hasil) |
| d | cwd/env project tiap agent saat menjalankan server | Folder cadangan lebih sering dipakai |
| e | `npm` tersedia untuk memasang dependensi di folder runtime | Pakai `node --run` atau SDK dibundel |

## 11. Kriteria selesai

1. Di 4 agent (Claude Code, TRAE, TRAE SOLO, ZCode), satu panggilan `generate_image` menghasilkan file di folder yang benar.
2. `n=5` tanpa `confirmed` ditolak tanpa panggilan ke 9router (dibuktikan uji otomatis).
3. Pemindaian output, log, dan config tidak menemukan nilai key.
4. Edit berfungsi, atau dinyatakan tidak tersedia disertai alasan terukur.
5. Skrip pemasang: dry-run menampilkan perubahan, terapkan membuat cadangan, dijalankan dua kali hasilnya sama.

## 12. Langkah berikutnya

Setelah dokumen ini disetujui: rencana implementasi (`plan-dci-imagegen.md`), lalu eksekusi bertahap dengan checkpoint (KERJAKAN/LANJUT).

---
Copyright © 2026 Duta Corpora Indonesia — All rights reserved
