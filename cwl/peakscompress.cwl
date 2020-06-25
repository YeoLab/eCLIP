#!/usr/bin/env cwltool

### doc: "Compresses overlapping peaks into a single BED region." ###

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 16000
hints:
  - class: DockerRequirement
    dockerImageId: brianyee/perl:5.10.1
    
baseCommand: [compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat.pl]

arguments: [ $(inputs.input_bed.nameroot).compressed.bed ]

inputs:

  input_bed:
    type: File
    # format: http://edamontology.org/format_3003
    inputBinding:
      position: -1

outputs:

  output_bed:
    type: File
    # format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.input_bed.nameroot).compressed.bed

doc: |
  This tool wraps compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat.pl,
  which merges neighboring or overlapping regions in a BED file.
    Usage:   perl compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat.pl <in.bed> <out.compressed.bed>
