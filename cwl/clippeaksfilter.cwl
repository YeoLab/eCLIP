#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000



#baseCommand: [clippeaksfilter.py]
baseCommand: [fix_ld_library_path, clippeaksfilter.py]

arguments: [
  --out,
  $(inputs.input_clippeaksfilter_bed.nameroot)Fc$(inputs.input_clippeaksfilter_l2fc)Pv$(inputs.input_clippeaksfilter_pval).bed
  ]

inputs:

  input_clippeaksfilter_l2fc:
    type: string
    default: "3"
    inputBinding:
      position: 1
      prefix: --l2fc

  input_clippeaksfilter_pval:
    type: string
    default: "3"
    inputBinding:
      position: 2
      prefix: --pval

  input_clippeaksfilter_bed:
    type: File
    format: http://edamontology.org/format_3003
    inputBinding:
      position: 3
      prefix: --bed


outputs:

  output_clippeaksfilter_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.input_clippeaksfilter_bed.nameroot)Fc$(inputs.input_clippeaksfilter_l2fc)Pv$(inputs.input_clippeaksfilter_pval).bed
