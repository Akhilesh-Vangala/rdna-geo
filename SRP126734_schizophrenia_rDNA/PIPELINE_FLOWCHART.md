# rDNA extraction pipeline — flowchart

Flow of the pipeline: from SRA run list to rDNA-mapping BAMs (and optional variant calling).

---

## Flowchart (Mermaid)

```mermaid
flowchart TD
    subgraph input["Input"]
        A["run_list.txt\n(54 SRR accessions)"]
        B["rDNA reference\n1000_genome_project_referencerDNA.fa"]
    end

    subgraph one["1. Prepare reference"]
        C["bwa index\n(index rDNA reference)"]
    end

    subgraph two["2. Download"]
        D["SRA Toolkit\nprefetch → fasterq-dump"]
        E["FASTQ\n(paired: _1.fastq, _2.fastq)"]
    end

    subgraph three["3. Align to rDNA only"]
        F["bwa mem\n(FASTQ + rDNA reference)"]
        G["SAM stream"]
    end

    subgraph four["4. rDNA BAM"]
        H["samtools view\nsamtools sort"]
        I["Per-run rDNA BAM\n(e.g. SRR6375927_rdna.bam)"]
    end

    subgraph five["5. Optional downstream"]
        J["Variant calling\n(same as All of Us pipeline)"]
        K["VCF\n(merge with phenotype → association / ML)"]
    end

    A --> D
    D --> E
    B --> C
    C --> F
    E --> F
    F --> G
    G --> H
    H --> I
    I --> J
    J --> K

    style A fill:#e8f4fc
    style B fill:#e8f4fc
    style I fill:#c8e6c9
    style K fill:#fff9c4
```

---

## Flow in short

| Step | What happens |
|------|----------------|
| **Input** | `run_list.txt` (SRR IDs) + rDNA reference FASTA. |
| **1** | Index the rDNA reference with BWA (once). |
| **2** | For each SRR: SRA Toolkit → download FASTQ. |
| **3** | Align FASTQ to rDNA reference only (BWA MEM) → SAM. |
| **4** | Convert SAM to sorted BAM → **one rDNA BAM per run** (these are “sequences mapping to the rDNA”). |
| **5** | (Optional) Variant calling on rDNA BAMs → VCF → merge with phenotype for association/ML. |

---

## One-line summary

**run_list.txt → download FASTQ → align to rDNA reference → rDNA BAM (and optionally VCF).**
