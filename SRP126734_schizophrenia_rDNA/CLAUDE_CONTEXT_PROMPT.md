# Exact prompt to give Claude (or any coding assistant) for full context

**Copy everything below the line and paste it into a new chat (or at the start of a task) so the assistant has full context and remembers what needs to be achieved.**

---

You are helping with a bioinformatics project. Below is the exact goal from the professor’s email, the project folder structure, what has already been done, and what remains. Use this as the single source of truth.

## 1. Goal from the professor’s email (Andreas)

> "This is a dataset in GEO that contains a little under 30 sequencing samples from schizophrenia patients and a similar number of matched controls: **SRP126734**. I think this could be a good test set. The **main first thing** will be to **figure out if we can specifically download the sequences mapping to the rDNA**."

So the primary deliverable is: **determine whether we can obtain the reads that map to rDNA** for this study, in a targeted and reproducible way. Anything else (variant calling, association, ML) comes after this first step.

## 2. Project folder and what’s in it

**Main project root:** `rna` (contains two subfolders: `all_of_us/` for the initial All of Us project, and `geo/` for public-dataset rDNA work).

**All of Us:** `rna/all_of_us/` — RA docs, meeting prep, rDNA presentation summary, Kwashiorkor cohort, pipeline references.

**GEO / public test set:** `rna/geo/SRP126734_schizophrenia_rDNA/`

Files in `geo/SRP126734_schizophrenia_rDNA/`:

| File | Purpose |
|------|--------|
| **GOAL_AND_APPROACH.md** | Canonical description: the professor’s ask, how we achieve it (SRA → FASTQ → align to rDNA reference → BAM = rDNA-mapping reads), and what we did (run list, metadata, pipeline design, script). |
| **README.md** | Dataset summary (SRP126734 = GSE108065, 54 runs, 29 schizophrenia / 25 controls, WGS), file list, links. |
| **PIPELINE_AND_DATASET_EXPLAINED.md** | Plain-language explanation of the dataset and how the pipeline works (download → align to rDNA only → BAM is the rDNA extract). |
| **RDNA_EXTRACTION_PIPELINE.md** | Step-by-step pipeline: prerequisites (SRA Toolkit, BWA, samtools, rDNA reference), commands for one run, scaling to all runs. |
| **download_and_extract_rdna.sh** | Executable pipeline: for each SRR in run_list.txt (or a single SRR with `-s SRRxxxx`), download FASTQ, align to `1000_genome_project_referencerDNA.fa` with BWA, output per-run rDNA BAM. Uses env var RDNA_REF for reference path. Not run yet. |
| **run_list.txt** | 54 lines, one SRA run accession (SRR) per line (SRR6375927 … SRR6375980). |
| **sample_metadata.tsv** | TSV: Run, Experiment, Sample_name (GSM), Phenotype. Phenotype column is empty; to be filled from GSE108065 (case/control). |
| **DATA_REQUIREMENTS.md** | Requirements and success criteria for this test set. |
| **CLAUDE_CONTEXT_PROMPT.md** | This prompt — for handing off context to an AI or a collaborator. |

## 3. Dataset (fixed facts)

- **Study:** SRP126734 = GSE108065 = PRJNA422380. Title: “Genome-wide sequencing of schizophrenia and control individuals [WGS]”.
- **Samples:** 54 total = 29 schizophrenia patients + 25 matched controls.
- **Sequencing:** Illumina HiSeq X Ten, whole-genome (WGS), paired-end, genomic DNA. So rDNA is present in the reads.
- **rDNA reference:** Same as main project: `1000_genome_project_referencerDNA.fa`. Pipeline aligns only to this reference so that the output BAMs are exactly “sequences mapping to the rDNA.”

## 4. What has been done

- Verified the dataset (SRA/GEO/BioProject, 54 runs, 29 vs 25).
- Fetched the official run list and wrote it to `run_list.txt`.
- Built `sample_metadata.tsv` (Run, SRX, GSM; Phenotype to be filled).
- Designed and documented the pipeline (SRA → FASTQ → BWA to rDNA reference → per-run rDNA BAM).
- Implemented the pipeline in `download_and_extract_rdna.sh`.
- **Not done yet:** Pipeline has not been run (no FASTQ or BAMs produced). Phenotype column not yet filled from GEO.

## 5. What needs to be achieved (from the email)

1. **Main deliverable:** Show that we can specifically download the sequences mapping to the rDNA. That means: run the pipeline (e.g. on one run first), produce the rDNA BAM, and report that we obtained N reads mapping to rDNA (e.g. via samtools flagstat / depth).
2. **Optional:** Fill Phenotype in sample_metadata.tsv from GSE108065 (case/control). Optionally scale to all 54 runs; optionally add variant calling later (same as main project).

When making changes or suggestions, keep this context: the goal is from Andreas’s email; the pipeline is “download SRA → align to rDNA reference only → BAM = rDNA-mapping sequences”; and the project folder is `rna/geo/SRP126734_schizophrenia_rDNA/` with the files listed above.
