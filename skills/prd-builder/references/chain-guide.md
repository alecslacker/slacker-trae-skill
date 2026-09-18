# Chain Guide — Cara Chain Antar Phase & Skill Lain

File ini menjelaskan cara berpindah dari satu phase ke phase berikutnya, dan kapan harus delegate ke skill lain.

---

## Chain Antar Phase Internal

### Phase 0 → Phase 1: Memory Init + PRD Start

**Trigger**: User memulai proyek baru atau lanjut sesi.

**Langkah**:
1. **CEK** apakah `project_memory.md` sudah ada di `~/.trae/memory/projects/<kunci-project>/` (path resmi native; kunci = nama/slug project, BUKAN folder project)
2. Jika **ada** → baca M001, tampilkan progress terakhir ke user, tanya: lanjut / mulai baru / revisi
3. Jika **tidak ada** → mulai dari Phase 0 (Ice Break) normal
4. Setelah Phase 0 selesai → **TULIS** M001 (PRD Status: "Phase 0 selesai, mulai Phase 1")
5. Lanjut ke Phase 1

---

### Phase 1 → Phase 2: PRD Complete → Implementation Plan

**Trigger**: User konfirmasi PRD final (semua 8 section selesai).

**Langkah**:
1. **UPDATE** M001: "PRD selesai (prd-[nama].md v1.0). Mulai Phase 2."
2. Generate `prd-[nama-proyek].md` → simpan ke `.trae/documents/`
3. Tanya: "PRD sudah jadi. Mau lanjut bikin Implementation Plan dan Task Breakdown?"
4. Jika ya → mulai Phase 2
5. Jika tidak → stop, tawarkan opsi lain

**Yang dibawa ke Phase 2**:
- Semua fitur dari section Core Features (PRD section 3)
- Architecture & tech stack dari PRD section 5 dan 7
- Constraint dari PRD section 2 (timeline, budget)

---

### Phase 2 → Phase 3: Plan → Task Breakdown

**Trigger**: User konfirmasi Implementation Plan.

**Langkah**:
1. **UPDATE** M001: "Plan selesai (plan-[nama].md v1.0). Mulai Phase 3."
2. Generate `plan-[nama-proyek].md`
3. Auto-lanjut ke Phase 3 (tidak perlu tanya, karena Task Breakdown adalah konversi Plan ke checklist)
4. Generate `tasks-[nama-proyek].md`
5. **UPDATE** M001: "Tasks selesai (tasks-[nama].md v1.0)."

---

### Phase 3 → Phase 4: Tasks → Design Spec

**Trigger**: Task Breakdown selesai.

**Langkah**:
1. Tanya: "Mau lanjut bikin Design Spec tampilan UI/UX?"
2. Jika ya → mulai Phase 4 dengan **Sequential Design Process** (lihat SKILL.md Phase 4): rough layout → hierarchy → tokens (dari PRD Section 8) → interaction → accessibility → edge state → AI Test
3. Generate aset visual via `byteplus-seedream5` (style konsisten satu project)
4. Jika tidak → tawarkan opsi lain (lihat Chain ke Skill Lain di bawah)
5. Setelah Phase 4 selesai → **UPDATE** M001: "Design Spec selesai (wireframe-[nama].md v1.0, AI Test LULUS). Semua fase selesai."

---

## Resume Sesi (Sesi Baru, Proyek Lama)

**Trigger**: User memulai sesi baru dan project memory sudah ada.

```
User: "Lanjutkan proyek [nama]"
  ↓
Agent: BACA project_memory.md
  ↓
Agent: Tampilkan ringkasan:
  "Sesi terakhir kita sudah sampai [Phase X]. Berikut ringkasan keputusan yang sudah dibuat:
  - [Ringkasan M002-M0XX]
  Mau lanjut dari situ, mulai baru, atau revisi?"
  ↓
User pilih:
  ├── "Lanjut" → baca memory entries terkait, langsung ke phase/section terakhir
  ├── "Mulai baru" → tanya: overwrite memory atau proyek baru?
  └── "Revisi [section]" → baca entry terkait, tampilkan, tanya apa yang diubah
```

