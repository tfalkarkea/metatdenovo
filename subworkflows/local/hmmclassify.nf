include { HMMER_HMMSEARCH } from '../../modules/nf-core/hmmer/hmmsearch/main'
include { HMMRANK         } from '../../modules/local/hmmrank'

workflow HMMCLASSIFY {

    take:
    ch_hmmclassify // channel: [ val(meta), [ hmm, aa_fasta ] ]

    main:
    ch_versions = Channel.empty()

    HMMER_HMMSEARCH ( 
        ch_hmmclassify
            .map { [ [ id: "${it[0].id}.${it[1].baseName}" ], it[1], it[2], false, true, false ] }
    )
    ch_versions = ch_versions.mix(HMMER_HMMSEARCH.out.versions.first())

    HMMRANK (
        ch_hmmclassify
            .map { it[0] }
            .distinct()
            .combine ( HMMER_HMMSEARCH.out.target_summary.collect { it[1] } )
            .map { [ it[0], [ it[1] ] ] }
    )
    ch_versions = ch_versions.mix(HMMRANK.out.versions)

    emit:
    HMMRANK.out.hmmrank

    versions = ch_versions                     // channel: [ versions.yml ]
}

