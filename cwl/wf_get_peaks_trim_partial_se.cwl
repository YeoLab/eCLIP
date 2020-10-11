#!/usr/bin/env cwltool

### ###

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement

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

  species:
    type: string

  chrom_sizes:
    type: File

  # barcodesfasta:
  #   type: File

  # randomer_length:
  #   type: string

  sample:
    type:
      # array of 2, one IP one Input
      type: array
      items:
        # record of SE reads and name
        type: record
        fields:
          read1:
            type: File
          # read2:
          #   type: File
          adapters:
            type: File
          name:
            type: string
  blacklist_file:
    type: File
    
outputs:


  ### Demultiplexed outputs ###


  output_ip_b1_demuxed_fastq_r1:
    type: File
    outputSource: step_ip_alignment/b1_demuxed_fastq_r1

  output_input_b1_demuxed_fastq_r1:
    type: File
    outputSource: step_input_alignment/b1_demuxed_fastq_r1


  ### Trimmed outputs ###


  output_ip_b1_trimx1_fastq:
    type: File[]
    outputSource: step_ip_alignment/b1_trimx1_fastq
  output_ip_b1_trimx1_metrics:
    type: File
    outputSource: step_ip_alignment/b1_trimx1_metrics
  output_ip_b1_trimx1_fastqc_report:
    type: File
    outputSource: step_ip_alignment/b1_trimx1_fastqc_report
  output_ip_b1_trimx1_fastqc_stats:
    type: File
    outputSource: step_ip_alignment/b1_trimx1_fastqc_stats
  # output_ip_b1_trimx2_fastq:
  #   type: File[]
  #   outputSource: step_ip_alignment/b1_trimx2_fastq
  # output_ip_b1_trimx2_metrics:
  #   type: File
  #   outputSource: step_ip_alignment/b1_trimx2_metrics
  # output_ip_b1_trimx2_fastqc_report:
  #   type: File
  #   outputSource: step_ip_alignment/b1_trimx2_fastqc_report
  # output_ip_b1_trimx2_fastqc_stats:
  #   type: File
  #   outputSource: step_ip_alignment/b1_trimx2_fastqc_stats
    
  output_input_b1_trimx1_fastq:
    type: File[]
    outputSource: step_input_alignment/b1_trimx1_fastq
  output_input_b1_trimx1_metrics:
    type: File
    outputSource: step_input_alignment/b1_trimx1_metrics
  output_input_b1_trimx1_fastqc_report:
    type: File
    outputSource: step_input_alignment/b1_trimx1_fastqc_report
  output_input_b1_trimx1_fastqc_stats:
    type: File
    outputSource: step_input_alignment/b1_trimx1_fastqc_stats
  # output_input_b1_trimx2_fastq:
  #   type: File[]
  #   outputSource: step_input_alignment/b1_trimx2_fastq
  # output_input_b1_trimx2_metrics:
  #   type: File
  #   outputSource: step_input_alignment/b1_trimx2_metrics
  # output_input_b1_trimx2_fastqc_report:
  #   type: File
  #   outputSource: step_input_alignment/b1_trimx2_fastqc_report
  # output_input_b1_trimx2_fastqc_stats:
  #   type: File
  #   outputSource: step_input_alignment/b1_trimx2_fastqc_stats

  ### Repeat mapping outputs ###


  output_ip_b1_maprepeats_mapped_to_genome:
    type: File
    outputSource: step_ip_alignment/b1_maprepeats_mapped_to_genome
  output_ip_b1_maprepeats_stats:
    type: File
    outputSource: step_ip_alignment/b1_maprepeats_stats
  output_ip_b1_maprepeats_star_settings:
    type: File
    outputSource: step_ip_alignment/b1_maprepeats_star_settings
  output_ip_b1_sorted_unmapped_fastq:
    type: File
    outputSource: step_ip_alignment/b1_sorted_unmapped_fastq

  output_input_b1_maprepeats_mapped_to_genome:
    type: File
    outputSource: step_input_alignment/b1_maprepeats_mapped_to_genome
  output_input_b1_maprepeats_stats:
    type: File
    outputSource: step_input_alignment/b1_maprepeats_stats
  output_input_b1_maprepeats_star_settings:
    type: File
    outputSource: step_input_alignment/b1_maprepeats_star_settings
  output_input_b1_sorted_unmapped_fastq:
    type: File
    outputSource: step_input_alignment/b1_sorted_unmapped_fastq


  ### Genomic mapping outputs ###


  output_ip_b1_mapgenome_mapped_to_genome:
    type: File
    outputSource: step_ip_alignment/b1_mapgenome_mapped_to_genome
  output_ip_b1_mapgenome_stats:
    type: File
    outputSource: step_ip_alignment/b1_mapgenome_stats
  output_ip_b1_mapgenome_star_settings:
    type: File
    outputSource: step_ip_alignment/b1_mapgenome_star_settings
  # output_ip_b1_output_sorted_bam:
  #   type: File
  #   outputSource: step_ip_alignment/b1_output_sorted_bam

  output_input_b1_mapgenome_mapped_to_genome:
    type: File
    outputSource: step_input_alignment/b1_mapgenome_mapped_to_genome
  output_input_b1_mapgenome_stats:
    type: File
    outputSource: step_input_alignment/b1_mapgenome_stats
  output_input_b1_mapgenome_star_settings:
    type: File
    outputSource: step_input_alignment/b1_mapgenome_star_settings
  # output_input_b1_output_sorted_bam:
  #   type: File
  #   outputSource: step_input_alignment/b1_output_sorted_bam


  ### Duplicate removal outputs ###


  output_ip_b1_pre_rmdup_sorted_bam:
    type: File
    outputSource: step_ip_alignment/b1_output_pre_rmdup_sorted_bam
  output_ip_b1_barcodecollapsese_metrics:
    type: File
    outputSource: step_ip_alignment/b1_output_barcodecollapsese_metrics
  output_ip_b1_rmdup_sorted_bam:
    type: File
    outputSource: step_ip_alignment/b1_output_rmdup_sorted_bam

  output_input_b1_pre_rmdup_sorted_bam:
    type: File
    outputSource: step_input_alignment/b1_output_pre_rmdup_sorted_bam
  output_input_b1_barcodecollapsese_metrics:
    type: File
    outputSource: step_input_alignment/b1_output_barcodecollapsese_metrics
  output_input_b1_rmdup_sorted_bam:
    type: File
    outputSource: step_input_alignment/b1_output_rmdup_sorted_bam


  ### Bigwig files ###


  output_ip_pos_bw:
    type: File
    outputSource: step_ip_alignment/output_pos_bw
  output_ip_neg_bw:
    type: File
    outputSource: step_ip_alignment/output_neg_bw

  output_input_pos_bw:
    type: File
    outputSource: step_input_alignment/output_pos_bw
  output_input_neg_bw:
    type: File
    outputSource: step_input_alignment/output_neg_bw


  ### Peak outputs ###


  output_clipper_bed:
    type: File
    outputSource: step_clipper/output_bed
  output_inputnormed_peaks:
    type: File
    outputSource: step_input_normalize_peaks/inputnormedBed
  output_compressed_peaks:
    type: File
    outputSource: step_compress_peaks/output_bed

  ### Downstream ###
  
  output_blacklist_removed_bed:
    type: File
    outputSource: step_blacklist_remove/output_blacklist_removed_bed
  output_narrowpeak:
    type: File
    outputSource: step_bed_to_narrowpeak/output_narrowpeak
  output_fixed_bed:
    type: File
    outputSource: step_fix_bed_for_bigbed_conversion/output_fixed_bed
  output_bigbed:
    type: File
    outputSource: step_bed_to_bigbed/output_bigbed
    
    
