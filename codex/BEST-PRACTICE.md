# BEST-PRACTICE.md — OpenAI Codex (CLI & Desktop)

> Rangkuman best practice resmi + temuan riset, 2026-10-05 (sumber utama: developers.openai.com/codex, agentskills.io, config-reference; versi acuan **0.160.0**, rilis 2026-10-02). File ini referensi — aturan aktif ada di `AGENTS.md`.

## Identitas Produk

- **Codex** = agentic coding tool OpenAI. Dua wajah: Codex CLI (open source, github.com/openai/codex) + Codex Desktop/App (bundled plugin: browser, documents, pdf, spreadsheets, presentations, computer-use).
- Setup Mas Wondho: `CODEX_HOME = C:\Users\alecs\.codex`, model `gpt-6-astra`, Windows sandbox `elevated`, memories ON.

## Aturan & Config (terverifikasi)

| File | Isi |
|------|-----|
| `~/.codex/AGENTS.md` | Rules global — dibaca otomatis tiap sesi. `AGENTS.override.md` menimpa bila ada. **Cap chain 32 KiB** (gabungan global + semua AGENTS.md project root→CWD). |
| `~/.codex/config.toml` | Model, sandbox, approval, plugin, MCP (`mcp_servers`), trust per project, fitur (`memories`). |
| `~/.agents/skills/` | **Path resmi skill user-scope** (standar agentskills.io). `~/.codex/skills` = legacy (tidak ada di docs 0.160). |
| `~/.agents/mcp.json` | MCP tambahan gaya Claude Code (flat `mcpServers`). |
| `~/.codex/rules/*.rules` | Engine rules **Starlark**: `prefix_rule(pattern, decision allow/prompt/forbidden)` untuk kontrol eksekusi command. **File `.md` di folder ini TIDAK dibaca.** `default.rules` dibuat otomatis TUI saat approve command. |
| `<project>/AGENTS.md` | Rules project — digabung root-down; yang paling dekat file yang diedit menang; chat prompt eksplisit menimpa semuanya (FAQ agents.md). |

**Precedence AGENTS.md** [CONFIRMED docs]: global → project root → turun ke CWD, merge bukan replace. `project_doc_max_bytes` default 32 KiB untuk seluruh chain — file berhenti ditambah begitu cap tersentuh (bisa terpotong tanpa warning). Naikkan hanya sebagai solusi sementara; solusi benar = pecah ke nested dirs / skills.

## Skills (standar agentskills.io)

- Format: folder + `SKILL.md` frontmatter `name` (≤64 char kebab-case, match nama folder) + `description` (≤1024 char). Body disarankan <500 baris / <5000 token.
- **Progressive disclosure**: metadata (name+description) dimuat di startup untuk SEMUA skill; isi penuh SKILL.md baru dimuat saat skill diaktivasi.
- Invokasi: eksplisit `$skill-name` / `/skills`, atau implisit via matching `description`. Disable per-skill via `[[skills.config]]` di config.toml atau `allow_implicit_invocation: false` di `agents/openai.yaml`.
- Timeline: eksperimental v0.65.0 (2025-10-06) [SINGLE-SOURCE]; resmi Desember 2025 [MAJORITY].
- Marketplace resmi ada, tapi unitnya **plugin**; skill kurasi via `$skill-installer` (mis. `$skill-installer linear`); repo resmi github.com/openai/skills.
- **Implikasi 302 skill kita**: injeksi metadata besar tiap sesi → bila auto-trigger melemah, panggil eksplisit `$name`. Jangan disable demi sinkronisasi (identitas dengan TRAE dipertahankan).

## Memories

- Config: `[features] memories = true` + `[memories] generate_memories / use_memories / disable_on_external_context / extract_model / consolidation_model`.
- Cara kerja: thread selesai → Codex ekstrak konteks berguna → file di `~/.codex/memories/` (summaries, durable entries, evidence); redact secret; update background saat idle. Lewati sesi aktif/pendek.
- **BY DESIGN bukan untuk diedit manual** — docs resmi: "Treat these files as generated state... don't rely on editing them by hand as your primary control surface." Kontrol = config + `/memories` (per-thread) + settings app. Tidak ada padanan `user_profile.md` TRAE.
- Memory kanonik lintas-agent Mas Wondho tetap di TRAE native (`~/.trae/memory/`) — Codex memories hanya recall layer.

## Sandbox, Approval & Security

| Aspek | Codex |
|---|---|
| Posture default | OS sandbox + **network OFF by default** + approval `on-request` (folder version-controlled) / `read-only` (non-VC) |
| Sandbox modes | `read-only` / `workspace-write` / `danger-full-access` (preset lama suggest/auto-edit/full-auto sudah dihapus) |
| Bypass total | `--yolo` (alias `--dangerously-bypass-approvals-and-sandbox`) — resmi "not recommended" |
| Headless | `codex exec` — tanpa interaksi; `--full-auto` deprecated (masih diterima + warning) |
| Windows | `[windows] sandbox = "elevated"` = native restricted token + user khusus + firewall rules (terkuat). Setup admin: `codex sandbox setup --elevated`. Alternatif `unelevated` isolasi lebih lemah. |

- `rules/*.rules` Starlark: precedence decision `forbidden` > `prompt` > `allow`. Test: `codex execpolicy check --rules <file> -- <cmd>`.
- Banyak `[projects] trust_level = "trusted"` = project-scoped `.codex/config.toml` + `.codex/rules/` ikut dimuat di project itu.
- Hygiene: `~/.agents/mcp.json` berisi API key plain-text — jangan pernah di-commit / di-copy ke repo.

## Best Practice Eksekusi

1. **Mode sesuai risiko**: default aman sudah bagus. Naik ke `workspace-write` hanya saat butuh; `--yolo` hanya atas instruksi eksplisit Mas Wondho.
2. **Headless (`codex exec`)**: pastikan prompt lengkap + plan jelas; tidak ada interaksi approval di tengah jalan.
3. **AGENTS.md tetap ramping**: global < 30 KB; detail domain = skills (progressive disclosure); kontrol command = `rules/*.rules`.
4. **Skills eksplisit** (`$name`) ketika auto-trigger tidak menangkap — 302 skill = injeksi besar.
5. **Memories = recall** — jangan edit manual; guidance tetap di AGENTS.md.
6. **Setelah edit besar**: `graphify update .` di project terkait (peta codebase tetap segar).
7. **Verifikasi library**: web fetch dokumen resmi / Context7 MCP bila aktif di sesi — jangan andalkan ingatan model.

## Kapan Pakai Codex vs Lainnya

- **Codex**: model frontier OpenAI (gpt-6-astra), sandbox Windows elevated, plugin dokumen (pdf/xlsx/pptx) & computer-use terintegrasi, ekosistem open source.
- **TRAE WORK**: tool utama Mas Wondho — memory native, MCP luas, skills 302 terkurasi.
- **Z Code**: kuota GLM termurah + bonus 1.5x.
- **Claude Code**: terminal-first, hooks & plugin matang.
