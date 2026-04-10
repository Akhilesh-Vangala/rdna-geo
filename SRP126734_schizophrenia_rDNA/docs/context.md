# Context

## Objective

Extract reads that map to the rDNA reference from SRP126734 WGS: SRA download, alignment to a lab-provided rDNA FASTA, rDNA BAMs and mapping statistics; optional per-run VCFs.

## Dataset

- **SRP126734** = GSE108065. 54 WGS runs (29 schizophrenia, 25 controls). Illumina HiSeq X Ten, paired-end. Public on NCBI SRA.
- **Run list:** `data/run_list.txt`
- **Sample metadata:** `data/sample_metadata.tsv`

## Data access

Reads are fetched with SRA Toolkit (`fasterq-dump` / `fastq-dump`) using IDs in `run_list.txt`. No API key. Set **`RDNA_REF`** to the rDNA FASTA used for alignment (must match lab reference policy).

## Pipeline

- **Steps 1–4:** `scripts/download_and_extract_rdna.sh` — SRA → FASTQ → BWA → sorted, indexed BAMs in `rdna_bams/`.
- **Step 5:** `scripts/variant_calling.sh` — default **bcftools**; optional **GATK** via `VARIANT_CALLER=gatk`.
- **Orchestration:** `scripts/run_pipeline.sh`.

Lab-specific callers (e.g. mgatk) are not included; extend `variant_calling.sh` if required.
