#!/usr/bin/env cwltool

### doc: "samtools sort tool (sort by coordinate)" ###

### This is a copy of namesort.cwl, ###
### exists in case TOIL mistakes namesorting with regular sorting ###
### Changes: name_sort flag is FALSE by default ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    # ramMin: 30000
    # tmpdirMin: 8000
    # outdirMin: 8000

# samtools executable in bin folder is v 0.1.18-dev (r982:313)

baseCommand: [samtools, sort]

#$namespaces:
#  ex: http://example.com/

#hints:

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  name_sort:
    type: boolean
    inputBinding:
      position: 1
      prefix: -n
    default: false

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

  memory:
    default: 3G
    type: string
    inputBinding:
      position: 3
      prefix: -m

  input_sort_bam:
    type: File
    # format: http://edamontology.org/format_2572
    inputBinding:
      position: 4
    label: ""
    doc: "input bam"


# arguments: [
#   "-o",
#   $(inputs.input_sort_bam.nameroot)So.bam
#   ]

outputs:

  output_sort_bam:
    type: File
    # format: http://edamontology.org/format_2572
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
  This tool wraps samtools sort by coordinates (namesort flag is False by default).
    Usage: samtools sort [options...] [in.bam]