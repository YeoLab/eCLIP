#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

# samtools executable in bin folder is v 0.1.18-dev (r982:313)
baseCommand: [samtools, view, -hb, -f, "128"]

#$namespaces:
#  ex: http://example.com/

#hints:

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  input_view_bam:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
    #secondaryFiles:
    #  - ".bai"
    label: "input bam"
    doc: "input bam"


stdout: $(inputs.input_view_bam.nameroot)V2.bam

outputs:

  output_view_r2bam:
    type: File
    format: http://edamontology.org/format_2572
    outputBinding:
      glob: $(inputs.input_view_bam.nameroot)V2.bam
    label: "output bam"
    doc: "output bam"
