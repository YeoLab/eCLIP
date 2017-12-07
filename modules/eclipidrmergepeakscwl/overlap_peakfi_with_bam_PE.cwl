#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [overlap_peakfi_with_bam_PE.pl]


arguments: [
  $(inputs.outputprefix).$(inputs.inputnormsuffix).bed
  ]


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


  outputprefix:
    type: string

  inputnormsuffix:
    type: string
    default: "inputnormed"


outputs:

  inputnormedBed:
    type: File
    outputBinding:
      #glob: $(inputs.output)
      glob: $(inputs.outputprefix).$(inputs.inputnormsuffix).bed

  inputnormedBedfull:
    type: File
    outputBinding:
      #glob: "$(inputs.output).full"
      glob: $(inputs.outputprefix).$(inputs.inputnormsuffix).bed.full
