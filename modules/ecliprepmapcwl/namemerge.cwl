#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [namemerge]


inputs:

  name1:
    type: string
    inputBinding:
      position: 1

  name2:
    type: string
    inputBinding:
      position: 2

  substitutechar:
    type: string
      inputBinding:
      position: 3


stdout: MERGEDNAME

outputs:

  mergedname:
    type: string
    outputBinding:
      glob: $(inputs.outputfilename)

