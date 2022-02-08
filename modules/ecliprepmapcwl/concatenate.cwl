#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [cat]


inputs:

  file_s:
    type: File[]
    inputBinding:
      position: 1

  concatenated_nameroot:
    type: string

stdout: $(inputs.concatenated_nameroot).concatenated.sam

outputs:

  concatenatedsam:
    type: File
    outputBinding:
      glob: $(inputs.concatenated_nameroot).concatenated.sam


