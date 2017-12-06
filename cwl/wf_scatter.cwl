#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement

#hints:
  #- class: ex:ScriptRequirement
  #  scriptlines:
  #    - "#!/bin/bash"


inputs:


  barcodesfasta:
    type: File



  species:
    type: string

  dataset:
    type: string

  seqdatapath:
      type: string
      default: "./"

  randomer_length:
    type: string

  out_filter_multimap_nmax_1:
    type: string
    default: "1"

  clipalize_items:
    #default: []
    type:
      type: array
      items:
        type: record
        fields:
          fwd:
            type: File
          rev:
            type: File
          name:
            type: string
          barcodeids:
            type: string[]

  normalize_items:
    type:
      type: array
      items:
        type: record
        fields:
          ip:
            type: string
          in:
            type: string

  idrize_items:
    type:
      type: array
      items:
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


  l2fc:
    type: string
    default: "1"
  pval:
    type: string
    default: "1"


  dorepmap:
    type: boolean
    default: False


outputs:

  name_s:
    outputSource: scatter_clipalize/AB_name
    type: string[]

  triplet_s:
    outputSource: scatter_clipalize/AB_triplet
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

  bed_s:
    type: File[]
    outputSource: scatter_clipalize/AB_output_clipper_bed
  pickle_s:
    type: File[]
    outputSource: scatter_clipalize/AB_output_clipper_pickle
  log_s:
    type: File[]
    outputSource: scatter_clipalize/AB_output_clipper_log
  bam_s:
    type: File[]
    outputSource: scatter_clipalize/AB_output_view_r2bam
  bai_s:
    type: File[]
    outputSource: scatter_clipalize/AB_output_index_bai

  posbw_s:
    type: File[]
    outputSource: scatter_clipalize/AB_posbw
  negbw_s:
    type: File[]
    outputSource: scatter_clipalize/AB_negbw
  #posbg_s:
  #  type: File[]
  #  outputSource: scatter_clipalize/AB_posbg
  #negbg_s:
  #  type: File[]
  #  outputSource: scatter_clipalize/AB_negbg
  #noposbg_s:
  #  type: File[]
  #  outputSource: scatter_clipalize/AB_noposbg
  #nonegbg_s:
  #  type: File[]
  #  outputSource: scatter_clipalize/AB_nonegbg
  #nonegtbg_s:
  #  type: File[]
  #  outputSource: scatter_clipalize/AB_nonegtbg
  trackdbtxt_s:
    type: File[]
    outputSource: scatter_clipalize/AB_trackdbtxt
  hubtxt_s:
    type: File[]
    outputSource: scatter_clipalize/AB_hubtxt
  genomestxt_s:
    type: File[]
    outputSource: scatter_clipalize/AB_genomestxt
  pos_bw_s:
    type: File[]
    outputSource: scatter_clipalize/AB_pos_bw
  neg_bw_s:
    type: File[]
    outputSource: scatter_clipalize/AB_neg_bw

  bigbed_s:
    type: File[]
    outputSource: scatter_clipalize/AB_bigbed

  demuxedAfwd:
    type: File[]
    outputSource: scatter_clipalize/demuxedAfwd
  demuxedArev:
    type: File[]
    outputSource: scatter_clipalize/demuxedArev
  demuxedBfwd:
    type: File[]
    outputSource: scatter_clipalize/demuxedBfwd
  demuxedBrev:
    type: File[]
    outputSource: scatter_clipalize/demuxedBrev

  AB_merge_bam:
    type: File[]
    outputSource: scatter_clipalize/AB_merge_bam
  AB_output_fixscores_bed:
    type: File[]
    outputSource: scatter_clipalize/AB_output_fixscores_bed
  AB_output_bedsort_bed:
    type: File[]
    outputSource: scatter_clipalize/AB_output_bedsort_bed


  A_output_trim_fwd:
    type: File[]
    outputSource: scatter_clipalize/A_output_trim_fwd
  A_output_trim_rev:
    type: File[]
    outputSource: scatter_clipalize/A_output_trim_rev
  A_output_trim_report:
    type: File[]
    outputSource: scatter_clipalize/A_output_trim_report
  A_output_trimagain_fwd:
    type: File[]
    outputSource: scatter_clipalize/A_output_trimagain_fwd
  A_output_trimagain_rev:
    type: File[]
    outputSource: scatter_clipalize/A_output_trimagain_rev
  A_output_trimagain_report:
    type: File[]
    outputSource: scatter_clipalize/A_output_trimagain_report
  A_output_maprepeats_unmapped_fwd:
    type: File[]
    outputSource: scatter_clipalize/A_output_maprepeats_unmapped_fwd
  A_output_maprepeats_unmapped_rev:
    type: File[]
    outputSource: scatter_clipalize/A_output_maprepeats_unmapped_rev
  A_output_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: scatter_clipalize/A_output_maprepeats_mapped_to_genome
  A_output_maprepeats_stats:
    type: File[]
    outputSource: scatter_clipalize/A_output_maprepeats_stats
  A_output_fastqsort_sortedfastq_fwd:
    type: File[]
    outputSource: scatter_clipalize/A_output_fastqsort_sortedfastq_fwd
  A_output_fastqsort_sortedfastq_rev:
    type: File[]
    outputSource: scatter_clipalize/A_output_fastqsort_sortedfastq_rev
  A_output_map_mapped_to_genome:
    type: File[]
    outputSource: scatter_clipalize/A_output_map_mapped_to_genome
  A_output_map_stats:
    type: File[]
    outputSource: scatter_clipalize/A_output_map_stats
  A_output_map_unmapped_fwd:
    type: File[]
    outputSource: scatter_clipalize/A_output_map_unmapped_fwd
  A_output_map_unmapped_rev:
    type: File[]
    outputSource: scatter_clipalize/A_output_map_unmapped_rev
  A_output_barcodecollapsepe_bam:
    type: File[]
    outputSource: scatter_clipalize/A_output_barcodecollapsepe_bam
  A_output_barcodecollapsepe_metrics:
    type: File[]
    outputSource: scatter_clipalize/A_output_barcodecollapsepe_metrics
  A_output_sort_bam:
    type: File[]
    outputSource: scatter_clipalize/A_output_sort_bam
  A_output_index_bai:
    type: File[]
    outputSource: scatter_clipalize/A_output_index_bai

  B_output_trim_fwd:
    type: File[]
    outputSource: scatter_clipalize/B_output_trim_fwd
  B_output_trim_rev:
    type: File[]
    outputSource: scatter_clipalize/B_output_trim_rev
  B_output_trim_report:
    type: File[]
    outputSource: scatter_clipalize/B_output_trim_report
  B_output_trimagain_fwd:
    type: File[]
    outputSource: scatter_clipalize/B_output_trimagain_fwd
  B_output_trimagain_rev:
    type: File[]
    outputSource: scatter_clipalize/B_output_trimagain_rev
  B_output_trimagain_report:
    type: File[]
    outputSource: scatter_clipalize/B_output_trimagain_report
  B_output_maprepeats_unmapped_fwd:
    type: File[]
    outputSource: scatter_clipalize/B_output_maprepeats_unmapped_fwd
  B_output_maprepeats_unmapped_rev:
    type: File[]
    outputSource: scatter_clipalize/B_output_maprepeats_unmapped_rev
  B_output_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: scatter_clipalize/B_output_maprepeats_mapped_to_genome
  B_output_maprepeats_stats:
    type: File[]
    outputSource: scatter_clipalize/B_output_maprepeats_stats
  B_output_fastqsort_sortedfastq_fwd:
    type: File[]
    outputSource: scatter_clipalize/B_output_fastqsort_sortedfastq_fwd
  B_output_fastqsort_sortedfastq_rev:
    type: File[]
    outputSource: scatter_clipalize/B_output_fastqsort_sortedfastq_rev
  B_output_map_mapped_to_genome:
    type: File[]
    outputSource: scatter_clipalize/B_output_map_mapped_to_genome
  B_output_map_stats:
    type: File[]
    outputSource: scatter_clipalize/B_output_map_stats
  B_output_map_unmapped_fwd:
    type: File[]
    outputSource: scatter_clipalize/B_output_map_unmapped_fwd
  B_output_map_unmapped_rev:
    type: File[]
    outputSource: scatter_clipalize/B_output_map_unmapped_rev
  B_output_barcodecollapsepe_bam:
    type: File[]
    outputSource: scatter_clipalize/B_output_barcodecollapsepe_bam
  B_output_barcodecollapsepe_metrics:
    type: File[]
    outputSource: scatter_clipalize/B_output_barcodecollapsepe_metrics
  B_output_sort_bam:
    type: File[]
    outputSource: scatter_clipalize/B_output_sort_bam
  B_output_index_bai:
    type: File[]
    outputSource: scatter_clipalize/B_output_index_bai


  peaksnormalizedperl_bed_s:
    type: File[]
    outputSource: scatter_normalize/peaksnormalizedperl_bed
  peaksnormalizedperl_bedfull_s:
    type: File[]
    outputSource: scatter_normalize/peaksnormalizedperl_bedfull
  peaksnormalizedpy_bed_s:
    type: File[]
    outputSource: scatter_normalize/peaksnormalizedpy_bed
  peaksnormalizedpy_bedfull_s:
    type: File[]
    outputSource: scatter_normalize/peaksnormalizedpy_bedfull

