#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [overlap_peakfi_with_bam_PE.pl]

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
  clipReadnum:
    type: File
    inputBinding:
      position: -2

  #mapped_read_num"
  inputReadnum:
    type: File
    inputBinding:
      position: -1


  outputFile:
    type: string
    inputBinding:
      position: 0


outputs:

  inputnormedBed:
    type: File
    outputBinding:
      glob: $(inputs.outputFile)
      # glob: $(inputs.outputprefix).$(inputs.inputnormsuffix).bed

  inputnormedBedfull:
    type: File
    outputBinding:
      glob: "$(inputs.outputFile).full"
      # glob: $(inputs.outputprefix).$(inputs.inputnormsuffix).bed.full
