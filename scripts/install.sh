#!/usr/bin/env bash
# ============================================================
# install.sh — Pasang skills TRAE dari repo ini ke MacBook (macOS)
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
# ============================================================
# Padanan install.ps1 untuk macOS. Cara pakai:
#   1. Clone repo (atau download ZIP lalu extract)
#   2. Buka Terminal di folder repo
#   3. Jalankan:  ./scripts/install.sh
#
# Opsi:
#   ./scripts/install.sh --mirror      # hapus skill lokal yang tidak ada di repo (identik penuh)
#   ./scripts/install.sh --skip-memory # jangan sentuh folder memory
#
# Aman: folder ~/.trae/skills yang sudah ada di-backup dulu otomatis.

set -euo pipefail

MIRROR=0
SKIP_MEMORY=0
for arg in "$@"; do
    case "$arg" in
        --mirror)      MIRROR=1 ;;
        --skip-memory) SKIP_MEMORY=1 ;;
        *) echo "[X] Opsi tidak dikenal: $arg"; exit 1 ;;
    esac
done

# --- Konfigurasi path --------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_SKILLS="$REPO_ROOT/skills"
REPO_MEMORY="$REPO_ROOT/memory"
TRAE_DIR="$HOME/.trae"
SKILLS_DIR="$TRAE_DIR/skills"
MEMORY_DIR="$TRAE_DIR/memory"
STAMP="$(date +%Y%m%d-%H%M%S)"

# --- Warna -------------------------------------------------------------------
C='\033[36m'; G='\033[32m'; Y='\033[33m'; R='\033[31m'; D='\033[90m'; N='\033[0m'

echo -e "${C}================================================${N}"
echo -e "${C} SLACKER TRAE SKILL — Pemasang macOS (Slackercode Family)${N}"
echo -e "${C}================================================${N}"
echo ""

# --- Validasi repo -----------------------------------------------------------
if [ ! -d "$REPO_SKILLS/blog" ]; then
    echo -e "${R}[X] Folder 'skills' repo tidak ditemukan di: $REPO_SKILLS${N}"
    echo -e "${Y}    Pastikan script dijalankan dari clone repo yang utuh.${N}"
    exit 1
fi

# --- Buat folder tujuan -------------------------------------------------------
mkdir -p "$SKILLS_DIR"
[ "$SKIP_MEMORY" -eq 0 ] && mkdir -p "$MEMORY_DIR"

# --- Backup skill lama (kalau ada) --------------------------------------------
existing_count=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$existing_count" -gt 0 ]; then
    BACKUP="$TRAE_DIR/skills-backup-$STAMP"
    echo -e "${Y}[i] Ada $existing_count folder skill lokal — backup ke:${N}"
    echo -e "${Y}    $BACKUP${N}"
    cp -R "$SKILLS_DIR" "$BACKUP"
fi

# --- Copy skills ---------------------------------------------------------------
echo ""
EXCLUDES=(--exclude='__pycache__' --exclude='.venv' --exclude='node_modules' --exclude='*.pyc')
if [ "$MIRROR" -eq 1 ]; then
    echo -e "${C}[1/2] Copy skills (MIRROR — identik dengan repo)...${N}"
    rsync -a --delete "${EXCLUDES[@]}" "$REPO_SKILLS"/ "$SKILLS_DIR"/
else
    echo -e "${C}[1/2] Copy skills (merge — skill lokal tidak dihapus)...${N}"
    rsync -a "${EXCLUDES[@]}" "$REPO_SKILLS"/ "$SKILLS_DIR"/
fi

installed=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
echo -e "${G}    OK — total $installed folder skill di ~/.trae/skills${N}"

# --- Copy memory (opsional) -----------------------------------------------------
if [ "$SKIP_MEMORY" -eq 0 ] && [ -d "$REPO_MEMORY" ]; then
    echo -e "${C}[2/2] Copy memory (profil preferensi)...${N}"
    # Memory lokal yang sudah ada tetap dipertahankan; file repo menimpa versi lama
    find "$REPO_MEMORY" -maxdepth 1 -type f -exec cp {} "$MEMORY_DIR" \; -print | sed 's|.*/|    OK — |'
else
    echo -e "${D}[2/2] Memory dilewati (--skip-memory / tidak ada).${N}"
fi

# --- Selesai ---------------------------------------------------------------------
echo ""
echo -e "${G}================================================${N}"
echo -e "${G} SELESAI!${N}"
echo -e "${G}================================================${N}"
echo ""
echo -e "${Y}Langkah terakhir (WAJIB agar skills aktif):${N}"
echo "  1. Restart TRAE IDE (tutup total, buka lagi)"
echo "  2. Skills otomatis terbaca dari ~/.trae/skills"
if [ "$SKIP_MEMORY" -eq 0 ]; then
    echo ""
    echo -e "${D}Catatan memory: profil preferensi tersalin. Sesuaikan bila perlu${N}"
    echo -e "${D}               (API key seperti ARK_API_KEY TIDAK ikut — set manual per komputer).${N}"
fi
echo ""
echo -e "${D}Skill Python (blog) butuh python3 >= 3.11 — cek README bagian macOS.${N}"
