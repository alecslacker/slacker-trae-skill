# SLACKER TRAE SKILL

> **Milik Slackercode Family** — kumpulan skill TRAE IDE, tersinkron otomatis antar komputer lewat GitHub.

Repo ini berisi **437<!--skill-count:437--> skill TRAE IDE** yang sudah dikurasi, diaudit keamanannya, dan siap pakai — dari blog engine, keamanan DevOps, sampai marketing.

> ⚠️ **Repo ini PRIVATE, khusus Slackercode Family.** Folder `memory/` berisi profil preferensi pribadi — jangan pernah diubah ke publik.

---

## Isi Repo

| Folder / File | Isi |
|---------------|-----|
| `skills/` | 437<!--skill-count:437--> folder skill — kurasi standalone + ekspor plugin TRAE resmi + logo-design + reverse-engineer-anything (lihat tabel di bawah) |
| `skills/INVENTORY.md` | Inventaris 390 skill per sumber (kurasi internal / plugin TRAE / GitHub eksternal) — auto-generated oleh `scripts/update-inventory.ps1`, jawaban "skill X dari mana?" |
| `memory/` | Profil preferensi (`user_profile.md`) + template project memory — dibaca TRAE tiap sesi via Memory Protocol |
| `rules/` | Aturan perilaku tambahan (`critical-thinking.md`, `memory-protocol.md`) — sumber kebenaran; pasang manual ke `~/.trae/user_rules/` |
| `claude/` | Artefak Claude Code CLI: `CLAUDE.md` global, `commands/`, `settings.template.json` |
| `zcode/` | Artefak Z Code: `AGENTS.md` global, `BEST-PRACTICE.md`, `commands/` |
| `codex/` | Artefak Codex: `AGENTS.md` global (padanan Rules TRAE WORK), `BEST-PRACTICE.md` (riset 2026-10-05) |
| `scripts/export-plugins.ps1` | Ekspor skill plugin TRAE resmi (superpowers, dev-skills, harness, dkk) → repo — skip plugin terikat MCP TRAE-only (lark, cloudflare, dll) |
| `scripts/install-rea.ps1` | Setup dependensi skill REA: rea-agents (npm) + JDK 21 + Ghidra 12.1.4 + jadx JAR + registrasi MCP — lihat bagian "Skill REA" |
| `mcp/dci-imagegen/` | Kode sumber MCP pembuat gambar via 9router (`generate_image`, `list_image_models`) + tes. Runtime dipasang ke `~/.9router/mcp/dci-imagegen` oleh `scripts/install-imagegen.ps1` |
| `mcp/dci-tts/` | Kode sumber MCP pembuat suara (TTS) via 9router (`text_to_speech`, `list_free_voices`) + tes. Runtime dipasang ke `~/.9router/mcp/dci-tts` oleh `scripts/install-tts.ps1` |
| `scripts/install-imagegen.ps1` | Pasang runtime `dci-imagegen` ke `~/.9router/mcp/` (bawaan dry-run, `-Apply` untuk menulis) |
| `scripts/register-imagegen.ps1` | Daftarkan/cabut (`-Hapus`) server ke TRAE, TRAE SOLO, ZCode, Claude Code. Bawaan dry-run, `-Apply` untuk menulis |
| `scripts/install-tts.ps1` | Pasang runtime `dci-tts` ke `~/.9router/mcp/` (bawaan dry-run, `-Apply` untuk menulis) |
| `scripts/register-tts.ps1` | Daftarkan/cabut (`-Hapus`) server `dci-tts` ke 4 agent. Bawaan dry-run, `-Apply` untuk menulis |
| `scripts/install.sh` | Padanan macOS `install.ps1` — pasang skills + memory ke `~/.trae/skills` |
| `scripts/collect.sh` | Padanan macOS `collect.ps1` — kumpulkan skill/memory lokal → repo → GitHub |
| `scripts/sync.sh` | Padanan macOS satu pintu: `./scripts/sync.sh claude\|zcode\|codex\|all [--mirror]` |
| `scripts/verify.sh` | Padanan macOS `verify-sync.ps1` — jumlah skill + sidik jari folder taste |
| `scripts/install.ps1` | Pemasang skill untuk komputer baru (TRAE) |
| `scripts/collect.ps1` | Pengumpul perubahan skill lokal → repo → GitHub (TRAE) |
| `scripts/sync-claude.ps1` | Sinkron repo → Claude Code CLI (`~/.claude`) |
| `scripts/sync-zcode.ps1` | Sinkron repo → Z Code (`~/.zcode`) + MCP dari Claude |
| `scripts/sync-codex.ps1` | Sinkron repo → Codex (`~/.agents/skills` resmi + `~/.codex/skills` legacy + AGENTS.md) |
| `scripts/verify-sync.ps1` | Verifikasi silang repo vs TRAE/Claude/ZCode/Codex (jumlah skill + MD5 isi per folder) |
| `scripts/check-upstream.ps1` | Cek update skill dari repo upstream GitHub (baca `upstream-manifest.json`) |
| `scripts/fix-node-path-machine.ps1` | Hapus Node standalone (`C:\Program Files\nodejs`) dari PATH Machine (butuh UAC) agar Node Laragon versi terpilih jadi utama — jalankan sekali per komputer Windows, idempoten |
| `upstream-manifest.json` | Daftar sumber upstream skill + versi terakhir tercatat |
| `CHANGELOG.md` | Riwayat perubahan per rilis (Keep a Changelog) — update saat checkpoint besar |

