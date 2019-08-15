#!/usr/bin/env cwltool

### doc: "Indexes a bam file (should be deprecated by samtools-index.cwl so kept for legacy)" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 8000
    #tmpdirMin: 4000
    #outdirMin: 4000

# samtools executable in bin folder is v 0.1.18-dev (r982:313)

baseCommand: [samtools, index]

#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  input_index_bam:
    type: File
    # format: http://edamontology.org/format_2572
    inputBinding:
      position: -1
    label: ""
    doc: "input bam to index"

arguments: [ $(inputs.input_index_bam.basename).bai ]

outputs:

  output_index_bai:
    type: File
    # format: http://edamontology.org/format_3327
    outputBinding:
      glob: $(inputs.input_index_bam.basename).bai
    label: ""
    doc: "index"

doc: |
  Indexes a bam file (should be deprecated by samtools-index.cwl so kept for legacy),
  with the difference being that this tool returns the *.bai index while the other
  returns a BAM file object containing an index file as a secondaryFile.

  Usage: samtools index <input.bam> <output.bam>