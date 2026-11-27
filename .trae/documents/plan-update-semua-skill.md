# IMPLEMENTATION PLAN: Update & Perbarui Semua Skill

Tanggal: 2026-11-27 · Repo: `f:\Project\trae-skill` · Scope: skill yang tercatat di `upstream-manifest.json` + `mastermind`.

## Overview

Refresh skill ke versi terbaru dari sumber masing-masing, lalu sinkron ke TRAE/Claude/ZCode/Codex dan commit+push. Repo sedang clean di `master` (head `061a0e9`). Ada 437 skill; 13 sumber upstream terdaftar di manifest.

## Temuan awal (evidence)

- `check-upstream.ps1`: **2 sumber ada update** — `JuliusBrussee/caveman` v4.1.0 → **v4.2.0**; `miqdadbadjuber/anti-slop` v3.2.32 → **v3.2.33**.
- 8 sumber lain gagal dicek via GitHub API (likely rate limit 60 req/jam, bukan repo hilang): design-taste-frontend, logo-design, blog-write, threat-modeling, cro, docx, playwright-best-practices, remotion-motion-graphics, bug-bounty.
- 3 sumber status TERBARU: ponytail v5.3.3, reverse-engineer-anything 6.10.1, caveman (sebelum rilis v4.2.0).
- `mastermind` bukan repo eksternal — sumber pasang ada di `~/.trae/skills/mastermind/SKILL.md`: **52.438 byte, ubah 2026-11-27 11:49**, sementara salinan repo **43.902 byte, ubah 2026-11-18**. Jadi lokal lebih baru dan perlu di-collect ke repo.
- Catatan multi-sesi: commit `061a0e9..e43e12c` berasal dari sesi lain (graphify, isolasi, worktree, dci-tts). Plan ini **tidak menyentuh** perubahan di luar scope skill di atas.

## Library/Tool Pre-Check

- Tanpa library baru. Pakai script repo yang sudah ada: `check-upstream.ps1`, `update-inventory.ps1`, `sync-claude.ps1`, `sync-zcode.ps1`, `sync-codex.ps1`.
- GitHub API kena rate limit → fallback `git ls-remote` (tanpa API key) untuk cek tag/commit 8 repo yang gagal.
- Verifikasi konten: `git diff --no-index` / `Get-FileHash` sebelum menimpa skill yang punya ekstensi lokal.

## Skill yang dipakai

- `skill-creator` (protokol Update: baca target, patch hanya yang berubah, validasi).
- `git-commit` / `atomic-commit-discipline` untuk commit per batch.

## Tasks (eksekusi per task, checkpoint `KERJAKAN`/`LANJUT`)

1. **Bypass rate limit** — `git ls-remote --tags`/`--heads` untuk 8 repo gagal; catat tag/commit terbaru; bandingkan dengan `upstream_terakhir` di manifest. Tanpa mengubah file.
2. **Update caveman 7 skill** — sparse-checkout tag v4.2.0 ke staging; diff SKILL.md lama vs baru; salin hanya yang berubah ke `skills/`; catat di manifest.
3. **Update antislop 6 skill** — sparse-checkout tag v3.2.33; WAJIB preserved local extension di `skills/antislop-ui/SKILL.md` (blok `local-extension` Liveliness Recipes + baris `Fix Sterile Default`) seperti catatan manifest; diff dulu sebelum timpa.
4. **Collect mastermind** — salin `~/.trae/skills/mastermind/` → `skills/mastermind/`; diff ringkas; pastikan atribusi DCI/Alecs tetap utuh.
5. **Update 8 repo lain bila benar-benar berubah** — hanya SKILL.md/reference yang berubah; skip perubahan README/installer/CI saja. Untuk `design-taste-frontend` jangan timpa aset 35 MB tanpa diff.
6. **Finalisasi** — `update-inventory.ps1`; jalankan 3 sync script; verifikasi hash lintas target; `git add` per path scope; commit + push.

## Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Rate limit GitHub API | `git ls-remote` + raw.githubusercontent.com, bukan API |
| Ekstensi lokal tertimpa (antislop-ui, taste) | Diff dulu, re-apply blok lokal setelah copy |
| Aset besar tidak sengaja masuk commit | Sparse-checkout hanya folder skill; cek `git diff --stat` sebelum add |
| Sesi lain mengubah repo saat proses | Commit per batch, `git add <path>` eksplisit, tidak `git add .` |
| Perubahan skill merusak agent lain | Verifikasi hash 7+ skill lintas 6 target sebelum push |

## Definition of Done

- Semua sumber dengan update nyata tersalin ke `skills/`.
- `mastermind` versi lokal (52 KB) masuk repo.
- `upstream-manifest.json`, `INVENTORY.md`, `CHANGELOG.md`, marker skill-count konsisten.
- 3 sync script sukses; hash skill identik di repo/TRAE/Claude/ZCode/Codex.
- Commit per batch ter-push ke `origin/master`.

---
Mas Wondho, konfirmasi untuk lanjut?
