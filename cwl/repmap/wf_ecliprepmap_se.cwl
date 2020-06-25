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
  barcode1rmRepBam:
    type: File

  barcode1Inputr1FastqGz:
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



  ### PRE RMDUPED SAM FILE FINAL OUTPUTS ###


  output_ip_concatenated_pre_rmDup_sam_file:
    type: File
    outputSource: step_ecliprepmap_barcode1/output_concatenated_preRmDup_sam_file
  output_input_concatenated_pre_rmDup_sam_file:
    type: File
    outputSource: step_ecliprepmap_input/output_concatenated_preRmDup_sam_file


  ### RMDUPED SAM FILE FINAL OUTPUTS ###

  output_barcode1_concatenated_rmDup_sam_file:
    type: File
    outputSource: step_ecliprepmap_barcode1/output_concatenated_rmDup_sam_file
  output_input_concatenated_rmDup_sam_file:
    type: File
    outputSource: step_ecliprepmap_input/output_concatenated_rmDup_sam_file


  ### FINAL PARSED STATISTICS FILES ###

  output_ip_parsed:
    type: File
    outputSource: step_ecliprepmap_barcode1/output_combined_parsed_file
  output_input_parsed:
    type: File
    outputSource: step_ecliprepmap_input/output_combined_parsed_file
  output_ip_reparsed:
    type: File
    outputSource: step_ecliprepmap_barcode1/output_combined_reparsed_file
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
# Repeat-map single-end IP (1 sample)
###########################################################################

  step_ecliprepmap_barcode1:
    run: wf_ecliprepmap_se_1sample.cwl
    in:
      dataset:
        source: barcode1r1FastqGz
        valueFrom: |
          ${
            return self.nameroot + ".barcode1";
          }
      r1FastqGz: barcode1r1FastqGz
      rmRepBam: barcode1rmRepBam
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      prefixes: prefixes
      chrM_genelist_file: chrM_genelist_file
      mirbase_gff3_file: mirbase_gff3_file
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
# Repeat-map input sample (1 sample)
###########################################################################

  step_ecliprepmap_input:
    run: wf_ecliprepmap_se_1sample.cwl
    in:
      dataset:
        source: barcode1Inputr1FastqGz
        valueFrom: |
          ${
            return self.nameroot + ".input";
          }
      r1FastqGz: barcode1Inputr1FastqGz
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      rmRepBam: barcode1InputrmRepBam
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      prefixes: prefixes
      chrM_genelist_file: chrM_genelist_file
      mirbase_gff3_file: mirbase_gff3_file
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
      ip_parsed_file: step_ecliprepmap_barcode1/output_combined_parsed_file
      input_parsed_file: step_ecliprepmap_input/output_combined_parsed_file
    out:
      - out_file_nopipes_file
      - out_file_withpipes_file

  step_calculate_fold_change_from_reparsed_files:
    run: calculate_fold_change_from_parsed_files.cwl
    in:
      ip_parsed_file: step_ecliprepmap_barcode1/output_combined_reparsed_file
      input_parsed_file: step_ecliprepmap_input/output_combined_reparsed_file
    out:
      - out_file_nopipes_file
      - out_file_withpipes_file