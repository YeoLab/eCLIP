#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [fqgzconcat.sh]


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000

  - class: InlineJavascriptRequirement

arguments:
  - $(inputs.fqgz_files.path)
  - ${if ("secondaryFiles" in inputs.fqgz_files)
     { return inputs.fqgz_files.secondaryFiles.map(  function(fileObject){return fileObject.path}   )
     }
     else {return []}
     }
inputs:

  concatenated_filename:
    type: string
    inputBinding:
      position: -1

  fqgz_files:
    type: File

outputs:

  concatenated:
    type: File
    outputBinding:
      glob: $(inputs.concatenated_filename)
