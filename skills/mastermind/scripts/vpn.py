#!/usr/bin/env python3
"""vpn.py — kendali OpenVPN Connect (app desktop) untuk aktivitas yang butuh egress terkontrol.

Membaca status koneksi dari berkas state app dan memicu connect/disconnect lewat
flag command-line yang app itu baca saat launch. Windows saja (app desktop
OpenVPN Connect); di platform lain perintah menolak dengan pesan jelas.

Sumber kebenaran (diverifikasi dari `resources/app.asar` + uji live 2026-11-28):
  * state  : %APPDATA%\\OpenVPN Connect\\config.json
             -> "persist:root" (string JSON) -> "status" (string JSON)
             -> connectedProfile (dict bila terhubung), connectorActive (bool)
  * profil : ... -> status -> profiles : dict keyed by id profil
  * trigger: flag `--connect-shortcut=<id>` dan `--disconnect-shortcut` dibaca
             dari `app.commandLine` -> app harus DILAUNCH SEGAR (kill dulu),
             flag tak berguna bila di-attach ke proses yang sudah jalan.

Contoh:
  python vpn.py profiles
  python vpn.py status
  python vpn.py connect 1767186941079
  python vpn.py disconnect
  python vpn.py status --tunggu 30     # tunggu sampai connected, maks 30 dtk

Exit code: 0 tujuan tercapai / info lengkap, 1 masalah lingkungan (app tak
ditemukan), 2 keadaan berlawanan dengan yang diminta (status: tak terhubung;
connect/disconnect: tak berubah setelah jeda tunggu).

Author: Alecs — Slackercode Family
Copyright (c) 2026 Alecs (Slackercode Family)
"""

import argparse
import json
import os
import platform
import subprocess
import sys
import time
from pathlib import Path

APlikasi = "OpenVPN Connect"
NAMA_EXE = "OpenVPNConnect.exe"
JEDA_POLING = 3        # detik antar cek saat menunggu state berubah
MAKS_CARI_EXE = ["C:\\Program Files", "C:\\Program Files (x86)"]


def lokasi_state():
    """Path config.json milik OpenVPN Connect, atau None bila app tak ada."""
    if os.name != "nt":
        return None
    appdata = os.environ.get("APPDATA")
    if not appdata:
        return None
    berkas = Path(appdata) / APlikasi / "config.json"
    return berkas if berkas.is_file() else None


def cari_exe():
    """Cari OpenVPNConnect.exe di Program Files, atau None."""
    for basis in MAKS_CARI_EXE:
        kandidat = Path(basis) / APlikasi / NAMA_EXE
        if kandidat.is_file():
            return str(kandidat)
    return None


def baca_status():
    """Pembalikan layer JSON state app -> (dict_status, dict_profil)."""
    berkas = lokasi_state()
    if not berkas:
        return None, None
    with open(berkas, encoding="utf-8") as f:
        akar = json.load(f)
    root = json.loads(akar["persist:root"])
    status = root.get("status")
    if isinstance(status, str):
        status = json.loads(status)
    return status or {}, (status or {}).get("profiles") or {}


def ip_tun():
    """IPv4 antarmuka TUN adapter OpenVPN Connect (ground truth koneksi).

    Adapter TAP-nya bernama bebas oleh app (mis. "OPEN VPN"), jadi jangan
    match nama — match deskripsi "OpenVPN Connect" yang stabil. None bila
    tak ada IPv4 di adapter itu (= koneksi mati). [TERBUKTI 2026-11-28]
    """
    try:
        ps = ("$a = Get-NetAdapter | Where-Object { "
              "$_.InterfaceDescription -match 'OpenVPN Connect' } | "
              "Select-Object -First 1; "
              "if ($a) { Get-NetIPAddress -InterfaceIndex $a.ifIndex | "
              "Where-Object { $_.AddressFamily -eq 'IPv4' } | "
              "Select-Object -First 1 -ExpandProperty IPAddress }")
        hasil = subprocess.run(
            ["powershell", "-NoProfile", "-Command", ps],
            capture_output=True, text=True, timeout=15)
        nilai = hasil.stdout.strip()
        return nilai or None
    except Exception:
        return None


