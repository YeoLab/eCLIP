#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:

  dataset:
    type: string

  barcode1r1FastqGz:
    type: File
  barcode1r2FastqGz:
    type: File
  barcode1rmRepBam:
    type: File

  barcode2r1FastqGz:
    type: File
  barcode2r2FastqGz:
    type: File
  barcode2rmRepBam:
    type: File

  barcode1Inputr1FastqGz:
    type: File
  barcode1Inputr2FastqGz:
    type: File
  barcode1InputrmRepBam:
    type: File

  bowtie2_db:
    type: Directory
  bowtie2_prefix:
    type: string
  fileListFile1:
    type: File
  fileListFile2:
    type: File

  gencodeGTF:
    type: File
  gencodeTableBrowser:
    type: File
  repMaskBEDFile:
    type: File

  chrM_genelist_file:
    type: File
  mirbase_gff3_file:
    type: File

  prefixes:
    type: string[]
    default: [
      "AA","AC","AG","AT","AN",
      "CA","CC","CG","CT","CN",
      "GA","GC","GG","GT","GN",
      "TA","TC","TG","TT","TN",
      "NA","NC","NG","NT","NN"
    ]

outputs:


  ### PRE RMDUPED SAM FILE INTERMEDIATES ###


  # output_barcode1_concatenated_pre_rmDup_sam_file:
  #   type: File
  #   outputSource: step_ecliprepmap_barcode1/output_concatenated_preRmDup_sam_file
  # output_barcode2_concatenated_pre_rmDup_sam_file:
  #   type: File
  #   outputSource: step_ecliprepmap_barcode2/output_concatenated_preRmDup_sam_file


  ### PRE RMDUPED SAM FILE FINAL OUTPUTS ###


  output_ip_concatenated_pre_rmDup_sam_file:
    type: File
    outputSource: step_gzip_preRmDup/gzipped
  output_input_concatenated_pre_rmDup_sam_file:
    type: File
    outputSource: step_ecliprepmap_input/output_concatenated_preRmDup_sam_file


  ### RMDUPED SAM FILE INTERMEDIATES ###


  # output_barcode1_concatenated_rmDup_sam_file:
  #   type: File
  #   outputSource: step_ecliprepmap_barcode1/output_concatenated_rmDup_sam_file
  # output_barcode2_concatenated_rmDup_sam_file:
  #   type: File
  #   outputSource: step_ecliprepmap_barcode2/output_concatenated_rmDup_sam_file


  ### RMDUPED SAM FILE FINAL OUTPUTS ###


  output_ip_concatenated_rmDup_sam_file:
    type: File
    outputSource: step_gzip_rmDup/gzipped
  output_input_concatenated_rmDup_sam_file:
    type: File
    outputSource: step_ecliprepmap_input/output_concatenated_rmDup_sam_file


  ### FINAL PARSED STATISTICS FILES ###

  output_ip_parsed:
    type: File
    outputSource: step_combine_parsed/output
  output_input_parsed:
    type: File
    outputSource: step_ecliprepmap_input/output_combined_reparsed_file
  output_ip_reparsed:
    type: File
    outputSource: step_reparse/reparsed_file
  output_input_reparsed:
    type: File
    outputSource: step_ecliprepmap_input/output_combined_reparsed_file
  output_nopipes:
    type: File
    outputSource: step_calculate_fold_change_from_parsed_files/out_file_nopipes_file
  output_withpipes:
    type: File
    outputSource: step_calculate_fold_change_from_parsed_files/out_file_withpipes_file
  output_reparsed_nopipes:
    type: File
    outputSource: step_calculate_fold_change_from_reparsed_files/out_file_nopipes_file
  output_reparsed_withpipes:
    type: File
    outputSource: step_calculate_fold_change_from_reparsed_files/out_file_withpipes_file

steps:

###########################################################################
# Repeat-map paired-end IP (2 barcodes)
###########################################################################

  step_ecliprepmap_barcode1:
    run: wf_ecliprepmap_pe_1barcode.cwl
    in:
      dataset:
        source: dataset
        valueFrom: |
          ${
            return self + ".barcode1";
          }
      r1FastqGz: barcode1r1FastqGz
      r2FastqGz: barcode1r2FastqGz
      rmRepBam: barcode1rmRepBam
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      chrM_genelist_file: chrM_genelist_file
      mirbase_gff3_file: mirbase_gff3_file
      prefixes: prefixes
    out:
      - output_repeat_mapped_sam_file
      - output_rmDup_sam_files
      - output_pre_rmDup_sam_files
      - output_concatenated_rmDup_sam_file
      - output_concatenated_preRmDup_sam_file
      - output_parsed_files
      - output_combined_parsed_file

  step_ecliprepmap_barcode2:
    run: wf_ecliprepmap_pe_1barcode.cwl
    in:
      dataset:
        source: dataset
        valueFrom: |
          ${
            return self + ".barcode2";
          }
      r1FastqGz: barcode2r1FastqGz
      r2FastqGz: barcode2r2FastqGz
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      rmRepBam: barcode2rmRepBam
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      chrM_genelist_file: chrM_genelist_file
      mirbase_gff3_file: mirbase_gff3_file
      prefixes: prefixes
    out:
      - output_repeat_mapped_sam_file
      - output_rmDup_sam_files
      - output_pre_rmDup_sam_files
      - output_concatenated_rmDup_sam_file
      - output_concatenated_preRmDup_sam_file
      - output_parsed_files
      - output_combined_parsed_file
      - output_combined_reparsed_file

