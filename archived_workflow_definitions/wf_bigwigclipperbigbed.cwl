#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement

#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  dataset:
    type: string
  name:
    type: string
  species:
    type: string
    default: hg19
  chromsizes:
     type: File
  input_bam:
    type: File


outputs:

  X_output_view_r2bam:
    type: File
    outputSource: X_viewr2/output_view_r2bam
  X_output_index_bai:
    type: File
    outputSource: X_index/output_index_bai

  X_posbw:
    type: File
    outputSource: X_bamtobigwigs/posbw
  X_negbw:
    type: File
    outputSource: X_bamtobigwigs/negbw
  #X_posbg:
  #  type: File
  #  outputSource: X_bamtobigwigs/posbg
  #X_negbg:
  #  type: File
  #  outputSource: X_bamtobigwigs/negbg
  #X_noposbg:
  #  type: File
  #  outputSource: X_bamtobigwigs/noposbg
  #X_nonegbg:
  #  type: File
  #  outputSource: X_bamtobigwigs/nonegbg
  #X_nonegtbg:
  #  type: File
  #  outputSource: X_bamtobigwigs/nonegtbg
  X_trackdbtxt:
    type: File
    outputSource: X_makerackhubs/trackdbtxt
  X_hubtxt:
    type: File
    outputSource: X_makerackhubs/hubtxt
  X_genomestxt:
    type: File
    outputSource: X_makerackhubs/genomestxt
  X_pos_bw:
    type: File
    outputSource: X_makerackhubs/pos_bw
  X_neg_bw:
    type: File
    outputSource: X_makerackhubs/neg_bw


  X_output_clipper_bed:
    type: File
    outputSource: X_clipper/output_bed
  X_output_clipper_pickle:
    type: File
    outputSource: X_clipper/output_pickle

  X_output_clipper_log:
    type: File
    outputSource: X_clipper/output_log

  X_output_fixscores_bed:
    type: File
    outputSource: X_fixscores/output_bed

  X_output_bedsort_bed:
    type: File
    outputSource: X_bedsort/output_bed

  X_bigbed:
    type: File
    outputSource: X_bedtobigbed/output_bigbed

  X_triplet:
    type: Any
    outputSource: X_regrouptriplet/triplet

  #X_triplet:
  #  type:
  #    type: record
  #    fields:
  #      bam:
  #        type: File
  #        outputSource: X_viewr2/output_view_r2bam
  #      bai:
  #        type: File
  #        outputSource: X_index/output_index_bai
  #      peaks_bed:
  #        type: File
  #        outputSource: X_clipper/output_clipper_bed

steps:

  # Common preliminary : from bam, get read2 and make bai
  ####################

  X_viewr2:
    run: viewr2.cwl
    in:
      input_view_bam: input_bam
    out: [output_view_r2bam]

  X_index:
    run: index.cwl
    in:
      input_index_bam: X_viewr2/output_view_r2bam
    out: [output_index_bai]


  # 1 of 4 : generate bigwigs for pre-clipper alignement data
  ###########################################################

  # the above two (bam and bai) also serve as inputs to the normalization step

  X_bamtobigwigs:
    run: makebigwigfiles.cwl
    in:
      bam: X_viewr2/output_view_r2bam
      bai: X_index/output_index_bai
      chromsizes: chromsizes
    out: [posbw, negbw
          #, posbg, negbg, noposbg, nonegbg, nonegtbg
         ]

  # 2 of 4 : call peaks with clipper and produce bed and bigbed formats
  ##########################################################################

  X_clipper:
    #run: /projects/ps-yeolab/software/clipper/clipper-1.1.201704fasterpeaks/bin/clipper.cwl
    run: clipper.cwl
    in:
      species: species
      bam: X_viewr2/output_view_r2bam
    out: [
          output_bed,
          output_pickle,
          output_log
         ]

  # 3 of 4 : generate bigbed for post-clipper peaks data
  #######################################################

  X_fixscores:
    run: fixscores.cwl
    in:
      input_bed: X_clipper/output_bed
    out: [output_bed]

  X_bedsort:
    run: bedsort.cwl
    in:
      input_bed: X_fixscores/output_bed
    out: [output_bed]


  X_bedtobigbed:
    run: bedtobigbed.cwl
    in:
      input_bed: X_bedsort/output_bed
      input_chromsizes: chromsizes
    out: [output_bigbed]


  # 4 of 4 : generate trackhubs for bigwigs and bigbed
  #####################################################

  X_makerackhubs:
    run: maketrackhubs.cwl
    in:
      dataset: dataset
      name:    name
      species: species
      posbw: X_bamtobigwigs/posbw
      negbw: X_bamtobigwigs/negbw
      input_bigbed: X_bedtobigbed/output_bigbed
    out: [ trackdbtxt,
           hubtxt,
           genomestxt,
           pos_bw,
           neg_bw,
           output_bigbed
           ]


  # Postscriptum: regroup triplet for feeding normalization step
  ##############################################################

  X_regrouptriplet:
    run: regrouptriplet.cwl
    in:
      dataset: dataset
      name: name
      bed:  X_clipper/output_bed
      bam:  X_viewr2/output_view_r2bam
      bai:  X_index/output_index_bai
    out: [triplet]
