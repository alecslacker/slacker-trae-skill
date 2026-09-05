# Templates — Template Dokumen Output PRD Builder

File ini berisi template untuk semua 4 dokumen yang dihasilkan oleh skill. Gunakan template ini saat generate output.

---

## Template 1: PRD (Product Requirements Document)

**Nama file**: `prd-[nama-proyek].md`

```markdown
# PRD: [Nama Proyek]

> **Status**: DRAFT
> **Tanggal**: [YYYY-MM-DD]
> **Versi**: 1.0

---

## 1. Overview

### Deskripsi
[Satu kalimat dari Q1.1]

### Target Pengguna
| Tipe Pengguna | Deskripsi | Prioritas |
|---------------|-----------|-----------|
| [Tipe 1] | [Deskripsi] | Primer |
| [Tipe 2] | [Deskripsi] | Sekunder |

### Masalah yang Dipecahkan
[Q1.3]

### Solusi yang Ditawarkan
[Q1.4]

### Platform
[Q1.5]

---

## 2. Requirements

### Must-Have (Versi 1)
- [Q2.1 must-have items]

### Nice-to-Have (Versi 2+)
- [Q2.1 nice-to-have items]

### Autentikasi
- [Q2.2 detail login]

### Role & Akses
- [Q2.3 jika ada multi-role, atau "Semua pengguna memiliki akses yang sama"]

### Non-Functional
| Aspek | Target |
|-------|--------|
| Estimasi pengguna bulan 1 | [Q2.4] |
| Data sensitif | [Q2.4] |
| Mode offline | [Q2.4] |

### Out of Scope
- [Q2.5 items]

---

## 3. Core Features

### Fitur Utama

#### F1: [Nama Fitur]
- **User story**: Sebagai [tipe user], saya ingin [aksi] supaya [tujuan]
- **Alur**: [Q3.2 detail]
- **Output**: [Apa yang user lihat setelah fitur jalan]
- **Prioritas**: Must-have

#### F2: [Nama Fitur]
- ...

### Fitur Pendukung
- [Q3.3 items dengan prioritas]

### Notifikasi
- [Q3.4 jika ada, atau "Tidak ada notifikasi di versi 1"]

---

## 4. User Flow

### First-Time User
```
[Q4.1 — numbered flow]
```

### Happy Path (Alur Utama)
```
[Q4.2 — numbered flow]
```

### Alur Sekunder
1. [Q4.3 alur 1]
2. [Q4.3 alur 2]

### Error & Edge Case
| Skenario | Yang Terjadi | Yang User Bisa Lakukan |
|----------|-------------|----------------------|
| [Q4.4 skenario 1] | [Respon sistem] | [Aksi user] |
| ... | ... | ... |

---

## 5. Architecture

### Tipe Aplikasi
[Q5.2]

### Integrasi Pihak Ketiga
| Service | Tujuan | Prioritas |
|---------|--------|-----------|
| [Q5.1 service 1] | [Tujuan] | Wajib / Opsional |

### Admin Dashboard
[Q5.3 jika ada, atau "Tidak ada dashboard admin di versi 1"]

### Skala
- Pengguna aktif target (1 tahun): [Q5.4]
- Data per user per hari: [Q5.4]

---

## 6. Database Schema

### Entitas Utama

#### E1: [Nama Entitas]
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| [field] | [tipe] | Ya/Tidak | [catatan] |

#### E2: [Nama Entitas]
| Field | Tipe | Wajib | Catatan |
|-------|------|-------|---------|
| ... | ... | ... | ... |

### Relasi
| Dari | Ke | Tipe | Catatan |
|------|-----|------|---------|
| [Entitas A] | [Entitas B] | One-to-Many / Many-to-Many | [deskripsi] |

### Penyimpanan
- Permanen: [entitas yang disimpan selamanya]
- Sementara: [Q6.4 jika ada]

---

## 7. Tech Stack

### Frontend
| Komponen | Teknologi | Justifikasi |
|----------|-----------|-------------|
| Framework | [Q7.3] | [alasan] |
| Styling | Tailwind CSS | Utility-first, cepat, konsisten |
| State | [sesuai framework] | [alasan] |

### Backend
| Komponen | Teknologi | Justifikasi |
|----------|-----------|-------------|
| Runtime/Framework | [Q7.3] | [alasan] |
| Database | [Q7.3] | [alasan] |
| Auth | [Q7.3 / Better Auth / dll] | [alasan] |
| ORM | [Drizzle / Eloquent / dll] | [alasan] |

### Infrastruktur
| Komponen | Service | Tier | Estimasi Biaya |
|----------|---------|------|----------------|
| Hosting | [Vercel / Railway / dll] | [Free/Paid] | [Rp/bulan] |
| Database | [Supabase / Neon / dll] | [Free/Paid] | [Rp/bulan] |
| Storage | [S3 / Cloudinary / dll] | [Free/Paid] | [Rp/bulan] |

### Integrasi
| Service | Provider | Status |
|---------|----------|--------|
| [Payment] | [Midtrans / dll] | [Will integrate] |

### Constraint & Catatan
- [Q7.1 preferensi]
- [Q7.2 budget/timeline]

---

## 8. Design System (Anti-Slop)

> Semua keputusan desain EKSPLISIT — tidak ada yang ditebak saat coding. Section ini jadi kontrak desain untuk Phase 4 (Design Spec) dan implementasi UI.

### Arah Estetika
- **Vibe**: [Q8.1 — contoh: Minimalis premium]
- **Referensi**: [Q8.2 — website/aplikasi acuan + hasil analisis screenshot jika ada]
- **Mode**: [Q8.3 — terang/gelap/keduanya]

### Design Tokens — Color
| Token | Nilai (hex) | Penggunaan |
|-------|-------------|------------|
| primary | [hex] | Aksi utama, link, fokus |
| primary-hover | [hex] | Hover state tombol utama |
| surface | [hex] | Background halaman/kartu |
| text-primary | [hex] | Teks utama |
| text-secondary | [hex] | Teks pendukung/caption |
| success | [hex] | Feedback sukses |
| warning | [hex] | Feedback peringatan |
| error | [hex] | Feedback error |

### Design Tokens — Typography
| Level | Font | Ukuran | Weight | Penggunaan |
|-------|------|--------|--------|------------|
| h1 | [Heading font] | [48px] | 700 | Judul halaman |
| h2 | [Heading font] | [32px] | 600 | Judul section |
| h3 | [Heading font] | [24px] | 600 | Sub-judul |
| h4 | [Heading font] | [20px] | 600 | Kartu/panel |
| body | [Body font] | [16px] | 400 | Teks utama, line-height 1.6 |
| caption | [Body font] | [14px] | 400 | Label, helper text |

### Design Tokens — Spacing, Radius, Shadow, Motion
| Token | Nilai | Catatan |
|-------|-------|---------|
| Spacing base | 8px (scale: 4/8/16/24/32/48/64) | Kelipatan grid konsisten |
| Radius input | [4px] | Input field |
| Radius kartu | [8-12px] | Card/panel |
| Radius section | [16px] | Section besar |
| Shadow sm/md/lg | [nilai konkret] | Elevation bertingkat |
| Motion fast | [150ms, easing cubic-bezier] | Hover, toggle |
| Motion normal | [250ms] | Modal, dropdown |
| Motion slow | [400ms] | Page transition |

### Iconography
- [Set icon tunggal yang dipilih — contoh: Lucide, Heroicons. DILARANG campur set]

### Larangan Desain (Anti-Slop)
- TIDAK ada font generik (Inter/Roboto/Arial) tanpa justifikasi eksplisit
- TIDAK ada gradient background tanpa tujuan emosional
- TIDAK ada drop shadow berlapis tanpa elevation system
- TIDAK ada emoji berlebihan di UI
- TIDAK ada placeholder "Lorem ipsum" — semua copy realistis Bahasa Indonesia natural
```