steps:

###########################################################################
# Upstream
###########################################################################

  step_ip_alignment:
    run: wf_clipseqcore_trim_partial_se_1barcode.cwl
    in:
      read:
        source: sample
        valueFrom: |
          ${
            return self[0];
          }
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      chrom_sizes: chrom_sizes
    out: [
      b1_demuxed_fastq_r1,
      # b1_demuxed_fastq_r2,
      b1_trimx1_fastq,
      b1_trimx1_metrics,
      b1_trimx1_fastqc_report,
      b1_trimx1_fastqc_stats,
      # b1_trimx2_fastq,
      # b1_trimx2_metrics,
      # b1_trimx2_fastqc_report,
      # b1_trimx2_fastqc_stats,
      b1_maprepeats_mapped_to_genome,
      b1_maprepeats_stats,
      b1_maprepeats_star_settings,
      b1_sorted_unmapped_fastq,
      b1_mapgenome_mapped_to_genome,
      b1_mapgenome_stats,
      b1_mapgenome_star_settings,
      b1_output_pre_rmdup_sorted_bam,
      b1_output_barcodecollapsese_metrics,
      b1_output_rmdup_sorted_bam,
      output_pos_bw,
      output_neg_bw
    ]

  step_input_alignment:
    run: wf_clipseqcore_trim_partial_se_1barcode.cwl
    in:
      read:
        source: sample
        valueFrom: |
          ${
            return self[1];
          }
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      chrom_sizes: chrom_sizes
    out: [
      b1_demuxed_fastq_r1,
      # b1_demuxed_fastq_r2,
      b1_trimx1_fastq,
      b1_trimx1_metrics,
      b1_trimx1_fastqc_report,
      b1_trimx1_fastqc_stats,
      # b1_trimx2_fastq,
      # b1_trimx2_metrics,
      # b1_trimx2_fastqc_report,
      # b1_trimx2_fastqc_stats,
      b1_maprepeats_mapped_to_genome,
      b1_maprepeats_stats,
      b1_maprepeats_star_settings,
      b1_sorted_unmapped_fastq,
      b1_mapgenome_mapped_to_genome,
      b1_mapgenome_stats,
      b1_mapgenome_star_settings,
      b1_output_pre_rmdup_sorted_bam,
      b1_output_barcodecollapsese_metrics,
      b1_output_rmdup_sorted_bam,
      output_pos_bw,
      output_neg_bw
    ]

  step_index_ip:
    run: samtools-index.cwl
    in:
      alignments: step_ip_alignment/b1_output_rmdup_sorted_bam
    out: [alignments_with_index]

  step_index_input:
    run: samtools-index.cwl
    in:
      alignments: step_input_alignment/b1_output_rmdup_sorted_bam
    out: [alignments_with_index]

  step_clipper:
    run: clipper.cwl
    in:
      species: species
      bam: step_ip_alignment/b1_output_rmdup_sorted_bam
      outfile:
        default: ""
    out:
      [output_tsv, output_bed]
  

###########################################################################
# Downstream
###########################################################################

  step_ip_mapped_readnum:
    run: samtools-mappedreadnum.cwl
    in:
      input: step_ip_alignment/b1_output_rmdup_sorted_bam
      readswithoutbits:
        default: 4
      count:
        default: true
      output_name:
        default: ip_mapped_readnum.txt
    out: [output]

  step_input_mapped_readnum:
    run: samtools-mappedreadnum.cwl
    in:
      input: step_input_alignment/b1_output_rmdup_sorted_bam
      readswithoutbits:
        default: 4
      count:
        default: true
      output_name:
        default: input_mapped_readnum.txt
    out: [output]

  step_input_normalize_peaks:
    run: overlap_peakfi_with_bam_PE.cwl
    in:
      clipBamFile: step_index_ip/alignments_with_index
      inputBamFile: step_index_input/alignments_with_index
      peakFile: step_clipper/output_bed
      clipReadnum: step_ip_mapped_readnum/output
      inputReadnum: step_input_mapped_readnum/output
    out: [
      inputnormedBed,
      inputnormedBedfull
    ]

  step_compress_peaks:
    run: peakscompress.cwl
    in:
      input_bed: step_input_normalize_peaks/inputnormedBed
    out: [output_bed]
