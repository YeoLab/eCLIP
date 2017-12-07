#!/usr/bin/env cwltool

cwlVersion: v1.0

class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement


inputs:

  count1:
    type: int
    inputBinding:
      position: 1

  count2:
    type: int
    inputBinding:
      position: 2


outputs:

  ratio:
    type: float

expression: "${ return {'ratio': Math.max(inputs.count1, inputs.count2) / Math.min(inputs.count1, inputs.count2) }; }"

