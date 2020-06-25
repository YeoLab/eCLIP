#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [calculate_fold_change_from_parsed_files.py]

inputs:

  ip_parsed_file:
    type: File
    inputBinding:
      prefix: --ip_parsed
      position: 1

  input_parsed_file:
    type: File
    inputBinding:
      prefix: --input_parsed
      position: 2

  out_file_nopipes:
    type: string
    inputBinding:
      position: 3
      prefix: --out_file_nopipes
      valueFrom: |
        ${
          if (inputs.out_file_nopipes == "") {
            return inputs.ip_parsed_file.nameroot + ".nopipes.tsv";
          }
          else {
            return inputs.out_file_nopipes;
          }
        }
    default: ""

  out_file_withpipes:
    type: string
    inputBinding:
      position: 4
      prefix: --out_file_withpipes
      valueFrom: |
        ${
          if (inputs.out_file_nopipes == "") {
            return inputs.ip_parsed_file.nameroot + ".withpipes.tsv";
          }
          else {
            return inputs.out_file_withpipes;
          }
        }
    default: ""

outputs:

  out_file_nopipes_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.out_file_nopipes == "") {
            return inputs.ip_parsed_file.nameroot + ".nopipes.tsv";
          }
          else {
            return inputs.out_file_nopipes;
          }
        }

  out_file_withpipes_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.out_file_withpipes == "") {
            return inputs.ip_parsed_file.nameroot + ".withpipes.tsv";
          }
          else {
            return inputs.out_file_withpipes;
          }
        }