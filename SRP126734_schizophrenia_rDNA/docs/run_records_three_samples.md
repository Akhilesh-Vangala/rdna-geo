# SRP126734 — three example runs (for professor summary)

**Status: all three completed** (2026-04-09). Step 1 only; `SKIP_STEP2=true` (no variant calling yet).

## Summary table

| # | SRR | Phenotype (`sample_metadata.tsv`) | rDNA BAM (under `rdna_bams/`) | Reads in BAM (total) | Properly paired |
|---|-----|----------------------------------|--------------------------------|----------------------|-------------------|
| 1 | SRR6375927 | Control | `SRR6375927_rdna.bam` | 237,374 | 166,770 (72.26%) |
| 2 | SRR6375928 | Schizo | `SRR6375928_rdna.bam` | 531,364 | 419,012 (80.65%) |
| 3 | SRR6375931 | Control | `SRR6375931_rdna.bam` | 126,553 | 83,410 (67.86%) |

All three: **100% of reads in the BAM map** to the rDNA reference (pipeline drops unmapped reads before BAM). Counts differ because each library yields a different number of reads that align to this rDNA reference.

## Implementation (what we ran)

- **Study:** SRP126734 (public SRA); cohort table: `data/sample_metadata.tsv`, list: `data/run_list.txt`.
- **Flow:** `prefetch` → `fasterq-dump` from local `.sra` → `bwa mem` to collaborator rDNA FASTA → `samtools sort/index`, `samtools flagstat`.
- **Reference:** `geo scripts/1000_genome_new_ref_v3_string (1).fasta` (path on lab machine).
- **Per-run logs:** `logs/SRR6375927.log`, `logs/SRR6375928.log`, `logs/SRR6375931.log` (local; may be gitignored).

## Flagstat excerpts (from logs)

**SRR6375927:** 237,374 in total; 237,374 mapped (100%); 166,770 properly paired (72.26%); 63,422 singletons (27.48%).

**SRR6375928:** 531,364 in total; 531,364 mapped (100%); 419,012 properly paired (80.65%); 100,131 singletons (19.27%).

**SRR6375931:** 126,553 in total; 126,553 mapped (100%); 83,410 properly paired (67.86%); 38,761 singletons (31.54%).

## First run — desired result?

**Yes.** The professor’s first ask was to show that **sequences mapping to rDNA** can be obtained from SRP126734. Each run produces an **rDNA-only BAM** and **mapping statistics**; that satisfies the **download / extract / align** milestone. Variant calling is **follow-up**.

See also: `docs/run_record_SRR6375927.md` (first-run detail).
