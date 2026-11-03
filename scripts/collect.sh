#!/usr/bin/env bash
# ============================================================
# collect.sh — Kumpulkan skill lokal ke repo + push ke GitHub (macOS)
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
# ============================================================
# Padanan collect.ps1. Jalankan dari root repo hasil clone:
#   ./scripts/collect.sh                        # commit + push otomatis
#   ./scripts/collect.sh -m "pesan"             # pesan commit custom
#   ./scripts/collect.sh --no-push              # commit saja tanpa push

set -euo pipefail
C='\033[36m'; G='\033[32m'; Y='\033[33m'; R='\033[31m'; N='\033[0m'

MESSAGE=""
NO_PUSH=0
while [ $# -gt 0 ]; do
    case "$1" in
        -m|--message) MESSAGE="$2"; shift 2 ;;
        --no-push)    NO_PUSH=1; shift ;;
        *) echo -e "${R}[X] Argumen tidak dikenal: $1${N}"; exit 1 ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_SKILLS="$REPO_ROOT/skills"
REPO_MEMORY="$REPO_ROOT/memory"
SKILLS_DIR="$HOME/.trae/skills"
MEMORY_DIR="$HOME/.trae/memory"

echo -e "${C}================================================${N}"
echo -e "${C} SLACKER TRAE SKILL — Pengumpul macOS (lokal -> repo -> GitHub)${N}"
echo -e "${C}================================================${N}"
echo ""

# --- Validasi -----------------------------------------------------------------
[ -d "$SKILLS_DIR" ] || { echo -e "${R}[X] Folder skill lokal tidak ditemukan: $SKILLS_DIR${N}"; exit 1; }
[ -d "$REPO_ROOT/.git" ] || { echo -e "${R}[X] Ini bukan repo git. Clone dulu dari GitHub.${N}"; exit 1; }

# --- 1. Copy skills lokal -> repo (backup lokal TIDAK ikut) ---------------------
echo -e "${C}[1/3] Sinkron skill lokal -> repo...${N}"
rsync -a --delete \
    --exclude='__pycache__' --exclude='.venv' --exclude='node_modules' --exclude='*.pyc' \
    --exclude='skills-backup-*' \
    "$SKILLS_DIR"/ "$REPO_SKILLS"/
echo -e "${G}    OK${N}"

# --- 2. Copy memory lokal -> repo -------------------------------------------------
if [ -d "$MEMORY_DIR" ]; then
    echo -e "${C}[2/3] Sinkron memory -> repo...${N}"
    find "$MEMORY_DIR" -maxdepth 1 -type f -exec cp {} "$REPO_MEMORY" \;
    echo -e "${G}    OK${N}"
else
    echo -e "${Y}[2/3] Memory lokal tidak ada — lewati.${N}"
fi

# --- 2.5 Sinkron jumlah skill ke dokumen ber-marker <N><!--skill-count:N--> ------
echo -e "${C}[2.5/3] Sinkron jumlah skill -> dokumen...${N}"
SKILL_TOTAL=$(find "$REPO_SKILLS" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
DOCS="$REPO_ROOT/README.md $REPO_ROOT/AGENTS.md $REPO_ROOT/.knowledge.md \
$REPO_ROOT/claude/CLAUDE.md $REPO_ROOT/codex/AGENTS.md $REPO_ROOT/codex/BEST-PRACTICE.md \
$REPO_ROOT/zcode/AGENTS.md $REPO_ROOT/zcode/BEST-PRACTICE.md $REPO_ROOT/memory/user_profile.md"
SYNCED=0
for doc in $DOCS; do
    [ -f "$doc" ] || continue
    if sed -i '' -E "s/[0-9]+<!--skill-count:[0-9]+-->/${SKILL_TOTAL}<!--skill-count:${SKILL_TOTAL}-->/g" "$doc"; then
        SYNCED=$((SYNCED+1))
    fi
done
echo -e "${G}    OK — $SYNCED dokumen dicek, jumlah skill: $SKILL_TOTAL${N}"

# Catatan: regenerasi INVENTORY.md (update-inventory.ps1) hanya ada di Windows —
# jalankan collect.ps1 di mesin Windows untuk sinkron inventaris penuh.

# --- 3. Git commit -----------------------------------------------------------------
echo -e "${C}[3/3] Git commit...${N}"
git -C "$REPO_ROOT" add -A

if [ -z "$(git -C "$REPO_ROOT" status --porcelain)" ]; then
    echo -e "${Y}    Tidak ada perubahan — sudah sinkron.${N}"
    exit 0
fi

if [ -z "$MESSAGE" ]; then
    CHANGED=$(git -C "$REPO_ROOT" status --porcelain | wc -l | tr -d ' ')
    HOST=$(scutil --get ComputerName 2>/dev/null || hostname)
    MESSAGE="sync: $CHANGED perubahan skill/memory dari $HOST ($(date '+%Y-%m-%d %H:%M'))"
fi
git -C "$REPO_ROOT" commit -m "$MESSAGE"
echo -e "${G}    Commit: $MESSAGE${N}"

# --- Push -----------------------------------------------------------------------------
if [ "$NO_PUSH" -eq 0 ]; then
    echo -e "${C}    Push ke GitHub...${N}"
    if git -C "$REPO_ROOT" push; then
        echo -e "${G}    Push OK.${N}"
    else
        echo -e "${Y}    [!] Push gagal — cek koneksi/remote. Jalankan manual: git push${N}"
    fi
else
    echo -e "${Y}    (--no-push — push dilewati, jalankan git push manual nanti)${N}"
fi

echo ""
echo -e "${G}Selesai! Di komputer lain: git pull lalu ./scripts/install.sh${N}"
