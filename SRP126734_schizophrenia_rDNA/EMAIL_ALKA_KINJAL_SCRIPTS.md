# Email: Scripts from Alka and Kinjal (rDNA extraction)

**From Andreas (to Alka, Kinjal, Narayani, Akhilesh):**

> Hi Alka and Kinjal,
> I just spoke with Narayani and Akhilesh about also doing some rDNA analysis **outside of All of Us**. You mentioned that the **workspace of our collaborators has all the script they used to extract the rDNA data and build their dataset**. Could you please **copy those scripts and send them to Narayani and Akhilesh**, so they can familiarize themselves with the approach and then **adapt this approach to also access rDNA sequencing data from other publicly available datasets**?
>
> Also, to everybody, I just realized that it is spring break next week, so please let me know if you want to meet next week or not.
> Thank you!!
> Best,
> Andreas

**What this means for us (Narayani & Akhilesh):**

- We are doing rDNA analysis **outside of All of Us** as well (e.g. public datasets like SRP126734).
- **Alka and Kinjal** will send us the **scripts their collaborators used** to extract rDNA and build the dataset (likely the same pipeline we’ve been referring to: align to rDNA reference, maybe variant calling, etc.).
- Our job: **familiarize ourselves** with that approach and **adapt it** to get rDNA from **other publicly available datasets** (SRA, GEO, etc.).

**How that fits this folder:**

- The script we have here (`download_and_extract_rdna.sh`) is a **minimal, generic** version: SRA → FASTQ → BWA to rDNA reference → BAM. It was written without access to the collaborators’ actual scripts.
- **Once we have Alka/Kinjal’s scripts**, we should:
  1. Use them as the **source of truth** for tools, parameters, reference handling, and any filtering/steps that run at scale.
  2. **Adapt** those scripts (or their logic) to public data: e.g. input = SRA run or FASTQ instead of All of Us CRAM; same rDNA reference and downstream steps where possible.
  3. Run the adapted pipeline on SRP126734 (and other public datasets) so we’re aligned with the lab’s established approach.

**Status:** Waiting on scripts from Alka and Kinjal. Once received, we’ll compare with this folder’s pipeline and document any differences and adaptations.
