#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement


inputs:

  singleprefix:
    type: string
    default: "AA"

  r1FastqGz:
    type: File
  r2FastqGz:
    type: File
  # BAM file after removing repetitive elements (after 2nd STAR mapping)
  rmRepBam:
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


  prefixes: string[]

  concatenated_rmdup_nameroot:
    type: string
    default: "ecliprepmap_single_rmdup"
  
  concatenated_dup_nameroot:
    type: string
    default: "ecliprepmap_single_dup"

#  combined_nameroot:
#    type: string
#    default: "single.combined.sam"

outputs:


  ## first mapped SAM-like file to bowtie2
  maprep_repsam:
    type: File
    outputSource: maprep/repsam


  ## duplicate removed SAM-like files, one for each barcode
  rmDuped_sam_s:
    type: File[]
    outputSource: deduplicate/deduplicatedRmDupSam


  ## Final remove duplicate SAM-like file
  concatenatedRmDupSam:
    type: File
    outputSource: concatenateRmDup/concatenatedsam
  
  ## Final PRERMDUP SAM-like file
  concatenatedDupSam:
    type: File
    outputSource: concatenateDup/concatenatedsam

#   combinedsam:
#     type: File
#     outputSource: combine/combinedsam

#   outputFilename:
#     type: string
#     default: combined.parsed.txt

  parsedFiles:
    type: File[]
    outputSource: deduplicate/parsedFile

steps:

  maprep:
    run: maprep.cwl
    in:
      read1: r1FastqGz
      read2: r2FastqGz
      indexTar: bowtieReferenceTar
      fileListFile: fileListFile1
    out:
      - repsam

  splitbam_repsam:
    run: splitbam.cwl
    in:
      sam: maprep/repsam
    out:
      - repsam_s


  splitbam_rmrepbam:
    run: splitbam.cwl
    in:
      sam: rmRepBam
    out:
      - repsam_s



  # pair_matching_prefixes
  getpair:
    run: getpair.cwl
    in:
      rep_s: splitbam_repsam/repsam_s
      rmrep_s: splitbam_rmrepbam/repsam_s
      prefix: prefixes
    scatter: prefix
    out:
      - prefixrep
      - prefixrmrep



  deduplicate:
    run: deduplicate.cwl
    in:
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBedFile: repMaskBEDFile

      fileList1: fileListFile1
      fileList2: fileListFile2

      repFamilySam: getpair/prefixrep
      rmRepSam: getpair/prefixrmrep
    scatter: [repFamilySam, rmRepSam]
    scatterMethod: dotproduct

    out:
      - deduplicatedRmDupSam
      - deduplicatedPreRmDupSam
      - parsedFile
      - doneFile

  concatenateRmDup:
    run: concatenate.cwl
    in:
      file_s: deduplicate/deduplicatedRmDupSam
      concatenated_nameroot: concatenated_rmdup_nameroot
    out:
      - concatenatedsam

  concatenateDup:
    run: concatenate.cwl
    in:
      file_s: deduplicate/deduplicatedPreRmDupSam
      concatenated_nameroot: concatenated_dup_nameroot
    out:
      - concatenatedsam
       
#  combine:
#    run: combine.cwl
#    in:
#      file_s: deduplicate/parsedFile
#      combined_nameroot: combined_nameroot
#    out:
#      - combinedsam

#   combine_parsed:
#     run: combine.cwl
#     in:
#       file_s: deduplicate/parsedFile
#       outputFilename: outputFilename
#     out:
#       - combinedsam



## Rough outline of steps involved

# unzip adaptertrim/polyAtrim read1.fastq.gz
# unzip adaptertrim/polyAtrim read2.fastq.gz

# split_bam_to_subfiles.pl rmRep.bam
# parse_bowtie2_output_realtime_includemultifamily.pl read1.fastq read2.fastq filelist.UpdatedSimpleRepeat working_dir/ samfile.sam
# split_bam_to_subfiles.pl samfile.sam

# for each AA/AC/AT/AT/CA/etc. perform duplicate removal and remove the tmp files.
# duplicate_removal_inline_paired.count_region_other_reads.pl samfile.sam.AA.tmp pre-merged-X1A-round2.rmRep.bam.AA.tmp

# cat XYZ.*.AA.tmp.combined_w_uniquemap.rmDup.sam >> XYZ.combined_w_uniquemap.rmDup.sam
# cat XYZ.*.AA.tmp.combined_w_uniquemap.prermDup.sam >> XYZ.combined_w_uniquemap.prermDup.sam
# gzip XYZ.combined_w_uniquemap.prermDup.sam

# merge_multiple_parsed_files.pl *.sam.parsed (both X1A and X1B)
