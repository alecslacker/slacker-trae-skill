# TRAE Skills — Repo Sinkronisasi Multi-Komputer

Kumpulan **289 skill TRAE IDE** milik Mas Wondho (Duta Corpora Indonesia), tersinkron antar komputer via GitHub.

> **WAJIB repo PRIVATE** — `memory/` berisi profil preferensi pribadi. Jangan ubah ke public.

## Isi Repo

| Folder | Isi |
|--------|-----|
| `skills/` | 289 folder skill (blog engine, DevOps-Security 163 skill, Marketing 45 skill, playwright, antislop family, prd-builder, byteplus-seedream5, dll) |
| `memory/` | Profil preferensi (`user_profile.md`) — dibaca TRAE tiap sesi |
| `scripts/install.ps1` | Installer untuk komputer baru |
| `scripts/collect.ps1` | Pengumpul perubahan lokal → repo → GitHub |

## Setup Pertama (Sekali Saja)

```powershell
# 1. Buat repo PRIVATE di https://github.com/new (nama bebas, misal: trae-skills)
# 2. Dari folder repo lokal ini:
git remote add origin https://github.com/USERNAME/trae-skills.git
git branch -M main
git push -u origin main
```

## Komputer Baru / Lain (Sekali Saja)

```powershell
# 1. Install git + TRAE IDE
# 2. Clone repo:
git clone https://github.com/USERNAME/trae-skills.git
cd trae-skills

# 3. Install semua skill:
.\scripts\install.ps1
#    (skill lokal lama otomatis di-backup ke ~/.trae/skills-backup-[tanggal])

# 4. Restart TRAE IDE — selesai, semua skill aktif.
```

**Opsi install:**
- `.\scripts\install.ps1 -Mirror` — buat identik 100% dengan repo (hapus skill lokal yang tidak ada di repo)
- `.\scripts\install.ps1 -SkipMemory` — skip folder memory

## Alur Harian (Sinkronisasi)

```
Komputer A (ada skill baru/diubah):
    .\scripts\collect.ps1
    → copy skill+memory lokal ke repo → commit → push

Komputer B (mau dapat update):
    git pull
    .\scripts\install.ps1
    → restart TRAE
```

## Yang TIDAK Ikut Tersinkron (Set Manual per Komputer)

| Item | Kenapa | Cara Set |
|------|--------|----------|
| `ARK_API_KEY` (BytePlus Seedream) | API key = rahasia, tidak boleh di git | `[Environment]::SetEnvironmentVariable('ARK_API_KEY','ark-xxx','User')` |
| Python 3.12 | Skill blog butuh interpreter 3.11+ | Install Python 3.12 ke `C:\Python312` |
| Deps blog (`textstat`, `bs4`) | Install per komputer | `C:\Python312\python.exe -m pip install --user textstat beautifulsoup4` |
| MCP servers | Dikelola host TRAE per komputer | Enable manual di TRAE |

## Komponen Utama (289 Skill)

| Kategori | Jumlah | Contoh Trigger |
|----------|--------|----------------|
| Blog engine (claude-blog v2.2.0) | 32 | "tulis blog", "audit SEO", "topic cluster" |
| DevOps-Security (BagelHole) | 163 | "k8s", "hardening", "SOC2", "vault" |
| Marketing (Cesarjoquin v2.5.1) | 45 + tools | "copywriting", "CRO", "landing page" |
| Playwright best practices | 1 | "test E2E", "fix flaky test" |
| antislop family | 6 | semua task UI/tulisan |
| prd-builder v2 | 1 | "buat PRD", "rancang aplikasi" |
| byteplus-seedream5 | 1 | "generate gambar", "hero banner" |
| Skill bawaan lainnya | ±40 | frontend, testing, dokumen, dll |

## Catatan Teknis

- Skill Python blog: interpreter wajib `C:\Python312\python.exe` (yang di PATH TRAE VM hanya 3.10, tidak memenuhi syarat 3.11+)
- Script `.sh` (DevOps-Security) Linux-only — tidak auto-run di Windows, hanya referensi
- Setelah install di komputer baru, MCP yang dipakai skill (Context7, zai-vision, dll) perlu di-enable manual di TRAE
- Jangan commit `__pycache__`, `*.pyc`, `node_modules` — sudah dikecualikan `.gitignore`