def terhubung_hidup():
    """Apakah tunnel VPN benar-benar hidup sekarang.

    Satu-satunya acuan live = IPv4 non-link-local di adapter TUN. Saat
    tunnel mati, adapter TAP tetap "Up" tapi hanya memegang alamat
    APIPA 169.254.x.x [TERBUKTI 2026-11-28]. State app
    (`connectorActive`, `connectedProfile`) persisten/stale dan tidak
    bisa jadi acuan sendirian.
    """
    ip = ip_tun()
    return bool(ip) and not ip.startswith("169.254.")


def profil_terhubung(status):
    """(id, nama) profil yang sedang terhubung, atau None bila tak hidup."""
    if not terhubung_hidup():
        return None
    terhubung = status.get("connectedProfile")
    if isinstance(terhubung, dict) and terhubung.get("id"):
        return terhubung["id"], terhubung.get("profileDisplayName") \
            or terhubung.get("profileName")
    return ("?profil tak terbaca?", None)


def proses_jalan():
    """Apakah OpenVPNConnect.exe sedang berjalan."""
    if os.name != "nt":
        return False
    try:
        hasil = subprocess.run(
            ["tasklist", "/FI", "IMAGENAME eq %s" % NAMA_EXE],
            capture_output=True, text=True, timeout=10)
        return NAMA_EXE in hasil.stdout
    except Exception:
        return False


def matikan_aplikasi():
    """Hentikan semua proses OpenVPNConnect.exe (diperlukan sebelum launch berflag)."""
    subprocess.run(["taskkill", "/f", "/im", NAMA_EXE],
                   capture_output=True, timeout=15)
    time.sleep(2)


def luncur(flag):
    """Launch app segar dengan satu flag command-line (ex. '--connect-shortcut=ID')."""
    exe = cari_exe()
    if not exe:
        print("OpenVPNConnect.exe tak ditemukan di Program Files [LINGKUNGAN]")
        return 1
    subprocess.Popen([exe, flag],
                     creationflags=getattr(subprocess, "CREATE_NEW_CONSOLE", 0))
    return 0


def tunggu_state(predikat, durasi):
    """Awas state app sampai `predikat` benar atau `durasi` habis. True bila tercapai."""
    batas = time.time() + durasi
    while time.time() < batas:
        status, _ = baca_status()
        if predikat(status):
            return True
        time.sleep(JEDA_POLING)
    status, _ = baca_status()
    return predikat(status)


def cmd_profiles(_args):
    status, profil = baca_status()
    if status is None:
        print("app OpenVPN Connect tak terdeteksi (config.json tak ada) [LINGKUNGAN]")
        return 1
    if not profil:
        print("belum ada profil di OpenVPN Connect [KOSONG]")
        return 2
    hasil = profil_terhubung(status)
    terhubung_id = hasil[0] if hasil else None
    for pid, p in profil.items():
        nama = p.get("profileName", "(tanpa nama)")
        kata = {
            "id": pid,
            "nama": nama,
            "passwordTersimpan": p.get("savedPassword", False),
            "terhubung": pid == terhubung_id,
        }
        print(json.dumps(kata, ensure_ascii=False))
    return 0


def cmd_status(args):
    status, _ = baca_status()
    if status is None:
        print("app OpenVPN Connect tak terdeteksi [LINGKUNGAN]")
        return 1
    hasil = profil_terhubung(status)
    pid, nama = hasil if hasil else (None, None)
    terhubung = pid is not None
    if args.tunggu:
        terhubung = pid is not None or tunggu_state(
            lambda s: profil_terhubung(s) is not None, args.tunggu)
        if terhubung:
            status, _ = baca_status()
            hasil = profil_terhubung(status)
            pid, nama = hasil if hasil else (None, None)
    keluaran = {
        "terhubung": terhubung,
        "profil": nama if terhubung else None,
        "profilId": pid if terhubung else None,
        "connectorActive": bool(status.get("connectorActive")),
        "ipTun": ip_tun() if terhubung else None,
    }
    print(json.dumps(keluaran, ensure_ascii=False))
    return 0 if terhubung else 2


