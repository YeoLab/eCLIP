#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
    #tmpdirMin: 4000
    #outdirMin: 4000

baseCommand: [parsebarcodes.sh]

#$namespaces:
#  ex: http://example.com/

#hints:
#  - class: FileRequirement
#    fileDef:
#      - singularityexec: $(inputs.singularityexec)
#  - class: ex:PackageRequirement
#    packages:
#      - name: tree
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

# TODO purpose is NOT hand over to next cwl tool, but merely to log for debug
# TODO not supported by toil, done instead inside parsebarcodes.sh
#requirements:
#
#  InitialWorkDirRequirement:
#    listing:
#      - entryname: $(inputs.barcodeidA)
#        entry: |
#          $(inputs.barcodeidA)
#      - entryname: $(inputs.barcodeidB)
#        entry: |
#          $(inputs.barcodeidB)

inputs:

  ####################
  #bindir:
  #  type: Directory
  #  default:
  #    class: Directory
  #    location: bin
  ####################


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
