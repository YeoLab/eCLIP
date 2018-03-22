#!/usr/bin/env cwltool

### This is kind of a worthless workflow, ###
### but to keep consistent with the paired-end ###
### pipeline, I'm keeping it here. ###

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
  # randomer_length:
  #   type: string
  # barcodesfasta:
  #   type: File

  read:
    type:
      type: record
      fields:
        read1:
          type: File
        # barcodeids:
        #   type: string[]
        name:
          type: string
outputs:

  ### DEMUXED FILES ###
  A_output_demuxed_read1:
    type: File
    outputSource: AB_demux/demuxedAfwd

  ### TRIM/CUTADAPT PARAMS ###


steps:

###########################################################################
# Upstream
###########################################################################
  AB_demux:
    run: demux_se.cwl
    in:
      reads: read
      dataset: dataset
    out: [
      demuxedAfwd,
      output_demuxedsingleend_metrics,
      output_dataset,
      name
    ]

###########################################################################
# Downstream
###########################################################################

doc: |
  This workflow takes in single-end reads, and performs the following steps in order:
  demux_se.cwl (does not actually demux for single end, but mirrors the paired-end processing protocol)
