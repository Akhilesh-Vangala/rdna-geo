# Full screenshot text extract

- **File:** `SCREENSHOT_OCR_FULL.txt` (~8k lines) — Tesseract OCR of **every** PNG in `rna/geo scripts`, `geo scripts 2`, `geo scripts 3`, `geo scripts 4`.
- **Regenerate:** from repo root,
  ```bash
  ./geo/SRP126734_schizophrenia_rDNA/scripts/ocr_geo_screenshots.sh
  ```
- **Caveats:** Jupyter UI chrome, fonts, and fuzzy characters produce errors (e.g. `§`, `lrUs`, `us-centrall`). Use alongside the PNGs and the curated replicas in `R/` and `python/`.
- **Index:** see `NOTEBOOK_INDEX_FROM_OCR.md`.
