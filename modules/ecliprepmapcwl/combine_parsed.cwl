#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [merge_multiple_parsed_files.pl]

inputs:

  outputFilename:
    type: string
    inputBinding:
      position: 1
  inputFiles:
    type: File[]
    inputBinding:
      position: 2
    label: "input"
    doc: "input file"

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.outputFile)
