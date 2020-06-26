#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [gzip]

inputs:

  stdout:
    type: boolean
    inputBinding:
      position: 1
      prefix: -c
    default: true

  input:
    type: File
    inputBinding:
      position: 2

stdout: $(inputs.input.basename).gz

outputs:

  gzipped:
    type: File
    outputBinding:
      glob: $(inputs.input.basename).gz
