#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [convert_ReadsByLoc_combined_significancecalls.pl]

inputs:

  combinedReadsByLocFile:
    type: File
    inputBinding:
      position: 1
    label: "tabbed files containing number of reads per gene by location"
    doc: "tabbed files containing number of reads per gene by location"

  clipMappedReadNumFile:
    type: File
    inputBinding:
      position: 2

  inputMappedReadNumFile:
    type: File
    inputBinding:
      position: 3

  l2fcWithPvalEnr:
    default: ""
    type: string
    inputBinding:
      position: 4
      valueFrom: |
        ${
          if (inputs.l2fcWithPvalEnr == "") {
            return inputs.combinedReadsByLocFile.nameroot + ".l2fcwithpval_enr.tsv";
          }
          else {
            return inputs.l2fcWithPvalEnr;
          }
        }

  l2fc:
    default: ""
    type: string
    inputBinding:
      position: 5
      valueFrom: |
        ${
          if (inputs.l2fc == "") {
            return inputs.combinedReadsByLocFile.nameroot + ".l2fc.tsv";
          }
          else {
            return inputs.l2fc;
          }
        }

outputs:
  l2fcOutputFile:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.l2fc == "") {
            return inputs.combinedReadsByLocFile.nameroot + ".l2fc.tsv";
          }
          else {
            return inputs.l2fc;
          }
        }

  l2fcWithPvalEnrOutputFile:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.l2fcWithPvalEnr == "") {
            return inputs.combinedReadsByLocFile.nameroot + ".l2fcwithpval_enr.tsv";
          }
          else {
            return inputs.l2fcWithPvalEnr;
          }
        }