#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: InlineJavascriptRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  species:
    type: string

  name_s:
    type: string[]

  triplet_s:
    type:

      type: array
      items: Any

        #type: record
        #fields:
        #  dataset:
        #    type: string
        #  name:
        #    type: string
        #  bed:
        #    type: File
        #  bam:
        #    type: File
        #  bai:
        #    type: File

  pair1:
    type:
      type: record
      fields:
        ip:
          type: string
        in:
          type: string

  pair2s:
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

  peaksnormalized_bed_s:
    type: File[]
    outputSource: scatter_overlapize/peaksnormalized_bed



steps:

###########################################################################
# Look up triplets1
###########################################################################

  lookupindexpair1:
    run: lookupindexpair.cwl
    in:
      pair: pair1
      name_s: name_s
    out: [ipindex, inindex]

  lookup1:
    run: lookuptripletpair.cwl
    in:
      ipindex: lookupindexpair1/ipindex
      inindex: lookupindexpair1/inindex
      triplet_s: triplet_s
    out: [ipbed, ipbam, ipbai, inbed, inbam, inbai]

###########################################################################
# Normalize
###########################################################################


  scatter_overlapize:
    run: wf_overlapize.cwl
    ##############
    scatter: pair2
    ##############
    in:
      ipbed1: lookup1/ipbed
      ipbam1: lookup1/ipbam
      ipbai1: lookup1/ipbai

      inbam1: lookup1/inbam
      inbai1: lookup1/inbai

      species: species
      name_s: name_s
      triplet_s: triplet_s

      pair2: pair2s

    out: [
      peaksnormalized_bed
      ]
