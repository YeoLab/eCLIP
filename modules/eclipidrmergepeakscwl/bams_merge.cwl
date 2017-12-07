#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand:
  - samtools
  - merge


arguments:
  - $(inputs.bam_rep1.basename)_$(inputs.bam_rep2.basename).merged.bam


inputs:

  bam_rep1:
    type: File
    inputBinding:
      position: 2

  bam_rep2:
    type: File
    inputBinding:
      position: 3

outputs:

  merged:
    type: File
    outputBinding:
      glob: $(inputs.bam_rep1.basename)_$(inputs.bam_rep2.basename).merged.bam
