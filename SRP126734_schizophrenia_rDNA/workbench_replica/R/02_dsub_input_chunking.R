# Replica: rdna_01_full_extractalign_dsub — write Task_N_input.txt from cram_uri column.
# Requires: df with column cram_uri (and any other columns you want in manifest_df.csv).

suppressPackageStartupMessages({
  library(dplyr)
  library(data.table)
})

prepare_dsub_inputs <- function(df, out_dir = "dsub_files_full", size = 50L) {
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  use_v <- df %>% pull(cram_uri)
  n_chunks <- ceiling(length(use_v) / size)
  split_l <- split(use_v, ceiling(seq_along(use_v) / size))
  names(split_l) <- paste0(out_dir, "/Task_", seq_along(split_l), "_input.txt")
  fwrite(df, file.path(out_dir, "manifest_df.csv"))
  invisible(mapply(function(path, lines) writeLines(lines, path), names(split_l), split_l))
  list(n_chunks = n_chunks, input_files = names(split_l))
}

# Example (commented): AoU manifest
# mani <- fread("data/manifest.csv")
# prepare_dsub_inputs(mani, out_dir = "dsub_files_pilot", size = 10L)
