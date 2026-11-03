#!/usr/bin/env bash
# ============================================================
# sync.sh — Sinkron repo trae-skills ke agent CLI di macOS
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
# ============================================================
# Satu pintu padanan sync-claude.ps1 / sync-zcode.ps1 / sync-codex.ps1:
#   ./scripts/sync.sh claude          # repo -> ~/.claude  (skills + CLAUDE.md + commands + settings merge)
#   ./scripts/sync.sh zcode           # repo -> ~/.zcode   (skills + AGENTS.md + commands; MCP TIDAK disentuh)
#   ./scripts/sync.sh codex           # repo -> ~/.agents/skills + ~/.codex/skills + AGENTS.md
#   ./scripts/sync.sh all             # ketiganya sekaligus
# Tambah --mirror untuk hapus skill target yang tidak ada di repo (aman: .system Codex tetap).
# Aman dijalankan berulang (idempoten). Tutup aplikasi terkait saat sync.

set -euo pipefail

# --- Warna ---
C='\033[36m'; G='\033[32m'; Y='\033[33m'; R='\033[31m'; N='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_SKILLS="$REPO_ROOT/skills"
MIRROR=0
TARGETS=()

for arg in "$@"; do
    case "$arg" in
        --mirror) MIRROR=1 ;;
        claude|zcode|codex|all) TARGETS+=("$arg") ;;
        *) echo -e "${R}[X] Argumen tidak dikenal: $arg${N}"; echo "Pakai: ./scripts/sync.sh claude|zcode|codex|all [--mirror]"; exit 1 ;;
    esac
