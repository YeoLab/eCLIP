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

  pair:
    type:
      type: record
      fields:
        ip:
          type: string
          inputBinding:
            prefix: --ip-name
            position: 1
        in:
          type: string
          inputBinding:
            prefix: --in-name
            position: 2

  triplet_s:
    type:

      type: array
      items: Any

        #type: record
        #fields:
        #  bam:
        #    type: File
        #  bai:
        #    type: File
        #  peaks_bed:
        #    type: File


arguments:

  - $(inputs.triplet_s[0].bed.location)
  - $(inputs.triplet_s[0].bam.location)
  - $(inputs.triplet_s[0].bai.location)

  - $(inputs.triplet_s[0].bed.basename)
  - $(inputs.triplet_s[0].bam.basename)
  - $(inputs.triplet_s[0].bai.basename)

  - $(inputs.triplet_s[0].dataset).trim()
  - $(inputs.triplet_s[0].name).trim()


outputs:

  bed:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[0].bed.basename)
  bam:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[0].bam.basename)
  bai:
    type: File
    outputBinding:
      glob: $(inputs.triplet_s[0].bai.basename)