**Yang HARUS dibaca dari memory saat resume**:
- M001: Status progress (tau di mana kita berhenti)
- M002-M012: Semua keputusan yang sudah disepakati (jangan tanya ulang)
- File output yang sudah ada di `.trae/documents/`

---

## Memory Update Flow per Phase

```
Phase 0 (Ice Break)
  → TULIS M001: "Phase 0 selesai. Proyek: [nama]. Ide: [ringkasan]."
  ↓
Phase 1 (PRD, 8 section)
  → Setelah setiap section: TULIS M002-M012
  → Setelah semua selesai: UPDATE M001: "PRD selesai. prd-[nama].md v1.0"
  ↓
Phase 2 (Plan)
  → Setelah selesai: UPDATE M001: "Plan selesai. plan-[nama].md v1.0"
  ↓
Phase 3 (Tasks)
  → Setelah selesai: UPDATE M001: "Tasks selesai. tasks-[nama].md v1.0"
  ↓
Phase 4 (Wireframe)
  → Setelah selesai: UPDATE M001: "Semua fase selesai. Siap implementasi."
```

---

## Chain ke Skill Lain

Setelah Phase 3 (atau Phase 4) selesai, tawarkan opsi lanjutan:

### Opsi A: Mulai Coding

**Jika user bilang**: "Mulai coding", "Lanjut implementasi", "Kerjakan task-nya"

| Kondisi | Skill yang Dipakai | Alasan |
|---------|-------------------|--------|
| Task pertama dari breakdown | `test-driven-development` | Mulai dengan TDD untuk fondasi yang kuat |
| Task setup/konfigurasi | Langsung kerjakan + `git-commit` | Setup biasanya straightforward |
| Task UI/frontend | `frontend-design` atau `frontend-skill` | Untuk hasil UI yang polished |
| Task melibatkan library eksternal | WAJIB cek Context7 dulu | Pastikan API terbaru |

**Penting**: Saat mulai coding, gunakan tasks-[nama-proyek].md sebagai checklist. Update status `- [ ]` ke `- [x]` setiap kali task selesai.

---

### Opsi B: Wireframe / Design Spec Lebih Detail

**Jika user bilang**: "Buat wireframe lebih detail", "Bikin mockup", "Desain UI"

| Kondisi | Skill yang Dipakai |
|---------|-------------------|
| Wireframe HTML interaktif | `dynamic-ui` atau `frontend-skill` |
| Landing page / website visual kuat | `frontend-skill` |
| Komponen UI production-grade | `frontend-design` (aesthetic bold, anti font generik) |
| Generate hero/ilustrasi/logo aset visual | `byteplus-seedream5` (Dola Pro utk teks Indonesia, Lite utk 4K/batch) |
| HTML report / dashboard | `html-report` |
| HTML slide deck | `html-deck` |

**Aturan aset visual (Anti-Slop Layer 7)**: prompt Seedream WAJIB memuat 5 elemen — (1) tujuan penggunaan, (2) style konsisten dgn aset lain di project sama, (3) palette hex dari Design Tokens PRD Section 8, (4) mood sesuai vibe, (5) komposisi. Semua aset satu project = satu style.

---

### Opsi B2: Design QA Gate (Post-Implementasi)

**Jika user bilang**: "Cek desainnya", "Audit UI", "Review tampilan"

| Kondisi | Skill/Tool yang Dipakai |
|---------|------------------------|
| Review kode UI vs Web Interface Guidelines | `web-design-guidelines` (fetch rules terbaru + findings format file:line) |
| Screenshot UI untuk verifikasi visual | `webapp-testing` (Playwright) atau integrated_browser |
| Bandingkan implementasi vs design spec | `ui_diff_check` (mcp_zai-vision) |
| AI Test 7 pertanyaan ulang di UI final | Checklist dari wireframe-[nama].md + screenshot |
| Aksesibilitas mendalam | Kontras 7:1, keyboard nav, screen reader — dari Phase 4 step 5 |

**Urutan Design QA yang benar**: screenshot dulu → web-design-guidelines review kode → ui_diff_check vs spec → AI Test final. Semua findings diperbaiki sebelum deploy.

---

### Opsi C: Review & Quality

**Jika user bilang**: "Review kodenya", "Cek keamanan", "Audit"

