#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [get_reproducing_peaks.pl]



inputs:


  # rep1 full out after idr (.01.bed.full or rep1.bed.full)
  rep1FullIn:
    type: File
    inputBinding:
      position: 1

  # rep1 full out after idr (.02.bed.full or rep2.bed.full)"
  rep2FullIn:
    type: File
    inputBinding:
      position: 2


  rep1Entropy:
    type: File
    inputBinding:
      position: 7

  rep2Entropy:
    type: File
    inputBinding:
      position: 8

  idr:
    type: File
    inputBinding:
      position: 9



  # rep1 full out after this step
  rep1FullOutFilename:
    type: string
    inputBinding:
      position: 3
  # rep2 full out after this step
  rep2FullOutFilename:
    type: string
    inputBinding:
      position: 4
  # final reproduced peaks?
  bedOutFilename:
    type: string
    inputBinding:
      position: 5


  customBedOutFilename:
    type: string
    inputBinding:
      position: 6



outputs:


  rep1FullOut:
    type: File
    outputBinding:
      glob: $(inputs.rep1FullOutFilename)
  rep2FullOut:
    type: File
    outputBinding:
      glob: $(inputs.rep2FullOutFilename)
  bedOut:
    type: File
    outputBinding:
      glob: $(inputs.bedOutFilename)


  customBedOut:
    type: File
    outputBinding:
      glob: $(inputs.customBedOutFilename)

