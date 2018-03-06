#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000

  - class: InlineJavascriptRequirement

baseCommand: [lookupbamidrpair.sh]


inputs:

  ip1index: int
  ip2index: int
  in1index: int
  in2index: int

  triplet_s:
    type:
      type: array
      items: Any








arguments:



  - $(inputs.triplet_s[inputs.ip1index].bam.location)

  - $(inputs.triplet_s[inputs.ip2index].bam.location)

  - $(inputs.triplet_s[inputs.in1index].bam.location)

  - $(inputs.triplet_s[inputs.in2index].bam.location)



  - $(inputs.triplet_s[inputs.ip1index].bam.basename)

  - $(inputs.triplet_s[inputs.ip2index].bam.basename)

  - $(inputs.triplet_s[inputs.in1index].bam.basename)

  - $(inputs.triplet_s[inputs.in2index].bam.basename)



outputs:


  ip1bam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.ip1index].bam.basename)

  ip2bam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.ip2index].bam.basename)

  in1bam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.in1index].bam.basename)

  in2bam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.in2index].bam.basename)

