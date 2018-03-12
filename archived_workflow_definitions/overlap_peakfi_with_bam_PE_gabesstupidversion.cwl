#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [peaks_normalize_overlap_peakfi_with_bam_PE_gabes.pl]


inputs:

  # IP BAM file
  clipBamFile:
    type: File
    inputBinding:
      position: -5
    secondaryFiles:
      - $(inputs.clipBamFile.basename).bai

  inputBamFile:
    type: File
    inputBinding:
      position: -4
    secondaryFiles:
      - $(inputs.inputBamFile.basename).bai

  peakFile:
    type: File
    inputBinding:
      position: -3
  
  outputFile:
    type: string
    inputBinding:
      position: -2

  # clipBamFileIndex:
  #   type: File
  #   inputBinding:
  #     position: -1

  # inputBamFileIndex:
  #   type: File
  #   inputBinding:
  #     position: 1

  # mapped_read_num
  # clipReadnum:
  #   type: File
  #   inputBinding:
  #     position: -2

  #mapped_read_num"
  # inputReadnum:
  #   type: File
  #   inputBinding:
  #     position: -1


  # outputprefix:
  #   type: string

  # inputnormsuffix:
  #   type: string
  #   default: "inputnormed"


outputs:

  inputnormedBed:
    type: File
    outputBinding:
      #glob: $(inputs.output)
      # glob: $(inputs.outputprefix).$(inputs.inputnormsuffix).bed
      glob: $(inputs.outputFile)

#   inputnormedBedfull:
#     type: File
#     outputBinding:
#       #glob: "$(inputs.output).full"
#       # glob: $(inputs.outputprefix).$(inputs.inputnormsuffix).bed.full
#       glob: any
