process EGGNOG_DOWNLOAD {
    tag '$meta.id'
    label 'process_low'

    conda (params.enable_conda ? "bioconda::eggnog-mapper=2.1.6" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/eggnog-mapper:2.1.6--pyhdfd78af_0':
        'quay.io/biocontainers/eggnog-mapper:2.1.6--pyhdfd78af_0' }"

    output:
    path("./eggnog")     , emit: db
    path("*.dmnd")       , emit: proteins, optional: true
    path("hmmer/")       , emit: hmmer   , optional: true
    path("mmseqs/")      , emit: mmseqs  , optional: true
    path("pfam/")        , emit: pfam    , optional: true
    path "versions.yml"  , emit: versions

    script:
    def args = task.ext.args ?: ''

    """
    mkdir eggnog

    download_eggnog_data.py \\
        $args \\
        -y \\
        --data_dir ./eggnog/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eggnog: \$( echo \$(emapper.py --version 2>&1)| sed 's/.* emapper-//' )
    END_VERSIONS

    """

    stub:

    """

    touch ./eggnog/eggnog.db.gz
    unpigz -c ./eggnog/eggnog.db.gz >./eggnog/eggnog.db
    touch ./eggnog/eggnog.taxa.db
    touch ./eggnog/eggnog.taxa.db.traverse.pkl

    cp ./eggnog/* ./

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eggnog: \$( echo \$(emapper.py --version 2>&1)| sed 's/.* emapper-//' )
    END_VERSIONS

    """
}