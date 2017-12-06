#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


#baseCommand: [bedSort]
baseCommand: [fix_ld_library_path, bedSort]


arguments: [
  $(inputs.input_bed.nameroot)So.bed
  ]



inputs:

  input_bed:
    type: File
    format: http://edamontology.org/format_3003
    inputBinding:
      position: -1
    label: ""
    doc: "input bed"

outputs:

  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.input_bed.nameroot)So.bed
    label: ""
    doc: "sorted bed"