#  peaksnormalizedpy1_bed_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy1_bed
#  peaksnormalizedpy1_bedfull_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy1_bedfull
#  peaksnormalizedpy2_bed_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy2_bed
#  peaksnormalizedpy2_bedfull_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy2_bedfull
#  peaksnormalizedpy3_bed_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy3_bed
#  peaksnormalizedpy3_bedfull_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy3_bedfull
#  peaksnormalizedpy4_bed_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy4_bed
#  peaksnormalizedpy4_bedfull_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksnormalizedpy4_bedfull


  peaksnormalizedperlcompressedperl_bed_s:
    type: File[]
    outputSource: scatter_normalize/peaksnormalizedperlcompressedperl_bed
  peaksnormalizedpycompressedpy_bed_s:
    type: File[]
    outputSource: scatter_normalize/peaksnormalizedpycompressedpy_bed


#  peaksannotated_bed_s:
#    type: File[]
#    outputSource: scatter_normalize/peaksannotated_bed


  filteredpeaksperl_bed_s:
    type: File[]
    outputSource: scatter_normalize/filteredpeaksperl_bed
  filteredpeakspy_bed_s:
    type: File[]
    outputSource: scatter_normalize/filteredpeakspy_bed


  #clipanalysis_metrics_s:
  #  type: File[]
  #  outputSource: scatter_normalize/clipanalysis_metrics



  peaksoverlapized_bed_s_s:
    type:
      type: array
      items: Any
    outputSource: scatter_scatter_overlapize/peaksnormalized_bed_s


