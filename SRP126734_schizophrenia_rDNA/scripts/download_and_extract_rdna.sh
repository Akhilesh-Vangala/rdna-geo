#!/usr/bin/env bash
# ==============================================================================
# SRP126734 — Download SRA runs and extract rDNA-mapping sequences
#
# Usage:
#   ./download_and_extract_rdna.sh                     # process all runs in run_list.txt
#   ./download_and_extract_rdna.sh -s SRR6375927       # process a single run
#   RDNA_REF=/path/to/ref.fa ./download_and_extract_rdna.sh
#
# Requirements:
#   sra-tools (fasterq-dump), bwa, samtools
#   Install: conda install -c bioconda sra-tools bwa samtools
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STUDY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ------------------------------------------------------------------------------
# Configuration — override via environment variables if needed
# ------------------------------------------------------------------------------
RDNA_REF="${RDNA_REF:-$STUDY_ROOT/1000_genome_project_referencerDNA.fa}"
FASTQ_DIR="${FASTQ_DIR:-$STUDY_ROOT/fastq}"
BAM_DIR="${BAM_DIR:-$STUDY_ROOT/rdna_bams}"
LOG_DIR="${LOG_DIR:-$STUDY_ROOT/logs}"
RUN_LIST="${RUN_LIST:-$STUDY_ROOT/data/run_list.txt}"
THREADS="${THREADS:-4}"
KEEP_FASTQ="${KEEP_FASTQ:-false}"

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------
mkdir -p "$FASTQ_DIR" "$BAM_DIR" "$LOG_DIR"
LOGFILE="$LOG_DIR/pipeline_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }
err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOGFILE" >&2; }

log "Pipeline started"
log "RDNA_REF=$RDNA_REF | FASTQ_DIR=$FASTQ_DIR | BAM_DIR=$BAM_DIR | THREADS=$THREADS"

# ------------------------------------------------------------------------------
# Tool checks
# ------------------------------------------------------------------------------
check_tool() {
  if ! command -v "$1" &>/dev/null; then
    err "Required tool not found: $1"
    err "Install with: conda install -c bioconda sra-tools bwa samtools"
    exit 1
  fi
}
check_tool bwa
check_tool samtools
if command -v fasterq-dump &>/dev/null; then
  SRA_DUMP="fasterq-dump"
elif command -v fastq-dump &>/dev/null; then
  SRA_DUMP="fastq-dump"
else
  err "Neither fasterq-dump nor fastq-dump found. Install sra-tools."
  exit 1
fi
log "Using SRA tool: $SRA_DUMP"

# ------------------------------------------------------------------------------
# Reference check and indexing
# ------------------------------------------------------------------------------
if [[ ! -f "$RDNA_REF" ]]; then
  err "rDNA reference not found: $RDNA_REF"
  err "Set RDNA_REF=/path/to/1000_genome_project_referencerDNA.fa"
  exit 1
fi
if [[ ! -f "${RDNA_REF}.bwt" ]]; then
  log "Indexing rDNA reference with BWA (one-time setup)..."
  bwa index "$RDNA_REF" 2>>"$LOGFILE"
  log "Reference indexed."
fi

# ------------------------------------------------------------------------------
# Parse single-run mode
# ------------------------------------------------------------------------------
SINGLE_SRR=""
if [[ "${1:-}" == "-s" && -n "${2:-}" ]]; then
  SINGLE_SRR="$2"
fi

# ------------------------------------------------------------------------------
# Per-run processing function
# ------------------------------------------------------------------------------
process_run() {
  local srr="$1"
  local run_log="$LOG_DIR/${srr}.log"

  # Skip if already done
  if [[ -f "${BAM_DIR}/${srr}_rdna.bam" && -f "${BAM_DIR}/${srr}_rdna.bam.bai" ]]; then
    log "$srr — already processed, skipping."
    return 0
  fi

  log "$srr — starting..."

  # Download FASTQ
  log "$srr — downloading from SRA..."
  if [[ "$SRA_DUMP" == "fasterq-dump" ]]; then
    fasterq-dump "$srr" --split-files -O "$FASTQ_DIR" --threads "$THREADS" 2>>"$run_log" \
      || { err "$srr — fasterq-dump failed"; return 1; }
  else
    fastq-dump "$srr" --split-files --outdir "$FASTQ_DIR" 2>>"$run_log" \
      || { err "$srr — fastq-dump failed"; return 1; }
  fi

  # Determine paired vs single end
  local F1="${FASTQ_DIR}/${srr}_1.fastq"
  local F2="${FASTQ_DIR}/${srr}_2.fastq"
  local OUT_BAM="${BAM_DIR}/${srr}_rdna.bam"
  local TMP_BAM="${BAM_DIR}/${srr}_rdna.tmp.bam"

  if [[ ! -f "$F1" ]]; then
    err "$srr — FASTQ not found after download: $F1"
    return 1
  fi

  # Align to rDNA reference
  log "$srr — aligning to rDNA reference..."
  if [[ -f "$F1" && -f "$F2" ]]; then
    bwa mem -t "$THREADS" "$RDNA_REF" "$F1" "$F2" 2>>"$run_log" \
      | samtools view -bS -F 4 - \
      | samtools sort -o "$OUT_BAM" - 2>>"$run_log"
  else
    log "$srr — single-end reads detected"
    bwa mem -t "$THREADS" "$RDNA_REF" "$F1" 2>>"$run_log" \
      | samtools view -bS -F 4 - \
      | samtools sort -o "$OUT_BAM" - 2>>"$run_log"
  fi

  # Index BAM
  samtools index "$OUT_BAM" 2>>"$run_log"

  # Report mapping stats
  log "$srr — mapping stats:"
  samtools flagstat "$OUT_BAM" | tee -a "$LOGFILE" | tee -a "$run_log"

  # Cleanup FASTQ to save disk space (unless KEEP_FASTQ=true)
  if [[ "$KEEP_FASTQ" != "true" ]]; then
    rm -f "$F1" "$F2"
    log "$srr — FASTQ removed to save space (set KEEP_FASTQ=true to retain)"
  fi

  log "$srr — done → $OUT_BAM"
}

# ------------------------------------------------------------------------------
# Main — single run or batch
# ------------------------------------------------------------------------------
PASS=0
FAIL=0

if [[ -n "$SINGLE_SRR" ]]; then
  process_run "$SINGLE_SRR" && PASS=$((PASS+1)) || FAIL=$((FAIL+1))
else
  if [[ ! -f "$RUN_LIST" ]]; then
    err "Run list not found: $RUN_LIST"
    exit 1
  fi
  while IFS= read -r srr || [[ -n "$srr" ]]; do
    [[ -z "$srr" || "$srr" =~ ^# ]] && continue
    process_run "$srr" && PASS=$((PASS+1)) || FAIL=$((FAIL+1))
  done < "$RUN_LIST"
fi

log "Pipeline complete — Passed: $PASS | Failed: $FAIL"
log "rDNA BAMs in: $BAM_DIR"
log "Logs in: $LOG_DIR"

if [[ $FAIL -gt 0 ]]; then
  err "$FAIL run(s) failed. Check logs in $LOG_DIR"
  exit 1
fi
