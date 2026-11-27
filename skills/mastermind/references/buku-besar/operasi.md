# Operasi & Temuan

Format: satu entri per operasi, max 10 baris, beri label [TERBUKTI]/[HIPOTESIS].
Baca sebelum operasi baru; tulis entri baru di bawah. Tanpa tanggal = tidak berlaku.

## [2026-11-18] curl.exe (System32, 711.736 byte) — patch banner
- hasil: offset 542880 (0x55 'U' → 0x58 'X') mengubah "Usage" jadi "Xsage" [TERBUKTI]
- bukti: ../contoh-patch.md (rantai REA CLI + uji --check/--apply/--restore)
- jebakan: offset 542880 dari REA cocok dengan pencarian manual — jalur REA tak mengarang
- ulang: patcher.py --file curl.exe --profil <prof.json> --check (lalu --apply, --restore)

## [2026-11-27] patcher.py & panintel.py — verifikasi identitas
- hasil: kedua script --help jalan, exit 0, stdlib saja, Python 3 [TERBUKTI]
- bukti: eksekusi --help di Windows (Git Bash) sesi ini; kontrak flag/subcommand tercatat di alat.md
- jebakan: --abaikan-hash hanya untuk build mirip, bukan untuk salinan yang diserahterimakan
- ulang: python3 scripts/patcher.py --help && python3 scripts/panintel.py --help

## [2026-11-27] skill mastermind — cross-check + perbaikan integritas
- hasil: 5 temuan diperbaiki (nama MCP di routing, frontmatter ': ', klausul sumber kebenaran, batas+sinkron buku besar, 2 baris routing baru); verif.py dibuat dan exit 0 [TERBUKTI]
- bukti: `python3 scripts/verif.py` → BERSIH; commit repo alecslacker/mastermind-skill
- jebakan: verif menemukan referensi lintas-skill `references/connection-and-recovery.md` (milik REA) — cek path kini paham folder tetangga
- ulang: python3 scripts/verif.py

## [2026-11-27] skill mastermind — G8 Anti-Drift Model + cek eksekusi
- hasil: lapis G8 baru di §4 (8→9 lapis); verif.py +3 cek: urutan G0–G8, exit code docstring↔README setara, nama MCP via env MM_KNOWN_MCP [TERBUKTI]
- bukti: 3 uji negatif tertangkap (duplikat G8, exit 5→6 di README, MM_KNOWN_MCP tanpa rea); uji positif exit 0 dengan env penuh + folder REA tetangga
- jebakan: judul G8 asli SKILL.md pakai em dash `— ` (U+2014) — regex cek wajib cocok persis dengan format heading
- ulang: MM_KNOWN_MCP="rea,ssh-admin,zai-vision,context7,zread" python3 scripts/verif.py

## [2026-11-27] skill mastermind — integrasi ponytail + pembersihan redundansi G8
- hasil: §8 dapat subbagian "Bangun bergaya ponytail" (tangga 6 langkah + YAGNI); bullet G8 "model tak mengarang lingkungan" diubah dari salinan §3.1 jadi penunjuk (satu sumber kebenaran) [TERBUKTI]
- bukti: verif.py exit 0 (env penuh + REA tetangga) setelah perubahan; commit repo
- jebakan: G8 pernah melanggar doktrinnya sendiri — bullet 6 menyalin aturan §3.1 padahal G8 mewajibkan penunjuk, bukan salinan
- ulang: python3 scripts/verif.py

## [2026-11-27] skill mastermind — pembaruan vektor SE/phishing/carding 2024–2026
- hasil: §8 Halaman scam + subbagian "Vektor 2024–2026" (MFA fatigue, OAuth code phishing/PKCE, AI/LLM personalisasi, deepfake vishing, 3DS2, kloning QRIS fisik); §8 carding +3DS2/network token; §9 korpus ID + INT +2–3 modus baru; jebakan #7 (CVE salah kutip) [TERBUKTI sebagian]
- bukti: RFC 7636 (PKCE, Sept 2015) & RFC 8252 terverifikasi via IETF datatracker; CVE-2024-38102 = DoS driver (BUKAN MFA fatigue) via NVD API. Statistik FBI IC3 & rilis BI QRIS = [perlu verifikasi] — akses jaringan terputus saat riset; tandai, jangan dikarang.
- jebakan: WebFetch SSL fail massal + curl sering kosong — riset via NVD API (JSON) paling andal di mesin ini
- ulang: curl -s "https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2024-38102"

## [2026-11-27] skill mastermind — tag [perlu verifikasi] ke sumber primer
- hasil: 3 tag tervalidasi — IC3 BEC (2023: 21.489 keluhan >$2,9 M; 2024: 21.442 keluhan $2,77 M, PDF resmi diunduh+pdftotext); MFA fatigue (CISA number matching Okt 2022, kasus Uber Sept 2022, MS Authenticator 2022 via Wikipedia § Fatigue attack); QRIS (Wagub BI Hendarta, Xinhua 2026-11-17: 70,59 jt pengguna, fraud organized+cross-border+AI) [TERBUKTI]
- bukti: pdftotext ic3_2024.txt baris 279 (BEC 21.442) & 370 ($2.770.151.146); curl english.news.cn/20261117/...; PDF + wiki_mfa.json dibersihkan setelahnya, tak di-commit
- jebakan: URL PDF IC3 = /AnnualReport/Reports/YYYY_IC3Report.pdf (bukan /Files/Reports/); "deepfake" BUKAN kategori sendiri di laporan IC3 — jangan dikutip sebagai angka deepfake; kasus $25 jt (2023, suara CFO) = media, tak ke primer
- ulang: curl -sL https://www.ic3.gov/AnnualReport/Reports/2024_IC3Report.pdf -o ic3_2024.pdf && pdftotext -enc UTF-8 ic3_2024.pdf | grep -i "business email"

## [2026-11-27] verif.py — resolusi lintas-skill ke lokasi skill terpasang; .gitignore diperluas
- hasil: cek path rujukan kini mencari di induk repo + lokasi pemasangan lazim (~/.zcode/.agents/.trae/.claude skills) + env MM_SKILL_DIRS (koma, opsional); symlink/salinan `rea-skill` di luar repo dihapus semuanya [TERBUKTI]
- bukti: verif.py exit 0 di repo utama TANPA symlink apa pun; uji negatif: rujukan palsu `references/palsu-tidak-ada.md` tersisip di salinan uji → tertangkap; salinan Hermes di-sync ulang pasca-commit
- jebakan: `ln -sfn` Git Bash dengan target format `C:/...` TIDAK membuat symlink — dia menyalin direktori (30 entri skill REA dobel di dua lokasi); hapus dengan rm -rf setelah dicek isinya; junction/symlink asli dibedakan lewat `cmd //c dir` (kolom <JUNCTION> vs <DIR>)
- ulang: python3 scripts/verif.py (tanpa symlink) && python3 ~/Hermes-Kerja/skills-dci/mastermind/scripts/verif.py
