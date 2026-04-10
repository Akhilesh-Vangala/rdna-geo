# SRP126734 — Schizophrenia rDNA

Test set for the rDNA–disease project (Hochwagen lab). Goal: obtain sequences mapping to the rDNA from public WGS (SRP126734 / GSE108065). 54 samples (29 schizophrenia, 25 controls). Illumina HiSeq X Ten, paired-end.

## Structure

```
data/               run_list.txt, sample_metadata.tsv  (54-run trial set for the professor’s ask)
scripts/            download_and_extract_rdna.sh, run_pipeline.sh, variant_calling.sh (bcftools or GATK)
docs/               pipeline.md, context.md, screenshot_pipeline_map.md
workbench_replica/  R + Python snippets reconstructed from Alka’s Workbench screenshots (AoU/dsub path)
```

## Run pipeline (what the professor asked first: rDNA-mapping reads from SRA)

From this directory (study root):

```bash
# Point to the collaborator rDNA FASTA (e.g. geo scripts/1000_genome_new_ref_v3_string (1).fasta)
RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/download_and_extract_rdna.sh -s SRR6375927

# Full pipeline including variant calling (per-sample VCFs in vcfs/)
RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/run_pipeline.sh -s SRR6375927

# Download + align only (skip step 2):
SKIP_STEP2=true RDNA_REF="/absolute/path/to/rDNA.fa" ./scripts/run_pipeline.sh -s SRR6375927
```

Output: `rdna_bams/` (rDNA BAMs), `vcfs/` (`<SRR>_rdna.vcf.gz` from **bcftools** by default). Logs in `logs/`.

**Variant calling:** default is `bcftools mpileup | bcftools call`. For GATK HaplotypeCaller, install GATK and run with `VARIANT_CALLER=gatk ./scripts/variant_calling.sh` (adds read groups; creates `*_rdna_rg.bam`). Lab-specific **mgatk**-style pipelines are separate; this gives standard VCFs from your rDNA BAMs.

## Requirements

sra-tools, bwa, samtools, **bcftools** (for step 2). rDNA reference from collaborators. See `docs/pipeline.md` and `docs/context.md`.

## Screenshots vs this repo

WhatsApp screenshots show the **All of Us** path (CRAM manifest, `dsub`, huge idxstats). That is documented and partially replicated under `workbench_replica/` and `docs/screenshot_pipeline_map.md`. **Local execution for SRP126734** is the bash script above, not those notebooks.

## Sharing with a friend (what to send)

**In one zip or repo path, send the whole study directory:**

`geo/SRP126734_schizophrenia_rDNA/` — includes `scripts/`, `data/`, `docs/`, `workbench_replica/`, and this README.

**Also send separately (not tracked in git — too large / collaborator file):**

- The **rDNA FASTA** you used (e.g. `1000_genome_new_ref_v3_string (1).fasta` from the `geo scripts/` folder on your machine), or any path your lab approves. Your friend sets `RDNA_REF="/absolute/path/to/that.fasta"` when running.

**Optional:** if the repo’s `.gitignore` excluded outputs on their clone, tell them **BAMs / FASTQ / VCFs / logs** are produced locally when they run the scripts — they are not required in the share.

**Tell them to install:** `conda install -c bioconda sra-tools bwa samtools bcftools` (and **GATK** only if they use `VARIANT_CALLER=gatk`).

**One-line summary for your friend:** *Public schizophrenia/control WGS (SRP126734): download from SRA → align to lab rDNA reference → rDNA-only BAMs; optional bcftools/GATK VCFs. Workbench replica folder is documentation of the All of Us cloud workflow, not what runs GEO.*
