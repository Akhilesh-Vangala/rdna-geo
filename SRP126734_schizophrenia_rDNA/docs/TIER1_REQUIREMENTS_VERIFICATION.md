# Tier 1 — requirements verification (professor vs Alka materials)

This document separates **what was strictly required** for each stated goal, **what was actually executed**, and **where Alka’s screenshots/files fit** so there is no mixed message.

---

## 1. Professor Hochwagen (GEO email) — SRP126734

**Quoted intent:** Use **SRP126734** as a test set; **first thing** is to figure out if you can **get sequences mapping to rDNA**.

| Requirement | How it is satisfied | Evidence in repo / on disk |
|-------------|---------------------|----------------------------|
| Correct public study | SRP126734 / GSE108065; 54 runs in `data/run_list.txt` | `data/run_list.txt`, `data/sample_metadata.tsv` |
| Obtain reads mapping to rDNA | SRA → FASTQ → **BWA** to **rDNA FASTA** → **BAM** (unmapped filtered) | `scripts/download_and_extract_rdna.sh`, `scripts/run_pipeline.sh` |
| Same biological reference as lab | Collaborator **rDNA FASTA** (from Alka’s shared files) | e.g. `geo scripts/1000_genome_new_ref_v3_string (1).fasta` |
| Report / proof | **flagstat** + BAM paths | `docs/run_records_three_samples.md`, `logs/SRR*.log`, `rdna_bams/*.bam` |

**Tier 1 verdict for this email:** **Met** for the **extraction / alignment** milestone (three example runs documented). **Not** part of this first ask: full **variant calling** (see §4).

---

## 2. What Alka sent — two different kinds of “scripts”

| Kind | What it is | Needed for GEO email (§1)? |
|------|------------|----------------------------|
| **A. Files** | rDNA **FASTA**, example outputs (e.g. mgatk-style TSV), PDFs, manuscript bits | **FASTA = yes** (reference for BWA). Other files = context / downstream / learning, not required to *produce* the first rDNA BAMs from SRA. |
| **B. Screenshots** | All of Us notebooks (`path_01_*`, `rdna_01_*`, `path_loose_analysis`, `rdna_02_EDA`, …) | **Not executed** on your Mac for SRP126734. They describe **CRAM + `dsub` + GCS** — **different stack** than NCBI SRA. **Still valuable:** shows how **seniors/lab** run rDNA work **on AoU**; aligns you with lab vocabulary and future controlled-tier work. |

**Why Alka sent it (reasonable interpretation):**  
- **Reference + context** so your **alignment** matches what they use.  
- **Transparency** about how the **MSK/AoU** side works (credits, scale, EDA).  
- **Not** a substitute for downloading **SRP126734** from **SRA** (that’s a different data path).

---

## 3. What we actually ran (execution truth)

| Track | Ran? | Artifacts |
|-------|------|-----------|
| **SRP126734 bash pipeline** (`run_pipeline.sh` → `download_and_extract_rdna.sh`) | **Yes** — 3 SRRs | `rdna_bams/SRR6375927_rdna.bam`, `…5928…`, `…5931…`; logs; `docs/run_records_three_samples.md` |
| **`workbench_replica/` R/Python** | **No** — not used as the driver for those BAMs | Reference / teaching only |
| **`variant_calling.sh`** | **Implemented** — default **bcftools**; optional **GATK** | `vcfs/<SRR>_rdna.vcf.gz` when step 2 is run |

---

## 4. `docs/context.md` — “collaborator scripts” (professor ↔ Alka)

The repo says the professor asked collaborators for **rDNA extraction / variant-calling** alignment with the lab. That implies **two layers**:

| Layer | Status | Notes |
|-------|--------|--------|
| **Extraction to rDNA (SRA world)** | **Done** with **bash + BWA + Alka’s FASTA** | Matches “get sequences mapping to rDNA” for **public** data. |
| **Variant calling** | **bcftools/GATK** in `variant_calling.sh` (generic VCFs from rDNA BAMs) | **Not** a copy of Alka’s **mgatk** commands; `HQ_mgatk_variants.tsv` in `geo scripts/` is **example lab output**, not reproduced by default. |

So: **Alka’s materials were “needed”** in the sense of **reference + lab alignment + future steps**; they were **not** the **executable** path for **downloading SRP126734 from NCBI** (that’s **`prefetch` / `fasterq-dump` + your shell scripts**).

---

## 5. Resolving the misunderstanding

| Statement | Accurate? |
|-----------|-----------|
| “We had to run Alka’s Jupyter/`dsub` notebooks to satisfy the GEO email.” | **No** — those notebooks target **AoU CRAM + cloud batch**, not **SRA**. |
| “Alka’s files were irrelevant.” | **No** — the **rDNA FASTA** (and understanding their pipeline) **is** relevant. |
| “We satisfied the professor’s first GEO ask with our runs.” | **Yes** — SRP126734 → rDNA BAMs + stats, documented. |
| “We fully replicated every senior notebook line-by-line.” | **No** — only **OCR + partial `workbench_replica`**; original `.ipynb` not shared. |

---

## 6. Single summary sentence (for you or email)

**We used Alka’s rDNA reference and lab context from her materials; we implemented the professor’s SRP126734 ask with the **SRA bash pipeline** on your machine and documented three runs. The Workbench notebook code is **parallel documentation** for how the lab does **All of Us**, not the code path that produced the **GEO** BAMs.**
