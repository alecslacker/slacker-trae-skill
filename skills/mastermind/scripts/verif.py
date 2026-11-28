#!/usr/bin/env python3
"""verif.py — uji integritas skill Mastermind.

Cek struktural cepat, nol dependensi di luar stdlib Python.
Jalankan dari mana saja:
    python3 scripts/verif.py [root_skill]
Tanpa argumen, root = dua level di atas berkas ini (root skill).

Cek: frontmatter (nama folder, format description), jumlah fence,
penomoran section, path rujukan yang ada (root, folder tetangga, atau
lokasi pemasangan skill yang lazim — env MM_SKILL_DIRS menambah lokasi),
nama terlarang/penggalan ejaan,
keberadaan buku besar dan skrip, urutan guardrail G0–G8,
kesetaraan exit code docstring↔README (G8), dan nama MCP yang dirujuk
(hanya bila env MM_KNOWN_MCP diset — daftar koma; tidak diset = dilewati,
tidak pernah gagal).

Exit: 0 = bersih, 1 = ada kegagalan, 2 = struktur tak dikenal.
Author: Alecs — Slackercode Family
Copyright (c) 2026 Alecs (Slackercode Family)
"""
import os
import re
import sys
from pathlib import Path


def gari_frontmatter(teks):
    """Kembalikan (nama, description) dari frontmatter ---, atau (None, None)."""
    if not teks.startswith("---"):
        return None, None
    akhir = teks.find("\n---", 3)
    if akhir < 0:
        return None, None
    blok = teks[3:akhir]
    nama = re.search(r"^name:\s*(\S+)", blok, re.M)
    desk = re.search(r"^description:\s*(.+)$", blok, re.M)
    return (nama.group(1) if nama else None,
            desk.group(1).strip() if desk else None)


def baris_di_luar_fence(teks):
    """Isi baris yang berada di luar balok kode (agar heading contoh tak ikut)."""
    luar, dalam = [], False
    for baris in teks.splitlines():
        if baris.startswith("```"):
            dalam = not dalam
            continue
        if not dalam:
            luar.append(baris)
    return luar


def dir_pencarian_lintas(root):
    """Direktori induk yang masing-masing memuat folder skill lain:
    induk repo (folder tetangga) + lokasi pemasangan skill yang lazim
    (~/.zcode, ~/.agents, ~/.trae, ~/.claude). Env MM_SKILL_DIRS
    (daftar koma) menambah lokasi pemasangan yang tidak standar."""
    lokasi = [root.parent]
    home = Path.home()
    for rel in (".zcode/skills", ".agents/skills", ".trae/skills", ".claude/skills"):
        kandidat = home / rel
        if kandidat.is_dir():
            lokasi.append(kandidat)
    for bagian in os.environ.get("MM_SKILL_DIRS", "").split(","):
        bagian = bagian.strip()
        if bagian:
            lokasi.append(Path(bagian))
    return lokasi


