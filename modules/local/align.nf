process ALIGN {
    tag "$meta.cleanName"
    label 'process_high'
    // Combined local image: Dorado, samtools, and modkit.
    container 'tim-compute-wf-tools:2026.11'

    input:
    tuple val(meta), path(input_bams)
    path ref_genome

    output:
    tuple val(meta), path("${meta.cleanName}.aln.sorted.cram"), path("${meta.cleanName}.aln.sorted.cram.crai"), emit: aligned_cram
    path "ALIGN_versions.yml", emit: versions

    script:
    """
    samtools merge -f -@ ${task.cpus} "${meta.cleanName}.merged.bam" ${input_bams}

    dorado aligner --threads ${task.cpus} -Y \\
        ${ref_genome} \\
        "${meta.cleanName}.merged.bam" | \\
    samtools sort -@ ${task.cpus} --reference ${ref_genome} -o \\
    "${meta.cleanName}.aln.sorted.cram"

    samtools index -@ ${task.cpus} "${meta.cleanName}.aln.sorted.cram"

cat <<-END_VERSIONS > ALIGN_versions.yml
"${task.process}":
    dorado: \$(echo \$(dorado --version 2>&1) | sed 's/^.*dorado //; s/Using.*\$//')
    samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
END_VERSIONS
    """

    stub:
    """
    touch "${meta.cleanName}.aln.sorted.cram"
    touch "${meta.cleanName}.aln.sorted.cram.crai"
    
cat <<-END_VERSIONS > ALIGN_versions.yml
"${task.process}":
    dorado: \$(dorado --version 2>&1 | head -n1 | sed 's/^.*dorado //; s/ .*\$//')
    samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
END_VERSIONS
    """
}
