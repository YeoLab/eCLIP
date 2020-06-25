#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [cat]


inputs:

  files:
    type: File[]
    inputBinding:
      position: 1

  concatenated_output:
    type: string

stdout: $(inputs.concatenated_output)

outputs:

  concatenated:
    type: File
    outputBinding:
      glob: $(inputs.concatenated_output)