---

## Cara Pakai

### Langkah Pertama (Cukup Sekali)

Repo ini sudah siap push. Jika belum terhubung ke GitHub:

```powershell
cd trae-skills
git remote add origin https://github.com/alecslacker/slacker-trae-skill.git
git push -u origin master
```

### Komputer Baru / Komputer Lain (Cukup Sekali)

```powershell
# 1. Pastikan sudah install Git dan TRAE IDE
# 2. Ambil repo:
git clone https://github.com/alecslacker/slacker-trae-skill.git
cd slacker-trae-skill

# 3. Pasang semua skill:
.\scripts\install.ps1
#    Skill lama di komputer itu otomatis di-backup ke ~/.trae/skills-backup-[tanggal]

# 4. Restart TRAE IDE — selesai, semua skill langsung aktif.
```

**Pilihan saat memasang:**

| Perintah | Fungsi |
|----------|--------|
| `.\scripts\install.ps1` | Pasang normal — skill lama dibiarkan (aman) |
| `.\scripts\install.ps1 -Mirror` | Samakan 100% dengan repo — skill lokal yang tidak ada di repo ikut dihapus |
| `.\scripts\install.ps1 -SkipMemory` | Lewati folder memory (jangan sentuh profil) |

### Alur Sinkron Harian

```
Komputer A (ada skill baru / ada yang diubah):
    .\scripts\collect.ps1
    → salin skill + memory ke repo → simpan (commit) → kirim (push)

Komputer B (ingin mendapat pembaruan):
    git pull
    .\scripts\install.ps1
    → restart TRAE
```

Perintah tambahan `collect.ps1`:

| Perintah | Fungsi |
|----------|--------|
| `.\scripts\collect.ps1 -Message "pesan"` | Pakai pesan simpanan (commit) khusus |
| `.\scripts\collect.ps1 -NoPush` | Simpan saja, kirim nanti secara manual |

### Sinkron ke Claude Code CLI

Repo ini juga jadi sumber skill untuk **Claude Code CLI** — pengalaman identik dengan TRAE (skill yang sama, aturan Slackercoder yang sama, model GLM via z.ai):

```powershell
.\scripts\sync-claude.ps1          # normal — tambah/perbarui skill
.\scripts\sync-claude.ps1 -Mirror  # samakan 100% — skill lokal yang tidak ada di repo ikut dihapus
```

Yang disalin: 437<!--skill-count:437--> skill → `~/.claude/skills`, `CLAUDE.md` global (persona Slackercoder + hemat token), commands `/graphify-build` `/graphify-update`. Settings digabung otomatis — **token, plugin z.ai, dan MCP lokal tetap dipertahankan** (backup `settings.json.bak`).

Model aktif (GLM Coding Plan via `api.z.ai`): Sonnet/Opus = `glm-5.4[1m]`, Haiku = `glm-5.3-flash[1m]`, konteks 1M aktif (`[1m]` diurai Claude Code jadi beta header). Ganti model cukup edit `claude/settings.template.json` lalu sync ulang.

