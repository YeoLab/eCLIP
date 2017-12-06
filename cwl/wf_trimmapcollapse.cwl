#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement

#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:


  trimfirst_overlap_length:
    type: File
  trimagain_overlap_length:
    type: File

  g_adapters_default:
    type: File
  a_adapters_default:
    type: File
  g_adapters:
    type: File
  a_adapters:
    type: File
  A_adapters:
    type: File

  chromsizes:
    type: File
  starrefrepeats:
    type: File
  starrefgenome:
    type: File

  #out_filter_multimap_nmax_30:
  #  type: string
  #  default: "30"

  out_filter_multimap_nmax_1:
    type: string
  #  default: "1"


#  reads_X:
#    type:
#      type: record
#      fields:
#        fwd: File
#        rev: File

  reads_Xfwd:
    type: File
  reads_Xrev:
    type: File

outputs:

#  X_qc_fwd_report:
#    type: File
#    outputSource: X_qc_fwd/output_qc_report
#  X_qc_fwd_stats:
#    type: File
#    outputSource: X_qc_fwd/output_qc_stats

#  X_qc_rev_report:
#    type: File
#    outputSource: X_qc_rev/output_qc_report
#  X_qc_rev_stats:
#    type: File
#    outputSource: X_fqc_rev/output_qc_stats

  X_output_trim_fwd:
    type: File
    outputSource: X_trim/output_trim_fwd
  X_output_trim_rev:
    type: File
    outputSource: X_trim/output_trim_rev
  X_output_trim_report:
    type: File
    outputSource: X_trim/output_trim_report

  X_output_trimagain_fwd:
    type: File
    outputSource: X_trim_again/output_trim_fwd
  X_output_trimagain_rev:
    type: File
    outputSource: X_trim_again/output_trim_rev
  X_output_trimagain_report:
    type: File
    outputSource: X_trim_again/output_trim_report

  X_output_maprepeats_unmapped_fwd:
    type: File
    outputSource: X_map_repeats/output_map_unmapped_fwd
  X_output_maprepeats_unmapped_rev:
    type: File
    outputSource: X_map_repeats/output_map_unmapped_rev
  X_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: X_map_repeats/output_map_mapped_to_genome
  X_output_maprepeats_stats:
    type: File
    outputSource: X_map_repeats/output_map_stats

  X_output_fastqsort_sortedfastq_fwd:
    type: File
    outputSource: X_fastqsort_fwd/output_fastqsort_sortedfastq

  X_output_fastqsort_sortedfastq_rev:
    type: File
    outputSource: X_fastqsort_rev/output_fastqsort_sortedfastq

  X_output_map_mapped_to_genome:
    type: File
    outputSource: X_map/output_map_mapped_to_genome
  X_output_map_stats:
    type: File
    outputSource: X_map/output_map_stats
  X_output_map_unmapped_fwd:
    type: File
    outputSource: X_map/output_map_unmapped_fwd
  X_output_map_unmapped_rev:
    type: File
    outputSource: X_map/output_map_unmapped_rev

  X_output_barcodecollapsepe_bam:
    type: File
    outputSource: X_barcodecollapsepe/output_barcodecollapsepe_bam
  X_output_barcodecollapsepe_metrics:
    type: File
    outputSource: X_barcodecollapsepe/output_barcodecollapsepe_metrics

  X_output_sort_bam:
    type: File
    outputSource: X_sort/output_sort_bam

  X_output_index_bai:
    type: File
    outputSource: X_index/output_index_bai
     


steps:


#  X_qc_fwd:
#    run: qc.cwl
#    in:
#      reads: reads_Afwd
#    out: [output_qc_report, output_qc_stats]

#  X_qc_rev:
#    run: qc.cwl
#    in:
#      reads: reads_Arev
#    out: [output_qc_report, output_qc_stats]

  X_trim:
    run: trim.cwl
    in:
      input_trim_fwd: reads_Xfwd
      input_trim_rev: reads_Xrev
      input_trim_overlap_length_file: trimfirst_overlap_length
      input_trim_g_adapters: g_adapters
      input_trim_a_adapters: a_adapters
      input_trim_A_adapters: A_adapters
    out: [output_trim_fwd, output_trim_rev, output_trim_report]

  X_trim_again:
    run: trim.cwl
    in:
      input_trim_fwd: X_trim/output_trim_fwd
      input_trim_rev: X_trim/output_trim_rev
      input_trim_overlap_length_file: trimagain_overlap_length
      input_trim_g_adapters: g_adapters_default
      input_trim_a_adapters: a_adapters_default
      input_trim_A_adapters: A_adapters
    out: [output_trim_fwd, output_trim_rev, output_trim_report]


  X_map_repeats:
    run: map.cwl
    in:
      #out_filter_multimap_nmax: out_filter_multimap_nmax_30
      out_filter_multimap_nmax:
        valueFrom: "30"
      input_map_ref: starrefrepeats
      input_map_fwd: X_trim_again/output_trim_fwd
      input_map_rev: X_trim_again/output_trim_rev
    out: [output_map_unmapped_fwd, output_map_unmapped_rev, output_map_mapped_to_genome, output_map_stats]

  #X_view_repeats:
  #  run: view.cwl
  #  in:
  #     input_view_bam: X_map_repeats/output_map_mapped_to_genome
  #  out: [output_view_sam]

  #X_count_repeats:
  #  run: countaligned.cwl
  #  in:
  #    input_countaligned_sam: X_view_repeats/output_view_sam
  #  out: [output_countaligned_chromcounts]

  #X_qc_again:
  #  run: qc.cwl
  #  in:
  #    reads: X_map_repeats/output_map_unmapped_fwd
  #  out: [output_qc_report, output_qc_stats]

  X_fastqsort_fwd:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: X_map_repeats/output_map_unmapped_fwd
    out: [output_fastqsort_sortedfastq]

  X_fastqsort_rev:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: X_map_repeats/output_map_unmapped_rev
    out: [output_fastqsort_sortedfastq]

  X_map:
    run: map.cwl
    in:
      out_filter_multimap_nmax: out_filter_multimap_nmax_1
      #out_filter_multimap_nmax:
      #  valueFrom: "1"
      input_map_ref: starrefgenome
      input_map_fwd: X_fastqsort_fwd/output_fastqsort_sortedfastq
      input_map_rev: X_fastqsort_rev/output_fastqsort_sortedfastq
    out: [output_map_unmapped_fwd, output_map_unmapped_rev, output_map_mapped_to_genome, output_map_stats]

  # samtools sort -n 204_RBFOX2.rep1.CLIP.A01.r1.fq.gz.adapterTrim.round2.rmRep.bam > foo.bam
  # Goes after the second star map and before the pcr duplicate removal.
  X_sortlexico:
    run: sortlexico.cwl
    in:
      input_sortlexico_bam: X_map/output_map_mapped_to_genome
    out: [output_sortlexico_bam]

  X_barcodecollapsepe:
    run: barcodecollapsepe.cwl
    in:
      input_barcodecollapsepe_bam: X_sortlexico/output_sortlexico_bam
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
