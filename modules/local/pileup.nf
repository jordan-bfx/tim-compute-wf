process PILEUP {
    tag "$meta.cleanName"
    label 'process_high'
    // modkit
    container 'bioinformatics@sha256:a41c475e46b9122e47cbaa10a3d0fd7d7206fe97a61677547f47a666cd97edc2'

    input:
    tuple val(meta), path(aln_cram), path(crai)
    path ref_genome

    output:
    tuple val(meta), path("${meta.cleanName}.bed.gz"), emit: pileup
    path "PILEUP_versions.yml", emit: versions

    script:
    """
    modkit pileup -t ${task.cpus} -r ${ref_genome} --bgzf --cpg ${aln_cram} "${meta.cleanName}.bed.gz" \\
        --modified-bases C:m C:h

cat <<-END_VERSIONS > PILEUP_versions.yml
"${task.process}":
    modkit: \$(modkit --version 2>&1 | head -n1 | sed 's/^.*modkit //; s/ .*\$//')
END_VERSIONS
    """

    stub:
    """
    touch "${meta.cleanName}.bed.gz"

cat <<-END_VERSIONS > PILEUP_versions.yml
"${task.process}":
    modkit: \$(modkit --version 2>&1 | head -n1 | sed 's/^.*modkit //; s/ .*\$//')
END_VERSIONS
    """
}
