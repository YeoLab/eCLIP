class: CommandLineTool
cwlVersion: v1.0
baseCommand: "true"
requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: $(inputs.newname + inputs.suffix)
        entry: $(inputs.srcfile)
inputs:
  srcfile: File
  suffix: string
  newname: string
outputs:
  outfile:
    type: File
    outputBinding:
      glob: $(inputs.newname + inputs.suffix)