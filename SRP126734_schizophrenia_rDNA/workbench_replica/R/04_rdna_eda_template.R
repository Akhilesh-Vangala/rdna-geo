# Replica: rdna_02_EDA — metadata join + rDNA reference as per-base table + idxstats QC.
# AoU paths from screenshots; SRP126734 substitutes noted below.

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
})

# --- AoU paths (screenshots) ---
# mani <- fread("data/manifest.csv")
# metrics <- fread("data/genomic_metrics.tsv")
# anc_df <- fread("data/ancestry_preds.tsv")
# simple_metrics <- metrics %>%
#   transmute(sample = research_id, sample_source, aligned_q30_bases, dragen_sex_ploidy)
# simple_anc <- anc_df %>% transmute(sample = research_id, ancestry_pred)
# simple_meta <- left_join(simple_metrics, simple_anc, by = "sample")

# --- SRP126734 substitute: phenotype + run IDs ---
resolve_study_root <- function() {
  env <- Sys.getenv("SRP126734_ROOT", "")
  if (nzchar(env)) return(env)
  if (file.exists(file.path("data", "run_list.txt"))) return(normalizePath("."))
  if (file.exists(file.path("..", "data", "run_list.txt"))) return(normalizePath(".."))
  if (file.exists(file.path("..", "..", "data", "run_list.txt"))) {
    return(normalizePath(file.path("..", "..")))
  }
  warning("Could not find data/run_list.txt; set SRP126734_ROOT")
  "."
}
study_root <- resolve_study_root()
meta_path <- file.path(study_root, "data", "sample_metadata.tsv")
if (file.exists(meta_path)) {
  sm <- fread(meta_path)
  simple_meta <- sm %>%
    transmute(
      sample = Run,
      phenotype = Phenotype,
      sample_name = Sample_name
    )
}

# --- Reference: screenshot used ref/rdna.fa, width 13365, name seq1 ---
# Install BiocManager::install("Biostrings") on Workbench / local R if needed.
# ref_rdna <- Biostrings::readDNAStringSet("ref/rdna.fa")
# rdna_df <- tibble::tibble(ref = as.character(ref_rdna[[1]])) %>%
#   tidyr::separate_rows(ref, sep = "(?<=.)") %>%  # one row per base — or strsplit
#   mutate(BP = row_number())

# --- Idxstats: screenshot full_aou_hg38_idxstats.tsv.gz ---
# idx_df <- fread("data/full_aou_hg38_idxstats.tsv.gz", nThread = 8)
# idx_df <- dplyr::left_join(idx_df, simple_meta, by = "sample")

# SRP126734 local analogue after bash pipeline: per-run samtools idxstats on hg38 BAM
# (optional; your download script emits rDNA-only BAMs — use samtools flagstat there).