steps:

  parsespecies:
    run: parsespecies.cwl
    in:

      species: species
    out: [chromsizes, starrefrepeats, starrefgenome, annotateref]



  scatter_clipalize:

    run: wf_clipalize.cwl
    ####################
    scatter: readsABitem
    ####################
    in:
      readsABitem: clipalize_items
      barcodesfasta: barcodesfasta
      randomer_length: randomer_length
      species: species
      dataset: dataset
      seqdatapath: seqdatapath
      chromsizes: parsespecies/chromsizes
      starrefrepeats: parsespecies/starrefrepeats
      starrefgenome: parsespecies/starrefgenome
      out_filter_multimap_nmax_1: out_filter_multimap_nmax_1
      dorepmap:  dorepmap

    out: [

      demuxedAfwd,
      demuxedArev,
      demuxedBfwd,
      demuxedBrev,
      
      A_output_trim_fwd,
      A_output_trim_rev,
      A_output_trim_report,
      A_output_trimagain_fwd,
      A_output_trimagain_rev,
      A_output_trimagain_report,
      A_output_maprepeats_unmapped_fwd,
      A_output_maprepeats_unmapped_rev,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_fastqsort_sortedfastq_fwd,
      A_output_fastqsort_sortedfastq_rev,
      A_output_map_mapped_to_genome,
      A_output_map_stats,
      A_output_map_unmapped_fwd,
      A_output_map_unmapped_rev,
      A_output_barcodecollapsepe_bam,
      A_output_barcodecollapsepe_metrics,
      A_output_sort_bam,
      A_output_index_bai,
      
      B_output_trim_fwd,
      B_output_trim_rev,
      B_output_trim_report,
      B_output_trimagain_fwd,
      B_output_trimagain_rev,
      B_output_trimagain_report,
      B_output_maprepeats_unmapped_fwd,
      B_output_maprepeats_unmapped_rev,
      B_output_maprepeats_mapped_to_genome,
      B_output_maprepeats_stats,
      B_output_fastqsort_sortedfastq_fwd,
      B_output_fastqsort_sortedfastq_rev,
      B_output_map_mapped_to_genome,
      B_output_map_stats,
      B_output_map_unmapped_fwd,
      B_output_map_unmapped_rev,
      B_output_barcodecollapsepe_bam,
      B_output_barcodecollapsepe_metrics,
      B_output_sort_bam,
      B_output_index_bai,

      AB_merge_bam,
      AB_output_fixscores_bed,
      AB_output_bedsort_bed,

      AB_output_view_r2bam,
      AB_output_index_bai,
      AB_posbw, AB_negbw,
      #, AB_posbg, AB_negbg, AB_noposbg, AB_nonegbg, AB_nonegtbg,
      AB_trackdbtxt,
      AB_hubtxt,
      AB_genomestxt,
      AB_pos_bw, AB_neg_bw,

      AB_output_clipper_bed,
      AB_output_clipper_pickle,
      AB_output_clipper_log,
      AB_bigbed,

      AB_name,
      AB_triplet
    ]

  scatter_normalize:

    run: wf_normalize.cwl
    #############
    scatter: pair
    #############
    in:
      species: species
      annotateref: parsespecies/annotateref
      pair: normalize_items
      name_s: scatter_clipalize/AB_name
      triplet_s: scatter_clipalize/AB_triplet
      l2fc: l2fc
      pval: pval

    out: [
      peaksnormalizedperl_bed, peaksnormalizedperl_bedfull,
      peaksnormalizedpy_bed, peaksnormalizedpy_bedfull,

      #peaksnormalizedpy1_bed, peaksnormalizedpy1_bedfull, peaksnormalizedpy2_bed, peaksnormalizedpy2_bedfull, peaksnormalizedpy3_bed, peaksnormalizedpy3_bedfull, peaksnormalizedpy4_bed, peaksnormalizedpy4_bedfull,

      peaksnormalizedperlcompressedperl_bed,
      peaksnormalizedpycompressedpy_bed,

      #peaksannotated_bed,

      filteredpeaksperl_bed,
      filteredpeakspy_bed
#      ,
#      clipanalysis_metrics,
#      output_clipanalysis_qcfig,
#      output_clipanalysis_distfig
    ]




  scatter_idrize:

    run: wf_idrize.cwl
    ################
    scatter: idrpair
    ################
    in:
      species: species
      idrpair: idrize_items
      name_s: scatter_clipalize/AB_name
      triplet_s: scatter_clipalize/AB_triplet
    out: [

    ]





  scatter_scatter_overlapize:

    run: wf_scatter_overlapize.cwl
    ##############
    scatter: pair1
    ##############
    in:
      species: species
      pair1:  overlapize_items
      pair2s: overlapize_items
      name_s: scatter_clipalize/AB_name
      triplet_s: scatter_clipalize/AB_triplet

    out: [
      peaksnormalized_bed_s,
    ]
