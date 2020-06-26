#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1

hints:
  - class: DockerRequirement
    dockerPull: brianyee/makebigwigfiles:0.0.3

baseCommand: [makebigwigfiles]

arguments: [
  --bw_pos,
  $(inputs.bam.nameroot).norm.pos.bw,
  --bw_neg,
  $(inputs.bam.nameroot).norm.neg.bw
  ]

inputs:

  bam:
     type: File
     inputBinding:
       position: 1
       prefix: --bam
     secondaryFiles: [.bai]

  chromsizes:
    type: File
    inputBinding:
      position: 3
      prefix: --genome

outputs:

  posbw:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).norm.pos.bw

  negbw:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).norm.neg.bw

doc: |
  Creates strand-specific bigwig files from a BAM file.
  See original script here: https://github.com/YeoLab/gscripts/blob/master/gscripts/general/make_bigwig_files_pe.py
    Usage: makebigwigfiles --bam BAM --genome GENOME --dont_flip --bw_pos --bw_neg
