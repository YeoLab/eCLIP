#!/usr/bin/env cwl-runner

### doc: "cwl wrapper for bash script that parses barcodes based on overlap length" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 2000
    #tmpdirMin: 4000
    #outdirMin: 4000

baseCommand: [parsebarcodes.sh]

inputs:

# these are now hard-coded in parser.sh
#  adapter3prime:
#     type: string
#     optional: true
#     default: AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
#  adapter5prime:
#     type: string
#     optional: true
#     default : CTTCCGATCT

  randomer_length:
    type: string
    default: "10"
    inputBinding:
      position: 1
    doc: "randomer length: now normally 10, some old experiment used 5"

  barcodesfasta:
    type: File
    inputBinding:
      position: 2

  barcodeidA:
    type: string
    inputBinding:
      position: 3
  barcodeidB:
    type: string
    inputBinding:
      position: 4

outputs:

  a_adapters_default:
    type: File
    outputBinding:
      glob: a_adapters_default.fasta

  g_adapters_default:
    type: File
    outputBinding:
      glob: g_adapters_default.fasta

  a_adapters:
    type: File
    outputBinding:
      glob: a_adapters.fasta

  g_adapters:
    type: File
    outputBinding:
      glob: g_adapters.fasta

  A_adapters:
    type: File
    outputBinding:
      glob: A_adapters.fasta

  trimfirst_overlap_length:
    type: File
    outputBinding:
      glob: trimfirst_overlap_length.txt

  trimagain_overlap_length:
    type: File
    outputBinding:
      glob: trimagain_overlap_length.txt
