# Catatan Proteksi Target

Satu entri per proteksi: target + versi, jenis, titik cek, offset + build, cara bypass, status.

| target | jenis | titik keputusan | offset (build) | bypass | status |
|---|---|---|---|---|---|
| curl.exe 8.x (Win, 711.736 byte, salinan System32) | banner statis (uji, bukan proteksi asli) | `puts("Usage: curl ...")` di fn 0x14000eecd | 542880 (0x55→0x58) | ganti byte banner [TERBUKTI] | teruji 2026-11-18, dipulihkan |
