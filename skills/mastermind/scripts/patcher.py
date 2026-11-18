#!/usr/bin/env python3
"""patcher.py — penambal berkas biner berbasis profil. Aman diulang, selalu bisa dibalik.

Kontrak:
    patcher.py --file BINER --profil PROFIL.json --check
    patcher.py --file BINER --profil PROFIL.json --apply
    patcher.py --file BINER --profil PROFIL.json --restore

Bentuk profil:
    {
      "nama": "crackme-01",
      "versi_target": "1.0.0",
      "sha256_asli": "<hash berkas sebelum patch>",
      "catatan": "melewati cek serial",
      "patch": [{"offset": 4096, "dari": "74", "ke": "EB", "catatan": "jne -> jmp"}]
    }

Exit code: 0 berhasil · 1 galat · 2 sha256 tidak cocok · 3 offset tidak sesuai
           4 sudah terpatch (apply) · 5 cadangan tidak ada (restore)

Stdlib saja. Offset dihitung dari awal berkas, 0-based, hex tanpa awalan 0x.
"""

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path

CADANGAN = ".bak"


def baca_profil(path: Path) -> dict:
    try:
        profil = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as galat:
        keluar(f"profil tidak terbaca: {galat}", 1)
    if not isinstance(profil.get("patch"), list) or not profil["patch"]:
        keluar("profil harus memuat daftar 'patch' yang tidak kosong", 1)
    return profil


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def keadaan(data: bytes, satu: dict) -> str:
    offset = int(satu["offset"])
    if offset >= len(data):
        return "di_luar_berkas"
    sekarang = f"{data[offset]:02X}"
    if sekarang == satu["ke"].upper():
        return "terpatch"
    if sekarang == satu["dari"].upper():
        return "asli"
    return "lain"


def keluar(pesan: str, kode: int) -> None:
    print(pesan, file=sys.stderr)
    raise SystemExit(kode)


def main() -> int:
    p = argparse.ArgumentParser(description="Penambal biner berbasis profil")
    p.add_argument("--file", required=True, type=Path)
    p.add_argument("--profil", required=True, type=Path)
    aksi = p.add_mutually_exclusive_group(required=True)
    aksi.add_argument("--check", action="store_true")
    aksi.add_argument("--apply", action="store_true")
    aksi.add_argument("--restore", action="store_true")
    p.add_argument("--abaikan-hash", action="store_true",
                   help="lewati pemeriksaan sha256 asli (untuk build yang tidak persis sama)")
    arg = p.parse_args()

    if not arg.file.is_file():
        keluar(f"berkas tidak ada: {arg.file}", 1)
    profil = baca_profil(arg.profil)
    cadangan = arg.file.with_suffix(arg.file.suffix + CADANGAN)
    data = arg.file.read_bytes()

    if arg.restore:
        if not cadangan.is_file():
            keluar(f"cadangan tidak ada: {cadangan}", 5)
        asli = cadangan.read_bytes()
        if "sha256_asli" in profil and sha256(asli) != profil["sha256_asli"]:
            keluar("cadangan tidak cocok dengan sha256_asli profil", 2)
        os.replace(cadangan, arg.file)
        print(f"dipulihkan: {arg.file} ({len(asli)} byte)")
        return 0

    daftar = [(satu, keadaan(data, satu)) for satu in profil["patch"]]

    if arg.check:
        for satu, status in daftar:
            print(f"offset {satu['offset']:>8} [{status}] {satu.get('catatan', '')}")
        ringkas = {s for _, s in daftar}
        if ringkas == {"terpatch"}:
            print("status: seluruh patch sudah terpasang")
            return 0
        if ringkas <= {"asli"}:
            print("status: berkas masih asli")
            return 0
        print("status: campuran / tidak dikenal")
        return 3

    # --apply
    if all(s == "terpatch" for _, s in daftar):
        print("sudah terpatch, tidak ada yang diubah")
        return 4

    for satu, status in daftar:
        if status not in ("asli", "terpatch"):
            keluar(f"offset {satu['offset']} berisi {status}, bukan '{satu['dari']}' — build salah?", 3)

    if "sha256_asli" in profil and not arg.abaikan_hash:
        if sha256(data) != profil["sha256_asli"]:
            keluar(f"sha256 tidak cocok: {sha256(data)} != {profil['sha256_asli']}", 2)

    if not cadangan.is_file():
        cadangan.write_bytes(data)

    baru = bytearray(data)
    for satu, status in daftar:
        if status == "asli":
            baru[int(satu["offset"])] = int(satu["ke"], 16)
    sementara = arg.file.with_suffix(arg.file.suffix + ".tmp")
    sementara.write_bytes(baru)
    os.replace(sementara, arg.file)

    terpasang = sum(1 for _, s in daftar if s == "asli")
    print(f"terpasang {terpasang} patch pada {arg.file}")
    print(f"cadangan: {cadangan}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
