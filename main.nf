include { ALIGN }        from './modules/local/align'
include { PILEUP }       from './modules/local/pileup'
include { QC }           from './modules/local/qc'


workflow {
    main:
    ch_versions = Channel.empty()

    input_dir = file(params.input_dir, checkIfExists: true)
    ch_bams = Channel.fromPath("${input_dir}/*.bam", checkIfExists: true)
        .ifEmpty { error "No BAM files found in input directory: ${input_dir}" }
        .collect()
        .map { input_bams -> tuple([cleanName: params.clean_name], input_bams) }

    ALIGN(ch_bams, params.ref_genome)
    ch_versions = ch_versions.mix(ALIGN.out.versions)

    PILEUP(ALIGN.out.aligned_cram, params.ref_genome)
    ch_versions = ch_versions.mix(PILEUP.out.versions)

    QC(ALIGN.out.aligned_cram, params.ref_genome)
    ch_versions = ch_versions.mix(QC.out.versions)
}
