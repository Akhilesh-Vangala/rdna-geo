# SRP126734 — Schizophrenia rDNA

Test set for the rDNA–disease project (Hochwagen lab). Goal: obtain sequences mapping to the rDNA from public WGS (SRP126734 / GSE108065). 54 samples (29 schizophrenia, 25 controls). Illumina HiSeq X Ten, paired-end.

## Structure

```
data/           run_list.txt, sample_metadata.tsv
scripts/        download_and_extract_rdna.sh, run_pipeline.sh, variant_calling.sh
docs/           pipeline.md, context.md
```

## Run pipeline

From this directory (study root):

```bash
# Place rDNA reference in study root or set RDNA_REF
RDNA_REF=/path/to/1000_genome_project_referencerDNA.fa ./scripts/run_pipeline.sh -s SRR6375927   # one sample
RDNA_REF=/path/to/1000_genome_project_referencerDNA.fa ./scripts/run_pipeline.sh                 # all 54
```

Output: `rdna_bams/` (rDNA BAMs), `vcfs/` (after variant-calling step is filled). Logs in `logs/`.

## Requirements

sra-tools, bwa, samtools. rDNA reference from collaborators. See `docs/pipeline.md` and `docs/context.md`.
