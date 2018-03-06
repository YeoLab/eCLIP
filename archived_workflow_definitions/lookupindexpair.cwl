#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: ExpressionTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000

  - class: InlineJavascriptRequirement

inputs:

  pair:
    type:
      type: record
      fields:
        ip:
          type: string
        in:
          type: string

  name_s:
    type: string[]

outputs:
  ipindex: int
  inindex: int

expression: "$({ 'ipindex': inputs.name_s.indexOf(inputs.pair.ip), 'inindex': inputs.name_s.indexOf(inputs.pair.in) })"

