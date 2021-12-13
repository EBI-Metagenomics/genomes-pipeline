#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  many_genomes: Directory[]?
  mash_folder: File[]?          # for many_genomes
  one_genome: Directory[]?
  mmseqs_limit_c: float         # common
  mmseqs_limit_i: float[]       # common
  mmseq_limit_annotation: float
  csv: File
  gunc_db_path: File

outputs:

  pangenomes:
    type: Directory[]?
    outputSource: process_many_genomes/pangenome_clusters
  pangenomes_initial_fa:
    type: File[]
    outputSource: process_many_genomes/initial_genomes_fa-s


  singletons:
    type: Directory[]?
    outputSource: process_one_genome/cluster_folder
  singletons_gunc_completed:
    type: File
    outputSource: process_one_genome/gunc_completed
  singletons_gunc_failed:
    type: File
    outputSource: process_one_genome/gunc_failed
  singletons_filtered_initial_fa:
    type: File[]?
    outputSource: process_one_genome/filtered_initial_fa-s


  panaroo_folder:
    type: Directory
    outputSource: process_many_genomes/panaroo_output

#  gffs_list:
#    type: File[]
#    outputSource:
#      source:
#        - process_many_genomes/prokka_gffs  # File[]
#        - process_one_genome/prokka_gff-s   # File[]
#      linkMerge: merge_flatten

  mmseqs_output:
    type: Directory?
    outputSource: mmseqs/mmseqs_dir
  cluster_representatives:
    type: File?
    outputSource: mmseqs/cluster_reps
  cluster_tsv:
    type: File?
    outputSource: mmseqs/cluster_tsv

  all_main_reps_faa_pangenomes:
    type: File[]?
    outputSource: process_many_genomes/main_reps_faa

  all_main_reps_gff_pangenomes:
    type: File[]?
    outputSource: process_many_genomes/main_reps_gff

  all_gffs_pangenomes:
    type: File[]
    outputSource: process_many_genomes/prokka_gffs

  all_main_reps_faa_singletons:
    type: File[]?
    outputSource: process_one_genome/prokka_faa-s

  all_main_reps_gff_singletons:
    type: File[]?
    outputSource: process_one_genome/prokka_gff-s

  all_core_genes:
    type: File[]
    outputSource: process_many_genomes/core_genes_files
  all_pangenome_fna:
    type: File[]
    outputSource: process_many_genomes/pangenome_fnas

steps:

# ----------- << mash trees >> -----------
  process_mash:
    scatter: input_mash
    run: ../../../tools/mash2nwk/mash2nwk.cwl
    in:
      input_mash: mash_folder
    out: [mash_tree]  # File[]

# ----------- << many genomes cluster processing >> -----------
  process_many_genomes:
    when: $(Boolean(inputs.input_clusters))
    run: pan-genomes/wrapper-pan-genomes.cwl
    in:
      input_clusters: many_genomes
      mash_folder: process_mash/mash_tree
    out:
      - prokka_seqs
      - pangenome_clusters
      - prokka_gffs
      - panaroo_output  # Dir
      - initial_genomes_fa-s  # File[]
      - main_reps_gff
      - main_reps_faa
      - core_genes_files
      - pangenome_fnas

# ----------- << one genome cluster processing >> -----------
  process_one_genome:
    when: $(Boolean(inputs.input_cluster))
    run: singletons/wrapper-singletons.cwl
    in:
      input_cluster: one_genome
      csv: csv
      gunc_db_path: gunc_db_path
    out:
      - prokka_faa-s
      - prokka_gff-s
      - cluster_folder
      - gunc_completed
      - gunc_failed
      - filtered_initial_fa-s  # File[]?

# ----------- << mmseqs subwf>> -----------
#  filter_nulls_prokka_singletones:
#    run: ../../../utils/filter_nulls.cwl
#    in:
#      list_files: process_one_genome/prokka_faa-s
#    out: [ out_files ]

  mmseqs:
    run: mmseq-subwf.cwl
    in:
      prokka_many: process_many_genomes/prokka_seqs
      prokka_one: process_one_genome/prokka_faa-s  #filter_nulls_prokka_singletones/out_files
      mmseqs_limit_i: mmseqs_limit_i
      mmseqs_limit_c: mmseqs_limit_c
      mmseq_limit_annotation: mmseq_limit_annotation
    out:
      - mmseqs_dir
      - cluster_reps
      - cluster_tsv
