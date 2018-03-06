#!/usr/bin/env cwltool

cwlVersion: v1.0

class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement

inputs:
  file:
    type: File
    inputBinding:
      loadContents: true

outputs:
  output:
    type: string

expression: "${return {'output':inputs.file.contents}; }"