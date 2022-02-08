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
  barcode1rmRepBam:
    type: File

  barcode2r1FastqGz:
    type: File
  barcode2r2FastqGz:
    type: File
  # BAM file after removing repetitive elements (after 2nd STAR mapping)
  barcode2rmRepBam:
    type: File



  bowtieReferenceTar:
    type: File
    default:
      class: File
      path: /projects/ps-yeolab/software/ecliprepmap/0.0.2/ecliprepmap_refdata/bowtie2_repetitive_elements_index.tar
  fileListFile1:
    type: File
    default:
       class: File
       path: /projects/ps-yeolab/software/ecliprepmap/0.0.2/ecliprepmap_refdata/MASTER_filelist.wrepbaseandtRNA.enst2id.fixed.UpdatedSimpleRepeat
  fileListFile2:
    type: File
    default:
      class: File
      path: /projects/ps-yeolab/software/ecliprepmap/0.0.2/ecliprepmap_refdata/ALLRepBase_elements.id_table.FULL

  gencodeGTF:
    type: File
    default:
      class: File
      #path: "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf"
      path: /projects/ps-yeolab/software/ecliprepmap/0.0.2/ecliprepmap_refdata/gencode.v19.chr_patch_hapl_scaff.annotation.gtf
  gencodeTableBrowser:
    type: File
    default:
      class: File
      #path: "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf.parsed_ucsc_tableformat"
      path: /projects/ps-yeolab/software/ecliprepmap/0.0.2/ecliprepmap_refdata/gencode.v19.chr_patch_hapl_scaff.annotation.gtf.parsed_ucsc_tableformat

  repMaskBEDFile:
    type: File
    default:
      class: File
      path: /projects/ps-yeolab/software/ecliprepmap/0.0.2/ecliprepmap_refdata/RepeatMask.bed

  prefixes:
    type: string[]
    default: ["AA","AC","AG","AT","AN","CA","CC","CG","CT","CN","GA","GC","GG","GT","GN","TA","TC","TG","TT","TN","NA","NC","NG","NT","NN"]


  concatenated_barcode1_nameroot:
    type: string
    default: ecliprepmap_barcode1
  concatenated_barcode2_nameroot:
    type: string
    default: ecliprepmap_barcode2
#  concatenated_filename:
#    type: string
#    default: ecliprepmap_concatenated.sam

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

#  barcode1combinedsam:
#    type: File
#    outputSource: ecliprepmap_barcode1/combinedsam
#  barcode2combinedsam:
#    type: File
#    outputSource: ecliprepmap_barcode2/combinedsam
#  combinedsam:
#    type: File
#    outputSource: combine_barcodes/combinedsam

steps:

  ecliprepmap_barcode1:
    run: wf_ecliprepmapsingle.cwl
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
#      combined_nameroot: combined_barcode1_nameroot
      prefixes: prefixes
    out:
      - maprep_repsam
      #- rep_split
      - rmDuped_sam_s
      - concatenatedRmDupSam
      - concatenatedDupSam
      #- combinedsam
      - parsedFiles

  ecliprepmap_barcode2:
    run: wf_ecliprepmapsingle.cwl
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
#      combined_nameroot: combined_barcode2_nameroot
      prefixes: prefixes
    out:
      - maprep_repsam
      #- rep_split
      - rmDuped_sam_s
      - concatenatedRmDupSam
      - concatenatedDupSam
      #- combinedsam
      - parsedFiles

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

#  combine_barcodes:
#    in:
#      sam1: ecliprepmap_barcode1/combinedsam
#      sam2: ecliprepmap_barcode1/combinedsam
#    out:
#      - combinedsam
#    run:
#      class: CommandLineTool
#      baseCommand: [cat]
#      inputs:
#        sam1:
#          type: File
#          inputBinding:
#            position: 1
#        sam2:
#          type: File
#          inputBinding:
#            position: 2
#      #stdout: $(inputs.sam1.nameroot).final.sam
#      stdout: ecliprepmap_conmbined.sam
#      outputs:
#        combinedsam:
#          type: File
#          outputBinding:
#            glob: ecliprepmap_conmbined.sam

