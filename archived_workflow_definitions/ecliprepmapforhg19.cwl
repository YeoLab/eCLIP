#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

#requirements:
#  - class: SubworkflowFeatureRequirement
#  - class: MultipleInputFeatureRequirement


baseCommand: [ecliprepmapforhg19.sh]


inputs:


  species:
    type: string
    inputBinding:
      position: 1



  barcode1r1FastqGz:
    type: File
    inputBinding:
      position: 2

  barcode1r2FastqGz:
    type: File
    inputBinding:
      position: 3

  barcode1rmRepBam:
    type: File
    inputBinding:
      position: 4


  barcode2r1FastqGz:
    type: File
    inputBinding:
      position: 5

  barcode2r2FastqGz:
    type: File
    inputBinding:
      position: 6

  barcode2rmRepBam:
    type: File
    inputBinding:
      position: 7



  dorepmap:
    type: boolean
    default: False
    inputBinding:
      position: 8
      prefix: --dorepmap


outputs: []


#  barcode1concatenatedRmDupSam:
#    type: File
#    outputSource: ecliprepmap_barcode1/concatenatedRmDupSam
#  barcode2concatenatedRmDupSam:
#    type: File
#    outputSource: ecliprepmap_barcode2/concatenatedRmDupSam
#  concatenatedRmDupSam:
#    type: File
#    outputSource: concatenate_rmdup_barcodes/concatenatedsam
#
#  barcode1concatenatedPreRmDupSam:
#    type: File
#    outputSource: ecliprepmap_barcode1/concatenatedDupSam
#  barcode2concatenatedPreRmDupSam:
#    type: File
#    outputSource: ecliprepmap_barcode2/concatenatedDupSam
#  concatenatedPreRmDupSam:
#    type: File
#    outputSource: concatenate_prermdup_barcodes/concatenatedsam
#
#  combinedParsed:
#    type: File
#    outputSource: combine_parsed/output




