#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [split_bam_to_subfiles_SE.pl]

requirements:
  - class: InlineJavascriptRequirement

inputs:

  sam_file:
    type: File
    inputBinding:
      position: 1

outputs:

  repsam_s:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.tmp"
