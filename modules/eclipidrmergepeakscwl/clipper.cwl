#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 8
    ramMin: 30000


baseCommand: [clipper]


arguments: [
  #--debug,
  --outfile,
  $(inputs.bam.nameroot)Cl.bed
]

inputs:

  species:
    type: string
    inputBinding:
      position: 0
      prefix: --species
    doc: "species: one of ce10 ce11 dm3 hg19 hg19chr19kbp550 GRCh38 mm9 mm10"

  bam:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
      prefix: --bam
    #secondaryFiles:
    #  - ".bai"

  # timeout can not be omitted, default value of None in clipper creates error
  timeout:
    type: string
    # 600 seconds, 10 minutes
    # default: "600"
    # 100 hours, > 4 days
    default: "3600000"
    inputBinding:
      position: 7
      prefix: --timeout

  maxgenes:
    type: string
    #default: "2100"
    default: "1000000"
    inputBinding:
      position: 8
      prefix: --maxgenes

#  gene:
#    type: string
#    default: "ENSG00000202191.1"
#    inputBinding:
#     position: 8
#     prefix: --gene

  savepickle:
    type: boolean
    default: true
    inputBinding:
      position: 9
      prefix: --save-pickle


outputs:


  output_tsv:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)Cl.bed.tsv

  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.bam.nameroot)Cl.bed

  output_pickle:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)Cl.bed.pickle

  output_log:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)Cl.bed.log
      
