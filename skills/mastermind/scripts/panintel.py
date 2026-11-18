#!/usr/bin/env python3
"""panintel - audit dump PAN, intel BIN, dan pembangkit data uji. Offline penuh.

Dipakai untuk triase cepat berkas dump kartu (combolist/dump/cvv-shop format),
validasi struktur PAN, dan pembuatan data uji sintetis. Tidak membuka socket.

Contoh:
  python panintel.py check 4111111111111111
  python panintel.py audit dump.txt --json --limit 200000
  python panintel.py gen --brand visa -n 20 --broken 0.3 --out uji.txt

Exit code: 0 semua valid / sukses, 2 PAN tunggal tidak valid, 3 dump memuat PAN cacat.
"""

import argparse
import json
import random
import re
import sys

MAKS_BARIS = 1_000_000

# Tabel prefix. Diurutkan dari prefix terpanjang agar yang paling spesifik menang.
# len = panjang PAN yang sah untuk brand tersebut.
ATURAN = [
    {"brand": "amex", "n": 2, "tepat": ("34", "37"), "rentang": None, "len": (15,)},
    {"brand": "diners", "n": 4, "tepat": ("3095",), "rentang": None, "len": (14,)},
    {"brand": "diners", "n": 2, "tepat": ("36", "38", "39"), "rentang": None, "len": (14, 16)},
    {"brand": "jcb", "n": 4, "tepat": None, "rentang": (3528, 3589), "len": (16, 17, 18, 19)},
    {"brand": "discover", "n": 6, "tepat": None, "rentang": (622126, 622925), "len": (16, 19)},
    {"brand": "discover", "n": 4, "tepat": ("6011",), "rentang": None, "len": (16,)},
    {"brand": "discover", "n": 3, "tepat": None, "rentang": (644, 649), "len": (16,)},
    {"brand": "discover", "n": 2, "tepat": ("65",), "rentang": None, "len": (16, 19)},
    {"brand": "unionpay", "n": 2, "tepat": ("62",), "rentang": None, "len": (16, 17, 18, 19)},
    {"brand": "mastercard", "n": 4, "tepat": None, "rentang": (2221, 2720), "len": (16,)},
    {"brand": "mastercard", "n": 2, "tepat": None, "rentang": (51, 55), "len": (16,)},
    {
        "brand": "maestro",
        "n": 4,
        "tepat": ("5018", "5020", "5038", "6304", "6759", "6761", "6762", "6763"),
        "rentang": None,
        "len": (12, 13, 14, 15, 16, 17, 18, 19),
    },
    {"brand": "rupay", "n": 4, "tepat": ("6521", "6522"), "rentang": None, "len": (16,)},
    {"brand": "rupay", "n": 2, "tepat": ("60",), "rentang": None, "len": (16,)},
    {"brand": "visa", "n": 1, "tepat": ("4",), "rentang": None, "len": (13, 16, 19)},
]
ATURAN.sort(key=lambda a: -a["n"])

POLA_KANDIDAT = re.compile(r"(?<!\d)(\d[\d \-]{10,25}\d)(?!\d)")
POLA_DUMP = re.compile(r"[|;:,\t]")


def bersihkan(teks):
    """Buang spasi/strip, sisakan digit saja."""
    return re.sub(r"\D", "", teks)


def cocok_brand(pan):
    """Kembalikan (brand, panjang_sah) atau (None, ()) bila prefix tak dikenal."""
    for a in ATURAN:
        if len(pan) < a["n"]:
            continue
        p = pan[: a["n"]]
        if a["tepat"] is not None and p in a["tepat"]:
            return a["brand"], a["len"]
        if a["rentang"] is not None and a["rentang"][0] <= int(p) <= a["rentang"][1]:
            return a["brand"], a["len"]
    return None, ()


def luhn_sah(pan):
    total = 0
    for i, ch in enumerate(reversed(pan)):
        d = int(ch)
        if i % 2 == 1:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return total % 10 == 0


