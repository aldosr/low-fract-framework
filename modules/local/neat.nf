process NEAT {
    tag "Create artificial normal datasets"
    label 'process_high'

    input:
    tuple val(meta), val(info)
    val rng
    val readlen
    val coverage
    path bed
    path fasta
    path neat_path
    path fraglenmodel
    path seqerrormodel
    path mutmodel
    path gcbiasmodel

    output:
    tuple val(meta), path("*.vcf.gz")     , emit: vcf
    tuple val(meta), path("*.tbi")        , emit: tbi
    tuple val(meta), path("*.bam")        , emit: bam
    val   rng                             , emit: rng
    path "versions.yml"                   , emit: versions
    

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "neat"
    def version = '3.2' //VERSION IS HARDCODED

    """
    python3 ${neat_path}/gen_reads.py \\
        $args \\
        -r $fasta \\
        -R $readlen \\
        --pe-model $fraglenmodel \\
        -c $coverage \\
        -e $seqerrormodel \\
        --gc-model $gcbiasmodel \\
        -tr $bed \\
        --rng $rng \\
        -m $mutmodel \\
        -o $prefix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ncsa/NEAT: 'Version $version'
        GC bias model: $gcbiasmodel
        Bed used: $bed
        Mutational model: $mutmodel
        Mutational rate: none   
        FASTA: $fasta
        Sequencing error model: $seqerrormodel
        Frag length model: $fraglenmodel
        Coverage: $coverage
        Read length: $readlen
        RNG: $rng
        META: $meta
        TEST: $RANDOM
    END_VERSIONS
     """

    stub:
    def prefix = task.ext.prefix ?: "neat"
    """
    touch ${prefix}.vcf.gz
    touch ${prefix}.vcf.gz.tbi
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ncsa/NEAT: 'Version $version'
        GC bias model: $gcbiasmodel
        Bed used: $bed
        Mutational model: $mutmodel
        Mutational rate: none   
        FASTA: $fasta
        Sequencing error model: $seqerrormodel
        Frag length model: $fraglenmodel
        Coverage: $coverage
        Read length: $readlen
    END_VERSIONS
    """
}
