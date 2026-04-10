# SRP126734 — Schizophrenia rDNA (public WGS)

Public WGS from **SRP126734 / GSE108065**: 54 runs (29 schizophrenia, 25 controls), Illumina HiSeq X Ten, paired-end. Pipeline: SRA → FASTQ → align to **rDNA reference** → rDNA BAMs; optional variant calling → VCFs.

## Layout

```
data/      run_list.txt, sample_metadata.tsv
scripts/   download_and_extract_rdna.sh, run_pipeline.sh, variant_calling.sh
docs/      pipeline.md, context.md
```

## Usage

Run from this directory (study root). Set **`RDNA_REF`** to your rDNA FASTA (absolute path).

```bash
# Single run: download + align
RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/download_and_extract_rdna.sh -s SRR6375927

# Full pipeline (align + variant calling)
RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/run_pipeline.sh -s SRR6375927

# Align only (skip variant calling)
SKIP_STEP2=true RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/run_pipeline.sh -s SRR6375927

# Variant calling only (existing BAMs)
SKIP_STEP1=true RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/run_pipeline.sh
```

**Outputs:** `rdna_bams/<SRR>_rdna.bam`, `vcfs/<SRR>_rdna.vcf.gz` (after step 2), `logs/`.

**Variant calling:** default `bcftools mpileup | bcftools call`. For GATK: `VARIANT_CALLER=gatk ./scripts/variant_calling.sh` (requires GATK; creates `*_rdna_rg.bam`).

## Dependencies

Install (e.g. conda):

```bash
conda install -c bioconda sra-tools bwa samtools bcftools
```

GATK only if using `VARIANT_CALLER=gatk`.

See **`docs/pipeline.md`** (steps, troubleshooting) and **`docs/context.md`** (dataset, access).