def cmd_connect(args):
    status, profil = baca_status()
    if status is None:
        print("app OpenVPN Connect tak terdeteksi [LINGKUNGAN]")
        return 1
    target = args.profil
    if target.isdigit() and target not in profil:
        print("id profil tak dikenal: %s (lihat: python vpn.py profiles)" % target)
        return 2
    # pilih profil bila user memberi nama, bukan id
    if not target.isdigit():
        cocok = [pid for pid, p in profil.items()
                 if p.get("profileName", "").lower() == target.lower()]
        if len(cocok) != 1:
            print("nama profil tak cocok/ ambigu: %r (lihat: python vpn.py profiles)"
                  % target)
            return 2
        target = cocok[0]
    sudah = profil_terhubung(status)
    if sudah and sudah[0] == target:
        print("sudah terhubung ke profil %s [SUDAH]" % target)
        return 0
    matikan_aplikasi()
    if luncur("--connect-shortcut=%s" % target) != 0:
        return 1
    print("meluncurkan connect untuk %s ... menunggu konfirmasi" % target)
    capai = tunggu_state(
        lambda s: profil_terhubung(s) and profil_terhubung(s)[0] == target,
        args.tunggu)
    status2, _ = baca_status()
    hasil = profil_terhubung(status2)
    if capai and hasil and hasil[0] == target:
        print("TERHUBUNG ke %s (ip TUN: %s)"
              % (target, ip_tun() or "tak terbaca"))
        return 0
    print("belum terhubung setelah %d dtk [TIDAK BERUBAH]" % args.tunggu)
    return 2


def cmd_disconnect(args):
    status, _ = baca_status()
    if status is None:
        print("app OpenVPN Connect tak terdeteksi [LINGKUNGAN]")
        return 1
    hasil = profil_terhubung(status)
    pid, nama = hasil if hasil else (None, None)
    if not pid:
        print("tidak ada koneksi aktif [SUDAH MATI]")
        return 0
    matikan_aplikasi()
    if luncur("--disconnect-shortcut") != 0:
        return 1
    print("meluncurkan disconnect %s ... menunggu konfirmasi" % (nama or pid))
    capai = tunggu_state(lambda s: profil_terhubung(s) is None, args.tunggu)
    status2, _ = baca_status()
    if capai and profil_terhubung(status2) is None:
        print("TERPUTUS (profil %s)" % (nama or pid))
        return 0
    print("masih terhubung setelah %d dtk [TIDAK BERUBAH]" % args.tunggu)
    return 2


def main():
    if os.name != "nt":
        print("vpn.py melayani OpenVPN Connect desktop (Windows). "
              "Platform ini: %s [LINGKUNGAN]" % platform.system())
        return 1
    parser = argparse.ArgumentParser(
        description="Kendali OpenVPN Connect untuk aktivitas yang butuh egress terkontrol.")
    sub = parser.add_subparsers(dest="perintah", required=True)

    p_prof = sub.add_parser("profiles", help="daftar profil yang tersedia")
    p_prof.set_defaults(func=cmd_profiles)

    p_stat = sub.add_parser("status", help="status koneksi sekarang")
    p_stat.add_argument("--tunggu", type=int, default=0,
                        help="dtk maksimal tunggu sampai connected (0 = cek sekali)")
    p_stat.set_defaults(func=cmd_status)

    p_con = sub.add_parser("connect", help="hubungkan ke profil (id atau nama)")
    p_con.add_argument("profil", help="id profil (mis. 1767186941079) atau nama persisnya")
    p_con.add_argument("--tunggu", type=int, default=45,
                       help="dtk maksimal tunggu sampai connected (default 45)")
    p_con.set_defaults(func=cmd_connect)

    p_dis = sub.add_parser("disconnect", help="putuskan koneksi aktif")
    p_dis.add_argument("--tunggu", type=int, default=60,
                       help="dtk maksimal tunggu sampai terputus (default 60)")
    p_dis.set_defaults(func=cmd_disconnect)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
