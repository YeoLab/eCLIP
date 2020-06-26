#!/usr/bin/env cwl-runner

### doc: "Fixes a BED file" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
hints:
  - class: DockerRequirement
    dockerPull: brianyee/python:2.7.16
    
baseCommand: [fix_bed_for_bigbed_conversion.py]

inputs:

  input_bed:
    type: File
    inputBinding:
      position: 1
      prefix: --input_bed
    label: ""
    doc: "input bed (eCLIP input-normalized format) to be fixed (ie. change col4 to string, col5 to integer) for bigbed conversion"
      
arguments: [
  "--output_fixed_bed",
  $(inputs.input_bed.nameroot).fx.bed
]

outputs:

  output_fixed_bed:
    type: File
    outputBinding:
      glob: $(inputs.input_bed.nameroot).fx.bed
    label: ""
    doc: "eCLIP peaks in proper BED6 format"

doc: |
  This tool fixes the eCLIP input-normalized format to the proper BED6 format prior to bigbed conversion.
