# SLACKER TRAE SKILL

> **Milik Slackercode Family** — kumpulan skill TRAE IDE milik Mas Wondho (alecslacker), tersinkron otomatis antar komputer lewat GitHub.

Repo ini berisi **289 skill TRAE IDE** yang sudah dikurasi, diaudit keamanannya, dan siap pakai — dari blog engine, keamanan DevOps, marketing, sampai generator gambar Seedream.

> ⚠️ **Repo ini PRIVATE, khusus Slackercode Family.** Folder `memory/` berisi profil preferensi pribadi — jangan pernah diubah ke publik.

---

## Isi Repo

| Folder / File | Isi |
|---------------|-----|
| `skills/` | 289 folder skill lengkap (lihat tabel di bawah) |
| `memory/` | Profil preferensi (`user_profile.md`) — dibaca TRAE setiap sesi |
| `scripts/install.ps1` | Pemasang skill untuk komputer baru |
| `scripts/collect.ps1` | Pengumpul perubahan skill lokal → repo → GitHub |

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

---

## Yang TIDAK Ikut Tersinkron (Atur Manual per Komputer)

| Hal | Alasan | Cara Atur |
|-----|--------|-----------|
| `ARK_API_KEY` (BytePlus Seedream) | Kunci API = rahasia, tidak boleh masuk git | `[Environment]::SetEnvironmentVariable('ARK_API_KEY','ark-xxx','User')` |
| Python 3.12 | Skill blog butuh Python 3.11+ | Pasang Python 3.12 ke `C:\Python312` |
| Dependensi blog (`textstat`, `beautifulsoup4`) | Dipasang per komputer | `C:\Python312\python.exe -m pip install --user textstat beautifulsoup4` |
| Server MCP (Context7, zai-vision, dll) | Dikelola TRAE per komputer | Aktifkan manual di pengaturan TRAE |

---

## Komponen Utama (289 Skill)

| Kategori | Jumlah | Contoh Pemicu |
|----------|--------|---------------|
| Mesin blog (claude-blog v2.2.0) | 32 | "tulis blog", "audit SEO", "topic cluster" |
| DevOps-Security (BagelHole) | 163 | "k8s", "hardening", "SOC2", "vault" |
| Marketing (Cesarjoquin v2.5.1) | 45 + tools | "copywriting", "CRO", "landing page" |
| Playwright best practices | 1 | "test E2E", "perbaiki test flaky" |
| Keluarga antislop | 6 | semua tugas UI / tulisan |
| prd-builder v2 | 1 | "buat PRD", "rancang aplikasi" |
| byteplus-seedream5 | 1 | "generate gambar", "hero banner" |
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
