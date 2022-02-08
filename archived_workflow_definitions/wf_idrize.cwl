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

#  annotateref:
#    type: File

  idrpair:
    type:
      type: record
      fields:
        ip1:
          type: string
        ip2:
          type: string
        in1:
          type: string
        in2:
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

outputs: []


steps:

###########################################################################
# Look up triplets
###########################################################################

  lookupindexidrpair:
    run: lookupindexidrpair.cwl
    in:
      idrpair: idrpair
      name_s: name_s
    out: [ip1index, ip2index, in1index, in2index]

  lookup:
    run: lookupbamidrpair.cwl
    in:
      ip1index: lookupindexidrpair/ip1index
      ip2index: lookupindexidrpair/ip2index
      in1index: lookupindexidrpair/in1index
      in2index: lookupindexidrpair/in2index
      triplet_s: triplet_s
    out: [ip1bam, ip2bam, in1bam, in2bam ]

###########################################################################
# IDR ratios
###########################################################################

  ABI_idrselfconsistencyratio:
    run: eclipidrselfconsistencyratio.cwl
    in:
      ip1bam: lookup/ip1bam
      ip2bam: lookup/ip2bam
      in1bam: lookup/in1bam
      in2bam: lookup/in2bam
      species: species
    out: [

      ]

  ABI_idrrescueratio:
    run: eclipidrrescueratio.cwl
    in:
      ip1bam: lookup/ip1bam
      ip2bam: lookup/ip2bam
      in1bam: lookup/in1bam
      in2bam: lookup/in2bam
      species: species
    out: [

      ]








