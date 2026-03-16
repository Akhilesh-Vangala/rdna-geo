# Context and requirements

## Goal

Professor’s ask: determine whether we can specifically obtain the sequences mapping to the rDNA for SRP126734. Deliverable: download SRA runs, align to rDNA reference only, produce rDNA BAMs and report read counts.

## Dataset

- SRP126734 = GSE108065. 54 WGS runs (29 schizophrenia, 25 controls). Illumina HiSeq X Ten, paired-end. Public on NCBI SRA.
- Run list: `data/run_list.txt`. Sample and phenotype mapping: `data/sample_metadata.tsv`.

## Data access

Raw data lives on NCBI SRA. Connection: run IDs in `data/run_list.txt` plus SRA Toolkit (`fasterq-dump`). No API key; public access. Scripts use these IDs to fetch FASTQ and then align to the rDNA reference.

## Requirements and status

- Dataset and run list: done. Phenotypes filled from GSE108065.
- Pipeline scripts: done. rDNA reference and collaborator variant-calling scripts: pending (obtain from Alka/Kinjal per professor’s request). Pipeline not yet run on data.

## Collaborator scripts

Professor asked Alka and Kinjal to share the collaborators’ rDNA extraction/variant-calling scripts so this workflow can be aligned with the lab pipeline. Once received, integrate variant-calling steps into `scripts/variant_calling.sh`.
