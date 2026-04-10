# Notebook titles recovered from screenshot OCR

Source: `SCREENSHOT_OCR_FULL.txt` (Tesseract over all 156 PNGs under `geo scripts*`). OCR garbles some titles; likely intended names in brackets.

| OCR name | Likely real name | Role (from text around hits) |
|----------|------------------|------------------------------|
| `path_01_full_extractalign_dsub.ipynb` | same | Python env, `aou_dsub.bash`, manifest `data/manifest.csv`, dsub defaults |
| `1_dsub_setup.ipynb` | same | Referenced as creator of `source ~/aou_dsub.bash` |
| `CM_0O_setup.ipynb` / `CM_0OO_setup.ipynb` | e.g. `CM_00_setup.ipynb` | Setup cells (OCR noise) |
| `path_loose_analysis.ipynb` | same | R: pilot timing, `gsutil`, VM costs, `dsub_files_pilot` |
| `rdna_01_full_extractalign_dsub.ipynb` | same | R: `cram_uri` chunking, `dsub_files_full/Task_*_input.txt` |
| `rdna_02_EDA.ipynb` | same | R: manifest join, `ref/rdna.fa`, idxstats, EDA |
| `na_02_EDA.ipynb` | `rdna_02_EDA.ipynb` | OCR fragment |

Workspace URL pattern (from OCR): `workbench.researchallofus.org/.../rdna/analysis/preview/<notebook>`.

For **SRP126734 locally**, use `scripts/download_and_extract_rdna.sh` and optional `FASTQ_MAX_SPOTS` for pilots; AoU notebooks are not runnable without that workspace.
