#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool


# # wrapped perl script for parsing bowtie results inline
baseCommand: [maprep]


inputs:


  #read1 trimmed fastq
  read1:
    type: File
    inputBinding:
      position: 1

  # read2 trimmed fastq"
  read2:
    type: File
    inputBinding:
      position: 2

  indexTar:
    type: File
    inputBinding:
      position: 3

  # TODO ask eric
  fileListFile:
    type: File
    inputBinding:
      position: 4


outputs:

  repsam:
    type: File
    outputBinding:
      glob: "*_rep.sam"