### Sinkron ke Z Code

**Z Code** (aplikasi desktop Z.ai, agent GLM native) memakai standar yang sama — skill `SKILL.md` + `AGENTS.md` global:

```powershell
.\scripts\sync-zcode.ps1          # skills + AGENTS.md + commands (config MCP TIDAK disentuh)
.\scripts\sync-zcode.ps1 -Mirror  # samakan 100% dengan repo
```

Yang disalin: 437<!--skill-count:437--> skill → `~/.zcode/skills`, `AGENTS.md` (persona Slackercoder + topologi MCP hasil audit 2026-10-06) → `~/.zcode/AGENTS.md`, commands graphify → `~/.zcode/commands`. Config MCP (`~/.zcode/cli/config.json`) **TIDAK disentuh** — MCP dikelola langsung di Z Code (8 server aktif di blok `mcp.servers`; sync lama dari `~/.claude.json` dihapus karena menimpa kurasi Z Code dan membuat blok dobel). Jalankan saat Z Code tertutup.

### Sinkron ke Codex

**Codex** (OpenAI, CLI + desktop) memakai path skill resmi `~/.agents/skills` (standar agentskills.io) + `AGENTS.md` global di `~/.codex`:

```powershell
.\scripts\sync-codex.ps1          # skills (resmi + legacy) + AGENTS.md + BEST-PRACTICE.md
.\scripts\sync-codex.ps1 -Mirror  # samakan 100% dengan repo (folder .system Codex tetap aman)
```

Yang disalin: 437<!--skill-count:437--> skill → `~/.agents/skills` (path resmi user-scope) dan `~/.codex/skills` (legacy, agar tidak basi; bundled `.system` tidak disentuh), `AGENTS.md` (padanan penuh Rules TRAE WORK) + `BEST-PRACTICE.md` → `~/.codex/` (backup lama otomatis), serta arsip otomatis `rules/slackercoder-rules.md` yang inert (engine rules Codex hanya membaca file `.rules` Starlark). Jalankan saat Codex tertutup. Catatan: memories Codex (`~/.codex/memories/`) = state generated, jangan edit manual — memory kanonik tetap di TRAE.

### Dukungan macOS (MacBook)

Semua perintah `.ps1` punya padanan bash. Prasyarat: macOS + Terminal + Git (`xcode-select --install` bila belum ada) + TRAE IDE. Jalankan sekali setelah clone:

```bash
chmod +x scripts/*.sh   # sekali saja setelah clone
./scripts/install.sh             # pasang skills + memory ke ~/.trae/skills (backup otomatis)
./scripts/install.sh --mirror    # identik 100% dengan repo
./scripts/install.sh --skip-memory
```

Alur sinkron harian di MacBook:

```bash
./scripts/collect.sh                     # kumpulkan skill/memory lokal -> repo -> GitHub
./scripts/collect.sh -m "pesan" --no-push

git pull && ./scripts/install.sh         # terima pembaruan dari komputer lain

./scripts/sync.sh claude                 # sinkron ke Claude Code CLI (~/.claude)
./scripts/sync.sh zcode                  # sinkron ke Z Code (~/.zcode; MCP tidak disentuh)
./scripts/sync.sh codex                  # sinkron ke Codex (~/.agents/skills + legacy)
./scripts/sync.sh all --mirror           # semuanya sekaligus, identik penuh

./scripts/verify.sh                      # verifikasi silang jumlah + sidik jari
```

Catatan macOS:

| Hal | Keterangan |
|-----|------------|
| Python skill blog | Pakai `python3` sistem (butuh ≥ 3.11). Install: `brew install python@3.12` + `python3 -m pip install --user textstat beautifulsoup4` |
| Skill REA | Belum tersedia di macOS (installer Windows-only: Ghidra/JDK di `C:\tools`) — gunakan mesin Windows untuk REA |
| `update-inventory.ps1` | Hanya Windows — regenerasi `skills/INVENTORY.md` jalankan via `collect.ps1` di mesin Windows |
| rsync/md5 | Bawaan macOS — tidak perlu install tambahan |

---

## Skill REA (Reverse Engineer Anything)

Skill `skills/reverse-engineer-anything/` untuk reverse engineering berkas hasil build (binary) — men-jelaskan fitur, membandingkan versi, dan dekompilasi kode. Cakupan target: **native (.exe/.dll/firmware via Ghidra), managed, Electron/JavaScript, packaged, dan APK Android (via jadx)**. Skill hanya berisi instruksi — **tidak membawa engine analisisnya**. Dependensi dipasang otomatis per komputer via:

```powershell
.\scripts\install-rea.ps1          # install/refresh semua dependensi (idempoten)
.\scripts\install-rea.ps1 -Doctor  # hanya cek kesehatan (rea doctor)
```

| Dependensi | Fungsi | Dipasang ke |
|------------|--------|-------------|
| `rea-agents` (npm global, Node ≥ 22.19) | Server MCP + CLI REA | npm global |
| JDK 21 (Temurin, portable) | Prasyarat Ghidra & jadx | `C:\tools\jdk-21` |
| Ghidra 12.1.4 | Analisis native: exe/dll/ELF/firmware | `C:\tools\ghidra_12.1.4_PUBLIC` |
| jadx-headless-mcp 0.7.1 (JAR, SHA-256 diverifikasi) | Dekompilasi APK Android | `C:\tools\jadx-headless-mcp-0.7.1-all.jar` |

Script juga mengatur env user permanen (`GHIDRA_INSTALL_DIR`, `JAVA_HOME`, `REA_ANALYSIS_PROVIDER`, `REA_JADX_MCP_JAR`) dan mendaftarkan MCP `rea` ke Claude Code + Codex + Z Code. Catatan: REA dilarang meng-install sendiri alat di luar daftar ini — jangan ganti Ghidra ke 12.2+ sebelum REA mendukung.

---

## Pantau Update Skill Upstream

Skill dari repo eksternal (antislop, design-taste-frontend, blog multilingual) tidak update sendiri — pantau lewat manifest:

```powershell
.\scripts\check-upstream.ps1                  # cek semua sumber, tampilkan laporan
.\scripts\check-upstream.ps1 -UpdateManifest  # sekalian catat versi terbaru ke manifest
```

Cara kerja: `upstream-manifest.json` mencatat repo sumber + versi terakhir yang sudah kita tarik. Script memanggil API publik GitHub (tanpa API key) dan menandai `ADA UPDATE` bila ada rilis/commit lebih baru. **Skill baru dari repo eksternal = wajib tambah entrinya ke manifest.** Catatan: rilis upstream sering hanya menyentuh README/installer — selalu diff SKILL.md sebelum menyalin penuh.

---

## Yang TIDAK Ikut Tersinkron (Atur Manual per Komputer)

| Hal | Alasan | Cara Atur |
|-----|--------|-----------|
| Python 3.12 | Skill blog butuh Python 3.11+ | Pasang Python 3.12 ke `C:\Python312` |
| Dependensi blog (`textstat`, `beautifulsoup4`) | Dipasang per komputer | `C:\Python312\python.exe -m pip install --user textstat beautifulsoup4` |
| Server MCP (Context7, zai-vision, dll) | Dikelola TRAE per komputer | Aktifkan manual di pengaturan TRAE |
| Kredensial 9router (`~/.9router/env`) | Rahasia, sengaja di luar repo | Buat file berisi `NINEROUTER_URL` dan `NINEROUTER_KEY`, lalu jalankan `install-imagegen.ps1 -Apply` dan `register-imagegen.ps1 -Apply` |

---

## Update 2026-11-24 — Baca Dulu di Komputer Lain

Sinkron skill **tidak** memasang MCP dan **tidak** mengubah model Claude Code. Setelah `pull`, lakukan sekali per komputer:

1. **Kredensial.** Buat `~/.9router/env` berisi dua baris: `NINEROUTER_URL=https://...` dan `NINEROUTER_KEY=...`. Isinya rahasia — jangan commit, jangan tampilkan di chat atau log.
2. **Pasang runtime.** `pwsh -File scripts/install-imagegen.ps1 -Apply`
3. **Daftarkan ke agent.** `pwsh -File scripts/register-imagegen.ps1 -Apply`
   Keduanya dry-run sampai `-Apply` diberikan. Untuk sebagian agent: `-Agen trae`, `-Agen traesolo`, `-Agen zcode`, atau `-Agen claude`. Node default `C:\nvm4w\nodejs\node.exe` — ganti `-Node` bila beda.
