#!/usr/bin/env cwltool

cwlVersion: v1.0

class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement


inputs:

  species:
    type: string

  #dataset:
  #  type: string


  name_s:
    type: string[]

  triplet_s:
    type:
      type: array
      items: Any

        #type: record
        #fields:
        #  bed:
        #    type: File
        #  bam:
        #    type: File
        #  bai:
        #    type: File


  overlapize_items:
    type:
      type: array
      items:
        type: record
        fields:
          ip:
            type: string
          in:
            type: string


outputs:

  peaksoverlapized_bed_s_s:
    type:
      type: array
      items: Any
    outputSource: scatter_scatter_overlapize/peaksnormalized_bed_s


steps:

  scatter_scatter_overlapize:

    run: wf_scatter_overlapize.cwl
    ##############
    scatter: pair1
    ##############
    in:
      species: species
      pair1:  overlapize_items
      pair2s: overlapize_items
      name_s: name_s
      triplet_s: triplet_s

    out: [
      peaksnormalized_bed_s,
    ]

