# SRP126734 — Schizophrenia rDNA Analysis

## What This Is

Test dataset for the rDNA–disease project (Prof. Andreas Hochwagen, NYU).

**Professor's ask:**
> "This is a dataset in GEO that contains a little under 30 sequencing samples from schizophrenia patients and a similar number of matched controls: SRP126734. The main first thing will be to figure out if we can specifically download the sequences mapping to the rDNA."

**Our job:** Download the raw sequencing data from NCBI SRA, align to the rDNA reference, extract only the rDNA-mapping reads, and confirm it works.

---

## Dataset

| Field | Value |
|---|---|
| SRA Project | SRP126734 |
| GEO Series | GSE108065 |
| Samples | 54 total — 29 schizophrenia, 25 controls |
| Sequencing | Whole-genome (WGS), paired-end, Illumina HiSeq X Ten |
| Data type | Raw reads (FASTQ), publicly available on NCBI SRA |

The data is **public** — no login or credentials needed.

---

## Files in This Folder

### Data files
| File | What it contains |
|---|---|
| `run_list.txt` | 54 SRR accession numbers (SRR6375927 – SRR6375980) |
| `sample_metadata.tsv` | SRR → SRX → GSM → Phenotype (Schizo/Control) for all 54 samples |

### Scripts
| File | What it does | Status |
|---|---|---|
| `download_and_extract_rdna.sh` | Downloads FASTQ from NCBI SRA + aligns to rDNA reference → outputs rDNA BAM per sample | Ready |
| `variant_calling.sh` | Takes rDNA BAMs → calls variants → outputs VCF per sample | Stub — fill in with collaborator scripts |
| `run_pipeline.sh` | Master script — runs both steps end to end | Ready |

### Documentation
| File | Purpose |
|---|---|
| `README.md` | This file — single source of truth |
| `APPROACH.md` | Pipeline flowchart |
| `sample_metadata.tsv` | All phenotype labels (fetched from GEO) |

---

## How the Data is Accessed

The raw sequencing data lives on NCBI's public SRA servers. We access it using `fasterq-dump` (part of SRA Toolkit), which downloads each sample by its SRR accession number over the internet — no login needed.

```
run_list.txt (54 SRR numbers)
        │
        │  fasterq-dump SRR6375927  ← connects to NCBI automatically
        ▼
FASTQ files (raw reads) downloaded to ./fastq/
        │
        │  bwa mem → rDNA reference
        ▼
rDNA-only BAM in ./rdna_bams/      ← answers professor's question
        │
        │  variant_calling.sh      ← fill with collaborator scripts
        ▼
VCF files in ./vcfs/
        │
        │  (downstream analysis)
        ▼
Variants + phenotype labels → burden analysis / association test
```

---

## Tools Required

All installed:

| Tool | Version | Purpose |
|---|---|---|
| `fasterq-dump` | 3.3.0 | Download FASTQ from NCBI SRA |
| `bwa` | 0.7.19 | Align reads to rDNA reference |
| `samtools` | 1.23 | Convert/sort/index BAM files |

Install command (if needed on another machine):
```bash
brew install sratoolkit bwa samtools
```

---

## What's Still Needed

### 1. rDNA Reference File
**File:** `1000_genome_project_referencerDNA.fa`

This is the human rDNA sequence (based on GenBank U13369) used as the alignment target. Without it, BWA has nothing to align reads against.

**Get it from:** Alka & Kinjal — they already have this file. Ask them to send it and place it in this folder.

### 2. Collaborator Scripts (for variant calling)
Andreas asked Alka & Kinjal to share the scripts their collaborators used to extract rDNA data and build their dataset. Once received:
- Paste the variant calling commands into `variant_calling.sh` where marked `TODO`

---

## How to Run

### Step 0 — Place the reference file in this folder
```
1000_genome_project_referencerDNA.fa  ← get from Alka & Kinjal
```

### Step 1 — Test on one sample first
```bash
cd /path/to/SRP126734_schizophrenia_rDNA

RDNA_REF=./1000_genome_project_referencerDNA.fa \
./run_pipeline.sh -s SRR6375927
```

Check the output:
```bash
samtools flagstat rdna_bams/SRR6375927_rdna.bam
```
This prints how many reads mapped to rDNA — that number answers the professor's question.

### Step 2 — Run all 54 samples
```bash
RDNA_REF=./1000_genome_project_referencerDNA.fa \
./run_pipeline.sh
```

### Optional flags
```bash
KEEP_FASTQ=true   # keep FASTQ files after alignment (deleted by default to save space)
THREADS=8         # increase threads (default: 4)
SKIP_STEP2=true   # run download only, skip variant calling
SKIP_STEP1=true   # run variant calling only (if BAMs already exist)
```

---

## Output Structure (after running)

```
SRP126734_schizophrenia_rDNA/
├── rdna_bams/
│   ├── SRR6375927_rdna.bam      ← rDNA-mapping reads for sample 1
│   ├── SRR6375927_rdna.bam.bai  ← index
│   └── ...54 samples
├── vcfs/
│   ├── SRR6375927.vcf           ← variants (after collaborator scripts added)
│   └── ...
├── fastq/                       ← deleted after alignment by default
└── logs/
    ├── pipeline_YYYYMMDD.log    ← master log
    └── SRR6375927.log           ← per-sample log
```

---

## Sample Metadata Summary

All 54 phenotypes confirmed from GEO (GSE108065):
- **29 Schizophrenia:** SRR6375928-930, 933-935, 938-941, 943, 946-948, 950-956, 972-975, 977-980
- **25 Control:** SRR6375927, 931-932, 936-937, 942, 944-945, 949, 957-971, 976

Full mapping in `sample_metadata.tsv`.

---

## Current Status

| Task | Status |
|---|---|
| Dataset identified (SRP126734) | Done |
| All 54 SRR accessions listed | Done |
| All 54 phenotypes filled from GEO | Done |
| Tools installed (sra-tools, bwa, samtools) | Done |
| `download_and_extract_rdna.sh` production ready | Done |
| `run_pipeline.sh` master script ready | Done |
| rDNA reference file | **Waiting — get from Alka & Kinjal** |
| Collaborator variant calling scripts | **Waiting — Andreas asked Alka & Kinjal to send** |
| Pipeline actually run on data | Not yet |
