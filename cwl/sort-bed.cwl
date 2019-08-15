#!/usr/bin/env cwltool

### Sorts a BED file ###
### cmd: sort -k1,1 -k2,2n unsorted.bed > sorted.bed ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16

baseCommand: [sort]

inputs:

  unsorted_bed:
    type: File
    inputBinding:
      position: 1

arguments: [
  "-k1,1",
  "-k2,2n"
  ]
  
  
stdout: $(inputs.unsorted_bed.nameroot).sorted.bed

outputs:

  sorted_bed:
    type: File
    outputBinding:
      glob: $(inputs.unsorted_bed.nameroot).sorted.bed

doc: |
  This tool wraps unix sort to sort a BED file.