| Kondisi | Skill yang Dipakai |
|---------|-------------------|
| Review kode yang sudah ditulis | `git-commit` (untuk commit + review) |
| Security audit | `security-best-practices` |
| UI review (Web Interface Guidelines) | `web-design-guidelines` |
| Test web app | `webapp-testing` |

---

### Opsi D: Riset & Pembelajaran

**Jika user bilang**: "Pelajari library X", "Cek best practices"

| Kondisi | Skill/Tool yang Dipakai |
|---------|------------------------|
| Cek dokumentasi library | Context7 MCP (`resolve-library-id` → `query-docs`) |
| Cari di repo GitHub | `zread` MCP (`search_doc`, `read_file`) |
| Baca halaman web | `web-reader` MCP (`webReader`) |
| Riset komprehensif | `research-guide` skill |

---

## Skenario Chain Lengkap

```
User: "Saya mau bikin aplikasi warung online"
  ↓
[prd-builder Phase 0-1] → prd-warung-online.md
  ↓
[prd-builder Phase 2] → plan-warung-online.md
  ↓
[prd-builder Phase 3] → tasks-warung-online.md
  ↓
User: "Mau lihat tampilannya dulu"
  ↓
[prd-builder Phase 4] → wireframe-warung-online.md
  ↓
User: "Oke, mulai coding"
  ↓
[frontend-design atau TDD] → implementasi task T-01, T-02, ...
  ↓
[Update tasks-warung-online.md] → centang task yang selesai
  ↓
[git-commit] → commit dengan conventional message
```

---

## Integrasi Plugins & MCP per Phase

Selain chain ke skill, skill ini bisa memanfaatkan MCP servers dan plugins yang tersedia. Berikut detail kapan dan bagaimana menggunakan.

### Phase 0 (Ice Break) — Riset Kompetitor & Referensi

**Trigger**: User menyebut aplikasi lain sebagai referensi, atau butuh riset kompetitor.

| Tool | Cara Pakai | Contoh Penggunaan |
|------|-----------|-------------------|
| `web_search_prime` (mcp_web-search-prime) | `run_mcp(server_name="mcp_web-search-prime", tool_name="web_search_prime", args={search_query: "aplikasi kasir UMKM Indonesia terbaik 2026"})` | User bilang "saya mau bikin seperti aplikasi X" → riset apa itu X |
| `webReader` (mcp_web-reader) | `run_mcp(server_name="mcp_web-reader", tool_name="webReader", args={url: "https://aplikasi-x.com"})` | Baca fitur-fitur kompetitor langsung dari website |
| `ui_to_artifact` (mcp_zai-vision) | `run_mcp(server_name="mcp_zai-vision", tool_name="ui_to_artifact", args={image_url: "path/to/screenshot.png"})` | User kirim screenshot → ekstrak design pattern |
| `browser_snapshot` (integrated_browser) | Navigasi ke URL referensi, lalu snapshot | Capture struktur website kompetitor |

**Cara tawarkan ke user**: "Mau saya riset kompetitor dulu? Kalau ada website atau screenshot referensi, saya bisa analisis."

---

### Phase 1 (PRD) — Saat Menjawab Pertanyaan

| Tool | Section | Cara Pakai |
|------|---------|-----------|
| `sequentialthinking` (mcp_sequential-thinking) | Section 5 (Architecture) | `run_mcp(server_name="mcp_sequential-thinking", tool_name="sequentialthinking", args={thought: "Membandingkan arsitektur monolith vs microservice untuk aplikasi warung..."})` |
| `resolve-library-id` → `query-docs` (mcp_context7) | Section 7 (Tech Stack) | WAJIB. Setiap library yang direkomendasikan harus dicek API-nya masih valid. `resolve-library-id` untuk dapat ID, lalu `query-docs` untuk baca dokumentasi. |
| `get_figma_data` (mcp_Figma_AI_Bridge) | Section 4 (User Flow) / Phase 4 | Jika user punya desain di Figma, baca langsung: `run_mcp(server_name="mcp_Figma_AI_Bridge", tool_name="get_figma_data", args={figma_url: "..."})` |
| `get-wireframe-tool` (mcp_needmcp) | Section 4 / Phase 4 | Generate wireframe layout otomatis saat brainstorm |
| `analyze_image` (mcp_zai-vision) | Semua section | Jika user kirim gambar referensi (screenshot app lain, sketsa, dsb) |

