#!/usr/bin/env bash
# ==============================================================================
# SRP126734 — Master Pipeline Runner
#
# Runs the full pipeline end-to-end:
#   Step 1: Download SRA data + extract rDNA-mapping reads → BAMs
#   Step 2: Variant calling on rDNA BAMs → VCFs (default: bcftools; VARIANT_CALLER=gatk optional)
#
# Usage:
#   ./run_pipeline.sh                   # full run (all 54 samples)
#   ./run_pipeline.sh -s SRR6375927     # test on one sample
#   SKIP_STEP1=true ./run_pipeline.sh   # skip download, run variant calling only
#   SKIP_STEP2=true ./run_pipeline.sh   # run download only
#
# Requirements:
#   sra-tools, bwa, samtools, bcftools (step 2)
#   conda install -c bioconda sra-tools bwa samtools bcftools
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STUDY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="${LOG_DIR:-$STUDY_ROOT/logs}"
mkdir -p "$LOG_DIR"
LOGFILE="$LOG_DIR/master_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }
err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOGFILE" >&2; }

SKIP_STEP1="${SKIP_STEP1:-false}"
SKIP_STEP2="${SKIP_STEP2:-false}"
SINGLE_SRR="${2:-}"
MODE_FLAG="${1:-}"

log "============================================================"
log " SRP126734 rDNA Pipeline"
log " Date: $(date)"
log "============================================================"

# ------------------------------------------------------------------------------
# Step 1: Download + rDNA extraction
# ------------------------------------------------------------------------------
if [[ "$SKIP_STEP1" != "true" ]]; then
  log "--- STEP 1: Download and extract rDNA-mapping reads ---"
  if [[ "$MODE_FLAG" == "-s" && -n "$SINGLE_SRR" ]]; then
    bash "$SCRIPT_DIR/download_and_extract_rdna.sh" -s "$SINGLE_SRR" 2>&1 | tee -a "$LOGFILE"
  else
    bash "$SCRIPT_DIR/download_and_extract_rdna.sh" 2>&1 | tee -a "$LOGFILE"
  fi
  log "--- STEP 1 complete ---"
else
  log "--- STEP 1 skipped (SKIP_STEP1=true) ---"
fi

# ------------------------------------------------------------------------------
# Step 2: Variant calling
# ------------------------------------------------------------------------------
if [[ "$SKIP_STEP2" != "true" ]]; then
  log "--- STEP 2: Variant calling ---"
  if [[ "$MODE_FLAG" == "-s" && -n "$SINGLE_SRR" ]]; then
    bash "$SCRIPT_DIR/variant_calling.sh" -s "$SINGLE_SRR" 2>&1 | tee -a "$LOGFILE"
  else
    bash "$SCRIPT_DIR/variant_calling.sh" 2>&1 | tee -a "$LOGFILE"
  fi
  log "--- STEP 2 complete ---"
else
  log "--- STEP 2 skipped (SKIP_STEP2=true) ---"
fi

log "============================================================"
log " Pipeline finished. Check logs in: $LOG_DIR"
log "============================================================"
