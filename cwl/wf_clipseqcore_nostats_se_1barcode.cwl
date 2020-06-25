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

  chrom_sizes:
    type: File

  # barcodesfasta:
  #   type: File

  # randomer_length:
  #   type: string

  read:
    type:
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

  # r2_bam:
  #   type: string

  # output_bam:
  #   type: string
  
  # adapters:
  #   type: File

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
  # b1_demuxed_fastq_r2:
  #   type: File
  #   outputSource: demultiplex/A_output_demuxed_read2

  b1_trimx1_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_first
  b1_trimx1_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_metrics
  b1_trimx1_fastqc_report:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_fastqc_report
  b1_trimx1_fastqc_stats: 
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_fastqc_stats
  b1_trimx2_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_again
  b1_trimx2_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_metrics
  b1_trimx2_fastqc_report:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_fastqc_report
  b1_trimx2_fastqc_stats: 
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_fastqc_stats
    
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
    type: File
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

  b1_output_pre_rmdup_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/A_output_sorted_bam

  # b1_output_barcodecollapsese_metrics:
  #   type: File
  #   outputSource: b1_trim_and_map/X_output_barcodecollapsese_metrics

  b1_output_rmdup_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/X_output_sorted_bam

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
    run: wf_demultiplex_se.cwl
    in:
      dataset: dataset
      read: read
    out: [
      A_output_demuxed_read1,
      read_name,
      dataset_name
    ]

  b1_trim_and_map:
    run: wf_trim_and_map_se_nostats.cwl
    in:
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      trimfirst_overlap_length:
        default: "1"
      trimagain_overlap_length:
        default: "5"
      a_adapters: 
        source: read
        valueFrom: |
          ${
            return self.adapters;
          }
      read1: demultiplex/A_output_demuxed_read1
      read_name: demultiplex/read_name
      dataset_name: demultiplex/dataset_name
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_first_fastqc_report,
      X_output_trim_first_fastqc_stats,
      X_output_trim_again,
      X_output_trim_again_metrics,
      X_output_trim_again_fastqc_report,
      X_output_trim_again_fastqc_stats,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_maprepeats_star_settings,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_mapgenome_star_settings,
      A_output_sorted_bam,
      # A_output_sorted_bam_index,
      X_output_barcodecollapsese_bam,
      # X_output_barcodecollapsese_metrics,
      X_output_sorted_bam
    ]


###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################

  make_bigwigs:
    run: makebigwigfiles.cwl
    in:
      chromsizes: chrom_sizes
      bam: b1_trim_and_map/X_output_sorted_bam
    out:
      [posbw, negbw]
