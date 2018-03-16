#!/usr/bin/env cwltool


cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:
  dataset:
    type: string
  randomer_length:
    type: string
  barcodesfasta:
    type: File

  read:
    type:
      type: record
      fields:
        read1:
          type: File
        read2:
          type: File
        barcodeids:
          type: string[]
        name:
          type: string
outputs:

  ### DEMUXED FILES ###
  A_output_demuxed_read1:
    type: File
    outputSource: AB_demux/demuxedAfwd
  A_output_demuxed_read2:
    type: File
    outputSource: AB_demux/demuxedArev
  B_output_demuxed_read1:
    type: File
    outputSource: AB_demux/demuxedBfwd
  B_output_demuxed_read2:
    type: File
    outputSource: AB_demux/demuxedBrev

  ### TRIM/CUTADAPT PARAMS ###
  AB_output_trimfirst_overlap_length:
    type: File
    outputSource: AB_parsebarcodes/trimfirst_overlap_length
  AB_output_trimagain_overlap_length:
    type: File
    outputSource: AB_parsebarcodes/trimagain_overlap_length
  AB_g_adapters_default:
    type: File
    outputSource: AB_parsebarcodes/g_adapters_default
  AB_a_adapters_default:
    type: File
    outputSource: AB_parsebarcodes/a_adapters_default
  AB_g_adapters:
    type: File
    outputSource: AB_parsebarcodes/g_adapters
  AB_a_adapters:
    type: File
    outputSource: AB_parsebarcodes/a_adapters
  AB_A_adapters:
    type: File
    outputSource: AB_parsebarcodes/A_adapters


steps:

###########################################################################
# Upstream
###########################################################################
  AB_demux:
    run: demux_pe.cwl
    in:
      barcodesfasta: barcodesfasta
      randomer_length: randomer_length
      dataset: dataset
      # seqdatapath: seqdatapath
      reads: read
    out: [demuxedAfwd, demuxedArev,
          demuxedBfwd, demuxedBrev,
          output_demuxedpairedend_metrics,
          output_dataset,
          name,
          barcodeidA,
          barcodeidB
         ]

  AB_parsebarcodes:
    run: parsebarcodes.cwl
    in:
      randomer_length: randomer_length
      barcodeidA: AB_demux/barcodeidA
      barcodeidB: AB_demux/barcodeidB
      barcodesfasta: barcodesfasta
    out: [
      trimfirst_overlap_length, trimagain_overlap_length,
      g_adapters_default, a_adapters_default,
      g_adapters, a_adapters, A_adapters
    ]

###########################################################################
# Downstream
###########################################################################

