#!/usr/bin/env cwltool

class: CommandLineTool

cwlVersion: v1.0

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: $(inputs.newname + inputs.suffix)
        entry: $(inputs.srcfile)

baseCommand: "true"

inputs:
  srcfile: File

  suffix: string

  newname: string

outputs:
  outfile:
    type: File
    outputBinding:
      glob: $(inputs.newname + inputs.suffix)
