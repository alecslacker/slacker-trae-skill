#!/usr/bin/env python3
"""Generator gambar Seedream 5.0 (BytePlus ModelArk) — standalone & aman.

Menggunakan API resmi BytePlus images/generations secara langsung sehingga
tidak terikat validasi enum MCP byteplus-image yang masih Seedream 4.x.

Keamanan:
- API key hanya dibaca dari env var ARK_API_KEY, TIDAK pernah dicetak ke output.
- Semua request HTTPS (SSL default), timeout default 120 detik.
- Download hasil divalidasi: content-type image/*, maksimal 20 MB.
"""
import argparse
import json
import os
import pathlib
import sys
import time
import urllib.error
import urllib.request

API_URL = "https://ark.ap-southeast.bytepluses.com/api/v3/images/generations"
API_MODELS_URL = "https://ark.ap-southeast.bytepluses.com/api/v3/models"

# Kombinasi utama akun Mas Wondho (2026-08-31, verifikasi konsol + API):
# Dola-Seedream-5.0-pro + Dola-Seedream-5.0-lite, dengan 4.5 sebagai opsi cadangan.
MODELS = {
    "pro": {
        "id": "dola-seedream-5-0-pro-260628",
        "sizes": ["1K", "1.5K", "2K"],
        "desc": "Dola-Seedream-5.0-pro - $0.045/gbr; precise editing, layer control, teks multibahasa (termasuk Indonesia)",
    },
    "lite": {
        "id": "seedream-5-0-260128",
        "sizes": ["2K", "3K", "4K"],
        "desc": "Dola-Seedream-5.0-lite - $0.035/gbr; estetika terbaru, konsistensi, batch, hemat",
    },
    "4.5": {
        "id": "seedream-4-5-251128",
        "sizes": ["2K", "4K"],
        "desc": "Seedream 4.5 - $0.04/gbr; opsi cadangan, text rendering klasik",
    },
}

# Alias model ID yang umum ditemui di docs, dipetakan ke ID asli akun.
MODEL_ALIASES = {
    "seedream-5-0-lite-260128": "seedream-5-0-260128",
}

MAX_DOWNLOAD_BYTES = 20 * 1024 * 1024  # 20 MB, cegah file raksasa tak terduga


def resolve_model(model_arg: str) -> str:
    """Terima '4.5'/'lite' atau model ID lengkap; validasi terhadap daftar resmi."""
    if model_arg in MODELS:
        return MODELS[model_arg]["id"]
    # Hiraukan alias yang umum dari docs
    if model_arg in MODEL_ALIASES:
        return MODEL_ALIASES[model_arg]
    # Model ID lengkap — pastikan dikenal untuk hindari salah ketik
    for info in MODELS.values():
        if info["id"] == model_arg:
            return model_arg
    sys.exit(f"ERROR: model '{model_arg}' tidak valid. Pilihan: pro, lite, 4.5, atau ID lengkap "
             "(jalankan --list-models).")


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Generate gambar Seedream 5.0 via API BytePlus ModelArk.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Contoh:\n"
            "  seedream5_generate.py --list-models\n"
            "  seedream5_generate.py --prompt \"minimalist geometric logo...\" --model pro --size 2K\n"
            "  seedream5_generate.py --prompt \"...\" --model lite --size 4K --seed 42\n"
        ),
    )
    parser.add_argument("--prompt", help="Deskripsi gambar (3-2000 karakter)")
    parser.add_argument("--model", default="pro", help="pro | lite | 4.5 | model ID lengkap (default: pro)")
    parser.add_argument("--size", default=None, help="Resolusi: pro 1K/1.5K/2K, lite 2K/3K/4K, 4.5 2K/4K")
    parser.add_argument("--count", type=int, default=1, help="Jumlah gambar (1-15)")
    parser.add_argument("--out", default=None, help="Folder penyimpanan (default: ~/Pictures/byteplus-seedream5)")
    parser.add_argument("--seed", type=int, default=None, help="Seed reproducible (opsional)")
    parser.add_argument("--watermark", action="store_true", help="Tambahkan watermark ByteDance")
    parser.add_argument("--timeout", type=int, default=120, help="Timeout request dalam detik (default 120)")
    parser.add_argument("--list-models", action="store_true", help="Tampilkan model yang tersedia lalu keluar")
    parser.add_argument("--list-live", action="store_true",
                        help="Tampilkan model yang terakses akun via API (butuh ARK_API_KEY)")
    return parser.parse_args(argv)


def list_models():
    """Cetak daftar model (Dola 5.0 pro + lite + 4.5) tanpa memerlukan API key."""
    print("Model Seedream yang didukung skill ini (kombinasi Dola 5.0):\n")
    for key, info in MODELS.items():
        print(f"  {key:4} -> {info['id']}")
        print(f"        resolusi: {', '.join(info['sizes'])}")
        print(f"        {info['desc']}\n")
    print("Catatan: pastikan model sudah diaktifkan di konsol BytePlus ModelArk "
          "(region ap-southeast-1) sebelum dipakai.")


def require_key() -> str:
    """Ambil ARK_API_KEY dari env; keluar dengan instruksi bila tidak tersedia."""
    api_key = os.environ.get("ARK_API_KEY")
    if not api_key or len(api_key) < 20:
        print("ERROR: ARK_API_KEY tidak ditemukan atau tidak valid.\n", file=sys.stderr)
        print("  Buat key di: https://ai.byteplus.com/ark/region:ap-southeast-1/apikey", file=sys.stderr)
        print("  Lalu set:  $env:ARK_API_KEY = \"sk-xxxxx\"", file=sys.stderr)
        sys.exit(2)
    return api_key


