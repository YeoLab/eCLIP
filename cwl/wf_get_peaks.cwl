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

  ip_read:
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

  input_read:
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

  ip_bam:
    type: string
  ip_r2_bam:
    type: string
  input_bam:
    type: string
  input_r2_bam:
    type: string
  clipper_bed:
    type: string
  inputnormed_bed:
    type: string

  ### Defaults ###
  unmapped_reads_bits:
    type: int
    default: 4

  count_reads:
    type: boolean
    default: true

  ip_mapped_readnum:
    type: string
    default: "ip_mapped_readnum.txt"

  input_mapped_readnum:
    type: string
    default: "input_mapped_readnum.txt"

  # input_norm_output_prefix:
  #   type: string
  #   default: "input_normed"

outputs:
  output_merged_bam:
    type: File
    outputSource: step_ip_alignment/output_r2_bam

  output_input_bam:
    type: File
    outputSource: step_input_alignment/output_r2_bam

  output_clipper_bed:
    type: File
    outputSource: step_clipper/output_bed

  output_ip_mapped_readnum:
    type: File
    outputSource: step_ip_mapped_readnum/output

  output_input_mapped_readnum:
    type: File
    outputSource: step_input_mapped_readnum/output

  output_inputnormedBed:
    type: File
    outputSource: step_input_normalize_peaks/inputnormedBed

  output_compressed_peaks:
    type: File
    outputSource: step_compress_peaks/output_bed

steps:

###########################################################################
# Upstream
###########################################################################
  step_ip_alignment:
    run: wf_clipseqcore_pe_2barcodes.cwl
    in:
      read: ip_read
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      barcodesfasta: barcodesfasta
      randomer_length: randomer_length
      output_bam: ip_bam
      r2_bam: ip_r2_bam
    out:
      [output_r2_bam]

  step_input_alignment:
    run: wf_clipseqcore_pe_1barcode.cwl
    in:
      read: input_read
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      barcodesfasta: barcodesfasta
      randomer_length: randomer_length
      output_bam: input_bam
      r2_bam: input_r2_bam
    out:
      [output_r2_bam]

  step_index_ip:
    run: samtools-index.cwl
    in:
      alignments: step_ip_alignment/output_r2_bam
    out: [alignments_with_index]

  step_index_input:
    run: samtools-index.cwl
    in:
      alignments: step_input_alignment/output_r2_bam
    out: [alignments_with_index]

  step_clipper:
    run: clipper.cwl
    in:
      species: species
      bam: step_ip_alignment/output_r2_bam
      outfile: clipper_bed
    out:
      [output_tsv, output_bed, output_pickle]
  

###########################################################################
# Downstream
###########################################################################

  step_ip_mapped_readnum:
    run: samtools-mappedreadnum.cwl
    in:
      input: step_ip_alignment/output_r2_bam
      readswithoutbits: unmapped_reads_bits
      count: count_reads
      output_name: ip_mapped_readnum
    out: [output]

  step_input_mapped_readnum:
    run: samtools-mappedreadnum.cwl
    in:
      input: step_input_alignment/output_r2_bam
      readswithoutbits: unmapped_reads_bits
      count: count_reads
      output_name: input_mapped_readnum
    out: [output]

  step_input_normalize_peaks:
    run: overlap_peakfi_with_bam_PE.cwl
    # run: overlap_peakfi_with_bam_PE_gabesstupidversion.cwl
    # run: peaksoverlapize.cwl
    in:
      clipBamFile: step_index_ip/alignments_with_index
      inputBamFile: step_index_input/alignments_with_index
      peakFile: step_clipper/output_bed
      clipReadnum: step_ip_mapped_readnum/output
      inputReadnum: step_input_mapped_readnum/output
      outputFile: inputnormed_bed
      # outputPrefix: input_norm_output_prefix
    out: [
      inputnormedBed,
      inputnormedBedfull
    ]

  step_compress_peaks:
    run: peakscompressperl.cwl
    in:
      input_bed: step_input_normalize_peaks/inputnormedBed
    out: [output_bed]
