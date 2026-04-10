# Workbench pipeline replica (from Alka’s screenshots)

These files **recreate the logic visible in PNG screenshots** of All of Us Researcher Workbench notebooks (`path_01_full_extractalign_dsub`, `rdna_01_full_extractalign_dsub`, `path_loose_analysis`, `rdna_02_EDA`). They are **not** a byte-for-byte copy of the original `.ipynb` files (those were not shared).

## How this relates to Professor Hochwagen’s email

- **His ask (SRP126734):** Use public GEO/SRA data and show you can **obtain reads mapping to rDNA**. That is implemented for this study by **`scripts/download_and_extract_rdna.sh`** (SRA → FASTQ → BWA to rDNA → BAM with unmapped reads removed).
- **Senior / MSK / AoU path in screenshots:** **CRAM manifest → chunking → `dsub` on Google Cloud** plus **EDA on AoU tables** (`manifest.csv`, idxstats, etc.). That path needs the Workbench, buckets, and manifests you do **not** have for 414k participants on your laptop.

So: **trial dataset + bash pipeline = what you can run locally for the professor’s first milestone.** The R/Python files here are for **parity with the lab’s cloud workflow** when you are on AoU or reproducing their methods on paper.

## Files

| File | Screenshot source (notebook) | Role |
|------|------------------------------|------|
| `python/01_notebook_env_stub.py` | `path_01_full_extractalign_dsub` | Imports, `USER_NAME` from `OWNER_EMAIL`, manifest note |
| `R/01_greedy_partition.R` | `path_01_full_extractalign_dsub` | Greedy chunking of job sizes for balanced `dsub` tasks |
| `R/02_dsub_input_chunking.R` | `rdna_01_full_extractalign_dsub` | Split `cram_uri` list into per-task input files + manifest copy |
| `R/03_path_loose_cost_analysis.R` | `path_loose_analysis` | Parse timing logs from GCS, estimate VM cost |
| `R/04_rdna_eda_template.R` | `rdna_02_EDA` | Load rDNA FASTA to per-base frame; idxstats + metadata pattern (AoU); **SRP126734 substitutes** in comments |

See `../docs/screenshot_pipeline_map.md` for a fuller index.

## Full OCR of all WhatsApp screenshots

`SCREENSHOT_OCR_FULL.txt` contains machine-readable text from **all 156** PNGs (run `scripts/ocr_geo_screenshots.sh` to refresh). `NOTEBOOK_INDEX_FROM_OCR.md` lists `.ipynb` names found inside that dump.
