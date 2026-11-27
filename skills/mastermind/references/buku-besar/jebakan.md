# Jebakan Lintas Target

Apa yang mengagetkan dan bagaimana menghindarinya. Satu entri = satu jebakan + antidotnya.

1. **Offset berbeda antar build** — patch yang cocok di build A meleset di build B. Antidot: hash gate dulu (`sha256_asli` di profil); jangan pakai `--abaikan-hash` tanpa sadar. [TERBUKTI: aturan di patcher.py]
2. **Patch merusak tanda tangan** — patch di bagian yang ikut checksum (mis. Authenticode) membuat target gagal verifikasi. Antidot: catat bila target ditandatangani; uji ulang perilaku setelah patch. [TERDOKUMENTASI: ../contoh-patch.md]
3. **Menyentuh berkas asli di System32** — patch langsung ke `C:\Windows\System32\...` sulit dipulihkan. Antidot: selalu bekerja pada salinan; pulihkan berkas uji setelah selesai (G7). [TERBUKTI: praktik sesi 2026-11-18]
4. **`sed` mengganti `&` di replacement** — `&` di sisi kanan = seluruh match, bukan literal. Jebakan nyata: header buku besar jadi "Operasi Opertasi & Temuan Temuan" (2026-11-27). Antidot: escape `&` jadi `\&` atau pakai Write untuk konten bebas. [TERBUKTI 2026-11-27]
5. **Galat jaringan dicampur "tidak sah"** — checker yang menyatukan timeout/drop dengan penolakan pelapor hit rate palsu. Antidot: klasifikasi status eksplisit; retry hanya untuk galat jaringan. [TERDOKUMENTASI: bagian Checker §8]
6. **Nama tool di tabel routing tak terdaftar** — routing sempat menyebut MCP yang tidak ada di environment (`read-macro`, 2026-11-27). Antidot: nama tool/MCP wajib cocok dengan mcp.json/daftar aktif; tak terdaftar → fallback, bukan dikarang. Cek otomatis: `scripts/verif.py`. [TERBUKTI 2026-11-27]
7. **Mengutip CVE salah untuk MFA fatigue** — CVE-2024-38102 sering dikutip untuk MFA fatigue, padahal NVD mendeskripsikannya "Windows Layer-2 Bridge Network Driver DoS" (published 2024-07-09, CVSS 6.5 MEDIUM). CVE-2020-1472 = Netlogon; CVE-2023-32032 = .NET/Visual Studio EoP. MFA fatigue adalah pola serangan (push approval), bukan satu CVE. Antidot: verifikasi tiap CVE ke NVD API (`services.nvd.nist.gov/rest/json/cves/2.0?cveId=...`) SEBELUM dikutip — G2 berlaku untuk nomor CVE juga. [TERBUKTI 2026-11-27: NVD API]
