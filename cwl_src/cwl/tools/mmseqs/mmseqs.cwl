#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 150000
    coresMin: 32
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}

hints:
  DockerRequirement:
    dockerPull: "quay.io/microbiome-informatics/genomes-pipeline.mmseqs:v2"

baseCommand: [ mmseqs_wf.sh ]

arguments:
  - valueFrom: '32'
    prefix: -t
  - valueFrom: mmseqs_$(inputs.limit_i)_outdir
    prefix: -o

inputs:
  input_fasta:
    type: File
    inputBinding:
      prefix: '-f'

  limit_i:
    type: float
    inputBinding:
      prefix: -i
  limit_c:
    type: float
    inputBinding:
      prefix: -c

stderr: stderr_mmseqs.txt
stdout: stdout_mmseqs.txt

outputs:
  stderr: stderr
  stdout: stdout

  outdir:
    type: Directory
    outputBinding:
      glob: mmseqs_$(inputs.limit_i)_outdir
  faa:
    type: File
    outputBinding:
      glob: mmseqs_$(inputs.limit_i)_outdir/mmseqs_cluster_rep.fa

  mmseq_cluster_tsv:
    type: File
    outputBinding:
      glob: mmseqs_$(inputs.limit_i)_outdir/mmseqs_cluster.tsv