#!/usr/bin/env bash
# ==============================================================================
# SRP126734 — Variant Calling on rDNA BAMs
#
# STATUS: STUB — awaiting collaborator scripts from Alka & Kinjal
#
# This script will take per-sample rDNA BAMs (output of download_and_extract_rdna.sh)
# and call variants to produce per-sample VCFs.
#
# Usage (once complete):
#   ./variant_calling.sh                        # process all BAMs in rdna_bams/
#   ./variant_calling.sh -s SRR6375927          # process single sample
#
# Requirements (expected):
#   gatk, samtools, reference FASTA + index
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
RDNA_REF="${RDNA_REF:-1000_genome_project_referencerDNA.fa}"
BAM_DIR="${BAM_DIR:-./rdna_bams}"
VCF_DIR="${VCF_DIR:-./vcfs}"
LOG_DIR="${LOG_DIR:-./logs}"
THREADS="${THREADS:-4}"

mkdir -p "$VCF_DIR" "$LOG_DIR"
LOGFILE="$LOG_DIR/variant_calling_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }
err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOGFILE" >&2; }

# ------------------------------------------------------------------------------
# TODO: Fill in with collaborator scripts from Alka & Kinjal
# ------------------------------------------------------------------------------
# Expected steps (to be confirmed with collaborator scripts):
#
# 1. Add read groups to BAM (required by GATK)
#    samtools addreplacerg -r "ID:$srr\tSM:$srr\tPL:ILLUMINA" \
#      -o ${BAM_DIR}/${srr}_rg.bam ${BAM_DIR}/${srr}_rdna.bam
#
# 2. Call variants with GATK HaplotypeCaller
#    gatk HaplotypeCaller \
#      -R $RDNA_REF \
#      -I ${BAM_DIR}/${srr}_rg.bam \
#      -O ${VCF_DIR}/${srr}.g.vcf.gz \
#      -ERC GVCF \
#      --sample-name $srr
#
# 3. Genotype GVCFs (joint calling across all samples)
#    gatk CombineGVCFs ...
#    gatk GenotypeGVCFs ...
#
# 4. Filter variants
#    gatk VariantFiltration ...
# ------------------------------------------------------------------------------

log "variant_calling.sh — STUB. Waiting for collaborator scripts."
log "Once received, replace the TODO section above with the actual commands."
log "Input BAMs expected in: $BAM_DIR"
log "Output VCFs will go to: $VCF_DIR"

# Validate BAMs exist
BAM_COUNT=$(find "$BAM_DIR" -name "*_rdna.bam" 2>/dev/null | wc -l)
log "Found $BAM_COUNT rDNA BAM(s) in $BAM_DIR ready for variant calling."

if [[ $BAM_COUNT -eq 0 ]]; then
  err "No BAMs found. Run download_and_extract_rdna.sh first."
  exit 1
fi

log "Listing available BAMs:"
find "$BAM_DIR" -name "*_rdna.bam" | sort | tee -a "$LOGFILE"
