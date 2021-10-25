#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

doc: |
  - per-genome annotation
  - add annotations to gffs

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  kegg: File
  species_representatives: File
  ips: File
  eggnog: File
???   protein_fasta: File

outputs:
  :
    type: File
    outputSource: unite_folders/csv


steps:

# ----------- << per genome annotation >> -----------
  generate_per_genome_annotations:
    run: ../tools/genomes-catalog-update/per_genome_annotations/make_per_genome_annotations.cwl
    in:
      ips: ips
      eggnog: eggnog
      species_representatives: species_representatives

      outdirname: {default: per-genome-annotations }
    out: [ per_genome_annotations ]

  function_summary_stats:
    run: ../tools/genomes-catalog-update/function_summary_stats/generate_annots.cwl
    in:
      ips: ips
      eggnog: eggnog
      output: { default: func_summary }
      protein_fasta:
      kegg_db: kegg

