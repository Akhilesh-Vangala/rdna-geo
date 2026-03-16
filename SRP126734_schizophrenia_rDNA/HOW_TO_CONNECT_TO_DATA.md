# How we connect with the data itself

The **original dataset** (the 54 sequencing runs) lives on **NCBI’s servers**, not in this folder. We connect to it using the **run accessions** we already have and NCBI’s download tools.

---

## 1. What we have (the link to the data)

- **run_list.txt** — One SRA run accession per line (e.g. `SRR6375927`, `SRR6375928`, …). Each line is a **unique ID** for one run’s data on NCBI.
- **sample_metadata.tsv** — Maps each run (SRR) to experiment (SRX) and sample (GSM). Same IDs, no actual sequences.

Those IDs are the **connection**: NCBI uses them to serve the real data.

---

## 2. How to actually get the data (connect and download)

You need **SRA Toolkit** (from NCBI): [https://github.com/ncbi/sra-tools](https://github.com/ncbi/sra-tools).

**For one run (e.g. SRR6375927):**

```bash
# Optional: prefetch the run (downloads .sra file)
prefetch SRR6375927

# Dump to FASTQ (what we use for alignment)
fasterq-dump SRR6375927 --split-files -O ./fastq
# Or: fastq-dump SRR6375927 --split-files --outdir ./fastq
```

After that, `./fastq/SRR6375927_1.fastq` and `SRR6375927_2.fastq` (or one file if single-end) **are** the data for that run. So:

- **Connection** = using the accession (e.g. `SRR6375927`) with SRA Toolkit.
- **Result** = FASTQ files on your machine, which you then align to the rDNA reference (see `download_and_extract_rdna.sh` or `RDNA_EXTRACTION_PIPELINE.md`).

**For all 54 runs:** loop over `run_list.txt` and run the same for each SRR (or use the script once we’re ready to run it).

---

## 3. In one sentence

**We connect to the data by giving SRA Toolkit the run IDs from `run_list.txt`; it fetches the corresponding FASTQ from NCBI and writes it into our folder.**

No API key is needed for public SRA data; the run ID is enough.
