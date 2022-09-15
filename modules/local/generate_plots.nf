process GENERATE_PLOTS {

    tag "Benchmark of the spiked-in somatic variants on sample: ${meta[0].sample}"
    label 'process_low'

    container "aldosr/neat:3.2"

    input:
    val(meta)

    output:
    path("*.xlsx")   , emit: benchmark
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: ""
    
    """
    benchmark.py \\
        -n ${meta[0].vcf}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        
    END_VERSIONS
    """
}