# Dataset and pipeline — plain-language explanation

## The dataset (SRP126734)

- **What it is:** A public sequencing study in NCBI. Same study is listed as:
  - **SRA:** SRP126734  
  - **GEO:** GSE108065  
  - **BioProject:** PRJNA422380  

- **Design:** Whole-genome sequencing (WGS) of **29 schizophrenia patients** and **25 matched controls** — 54 people total. Each person has one sequencing “run” (one SRR).

- **Technology:** Illumina HiSeq X Ten, paired-end, genomic DNA. So we get reads from the **entire genome**, including the ribosomal DNA (rDNA) region. That’s why we can later isolate “sequences mapping to the rDNA” from this dataset.

- **What we have in this folder:**
  - **run_list.txt** — All 54 SRA run IDs (SRR6375927 through SRR6375980). These are the exact accessions to download.
  - **sample_metadata.tsv** — For each run: Run (SRR), Experiment (SRX), Sample (GSM). A Phenotype column is there to fill in “case” vs “control” from GEO (GSE108065) when needed.

So the dataset is fixed and verified: 54 WGS runs, schizophrenia vs control, ready to use for rDNA extraction.

---

## How we’re doing the pipeline

We do **not** download the full genome and then search for rDNA. We only ever align to rDNA.

**Steps:**

1. **Download**  
   For each run (e.g. SRR6375927), use NCBI SRA Toolkit to get the raw reads in FASTQ format:
   - `prefetch SRR6375927` (optional)
   - `fasterq-dump SRR6375927 --split-files` (or `fastq-dump`)
   That gives us two files per run (paired-end): `SRR6375927_1.fastq`, `SRR6375927_2.fastq`.

2. **Align only to rDNA**  
   We have a reference that contains **only** rDNA: `1000_genome_project_referencerDNA.fa` (same as in the main rDNA project). We align the FASTQ to this reference with BWA:
   - `bwa index 1000_genome_project_referencerDNA.fa` (once)
   - `bwa mem 1000_genome_project_referencerDNA.fa SRR6375927_1.fastq SRR6375927_2.fastq`
   Reads that come from rDNA will map; reads from the rest of the genome will not map (we discard them in practice by only keeping the alignment output).

3. **Save the rDNA-mapping reads**  
   The BWA output is piped into samtools to produce a sorted BAM file, e.g. `SRR6375927_rdna.bam`. **That BAM is exactly “the sequences mapping to the rDNA”** for that sample — because we aligned to an rDNA-only reference.

4. **Optional checks**  
   We can run `samtools flagstat` and `samtools depth` on the BAM to report how many reads mapped and what coverage we get. That answers “can we specifically download the sequences mapping to the rDNA?” with a yes and a number.

**In one line:** Download SRA run → turn into FASTQ → align to rDNA reference only → the resulting BAM is our rDNA-mapping extract.

**Where it’s implemented:** The script `download_and_extract_rdna.sh` does exactly this for one run (with `-s SRRxxxx`) or for all runs in `run_list.txt`. It has not been run yet; when we run it, we’ll have the rDNA BAMs and can report the counts.
