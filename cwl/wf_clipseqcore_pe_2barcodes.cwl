#!/usr/bin/env cwltool

doc: |
  Workflow for handling reads containing two barcodes.
  Returns the bam file containing read2 only.
  
  Notes:

    runs the following steps: 
    - demultiplex
    - trimfirst_file2string
    - trimagain_file2string
    - b1_trim_and_map
    - view_r2
    - index_r2_bam
    - make_bigwigs

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement

inputs:
  dataset:
    type: string

  speciesGenomeDir:
    type: Directory

  repeatElementGenomeDir:
    type: Directory

  chrom_sizes:
    type: File

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

outputs:


  ### DEMULTIPLEXED OUTPUTS ###


  b1_demuxed_fastq_r1:
    type: File
    outputSource: demultiplex/A_output_demuxed_read1
  b1_demuxed_fastq_r2:
    type: File
    outputSource: demultiplex/A_output_demuxed_read2

  b2_demuxed_fastq_r1:
    type: File
    outputSource: demultiplex/B_output_demuxed_read1
  b2_demuxed_fastq_r2:
    type: File
    outputSource: demultiplex/B_output_demuxed_read2


  ### TRIMMED OUTPUTS (BARCODE1, ROUND 1) ###


  b1_trimx1_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_first
  b1_trimx1_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_metrics
  b1_trimx1_fastqc_report_R1:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_fastqc_report_R1
  b1_trimx1_fastqc_stats_R1: 
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_fastqc_stats_R1
  b1_trimx1_fastqc_report_R2:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_fastqc_report_R2
  b1_trimx1_fastqc_stats_R2: 
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_fastqc_stats_R2


  ### TRIMMED OUTPUTS (BARCODE1, ROUND 2) ###


  b1_trimx2_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_again
  b1_trimx2_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_metrics
  b1_trimx2_fastqc_report_R1:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_fastqc_report_R1
  b1_trimx2_fastqc_stats_R1: 
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_fastqc_stats_R1
  b1_trimx2_fastqc_report_R2:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_fastqc_report_R2
  b1_trimx2_fastqc_stats_R2: 
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_fastqc_stats_R2


  ### TRIMMED OUTPUTS (BARCODE2, ROUND 1) ###


  b2_trimx1_fastq:
    type: File[]
    outputSource: b2_trim_and_map/X_output_trim_first
  b2_trimx1_metrics:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_first_metrics
  b2_trimx1_fastqc_report_R1:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_first_fastqc_report_R1
  b2_trimx1_fastqc_stats_R1: 
    type: File
    outputSource: b2_trim_and_map/X_output_trim_first_fastqc_stats_R1
  b2_trimx1_fastqc_report_R2:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_first_fastqc_report_R2
  b2_trimx1_fastqc_stats_R2: 
    type: File
    outputSource: b2_trim_and_map/X_output_trim_first_fastqc_stats_R2


  ### TRIMMED OUTPUTS (BARCODE2, ROUND 2) ###


  b2_trimx2_fastq:
    type: File[]
    outputSource: b2_trim_and_map/X_output_trim_again
  b2_trimx2_metrics:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_again_metrics
  b2_trimx2_fastqc_report_R1:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_again_fastqc_report_R1
  b2_trimx2_fastqc_stats_R1: 
    type: File
    outputSource: b2_trim_and_map/X_output_trim_again_fastqc_stats_R1
  b2_trimx2_fastqc_report_R2:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_again_fastqc_report_R2
  b2_trimx2_fastqc_stats_R2: 
    type: File
    outputSource: b2_trim_and_map/X_output_trim_again_fastqc_stats_R2


  ### REPEAT MAPPING OUTPUTS (BARCODE1) ###


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


  ### REPEAT MAPPING OUTPUTS (BARCODE2) ###


  b2_maprepeats_mapped_to_genome:
    type: File
    outputSource: b2_trim_and_map/A_output_maprepeats_mapped_to_genome
  b2_maprepeats_stats:
    type: File
    outputSource: b2_trim_and_map/A_output_maprepeats_stats
  b2_maprepeats_star_settings:
    type: File
    outputSource: b2_trim_and_map/A_output_maprepeats_star_settings
  b2_sorted_unmapped_fastq:
    type: File[]
    outputSource: b2_trim_and_map/A_output_sort_repunmapped_fastq


  ### GENOME MAPPING OUTPUTS (BARCODE1) ###


  b1_mapgenome_mapped_to_genome:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_mapped_to_genome
  b1_mapgenome_stats:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_stats
  b1_mapgenome_star_settings:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_star_settings


  ### GENOME MAPPING OUTPUTS (BARCODE2) ###


  b2_mapgenome_mapped_to_genome:
    type: File
    outputSource: b2_trim_and_map/A_output_mapgenome_mapped_to_genome
  b2_mapgenome_stats:
    type: File
    outputSource: b2_trim_and_map/A_output_mapgenome_stats
  b2_mapgenome_star_settings:
    type: File
    outputSource: b2_trim_and_map/A_output_mapgenome_star_settings


  ### RMDUP BAM OUTPUTS (BARCODE1) ###


  b1_output_prermdup_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/A_output_sorted_bam
  b1_output_barcodecollapsepe_bam:
    type: File
    outputSource: b1_trim_and_map/X_output_barcodecollapsepe_bam
  b1_output_barcodecollapsepe_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_barcodecollapsepe_metrics


  ### RMDUP BAM OUTPUTS (BARCODE2) ###


  b2_output_prermdup_sorted_bam:
    type: File
    outputSource: b2_trim_and_map/A_output_sorted_bam
  b2_output_barcodecollapsepe_bam:
    type: File
    outputSource: b2_trim_and_map/X_output_barcodecollapsepe_bam
  b2_output_barcodecollapsepe_metrics:
    type: File
    outputSource: b2_trim_and_map/X_output_barcodecollapsepe_metrics


  ### SORTED RMDUP BAM OUTPUTS (BARCODE1) ###


  b1_output_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/X_output_sorted_bam


  ### SORTED RMDUP BAM OUTPUTS (BARCODE1) ###


  b2_output_sorted_bam:
    type: File
    outputSource: b2_trim_and_map/X_output_sorted_bam


  ### READ2 MERGED BAM OUTPUTS ###


  output_r2_bam:
    type: File
    outputSource: view_r2/output


  ### BIGWIG FILES ###


  output_pos_bw:
    type: File
    outputSource: make_bigwigs/posbw
  output_neg_bw:
    type: File
    outputSource: make_bigwigs/negbw

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
      X_output_trim_first_fastqc_report_R1,
      X_output_trim_first_fastqc_stats_R1,
      X_output_trim_first_fastqc_report_R2,
      X_output_trim_first_fastqc_stats_R2,
      X_output_trim_again,
      X_output_trim_again_metrics,
      X_output_trim_again_fastqc_report_R1,
      X_output_trim_again_fastqc_stats_R1,
      X_output_trim_again_fastqc_report_R2,
      X_output_trim_again_fastqc_stats_R2,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_maprepeats_star_settings,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_mapgenome_star_settings,
      A_output_sorted_bam,
      X_output_barcodecollapsepe_bam,
      X_output_barcodecollapsepe_metrics,
      X_output_sorted_bam
    ]

  b2_trim_and_map:
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
      read1: demultiplex/B_output_demuxed_read1
      read2: demultiplex/B_output_demuxed_read2
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_first_fastqc_report_R1,
      X_output_trim_first_fastqc_stats_R1,
      X_output_trim_first_fastqc_report_R2,
      X_output_trim_first_fastqc_stats_R2,
      X_output_trim_again,
      X_output_trim_again_metrics,
      X_output_trim_again_fastqc_report_R1,
      X_output_trim_again_fastqc_stats_R1,
      X_output_trim_again_fastqc_report_R2,
      X_output_trim_again_fastqc_stats_R2,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_maprepeats_star_settings,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_mapgenome_star_settings,
      A_output_sorted_bam,
      X_output_barcodecollapsepe_bam,
      X_output_barcodecollapsepe_metrics,
      X_output_sorted_bam
    ]

  merge:
    run: samtools-merge.cwl
    in:
      input_bam_files: [
        b1_trim_and_map/X_output_sorted_bam,
        b2_trim_and_map/X_output_sorted_bam
      ]
    out: [output_bam_file]

###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################

  view_r2:
    run: samtools-viewr2.cwl
    in:
      input: merge/output_bam_file
      readswithbits:
        default: 128
      isbam:
        default: true
    out: [output]

  index_r2_bam:
    run: samtools-index.cwl
    in:
      alignments: view_r2/output
    out: [alignments_with_index]

  make_bigwigs:
    run: makebigwigfiles_PE.cwl
    in:
      chromsizes: chrom_sizes
      bam: index_r2_bam/alignments_with_index
    out:
      [posbw, negbw]
