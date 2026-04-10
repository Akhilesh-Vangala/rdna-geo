# SRP126734 — successful run record (SRR6375927)

End-to-end **SRA → rDNA BAM** on the public trial dataset (Professor Hochwagen GEO ask: obtain reads mapping to rDNA).

## Run

| Field | Value |
|--------|--------|
| Date (local log) | 2026-04-09 |
| SRA run | `SRR6375927` |
| Study | SRP126734 (see `data/run_list.txt`, `data/sample_metadata.tsv`) |
| rDNA reference | `geo scripts/1000_genome_new_ref_v3_string (1).fasta` (path used on this machine) |

## Command pattern used

- `USE_PREFETCH=true` — used prefetched `.sra` under `sra_cache/` when present  
- `SKIP_STEP2=true` — variant calling not run (`variant_calling.sh` still stub)  
- Full extraction for this run (no `FASTQ_MAX_SPOTS` for this successful full pass)  
- Tools: Homebrew `prefetch`, `fasterq-dump`, `bwa`, `samtools`

## Outputs (on disk; large files are gitignored)

| Output | Path (relative to study root `SRP126734_schizophrenia_rDNA/`) |
|--------|----------------------------------------------------------------|
| rDNA BAM | `rdna_bams/SRR6375927_rdna.bam` (+ `.bai`) |
| Per-run log | `logs/SRR6375927.log` |
| Pipeline log | `logs/pipeline_*.log` |

## Mapping stats (from pipeline log, `samtools flagstat`)

- **Total reads in BAM:** 237,374 (QC-passed; aligned to rDNA reference only in this pipeline)  
- **Mapped:** 237,374 (100.00% of reads in this BAM)  
- **Properly paired:** 166,770 (72.26%)  
- **Singletons:** 63,422 (27.48%)  

Note: FASTQ files were removed after alignment (`KEEP_FASTQ` default) to save space.

## Status

**Step 1 complete** for this accession. Step 2 (variants) deferred until lab/collaborator workflow is integrated.
