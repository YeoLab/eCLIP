#!/usr/bin/env cwl-runner

### doc: "cwl wrapper for bash script that parses barcodes based on overlap length" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    # ramMin: 2000
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

doc: |
  This tool wraps parsebarcodes.sh.

  We have observed occasional double ligation events on the 5’ end of Read1, and we have found
  that to fix this requires we run cutadapt twice.  Additionally, because two adapters are used for
  each library (to ensure proper balancing on the Illumina sequencer), two separate barcodes may
  be ligated to the same Read1 5’ end (often with 5’ truncations).  To fix this we split the barcodes
  up into 15bp chunks so that cutadapt is able to deconvolute barcode adapters properly (as by
  default it will not find adapters missing the first N bases of the adapter sequence)

  parsebarcodes.sh writes the following files:
  trimfirst_overlap_length.txt : file that always contains "1"
  trimagain_overlap_length.txt : file that contains max((length of longest barcode - 2),5)
  g_adapters_default.fasta : empty file (to be fed to cutadapt properly)
  a_adapters_default.fasta : empty file (to be fed to cutadapt properly)
  g_adapters.fasta :  fasta file containing sequences to be trimmed via cutadapt -g flag
  a_adapters.fasta : fasta file containing sequences to be trimmed via cutadapt -a flag
  A_adapters.fasta : fasta file containing sequences to be trimmed via cutadapt -A flag

    Usage: parsebarcodes.sh <randommer_length> <barcodes_fasta> <barcode_A> <barcode_B>