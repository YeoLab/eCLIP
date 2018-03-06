#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  #- class: InlineJavascriptRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  barcodesfasta:
    type: File
  randomer_length:
    type: string

  species:
    type: string
  dataset:
    type: string
  seqdatapath:
      type: string
      default: "./"

  chromsizes:
    type: File
  starrefrepeats:
    type: File
  starrefgenome:
    type: File

  out_filter_multimap_nmax_1:
    type: string

  readsABitem:
    type:

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

  dorepmap:
    type: boolean
    default: False

outputs:

  demuxedAfwd:
    type: File
    outputSource: demuxAB/demuxedAfwd
  demuxedArev:
    type: File
    outputSource: demuxAB/demuxedArev
  demuxedBfwd:
    type: File
    outputSource: demuxAB/demuxedBfwd
  demuxedBrev:
    type: File
    outputSource: demuxAB/demuxedBrev

  A_output_trim_fwd:
    type: File
    outputSource: A_trimmapcollapse/X_output_trim_fwd
  A_output_trim_rev:
    type: File
    outputSource: A_trimmapcollapse/X_output_trim_rev
  A_output_trim_report:
    type: File
    outputSource: A_trimmapcollapse/X_output_trim_report
  A_output_trimagain_fwd:
    type: File
    outputSource: A_trimmapcollapse/X_output_trimagain_fwd
  A_output_trimagain_rev:
    type: File
    outputSource: A_trimmapcollapse/X_output_trimagain_rev
  A_output_trimagain_report:
    type: File
    outputSource: A_trimmapcollapse/X_output_trimagain_report

  A_output_maprepeats_unmapped_fwd:
    type: File
    outputSource: A_trimmapcollapse/X_output_maprepeats_unmapped_fwd
  A_output_maprepeats_unmapped_rev:
    type: File
    outputSource: A_trimmapcollapse/X_output_maprepeats_unmapped_rev
  A_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: A_trimmapcollapse/X_output_maprepeats_mapped_to_genome
  A_output_maprepeats_stats:
    type: File
    outputSource: A_trimmapcollapse/X_output_maprepeats_stats

  A_output_fastqsort_sortedfastq_fwd:
    type: File
    outputSource: A_trimmapcollapse/X_output_fastqsort_sortedfastq_fwd
  A_output_fastqsort_sortedfastq_rev:
    type: File
    outputSource: A_trimmapcollapse/X_output_fastqsort_sortedfastq_rev

  A_output_map_mapped_to_genome:
    type: File
    outputSource: A_trimmapcollapse/X_output_map_mapped_to_genome
  A_output_map_stats:
    type: File
    outputSource: A_trimmapcollapse/X_output_map_stats
  A_output_map_unmapped_fwd:
    type: File
    outputSource: A_trimmapcollapse/X_output_map_unmapped_fwd
  A_output_map_unmapped_rev:
    type: File
    outputSource: A_trimmapcollapse/X_output_map_unmapped_rev

  A_output_barcodecollapsepe_bam:
    type: File
    outputSource: A_trimmapcollapse/X_output_barcodecollapsepe_bam
  A_output_barcodecollapsepe_metrics:
    type: File
    outputSource: A_trimmapcollapse/X_output_barcodecollapsepe_metrics

  A_output_sort_bam:
    type: File
    outputSource: A_trimmapcollapse/X_output_sort_bam
  A_output_index_bai:
    type: File
    outputSource: A_trimmapcollapse/X_output_index_bai


  B_output_trim_fwd:
    type: File
    outputSource: B_trimmapcollapse/X_output_trim_fwd
  B_output_trim_rev:
    type: File
    outputSource: B_trimmapcollapse/X_output_trim_rev
  B_output_trim_report:
    type: File
    outputSource: B_trimmapcollapse/X_output_trim_report
  B_output_trimagain_fwd:
    type: File
    outputSource: B_trimmapcollapse/X_output_trimagain_fwd
  B_output_trimagain_rev:
    type: File
    outputSource: B_trimmapcollapse/X_output_trimagain_rev
  B_output_trimagain_report:
    type: File
    outputSource: B_trimmapcollapse/X_output_trimagain_report

  B_output_maprepeats_unmapped_fwd:
    type: File
    outputSource: B_trimmapcollapse/X_output_maprepeats_unmapped_fwd
  B_output_maprepeats_unmapped_rev:
    type: File
    outputSource: B_trimmapcollapse/X_output_maprepeats_unmapped_rev
  B_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: B_trimmapcollapse/X_output_maprepeats_mapped_to_genome
  B_output_maprepeats_stats:
    type: File
    outputSource: B_trimmapcollapse/X_output_maprepeats_stats

  B_output_fastqsort_sortedfastq_fwd:
    type: File
    outputSource: B_trimmapcollapse/X_output_fastqsort_sortedfastq_fwd
  B_output_fastqsort_sortedfastq_rev:
    type: File
    outputSource: B_trimmapcollapse/X_output_fastqsort_sortedfastq_rev

  B_output_map_mapped_to_genome:
    type: File
    outputSource: B_trimmapcollapse/X_output_map_mapped_to_genome
  B_output_map_stats:
    type: File
    outputSource: B_trimmapcollapse/X_output_map_stats
  B_output_map_unmapped_fwd:
    type: File
    outputSource: B_trimmapcollapse/X_output_map_unmapped_fwd
  B_output_map_unmapped_rev:
    type: File
    outputSource: B_trimmapcollapse/X_output_map_unmapped_rev

  B_output_barcodecollapsepe_bam:
    type: File
    outputSource: B_trimmapcollapse/X_output_barcodecollapsepe_bam
  B_output_barcodecollapsepe_metrics:
    type: File
    outputSource: B_trimmapcollapse/X_output_barcodecollapsepe_metrics

  B_output_sort_bam:
    type: File
    outputSource: B_trimmapcollapse/X_output_sort_bam
  B_output_index_bai:
    type: File
    outputSource: B_trimmapcollapse/X_output_index_bai



