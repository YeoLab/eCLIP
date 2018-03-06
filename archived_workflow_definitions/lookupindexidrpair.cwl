#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: ExpressionTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000

  - class: InlineJavascriptRequirement

inputs:

  idrpair:
    type:
      type: record
      fields:
        ip1:
          type: string
        ip2:
          type: string
        in1:
          type: string
        in2:
          type: string

  name_s:
    type: string[]

outputs:
  ip1index: int
  ip2index: int
  in1index: int
  in2index: int

expression: "$({ 'ip1index': inputs.name_s.indexOf(inputs.idrpair.ip1), 'ip2index': inputs.name_s.indexOf(inputs.idrpair.ip2), 'in1index':  inputs.name_s.indexOf(inputs.idrpair.in1), 'in2index':  inputs.name_s.indexOf(inputs.idrpair.in2) })"

