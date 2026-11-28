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
    echo -e "${C}[2/3] Copy memory (profil preferensi)...${N}"
    # Memory lokal yang sudah ada tetap dipertahankan; file repo menimpa versi lama
    find "$REPO_MEMORY" -maxdepth 1 -type f -exec cp {} "$MEMORY_DIR" \; -print | sed 's|.*/|    OK — |'
else
    echo -e "${D}[2/3] Memory dilewati (--skip-memory / tidak ada).${N}"
fi

# --- Copy rules User Rules TRAE (step 3/3) --------------------------------------
# Rules TRAE per komputer - installer yang menyinkronkan. Rules utama memakai
# konten INTI saja (di bawah garis '---' pada trae-rules.md). macOS (BSD sed/grep)
# tidak punya masalah BOM bawaan bila menulis via printf > file.
RULES_DIR="$TRAE_DIR/user_rules"
echo -e "${C}[3/3] Copy rules (User Rules TRAE)...${N}"
if [ -d "$REPO_ROOT/rules" ]; then
    mkdir -p "$RULES_DIR"

    # 1. Rules utama: konten inti di bawah baris '---'
    TRAE_RULES_PATH="$REPO_ROOT/trae-rules.md"
    if [ -f "$TRAE_RULES_PATH" ]; then
        KONTEN_INTI="$(awk 'f && NR>1 {print} /^---$/{f=1}' "$TRAE_RULES_PATH")"
        # Cari file rules utama lama (berisi 'RULES SLACKERCODER', file terbesar)
        TARGET_UTAMA=""
        UKURAN_TERBESAR=0
        for f in "$RULES_DIR"/rule-*.md; do
            [ -f "$f" ] || continue
            if grep -q 'RULES SLACKERCODER' "$f" 2>/dev/null; then
                SZ=$(wc -c < "$f" | tr -d ' ')
                if [ "$SZ" -gt "$UKURAN_TERBESAR" ]; then UKURAN_TERBESAR="$SZ"; TARGET_UTAMA="$f"; fi
            fi
        done
        if [ -z "$TARGET_UTAMA" ]; then TARGET_UTAMA="$RULES_DIR/rule-$(date +%s)000.md"; fi
        printf '%s\n' "$KONTEN_INTI" > "$TARGET_UTAMA"
        echo -e "${G}    OK — rules utama (Slackercoder) -> $(basename "$TARGET_UTAMA")${N}"
    else
        echo -e "${Y}    [!] trae-rules.md tidak ada di repo — rules utama dilewati${N}"
    fi

    # 2-3. Memory protocol & critical thinking: salin apa adanya (carikan file lama by konten)
    for pasangan in "memory-protocol.md:Memory Protocol" "critical-thinking.md:Anti-Sycophancy"; do
        NAMA="${pasangan%%:*}"; PENGENAL="${pasangan##*:}"
        SRC="$REPO_ROOT/rules/$NAMA"
        if [ ! -f "$SRC" ]; then echo -e "${Y}    [!] $NAMA tidak ada di repo — dilewati${N}"; continue; fi
        TARGET=""
        for f in "$RULES_DIR"/rule-*.md; do
            [ -f "$f" ] || continue
            [ "$f" = "$TARGET_UTAMA" ] && continue
            if grep -q "$PENGENAL" "$f" 2>/dev/null; then TARGET="$f"; break; fi
        done
        if [ -z "$TARGET" ]; then TARGET="$RULES_DIR/rule-$(date +%s)001.md"; fi
        if [ -f "$TARGET" ] && diff -q <(sort "$SRC") <(sort "$TARGET") >/dev/null 2>&1; then
            echo -e "${D}    OK — $NAMA sudah cocok${N}"
        else
            cp "$SRC" "$TARGET"
            echo -e "${G}    OK — $NAMA -> $(basename "$TARGET")${N}"
        fi
    done
else
    echo -e "${D}[3/3] Folder rules repo tidak ada — dilewati.${N}"
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
    echo -e "${D}               (API key seperti NINEROUTER_KEY TIDAK ikut — set manual per komputer).${N}"
fi
echo ""
echo -e "${D}Skill Python (blog) butuh python3 >= 3.11 — cek README bagian macOS.${N}"