#  AB_barcode1concatenatedRmDupSam:
#    type: File
#    outputSource: AB_ecliprepmap/barcode1concatenatedRmDupSam
#  AB_barcode2concatenatedRmDupSam:
#    type: File
#    outputSource: AB_ecliprepmap/barcode2concatenatedRmDupSam
#  AB_concatenatedRmDupSam:
#    type: File
#    outputSource: AB_ecliprepmap/concatenatedRmDupSam
#  AB_barcode1concatenatedPreRmDupSam:
#    type: File
#    outputSource: AB_ecliprepmap/barcode1concatenatedPreRmDupSam
#  AB_barcode2concatenatedPreRmDupSam:
#    type: File
#    outputSource: AB_ecliprepmap/barcode2concatenatedPreRmDupSam
#  AB_concatenatedPreRmDupSam:
#    type: File
#    outputSource: AB_ecliprepmap/concatenatedPreRmDupSam
#  AB_combinedParsed:
#    type: File
#    outputSource: AB_ecliprepmap/combinedParsed



  AB_merge_bam:
    type: File
    outputSource: AB_merge/output_merge_bam



  AB_output_view_r2bam:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_output_view_r2bam

  AB_output_index_bai:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_output_index_bai

  AB_posbw:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_posbw
  AB_negbw:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_negbw
  #AB_posbg:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_posbg
  #AB_negbg:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_negbg
  #AB_noposbg:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_noposbg
  #AB_nonegbg:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_nonegbg
  #AB_nonegtbg:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_nonegtbg

  AB_trackdbtxt:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_trackdbtxt
  AB_hubtxt:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_hubtxt
  AB_genomestxt:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_genomestxt
  AB_pos_bw:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_pos_bw
  AB_neg_bw:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_neg_bw


  #AB_output_bamtobigwigs_normposbw:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_output_bamtobigwigs_normposbw
  #AB_output_bamtobigwigs_normnegbw:
  #  type: File
  #  outputSource: AB_bigwigclipperbigbed/X_output_bamtobigwigs_normnegbw

  AB_output_clipper_bed:
     type: File
     outputSource: AB_bigwigclipperbigbed/X_output_clipper_bed
  AB_output_clipper_pickle:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_output_clipper_pickle

  AB_output_clipper_log:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_output_clipper_log

  AB_output_fixscores_bed:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_output_fixscores_bed

  AB_output_bedsort_bed:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_output_bedsort_bed

  AB_bigbed:
    type: File
    outputSource: AB_bigwigclipperbigbed/X_bigbed

  AB_name:
    type: string
    outputSource: demuxAB/name

  AB_triplet:
    outputSource: AB_bigwigclipperbigbed/X_triplet
    type: Any

    #type:
    #  type: record
    #  fields:
    #    name:
    #      type: string
    #      outputSource: demuxAB/name
    #    bed:
    #      type: File
    #      outputSource: AB_bigwigclipperbigbed/X_output_clipper_bed
    #    bam:
    #      type: File
    #      outputSource: AB_bigwigclipperbigbed/X_output_view_r2bam
    #    bai:
    #      type: File
    #      outputSource: AB_bigwigclipperbigbed/X_output_index_bai


