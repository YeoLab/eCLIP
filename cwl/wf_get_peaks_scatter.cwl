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

  barcodesfasta:
    type: File

  randomer_length:
    type: string

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
            read2:
              type: File
            barcodeids:
              type: string[]
            name:
              type: string

outputs:
  output_compressed_peaks:
    type: File[]
    outputSource: step_get_peaks/output_compressed_peaks

  ### DEMULTIPLEXED READ OUTPUTS ###
  output_ip_b1_demuxed_fastq_r1:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_demuxed_fastq_r1
  output_ip_b1_demuxed_fastq_r2:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_demuxed_fastq_r2

  output_ip_b2_demuxed_fastq_r1:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_demuxed_fastq_r1
  output_ip_b2_demuxed_fastq_r2:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_demuxed_fastq_r2

  output_input_b1_demuxed_fastq_r1:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_demuxed_fastq_r1
  output_input_b1_demuxed_fastq_r2:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_demuxed_fastq_r2

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
  output_ip_b2_trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_ip_b2_trimx1_fastq
  output_ip_b2_trimx1_metrics:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_trimx1_metrics
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
  output_ip_b2_trimx2_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_ip_b2_trimx2_fastq
  output_ip_b2_trimx2_metrics:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_trimx2_metrics
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
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_ip_b1_sorted_unmapped_fastq

  output_ip_b2_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_maprepeats_mapped_to_genome
  output_ip_b2_maprepeats_stats:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_maprepeats_stats
  output_ip_b2_maprepeats_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_maprepeats_star_settings
  output_ip_b2_sorted_unmapped_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_get_peaks/output_ip_b2_sorted_unmapped_fastq

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
    type:
      type: array
      items:
        type: array
        items: File
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
  output_ip_b1_output_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_ip_b1_output_sorted_bam

  output_ip_b2_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_mapgenome_mapped_to_genome
  output_ip_b2_mapgenome_stats:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_mapgenome_stats
  output_ip_b2_mapgenome_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_mapgenome_star_settings
  output_ip_b2_output_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_ip_b2_output_sorted_bam

  output_input_b1_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_mapgenome_mapped_to_genome
  output_input_b1_mapgenome_stats:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_mapgenome_stats
  output_input_b1_mapgenome_star_settings:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_mapgenome_star_settings
  output_input_b1_output_sorted_bam:
    type: File[]
    outputSource: step_get_peaks/output_input_b1_output_sorted_bam

  ### READ2 OUTPUTS ###
  output_ip_merged_bam:
    type: File[]
    outputSource: step_get_peaks/output_ip_merged_bam
  output_input_bam:
    type: File[]
    outputSource: step_get_peaks/output_input_bam

  ### PEAK OUTPUTS ###
  output_clipper_bed:
    type: File[]
    outputSource: step_get_peaks/output_clipper_bed
  output_inputnormed_peaks:
    type: File[]
    outputSource: step_get_peaks/output_inputnormed_peaks
steps:

###########################################################################
# Upstream
###########################################################################
  step_get_peaks:
    run: wf_get_peaks_pe.cwl
    scatter: sample
    in:
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      barcodesfasta: barcodesfasta
      randomer_length: randomer_length
      sample: samples
    out: [
      output_ip_b1_demuxed_fastq_r1,
      output_ip_b1_demuxed_fastq_r2,
      output_ip_b2_demuxed_fastq_r1,
      output_ip_b2_demuxed_fastq_r2,
      output_input_b1_demuxed_fastq_r1,
      output_input_b1_demuxed_fastq_r2,
      output_ip_b1_trimx1_fastq,
      output_ip_b1_trimx1_metrics,
      output_ip_b2_trimx1_fastq,
      output_ip_b2_trimx1_metrics,
      output_input_b1_trimx1_fastq,
      output_input_b1_trimx1_metrics,
      output_ip_b1_trimx2_fastq,
      output_ip_b1_trimx2_metrics,
      output_ip_b2_trimx2_fastq,
      output_ip_b2_trimx2_metrics,
      output_input_b1_trimx2_fastq,
      output_input_b1_trimx2_metrics,
      output_ip_b1_maprepeats_mapped_to_genome,
      output_ip_b1_maprepeats_stats,
      output_ip_b1_maprepeats_star_settings,
      output_ip_b1_sorted_unmapped_fastq,
      output_ip_b2_maprepeats_mapped_to_genome,
      output_ip_b2_maprepeats_stats,
      output_ip_b2_maprepeats_star_settings,
      output_ip_b2_sorted_unmapped_fastq,
      output_input_b1_maprepeats_mapped_to_genome,
      output_input_b1_maprepeats_stats,
      output_input_b1_maprepeats_star_settings,
      output_input_b1_sorted_unmapped_fastq,
      output_ip_b1_mapgenome_mapped_to_genome,
      output_ip_b1_mapgenome_stats,
      output_ip_b1_mapgenome_star_settings,
      output_ip_b1_output_sorted_bam,
      output_ip_b2_mapgenome_mapped_to_genome,
      output_ip_b2_mapgenome_stats,
      output_ip_b2_mapgenome_star_settings,
      output_ip_b2_output_sorted_bam,
      output_input_b1_mapgenome_mapped_to_genome,
      output_input_b1_mapgenome_stats,
      output_input_b1_mapgenome_star_settings,
      output_input_b1_output_sorted_bam,
      output_ip_merged_bam,
      output_input_bam,
      output_clipper_bed,
      output_inputnormed_peaks,
      output_compressed_peaks
    ]
