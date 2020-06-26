#!/usr/bin/env cwltool

cwlVersion: v1.0
class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement

inputs:

  sample:
    type:
      type: []
      items:
        - ip_read
          type: record
        - input_read:
          type: record

outputs:

  ip_read:
    type: record

  input_read:
    type: record

expression: |
   ${
      return {
        'ip_read': inputs.sample.ip_read,
        'input_read': inputs.sample.input_read
      }
    }

doc: |
  This tool parses a record object into two reads (read1 and read2)
