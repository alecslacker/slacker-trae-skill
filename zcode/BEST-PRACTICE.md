# BEST-PRACTICE.md — Z Code (Z.ai Agentic Development Environment)

> Rangkuman best practice resmi + temuan komunitas, hasil riset 2026-10-04 (sumber utama: docs resmi zcode.z.ai & docs.z.ai; riset lengkap tersimpan di riwayat sesi). File ini referensi — aturan aktif ada di `AGENTS.md`.

## Identitas Produk

- **ZCode** = Agentic Development Environment (ADE) resmi Z.ai, launch 1 Juli 2026, **open source Apache-2.0** sejak 21 Sep 2026 (github.com/zai-org/ZCode). Model tuning saat ini: **GLM-5.3**.
- Tiga front-end satu runtime: Desktop (Electron), Web (`zcode --web`), TUI (`zcode`).
- Bonus **kuota 1.5x** Coding Plan bila dipakai DI DALAM ZCode (vs endpoint API biasa).

## Aturan & Config (terverifikasi)

| File | Isi |
|------|-----|
| `~/.zcode/AGENTS.md` | Rules global — HANYA 2 sumber aturan: ini + `<workspace>/AGENTS.md`. Tidak ada scan subdirektori / `@import`. **`CLAUDE.md` TIDAK dibaca runtime** (migrasi one-time saat onboarding saja). |
| `~/.zcode/cli/config.json` | MCP, permission default, toggle plugin/skill, hooks. |
| `~/.zcode/v2/config.json` | Model provider (API key, base URL, daftar model). |
| `~/.zcode/{agents,skills,commands}/` | Subagent (`~/.zcode/agents/<name>.md`, user-level saja), skill (`SKILL.md`, panggil `$skill`), custom command (markdown, `/command`). |
| `<project>/.zcode/config.json` | Override workspace (prioritas: workspace > user; `.zcode` > `.agents`). |

**MCP — dua format kunci (penting untuk setup kita):**
- Nested `mcp.servers` = format terdokumentasi resmi di `config.json`.
- Flat `mcpServers` = jalur kompatibilitas gaya Claude Code (file `.agents/mcp.json` / manifest plugin).
- Docs resmi tidak menyatakan satu file membaca keduanya → setup kita menulis KEDUA kunci di `config.json` (dual-write via `sync-zcode.ps1`) tetap merupakan solusi yang benar agar CLI & UI sama-sama melihat 17 MCP.
- BREAKING: kunci config `mode` diganti `subagent` — edit manual config.json tidak dimigrasi otomatis.
- JANGAN salin antar mesin: `~/.zcode/v2/credentials.json` (enkripsi per-device) & `telemetry-state.json` (device ID).
- `setting.json` = format klien komunitas tidak resmi (zcode-app-cli npm) — bukan resmi.

## Best Practice Eksekusi

1. **Mode sesuai risiko** (Shift+Tab): Ask before changes (default) / Edit automatically / Plan mode / Full access. CLI: `--mode build|edit|plan|yolo`.
   ⚠️ **Headless default = yolo (auto-approve semua tool call!)** — script/CI WAJIB eksplisit `--mode build|plan`.
2. **Goal Mode** (`/goal <objektif>`): objektif jadi state machine + verifikasi independen tiap iterasi; subcommand pause/resume/replace/clear. Goal HARUS spesifik & terverifikasi: "buat `pnpm test` pass dan first-paint <2 detik", bukan "buat lebih cepat".
3. **Thought level** (flexible-effort GLM-5.3): Low/High/Max (default Max). Turunkan ke High/Low untuk Q&A & edit kecil = hemat latensi/kuota; Max untuk arsitektur & bug sulit.
4. **Konteks presisi**: `@` file/folder · `#` percakapan lama · `/` command · `$` skill · `+` attachment. Teks tempel panjang otomatis jadi attachment.
5. **Checkpoint & edit history**: checkpoint = Git-diff lokal di `~/.zcode/checkpoints/`; edit history = revisi prompt lama tanpa restart task.
6. **Idle-time tasks** (subscriber): kerja non-urgent dijalankan gratis di kapasitas kosong, tidak memotong kuota — cocok untuk cleanup/dokumentasi.
7. **Subagent**: bawaan `general-purpose` + `Explore` (read-only); custom via Settings. Tanpa override, subagent mewarisi model sesi induk (bukan bug).

## Skill Budget (RELEVAN UNTUK 302 SKILL KITA)

- Tiap turn meng-inject metadata semua skill aktif (nama + deskripsi ≤250 kar per skill) ke context.
- Terlalu banyak skill → injeksi terdegradasi jadi nama saja → **auto-trigger anjlok**.
- `description` wajib spesifik KAPAN skill dipakai; maks **1024 karakter** (lebih → skill didrop).
- Skill "terlihat tapi tak pernah kepakai" = checklist resmi: metadata terdegradasi / deskripsi vagu / allowlist `tools` subagent tak memuat / plugin induk disabled.
- **Implikasi kita**: 302 skill = zona risiko. Bila auto-trigger melemah di Z Code, opsi = disable skill jarang pakai via Settings (di TRAE tetap penuh — karena kita memilih TIDAK mengubah isi skill agar identik; lihat AGENTS.md bagian Skill).

## Keamanan & Hygiene

- **Insiden upload workspace (Sep 2026)**: v3.12.3 mengunggah snapshot workspace terenkripsi (86.6% isi `.git`) ke Alibaba Cloud OSS; opt-out rusak. Dihapus di 3.14.0 → **selalu pakai versi terbaru**, jangan versi lama.
- `~/.zcode/cli/exec` membengkak (riwayat output terminal tak dibersihkan) — aman dihapus saat app tertutup.
- Linux/WSL: AppImage butuh `libfuse2`; handler `zcode://` sering salah; bug input CJK di WSLg.

## Kuota (GLM Coding Plan)

- Endpoint Coding Plan WAJIB `/api/coding/paas/v4` — salah endpoint = kuota hangus.
- Multiplier jam sibuk 14:00–18:00 UTC+8 potong kuota 3x (GLM-5.2/turbo); off-peak 2x. Cek aturan terkini — pricing bergerak cepat.
- Satu task agentic berat bisa makan puluhan juta token (thinking + loop) — scope goal sempit.
- Endpoint Anthropic-compatible untuk Claude Code: `ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic` (model murah tanpa ganti harness, TANPA bonus 1.5x).

## Kapan Pakai Z Code vs Lainnya

- **ZCode**: kuota termurah + bonus 1.5x, GUI cockpit satu jendela, Goal Mode terverifikasi, provider mixing per-subagent, remote WeChat/Feishu, sovereign/self-host (GLM weights tersedia).
- **Claude Code**: terminal-first, CI scripting, hooks ekosistem matang, plugin besar, data residency AS.
- **TRAE WORK**: IDE-fokus multi-model, memory native, agent plugins — tetap tool utama Mas Wondho.
