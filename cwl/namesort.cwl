#!/usr/bin/env cwltool

### doc: "samtools sort tool (sort by name)" ###

### This is a copy of sort.cwl, ###
### exists in case TOIL mistakes namesorting with regular sorting ###
### Changes: name_sort flag is TRUE by default ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1

hints:
  - class: DockerRequirement
    dockerPull: brianyee/samtools:1.5

baseCommand: [samtools, sort]

inputs:

  name_sort:
    type: boolean
    inputBinding:
      position: 1
      prefix: -n
    default: true

  output_file:
    type: string
    inputBinding:
      position: 2
      prefix: -o
      valueFrom: |
        ${
          if (inputs.output_file == "") {
            return inputs.input_sort_bam.nameroot + "So.bam";
          }
          else {
            return inputs.output_file;
          }
        }
    default: ""

  input_sort_bam:
    type: File
    inputBinding:
      position: 3
    label: ""
    doc: "input bam"

outputs:

  output_sort_bam:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_file == "") {
            return inputs.input_sort_bam.nameroot + "So.bam";
          }
          else {
            return inputs.output_file;
          }
        }
    label: ""
    doc: "sorted bam"

doc: |
  This tool wraps samtools sort, setting the by-name (-n) flag to be True by default.
    Usage: samtools sort -n <input.bam> <output.bam>
