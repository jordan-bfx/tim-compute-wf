# tim-compute-wf
This pipeline takes a directory of BAM files, merges them with `samtools merge`, then aligns the merged reads to a reference genome. Set `clean_name` to name the aligned CRAM, pileup BED, and QC JSON outputs. Dorado aligns reads with soft clipping for supplementary alignments. Base modifications are summarized using modkit pileup, and the sample is QC'd using samtools flagstat and modkit summary.
```bash
nextflow run . --input_dir <bam_directory> --clean_name <sample_name> --ref_genome <reference.fa>
```

## Testing
Tests use [nf-test](https://www.nf-test.com). Test a small unaligned bam at `nf-test/data/test.bam`. The hg38 reference and its index need to be added to as `nf-test/data/hg38.fa` and `nf-test/data/hg38.fa.fai` (both git-ignored), then:
```bash
nf-test test                     # first run writes nf-test/main.nf.test.snap
nf-test test --update-snapshot   # after an intended output change
```
The test runs using `--input_dir`, `--clean_name`, and `--ref_genome`, just like a regular pipeline run.
