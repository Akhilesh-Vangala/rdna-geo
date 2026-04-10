#!/usr/bin/env bash
# ==============================================================================
# SRP126734 — Download SRA runs and extract rDNA-mapping sequences
#
# Usage:
#   ./download_and_extract_rdna.sh                     # process all runs in run_list.txt
#   ./download_and_extract_rdna.sh -s SRR6375927       # process a single run
#   RDNA_REF=/path/to/ref.fa ./download_and_extract_rdna.sh
#   FASTQ_MAX_SPOTS=20000 RDNA_REF=... ./download_and_extract_rdna.sh -s SRR6375927   # pilot (uses fastq-dump -X; fasterq-dump has no maxSpotId)
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
# Optional: limit spots for fasterq-dump (pilot / testing only; not full WGS)
FASTQ_MAX_SPOTS="${FASTQ_MAX_SPOTS:-}"
# If fasterq-dump fails with "Failed to call external services", try:
#   USE_PREFETCH=true   (prefetch .sra to disk, then fasterq-dump the local file)
SRA_CACHE_DIR="${SRA_CACHE_DIR:-$STUDY_ROOT/sra_cache}"
USE_PREFETCH="${USE_PREFETCH:-false}"
# Force Homebrew sra-tools if conda shadows a broken binary:
#   FASTERQ_DUMP=/opt/homebrew/bin/fasterq-dump PREFETCH=/opt/homebrew/bin/prefetch ./scripts/...
FASTERQ_DUMP="${FASTERQ_DUMP:-}"
PREFETCH="${PREFETCH:-}"
# Pilot mode (FASTQ_MAX_SPOTS): fasterq-dump has NO --maxSpotId; we use fastq-dump -X instead.
FASTQ_DUMP="${FASTQ_DUMP:-}"

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
if [[ -n "$FASTERQ_DUMP" && -x "$FASTERQ_DUMP" ]]; then
  SRA_DUMP="$FASTERQ_DUMP"
elif command -v fasterq-dump &>/dev/null; then
  SRA_DUMP="fasterq-dump"
elif command -v fastq-dump &>/dev/null; then
  SRA_DUMP="fastq-dump"
else
  err "Neither fasterq-dump nor fastq-dump found. Install sra-tools."
  exit 1
fi
log "Using SRA tool: $SRA_DUMP"
PREFETCH_EXE="${PREFETCH:-}"
if [[ -z "$PREFETCH_EXE" ]]; then
  PREFETCH_EXE="$(command -v prefetch 2>/dev/null || true)"
fi
FASTQ_DUMP_EXE="${FASTQ_DUMP:-}"
if [[ -z "$FASTQ_DUMP_EXE" ]]; then
  FASTQ_DUMP_EXE="$(command -v fastq-dump 2>/dev/null || true)"
fi

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
  local sra_local=""
  if [[ "$USE_PREFETCH" == "true" ]]; then
    if [[ -z "$PREFETCH_EXE" ]]; then
      err "USE_PREFETCH=true but prefetch not found"
      return 1
    fi
    mkdir -p "$SRA_CACHE_DIR"
    sra_local="$(find "$SRA_CACHE_DIR" -name "${srr}.sra" -type f 2>/dev/null | head -1)"
    if [[ -z "$sra_local" ]]; then
      log "$srr — prefetch → $SRA_CACHE_DIR (large; may take a long time)..."
      "$PREFETCH_EXE" -O "$SRA_CACHE_DIR" "$srr" >>"$run_log" 2>&1 || { err "$srr — prefetch failed"; return 1; }
      sra_local="$(find "$SRA_CACHE_DIR" -name "${srr}.sra" -type f 2>/dev/null | head -1)"
    fi
    if [[ -z "$sra_local" || ! -f "$sra_local" ]]; then
      err "$srr — prefetch did not produce ${srr}.sra under $SRA_CACHE_DIR"
      return 1
    fi
    log "$srr — using local SRA: $sra_local"
  fi

  local dump_src="$srr"
  [[ -n "$sra_local" ]] && dump_src="$sra_local"

  # FASTQ_MAX_SPOTS: only fastq-dump supports -X / --maxSpotId (not fasterq-dump 3.3+)
  if [[ -n "$FASTQ_MAX_SPOTS" ]]; then
    if [[ -z "$FASTQ_DUMP_EXE" ]]; then
      err "FASTQ_MAX_SPOTS set but fastq-dump not found. Install sra-tools or unset FASTQ_MAX_SPOTS."
      return 1
    fi
    log "$srr — fastq-dump pilot: -X $FASTQ_MAX_SPOTS (fasterq-dump has no maxSpotId flag)"
    "$FASTQ_DUMP_EXE" "$dump_src" --split-files --outdir "$FASTQ_DIR" -X "$FASTQ_MAX_SPOTS" >>"$run_log" 2>&1 \
      || { err "$srr — fastq-dump failed"; return 1; }
  elif [[ "$SRA_DUMP" == *fasterq-dump* ]] || [[ "$(basename "$SRA_DUMP")" == "fasterq-dump" ]]; then
    "$SRA_DUMP" "$dump_src" --split-files -O "$FASTQ_DIR" --threads "$THREADS" >>"$run_log" 2>&1 \
      || { err "$srr — fasterq-dump failed (try USE_PREFETCH=true if 'external services')"; return 1; }
  else
    "$SRA_DUMP" "$dump_src" --split-files --outdir "$FASTQ_DIR" >>"$run_log" 2>&1 \
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
