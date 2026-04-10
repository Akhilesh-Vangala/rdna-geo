#!/usr/bin/env bash
# ==============================================================================
# SRP126734 — Variant calling on rDNA BAMs
#
# Produces per-sample VCFs from *_rdna.bam files (output of download_and_extract_rdna.sh).
#
# Usage:
#   ./variant_calling.sh
#   ./variant_calling.sh -s SRR6375927
#   VARIANT_CALLER=gatk ./variant_calling.sh -s SRR6375927   # if GATK installed
#
# Environment:
#   RDNA_REF     — rDNA FASTA (must match alignment reference)
#   BAM_DIR, VCF_DIR, LOG_DIR, THREADS — same layout as download script
#   VARIANT_CALLER — bcftools (default) | gatk
#   SKIP_EXISTING — if true (default), skip when <SRR>_rdna.vcf.gz already exists
#
# Requirements:
#   bcftools + samtools (default path)
#   gatk + java (optional; set VARIANT_CALLER=gatk)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STUDY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RDNA_REF="${RDNA_REF:-$STUDY_ROOT/1000_genome_project_referencerDNA.fa}"
BAM_DIR="${BAM_DIR:-$STUDY_ROOT/rdna_bams}"
VCF_DIR="${VCF_DIR:-$STUDY_ROOT/vcfs}"
LOG_DIR="${LOG_DIR:-$STUDY_ROOT/logs}"
THREADS="${THREADS:-4}"
VARIANT_CALLER="${VARIANT_CALLER:-bcftools}"
SKIP_EXISTING="${SKIP_EXISTING:-true}"

SINGLE_SRR=""
if [[ "${1:-}" == "-s" && -n "${2:-}" ]]; then
  SINGLE_SRR="$2"
fi

mkdir -p "$VCF_DIR" "$LOG_DIR"
LOGFILE="$LOG_DIR/variant_calling_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }
err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOGFILE" >&2; }

log "variant_calling.sh — VARIANT_CALLER=$VARIANT_CALLER"
log "RDNA_REF=$RDNA_REF | BAM_DIR=$BAM_DIR | VCF_DIR=$VCF_DIR"

if [[ ! -f "$RDNA_REF" ]]; then
  err "rDNA reference not found: $RDNA_REF"
  exit 1
fi

if [[ ! -f "${RDNA_REF}.fai" ]]; then
  log "Indexing reference with samtools faidx (one-time)..."
  samtools faidx "$RDNA_REF" 2>>"$LOGFILE"
fi

check_bcftools() {
  if ! command -v bcftools &>/dev/null; then
    err "bcftools not found. Install: conda install -c bioconda bcftools"
    exit 1
  fi
}

check_gatk() {
  if ! command -v gatk &>/dev/null; then
    err "gatk not found. Install GATK or use VARIANT_CALLER=bcftools (default)."
    exit 1
  fi
}

call_one_bcftools() {
  local srr="$1"
  local in_bam="${BAM_DIR}/${srr}_rdna.bam"
  local out_vcf="${VCF_DIR}/${srr}_rdna.vcf.gz"

  if [[ ! -f "$in_bam" ]]; then
    err "$srr — BAM not found: $in_bam"
    return 1
  fi
  if [[ "$SKIP_EXISTING" == "true" && -f "$out_vcf" ]]; then
    log "$srr — VCF exists, skipping: $out_vcf"
    return 0
  fi

  log "$srr — bcftools mpileup | call → $out_vcf"
  # -q: min base quality, -Q: min mapping quality; adjust if needed for noisy rDNA
  bcftools mpileup -f "$RDNA_REF" -q 20 -Q 20 --threads "$THREADS" "$in_bam" 2>>"$LOGFILE" \
    | bcftools call -mv -Oz -o "$out_vcf" --threads "$THREADS" 2>>"$LOGFILE"
  bcftools index --threads "$THREADS" "$out_vcf"
  log "$srr — done (bcftools)"
}

call_one_gatk() {
  local srr="$1"
  local in_bam="${BAM_DIR}/${srr}_rdna.bam"
  local rg_bam="${BAM_DIR}/${srr}_rdna_rg.bam"
  local out_vcf="${VCF_DIR}/${srr}_rdna.vcf.gz"
  local dict
  if [[ "$RDNA_REF" == *.fasta ]]; then
    dict="${RDNA_REF%.fasta}.dict"
  else
    dict="${RDNA_REF%.fa}.dict"
  fi

  if [[ ! -f "$in_bam" ]]; then
    err "$srr — BAM not found: $in_bam"
    return 1
  fi
  if [[ "$SKIP_EXISTING" == "true" && -f "$out_vcf" ]]; then
    log "$srr — VCF exists, skipping: $out_vcf"
    return 0
  fi

  if [[ ! -f "$dict" ]]; then
    log "Creating sequence dictionary for GATK..."
    gatk CreateSequenceDictionary -R "$RDNA_REF" -O "$dict" 2>>"$LOGFILE"
  fi

  log "$srr — adding read groups → $rg_bam"
  samtools addreplacerg -r "@RG\tID:${srr}\tSM:${srr}\tPL:ILLUMINA" -o "$rg_bam" "$in_bam" 2>>"$LOGFILE"
  samtools index "$rg_bam"

  log "$srr — GATK HaplotypeCaller → $out_vcf"
  gatk --java-options "-Xmx4g" HaplotypeCaller \
    -R "$RDNA_REF" \
    -I "$rg_bam" \
    -O "$out_vcf" \
    --native-pair-hmm-threads "$THREADS" \
    2>>"$LOGFILE"

  if [[ -f "$out_vcf" && ! -f "${out_vcf}.tbi" ]]; then
    if command -v bcftools &>/dev/null; then
      bcftools index --threads "$THREADS" "$out_vcf" 2>>"$LOGFILE"
    elif command -v tabix &>/dev/null; then
      tabix -p vcf "$out_vcf" 2>>"$LOGFILE"
    fi
  fi
  log "$srr — done (GATK)"
}

PASS=0
FAIL=0

if [[ "$VARIANT_CALLER" == "gatk" ]]; then
  check_gatk
elif [[ "$VARIANT_CALLER" == "bcftools" ]]; then
  check_bcftools
else
  err "Unknown VARIANT_CALLER=$VARIANT_CALLER (use bcftools or gatk)"
  exit 1
fi

process_list() {
  local srr="$1"
  if [[ "$VARIANT_CALLER" == "gatk" ]]; then
    call_one_gatk "$srr" && PASS=$((PASS + 1)) || FAIL=$((FAIL + 1))
  else
    call_one_bcftools "$srr" && PASS=$((PASS + 1)) || FAIL=$((FAIL + 1))
  fi
}

if [[ -n "$SINGLE_SRR" ]]; then
  process_list "$SINGLE_SRR"
else
  BAM_COUNT=0
  while IFS= read -r bam; do
    [[ -z "$bam" ]] && continue
    base="$(basename "$bam" _rdna.bam)"
    process_list "$base"
    BAM_COUNT=$((BAM_COUNT + 1))
  done < <(find "$BAM_DIR" -name '*_rdna.bam' | sort)
  if [[ $BAM_COUNT -eq 0 ]]; then
    err "No BAMs matching *_rdna.bam in $BAM_DIR. Run download_and_extract_rdna.sh first."
    exit 1
  fi
fi

log "Variant calling complete — Passed: $PASS | Failed: $FAIL"
log "VCFs in: $VCF_DIR"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
