process RENAME_FASTA {

    publishDir "${params.outdir}/renamed_genomes", mode: 'copy'

    label 'process_light'

    memory "500 MB"
    cpus 1

    input:
    path genomes
    val start_number
    val max_number
    file check_csv
    // optional
    val prefix

    output:
    path "renamed_genomes", emit: renamed_genomes
    path "name_mapping.tsv", emit: rename_mapping
    path "renamed_*_checkm.txt", emit: renamed_checkm

    script:
    genomes_prefix = prefix ? prefix : "MGYG"
    """
    rename_fasta.py -d ${genomes} \
    -p ${genomes_prefix} \
    -i ${start_number} \
    --max ${max_number} \
    -t name_mapping.tsv \
    -o renamed_genomes \
    --csv ${check_csv}
    """

    stub:
    """
    mkdir renamed_genomes
    touch name_mapping.tsv
    touch renamed_${check_csv.baseName}_checkm.txt
    """
}