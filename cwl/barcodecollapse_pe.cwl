#!/usr/bin/env cwltool

### doc: "collapses eCLIP barcodes to remove PCR duplicates" ###

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1

hints:
  - class: DockerRequirement
    dockerPull: brianyee/python:2.7.16
    
baseCommand: [barcodecollapsepe.py]

arguments: [
  "-o",
  $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.bam,
  "-m",
  $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.metrics
  ]

inputs:

  input_barcodecollapsepe_bam:
    type: File

    inputBinding:
      position: 1
      prefix: -b
    label: ""
    doc: "input bam to barcode collapse. NOTE: no use for a bai index file!"

outputs:

  output_barcodecollapsepe_bam:
    type: File
    outputBinding:
      glob: $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.bam
    label: ""
    doc: "barcode collapseed mappings bam "

  output_barcodecollapsepe_metrics:
    type: File
    outputBinding:
      glob: $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.metrics
    label: ""
    doc: "barcode collapse metrics"

doc: |
  This tool wraps barcodecollapsepe.py, a paired-end PCR duplicate removal script
  which reads in a .bam file where the first string left of : split of the read name is the barcode
  and merge reads mapped to the same position that have the same barcode.
  Assumes paired end reads are adjacent in output file (ie needs unsorted bams)
  Also assumes no multimappers in the bam file (otherwise behavior is undefined)
    Usage: python barcodecollapsepe.py --bam BAM --out_file OUT_FILE --metrics_file METRICS_FILE
