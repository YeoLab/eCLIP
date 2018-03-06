#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000

  - class: InlineJavascriptRequirement

baseCommand: [lookuptripletpair.sh]


inputs:

  ipindex: int

  inindex: int

  triplet_s:
    type:
      type: array
      items: Any








arguments:



  - $(inputs.triplet_s[inputs.ipindex].bed.location)
  - $(inputs.triplet_s[inputs.ipindex].bam.location)
  - $(inputs.triplet_s[inputs.ipindex].bai.location)

  - $(inputs.triplet_s[inputs.inindex].bed.location)
  - $(inputs.triplet_s[inputs.inindex].bam.location)
  - $(inputs.triplet_s[inputs.inindex].bai.location)



  - $(inputs.triplet_s[inputs.ipindex].bed.basename)
  - $(inputs.triplet_s[inputs.ipindex].bam.basename)
  - $(inputs.triplet_s[inputs.ipindex].bai.basename)

  - $(inputs.triplet_s[inputs.inindex].bed.basename)
  - $(inputs.triplet_s[inputs.inindex].bam.basename)
  - $(inputs.triplet_s[inputs.inindex].bai.basename)


outputs:

  ipbed:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.ipindex].bed.basename)
  ipbam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.ipindex].bam.basename)
  ipbai:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.ipindex].bai.basename)

  inbed:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.inindex].bed.basename)
  inbam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.inindex].bam.basename)
  inbai:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[inputs.inindex].bai.basename)
