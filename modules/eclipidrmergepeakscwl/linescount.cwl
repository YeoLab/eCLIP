#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement


baseCommand: [ linescount.sh ]


inputs:

  textfile:
    type: File
    inputBinding:
      position: 1

stdout: $(inputs.textfile.basename).linescount

outputs:


  linescount:
    type: int
    outputBinding:
      glob: $(inputs.textfile.basename).linescount
      loadContents: true
      outputEval: $( parseInt(self[0].contents))


