# Screenshot → notebook → local equivalent

Alka’s WhatsApp images are ordered in folders `geo scripts`, `geo scripts 2`, `geo scripts 3`, `geo scripts 4` (repo root or Desktop copy). Timestamps align with her message order on 2026-03-24.

## Notebooks identified in sampled screenshots

| Notebook (Workbench) | Language | Purpose |
|----------------------|----------|---------|
| `path_01_full_extractalign_dsub.ipynb` | Python + bash | Env prep; `dsub` wrapper (`aou_dsub.bash`); manifest `data/manifest.csv`; pilot vs full CRAM lists |
| `rdna_01_full_extractalign_dsub.ipynb` | R | Build `dsub_files_full/Task_N_input.txt` from `cram_uri`; write `manifest_df.csv`; start `taskfile.tsv` for `dsub` |
| `path_loose_analysis.ipynb` | R | After pilot: read `dsub_files_pilot/*_input.txt`, pull `${WORKSPACE_BUCKET}/rdna/logging_pilot_v2/*-stdout.log` via `gsutil`, compute runtime and $ |
| `rdna_02_EDA.ipynb` | R | Join `manifest.csv`, `genomic_metrics.tsv`, `ancestry_preds.tsv`; load `ref/rdna.fa` (13,365 bp); idxstats `full_aou_hg38_idxstats.tsv.gz`; sample coverage checks |

## Trial dataset for the professor’s task

- **SRP126734:** `data/run_list.txt` (54 SRR IDs) and `data/sample_metadata.tsv` (phenotype). This is the **public test set** named in the email.
- **Not in repo:** raw FASTQ/BAM (produced when you run `scripts/download_and_extract_rdna.sh`).

## What the screenshots are *not*

- They are **not** a second copy of `download_and_extract_rdna.sh`. That shell script is the **SRA/local** analogue of “extract reads and align to rDNA,” without CRAM or `dsub`.
- They do **not** include downloadable **414,830-row** `manifest.csv` or MSK workspace outputs; those live in a cloud workspace Alka could only show as images.

## Local replica code

Under `workbench_replica/`:

- R/Python snippets reconstructed from visible cells.
- Comments mark **SRP126734** stand-ins where AoU-specific paths apply.

## Execution summary

| Goal | Run this |
|------|----------|
| Professor’s first ask on SRP126734 | `scripts/download_and_extract_rdna.sh` with `RDNA_REF` set to collaborator FASTA |
| Match seniors’ **idea** of chunk + cloud batch | Read `workbench_replica/R/01_*.R`, `02_*.R` (needs your own manifest + `dsub` environment) |
| Match seniors’ **cost post-mortem** | `workbench_replica/R/03_path_loose_cost_analysis.R` (needs logs in a bucket) |
| Match seniors’ **EDA** | `workbench_replica/R/04_rdna_eda_template.R` (needs AoU tables **or** adapted inputs from your BAMs/idxstats) |
