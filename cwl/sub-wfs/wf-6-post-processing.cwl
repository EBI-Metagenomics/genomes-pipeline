#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

doc: |
  - kegg, cog, ..
  - ncRNA
  - add annotations to gffs
  - genome.json


requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

  annotations: File[]
  kegg: File
  clusters: Directory[]
  biom: string
  metadata: File?
  claninfo_ncrna: File
  models_ncrna:
    type: File
    secondaryFiles:
      - .i1f
      - .i1i
      - .i1m
      - .i1p

outputs:
  annotations_cluster_dir:
    type: Directory[]
    outputSource: process_folders/final_folder

  annotated_gffs:
    type: File[]
    outputSource: process_folders/annotated_gff

steps:

  choose_annotations:
    doc: |
      input: list of all IPS and EggNOGs
      ex: MGYG000296485_InterProScan.tsv, MGYG000296486_eggNOG.tsv, ....)
      goal: get corresponding annotations for each MGYG cluster
    run: ../utils/get_file_pattern.cwl
    scatter: pattern
    in:
      list_files: annotations
      pattern:
        source: clusters
        valueFrom: $(self.basename)
    out: [ file_pattern ]  # File[]

  process_folders:
    doc: |
      For each cluster run post-processing:
      - kegg
      - ncRNA
      - gff annotation
      - json generation
    run: 6_post-processing/genome-post-processing.cwl
    scatter: [annotations, cluster]
    scatterMethod: dotproduct
    in:
      annotations: choose_annotations/file_pattern
      kegg: kegg
      cluster: clusters
      biom: biom
      metadata: metadata
      claninfo_ncrna: claninfo_ncrna
      models_ncrna: models_ncrna
    out:
      - final_folder  # Dir
      - annotated_gff # File