#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [peaksoverlapize.pl]


inputs:

  # IP BAM file
  clipBamFile:
    type: File
    inputBinding:
      position: -5

  inputBamFile:
    type: File
    inputBinding:
      position: -4

  peakFile:
    type: File
    inputBinding:
      position: -3

  # mapped_read_num
  readnum:
    type: File
    inputBinding:
      position: -2

  outputFile:
    type: string
    inputBinding:
      position: -1

outputs:

  inputnormedBed:
    type: File
    outputBinding:
      glob: $(inputs.outputFile)

  inputnormedBedfull:
    type: File
    outputBinding:
      glob: $(inputs.outputFile)
