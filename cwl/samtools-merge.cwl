#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1

baseCommand: [samtools, merge]

hints:
  - class: DockerRequirement
    dockerPull: brianyee/samtools:1.6

inputs:

  output_bam:
    type: string
    default: ""
    inputBinding:
      position: 1
      valueFrom: |
        ${
          if (inputs.output_bam == "") {
            return inputs.input_bam_files[0].nameroot + ".merged.bam";
          }
          else {
            return inputs.output_bam;
          }
        }
    label: ""
    doc: "output merged bam file name"

  input_bam_files:
    type: File[]
    inputBinding:
      position: 2
    label: ""
    doc: "input unmerged bam files"

outputs:

  output_bam_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_bam == "") {
            return inputs.input_bam_files[0].nameroot + ".merged.bam";
          }
          else {
            return inputs.output_bam;
          }
        }
    label: ""
    doc: "output merged bam file"

doc: |
  samtools-merge.cwl takes in a list of input_bam_files and
  returns a merged BAM file.

  Usage: samtools merge [-nurlf] [-h inh.sam] [-b <bamlist.fofn>] <out.bam> <in1.bam> [<in2.bam> ... <inN.bam>]