4. **Restart** TRAE, TRAE SOLO, ZCode, dan Claude Code agar config baru terbaca.
5. **Uji.** Panggil `list_image_models`, lalu `generate_image` dengan `n=1` dan `output_dir = <folder project aktif>/generated-images`.

### MCP `dci-tts` (pembuat suara) — langkah 2 dan 3 di atas menjadi:

2b. **Pasang runtime.** `pwsh -File scripts/install-tts.ps1 -Apply`
3b. **Daftarkan ke agent.** `pwsh -File scripts/register-tts.ps1 -Apply`
5b. **Uji.** Panggil `list_free_voices`, lalu `text_to_speech` dengan `voice = edge-tts/id-ID-ArdiNeural` (gratis), `segments` teksnya, dan `output_dir = <folder project aktif>/generated-audio`. Batch maks 10 adegan; lebih dari 6 wajib `confirmed=true`. Suara premium (OpenAI/ElevenLabs/Gemini TTS) baru bisa dipakai setelah koneksi provider TTS ditambahkan di dashboard 9router — MCP tidak perlu diubah.

Model utama Claude Code sekarang `glm-5.4[1m]`; Haiku tetap `glm-5.3-flash[1m]`. Jalankan `scripts/sync-claude.ps1` untuk menyelaraskan template — token dan plugin lokal dipertahankan. Cek dengan `/status` setelah restart. Koefisien kuota GLM-5.4 belum diverifikasi, jangan menganggapnya sama dengan GLM-5.3.

**Batas pemakaian:** setiap gambar memakai kuota ChatGPT di 9router. Pakai `n=1` kecuali diminta varian; lebih dari 4 butuh persetujuan. Hasil berlatar putih, ukuran ditentukan model, mode edit menggambar ulang (tidak setia pada tata letak), paralel maksimal 2 gambar. Folder hasil gambar sudah masuk `.gitignore`. Codex tidak dipasang karena sudah punya `$imagegen` sendiri.

**BytePlus:** bila komputer lain masih punya MCP `byteplus-image` atau env `ARK_API_KEY`, cabut keduanya dan cabut izin key di console BytePlus. Cadangan config lama sengaja disensor, bukan dihapus.

**Pembalikan:** `pwsh -File scripts/register-imagegen.ps1 -Hapus -Apply`.

---

## Membuat MCP Baru — Pola `dci-imagegen`

`mcp/dci-imagegen/` bisa dipakai sebagai acuan. Ini server **stdio** Node.js (`type: module`, Node ≥22) dengan SDK `@modelcontextprotocol/sdk` 1.32.2 dan `zod` 4.6.7 — versi dikunci di `package-lock.json`. Cek dokumentasi SDK lewat Context7 sebelum mengubah versi.

| Berkas | Peran |
|--------|-------|
| `src/index.js` | Titik masuk. Hubungkan `buatServer()` ke `StdioServerTransport`. Hanya protokol MCP yang boleh keluar ke stdout; log pakai `console.error`. |
| `src/server.js` | Definisi tool lewat `server.registerTool(nama, { description, inputSchema }, handler)`. Schema input pakai `zod`. Contoh: `list_image_models`, `generate_image`. |
| `src/config.js` | Baca kredensial dari `~/.<nama>/env` (bukan dari config agent). Environment menimpa berkas; URL wajib HTTPS kecuali localhost. |
| `src/router-client.js`, `src/generate.js`, `src/images.js`, `src/folders.js`, `src/errors.js` | Klien HTTP, logika bisnis, penyimpanan berkas, dan error yang disensor agar key tidak bocor. |
| `test/*.test.js` | `npm test` → `node --test`. Kode awal: 39 tes, 38 lulus, 1 dilewati. Uji mutasi ada di `scripts/uji-mutasi.ps1`. |
| `scripts/panggil.mjs` | Pemanggil manual untuk uji tanpa agent. |

