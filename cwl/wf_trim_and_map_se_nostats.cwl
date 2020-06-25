#!/usr/bin/env cwltool

### space to remind me of what the metadata runner is ###

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
  read1:
    type: File
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
    
outputs:

  X_output_trim_first:
    type: File[]
    outputSource: step_gzip_sort_X_trim/gzipped
  X_output_trim_first_metrics:
    type: File
    outputSource: X_trim/output_trim_report
  X_output_trim_first_fastqc_report:
    type: File
    outputSource: step_fastqc_trim/output_qc_report
  X_output_trim_first_fastqc_stats:
    type: File
    outputSource: step_fastqc_trim/output_qc_stats
    
  X_output_trim_again:
    type: File[]
    outputSource: step_gzip_sort_X_trim_again/gzipped
  X_output_trim_again_metrics:
    type: File
    outputSource: X_trim_again/output_trim_report
  X_output_trim_again_fastqc_report:
    type: File
    outputSource: step_fastqc_trim_again/output_qc_report
  X_output_trim_again_fastqc_stats:
    type: File
    outputSource: step_fastqc_trim_again/output_qc_stats
    
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
    type: File
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
    outputSource: A_sort/output_sort_bam

  X_output_barcodecollapsese_bam:
    type: File
    outputSource: X_barcodecollapsese/output_barcodecollapsese_bam
  # X_output_barcodecollapsese_metrics:
  #   type: File
  #   outputSource: X_barcodecollapsese/output_barcodecollapsese_metrics

  X_output_sorted_bam:
    type: File
    outputSource: X_sort/output_sort_bam

steps:

###########################################################################
# Parse adapter files to array inputs
###########################################################################

  get_a_adapters:
    run: file2stringArray.cwl
    in:
      file: a_adapters
    out:
      [output]

###########################################################################
# Trim
###########################################################################

  X_trim:
    run: trim_se.cwl
    in:
      input_trim: 
        source: read1
        valueFrom: ${ return [ self ]; }
      input_trim_overlap_length: trimfirst_overlap_length
      input_trim_a_adapters: get_a_adapters/output
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
    run: trim_se.cwl
    in:
      input_trim: X_trim/output_trim
      input_trim_overlap_length: trimagain_overlap_length
      input_trim_a_adapters: get_a_adapters/output
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
# FastQC
###########################################################################
  step_fastqc_trim:
    run: wf_fastqc.cwl
    in:
      reads: 
        source: step_gzip_sort_X_trim/gzipped
        valueFrom: |
          ${
            return self[0];
          }
    out:
      - output_qc_report
      - output_qc_stats
      
  step_fastqc_trim_again:
    run: wf_fastqc.cwl
    in:
      reads: 
        source: step_gzip_sort_X_trim_again/gzipped
        valueFrom: |
          ${
            return self[0];
          }
    out:
      - output_qc_report
      - output_qc_stats
      
###########################################################################
# Mapping
###########################################################################

  A_map_repeats:
    run: star-repeatmapping.cwl
    in:
      readFilesIn: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
      genomeDir: repeatElementGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
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
    in:
      srcfile: A_map_repeats/output_map_unmapped_fwd
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
    in:
      input_fastqsort_fastq: rename_unmapped_repeats/outfile
    out:
      [output_fastqsort_sortedfastq]
  
  step_gzip_sort_repunmapped_fastq:
    run: gzip.cwl
    in:
      input: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq
    out:
      - gzipped
      
  A_map_genome:
    run: star-genome.cwl
    in:
      readFilesIn: 
        source: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq
        valueFrom: ${ return [ self ]; }
      genomeDir: speciesGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
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
    
  A_sort:
    run: sort.cwl
    in:
      input_sort_bam: X_sortlexico/output_sort_bam
    out: [output_sort_bam]
      
  A_index:
    run: samtools-index.cwl
    in:
      alignments: A_sort/output_sort_bam
    out: [alignments_with_index]

  X_barcodecollapsese:
    run: barcodecollapse_se_nostats.cwl
    in:
      input_barcodecollapsese_bam: A_index/alignments_with_index
    out: [output_barcodecollapsese_bam]

  X_sort:
    run: sort.cwl
    in:
      input_sort_bam: X_barcodecollapsese/output_barcodecollapsese_bam
    out: [output_sort_bam]

###########################################################################
# Downstream
###########################################################################

doc: |
  This workflow takes in appropriate trimming params and demultiplexed reads,
  and performs the following steps in order: trimx1, trimx2, fastq-sort, filter repeat elements, fastq-sort, genomic mapping, sort alignment, index alignment, namesort, PCR dedup, sort alignment, index alignment
