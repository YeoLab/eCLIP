#!/usr/bin/env cwl-runner

### doc: "Fixes a BED file" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 1000
    
hints:
  - class: DockerRequirement
    dockerPull: brianyee/eclip:0.6.0a_python
    
baseCommand: [calculate_entropy.py]

inputs:

  full:
    type: File
    inputBinding:
      position: 1
      prefix: --full
    label: ""
    doc: "output full file from overlap_peakfi_with_bam.pl (should contain number of reads per peak)"
  ip_mapped:
    type: File
    inputBinding: 
      position: 2
      prefix: --ip_mapped
    label: ""
    doc: "File containing a single number corresponding to the number of mapped reads in IP"
  input_mapped:
    type: File
    inputBinding: 
      position: 3
      prefix: --input_mapped
    label: ""
    doc: "File containing a single number corresponding to the number of mapped reads in INPUT"
   
arguments: [
  "--output",
  $(inputs.full.nameroot).entropynum
]

outputs:

  output_entropynum:
    type: File
    outputBinding:
      glob: $(inputs.full.nameroot).entropynum
    label: ""
    doc: "File containing the sum entropy value"

doc: |
  This tool computes and sums the entropy values for significant peaks (l10p >=3 and l2fc >=3).
  Returns the number as a file.
