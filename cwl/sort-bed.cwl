#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1

hints:
  - class: DockerRequirement
    dockerPull: brianyee/bedtools:2.27.1
    
baseCommand: [sort]

arguments: [
  "-k1,1",
  "-k2,2n"
  ]

inputs:

  unsorted_bed:
    type: File
    inputBinding:
      position: 1

stdout: $(inputs.unsorted_bed.nameroot).sorted.bed

outputs:

  sorted_bed:
    type: File
    outputBinding:
      glob: $(inputs.unsorted_bed.nameroot).sorted.bed

doc: |
  This tool wraps unix sort to sort a BED file.
  
  Usage: sort -k1,1 -k2,2n unsorted.bed > sorted.bed
