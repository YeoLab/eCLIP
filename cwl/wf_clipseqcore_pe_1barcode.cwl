#!/usr/bin/env cwltool

### Workflow for handling reads containing one barcode ###
### Returns a bam file containing read2 only ###

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

  speciesGenomeDir:
    type: Directory

  repeatElementGenomeDir:
    type: Directory

  # TODO: remove, we don't use it here.
  species:
    type: string

  barcodesfasta:
    type: File

  randomer_length:
    type: string

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

  # r2_bam:
  #   type: string

  # output_bam:
  #   type: string

  ### Defaults ###

  # r2_bits:
  #   type: int
  #   default: 128
  # is_bam:
  #   type: boolean
  #   default: true

outputs:

  b1_demuxed_fastq_r1:
    type: File
    outputSource: demultiplex/A_output_demuxed_read1
  b1_demuxed_fastq_r2:
    type: File
    outputSource: demultiplex/A_output_demuxed_read2

  b1_trimx1_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_first
  b1_trimx1_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_metrics
  b1_trimx2_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_again
  b1_trimx2_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_metrics

  b1_maprepeats_mapped_to_genome:
    type: File
    outputSource: b1_trim_and_map/A_output_maprepeats_mapped_to_genome
  b1_maprepeats_stats:
    type: File
    outputSource: b1_trim_and_map/A_output_maprepeats_stats
  b1_maprepeats_star_settings:
    type: File
    outputSource: b1_trim_and_map/A_output_maprepeats_star_settings
  b1_sorted_unmapped_fastq:
    type: File[]
    outputSource: b1_trim_and_map/A_output_sort_repunmapped_fastq

  b1_mapgenome_mapped_to_genome:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_mapped_to_genome
  b1_mapgenome_stats:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_stats
  b1_mapgenome_star_settings:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_star_settings

  b1_output_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/X_output_sorted_bam

  output_r2_bam:
    type: File
    outputSource: view_r2/output

steps:

###########################################################################
# Upstream
###########################################################################

  demultiplex:
    run: wf_demultiplex_pe.cwl
    in:
      dataset: dataset
      randomer_length: randomer_length
      barcodesfasta: barcodesfasta
      read: read
    out: [
      A_output_demuxed_read1,
      A_output_demuxed_read2,
      B_output_demuxed_read1,
      B_output_demuxed_read2,
      AB_output_trimfirst_overlap_length,
      AB_output_trimagain_overlap_length,
      AB_g_adapters,
      AB_g_adapters_default,
      AB_a_adapters,
      AB_a_adapters_default,
      AB_A_adapters
    ]

  trimfirst_file2string:
    run: file2string.cwl
    in:
      file: demultiplex/AB_output_trimfirst_overlap_length
    out: [output]

  trimagain_file2string:
    run: file2string.cwl
    in:
      file: demultiplex/AB_output_trimagain_overlap_length
    out: [output]

  b1_trim_and_map:
    run: wf_trim_and_map_pe.cwl
    in:
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      trimfirst_overlap_length: trimfirst_file2string/output
      trimagain_overlap_length: trimagain_file2string/output
      g_adapters: demultiplex/AB_g_adapters
      g_adapters_default: demultiplex/AB_g_adapters_default
      a_adapters: demultiplex/AB_a_adapters
      a_adapters_default: demultiplex/AB_a_adapters_default
      A_adapters: demultiplex/AB_A_adapters
      read1: demultiplex/A_output_demuxed_read1
      read2: demultiplex/A_output_demuxed_read2
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_again,
      X_output_trim_again_metrics,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_maprepeats_star_settings,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_mapgenome_star_settings,
      A_output_sorted_bam,
      A_output_sorted_bam_index,
      X_output_barcodecollapsepe_bam,
      X_output_barcodecollapsepe_metrics,
      X_output_sorted_bam,
      X_output_index_bai
    ]


###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################


  view_r2:
    run: samtools-viewr2.cwl
    in:
      input: b1_trim_and_map/X_output_sorted_bam
      readswithbits:
        default: 128
      isbam:
        default: true
    out: [output]