---

## Template 2: Implementation Plan

**Nama file**: `plan-[nama-proyek].md`

```markdown
# Implementation Plan: [Nama Proyek]

> **PRD Reference**: [link ke prd-[nama].md]
> **Tanggal**: [YYYY-MM-DD]
> **Estimasi Total**: [X minggu]

---

## Prinsip

1. **Urutan dependency** — Task yang jadi fondasi dikerjakan duluan
2. **Complexity honest** — Low/Medium/High berdasarkan effort, bukan kepentingan
3. **Verifiable** — Setiap fase punya criteria yang bisa dicek

---

## Fase 1: Setup & Fondasi
**Estimasi**: [X hari]

| Task | Deskripsi | Complexity | Depends |
|------|-----------|------------|---------|
| Setup project & dependencies | Inisialisasi repo, install dependencies, config environment | Low | — |
| Setup database | Buat schema, migration, seed data | Medium | Setup project |
| Config auth | Setup authentication system | Medium | Setup project |

**Exit criteria**: Project bisa dijalankan lokal, database terhubung, auth berfungsi.

---

## Fase 2: Core Features
**Estimasi**: [X minggu]

| Task | Deskripsi | Complexity | Depends |
|------|-----------|------------|---------|
| [Feature 1 — detail] | [Deskripsi dari PRD F1] | High | Fase 1 |
| [Feature 2 — detail] | [Deskripsi dari PRD F2] | High | Feature 1 |
| [Feature 3 — detail] | [Deskripsi dari PRD F3] | Medium | Fase 1 |

**Exit criteria**: Semua must-have features berfungsi, happy path bisa dilalui end-to-end.

---

## Fase 3: Integration & Polish
**Estimasi**: [X minggu]

| Task | Deskripsi | Complexity | Depends |
|------|-----------|------------|---------|
| Integrasi [service] | [Detail integrasi pihak ketiga] | Medium | Fase 2 |
| Error handling | Handle edge cases dari PRD Q4.4 | Medium | Fase 2 |
| Edge state implementation | Implementasi semua state kosong/loading/error/offline dari Design Spec (copy Bahasa Indonesia natural) | Medium | Fase 2 |
| Aksesibilitas | Kontras 4.5:1+, keyboard nav, focus visible, aria-label | Medium | Fase 2 |
| UI polish | Micro-interactions sesuai Design Tokens motion, hover/focus/active/disabled semua elemen interaktif | Low | Fase 2 |
| Responsive | Pastikan mobile-friendly | Medium | Fase 2 |

**Exit criteria**: Error cases ditangani, SEMUA edge state terimplementasi dengan copy final, aksesibilitas lolos, UI polished, siap untuk testing.

---

## Fase 4: Testing & Deploy
**Estimasi**: [X hari]

| Task | Deskripsi | Complexity | Depends |
|------|-----------|------------|---------|
| Unit test | Test fungsi kritis | Medium | Fase 3 |
| E2E test | Test alur utama end-to-end | Medium | Fase 3 |
| Design QA — Web Interface Guidelines | Review UI via skill `web-design-guidelines` (fetch rules terbaru + audit file UI) | Medium | Fase 3 |
| Design QA — AI Test | Jalankan 7 pertanyaan AI Test dari Design Spec terhadap UI final (screenshot via `webapp-testing` bila perlu) | Low | Design QA Guidelines |
| Deploy | Setup CI/CD, deploy ke staging/production | Medium | Testing |

**Exit criteria**: Aplikasi live, semua test pass, Web Interface Guidelines bersih, AI Test LULUS, siap digunakan pengguna.

---

## Dependency Graph

```
Setup → Database → Auth → Core Features → Integration → Testing → Deploy
```

---

## Risiko & Mitigasi

| Risiko | Probabilitas | Impact | Mitigasi |
|--------|-------------|--------|----------|
| [Risiko 1] | Tinggi/Sedang/Rendah | Tinggi/Sedang/Rendah | [Aksi] |
```

