#!/usr/bin/env cwltool

### ###

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

  species:
    type: string

  chrom_sizes:
    type: File

  samples:
    type:
      type: array
      items:
        type: array
        items:
          type: record
          fields:
            read1:
              type: File
            name:
              type: string
  adapters:
    type: File

outputs:


  ### DEMULTIPLEXED READ OUTPUTS ###


  output_ip_b1_demuxed_fastq_r1:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_demuxed_fastq_r1

  output_input_b1_demuxed_fastq_r1:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_demuxed_fastq_r1


  ### TRIMMED OUTPUTS ###


  output_ip_b1_trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_ip_b1_trimx1_fastq
  output_ip_b1_trimx1_metrics:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_trimx1_metrics

  output_input_b1_trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_input_b1_trimx1_fastq
  output_input_b1_trimx1_metrics:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_trimx1_metrics

  output_ip_b1_trimx2_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_ip_b1_trimx2_fastq
  output_ip_b1_trimx2_metrics:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_trimx2_metrics

  output_input_b1_trimx2_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_input_b1_trimx2_fastq
  output_input_b1_trimx2_metrics:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_trimx2_metrics


  ### REPEAT MAPPING OUTPUTS ###


  output_ip_b1_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_maprepeats_mapped_to_genome
  output_ip_b1_maprepeats_stats:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_maprepeats_stats
  output_ip_b1_maprepeats_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_maprepeats_star_settings
  output_ip_b1_sorted_unmapped_fastq:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_sorted_unmapped_fastq

  output_input_b1_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_maprepeats_mapped_to_genome
  output_input_b1_maprepeats_stats:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_maprepeats_stats
  output_input_b1_maprepeats_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_maprepeats_star_settings
  output_input_b1_sorted_unmapped_fastq:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_sorted_unmapped_fastq


  ### GENOME MAPPING OUTPUTS ###


  output_ip_b1_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_mapgenome_mapped_to_genome
  output_ip_b1_mapgenome_stats:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_mapgenome_stats
  output_ip_b1_mapgenome_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_mapgenome_star_settings

  output_input_b1_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_mapgenome_mapped_to_genome
  output_input_b1_mapgenome_stats:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_mapgenome_stats
  output_input_b1_mapgenome_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_mapgenome_star_settings


  ### DUPLICATE REMOVAL OUTPUTS ###


  output_ip_b1_pre_rmdup_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_pre_rmdup_sorted_bam
  # output_ip_b1_barcodecollapsese_metrics:
  #   type: File[]?
  #   outputSource: step_get_peaks/output_ip_b1_barcodecollapsese_metrics
  output_ip_b1_rmdup_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_rmdup_sorted_bam

  output_input_b1_pre_rmdup_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_pre_rmdup_sorted_bam
  # output_input_b1_barcodecollapsese_metrics:
  #   type: File[]?
  #   outputSource: step_get_peaks/output_input_b1_barcodecollapsese_metrics
  output_input_b1_rmdup_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_rmdup_sorted_bam


  ### BIGWIG FILES ###


  output_ip_pos_bw:
    type: File[]
    outputSource: step_get_peaks/output_ip_pos_bw
  output_ip_neg_bw:
    type: File[]
    outputSource: step_get_peaks/output_ip_neg_bw
  output_input_pos_bw:
    type: File[]
    outputSource: step_get_peaks/output_input_pos_bw
  output_input_neg_bw:
    type: File[]
    outputSource: step_get_peaks/output_input_neg_bw


  ### PEAK OUTPUTS ###


  output_clipper_bed:
    type: File[]
    outputSource: step_get_peaks/output_clipper_bed
  output_inputnormed_peaks:
    type: File[]
    outputSource: step_get_peaks/output_inputnormed_peaks
  output_compressed_peaks:
    type: File[]
    outputSource: step_get_peaks/output_compressed_peaks


steps:

###########################################################################
# Upstream
###########################################################################
  step_get_peaks:
    run: wf_get_peaks_se.cwl
    scatter: sample
    in:
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      chrom_sizes: chrom_sizes
      sample: samples
      adapters: adapters
    out: [
      output_ip_b1_demuxed_fastq_r1,
      output_input_b1_demuxed_fastq_r1,
      output_ip_b1_trimx1_fastq,
      output_ip_b1_trimx1_metrics,
      output_input_b1_trimx1_fastq,
      output_input_b1_trimx1_metrics,
      output_ip_b1_trimx2_fastq,
      output_ip_b1_trimx2_metrics,
      output_input_b1_trimx2_fastq,
      output_input_b1_trimx2_metrics,
      output_ip_b1_maprepeats_mapped_to_genome,
      output_ip_b1_maprepeats_stats,
      output_ip_b1_maprepeats_star_settings,
      output_ip_b1_sorted_unmapped_fastq,
      output_input_b1_maprepeats_mapped_to_genome,
      output_input_b1_maprepeats_stats,
      output_input_b1_maprepeats_star_settings,
      output_input_b1_sorted_unmapped_fastq,
      output_ip_b1_mapgenome_mapped_to_genome,
      output_ip_b1_mapgenome_stats,
      output_ip_b1_mapgenome_star_settings,
      output_ip_b1_pre_rmdup_sorted_bam,
      # output_ip_b1_barcodecollapsese_metrics,
      output_ip_b1_rmdup_sorted_bam,
      output_input_b1_mapgenome_mapped_to_genome,
      output_input_b1_mapgenome_stats,
      output_input_b1_mapgenome_star_settings,
      output_input_b1_pre_rmdup_sorted_bam,
      # output_input_b1_barcodecollapsese_metrics,
      output_input_b1_rmdup_sorted_bam,
      output_ip_pos_bw,
      output_ip_neg_bw,
      output_input_pos_bw,
      output_input_neg_bw,
      output_clipper_bed,
      output_inputnormed_peaks,
      output_compressed_peaks
    ]
