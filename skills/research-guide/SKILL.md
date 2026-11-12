---
name: research-guide
description: "Use when the user asks for research, investigation, comparison, or fact-finding — market research, technical research, competitor analysis, due diligence, or any multi-source evidence gathering. Enforces source hierarchy, claim verification, confidence labeling, and anti-fabrication discipline per Critical Thinking Protocol."
---

# Research Guide — Protokol Riset Slackercoder

> Kurasi internal Slackercode Family. Author: Mas Wondho — Duta Corpora Indonesia (DCI).
> Copyright © 2026 Duta Corpora Indonesia. Selaras dengan Critical Thinking Protocol (anti-sycophancy).

## Kapan Skill Ini Aktif

Trigger: "riset", "research", "bandingkan", "cari tahu", "due diligence", "analisis pasar/kompetitor", "kumpulkan bukti". Terutama untuk pertanyaan yang jawabannya TIDAK bisa dipastikan dari satu sumber atau dari ingatan model saja.

## Alur Kerja — 5 Fase

### 1. Definisikan Pertanyaan (sebelum mencari)
- Rumuskan 1 pertanyaan riset inti + sub-pertanyaan maksimal 5.
- Tentukan kriteria "selesai": data apa yang dibutuhkan untuk menjawab.
- Identifikasi bias potensial (sumber yang punya kepentingan, data usang).

### 2. Kumpulkan Sumber (hierarki prioritas)
1. **Primer**: dokumen resmi, API docs, laporan keuangan, standar hukum, data terukur sendiri.
2. **Sekunder**: publikasi analysis bereputasi, dokumentasi vendor, statistik lembaga.
3. **Tersier**: agregator, wiki, forum — hanya untuk orientasi, BUKAN sitasi.

Alat per tanggal kebutuhan: WebSearch/WebFetch untuk umum; zread untuk repo GitHub; Context7 untuk library; blog-discourse untuk percakapan komunitas 30 hari terakhir.

### 3. Verifikasi Klaim (anti-fabrication)
- Setiap klaim faktual penting WAJIB punya sumber yang benar-benar dibaca pada sesi ini.
- Klaim yang tidak bisa diverifikasi: tandai "This needs verification" — jangan dihaluskan jadi fakta.
- DILARANG mengarang: statistik, judul paper, URL, kutipan orang nyata, angka pasar.
- Cross-check klaim mencurigakan minimal 2 sumber independen.

### 4. Sintesis dengan Label Keyakinan
- Klaim penting diberi label: `[High confidence]` / `[Medium confidence]` / `[Low confidence]` + alasan singkat dasar keyakinan itu.
- Pisahkan tegas: FAKTA (bersumber) vs ANALISIS (penalaran) vs SPEKULASI (ditandai jelas).
- Tampilkan kelemahan/butanya dulu bila ada — bukan validasi kosong.

### 5. Laporan
- Struktur: jawaban inti di atas (answer-first), detail menyusul, sumber di akhir.
- Sumber sebagai daftar tautan nyata yang telah di-fetch. Sumber yang tidak dibaca = tidak disebut.
- Untuk topik mutakhir (harga, hukum, rilis produk): nyatakan eksplisit kapan perlu verifikasi live.

## Batas
- Riset bukan opini: jika data tidak cukup, katakan "data tidak cukup" — jangan isi dengan tebakan yang terdengar meyakinkan.
- Dokumen riset sebagai deliverable: ikuti branding WAJIB (footer copyright DCI).
