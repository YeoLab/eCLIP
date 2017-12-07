#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat_outputfull.pl]

arguments: [

  $(inputs.outputprefix).compressed.bed, $(inputs.outputprefix).compressed.bed.full
  ]

inputs:

  inputFile:
    type: File
    inputBinding:
      position: -1



#  compressedFile:
#    type: string
#    inputBinding:
#      position: 2
#
#  compressedFileFull:
#    type: string
#    inputBinding:
#      position: 3


  outputprefix:
    type: string


outputs:

  compressedBed:
    type: File
    outputBinding:
#      glob: $(inputs.compressedFile)
      glob: $(inputs.outputprefix).compressed.bed

  compressedBedfull:
    type: File
    outputBinding:
#      glob: $(inputs.compressedFileFull)
      glob: $(inputs.outputprefix).compressed.bed.full