---

## Template 3: Task Breakdown (Trackable)

**Nama file**: `tasks-[nama-proyek].md`

```markdown
# Tasks: [Nama Proyek]

> **Plan Reference**: [link ke plan-[nama].md]
> **PRD Reference**: [link ke prd-[nama].md]
> **Terakhir diupdate**: [YYYY-MM-DD HH:MM]

---

## Setup
- [ ] T-01: Inisialisasi project & install dependencies — Complexity: Low
- [ ] T-02: Setup konfigurasi environment (.env, config files) — Complexity: Low
- [ ] T-03: Setup database & schema migration — Complexity: Medium
  - ↳ Depends: T-01
- [ ] T-04: Setup authentication system — Complexity: Medium
  - ↳ Depends: T-03

## Core
- [ ] T-05: [Feature 1 — komponen utama] — Complexity: High
  - ↳ Depends: T-04
- [ ] T-06: [Feature 1 — logic bisnis] — Complexity: High
  - ↳ Depends: T-05
- [ ] T-07: [Feature 2 — komponen utama] — Complexity: Medium
  - ↳ Depends: T-04
- [ ] T-08: [Feature 2 — integrasi] — Complexity: Medium
  - ↳ Depends: T-07

## Integration
- [ ] T-09: Integrasi [service pihak ketiga] — Complexity: Medium
  - ↳ Depends: T-08
- [ ] T-10: Error handling & edge cases — Complexity: Medium
  - ↳ Depends: T-06, T-08

## Polish
- [ ] T-11: UI polish (micro-interactions, loading, empty states) — Complexity: Low
  - ↳ Depends: T-10
- [ ] T-12: Responsive design (mobile-friendly) — Complexity: Medium
  - ↳ Depends: T-11

## Testing & Deploy
- [ ] T-13: Unit test untuk fungsi kritis — Complexity: Medium
  - ↳ Depends: T-12
- [ ] T-14: End-to-end test alur utama — Complexity: Medium
  - ↳ Depends: T-13
- [ ] T-15: Deploy ke staging/production — Complexity: Medium
  - ↳ Depends: T-14

---
**Progress: 0/15 (0%)**

```

