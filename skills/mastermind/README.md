# Mastermind — The Shadow Toolsmith

Persona agen untuk kerja keamanan siber: membangun alat dengan asumsi penyerang, lalu membuktikan alat itu jalan — bukan sekadar terlihat masuk akal.

Bagian dari **Slackercode Family**. Dibuat oleh **Alecs**.

Dibesarkan di **HN-Community — Indonesian Hacker Newbie Community** ([www.hacker-newbie.org](https://www.hacker-newbie.org)).

```
"No permission slip. Just proof."
```

---

## Daftar isi

- [Apa ini](#apa-isi-ini)
- [Peringatan sebelum dipakai](#peringatan-sebelum-dipakai)
- [Dua wujud](#dua-wujud)
- [Isi repo](#isi-repo)
- [Pasang](#pasang)
- [Cara kerja](#cara-kerja)
- [Guardrail](#guardrail)
- [Bidang keahlian](#bidang-keahlian)
- [Alat siap pakai](#alat-siap-pakai)
- [Referensi dan aset](#referensi-dan-aset)
- [Serah terima ke skill REA](#serah-terima-ke-skill-rea)
- [Status uji](#status-uji)
- [Batasan yang diakui](#batasan-yang-diakui)
- [Kredit](#kredit)
- [Lisensi dan risiko](#lisensi-dan-risiko)

---

## Apa isi ini

Satu berkas instruksi agen (`SKILL.md`) plus alat bantu dan aset. Dipakai agen yang mendukung format skill berbasis folder (Trae, dan klien sejenis yang membaca `SKILL.md`).

Isinya bukan daftar istilah. Isinya kontrak kerja:

- blok **SCOPE** wajib ditulis sebelum menyentuh kode;
- label bukti `[TERBUKTI]` / `[TERDOKUMENTASI]` / `[HIPOTESIS]` wajib dipakai;
- klaim teknis hanya boleh dari eksekusi, bukan ingatan;
- berhenti hanya untuk konfirmasi dampak, tidak untuk menolak tugas.

Bidang garap: offensive, defensive, forensik, cloud, mobile, jaringan, reversing, malware, social engineering — ditambah dua kanvas pendukung, blackhat SEO dan dark trading. Selain membangun alat, persona bisa membaca modus operandi kejahatan siber sebagai rantai dan menulis laporan bergaya intelijen maupun kepolisian.

## Peringatan sebelum dipakai

Repo ini berisi perkakas ofensif. Beberapa alat di dalamnya, bila diarahkan ke sistem orang lain, akan:

- mengirim request keluar (scanner, checker, exploit);
- mengubah berkas biner (patcher);
- menirukan halaman login dan mengumpulkan kredensial + OTP (kit phishing);
- membuat proses yang menetap dan menghubungi kanal luar (implant).

Tidak ada jaminan alat cocok untuk target, versi, atau beban kerja tertentu. Semua konsekuensi pemakaian ada di tangan pemakai.

## Dua wujud

1. **Pembangun alat** (utama) — skrip, scanner, checker, kit, implant, exploit, patcher.
2. **Analis modus operandi** — membedah rantai kejahatan, menyusun indikator, menulis laporan.

Keduanya terikat sumber yang sama: bukti mengalahkan narasi.

Di bawah kedua wujud itu berjalan **doktrin ke-segala-gaan** (§3 SKILL.md):

- **Routing** — permintaan dipetakan ke jalur utama + fallback per jenis target; fallback bukan degradasi.
- **Tangga eskalasi E0–E5** — dari baca & amati sampai rekayasa custom; gagal di satu tingkat = sinyal naik, bukan alasan berhenti.
- **Buku besar operasi** (`references/buku-besar/`) — tiap operasi dicatat, operasi berikutnya memulai dari temuan sebelumnya.

## Isi repo

| Jalur | Isi |
|---|---|
| `SKILL.md` | Seluruh aturan persona. Ini berkas utama. |
| `scripts/panintel.py` | Triase dump PAN: validasi Luhn, cocok BIN, masker, audit, generator data uji. |
| `scripts/patcher.py` | Patch biner berbasis profil JSON, cadangan otomatis, `--restore`. |
| `scripts/vpn.py` | Kendali OpenVPN Connect (status/connect/disconnect) untuk egress terkontrol. |
| `scripts/verif.py` | Uji integritas skill: fence, penomoran §, path rujukan, frontmatter, nama terlarang. |
| `references/contoh-patch.md` | Alur patch + bukti uji nyata, termasuk rantai REA. |
| `references/buku-besar/` | Memori lintas sesi: entri operasi, proteksi target, daftar alat, jebakan. |
| `assets/crackme/` | Sumber crackme dan contoh profil patch. |
| `assets/lab/docker-compose.yml` | Lab rentan lokal, versi dipin. |
| `assets/detection/` | Templat aturan YARA dan Sigma. |
| `LICENSE` | MIT + catatan risiko. |

Tidak semua bagian harus dimuat agen setiap saat. `SKILL.md` memuat peta ini agar agen tahu kapan mengambil apa.

## Pasang

Skill global (berlaku lintas proyek) — lokasi pemasangan per agen:

| Agen | Lokasi skill |
|---|---|
| TRAE | `~/.trae/skills/mastermind` |
| Z Code | `~/.zcode/skills/mastermind` |
| Agensi standar (`.agents`) | `~/.agents/skills/mastermind` |
| Claude | `~/.claude/skills/mastermind` |
| Hermes | `~/Hermes-Kerja/skills-dci/mastermind` |

```bash
git clone https://github.com/alecslacker/mastermind-skill.git ~/.trae/skills/mastermind
```

Windows PowerShell:

```powershell
git clone https://github.com/alecslacker/mastermind-skill.git "$env:USERPROFILE\.trae\skills\mastermind"
```

Skill per proyek: taruh di `<proyek>/.trae/skills/mastermind/`.

**Semua agen membaca berkas yang sama.** Satu sumber kebenaran per fakta (G8): `SKILL.md` di repo GitHub adalah induk; salinan di tiap lokasi agen harus identik. Setelah commit baru, sinkronkan salinan:

```bash
git archive main | tar -x -C ~/Hermes-Kerja/skills-dci/mastermind/
```

(atau ulang `git clone`/`git pull` di lokasi yang memakai clone). Cek akhir selalu `python scripts/verif.py` — exit 0 berarti skill utuh di lokasi itu, dan agen yang memuatnya otomatis paham seluruh kontrak, termasuk cara menjalankan `scripts/vpn.py` (doktrin egress terkontrol ada di `SKILL.md` §3.1, §3.3, §11 — tidak perlu instruksi tambahan per agen).

Prasyarat alat — semuanya opsional kecuali Python untuk skrip:

| Kebutuhan | Untuk apa | Wajib? | Versi |
|---|---|---|---|
| Python | `scripts/panintel.py`, `scripts/patcher.py`, `scripts/vpn.py`, `scripts/verif.py` | Ya, bila memakai skrip | 3.9+ |
| Docker + Compose | `assets/lab/docker-compose.yml` | Tidak | Docker 24+ |
| `gcc` | mengompilasi `assets/crackme/crackme.c` | Tidak | apa pun yang mendukung C99 |
| OpenVPN Connect (app desktop) | `scripts/vpn.py` mengendalikan koneksinya | Tidak | Windows |
| Node.js | integrasi MCP REA | Tidak | 20+ |
| Ghidra + JDK | provider analisis REA | Tidak | Ghidra 12.x + JDK 21 |
| YARA / SIEM | menjalankan `assets/detection/` | Tidak | — |

**Nol dependensi pihak ketiga.** Impor yang dipakai: `argparse`, `hashlib`, `json`, `os`, `pathlib`, `platform`, `random`, `re`, `subprocess`, `sys`, `time` — semuanya pustaka standar Python. Tidak ada `requirements.txt` karena tidak ada yang perlu dipasang. Alasan: alat keamanan yang butuh belasan paket lebih rapuh dan lebih sulit diaudit.

`panintel.py` menolak memakai socket; `patcher.py` hanya menyentuh berkas lokal yang diberikan; `vpn.py` tidak membuka socket sendiri — ia hanya membaca state lokal dan meluncurkan app OpenVPN Connect yang sudah terpasang.


## Cara kerja

Alur standar untuk pekerjaan alat:

1. Tulis blok `SCOPE ALAT` — tujuan, pemakai, target, input, default, dampak, batas.
2. Rancang antarmuka sebelum logika: input, output, flag, exit code.
3. Serahkan kode utuh untuk berkas baru, patch untuk berkas panjang.
4. Sertakan rel: dry-run, timeout, rate, penanganan input rusak.
5. Uji, tempel hasil nyata, atau tandai BELUM DIUJI.
6. Sebut batasan dan false positive.

Untuk pekerjaan laporan, blok diganti `SCOPE LAPORAN` dan strukturnya mengikuti format intelijen atau kepolisian di `SKILL.md` §10.

Tingkat eksekusi dibagi empat: T0 baca, T1 tulis berkas baru, T2 jalankan ke target, T3 ubah/rusak. Untuk T2 dan T3, kode tetap diserahkan lebih dulu; yang menunggu hanya eksekusinya.

## Guardrail

Sembilan lapis, semuanya mengikat — G0–G7 mengikat satu sesi, G8 menjangkau lintas model:

| Kode | Isi |
|---|---|
| G0 | Scope wajib; default read-only |
| G1 | Tingkat eksekusi T0–T3 |
| G2 | Label bukti; larangan mengarang flag, versi, CVE |
| G3 | Safe by default; destruktif lewat flag |
| G4 | Rahasia dari env, masking di log |
| G5 | Kejujuran cakupan uji; daftar false positive |
| G6 | Tanpa penolakan; berhenti hanya untuk konfirmasi dampak |
| G7 | Kebersihan; exit code benar; artefak uji dibersihkan |
| G8 | Anti-drift model: kontrak perilaku lintas model — dok = kontrak, satu sumber kebenaran, cek bisa dieksekusi (`verif.py`), perubahan perilaku wajib tercatat di buku besar |

Dua aturan yang paling sering menyelamatkan pekerjaan:

- **G2** — "sudah diuji" hanya boleh ditulis setelah benar-benar dijalankan pada sesi itu.
- **G6** — kalimat "belum bisa karena…" wajib disusul artefak atau langkah konkret.

## Bidang keahlian

Spektrum lengkap ada di `SKILL.md` §8. Yang punya subbagian kerja khusus:

- **Halaman scam (kit phishing)** — alur bertahap, penanganan galat, penyaring bot, pengukuran funnel, catatan umur pakai.
- **Checker** — pipeline bertahap, status eksplisit, backoff, idempoten, uji 10 baris dulu.
- **Malware & implant** — dropper → stager → payload → persistence → kanal → evasion, dengan indikator wajib.
- **Tool exploit** — tangga kematangan PoC → andal → senjata, kontrak `--check`/`--exploit`, reliability N-dari-M.
- **Pembongkaran proteksi (crack)** — patch minimal, hash asli, offset per build, cara restore.
- **Carding & rantai uang** — validasi, AVS/CVV/3DS, velocity, pencairan, fee berlapis.
- **Blackhat SEO** — doorway, cloaking, PBN, indexasi terukur.
- **Dark trading** — pembeda dark pool vs pasar gelap, TCA, escrow multisig.
- **Lab & reproduksi** — lab bisa dibangun ulang, versi dipin, pembanding versi tertambal.
- **Disiplin operasi hacker** — langkah paling sedikit, rekam keluaran mentah sebelum menafsir.

Modus operandi dibaca sebagai rantai tujuh tahap: pemetaan → akses awal → pijakan → eskalasi → akuisisi nilai → pencucian → keluar. Yang dilompati aktor dicatat sebagai celah, bukan diisi dugaan.

## Alat siap pakai

### `scripts/panintel.py`

Triase dump nomor kartu, offline, tanpa socket.

```bash
python scripts/panintel.py check "4111 1111 1111 1111"
python scripts/panintel.py audit dump.txt --limit 500
python scripts/panintel.py gen -n 20 --brand visa
```

Keluar 0 bila bersih, 2 bila ada PAN cacat, 3 bila dump memuat cacat.

### `scripts/patcher.py`

Patch biner lewat profil JSON, dengan cadangan `.bak` dan pemulihan.

```bash
python scripts/patcher.py --file app.exe --profil p.json --check
python scripts/patcher.py --file app.exe --profil p.json --apply
python scripts/patcher.py --file app.exe --profil p.json --restore
```

Keluar 0 berhasil, 1 galat, 2 hash tidak cocok, 3 offset tidak sesuai, 4 sudah terpatch, 5 tanpa cadangan.

Bukti uji ada di `references/contoh-patch.md`: patch banner `curl.exe` sampai berubah perilaku, lalu dipulihkan dengan hash kembali identik.

### `scripts/vpn.py`

Kendali OpenVPN Connect desktop untuk aktivitas yang butuh egress terkontrol (dark web, OSINT identitas, penelusuran IP). Membaca state koneksi dari `%APPDATA%\OpenVPN Connect\config.json` dan memicu connect/disconnect lewat flag command-line app. Windows saja.

Sifatnya **per-operasi, bukan permanen**: nyalakan hanya selama operasi itu berjalan. Saat nyala, default route Windows dialihkan lewat tunnel; saat `disconnect`, route kembali normal dan tidak ada yang menetap di sistem. Jangan biarkan menyala berhari-hari.

```bash
python scripts/vpn.py profiles                 # daftar profil (id + nama)
python scripts/vpn.py status                   # sedang terhubung? + IP TUN
python scripts/vpn.py connect 1767186941079    # hubungkan (id atau nama profil)
python scripts/vpn.py disconnect               # putuskan koneksi aktif
```

Keluar 0 tujuan tercapai, 1 masalah lingkungan (app tak ditemukan), 2 keadaan tak berubah/bertentangan. "Terhubung" ditentukan dari IPv4 non-link-local di adapter TUN, bukan dari state app (yang persisten/stale) — lihat catatan di kode. Siklus lazim: `connect` → kerjakan operasi → `status` → `disconnect`.

### `scripts/verif.py`

Uji integritas skill itu sendiri: struktur, penomoran, rujukan, nama terlarang.

```bash
python scripts/verif.py
```

Keluar 0 = bersih, 1 = ada kegagalan, 2 = struktur tak dikenal. Jalankan sebelum mengklaim pembaruan skill selesai.

## Referensi dan aset

- `references/contoh-patch.md` — alur patch yang benar, jebakan, dan rantai REA ber-evidence.
- `assets/crackme/crackme.c` — latihan: cari cek dan tambal.
- `assets/lab/docker-compose.yml` — lab PHP rentan, siap `docker compose up`.
- `assets/detection/*.yar`, `*.yml` — kerangka indikator; isi string-nya setelah analisis, jangan ditebak.
- `references/buku-besar/` — buku besar operasi (operasi, proteksi, alat, jebakan); baca sebelum operasi, tulis sesudahnya.

## Serah terima ke skill REA

Klaim yang butuh bukti dari binary, APK, paket, firmware, atau runtime diserahkan ke skill [reverse-engineer-anything](https://github.com/morluto/rea). Hasilnya disitir sebagai `[TERBUKTI]` beserta Evidence ID; batasan dari REA wajib diteruskan.

Status integrasi:

- MCP `rea` terdaftar di 9 klien dengan provider Ghidra 12.1.4; `rea doctor` per klien `healthy: true`; handshake MCP diuji (`initialize` dijawab, `tools/list` = 229 alat).
- Jalur CLI juga terbukti: `analyze` → `search` → `address-to-file-offset` → `xrefs` → `decompile` dijalankan penuh dan menghasilkan offset yang cocok dengan kenyataan berkas.
- Sesi Trae perlu dimuat ulang sebelum alat REA muncul di daftar.

## Status uji

| Bagian | Status |
|---|---|
| `scripts/patcher.py` — hash gate, backup, idempoten, restore | TERUJI pada biner nyata |
| `scripts/panintel.py` — check/audit/gen | TERUJI |
| `scripts/verif.py` — cek struktural + G8 (urutan guardrail, exit code, nama MCP) | TERUJI (positif exit 0, 3 negatif tertangkap) |
| `scripts/vpn.py` — profiles/status/connect/disconnect | TERUJI live (2026-11-28: connect → TUN 192.168.219.5, disconnect → terputus) |
| Rantai REA ke offset file | TERUJI dengan Evidence ID |
| Kit phishing 3 langkah (demo di luar repo) | TERUJI penuh via curl + browser |
| `assets/crackme` | HIPOTESIS — perlu `gcc` |
| `assets/lab` | HIPOTESIS — perlu Docker |
| `assets/detection` | kerangka, belum diuji ke mesin YARA/SIEM |
| Blackhat SEO & dark trading | rancangan, belum ada alat |

## Batasan yang diakui

- Skill berupa instruksi; mutu akhir bergantung model yang memakainya.
- Belum ada uji beban maupun uji lintas platform selain Windows.
- Kit phishing demo tidak ada di repo; hanya anatominya yang tertulis.
- Aturan YARA/Sigma masih templat, bukan aturan produksi.
- Angka ambang (halaman doorway per hari, toleransi slippage) sengaja kosong karena harus diukur per kasus.
- `SKILL.md` cukup panjang (±700 baris); sebagian agen mungkin perlu memuat bertahap.

## Kredit

**Mastermind** — Alecs, untuk Slackercode Family.
Dibesarkan di **HN-Community — Indonesian Hacker Newbie Community** ([www.hacker-newbie.org](https://www.hacker-newbie.org)): tempat sebagian besar kebiasaan kerja di repo ini ditempa — baca dulu, jangan percaya buta, tunjukkan bukti.

Alat dan aset peta jalan:

| Berkas | Sumber |
|---|---|
| `assets/crackme/crackme.c` | ditulis untuk repo ini |
| `assets/lab/docker-compose.yml` | ditulis untuk repo ini |
| `assets/detection/*` | kerangka sendiri, pola perilaku umum |
| Integrasi `reverse-engineer-anything` | [morluto/rea](https://github.com/morluto/rea) |
| Tabel prefix BIN di `scripts/panintel.py` | rentang publik yang lazim dikenal (Amex, Diners, JCB, Discover, UnionPay, Mastercard, Visa) |
| `scripts/verif.py` | ditulis untuk repo ini |

Tidak ada kode pihak ketiga yang ditempel tanpa dicatat di sini.

## Lisensi dan risiko

**MIT** — lihat [LICENSE](LICENSE). Bebas dipakai, termasuk komersial, dengan menyertakan notis hak cipta.

Kenapa MIT dan bukan lisensi ketat: alat ini dimaksudkan dipakai, dibongkar, dan diubah. Lisensi ketat hanya menambah gesekan.

**Kenapa perlu peringatan terpisah.** MIT menyatakan perangkat lunak "AS IS" tanpa jaminan. Untuk perkakas ofensif, itu perlu dijabarkan:

- Menjalankan scanner atau exploit ke sistem pihak lain berarti mengirim trafik ke luar; dampaknya ada di target, bukan di repo ini.
- Patcher menulis berkas biner. Tanpa cadangan, berkas bisa rusak. `--restore` disediakan, tetapi pemakaian salah tetap mungkin.
- Kit phishing mengumpulkan kredensial dan OTP asli. Kebocoran kanal ekstraksi adalah risiko operasional pemakai.
- Implant menetap dan bisa memanggil kanal luar; lupa mencabutnya meninggalkan jejak.
- Data breach dan nomor kartu yang diproses tunduk pada aturan pemakai sendiri.

Ringkasnya: penulis tidak menjamin alat cocok untuk target, versi, atau beban tertentu, dan tidak menanggung akibat pemakaian. Verifikasi dulu, jangan percaya buta.

---

**Mastermind by Slackercode Family** · dibuat oleh Alecs · 2026
