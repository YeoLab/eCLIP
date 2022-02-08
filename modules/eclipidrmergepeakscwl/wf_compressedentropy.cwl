#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow


inputs:

  clipBamFile:
    type: File

  inputBamFile:
    type: File

  clipBedFile:
    type: File



  outputprefix:
    type: string

  inputnormsuffix:
    type: string
    default: "uncompressed"


outputs:


  clipReadnum:
    type: File
    outputSource: calculate_clip_readnum/readnum
  inputReadnum:
    type: File
    outputSource: calculate_input_readnum/readnum


  inputnormedBed:
    type: File
    outputSource: input_norm/inputnormedBed
  inputnormedBedfull:
    type: File
    outputSource: input_norm/inputnormedBedfull


  compressedBed:
    type: File
    outputSource: compress_peaks/compressedBed
  compressedBedfull:
    type: File
    outputSource: compress_peaks/compressedBedfull


  entropyFull:
    type: File
    outputSource: make_informationcontent_from_peaks/entropyFull
  entropyExcessreads:
    type: File
    outputSource: make_informationcontent_from_peaks/entropyExcessreads


  entropyBed:
    type: File
    outputSource: create_entropybed_from_entropyfull/bed


steps:

  calculate_clip_readnum:
    run: calculate_readnum.cwl
    in:
      bamFile: clipBamFile
      #output: clipReadNum
    out:
      - readnum

  calculate_input_readnum:
    run: calculate_readnum.cwl
    in:
      bamFile: inputBamFile
      #output: inputReadNum
    out:
      - readnum


  input_norm:
    run: overlap_peakfi_with_bam_PE.cwl
    in:
      clipBamFile: clipBamFile
      inputBamFile: inputBamFile
      peakFile: clipBedFile
      clipReadnum: calculate_clip_readnum/readnum
      inputReadnum: calculate_input_readnum/readnum

      outputprefix: outputprefix
      inputnormsuffix: inputnormsuffix

    out:
      - inputnormedBed
      - inputnormedBedfull

  compress_peaks:
    run: compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat_outputfull.cwl
    in:
      inputFile: input_norm/inputnormedBedfull

      outputprefix: outputprefix

    out:
      - compressedBed
      - compressedBedfull

  make_informationcontent_from_peaks:
    run: make_informationcontent_from_peaks.cwl
    in:
      compressedBedfull: compress_peaks/compressedBedfull
      clipReadnum: calculate_clip_readnum/readnum
      inputReadnum: calculate_input_readnum/readnum

      outputprefix: outputprefix

    out:

      # ATTENTION! THIS IS WHATIS USED BY THE MAIN WORKFLOW !
      - entropyFull

      # NOT SURE IF THIS IS BEING USED FOR ANYTHING
      - entropyExcessreads


  # ATTENTION! THIS IS NOT USED BY THE MAIN WORKFLOW !!!
  create_entropybed_from_entropyfull:
    run: full_to_bed.cwl
    in:
      full: make_informationcontent_from_peaks/entropyFull
    out:
      - bed

