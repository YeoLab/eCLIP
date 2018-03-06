#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

#requirements:
#  - class: SubworkflowFeatureRequirement
#  - class: MultipleInputFeatureRequirement


baseCommand: [eclipidrrescueratio.sh]


inputs:


  ip1bam:
    type: File
    inputBinding:
      position: 1

  ip2bam:
    type: File
    inputBinding:
      position: 2

  in1bam:
    type: File
    inputBinding:
      position: 3

  in2bam:
    type: File
    inputBinding:
      position: 4

  species:
    type: string
    inputBinding:
      position: 5

outputs:

  rescuratio:
    type: File
    outputBinding:
      glob: 1.2.3.rescueratio.txt
