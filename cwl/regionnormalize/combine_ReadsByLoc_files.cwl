#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [combine_ReadsByLoc_files.pl]

inputs:

  readsByLocFiles:
    type: File[]
    inputBinding:
      position: 1
    label: "tabbed files containing number of reads per gene by location"
    doc: "tabbed files containing number of reads per gene by location"

outputs:
  outputFile:
    type: File
    outputBinding:
      glob: |
        ${
          return inputs.readsByLocFiles[0].nameroot + "_combined.tsv";
        }

stdout: |
    ${
      return inputs.readsByLocFiles[0].nameroot + "_combined.tsv";
    }