def list_live_models(api_key: str) -> None:
    """Query endpoint /models untuk melihat model yang benar-benar terakses akun."""
    req = urllib.request.Request(
        API_MODELS_URL,
        headers={"Authorization": f"Bearer {api_key}"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            raw = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        sys.exit(f"ERROR HTTP {e.code}: {e.reason} — cek ARK_API_KEY dan izin akun.")
    except urllib.error.URLError as e:
        sys.exit(f"ERROR jaringan: {e.reason}")
    try:
        data = json.loads(raw).get("data", [])
    except json.JSONDecodeError:
        sys.exit(f"ERROR: respons bukan JSON valid. Cuplikan: {raw[:300]}")
    if not data:
        print("Model list kosong — model belum diaktifkan di konsol BytePlus "
              "(region ap-southeast-1).")
        return
    print("Model yang terakses akun ini:\n")
    for m in data:
        print(f"  - {m.get('id', '?')}   (owned_by: {m.get('owned_by', '')})")
    print("\nGunakan nilai id di atas pada argumen --model "
          "(atau singkatan 'lite' / '4.5').")


def download_image(url: str, dest_dir: pathlib.Path, index: int, model_tag: str) -> pathlib.Path:
    """Unduh gambar hasil ke disk dengan validasi ukuran & content-type."""
    req = urllib.request.Request(url, method="GET")
    with urllib.request.urlopen(req, timeout=120) as resp:
        ctype = resp.headers.get("Content-Type", "")
        if "image" not in ctype.lower():
            sys.exit(f"ERROR: respons bukan gambar (Content-Type: {ctype}).")
        data = resp.read(MAX_DOWNLOAD_BYTES + 1)
    if len(data) > MAX_DOWNLOAD_BYTES:
        sys.exit("ERROR: file hasil melebihi 20 MB — batalkan unduhan.")
    ext = ".png" if "png" in ctype.lower() else ".jpg"
    # Timestamp agar tidak ada file yang tertimpa antar run
    stamp = time.strftime("%Y%m%d-%H%M%S")
    dest = dest_dir / f"seedream5-{model_tag}-{stamp}-{index:02d}{ext}"
    dest.write_bytes(data)
    return dest


def generate(args, api_key: str) -> None:
    """Panggil API BytePlus dan simpan gambar hasil."""
    model_id = resolve_model(args.model)
    info = MODELS.get(args.model)
    if args.model not in MODELS:
        for k, v in MODELS.items():
            if v["id"] == args.model:
                info = v
                break

    # Validasi resolusi agar sesuai kapabilitas tiap model
    # Default 2K (kompromi kualitas/biaya); fallback ke resolusi terbesar model.
    size = args.size or ("2K" if "2K" in info["sizes"] else info["sizes"][-1])
    if info and size not in info["sizes"]:
        sys.exit(f"ERROR: size '{size}' tidak didukung {model_id}. Pilihan: {', '.join(info['sizes'])}.")

    if not (3 <= len(args.prompt.strip()) <= 2000):
        sys.exit("ERROR: prompt harus 3-2000 karakter.")
    if not (1 <= args.count <= 15):
        sys.exit("ERROR: count harus 1-15.")

    payload = {
        "model": model_id,
        "prompt": args.prompt.strip(),
        "size": size,
        "response_format": "url",
        "watermark": args.watermark,
    }
    if args.seed is not None:
        payload["seed"] = args.seed

    body = json.dumps(payload).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    req = urllib.request.Request(API_URL, data=body, headers=headers, method="POST")

    print(f"[i] Memanggil {model_id} ({size})...")
    try:
        with urllib.request.urlopen(req, timeout=args.timeout) as resp:
            raw = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        detail = ""
        try:
            detail = e.read().decode("utf-8")[:500]
        except Exception:
            pass
        sys.exit(f"ERROR HTTP {e.code}: {e.reason}\n  Detail: {detail or '(kosong)'}\n"
                 "  Periksa key, kuota, dan aktivasi model di konsol BytePlus.")
    except urllib.error.URLError as e:
        sys.exit(f"ERROR jaringan: {e.reason}")

    try:
        result = json.loads(raw)
    except json.JSONDecodeError:
        sys.exit(f"ERROR: respons bukan JSON valid. Cuplikan: {raw[:300]}")

    if "error" in result:
        sys.exit(f"ERROR dari API: {result['error']}")

    items = result.get("data", [])
    if not items:
        sys.exit(f"ERROR: API tidak mengembalikan gambar. Respons: {raw[:300]}")

    # Tentukan folder tujuan
    out_dir = pathlib.Path(args.out) if args.out else (pathlib.Path.home() / "Pictures" / "byteplus-seedream5")
    out_dir.mkdir(parents=True, exist_ok=True)

    saved = []
    for i, item in enumerate(items, start=1):
        url = item.get("url")
        if not url:
            continue
        path = download_image(url, out_dir, i, args.model)
        saved.append((path, url))

    if not saved:
        sys.exit("ERROR: tidak ada URL gambar dalam respons.")

    print(json.dumps({
        "status": "success",
        "model": model_id,
        "count": len(saved),
        "images": [{"local_path": str(p), "size_kb": round(p.stat().st_size / 1024, 1)} for p, _ in saved],
    }, indent=2, ensure_ascii=False))


def main(argv=None):
    args = parse_args(argv if argv is not None else sys.argv[1:])

    if args.list_models:
        list_models()
        return 0

    if args.list_live:
        list_live_models(require_key())
        return 0

    if not args.prompt:
        print("ERROR: --prompt wajib diisi (atau gunakan --list-models / --list-live).\n", file=sys.stderr)
        return 2

    generate(args, require_key())
    return 0


if __name__ == "__main__":
    sys.exit(main())