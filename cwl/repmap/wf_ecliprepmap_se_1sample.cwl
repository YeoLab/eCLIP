#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:

  dataset:
    type: string

  r1FastqGz:
    doc: "Read1 after trimming inline barcodes"
    type: File
  rmRepBam:
    doc: "BAM file after removing repetitive elements (after 2nd STAR mapping)"
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

  output_repeat_mapped_sam_file:
    doc: "first mapped SAM-like file to bowtie2"
    type: File
    outputSource: step_map_repetitive_elements/rep_sam

  output_rmDup_sam_files:
    doc: "duplicate removed SAM-like files, one for each barcode"
    type: File[]
    outputSource: step_deduplicate/deduplicatedRmDupSam

  output_pre_rmDup_sam_files:
    doc: "pre-duplicate removed SAM-like files, one for each barcode"
    type: File[]
    outputSource: step_deduplicate/deduplicatedPreRmDupSam

  output_concatenated_rmDup_sam_file:
    doc: "Final remove duplicate SAM-like file"
    type: File
    outputSource: step_gzip_rmDup/gzipped

  output_concatenated_preRmDup_sam_file:
    doc: "Final duplicated SAM-like file"
    type: File
    outputSource: step_gzip_preRmDup/gzipped

  output_parsed_files:
    doc: "Output file containing read stats for each UMI prefix"
    type: File[]
    outputSource: step_deduplicate/parsedFile

  output_combined_parsed_file:
    doc: "Combined output file containing read stats for all UMI prefixes"
    type: File
    outputSource: step_combine_parsed/output

  output_combined_reparsed_file:
    doc: "re-parsed file"
    type: File
    outputSource: step_reparse/reparsed_file

steps:

  step_map_repetitive_elements:
    run: map_repetitive_elements_se.cwl
    in:
      read1: r1FastqGz
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      file_list_file: fileListFile1
    out:
      - rep_sam

  step_splitbam_repsam:
    run: splitbam_se.cwl
    in:
      sam_file: step_map_repetitive_elements/rep_sam
    out:
      - repsam_s

  step_splitbam_rmrepbam:
    run: splitbam_se.cwl
    in:
      sam_file: rmRepBam
    out:
      - repsam_s

  step_getpair:
    doc: |
      Given a prefix (AA, AC, ... NN), return the rep and rmrep pairs
      belonging to each prefix. Each file contains reads whose first 2nt
      of its umi matches the prefix.
    run: getpair.cwl
    in:
      rep_s: step_splitbam_repsam/repsam_s
      rmrep_s: step_splitbam_rmrepbam/repsam_s
      prefix: prefixes
    scatter: prefix
    out:
      - prefixrep
      - prefixrmrep

  step_deduplicate:
    doc: |
      Takes the repeat-mapped sam-like file, and the remove-replicate
      bam file, and uses UMI information to remove PCR duplicates.
    run: deduplicate_se.cwl
    in:
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBedFile: repMaskBEDFile
      fileList1: fileListFile1
      fileList2: fileListFile2
      repFamilySam: step_getpair/prefixrep
      rmRepSam: step_getpair/prefixrmrep
    scatter: [repFamilySam, rmRepSam]
    scatterMethod: dotproduct

    out:
      - deduplicatedRmDupSam
      - deduplicatedPreRmDupSam
      - parsedFile
      - doneFile

  step_concatenate_rmDup:
    doc: "concatenates all rmdup sam files using cat"
    run: concatenate.cwl
    in:
      files: step_deduplicate/deduplicatedRmDupSam
      concatenated_output:
        source: dataset
        valueFrom: |
          ${
            return self + ".rmDup.sam";
          }
    out:
      - concatenated

  step_concatenate_preRmDup:
    doc: "concatenates all pre-rmduped sam files using cat"
    run: concatenate.cwl
    in:
      files: step_deduplicate/deduplicatedPreRmDupSam
      concatenated_output:
        source: dataset
        valueFrom: |
          ${
            return self + ".preRmDup.sam";
          }
    out:
      - concatenated

  step_gzip_rmDup:
    run: gzip.cwl
    in:
      input: step_concatenate_rmDup/concatenated
    out:
      - gzipped

  step_gzip_preRmDup:
    run: gzip.cwl
    in:
      input: step_concatenate_preRmDup/concatenated
    out:
      - gzipped

  step_combine_parsed:
    doc: "concatenates all final statistics using custom perl script"
    run: combine.cwl
    in:
      files: step_deduplicate/parsedFile
      outputFile:
        source: dataset
        valueFrom: |
          ${
            return self + ".parsed";
          }
    out:
      - output

  step_reparse:
    run: reparse_samfile_updatedchrM_fixmultenstsort_SE.cwl
    in:
      sam_file: step_gzip_rmDup/gzipped
      chrM_genelist_file: chrM_genelist_file
      fileList1: fileListFile1
      fileList2: fileListFile2
      mirbase_file: mirbase_gff3_file
    out:
      - reparsed_file