**Contoh Context7 flow di Section 7**:
```
1. resolve-library-id → library: "Next.js" → dapat library_id
2. query-docs → library_id: "..." → query: "App Router latest API and best practices"
3. Gunakan hasil untuk justifikasi rekomendasi tech stack
```

---

### Phase 2 (Implementation Plan) — Perencanaan Teknis

| Tool | Kapan | Cara Pakai |
|------|------|-----------|
| `sequentialthinking` (mcp_sequential-thinking) | Feature kompleks | Break down jadi sub-task terurut dengan dependency |
| `resolve-library-id` → `query-docs` (mcp_context7) | Verifikasi tech stack | Pastikan library di PRD punya API yang support kebutuhan |
| `get_repo_structure` (mcp_zread) | Referensi arsitektur | `run_mcp(server_name="mcp_zread", tool_name="get_repo_structure", args={repo_url: "https://github.com/org/repo", path: "src/"})` — pelajari struktur repo open-source yang mirip |
| `search_doc` (mcp_zread) | Referensi implementasi | Cari cara orang lain implementasi fitur serupa di GitHub |

**Cara tawarkan ke user**: "Mau saya pelajari referensi implementasi dari repo open-source yang mirip?"

---

### Phase 3 (Task Breakdown) — Tracking

| Tool | Kapan | Cara Pakai |
|------|------|-----------|
| `TodoWrite` (built-in) | Saat generate tasks | Mirror task dari tasks.md ke todo list chat sebagai tracking visual |
| `sequentialthinking` (mcp_sequential-thinking) | Dependency kompleks | Urutkan dependency antar task yang saling ketergantungan |

---

### Phase 4 (Wireframe) — Visual Output

| Tool | Kapan | Cara Pakai |
|------|------|-----------|
| `PureShowWidget` (built-in) | Render visual di chat | Generate HTML/SVG wireframe dan render inline |
| `get_figma_data` + `download_figma_images` (mcp_Figma_AI_Bridge) | Import dari Figma | Jika user punya desain Figma, baca + download gambar |
| `get-wireframe-tool` / `get-layouts-tool` (mcp_needmcp) | Generate layout | Generate wireframe layout otomatis dari deskripsi |
| `uml-and-software-architecture-visualization` (build-web-data-visualization skill) | Diagram arsitektur | Visualisasi arsitektur sistem dalam diagram |
| `gantt-chart-visualization` (build-web-data-visualization skill) | Timeline | Visualisasi task breakdown sebagai Gantt chart |

---

### Post-PRD — Export & Presentasi

**Trigger**: Tanyakan ke user setelah PRD final disetujui: "Mau PRD ini diekspor ke format lain?"

| Format | Skill/MCP | Cara Pakai |
|--------|-----------|-----------|
| Word (.docx) | `docx` skill | Invoke skill docx, generate dari PRD markdown |
| PDF | `pdf` skill | Invoke skill pdf, generate dari PRD markdown |
| PowerPoint (.pptx) | `pptx` skill | Invoke skill pptx, buat presentasi dari PRD |
| Slide HTML | `html-deck` skill | Invoke skill html-deck, buat slide interaktif |
| HTML Report | `html-report` skill | Invoke skill html-report, buat report satu halaman |
| Lark Docs | `lark-doc` plugin | Push ke Lark/Feishu jika tim menggunakan |
| Gantt Chart | `gantt-chart-visualization` skill | Visualisasi timeline dari tasks.md |
| Architecture Diagram | `uml-and-software-architecture-visualization` skill | Visualisasi arsitektur dari PRD section 5 |

---

## Aturan Chain

1. **Selalu simpan output** phase sebelumnya sebelum lanjut
2. **Referensi silang**: Setiap dokumen harus link ke dokumen terkait
3. **Tanya dulu**: Jangan auto-chain tanpa konfirmasi user (kecuali Phase 2 → 3 yang otomatis)
4. **Context carry-over**: Bawa informasi penting dari phase sebelumnya
5. **Update tracking**: Saat coding, update tasks-[nama].md secara real-time
