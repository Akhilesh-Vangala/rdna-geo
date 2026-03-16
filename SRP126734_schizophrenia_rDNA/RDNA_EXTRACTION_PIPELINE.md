# rDNA Extraction Pipeline — SRP126734

How to **download** SRP126734 data and **extract sequences that map to rDNA** using the project’s rDNA reference.

---

## Overview

1. **Obtain rDNA reference**  
   Use `1000_genome_project_referencerDNA.fa` (same as in the main rDNA pipeline).

2. **Download SRA runs**  
   Use NCBI SRA Toolkit (`prefetch` + `fasterq-dump` or `fastq-dump`) for each SRR in `run_list.txt`.

3. **Align to rDNA**  
   Align FASTQ to the rDNA reference with BWA or Bowtie2; keep only reads that map to rDNA.

4. **Extract rDNA-mapping reads**  
   From the alignment (BAM/SAM), extract reads that map to the rDNA reference (and optionally sort/index for variant calling).

5. **(Optional) Variant calling**  
   Run the same variant-calling step as in the All of Us rDNA pipeline on the rDNA BAMs.

---

## Prerequisites

- **SRA Toolkit**  
  - [NCBI SRA Toolkit](https://github.com/ncbi/sra-tools)  
  - `prefetch SRR...` and `fasterq-dump SRR...` (or `fastq-dump`).

- **Reference**  
  - `1000_genome_project_referencerDNA.fa`  
  - Index for your aligner (see below).

- **Aligner**  
  - BWA or Bowtie2.  
  - BWA: `bwa index 1000_genome_project_referencerDNA.fa` then `bwa mem`.  
  - Bowtie2: `bowtie2-build` then `bowtie2`.

- **Samtools**  
  - To filter BAM (e.g. keep only mapped reads, sort, index).

---

## Step-by-step

### 1. Index the rDNA reference

```bash
# BWA
bwa index 1000_genome_project_referencerDNA.fa

# Bowtie2 (optional alternative)
bowtie2-build 1000_genome_project_referencerDNA.fa rdna_ref
```

### 2. Download one run (test)

```bash
# Prefetch (optional; creates .sra in ~/ncbi/public/sra or current dir)
prefetch SRR6375927

# Dump to FASTQ (paired if applicable)
fasterq-dump SRR6375927 --split-files -O ./fastq
# Or: fastq-dump SRR6375927 --split-files --outdir ./fastq
```

### 3. Align to rDNA

```bash
# Example: BWA MEM, paired-end
bwa mem 1000_genome_project_referencerDNA.fa fastq/SRR6375927_1.fastq fastq/SRR6375927_2.fastq \
  | samtools view -bS - \
  | samtools sort -o SRR6375927_rdna.bam -
samtools index SRR6375927_rdna.bam
```

All reads in `SRR6375927_rdna.bam` are **rDNA-mapping** (the reference is rDNA-only), so this BAM is the “rDNA-only” extract.

### 4. Check rDNA coverage

```bash
samtools flagstat SRR6375927_rdna.bam
samtools depth SRR6375927_rdna.bam | awk '{sum+=$3} END {print sum/NR}'
```

Use this to confirm that we **can** get rDNA-mapping sequences from this dataset.

### 5. Scale to all runs

- Loop over `run_list.txt`: for each SRR, run `prefetch`/`fasterq-dump` → align → sort/index.
- Store rDNA BAMs (and optionally FASTQs) in a structured way (e.g. `rdna_bams/SRR6375927_rdna.bam`).
- Optionally run the same variant-calling pipeline as in the main project on each rDNA BAM to get VCFs for association/ML.

---

## Important notes

- **WGS vs exome:** This study is WGS, so rDNA is expected to be present. If you were using exome data, rDNA would often be absent or sparse.
- **Storage:** Full FASTQ for 54 WGS runs is very large. Options: (1) stream directly into the aligner (e.g. `fasterq-dump ... | bwa mem ...`), or (2) download and align in batches and delete FASTQ after alignment.
- **Reference location:** Ensure the path to `1000_genome_project_referencerDNA.fa` is correct (e.g. in the main project or a shared reference directory).

---

## Relation to main project

- **All of Us pipeline:** CRAM → FASTQ → align to `1000_genome_project_referencerDNA.fa` → variant calling → VCF.  
- **Here:** SRA (FASTQ) → align to same rDNA reference → rDNA BAM (and optionally VCF).  
- **Downstream:** Same idea: phenotype (case/control) + rDNA variants/burden → association and supervised ML (e.g. as with Kwashiorkor in All of Us).
