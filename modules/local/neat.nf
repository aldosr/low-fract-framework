process NEAT {
    tag "Create artificial normal datasets for sample: ${meta.sample}"
    label 'process_high'

    input:
    val meta
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
    tuple val(meta), path("*.vcf.gz")                    , emit: vcf
    //tuple val(meta), path("*.tbi")        , emit: tbi
    tuple val(meta), path("*.bam")                       , emit: bam
    tuple val(meta), path("*.yml")                       , emit: versions
    

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${task.process.tokenize(':')[-1].tokenize('_')[0].toLowerCase()}_${meta.sample}"
    def version = '3.2' //VERSION IS HARDCODED

    """
    touch ${prefix}
    touch ${prefix}


    cat <<-END_VERSIONS > "${prefix}.versions.yml"
    "${task.process}":
        ncsa/NEAT: 'Version $version'
        GC bias model: $gcbiasmodel
        Bed used: $bed
        Mutational model: $mutmodel  
        FASTA: $fasta
        Sequencing error model: $seqerrormodel
        Frag length model: $fraglenmodel
        Coverage: $coverage
        Read length: $readlen
        Meta: $meta
    END_VERSIONS
     """

    stub:
    def prefix = task.ext.prefix ?: "${task.process}.toLowerCase()_${meta.sample}"
    """
    touch ${prefix}.vcf.gz
    touch ${prefix}.vcf.gz.tbi
    touch ${prefix}.bam
    python3 ${neat_path}/gen_reads.py \\
        $args \\
        -r $fasta \\
        -R $readlen \\
        --pe-model $fraglenmodel \\
        -c $coverage \\
        -e $seqerrormodel \\
        --gc-model $gcbiasmodel \\
        -tr $bed \\
        -m $mutmodel \\
        -o $prefix
    cat <<-END_VERSIONS > "${prefix}.versions.yml"
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
