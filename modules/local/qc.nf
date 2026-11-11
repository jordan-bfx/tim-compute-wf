process QC {
    tag "$meta.cleanName"
    label 'process_medium'
    // Combined local image: Dorado, samtools, and modkit.
    container 'tim-compute-wf-tools:2026.11'

    input:
    tuple val(meta), path(aln_cram), path(crai)
    path ref_genome

    output:
    tuple val(meta), path("${meta.cleanName}.stats.json"), emit: sample_info
    path "QC_versions.yml", emit: versions

    script:
    """
    {
        printf '{"flagstat": '
        samtools flagstat -@ ${task.cpus} -O json "${aln_cram}"
        printf ', "modkit_summary": '
        modkit summary -t ${task.cpus} -r ${ref_genome} --cpg "${aln_cram}" | awk '
            # "# key value" lines become fields, the table becomes "mods"
            function v(x) { return x ~ /^-?[0-9]+(\\.[0-9]+)?([eE][-+]?[0-9]+)?\$/ ? x : "\\"" x "\\"" }
            # modkit prints its comma lists (bases, modification codes) in a different order on every run
            function sorted(s,    a, n, i, j, t) {
                n = split(s, a, ",")
                for (i = 2; i <= n; i++) for (j = i; j > 1 && a[j-1] > a[j]; j--) { t = a[j]; a[j] = a[j-1]; a[j-1] = t }
                s = a[1]; for (i = 2; i <= n; i++) s = s "," a[i]
                return s
            }
            BEGIN { printf "{" }
            /^#/  { printf "%s\\"%s\\": %s", sep, \$2, v(sorted(\$3)); sep = ", "; next }
            !NF || /^>/ { next }
            !n    { n = split(\$0, h); printf "%s\\"mods\\": [", sep; sep = ""; next }
            {
                printf "%s{", sep
                for (i = 1; i <= n; i++) printf "%s\\"%s\\": %s", (i > 1 ? ", " : ""), h[i], (i <= 2 ? "\\"" \$i "\\"" : v(\$i))  # base and code stay strings
                printf "}"; sep = ", "
            }
            END   { print (n ? "]" : "") "}" }'
        printf '}\\n'
    } > "${meta.cleanName}.stats.json"

    # Versions fragment
    cat <<-END_VERSIONS > QC_versions.yml
    ${task.process}:
        samtools: \$(samtools --version 2>&1 | head -n1)
        modkit: \$(modkit --version 2>&1 | head -n1 | sed 's/^.*modkit //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    """
    touch "${meta.cleanName}.stats.json"

    cat <<-END_VERSIONS > QC_versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        modkit: \$(modkit --version 2>&1 | head -n1 | sed 's/^.*modkit //; s/ .*\$//')
    END_VERSIONS
    """
}