def cek(root):
    gagal, peringat = [], []
    skill = root / "SKILL.md"
    if not skill.is_file():
        return ["SKILL.md tidak ditemukan di %s" % root], []
    teks = skill.read_text(encoding="utf-8")

    # 1. frontmatter: nama harus sama folder; description tanpa ': ' dan <>
    nama, desk = gari_frontmatter(teks)
    if nama is None:
        gagal.append("frontmatter tidak lengkap")
    else:
        if nama != root.name:
            gagal.append("frontmatter name '%s' != nama folder '%s'" % (nama, root.name))
        if desk is None:
            gagal.append("description tidak ada")
        elif ": " in desk:
            gagal.append("description mengandung ': ' (format larangan)")
        elif "<" in desk or ">" in desk:
            gagal.append("description mengandung '<' atau '>' (format larangan)")

    # 2. jumlah fence harus genap
    if len(re.findall(r"^```", teks, re.M)) % 2:
        gagal.append("jumlah fence ganjil")

    # 3. penomoran section berurutan mulai 1 (heading di luar fence saja)
    nomor = []
    for baris in baris_di_luar_fence(teks):
        cocok = re.match(r"^## (\d+)\. ", baris)
        if cocok:
            nomor.append(int(cocok.group(1)))
    if nomor != list(range(1, len(nomor) + 1)):
        gagal.append("penomoran section tidak berurutan: %s" % nomor)

    # 4. path relatif yang dirujuk harus ada (root, folder tetangga, atau
    #    lokasi pemasangan skill yang dikenal — lihat dir_pencarian_lintas)
    for rujukan in sorted(set(re.findall(r"`((?:scripts|assets|references)/[^`]+?)`", teks))):
        target = rujukan.rstrip("/")
        if (root / target).exists():
            continue
        ditemukan = any(
            list(induk.glob("*/" + target)) for induk in dir_pencarian_lintas(root)
        )
        if not ditemukan:
            gagal.append("path yang dirujuk tidak ada: %s" % rujukan)

    # 5. nama terlarang & penggalan ejaan lama
    for i, baris in enumerate(teks.splitlines(), 1):
        if re.search(r"Slackercod(?!e)", baris):
            gagal.append("baris %d: penggalan 'Slackercod' (seharusnya Slackercode)" % i)
        if "Slackercoder Family" in baris:
            gagal.append("baris %d: 'Slackercoder Family' (keluarga = Slackercode Family)" % i)
        if ("Wondho" in baris or "Duta Corpora" in baris or "DCI" in baris) \
                and "DILARANG MUTLAK" not in baris:
            peringat.append("baris %d: nama terlarang muncul di luar baris DILARANG MUTLAK" % i)

    # 6. buku besar dan skrip wajib ada
    for berkas in ["operasi.md", "proteksi.md", "alat.md", "jebakan.md"]:
        if not (root / "references" / "buku-besar" / berkas).is_file():
            gagal.append("buku besar tidak ada: references/buku-besar/%s" % berkas)
    for berkas in ["panintel.py", "patcher.py", "vpn.py"]:
        if not (root / "scripts" / berkas).is_file():
            gagal.append("skrip tidak ada: scripts/%s" % berkas)

    # 7. (G8) guardrail G0–G8 berurutan mulai G0
    urutan = [int(m.group(1)) for m in re.finditer(r"^### G(\d+) — ", teks, re.M)]
    if urutan != list(range(len(urutan))):
        gagal.append("guardrail G tidak berurutan mulai G0: %s" % urutan)

    # 8. (G8) exit code: docstring skrip vs README harus setara
    isi_readme = (root / "README.md").read_text(encoding="utf-8")
    teks_rm = re.sub(r"```.*?```", "", isi_readme, flags=re.S)
    for skrip in ["panintel.py", "patcher.py"]:
        isi = (root / "scripts" / skrip).read_text(encoding="utf-8")
        # docstring: segmen dari "Exit code:" sampai baris kosong
        m = re.search(r"Exit code:\s*", isi, re.I)
        if not m:
            gagal.append("exit code tidak terdokumentasi di docstring: scripts/%s" % skrip)
            continue
        segmen = isi[m.end():].split("\n\n")[0]
        kdoc = {int(n) for n in re.findall(r"\b(\d{1,2})\b", segmen)}
        blok = re.search(r"### `scripts/%s`.*?(?=\n### |\n## |\Z)" % re.escape(skrip),
                         teks_rm, re.S)
        if not blok:
            gagal.append("blok README tidak ditemukan: scripts/%s" % skrip)
            continue
        kreadme = set()
        for baris in blok.group(0).splitlines():
            if baris.lstrip().startswith("Keluar"):
                kreadme = {int(n) for n in re.findall(r"\b(\d{1,2})\b", baris)}
        if not kreadme:
            gagal.append("exit code tidak terdokumentasi di README: scripts/%s" % skrip)
            continue
        if kdoc != kreadme:
            gagal.append("exit code %s tak setara: docstring %s vs README %s (G8)" %
                         (skrip, sorted(kdoc), sorted(kreadme)))

    # 9. (G8) nama MCP yang dirujuk — hanya bila MM_KNOWN_MCP diset (daftar koma)
    dikenal = os.environ.get("MM_KNOWN_MCP", "")
    if dikenal:
        daftar = {t.strip() for t in dikenal.split(",") if t.strip()}
        luar = "\n".join(baris_di_luar_fence(teks))
        for baris in luar.splitlines():
            for nama in re.findall(r"MCP `([a-z0-9_-]+)`", baris):
                if nama not in daftar:
                    gagal.append("MCP dirujuk tapi tak dikenal di environment: %s "
                                 "(set MM_KNOWN_MCP dari mcp.json/daftar aktif)" % nama)

    return gagal, peringat


def main():
    if len(sys.argv) > 2:
        print("pakai: python3 scripts/verif.py [root_skill]  (env MM_KNOWN_MCP=koma:daftar_mcp utk cek nama MCP)")
        return 2
    root = Path(sys.argv[1]) if len(sys.argv) == 2 else Path(__file__).resolve().parent.parent
    if not root.is_dir():
        print("root tidak ditemukan: %s" % root)
        return 2
    gagal, peringat = cek(root)
    for p in peringat:
        print("[PERINGATAN] %s" % p)
    for g in gagal:
        print("[GAGAL] %s" % g)
    if gagal:
        print("HASIL: %d kegagalan, %d peringatan" % (len(gagal), len(peringat)))
        return 1
    print("HASIL: BERSIH — 0 kegagalan, %d peringatan (root: %s)" % (len(peringat), root))
    return 0


if __name__ == "__main__":
    sys.exit(main())
