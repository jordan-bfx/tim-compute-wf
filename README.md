# Renew-Methylome
This pipeline takes an input BAM and a reference genome. It uses the BAM filename stem for the aligned CRAM, pileup BED, and QC JSON filenames. Dorado aligns reads with soft clipping for supplementary alignments. Base modifications are summarized using modkit pileup, and the sample is QC'd using samtools flagstat and modkit summary.
```bash
nextflow run . --input_bam <input.bam> --ref_genome <reference.fa>
```

## Testing
Tests use [nf-test](https://www.nf-test.com). Put a small unaligned bam at `nf-test/data/test.bam` and a reference at `nf-test/data/genome.fa` (both git-ignored), then:
```bash
nf-test test                     # first run writes nf-test/main.nf.test.snap
nf-test test --update-snapshot   # after an intended output change
```
The test runs using `--input_bam` and `--ref_genome`, just like a regular pipeline run.