steps:

###########################################################################
# Concat
###########################################################################









###########################################################################
# Demux
###########################################################################

  demuxAB:
    run: demux.cwl
    in:
      barcodesfasta: barcodesfasta
      randomer_length: randomer_length
      dataset: dataset
      seqdatapath: seqdatapath
      readsX: readsABitem
    out: [demuxedAfwd, demuxedArev,
          demuxedBfwd, demuxedBrev,
          output_demuxedpairedend_metrics,
          output_dataset,
          name,
          barcodeidA,
          barcodeidB
         ]

###########################################################################
# Parse inputs
###########################################################################

  parsespecies:
    run: parsespecies.cwl
    in:
      species: species
    out: [chromsizes, starrefrepeats, starrefgenome, annotateref]


###########################################################################
# Parse barcodes
###########################################################################

  parsebarcodesAB:
    run: parsebarcodes.cwl
    in:
      randomer_length: randomer_length
      barcodeidA: demuxAB/barcodeidA
      barcodeidB: demuxAB/barcodeidB
      barcodesfasta: barcodesfasta
    out: [trimfirst_overlap_length, trimagain_overlap_length,
          g_adapters_default, a_adapters_default,
          g_adapters, a_adapters, A_adapters
          ]

###########################################################################
# Upstream
###########################################################################

  A_trimmapcollapse:
      run: wf_trimmapcollapse.cwl
      in:
        reads_Xfwd: demuxAB/demuxedAfwd
        reads_Xrev: demuxAB/demuxedArev

        trimfirst_overlap_length: parsebarcodesAB/trimfirst_overlap_length
        g_adapters: parsebarcodesAB/g_adapters
        a_adapters: parsebarcodesAB/a_adapters
        A_adapters: parsebarcodesAB/A_adapters

        trimagain_overlap_length: parsebarcodesAB/trimagain_overlap_length
        g_adapters_default: parsebarcodesAB/g_adapters_default
        a_adapters_default: parsebarcodesAB/a_adapters_default

        chromsizes: parsespecies/chromsizes
        starrefrepeats: parsespecies/starrefrepeats
        starrefgenome: parsespecies/starrefgenome

        out_filter_multimap_nmax_1: out_filter_multimap_nmax_1

      out: [
        X_output_trim_fwd,
        X_output_trim_rev,
        X_output_trim_report,
        X_output_trimagain_fwd,
        X_output_trimagain_rev,
        X_output_trimagain_report,

        X_output_maprepeats_unmapped_fwd,
        X_output_maprepeats_unmapped_rev,
        X_output_maprepeats_mapped_to_genome,
        X_output_maprepeats_stats,

        X_output_fastqsort_sortedfastq_fwd,
        X_output_fastqsort_sortedfastq_rev,

        X_output_map_mapped_to_genome,
        X_output_map_stats,
        X_output_map_unmapped_fwd,
        X_output_map_unmapped_rev,
        
        X_output_barcodecollapsepe_bam,
        X_output_barcodecollapsepe_metrics,

        X_output_sort_bam,
        X_output_index_bai
        ]

  B_trimmapcollapse:
      run: wf_trimmapcollapse.cwl
      in:
        reads_Xfwd: demuxAB/demuxedBfwd
        reads_Xrev: demuxAB/demuxedBrev

        trimfirst_overlap_length: parsebarcodesAB/trimfirst_overlap_length
        g_adapters: parsebarcodesAB/g_adapters
        a_adapters: parsebarcodesAB/a_adapters
        A_adapters: parsebarcodesAB/A_adapters

        trimagain_overlap_length: parsebarcodesAB/trimagain_overlap_length
        g_adapters_default: parsebarcodesAB/g_adapters_default
        a_adapters_default: parsebarcodesAB/a_adapters_default

        chromsizes: parsespecies/chromsizes
        starrefrepeats: parsespecies/starrefrepeats
        starrefgenome: parsespecies/starrefgenome

        out_filter_multimap_nmax_1: out_filter_multimap_nmax_1

      out: [
        X_output_trim_fwd,
        X_output_trim_rev,
        X_output_trim_report,
        X_output_trimagain_fwd,
        X_output_trimagain_rev,
        X_output_trimagain_report,

        X_output_maprepeats_unmapped_fwd,
        X_output_maprepeats_unmapped_rev,
        X_output_maprepeats_mapped_to_genome,
        X_output_maprepeats_stats,

        X_output_fastqsort_sortedfastq_fwd,
        X_output_fastqsort_sortedfastq_rev,

        X_output_map_mapped_to_genome,
        X_output_map_stats,
        X_output_map_unmapped_fwd,
        X_output_map_unmapped_rev,
        X_output_barcodecollapsepe_bam,
        X_output_barcodecollapsepe_metrics,

        X_output_sort_bam,
        X_output_index_bai
        ]