**Alur membuat MCP baru:**
1. Salin folder sebagai template, ganti semua nama dengan prefix `dci_` dan sesuaikan `package.json` (`name`, `main`).
2. Tambah tool di `src/server.js`. Letakkan aturan pemakaian (batas jumlah, butuh konfirmasi, folder hasil) di `description` supaya agent membacanya sebelum memanggil.
3. Simpan rahasia di `~/.<nama>/env`, jangan pernah di config agent, README, atau log. Gunakan sanitasi error seperti `sensor()` di `src/errors.js`.
4. Jalankan `npm test` di folder MCP. Tambah tes untuk setiap cabang baru.
5. Adaptasi `scripts/install-imagegen.ps1` (tujuan runtime) dan `scripts/register-imagegen.ps1` (nama server, path entri, daftar agent). Keduanya dry-run sampai `-Apply`.
6. Daftarkan, restart agent, lalu uji satu panggilan nyata dengan nilai terkecil. Cabut lewat `-Hapus -Apply` bila perlu.

Header tiap berkas kode wajib memuat `Author: Mas Wondho — Duta Corpora Indonesia (DCI)` dan `Copyright © 2026 Duta Corpora Indonesia`. Kredensial dan hasil generate sengaja di luar repo.

---

## Komponen Utama (437<!--skill-count:437--> Skill)

| Kategori | Jumlah | Contoh Pemicu |
|----------|--------|---------------|
| Mesin blog (claude-blog v2.2.0) | 32 | "tulis blog", "audit SEO", "topic cluster" |
| DevOps-Security (BagelHole) | 163 | "k8s", "hardening", "SOC2", "vault" |
| Marketing (Cesarjoquin v2.5.1) | 45 + tools | "copywriting", "CRO", "landing page" |
| Playwright best practices | 1 | "test E2E", "perbaiki test flaky" |
| Keluarga antislop (v3.2.24 — sumber: [miqdadbadjuber/anti-slop](https://github.com/miqdadbadjuber/anti-slop), MIT) | 6 | tulisan/kode/a11y/mobile — arah desain frontend dipimpin design-taste-frontend |
| Design taste frontend (v2.1.5 — sumber: [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill), MIT) | 1 | "landing page premium", "redesign", "page terlihat generik" — lihat `skills/_TASTE-SKILLS-INTEGRASI.md` |
| prd-builder v2 | 1 | "buat PRD", "rancang aplikasi" |
| rab-builder | 1 | "buat RAB", "hitung biaya pembuatan" (vibe coding, z.ai Max $80/bln) |
| Ponytail (v4.2.0 — sumber: [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), MIT) | 6 | aturan coding minimalis rules kita (prinsip #4); "ponytail", "be lazy", "yagni", review/audit kode |
| mastermind | 1 | "recon", "scanner", "kit phishing", "checker", "laporan intelijen", "analisis malware" |
| Skill pendukung lainnya | ±40 | frontend, pengujian, dokumen, dll |

---

## Catatan Teknis

- Skill Python (blog) wajib pakai `C:\Python312\python.exe` — Python bawaan TRAE hanya 3.10, tidak memenuhi syarat 3.11+.
- Skrip `.sh` (DevOps-Security) hanya untuk Linux — tidak berjalan otomatis di Windows, hanya jadi referensi.
- Setelah memasang di komputer baru, server MCP yang dipakai skill (Context7, zai-vision, dan lainnya) perlu diaktifkan manual di TRAE.
- Folder `__pycache__`, `*.pyc`, dan `node_modules` otomatis dikecualikan (lihat `.gitignore`).

---

## Untuk Anggota Slackercode Family Lain

1. Minta akses kolaborator ke akun GitHub **alecslacker** (repo ini private).
2. Clone repo, jalankan `.\scripts\install.ps1`, restart TRAE.
3. Kalau menambah / memperbaiki skill: jalankan `.\scripts\collect.ps1` agar semua komputer keluarga mendapat pembaruan yang sama.

**Satu sumber kebenaran: repo ini.** Semua komputer menyamakan diri ke sini — bukan saling menyalin acak.

---

*Dibangun dan dirawat oleh Slackercode Family.*

Copyright © 2026 Duta Corpora Indonesia — All rights reserved
