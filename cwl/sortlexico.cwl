#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


# samtools executable in bin folder is v 0.1.18-dev (r982:313)

baseCommand: [samtools, sort, -n]

#$namespaces:
#  ex: http://example.com/

#hints:

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  input_sortlexico_bam:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
    label: ""
    doc: "input bam"

arguments: [
  "-o",
  $(inputs.input_sortlexico_bam.nameroot)So.bam
  ]

outputs:

  output_sortlexico_bam:
    type: File
    format: http://edamontology.org/format_2572
    outputBinding:
      glob: $(inputs.input_sortlexico_bam.nameroot)So.bam
    label: ""
    doc: "sorted bam"
