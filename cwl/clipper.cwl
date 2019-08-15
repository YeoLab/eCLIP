#!/usr/bin/env cwltool

### doc: "clipper cwl tool (https://github.com/yeolab/clipper)" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 8
    coresMax: 16
    ramMin: 32000

baseCommand: [clipper]

# hints:
#   DockerRequirement:
#     dockerPull: brianyee/clipper

inputs:

  species:
    type: string
    # default: hg19
    inputBinding:
      position: 0
      prefix: --species
    doc: "species: one of ce10 ce11 dm3 hg19 GRCh38 mm9 mm10"

  bam:
    type: File
    # format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
      prefix: --bam
    #secondaryFiles:
    #  - ".bai"

  # timeout can not be omitted, default value of None in clipper creates error
  # timeout:
  #   type: string
  #   # 600 seconds, 10 minutes
  #   # default: "600"
  #   # 100 hours, > 4 days
  #   default: "3600000"
  #   inputBinding:
  #     position: 7
  #     prefix: --timeout

  # maxgenes:
  #   type: string
  #   #default: "2100"
  #   default: "1000000"
  #   inputBinding:
  #     position: 8
  #     prefix: --maxgenes

  gene:
    type: string?
    inputBinding:
     position: 8
     prefix: --gene

  savepickle:
    type: boolean
    default: true
    inputBinding:
      position: 9
      prefix: --save-pickle

  outfile:
    type: string
    default: ""
    inputBinding:
      position: 10
      prefix: --outfile
      valueFrom: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + ".peakClusters.bed";
          }
          else {
            return inputs.outfile;
          }
        }

outputs:
  output_tsv:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + ".peakClusters.bed.tsv";
          }
          else {
            return inputs.outfile + ".tsv";
          }
        }
  output_bed:
    type: File
    # format: http://edamontology.org/format_3003
    outputBinding:
      glob: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + ".peakClusters.bed";
          }
          else {
            return inputs.outfile;
          }
        }
  output_pickle:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + ".peakClusters.bed.pickle";
          }
          else {
            return inputs.outfile + ".pickle";
          }
        }

doc: |
  CLIPper is a tool to define peaks in your CLIP-seq dataset.
  CLIPper was developed in the Yeo Lab at the University of California, San Diego.
    Usage: clipper --bam CLIP-seq_reads.srt.bam --species hg19 --outfile CLIP-seq_reads.srt.peaks.bed
