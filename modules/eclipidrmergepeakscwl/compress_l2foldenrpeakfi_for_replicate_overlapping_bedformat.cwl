#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat.pl]






inputs:

  inputFile:
    type: File
    inputBinding:
      position: 1



#  compressedFile:
#    type: string
#    inputBinding:
#      position: 2
#
#
#
#
#


  outputprefix:
    type: string


outputs:

  compressedOutputFile:
    type: File
    outputBinding:
#      glob: $(inputs.compressedFile)
      glob: $(inputs.outputprefix).compressed.bed






