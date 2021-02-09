#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
    
hints: 
  - class: DockerRequirement
    dockerPull: brianyee/brianyee/eclip:0.7.0_perl
    
baseCommand: [overlap_peakfi_with_bam_PE.pl]

inputs:

  # IP BAM file
  clipBamFile:
    type: File
    inputBinding:
      position: -5

  inputBamFile:
    type: File
    inputBinding:
      position: -4

  peakFile:
    type: File
    inputBinding:
      position: -3

  # mapped_read_num
  clipReadnum:
    type: File
    inputBinding:
      position: -2

  #mapped_read_num"
  inputReadnum:
    type: File
    inputBinding:
      position: -1

  outputFile:
    type: string
    default: ""
    inputBinding:
      position: 0
      valueFrom: |
        ${
          if (inputs.outputFile == "") {
            return inputs.peakFile.nameroot + ".normed.bed";
          }
          else {
            return inputs.outputFile;
          }
        }

outputs:

  inputnormedBed:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outputFile == "") {
            return inputs.peakFile.nameroot + ".normed.bed";
          }
          else {
            return inputs.outputFile;
          }
        }

  inputnormedBedfull:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outputFile == "") {
            return inputs.peakFile.nameroot + ".normed.bed.full";
          }
          else {
            return inputs.outputFile;
          }
        }

doc: |
  This tool wraps overlap_peakfi_with_bam_PE.pl
    Usage:
