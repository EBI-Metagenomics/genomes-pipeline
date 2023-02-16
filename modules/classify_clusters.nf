/*
This script does detection and separation of genomes into clusters according drep results.
Script generates clusters_split.txt file with information about each cluster:
    ex:
        many_genomes:1_1:CAJJTO01.fa,CAJKGB01.fa,CAJLGA01.fa
        many_genomes:2_1:CAJKRE01.fa,CAJKXJ01.fa
        one_genome:3_0:CAJKRY01.fa
        one_genome:4_0:CAJKXZ01.fa

If you want to return cluster folders with mash-files - use --create-clusters flag and set -f path
    ex. of output:
        split_outfolder
        - 1_1
            ---- CAJJTO01.fa
            ---- CAJKGB01.fa
            ---- CAJLGA01.fa
            ---- 1_1_mash.tsv
        - 2_1
            ---- CAJKRE01.fa
            ---- CAJKXJ01.fa
            ---- 2_1_mash.tsv
        - 3_0
            ---- CAJKRY01.fa
            ---- 3_0_mash.tsv
        - 4_0
            ---- CAJKRY01.fa
            ---- 4_0_mash.tsv
*/

process CLASSIFY_CLUSTERS {

    publishDir "${params.outdir}/", patter: "pg", mode:"copy"
    publishDir "${params.outdir}/", patter: "sg", mode:"copy"

    label "process_light"

    cpus 1
    memory "1 GB"

    input:
    path genomes_folder
    file text_file

    output:
    path "pg/**/*.fa", emit: many_genomes_fnas
    path "sg/**/*.fa", emit: one_genome_fnas

    script:
    """
    classify_folders.py -g ${genomes_folder} --text-file ${text_file}

    # Clean any empty directories #
    find many_genomes -type d -empty -print -delete
    find one_genome -type d -empty -print -delete

    mv many_genomes pg
    mv one_genome sg
    """
}