def digit_cek(sebagian):
    total = 0
    for i, ch in enumerate(reversed(sebagian)):
        d = int(ch)
        if i % 2 == 0:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return (10 - total % 10) % 10


def periksa(pan):
    """Validasi struktur. Kembalikan dict status + alasan."""
    hasil = {"pan": pan, "panjang": len(pan), "brand": None, "luhn": None, "status": "valid", "alasan": []}
    if not pan.isdigit():
        hasil["status"] = "cacat"
        hasil["alasan"].append("bukan_digit")
        return hasil
    if not 12 <= len(pan) <= 19:
        hasil["status"] = "cacat"
        hasil["alasan"].append("panjang_di_luar_12_19")
        return hasil
    brand, panjang_sah = cocok_brand(pan)
    hasil["brand"] = brand
    if brand is None:
        hasil["status"] = "cacat"
        hasil["alasan"].append("prefix_tak_dikenal")
        return hasil
    if len(pan) not in panjang_sah:
        hasil["status"] = "cacat"
        hasil["alasan"].append("panjang_tidak_sesuai_brand")
    hasil["luhn"] = luhn_sah(pan)
    if not hasil["luhn"] and hasil["status"] == "valid":
        hasil["status"] = "cacat"
        hasil["alasan"].append("luhn_gagal")
    return hasil


def masker(pan):
    """BIN tetap tampil, tengah ditutup - bagian dari keredaksian."""
    if len(pan) <= 10:
        return pan
    return pan[:6] + "*" * (len(pan) - 10) + pan[-4:]


def cmd_check(args):
    pan = bersihkan(args.pan)
    h = periksa(pan)
    if args.json:
        print(json.dumps(h, ensure_ascii=False))
    else:
        tampil = pan if args.reveal else masker(pan)
        print(f"PAN      : {tampil}")
        print(f"brand    : {h['brand'] or 'tidak dikenal'}")
        print(f"luhn     : {h['luhn']}")
        print(f"status   : {h['status']}")
        if h["alasan"]:
            print(f"alasan   : {', '.join(h['alasan'])}")
        print("catatan  : issuer, negara, dan jenis kartu butuh tabel BIN - [HIPOTESIS] tanpa itu")
    return 0 if h["status"] == "valid" else 2


def cmd_audit(args):
    try:
        with open(args.berkas, "r", encoding="utf-8", errors="replace") as f:
            isi = f.read(args.limit * 120)
    except OSError as e:
        print(f"gagal baca {args.berkas}: {e}", file=sys.stderr)
        return 1

    baris = isi.splitlines()[: args.limit]
    if len(baris) >= MAKS_BARIS:
        print(f"peringatan: dipotong di {MAKS_BARIS} baris", file=sys.stderr)

    kemunculan = 0
    kandidat = []
    baris_dump = 0
    for b in baris:
        if POLA_DUMP.search(b):
            baris_dump += 1
        for m in POLA_KANDIDAT.findall(b):
            kemunculan += 1
            kandidat.append(bersihkan(m))

    unik = list(dict.fromkeys(kandidat))
    hasil = [periksa(p) for p in unik]

    sah = [h for h in hasil if h["status"] == "valid"]
    cacat = [h for h in hasil if h["status"] != "valid"]
    per_brand = {}
    per_bin = {}
    per_alasan = {}
    for h in hasil:
        per_brand[h["brand"] or "tak_dikenal"] = per_brand.get(h["brand"] or "tak_dikenal", 0) + 1
        per_bin[h["pan"][:6]] = per_bin.get(h["pan"][:6], 0) + 1
        for a in h["alasan"]:
            per_alasan[a] = per_alasan.get(a, 0) + 1

    ringkas = {
        "berkas": args.berkas,
        "baris_dibaca": len(baris),
        "baris_berpola_dump": baris_dump,
        "kemunculan_pan": kemunculan,
        "unik": len(unik),
        "duplikat": kemunculan - len(unik),
        "valid": len(sah),
        "cacat": len(cacat),
        "rasio_valid": round(len(sah) / len(unik), 4) if unik else 0.0,
        "per_brand": dict(sorted(per_brand.items(), key=lambda x: -x[1])),
        "top_bin": dict(sorted(per_bin.items(), key=lambda x: -x[1])[:10]),
        "alasan_cacat": dict(sorted(per_alasan.items(), key=lambda x: -x[1])),
        "catatan": "negara/issuer/jenis kartu tidak disimpulkan tanpa tabel BIN - [HIPOTESIS]",
    }

    if args.json:
        print(json.dumps(ringkas, ensure_ascii=False, indent=2))
    else:
        print("RINGKASAN AUDIT")
        for k in ("berkas", "baris_dibaca", "baris_berpola_dump", "kemunculan_pan", "unik", "duplikat", "valid", "cacat", "rasio_valid"):
            print(f"{k:20}: {ringkas[k]}")
        print("per_brand           : " + (", ".join(f"{k}={v}" for k, v in per_brand.items()) or "-"))
        print("top_bin             : " + (", ".join(f"{k}={v}" for k, v in list(per_bin.items())[:10]) or "-"))
        print("alasan_cacat        : " + (", ".join(f"{k}={v}" for k, v in per_alasan.items()) or "-"))
        print("catatan             : " + ringkas["catatan"])
        if args.tampilkan_cacat and cacat:
            print("\nCONTOH CACAT")
            for h in cacat[:10]:
                print(f"  {masker(h['pan']):24} {'/'.join(h['alasan'])}")
    return 0 if not cacat else 3


