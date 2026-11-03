#!/usr/bin/env bash
# ============================================================
# verify.sh — Verifikasi silang repo vs TRAE/Claude/ZCode/Codex (macOS)
# Author: Mas Wondho — Duta Corpora Indonesia (DCI)
# Copyright © 2026 Duta Corpora Indonesia
# ============================================================
# Padanan verify-sync.ps1: jumlah folder skill + sidik jari (fingerprint)
# folder taste (design-taste-frontend, full-output-enforcement).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/skills"

# Sidik jari folder: (path relatif + md5 file) digabung lalu di-md5
fingerprint() {
    local folder="$1"
    [ -d "$folder" ] || { echo "HILANG"; return; }
    ( cd "$folder" && find . -type f ! -name '.DS_Store' | LC_ALL=C sort | \
        while read -r f; do printf '%s|%s\n' "$f" "$(md5 -q "$f")"; done ) | \
        md5 -q
}

filecount() {
    find "$1" -type f ! -name '.DS_Store' 2>/dev/null | wc -l | tr -d ' '
}

# Target: nama -> path
declare -A TARGETS=(
    [TRAE]="$HOME/.trae/skills"
    [CLAUDE]="$HOME/.claude/skills"
    [ZCODE]="$HOME/.zcode/skills"
    [CODEX]="$HOME/.agents/skills"
)

echo "=== VERIFIKASI SINKRON TASTE-SKILL (macOS) ==="
echo ""
echo "JUMLAH FOLDER SKILL:"
printf "  %-8s %s\n" "REPO" "$(find "$SRC" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
for k in TRAE CLAUDE ZCODE CODEX; do
    p="${TARGETS[$k]}"
    c=$([ -d "$p" ] && find "$p" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ' || echo "N/A")
    printf "  %-8s %s\n" "$k" "$c"
done
echo ""
echo "SIDIK JARI PER FOLDER (repo vs target):"
printf "  %-26s %-6s %-14s %s\n" "FOLDER" "FILE" "REPO" "TRAE/CLAUDE/ZCODE/CODEX"
printf "  %s\n" "$(printf '%0.s-' {1..80})"

MISMATCH=0
for n in design-taste-frontend full-output-enforcement; do
    [ -d "$SRC/$n" ] || continue
    hRef="$(fingerprint "$SRC/$n")"
    fRef="$(filecount "$SRC/$n")"
    cols=""
    for k in TRAE CLAUDE ZCODE CODEX; do
        fp="$(fingerprint "${TARGETS[$k]}/$n")"
        if [ "$fp" = "HILANG" ]; then cols+="HILANG "; MISMATCH=$((MISMATCH+1))
        elif [ "$fp" = "$hRef" ]; then cols+="OK "
        else cols+="BEDA "; MISMATCH=$((MISMATCH+1)); fi
    done
    printf "  %-26s %-6s %-14s %s\n" "$n" "$fRef" "${hRef:0:12}" "$cols"
done

echo ""
if [ "$MISMATCH" -eq 0 ]; then
    echo "HASIL: SEMUA COCOK — folder identik di repo, TRAE, Claude, ZCode, Codex."
else
    echo "HASIL: ADA $MISMATCH KETIDAKCOCOKAN. Perlu perbaikan."
fi
