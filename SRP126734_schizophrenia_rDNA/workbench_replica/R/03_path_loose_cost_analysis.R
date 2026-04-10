# Replica: path_loose_analysis — timing + cost from dsub stdout logs in WORKSPACE_BUCKET.

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(lubridate)
})

to_min <- function(sec) seconds(sec) / 60

vm_costs <- c(
  `n4-standard-2` = 0.094772,
  `n4-standard-4` = 0.189544,
  `n4-standard-8` = 0.379088
)

#' @param gsutil_cmd shell command that prints log lines (e.g. gsutil cat 'gs://.../*-stdout.log')
parse_timing_logs <- function(gsutil_cmd, pilot_dir = "dsub_files_pilot") {
  top_g <- system(gsutil_cmd, intern = TRUE)
  top_g <- grep("_time", top_g, value = TRUE)
  # Downstream: parse timestamps, join to task names from list.files(pilot_dir, '_input.txt')
  list(raw_lines = top_g, vm_costs = vm_costs)
}

# Example (commented):
# wb <- Sys.getenv("WORKSPACE_BUCKET")
# cmd <- sprintf("gsutil cat '%s/rdna/logging_pilot_v2/*-stdout.log' 2>/dev/null", wb)
# parse_timing_logs(cmd)