done
if [ ${#TARGETS[@]} -eq 0 ]; then
    echo "Pakai: ./scripts/sync.sh claude|zcode|codex|all [--mirror]"
    exit 1
fi
if [[ " ${TARGETS[*]} " == *" all "* ]]; then TARGETS=(claude zcode codex); fi

[ -d "$SRC_SKILLS" ] || { echo -e "${R}[X] Folder sumber tidak ditemukan: $SRC_SKILLS${N}"; exit 1; }

# --- Fungsi salin skill per-folder (padanan Copy-Skills di PowerShell) ---
copy_skills() {
    local src="$1" dst="$2"
    mkdir -p "$dst"
    local ok=0 fail=""
    for d in "$src"/*/; do
        local name; name="$(basename "$d")"
        rm -rf "$dst/$name"
        cp -R "$d" "$dst/$name"
        if [ -f "$dst/$name/SKILL.md" ]; then ok=$((ok+1)); else fail="$fail $name"; fi
    done
    # Bersihkan artefak yang tidak perlu
    find "$dst" -type d \( -name '__pycache__' -o -name '.venv' -o -name 'node_modules' -o -name '.git' \) -exec rm -rf {} + 2>/dev/null || true
    [ -n "$fail" ] && echo -e "${Y}[!] Skill tanpa SKILL.md setelah salin di $dst:$fail${N}"
    echo "$ok"
}

# --- Mirror: hapus skill target yang tidak ada di repo ---
mirror_prune() {
    local dst="$1" protect="${2:-}"
    for d in "$dst"/*/; do
        local name; name="$(basename "$d")"
        [ -d "$SRC_SKILLS/$name" ] && continue
        [ "$name" = "$protect" ] && continue   # mis. .system Codex
        rm -rf "$d"
        echo "Mirror: dihapus $name"
    done
}

for T in "${TARGETS[@]}"; do
    echo ""
    echo -e "${C}=== SINKRON ${T^^} ===${N}"

    if [ "$T" = "claude" ]; then
        DST="$HOME/.claude"
        SRC_CLAUDE="$REPO_ROOT/claude"
        [ -d "$SRC_CLAUDE" ] || { echo -e "${R}[X] $SRC_CLAUDE tidak ada${N}"; exit 1; }
        mkdir -p "$DST"
        OK=$(copy_skills "$SRC_SKILLS" "$DST/skills"); OK=${OK##*$'\n'} # ambil baris angka terakhir
        COUNT=$(find "$DST/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
        [ "$MIRROR" -eq 1 ] && mirror_prune "$DST/skills"
        # CLAUDE.md global
        cp "$SRC_CLAUDE/CLAUDE.md" "$DST/CLAUDE.md"
        # Commands
        mkdir -p "$DST/commands"
        cp "$SRC_CLAUDE"/commands/*.md "$DST/commands/" 2>/dev/null || true
        # settings: merge ringan — pertahankan token & plugin lokal (padanan logika .ps1)
        TPL="$SRC_CLAUDE/settings.template.json"; SET="$DST/settings.json"
        if [ -f "$TPL" ]; then
            if [ -f "$SET" ] && command -v python3 >/dev/null 2>&1; then
                cp "$SET" "$SET.bak"
                python3 - "$TPL" "$SET" <<'PYEOF'
import json, sys
tpl = json.load(open(sys.argv[1]))
try:
    cur = json.load(open(sys.argv[2]))
except Exception:
    cur = {}
env = dict(tpl.get('env', {}))
old = cur.get('env', {}).get('ANTHROPIC_AUTH_TOKEN')
if old and not env.get('ANTHROPIC_AUTH_TOKEN'):
    env['ANTHROPIC_AUTH_TOKEN'] = old
tpl['env'] = env
for k in ('enabledPlugins', 'mcpServers'):
    if k in cur:
        tpl[k] = cur[k]
json.dump(tpl, open(sys.argv[2], 'w'), indent=2, ensure_ascii=False)
PYEOF
            else
                cp "$TPL" "$SET"
            fi
        fi
        echo -e "${G}Skills   : $COUNT folder -> $DST/skills${N}"
        echo -e "${G}CLAUDE.md + commands + settings (merge, backup .bak) diperbarui${N}"

    elif [ "$T" = "zcode" ]; then
        DST="$HOME/.zcode"
        SRC_ZCODE="$REPO_ROOT/zcode"
        [ -d "$SRC_ZCODE" ] || { echo -e "${R}[X] $SRC_ZCODE tidak ada${N}"; exit 1; }
        mkdir -p "$DST"
        copy_skills "$SRC_SKILLS" "$DST/skills" >/dev/null
        COUNT=$(find "$DST/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
        [ "$MIRROR" -eq 1 ] && mirror_prune "$DST/skills"
        cp "$SRC_ZCODE/AGENTS.md" "$DST/AGENTS.md"
        cp "$SRC_ZCODE/BEST-PRACTICE.md" "$DST/BEST-PRACTICE.md"
        mkdir -p "$DST/commands"
        cp "$SRC_ZCODE"/commands/*.md "$DST/commands/" 2>/dev/null || true
        echo -e "${G}Skills   : $COUNT folder -> $DST/skills${N}"
        echo -e "${G}AGENTS.md + BEST-PRACTICE.md + commands diperbarui${N}"
        echo -e "${G}MCP      : tidak disentuh (dikelola langsung di Z Code)${N}"

    elif [ "$T" = "codex" ]; then
        SRC_CODEX="$REPO_ROOT/codex"
        AGENTS_SK="$HOME/.agents/skills"
        CODEX_HOME="$HOME/.codex"
        [ -d "$SRC_CODEX" ] || { echo -e "${R}[X] $SRC_CODEX tidak ada${N}"; exit 1; }
        [ -d "$CODEX_HOME" ] || { echo -e "${R}[X] $CODEX_HOME tidak ada — jalankan Codex dulu sekali${N}"; exit 1; }
        # Path resmi user-scope
        copy_skills "$SRC_SKILLS" "$AGENTS_SK" >/dev/null
        COUNT_A=$(find "$AGENTS_SK" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
        [ "$MIRROR" -eq 1 ] && mirror_prune "$AGENTS_SK"
        # Path legacy + .system dipertahankan
        copy_skills "$SRC_SKILLS" "$CODEX_HOME/skills" >/dev/null
        COUNT_L=$(find "$CODEX_HOME/skills" -mindepth 1 -maxdepth 1 -type d ! -name '.system' | wc -l | tr -d ' ')
        [ "$MIRROR" -eq 1 ] && mirror_prune "$CODEX_HOME/skills" '.system'
        # AGENTS.md global (backup otomatis) + BEST-PRACTICE.md
        if [ -f "$CODEX_HOME/AGENTS.md" ]; then
            STAMP=$(date +%Y%m%d-%H%M%S)
            cp "$CODEX_HOME/AGENTS.md" "$CODEX_HOME/AGENTS.md.bak-$STAMP"
            echo "Backup: AGENTS.md.bak-$STAMP"
        fi
        cp "$SRC_CODEX/AGENTS.md" "$CODEX_HOME/AGENTS.md"
        cp "$SRC_CODEX/BEST-PRACTICE.md" "$CODEX_HOME/BEST-PRACTICE.md"
        echo -e "${G}Skills resmi : $COUNT_A folder -> $AGENTS_SK${N}"
        echo -e "${G}Skills legacy: $COUNT_L folder (+ .system aman) -> $CODEX_HOME/skills${N}"
        echo -e "${G}AGENTS.md + BEST-PRACTICE.md diperbarui${N}"
    fi
done

echo ""
echo -e "${G}=== SINKRON SELESAI ===${N}"
echo "Verifikasi: ./scripts/verify.sh"
