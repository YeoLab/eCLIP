#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


baseCommand: [regrouptriplet.sh]


inputs:

  dataset:
    type: string
    inputBinding:
      position: 1

  name:
    type: string
    inputBinding:
      position: 2

  bed:
    type: File
    inputBinding:
      position: 3

  bam:
    type: File
    inputBinding:
      position: 4
  bai:
    type: File
    inputBinding:
      position: 5


outputs:

  triplet:
    type:
      type: record
      fields:

        dataset:
          type: string
          outputBinding:
            glob: $(inputs.dataset)
            loadContents: true
            outputEval: $(self[0].contents)

        name:
          type: string
          outputBinding:
            glob: $(inputs.name)
            loadContents: true
            outputEval: $(self[0].contents)

        bed:
          type: File
          outputBinding:
            glob: $(inputs.bed.basename)
        bam:
          type: File
          outputBinding:
            glob: $(inputs.bam.basename)
        bai:
          type: File
          outputBinding:
            glob: $(inputs.bai.basename)
