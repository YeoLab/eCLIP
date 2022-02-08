#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [merge_multiple_parsed_files.pl]


inputs:

  outputFile: 
    type: string
    inputBinding: 
      position: 1

  file_s:
    type: File[]
    inputBinding:
      position: 2






outputs:

  output:
    type: File
    outputBinding:
      glob: $(inputs.outputFile)


