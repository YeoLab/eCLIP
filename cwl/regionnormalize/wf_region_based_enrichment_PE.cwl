#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: MultipleInputFeatureRequirement

inputs:

  clipBamFile:
    type: File
  inputBamFile:
    type: File

  gencodeGTFFile:
    type: File
  gencodeTableBrowserFile:
    type: File

  trna_bed_file:
    type: File
  lncrna_table_file:
    type: File
  lncrna_full_file:
    type: File

outputs:
  clipBroadFeatureCountsFile:
    type: File
    outputSource: clipCountReadsBroadFeatures/outputFile

  inputBroadFeatureCountsFile:
    type: File
    outputSource: inputCountReadsBroadFeatures/outputFile

  combinedOutputFile:
    type: File
    outputSource: combineReadsByLocFiles/outputFile

  l2fcWithPvalEnrFile:
    type: File
    outputSource: significanceTest/l2fcWithPvalEnrOutputFile
  l2fcFile:
    type: File
    outputSource: significanceTest/l2fcOutputFile

steps:
  clipCalculateMappedReadNum:
    run: samtools-mappedreadnum.cwl
    in:
      input: clipBamFile
      readswithoutbits:
        default: 4
      count:
        default: true
      output_name:
        default: ip_mapped_readnum.txt
    out:
      - output

  inputCalculateMappedReadNum:
    run: samtools-mappedreadnum.cwl
    in:
      input: inputBamFile
      readswithoutbits:
        default: 4
      count:
        default: true
      output_name:
        default: input_mapped_readnum.txt
    out:
      - output

  clipCountReadsBroadFeatures:
    run: count_reads_broadfeatures_frombamfi_PEmap_lncRNA.cwl
    in:
      clipBamFile: clipBamFile
      gencodeGTFFile: gencodeGTFFile
      gencodeTableBrowserFile: gencodeTableBrowserFile
      trna_bed_file: trna_bed_file
      lncrna_table_file: lncrna_table_file
      lncrna_full_file: lncrna_full_file
    out:
      - outputFile

  inputCountReadsBroadFeatures:
    run: count_reads_broadfeatures_frombamfi_PEmap_lncRNA.cwl
    in:
      clipBamFile: inputBamFile
      gencodeGTFFile: gencodeGTFFile
      gencodeTableBrowserFile: gencodeTableBrowserFile
      trna_bed_file: trna_bed_file
      lncrna_table_file: lncrna_table_file
      lncrna_full_file: lncrna_full_file
    out:
      - outputFile

  combineReadsByLocFiles:
    run: combine_ReadsByLoc_files.cwl
    in:
      readsByLocFiles: [
        clipCountReadsBroadFeatures/outputFile,
        inputCountReadsBroadFeatures/outputFile
      ]
    out:
      - outputFile

  significanceTest:
    run: convert_ReadsByLoc_combined_significancecalls.cwl
    in:
      combinedReadsByLocFile: combineReadsByLocFiles/outputFile
      clipMappedReadNumFile: clipCalculateMappedReadNum/output
      inputMappedReadNumFile: inputCalculateMappedReadNum/output
    out:
      - l2fcOutputFile
      - l2fcWithPvalEnrOutputFile