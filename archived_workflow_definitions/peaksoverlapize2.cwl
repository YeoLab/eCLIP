#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000



# perl overlap_peakfi_with_bam_PE.pl
#
#    Experiment_bam_file         IP1 merged.r2.bam
#    Input_bam_file              IN1 unassigned.adapterTrim.round2.rmRep.rmDup.sorted.r2.bam
#
#    Peak_file                   IP2 .merged.r2.peaks.bed
#
#    Mapped_read_num_file
#    Output_file


baseCommand: [peaksoverlapize2]

arguments:

# locations

  - $(inputs.ipbed2.location)     # only change vs normalize is her: this file is here picked from IP2
  - $(inputs.ipbam1.location)
  - $(inputs.ipbai1.location)

  - $(inputs.inbam1.location)
  - $(inputs.inbai1.location)

# basenames

  - $(inputs.ipbed2.basename)
  - $(inputs.ipbam1.basename)
  - $(inputs.ipbai1.basename)

  - $(inputs.inbam1.basename)
  - $(inputs.inbai1.basename)

#

#  - $(inputs.ipbed2.nameroot)No.bed
#  - $(inputs.ipbed2.nameroot)No.full.bed
  - $(inputs.ipbed2.nameroot).OVER.$(inputs.ipbed1.basename).bed
  - $(inputs.ipbed2.nameroot).OVER.$(inputs.ipbed1.basename).full.bed

inputs:

  ipbed1:
    type: File
  ipbam1:
    type: File
  ipbai1:
    type: File
  inbam1:
    type: File
  inbai1:
    type: File

  ipbed2:
    type: File
  ipbam2:
    type: File
  ipbai2:
    type: File
  inbam2:
    type: File
  inbai2:
    type: File

outputs:

  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.ipbed2.nameroot).OVER.$(inputs.ipbed1.basename).bed

  output_bedfull:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.ipbed2.nameroot).OVER.$(inputs.ipbed1.basename).full.bed
