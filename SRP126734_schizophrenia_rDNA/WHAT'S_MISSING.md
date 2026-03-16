# What’s missing (data not downloaded)

**We have not downloaded or stored the dataset.**

Everything in this folder so far is **metadata + documentation + an unused script**. No sequencing data from SRA is on disk.

## What we have

| Item | Source | Stored here? |
|------|--------|--------------|
| List of 54 run IDs (SRR…) | NCBI SRA runinfo | Yes — `run_list.txt` |
| Run ↔ Sample (GSM) mapping | NCBI SRA runinfo | Yes — `sample_metadata.tsv` |
| Pipeline design + script | Written for this project | Yes — `RDNA_EXTRACTION_PIPELINE.md`, `download_and_extract_rdna.sh` |
| **Actual sequencing data (FASTQ or SRA)** | Would come from SRA download | **No** |
| **rDNA BAMs** | Would come from running the pipeline | **No** |

## What’s missing

1. **Downloaded data**  
   No `.sra` files, no `*.fastq` or `*.fastq.gz` from any SRR. The dataset has not been fetched.

2. **Pipeline not run**  
   `download_and_extract_rdna.sh` has never been executed. So we have no rDNA BAMs and no read counts.

3. **No empirical answer yet**  
   We have not demonstrated “we can specifically download the sequences mapping to the rDNA” with real data — only a plan and a script.

## Blocker before we run anything

We are **waiting on the rDNA extraction scripts from Alka and Kinjal** (per Andreas’s email). Those scripts are the lab’s actual pipeline; we should use them to align our approach and then adapt for public data (e.g. SRP126734). Until we have them, we’re not running downloads or our minimal script so we don’t diverge from the established workflow. See **EMAIL_ALKA_KINJAL_SCRIPTS.md**.

## How to fix it (after we have the scripts)

- **Minimal:** Run the pipeline for **one** run (e.g. first line of `run_list.txt`). That will:
  - Download that run’s FASTQ from SRA (via SRA Toolkit),
  - Align to the rDNA reference,
  - Produce one rDNA BAM and allow reporting “N reads mapping to rDNA.”
- **Full:** Run the script for all 54 runs (large storage and time). Optional.

**Requirements to run:** SRA Toolkit (`prefetch`, `fasterq-dump` or `fastq-dump`), BWA, samtools, and the rDNA reference file `1000_genome_project_referencerDNA.fa` in a path the script can use (e.g. set `RDNA_REF`).
