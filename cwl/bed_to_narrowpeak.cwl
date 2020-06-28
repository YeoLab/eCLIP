#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1

hints:
  - class: DockerRequirement
    dockerPull: brianyee/python:2.7.15_eclip0.6.0
    
baseCommand: [bed_to_narrowpeak.py]

arguments: [
  "--output_narrowpeak",
  $(inputs.input_bed.nameroot).narrowPeak
]

inputs:

  input_bed:
    type: File
    inputBinding:
      position: 1
      prefix: --input_bed
    label: ""
    doc: "input bam to convert to narrowPeak format. Must be ECLIP-style input-normed format! (log10p in col4, log2fold in col5)"

  species:
    type: string
    inputBinding: 
      position: 2
      prefix: --species

outputs:

  output_narrowpeak:
    type: File
    outputBinding:
      glob: $(inputs.input_bed.nameroot).narrowPeak
    label: ""
    doc: "eCLIP peaks in narrowPeak format"

doc: |
  This tool converts an input-normalized eCLIP peaks file (BED6) into a narrowPeak format for encode DCC. 
  cols 9 and 10 are just blank, col 5 is 1000 for things that meet the >=3 l2fc and l10pval cutoffs and 200 otherwise (it’s just for ucsc track coloring)
