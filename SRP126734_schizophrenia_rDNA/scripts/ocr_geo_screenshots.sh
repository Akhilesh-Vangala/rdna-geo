#!/usr/bin/env bash
# OCR all PNGs under repo-root "geo scripts*" folders into one text file (requires tesseract).
set -euo pipefail
# Repo layout: rna/geo scripts/ … and rna/geo/SRP126734_schizophrenia_rDNA/scripts/this file
RNA_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="${1:-$(cd "$(dirname "$0")/.." && pwd)/workbench_replica/SCREENSHOT_OCR_FULL.txt}"
: >"$OUT"
echo "# OCR aggregate $(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"$OUT"
shopt -s nullglob
for dir in "$RNA_ROOT"/geo\ scripts "$RNA_ROOT"/geo\ scripts\ 2 "$RNA_ROOT"/geo\ scripts\ 3 "$RNA_ROOT"/geo\ scripts\ 4; do
  [[ -d "$dir" ]] || continue
  for png in "$dir"/*.png; do
    echo "" >>"$OUT"
    echo "===== ${png#$RNA_ROOT/} =====" >>"$OUT"
    tesseract "$png" stdout 2>/dev/null >>"$OUT" || echo "[tesseract failed]" >>"$OUT"
  done
done
echo "Wrote $OUT"
