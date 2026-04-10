# Replica: greedy chunking for balanced dsub tasks (path_01_full_extractalign_dsub).
# Assigns each job size (e.g. CRAM GB) to the current lightest chunk under a per-chunk cap.

greedy_partition_sortable <- function(data_vector, chunk_max_size) {
  if (length(data_vector) == 0) return(list())
  ord <- order(data_vector, decreasing = TRUE)
  sizes <- data_vector[ord]
  chunk_sums <- numeric(0)
  chunks <- list()
  for (s in sizes) {
    if (length(chunk_sums) == 0L) {
      chunks[[1]] <- s
      chunk_sums <- s
      next
    }
    avail <- which(chunk_sums + s <= chunk_max_size)
    if (length(avail) == 0L) {
      k <- length(chunks) + 1L
      chunks[[k]] <- s
      chunk_sums[k] <- s
    } else {
      j <- avail[which.min(chunk_sums[avail])]
      chunks[[j]] <- c(chunks[[j]], s)
      chunk_sums[j] <- chunk_sums[j] + s
    }
  }
  chunks
}