###########################################################################
# Combine rmdup and pre-rmdup files from each barcode into single output
###########################################################################

  step_concatenate_rmDup:
    doc: "concatenates all rmdup sam files using cat"
    run: concatenate.cwl
    in:
      files:
        source:
          - step_ecliprepmap_barcode1/output_rmDup_sam_files
          - step_ecliprepmap_barcode2/output_rmDup_sam_files
        linkMerge: merge_flattened
      concatenated_output:
        source: dataset
        valueFrom: |
          ${
            return self + ".RmDup.sam";
          }
    out:
      - concatenated

  step_gzip_rmDup:
    run: gzip.cwl
    in:
      input: step_concatenate_rmDup/concatenated
    out:
      - gzipped

  step_concatenate_pre_rmDup:
    doc: "concatenates all pre-rmduped sam files using cat"
    run: concatenate.cwl
    in:
      files:
        source:
          - step_ecliprepmap_barcode1/output_pre_rmDup_sam_files
          - step_ecliprepmap_barcode2/output_pre_rmDup_sam_files
        linkMerge: merge_flattened
      concatenated_output:
        source: dataset
        valueFrom: |
          ${
            return self + ".preRmDup.sam";
          }
    out:
      - concatenated

  step_gzip_preRmDup:
    run: gzip.cwl
    in:
      input: step_concatenate_pre_rmDup/concatenated
    out:
      - gzipped

  step_combine_parsed:
    doc: "concatenates all final statistics using custom perl script"
    run: combine.cwl
    in:
      files:
        source:
          - step_ecliprepmap_barcode1/output_parsed_files
          - step_ecliprepmap_barcode2/output_parsed_files
        linkMerge: merge_flattened
      outputFile:
        source: dataset
        valueFrom: |
          ${
            return self + ".parsed";
          }
    out:
      - output

  step_reparse:
    run: reparse_samfile_updatedchrM_fixmultenstsort_PE.cwl
    in:
      sam_file: step_gzip_rmDup/gzipped
      chrM_genelist_file: chrM_genelist_file
      fileList1: fileListFile1
      fileList2: fileListFile2
      mirbase_file: mirbase_gff3_file
    out:
      - reparsed_file
###########################################################################
# Repeat-map input sample (1 barcode)
###########################################################################

  step_ecliprepmap_input:
    run: wf_ecliprepmap_pe_1barcode.cwl
    in:
      dataset:
        source: dataset
        valueFrom: |
          ${
            return self + ".input";
          }
      r1FastqGz: barcode1Inputr1FastqGz
      r2FastqGz: barcode1Inputr2FastqGz
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      rmRepBam: barcode1InputrmRepBam
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      chrM_genelist_file: chrM_genelist_file
      mirbase_gff3_file: mirbase_gff3_file
      prefixes: prefixes
    out:
      - output_repeat_mapped_sam_file
      - output_rmDup_sam_files
      - output_pre_rmDup_sam_files
      - output_concatenated_rmDup_sam_file
      - output_concatenated_preRmDup_sam_file
      - output_parsed_files
      - output_combined_parsed_file
      - output_combined_reparsed_file

###########################################################################
# Combine parsed files and calculate fold change/entropy
###########################################################################

  step_calculate_fold_change_from_parsed_files:
    run: calculate_fold_change_from_parsed_files.cwl
    in:
      ip_parsed_file: step_combine_parsed/output
      input_parsed_file: step_ecliprepmap_input/output_combined_parsed_file
    out:
      - out_file_nopipes_file
      - out_file_withpipes_file

  step_calculate_fold_change_from_reparsed_files:
    run: calculate_fold_change_from_parsed_files.cwl
    in:
      ip_parsed_file: step_reparse/reparsed_file
      input_parsed_file: step_ecliprepmap_input/output_combined_reparsed_file
    out:
      - out_file_nopipes_file
      - out_file_withpipes_file
