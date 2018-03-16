#!/usr/bin/env cwltool

### space to remind me of what the metadata runner is ###

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
  speciesGenomeDir:
    type: Directory
  repeatElementGenomeDir:
    type: Directory
  trimfirst_overlap_length:
    type: string
  trimagain_overlap_length:
    type: string
  g_adapters:
    type: File
  g_adapters_default:
    type: File
  a_adapters:
    type: File
  a_adapters_default:
    type: File
  A_adapters:
    type: File
  read1:
    type: File

  sort_names:
    type: boolean
    default: true
  trim_times:
    type: string
    default: "1"
  trim_error_rate:
    type: string
    default: "0.1"

outputs:

  X_output_trim_first:
    type: File[]
    outputSource: X_trim/output_trim
  X_output_trim_first_metrics:
    type: File
    outputSource: X_trim/output_trim_report

  X_output_trim_again:
    type: File[]
    outputSource: X_trim_again/output_trim
  X_output_trim_again_metrics:
    type: File
    outputSource: X_trim_again/output_trim_report

  A_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: A_map_repeats/aligned
  A_output_maprepeats_stats:
    type: File
    outputSource: A_map_repeats/mappingstats
  A_output_maprepeats_star_settings:
    type: File
    outputSource: A_map_repeats/starsettings
  A_output_sort_repunmapped_fastq:
    type: File[]
    outputSource: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq

  A_output_mapgenome_mapped_to_genome:
    type: File
    outputSource: A_map_genome/aligned
  A_output_mapgenome_stats:
    type: File
    outputSource: A_map_genome/mappingstats
  A_output_mapgenome_star_settings:
    type: File
    outputSource: A_map_genome/starsettings
  A_output_sorted_bam:
    type: File
    outputSource: A_sort/output_sort_bam
  A_output_sorted_bam_index:
    type: File
    outputSource: A_index/output_index_bai

  X_output_barcodecollapsepe_bam:
    type: File
    outputSource: X_barcodecollapsepe/output_barcodecollapsepe_bam
  X_output_barcodecollapsepe_metrics:
    type: File
    outputSource: X_barcodecollapsepe/output_barcodecollapsepe_metrics

  X_output_sorted_bam:
    type: File
    outputSource: X_sort/output_sort_bam

  X_output_index_bai:
    type: File
    outputSource: X_index/output_index_bai

steps:

###########################################################################
# Parse adapter files to array inputs
###########################################################################

  get_g_adapters:
    run: file2stringArray.cwl
    in:
      file: g_adapters
    out:
      [output]
  get_a_adapters:
    run: file2stringArray.cwl
    in:
      file: a_adapters
    out:
      [output]
  get_A_adapters:
    run: file2stringArray.cwl
    in:
      file: A_adapters
    out:
      [output]
  get_a_adapters_default:
    run: file2stringArray.cwl
    in:
      file: a_adapters_default
    out:
      [output]
  get_g_adapters_default:
    run: file2stringArray.cwl
    in:
      file: g_adapters_default
    out:
      [output]

###########################################################################
# Trim
###########################################################################

  X_trim:
    run: trim_pe.cwl
    in:
      input_trim: [read1]
      input_trim_overlap_length: trimfirst_overlap_length
      input_trim_g_adapters: get_g_adapters/output
      input_trim_a_adapters: get_a_adapters/output
      input_trim_A_adapters: get_A_adapters/output
      times: trim_times
      error_rate: trim_error_rate
    out: [output_trim, output_trim_report]

  X_trim_again:
    run: trim_pe.cwl
    in:
      input_trim: X_trim/output_trim
      input_trim_overlap_length: trimagain_overlap_length
      input_trim_g_adapters: get_g_adapters_default/output
      input_trim_a_adapters: get_a_adapters_default/output
      input_trim_A_adapters: get_A_adapters/output
      times: trim_times
      error_rate: trim_error_rate
    out: [output_trim, output_trim_report]

  A_sort_trimmed_fastq:
    run: fastqsort.cwl
    scatter: input_fastqsort_fastq
    in:
      input_fastqsort_fastq: X_trim_again/output_trim
    out:
      [output_fastqsort_sortedfastq]

###########################################################################
# Mapping
###########################################################################

  A_map_repeats:
    run: star-repeatmapping.cwl
    in:
      # outFileNamePrefix: A_parse_records/repName
      # outFilterMultimapNmax: repeatMultimapNmax
      readFilesIn: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
      genomeDir: repeatElementGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
      starsettings,
      mappingstats
    ]

  A_sort_repunmapped_fastq:
    run: fastqsort.cwl
    scatter: input_fastqsort_fastq
    in:
      input_fastqsort_fastq: [
        A_map_repeats/output_map_unmapped_fwd,
      ]
    out:
      [output_fastqsort_sortedfastq]

  A_map_genome:
    run: star-genome.cwl
    in:
      # outFileNamePrefix: A_parse_records/rmRepName
      # outFilterMultimapNmax: genomeMultimapNmax
      readFilesIn: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq
      genomeDir: speciesGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
      starsettings,
      mappingstats
    ]

  A_sort:
    run: sort.cwl
    in:
      input_sort_bam: A_map_genome/aligned
    out:
      [output_sort_bam]

  A_index:
    run: index.cwl
    in:
      input_index_bam: A_sort/output_sort_bam
    out:
      [output_index_bai]

  X_sortlexico:
    run: namesort.cwl
    in:
      name_sort: sort_names
      input_sort_bam: A_map_genome/aligned
    out: [output_sort_bam]

  X_barcodecollapsepe:
    run: barcodecollapse_pe.cwl
    in:
      input_barcodecollapsepe_bam: X_sortlexico/output_sort_bam
    out: [output_barcodecollapsepe_bam, output_barcodecollapsepe_metrics]

  X_sort:
    run: sort.cwl
    in:
      input_sort_bam: X_barcodecollapsepe/output_barcodecollapsepe_bam
    out: [output_sort_bam]

  X_index:
    run: index.cwl
    in:
      input_index_bam: X_sort/output_sort_bam
    out: [output_index_bai]

###########################################################################
# Downstream
###########################################################################

