# Data and Analysis Requirements — SRP126734 rDNA Test Set

**Context:** Andreas suggested SRP126734 as a test set for the rDNA–disease project. This document captures the **requirements** and **success criteria** so the exploration and analysis are done correctly and completely.

---

## Goal (from Andreas)

> "The main first thing will be to figure out if we can specifically download the sequences mapping to the rDNA."

So the **first deliverable** is:

1. **Confirm** that we can obtain sequencing data from SRP126734 (SRA/GEO).
2. **Extract** reads that map to the rDNA reference (`1000_genome_project_referencerDNA.fa`).
3. **Report** that rDNA-mapping sequences are available (e.g. read counts, coverage) so the dataset is validated as an rDNA test set.

---

## Dataset requirements (understood and checked)

| Requirement | Status |
|-------------|--------|
| Public SRA project with ~30 schizophrenia + ~30 controls | ✅ SRP126734: 54 runs (29 cases, 25 controls per GSE108065) |
| Sequencing type suitable for rDNA | ✅ WGS (whole-genome); rDNA is present in the genome |
| Accessible via SRA Toolkit / GEO | ✅ Run list and metadata in `run_list.txt`, `sample_metadata.tsv` |
| Link to phenotype (case/control) | ⚠️ GSE108065 has sample-level labels; `Phenotype` in metadata to be filled from GEO or paper |

---

## Analysis requirements

1. **Download**
   - Use SRA Toolkit (`prefetch`, `fasterq-dump` or `fastq-dump`) for runs in `run_list.txt`.
   - Start with 1–2 runs to validate before scaling.

2. **rDNA reference**
   - Use project reference: `1000_genome_project_referencerDNA.fa`.
   - Index with BWA (and/or Bowtie2) as in main pipeline.

3. **Alignment and extraction**
   - Align FASTQ to rDNA reference only → BAM contains only rDNA-mapping reads.
   - No need to align to full genome first; aligning directly to rDNA is correct for “sequences mapping to rDNA”.

4. **Validation**
   - For at least one run: report total rDNA-mapping reads and mean depth (e.g. `samtools flagstat`, `samtools depth`).
   - Document that the approach is reproducible (scripts and docs in this folder).

5. **Optional (downstream)**
   - Variant calling on rDNA BAMs → VCF.
   - Merge phenotype (case/control) with rDNA variants for burden/association and ML (same workflow as Kwashiorkor in All of Us).

---

## Deliverables in this folder

- [x] **run_list.txt** — All 54 SRA run accessions.
- [x] **sample_metadata.tsv** — Run, Experiment, Sample (GSM); Phenotype to be filled from GSE108065.
- [x] **README.md** — Dataset summary, goal, and next steps.
- [x] **RDNA_EXTRACTION_PIPELINE.md** — Step-by-step pipeline for rDNA extraction.
- [x] **download_and_extract_rdna.sh** — Example script: download → align to rDNA → rDNA BAM.
- [x] **DATA_REQUIREMENTS.md** — This file: requirements and success criteria.

---

## Success criteria (first goal)

- We can **download** at least one SRR from SRP126734.
- We can **align** those reads to `1000_genome_project_referencerDNA.fa` and produce an rDNA BAM.
- We can **report** rDNA-mapping read counts (and optionally coverage), showing that “we can specifically … download the sequences mapping to the rDNA.”

After that, the dataset is validated as an rDNA test set for schizophrenia vs control analyses.