def cmd_gen(args):
    brand = args.brand
    if brand == "acak":
        brand = random.choice(sorted({a["brand"] for a in ATURAN}))
    aturan = [a for a in ATURAN if a["brand"] == brand]
    if not aturan:
        print(f"brand tak dikenal: {brand}", file=sys.stderr)
        return 1
    a = random.choice(aturan)
    if a["tepat"]:
        prefix = random.choice(a["tepat"])
    else:
        prefix = str(random.randint(*a["rentang"]))
    panjang = random.choice(a["len"])

    keluaran = []
    for _ in range(args.n):
        badan = prefix + "".join(random.choice("0123456789") for _ in range(panjang - len(prefix) - 1))
        pan = badan + str(digit_cek(badan))
        if random.random() < args.broken:
            pan = pan[:-1] + str((int(pan[-1]) + random.randint(1, 9)) % 10)
        keluaran.append(pan)

    teks = "\n".join(keluaran) + "\n"
    if args.out:
        with open(args.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(teks)
        print(f"{len(keluaran)} PAN ditulis ke {args.out}", file=sys.stderr)
        print(f"brand={brand} cacat_disengaja={args.broken}")
    else:
        sys.stdout.write(teks)
    return 0


def main():
    p = argparse.ArgumentParser(prog="panintel", description="Audit dump PAN, intel BIN, dan pembangkit data uji. Offline.")
    sub = p.add_subparsers(dest="cmd", required=True)

    c = sub.add_parser("check", help="validasi satu PAN")
    c.add_argument("pan")
    c.add_argument("--json", action="store_true")
    c.add_argument("--reveal", action="store_true", help="tampilkan PAN utuh, bukan bertopeng")
    c.set_defaults(func=cmd_check)

    a = sub.add_parser("audit", help="audit berkas dump")
    a.add_argument("berkas")
    a.add_argument("--json", action="store_true")
    a.add_argument("--limit", type=int, default=MAKS_BARIS)
    a.add_argument("--tampilkan-cacat", action="store_true")
    a.set_defaults(func=cmd_audit)

    g = sub.add_parser("gen", help="bangkitkan PAN sintetis")
    g.add_argument("--brand", default="acak", choices=sorted({x["brand"] for x in ATURAN}) + ["acak"])
    g.add_argument("-n", type=int, default=20)
    g.add_argument("--broken", type=float, default=0.0, help="rasio cacat sengaja 0..1")
    g.add_argument("--out")
    g.set_defaults(func=cmd_gen)

    args = p.parse_args()
    sys.exit(args.func(args))


if __name__ == "__main__":
    main()
