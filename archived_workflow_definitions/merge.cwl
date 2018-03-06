#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


# samtools executable in bin folder is v 0.1.18-dev (r982:313)
baseCommand: [samtoolsmerge2]

#$namespaces:
#  ex: http://example.com/

#hints:
#
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


# TODO ME.bam is added by samtoolsmerge2, if actual merge, but not if 2 barcodes are same
arguments: [ $(inputs.input_merge_bam1.nameroot) , $(inputs.input_merge_bam2.nameroot)]


inputs:

  barcodeidA:
    type: string
    inputBinding:
      position: 3

  barcodeidB:
    type: string
    inputBinding:
      position: 4

  input_merge_bam1:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 5
    label: ""
    doc: "input bam 1 to merge"

  input_merge_bam2:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 6
    label: ""
    doc: "input bam 2 to merge"

outputs:

  output_merge_bam:
    type: File
    format: http://edamontology.org/format_2572
    outputBinding:
      glob: "*.bam"
    label: ""
    doc: "merged bam"