###########################################################################
# Map to repetititive elements
###########################################################################

  AB_ecliprepmap:
      run: ecliprepmapforhg19.cwl
      in:
        dorepmap: dorepmap
        species: species
        barcode1r1FastqGz: demuxAB/demuxedAfwd
        barcode1r2FastqGz: demuxAB/demuxedArev
        barcode1rmRepBam: A_trimmapcollapse/X_output_sort_bam
        barcode2r1FastqGz: demuxAB/demuxedBfwd
        barcode2r2FastqGz: demuxAB/demuxedBrev
        barcode2rmRepBam: B_trimmapcollapse/X_output_sort_bam
      out: [
#        barcode1concatenatedRmDupSam,
#        barcode2concatenatedRmDupSam,
#        concatenatedRmDupSam,
#        barcode1concatenatedPreRmDupSam,
#        barcode2concatenatedPreRmDupSam,
#        concatenatedPreRmDupSam,
#        combinedParsed
        ]

###########################################################################
# Merge barcode replicates
###########################################################################

  AB_merge:
    run: merge.cwl
    in:
      barcodeidA: demuxAB/barcodeidA
      barcodeidB: demuxAB/barcodeidB
      input_merge_bam1: A_trimmapcollapse/X_output_sort_bam
      input_merge_bam2: B_trimmapcollapse/X_output_sort_bam
    out: [output_merge_bam]

###########################################################################
# Downstream
###########################################################################

  AB_bigwigclipperbigbed:
    run: wf_bigwigclipperbigbed.cwl
    in:
      dataset: demuxAB/output_dataset
      name: demuxAB/name
      input_bam: AB_merge/output_merge_bam
      chromsizes: parsespecies/chromsizes
      species: species
    out: [
      X_output_view_r2bam,
      X_output_index_bai,
      X_posbw, X_negbw,
      #, X_posbg, X_negbg, X_noposbg, X_nonegbg, X_nonegtbg,
      X_trackdbtxt,
      X_hubtxt,
      X_genomestxt,
      X_pos_bw, X_neg_bw,
      X_output_clipper_bed,
      X_output_clipper_pickle,
      X_output_clipper_log,
      X_output_fixscores_bed,
      X_output_bedsort_bed,
      X_bigbed,
      X_triplet
      ]

###########################################################################
# Repmap
###########################################################################

#  repmap:
#    run: wf_ecliprepmapsingle
#    in:
#
#      barcode1r1FastqGz:
#      barcode1r2FastqGz:
#      barcode1rmRepBam:
#
#    out:
#      - barcode1concatenatedsam
#      - barcode2concatenatedsam
#      - concatenatedsam
