process BWA_INDEX {
    tag "$fasta"
    label 'process_single'

    conda "conda-forge::python=2.7.15 bioconda::bwa=0.7.17 bioconda::samtools=1.9 conda-forge::numpy=1.14.3 conda-forge::scipy=1.1.0 bioconda::pysam=0.15.0 bioconda::bedtools=2.27.1"
    container "docker.io/eshajoshi/l1em_test:latest"

    input:
    tuple val(meta), path(fasta)
    path l1em_bed, stageAs: "bwa_index/l1em/*"

    output:
    tuple val(meta), path('bwa_index'), emit: index
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkdir -p bwa_index/full
    bwa \\
        index \\
        $args \\
        -p bwa_index/full/$fasta \\
        $fasta
    
    ## Manually run commands in script below to be flexible with other genomes:
    ## https://github.com/FenyoLab/L1EM/blob/8a4c9ee1ce62273a28cd43fc7bf49da1ad0dc673/generate_L1EM_fasta_and_index.sh#L10-L11
    bedtools \\
        getfasta \\
        -s \\
        -name \\
        -fi $fasta \\
        -bed $l1em_bed > bwa_index/l1em/L1EM.400.fa

    cd bwa_index/l1em
    bwa \\
        index \\
        $args \\
        L1EM.400.fa

    cd ../../

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
    END_VERSIONS
    """
}