---

## Template 4: Wireframe / Design Spec (UI/UX)

**Nama file**: `wireframe-[nama-proyek].md`

> Wireframe dibuat dengan **Sequential Design Process** (jangan loncat ke styling sebelum struktur beres):
> 1. Rough Layout (struktur & hierarki) → 2. Hierarchy Refinement (dominan vs pendukung) → 3. Color + Typography (apply tokens dari PRD Section 8) → 4. Interaction Polish (hover/focus/active/disabled) → 5. Accessibility Audit (kontras, keyboard, screen reader) → 6. Edge State Design (kosong/error/loading/offline per screen) → 7. Final Critique (AI Test di bawah)

```markdown
# Wireframe / Design Spec: [Nama Proyek]

> **PRD Reference**: [link ke prd-[nama].md]
> **Design Tokens Reference**: PRD Section 8 (Design System)
> **Tanggal**: [YYYY-MM-DD]

---

## Screen 1: [Nama Screen — contoh: Login]

### Tujuan
[Kenapa screen ini ada, apa yang user capai]

### Elemen
| Prioritas | Elemen | Tipe | Catatan |
|-----------|--------|------|---------|
| Tinggi | Input email | Form field | Validasi format email |
| Tinggi | Input password | Form field | Min 8 karakter, show/hide toggle |
| Tinggi | Tombol Login | Button | Full-width, loading state |
| Sedang | Link "Lupa password?" | Link | Navigasi ke reset flow |
| Sedang | Link "Daftar akun" | Link | Navigasi ke register |

### Layout (ASCII)
```
┌─────────────────────────────┐
│                             │
│       [Logo Aplikasi]       │
│                             │
│   ┌─────────────────────┐   │
│   │ Email               │   │
│   └─────────────────────┘   │
│                             │
│   ┌─────────────────────┐   │
│   │ Password         👁 │   │
│   └─────────────────────┘   │
│                             │
│         Lupa password?      │
│                             │
│   ┌─────────────────────┐   │
│   │      LOGIN          │   │
│   └─────────────────────┘   │
│                             │
│     Belum punya akun?       │
│         Daftar di sini      │
│                             │
└─────────────────────────────┘
```

### Edge State (WAJIB per screen — Anti-Slop)
| State | Tampilan & Copy Final (Bahasa Indonesia natural) |
|-------|---------|
| Kosong | [Contoh: "Belum ada transaksi hari ini. Catat penjualan pertamamu!" + tombol "+ Catat"] |
| Loading | [Skeleton loader yang match layout final / copy kontekstual] |
| Error | [Jelaskan apa salah + apa yang user bisa lakukan. Contoh: "Email tidak terdaftar. Periksa ejaan atau daftar akun baru."] |
| Offline | ["Koneksi terputus. Perubahan tersimpan lokal dan tersinkron otomatis."] |
| Success | [Konfirmasi spesifik. Contoh: "Transaksi tersimpan. Stok sudah diperbarui."] |

### Interaction States
| Elemen | Hover | Focus | Active | Disabled |
|--------|-------|-------|--------|----------|
| Tombol Login | [bg primary-hover] | [ring 2px primary] | [scale 0.98] | [opacity 0.5, cursor not-allowed] |

### Aksesibilitas
- Kontras teks: minimal 4.5:1 (target 7:1 AAA)
- Navigasi keyboard: [tab order]
- Label screen reader: [aria-label untuk elemen ikon]

---

## Screen 2: [Nama Screen]
[Sama format seperti Screen 1 — WAJIB dengan Edge State table]

---

## Aset Visual (Generate via byteplus-seedream5)

Daftar aset yang digenerate dengan Seedream (prompt mengandung: tujuan + style konsisten + palette hex dari Design Tokens + mood + komposisi):

| Aset | Model | Prompt Ringkas | Lokasi File |
|------|-------|----------------|-------------|
| Hero image | pro/lite | [prompt lengkap] | [path] |
| Ilustrasi empty state | lite | [prompt lengkap, style konsisten] | [path] |
| Logo/OG image | pro | [prompt lengkap, teks Indonesia] | [path] |

Aturan konsistensi antar gambar: SATU style untuk semua (flat/isometric/3D — jangan campur), palette dari design tokens, mood sesuai vibe Section 8.

---

## AI Test — Final Gate (WAJIB lulus semua sebelum desain dinyatakan selesai)

- [ ] 1. Apakah layout bisa ditebak dalam 3 detik oleh orang yang sering lihat AI-generated UI? (Jika ya → REDESAIN)
- [ ] 2. Apakah tiap elemen punya tujuan emosional spesifik, bukan sekadar "biar cantik"?
- [ ] 3. Apakah spacing terasa intentional (grid 8px) bukan random?
- [ ] 4. Apakah typography punya karakter, bukan sans-serif default?
- [ ] 5. Apakah semua edge state punya copy ber-personality dalam Bahasa Indonesia natural?
- [ ] 6. Apakah semua gambar kontekstual, konsisten style, dan resolusi cukup (min 2x display)?
- [ ] 7. Kalau desainer profesional melihat ini, apakah mereka bilang "ini AI"? (Jika ya → REDESAIN)

**Hasil**: [LULUS / REDESAIN — ulang dari step Sequential Design yang relevan]

---

## Flow Antar Screen

```
[Login] → [Dashboard] → [Feature 1] → [Result]
                ↓
          [Profile] → [Settings]
```

---

## Catatan Design
- [Catatan tentang warna, font, spacing — refer ke Design Tokens PRD Section 8]
- [Referensi inspirasi dari Q8.2]
- [Constraint aksesibilitas]
```

---

## Aturan Penggunaan Template

1. **Isi semua placeholder** `[seperti ini]` dengan data aktual dari jawaban user
2. **Hapus section** yang tidak relevan (contoh: jika tidak ada admin, hapus section Admin Dashboard)
3. **Konsisten antar dokumen**: Task T-05 di tasks.md harus match dengan task di plan.md
4. **Format tanggal**: YYYY-MM-DD (ISO 8601)
5. **Progress bar** di tasks.md: update otomatis saat task selesai
