#!/usr/bin/env cwltool

### This sub workflow should be identical to wf_trim_and_map_se.cwl except that it runs cutadapt only once. ###

cwlVersion: v1.0
class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:
  speciesGenomeDir:
    type: Directory
  repeatElementGenomeDir:
    type: Directory
  trimfirst_overlap_length:
    type: string
  trimagain_overlap_length:
    type: string
  # g_adapters:
  #   type: File
  # g_adapters_default:
  #   type: File
  a_adapters:
    type: File
  # a_adapters_default:
  #   type: File
  # A_adapters:
  #   type: File
  read1s:
    type: File[]
  read_name:
    type: string
  dataset_name:
    type: string

  ## Defaults (don't change unless we have a very good reason) ##
  
  sort_names:
    type: boolean
    default: true
  trim_times:
    type: string
    default: "1"
  trim_error_rate:
    type: string
    default: "0.1"

  fastq_suffix:
    type: string
    default: ".fq"
  bam_suffix:
    type: string
    default: ".bam"
    
  hard_trim_length:
    type: int
    default: -9
    
outputs:

  X_output_trim_first:
    type: 
      type: array
      items:
        type: array
        items: File
    outputSource: step_wf_trim_partial_and_map/X_output_trim_first
  X_output_trim_first_metrics:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/X_output_trim_first_metrics

  A_output_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_maprepeats_mapped_to_genome
  A_output_maprepeats_stats:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_maprepeats_stats
  A_output_maprepeats_star_settings:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_maprepeats_star_settings
  A_output_sort_repunmapped_fastq:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_sort_repunmapped_fastq

  A_output_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_mapgenome_mapped_to_genome
  A_output_mapgenome_stats:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_mapgenome_stats
  A_output_mapgenome_star_settings:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_mapgenome_star_settings
  A_output_sorted_bam:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/A_output_sorted_bam

  X_output_barcodecollapsese_bam:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/X_output_barcodecollapsese_bam
  # X_output_barcodecollapsese_metrics:
  #   type: File[]
  #   outputSource: step_wf_trim_partial_and_map/X_output_barcodecollapsese_metrics

  X_output_sorted_bam:
    type: File[]
    outputSource: step_wf_trim_partial_and_map/X_output_sorted_bam

steps:

  step_wf_trim_partial_and_map:
    run: wf_trim_partial_and_map_se.cwl
    scatter: read1
    in:
      read1: read1s
      read_name: read_name
      dataset_name: dataset_name
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      trimfirst_overlap_length: trimfirst_overlap_length
      trimagain_overlap_length: trimagain_overlap_length
      a_adapters: a_adapters
    out:
      - X_output_trim_first
      - X_output_trim_first_metrics
      - A_output_maprepeats_mapped_to_genome
      - A_output_maprepeats_stats
      - A_output_maprepeats_star_settings
      - A_output_sort_repunmapped_fastq
      - A_output_mapgenome_mapped_to_genome
      - A_output_mapgenome_stats
      - A_output_mapgenome_star_settings
      - A_output_sorted_bam
      - X_output_barcodecollapsese_bam
      - X_output_sorted_bam
      # - X_output_barcodecollapsese_metrics
