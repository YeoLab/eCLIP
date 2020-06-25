#!/usr/bin/env cwltool

### Given a list of 'blacklist' regions, remove those regions from an input BED file ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
hints:
  - class: DockerRequirement
    dockerImageId: brianyee/bedtools:2.27.1
    
baseCommand: [bedtools, intersect]

inputs:

  input_bed:
    type: File
    inputBinding:
      position: 1
      prefix: -a
      
  blacklist_file:
    type: File
    inputBinding:
      position: 2
      prefix: -b
      
arguments: [
  "-v",
  "-s",
  ]
  
  
stdout: $(inputs.input_bed.nameroot).blacklist-removed.bed

outputs:

  output_blacklist_removed_bed:
    type: File
    outputBinding:
      glob: $(inputs.input_bed.nameroot).blacklist-removed.bed

doc: |
  This tool wraps bedtools intersect -v to remove blacklist regions