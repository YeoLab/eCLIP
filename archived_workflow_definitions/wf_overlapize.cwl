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


  pair2:
    type:
      type: record
      fields:
        ip:
          type: string
        in:
          type: string

  ipbed1:
    type: File
  ipbam1:
    type: File
  ipbai1:
    type: File
  inbam1:
    type: File
  inbai1:
    type: File




outputs:

  peaksnormalized_bed:
    type: File
    outputSource: overlapize/output_bed



steps:

###########################################################################
# Look up triplets2
###########################################################################

  lookupindexpair2:
    run: lookupindexpair.cwl
    in:
      pair: pair2
      name_s: name_s
    out: [ipindex, inindex]

  lookup2:
    run: lookuptripletpair.cwl
    in:
      ipindex: lookupindexpair2/ipindex
      inindex: lookupindexpair2/inindex
      triplet_s: triplet_s
    out: [ipbed, ipbam, ipbai, inbed, inbam, inbai]

###########################################################################
# Normalize
###########################################################################


  overlapize:
    run: peaksoverlapize.cwl


    in:
      ipbed1: ipbed1
      ipbam1: ipbam1
      ipbai1: ipbai1

      inbam1: inbam1
      inbai1: inbai1

      ipbed2: lookup2/ipbed
      ipbam2: lookup2/ipbam
      ipbai2: lookup2/ipbai

      inbam2: lookup2/inbam
      inbai2: lookup2/inbai

    out: [
      output_bed                            #, output_bedfull
      ]
