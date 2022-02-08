#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [make_informationcontent_from_peaks.pl]


arguments: [ $(inputs.outputprefix).compressed.bed.entropy.full , $(inputs.outputprefix).compressed.bed.entropy.excessreads ]


inputs:


  compressedBedfull:
    type: File
    inputBinding:
      position: -3

  # clip readnum number FILE
  clipReadnum:
    type: File
    inputBinding:
      position: -2

  # input readnum number FILE
  inputReadnum:
    type: File
    inputBinding:
      position: -1

  outputprefix:
    type: string


outputs:

  entropyFull:
    type: File
    outputBinding:
      #glob: $(inputs.entropyOutFileName)
      glob: $(inputs.outputprefix).compressed.bed.entropy.full

  entropyExcessreads:
    type: File
    outputBinding:
      #glob: $(inputs.excessReadsOutFileName)
      glob: $(inputs.outputprefix).compressed.bed.entropy.excessreads
