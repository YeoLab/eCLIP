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
  read2:
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
    outputSource: step_gzip_sort_X_trim/gzipped
  X_output_trim_first_metrics:
    type: File
    outputSource: X_trim/output_trim_report

  X_output_trim_again:
    type: File[]
    outputSource: step_gzip_sort_X_trim_again/gzipped
  X_output_trim_again_metrics:
    type: File
    outputSource: X_trim_again/output_trim_report

  A_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: rename_mapped_repeats/outfile
  A_output_maprepeats_stats:
    type: File
    outputSource: A_map_repeats/mappingstats
  A_output_maprepeats_star_settings:
    type: File
    outputSource: A_map_repeats/starsettings
  A_output_sort_repunmapped_fastq:
    type: File[]
    outputSource: step_gzip_sort_repunmapped_fastq/gzipped

  A_output_mapgenome_mapped_to_genome:
    type: File
    outputSource: rename_mapped_genome/outfile
  A_output_mapgenome_stats:
    type: File
    outputSource: A_map_genome/mappingstats
  A_output_mapgenome_star_settings:
    type: File
    outputSource: A_map_genome/starsettings
  A_output_sorted_bam:
    type: File
    outputSource: X_sortlexico/output_sort_bam

  X_output_barcodecollapsepe_bam:
    type: File
    outputSource: X_barcodecollapsepe/output_barcodecollapsepe_bam
  X_output_barcodecollapsepe_metrics:
    type: File
    outputSource: X_barcodecollapsepe/output_barcodecollapsepe_metrics

  X_output_sorted_bam:
    type: File
    outputSource: X_sort/output_sort_bam

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
      input_trim: [read1, read2]
      input_trim_overlap_length: trimfirst_overlap_length
      input_trim_g_adapters: get_g_adapters/output
      input_trim_a_adapters: get_a_adapters/output
      input_trim_A_adapters: get_A_adapters/output
      times: trim_times
      error_rate: trim_error_rate
    out: [output_trim, output_trim_report]
  
  step_gzip_sort_X_trim:
    run: gzip.cwl
    scatter: input
    in:
      input: X_trim/output_trim
    out:
      - gzipped
      
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
  
  step_gzip_sort_X_trim_again:
    run: gzip.cwl
    scatter: input
    in:
      input: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
    out:
      - gzipped
      
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
      output_map_unmapped_rev,
      starsettings,
      mappingstats
    ]
  rename_mapped_repeats:
    run: rename.cwl
    in:
      srcfile: A_map_repeats/aligned
      suffix:
        default: ".bam"
      newname:
        source: read1
        valueFrom: ${ return self.nameroot + ".repeat-mapped"; }
    out: [
      outfile
    ]
  rename_unmapped_repeats:
    run: rename.cwl
    scatter: srcfile
    in:
      srcfile: [
        A_map_repeats/output_map_unmapped_fwd,
        A_map_repeats/output_map_unmapped_rev
      ]
      suffix:
        default: ".fq"
      newname:
        source: read1
        valueFrom: ${ return self.nameroot + ".repeat-unmapped"; }
    out: [
      outfile
    ]
  A_sort_repunmapped_fastq:
    run: fastqsort.cwl
    scatter: input_fastqsort_fastq
    in:
      input_fastqsort_fastq: rename_unmapped_repeats/outfile
    out:
      [output_fastqsort_sortedfastq]
      
  step_gzip_sort_repunmapped_fastq:
    run: gzip.cwl
    scatter: input
    in:
      input: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq
    out:
      - gzipped
      
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
      output_map_unmapped_rev,
      starsettings,
      mappingstats
    ]
  rename_mapped_genome:
    run: rename.cwl
    in:
      srcfile: A_map_genome/aligned
      suffix:
        default: ".bam"
      newname:
        source: read1
        valueFrom: ${ return self.nameroot + ".genome-mapped"; }
    out: [
      outfile
    ]

  X_sortlexico:
    run: namesort.cwl
    in:
      name_sort: sort_names
      input_sort_bam: rename_mapped_genome/outfile
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

###########################################################################
# Downstream
###########################################################################


doc: |
  This workflow takes in appropriate trimming params and demultiplexed reads,
  and performs the following steps in order: trimx1, trimx2, fastq-sort, filter repeat elements, fastq-sort, genomic mapping, sort alignment, index alignment, namesort, PCR dedup, sort alignment, index alignment