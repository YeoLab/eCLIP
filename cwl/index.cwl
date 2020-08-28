#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4000
    
hints:
  - class: DockerRequirement
    dockerPull: brianyee/samtools:1.6

baseCommand: [samtools, index]

inputs:

  input_index_bam:
    type: File
    inputBinding:
      position: -1
    label: ""
    doc: "input bam to index"

arguments: [ $(inputs.input_index_bam.basename).bai ]

outputs:

  output_index_bai:
    type: File
    outputBinding:
      glob: $(inputs.input_index_bam.basename).bai
    label: ""
    doc: "index"

doc: |
  Indexes a bam file (should be deprecated by samtools-index.cwl so kept for legacy),
  with the difference being that this tool returns the *.bai index while the other
  returns a BAM file object containing an index file as a secondaryFile.

  Usage: samtools index <input.bam> <output.bam>
