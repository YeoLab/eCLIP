#!/usr/bin/env cwl-runner

### doc: "Convert peak bed to narrowPeak" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
  - class: InlineJavascriptRequirement

baseCommand: [bedToBigBed]

inputs:

  input_bed:
    type: File
    inputBinding:
      position: 1
    label: ""
  chrom_sizes:
    type: File
    inputBinding:
      position: 2
  output_bb_filename:
    type: string
    default: ""
    inputBinding:
      position: 3
      valueFrom: |
        ${
          if (inputs.output_bb_filename == "") {
            return inputs.input_bed.nameroot + ".bb";
          }
          else {
            return inputs.output_bb_filename;
          }
        }
        
outputs:

  output_bigbed:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_bb_filename == "") {
            return inputs.input_bed.nameroot + ".bb";
          }
          else {
            return inputs.output_bb_filename;
          }
        }
    label: ""
    doc: ""

doc: |
  This tool converts an input-normalized eCLIP peaks file (BED6) into a bigbed (bb) file.