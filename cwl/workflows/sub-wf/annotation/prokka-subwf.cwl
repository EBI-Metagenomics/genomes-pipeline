#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  prokka_input: File
  outdirname: string

outputs:
  gff:
    type: File
    outputSource: prokka/gff
  faa:
    type: File
    outputSource: prokka/faa


steps:

  change_headers:
   run: ../../../utils/cut_header.cwl
   in:
     inputfile: prokka_input
   out: [created_file]

  prokka:
    run: ../../../tools/prokka/prokka.cwl
    in:
      fa_file: change_headers/created_file
      outdirname: outdirname
    out: [ gff, faa ]
