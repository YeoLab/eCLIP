#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand:
  - bam_split.sh


arguments:
  - $(inputs.bam.nameroot).split1.bam
  - $(inputs.bam.nameroot).split2.bam


inputs:

  bam:
    type: File
    inputBinding:
      position: -1


outputs:

  split1:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).split1.bam

  split2:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).split2.bam