#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:

  barcode1r1FastqGz:
    type: File
  barcode1r2FastqGz:
    type: File
  # BAM file after removing repetitive elements (after 2nd STAR mapping)
  barcode1rmRepBam:States
    type: File

  barcode2r1FastqGz:
    type: File
  barcode2r2FastqGz:
    type: File
  # BAM file after removing repetitive elements (after 2nd STAR mapping)
  barcode2rmRepBam:
    type: File

  barcode1Inputr1FastqGz:
    type: File
  barcode1Inputr2FastqGz:
    type: File
  # BAM file after removing repetitive elements (after 2nd STAR mapping)
  barcode1InputrmRepBam:
    type: File


  bowtieReferenceTar:
    type: File
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

  prefixes:
    type: string[]
    default: ["AA","AC","AG","AT","AN","CA","CC","CG","CT","CN","GA","GC","GG","GT","GN","TA","TC","TG","TT","TN","NA","NC","NG","NT","NN"]


  concatenated_barcode1_nameroot:
    type: string
    default: ecliprepmap_barcode1

  concatenated_barcode2_nameroot:
    type: string
    default: ecliprepmap_barcode2

  concatenated_barcode1_input_nameroot:
    type: string
    default: ecliprepmap_input_barcode1



  concatenated_barcode1_rmdup_nameroot:
    type: string
    default: ecliprepmap_barcode1_rmdup
  
  concatenated_barcode1_dup_nameroot:
    type: string
    default: ecliprepmap_barcode1_dup



  concatenated_barcode2_rmdup_nameroot:
    type: string
    default: ecliprepmap_barcode2_rmdup
  
  concatenated_barcode2_dup_nameroot:
    type: string
    default: ecliprepmap_barcode2_dup



  concatenated_barcode1_input_rmdup_nameroot:
    type: string
    default: ecliprepmap_input_barcode1_rmdup

  concatenated_barcode1_input_dup_nameroot:
    type: string
    default: ecliprepmap_input_barcode1_dup



  combinedParsedFile:
    type: string
    default: combined.parsed

#  combined_filename:
#    type: string
#    default: ecliprepmap_combined.sam

outputs:

  barcode1concatenatedRmDupSam:
    type: File
    outputSource: ecliprepmap_barcode1/concatenatedRmDupSam
  barcode2concatenatedRmDupSam:
    type: File
    outputSource: ecliprepmap_barcode2/concatenatedRmDupSam
  concatenatedRmDupSam:
    type: File
    outputSource: concatenate_rmdup_barcodes/concatenatedsam

  barcode1concatenatedPreRmDupSam:
    type: File
    outputSource: ecliprepmap_barcode1/concatenatedDupSam
  barcode2concatenatedPreRmDupSam:
    type: File
    outputSource: ecliprepmap_barcode2/concatenatedDupSam
  concatenatedPreRmDupSam:
    type: File
    outputSource: concatenate_prermdup_barcodes/concatenatedsam

  combinedParsed:
    type: File
    outputSource: combine_parsed/output
  
  combinedInputParsed:
    type: File
    outputSource: ecliprepmap_barcode1_input/combinedParsed

  combinedsam:
    type: File
    outputSource: concatenate_rmdup_barcodes/concatenatedsam

steps:

  ecliprepmap_barcode1:
    run: wf_ecliprepmap1barcode.cwl
    in:
      r1FastqGz: barcode1r1FastqGz
      r2FastqGz: barcode1r2FastqGz
      bowtieReferenceTar: bowtieReferenceTar
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      rmRepBam: barcode1rmRepBam
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      concatenated_rmdup_nameroot: concatenated_barcode1_rmdup_nameroot
      concatenated_dup_nameroot: concatenated_barcode1_dup_nameroot
      prefixes: prefixes
    out:
      - maprep_repsam
      - rmDuped_sam_s
      - concatenatedRmDupSam
      - concatenatedDupSam
      - parsedFiles
      - combinedParsed

  ecliprepmap_barcode2:
    run: wf_ecliprepmap1barcode.cwl
    in:
      r1FastqGz: barcode2r1FastqGz
      r2FastqGz: barcode2r2FastqGz
      bowtieReferenceTar: bowtieReferenceTar
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      rmRepBam: barcode2rmRepBam
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      concatenated_rmdup_nameroot: concatenated_barcode2_rmdup_nameroot
      concatenated_dup_nameroot: concatenated_barcode2_dup_nameroot
      prefixes: prefixes
    out:
      - maprep_repsam
      - rmDuped_sam_s
      - concatenatedRmDupSam
      - concatenatedDupSam
      - parsedFiles
      - combinedParsed

  ecliprepmap_barcode1_input:
    run: wf_ecliprepmap1barcode.cwl
    in:
      r1FastqGz: barcode1Inputr1FastqGz
      r2FastqGz: barcode1Inputr2FastqGz
      bowtieReferenceTar: bowtieReferenceTar
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      rmRepBam: barcode1InputrmRepBam
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      concatenated_rmdup_nameroot: concatenated_barcode1_input_rmdup_nameroot
      concatenated_dup_nameroot: concatenated_barcode1_input_dup_nameroot
      prefixes: prefixes
    out:
      - maprep_repsam
      - rmDuped_sam_s
      - concatenatedRmDupSam
      - concatenatedDupSam
      - parsedFiles
      - combinedParsed
      
  concatenate_rmdup_barcodes:
    in:
      sam1: ecliprepmap_barcode1/concatenatedRmDupSam
      sam2: ecliprepmap_barcode2/concatenatedRmDupSam
    out:
      - concatenatedsam
    run:
      class: CommandLineTool
      baseCommand: [cat]
      inputs:
        sam1:
          type: File
          inputBinding:
            position: 1
        sam2:
          type: File
          inputBinding:
            position: 2
      #stdout: $(inputs.sam1.nameroot).final.sam
      stdout: ecliprepmap_concatenated.sam
      outputs:
        concatenatedsam:
          type: File
          outputBinding:
            glob: ecliprepmap_concatenated.sam

  concatenate_prermdup_barcodes:
    in:
      sam1: ecliprepmap_barcode1/concatenatedDupSam
      sam2: ecliprepmap_barcode2/concatenatedDupSam
    out:
      - concatenatedsam
    run:
      class: CommandLineTool
      baseCommand: [cat]
      inputs:
        sam1:
          type: File
          inputBinding:
            position: 1
        sam2:
          type: File
          inputBinding:
            position: 2
      #stdout: $(inputs.sam1.nameroot).final.sam
      stdout: ecliprepmap_concatenated.prermdup.sam
      outputs:
        concatenatedsam:
          type: File
          outputBinding:
            glob: ecliprepmap_concatenated.prermdup.sam

  combine_parsed:
    run: combine.cwl
    in:
      file_s:
        source: [ecliprepmap_barcode1/parsedFiles, ecliprepmap_barcode2/parsedFiles]
        linkMerge: merge_flattened
      outputFile: combinedParsedFile
    out: 
      - output
