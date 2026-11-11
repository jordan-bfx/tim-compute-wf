include { ALIGN }        from './modules/local/align'
include { PILEUP }       from './modules/local/pileup'
include { QC }           from './modules/local/qc'


workflow {
    main:
    ch_versions = Channel.empty()

    input_bam = file(params.input_bam, checkIfExists: true)
    ch_sample = Channel.of(tuple([cleanName: input_bam.simpleName], input_bam))

    ALIGN(ch_sample, params.ref_genome)
    ch_versions = ch_versions.mix(ALIGN.out.versions)

    PILEUP(ALIGN.out.aligned_cram, params.ref_genome)
    ch_versions = ch_versions.mix(PILEUP.out.versions)

    QC(ALIGN.out.aligned_cram, params.ref_genome)
    ch_versions = ch_versions.mix(QC.out.versions)
}
