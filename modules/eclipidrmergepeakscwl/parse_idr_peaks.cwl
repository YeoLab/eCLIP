#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [parse_idr_peaks.pl]

inputs:

  idrFile:
    type: File
    inputBinding:
      position: 1


  entropyFile1:
    type: File
    inputBinding:
      position: 2


  entropyFile2:
    type: File
    inputBinding:
      position: 3




  outputFilename:
    type: string
    inputBinding:
      position: 4





outputs:

  output:
    type: File
    outputBinding:
      glob: $(inputs.outputFilename)
