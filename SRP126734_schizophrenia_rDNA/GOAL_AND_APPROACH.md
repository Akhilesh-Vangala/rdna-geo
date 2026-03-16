# Goal and How We Achieve It

## What we were asked

From Andreas:

> "This is a dataset in GEO that contains a little under 30 sequencing samples from schizophrenia patients and a similar number of matched controls: **SRP126734**. I think this could be a good test set. The **main first thing** will be to **figure out if we can specifically download the sequences mapping to the rDNA**."

So the deliverable is: **determine whether we can obtain, in a targeted way, the reads that map to rDNA** for this study — and do it in a reproducible way.

---

## How we achieve it

We do **not** download the full genome and then search for rDNA in it. We do the following:

1. **Download** the study’s sequencing data from SRA (one or more runs from SRP126734) as FASTQ.
2. **Align** those reads to **only** the rDNA reference (`1000_genome_project_referencerDNA.fa`).
3. **Keep** the aligned reads. Those reads are, by definition, **the sequences mapping to the rDNA** — because the reference contains nothing else.

So “download the sequences mapping to the rDNA” means: **get FASTQ from SRA → align to rDNA reference → the resulting BAM (or extracted FASTQ from it) is our rDNA-mapping subset.** No full-genome alignment is required.

---

## What we did (concrete)

| Step | What we did |
|------|-------------|
| **Dataset** | Confirmed SRP126734 = GSE108065 = PRJNA422380: 54 WGS runs (29 schizophrenia, 25 controls), Illumina HiSeq X Ten, paired-end. |
| **Run list** | Pulled the official SRA run table and wrote every run accession to `run_list.txt` (54 SRRs). |
| **Metadata** | Built `sample_metadata.tsv` with Run, Experiment, Sample (GSM). Phenotype column is there to be filled from GSE108065 (case/control). |
| **Pipeline** | Defined a small pipeline: SRA → FASTQ → align to rDNA reference (BWA) → sorted BAM. The BAM is the “rDNA-only” extract. Documented it in `RDNA_EXTRACTION_PIPELINE.md` and implemented it in `download_and_extract_rdna.sh`. |
| **Reference** | Same as the main project: `1000_genome_project_referencerDNA.fa`. The script expects its path (or builds the BWA index if missing). |

We have **not** yet run the pipeline on real data (no FASTQ or BAMs produced). The pipeline is ready so that when we run it (e.g. on one run first), we can immediately report: “We downloaded run X, aligned to rDNA only, and obtained N reads mapping to rDNA.”

---

## Pipeline in one sentence

**Pipeline:** For each SRA run in `run_list.txt`, download FASTQ with SRA Toolkit, align to `1000_genome_project_referencerDNA.fa` with BWA, and write a per-run rDNA BAM; that BAM is the set of sequences mapping to the rDNA for that sample.

---

## Summary

- **Goal:** Figure out if we can specifically download the sequences mapping to the rDNA (Andreas’s main first ask).
- **Approach:** Download SRA → align to rDNA-only reference → keep those reads (BAM). That *is* the rDNA-mapping subset.
- **What we did:** Verified the dataset, listed all runs, added metadata, and implemented a small pipeline (script + docs) that performs this. Running the script on one or more runs will complete the demonstration.
