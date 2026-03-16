# Approach — SRP126734 rDNA Analysis

## Pipeline

```
NCBI SRA — SRP126734
(54 WGS samples: 29 schizophrenia, 25 controls)
      │
      ▼
 fasterq-dump (per SRR from run_list.txt)
      │
      ▼
 FASTQ_1 + FASTQ_2
      │
      ▼
 bwa mem → 1000_genome_project_referencerDNA.fa
      │
      ▼
 samtools: SAM → sorted BAM → index
      │
      ▼
 rDNA BAM per sample         ◀── answers professor's question
      │
      ▼
 Variant calling → VCF
      │
      ▼
 Extract variants/indels → Dataframe
      │
      ▼
 Label with phenotype (schizophrenia / control)
 from sample_metadata.tsv
      │
      ▼
 Burden analysis / Association test
```

## What's needed to run

1. **rDNA reference file** — `1000_genome_project_referencerDNA.fa` must be present (from 1000 Genomes Project / Alka & Kinjal).
2. **Phenotype column** — `sample_metadata.tsv` Phenotype field must be filled from GEO (GSE108065).

## Script

`download_and_extract_rdna.sh` handles steps 1–4 (download → rDNA BAM). Run on a single sample first:

```bash
./download_and_extract_rdna.sh -s SRR6375927
```
