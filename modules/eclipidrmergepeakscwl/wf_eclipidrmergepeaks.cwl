#!/usr/bin/env cwltool


cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement


inputs:


  rep1ClipBam:
    type: File
  rep1InputBam:
    type: File
  rep1PeaksBed:
    type: File

  rep2ClipBam:
    type: File
  rep2InputBam:
    type: File
  rep2PeaksBed:
    type: File


  # IDR PARAMS
  idrInputFileType:
    type: string
    default: bed
  idrRank:
    type: int
    default: 5
  idrPeakMergeMethod:
    type: string
    default: max
  idrPlot:
    type: boolean
    default: true


  #
  outputprefixRep1:
    type: string
    default: "01"
  outputprefixRep2:
    type: string
    default: "02"

  #
  inputnormsuffixRep1:
    type: string
    default: "idrpeaks_inputnormed_01"
  inputnormsuffixRep2:
    type: string
    default: "idrpeaks_inputnormed_02"

  #
  idrOutputFilename:
    type: string
    default: "01v02.idr.out"
  idrOutputBedFilename:
    type: string
    default: "01v02.idr.out.bed"

  # POST IDR PROCESSING
  idrInputNormRep1BedFilename:
    type: string
    default: "01v02.IDR.out.idrpeaks_inputnormed.01.bed"
  idrInputNormRep2BedFilename:
    type: string
    default: "01v02.IDR.out.idrpeaks_inputnormed.02.bed"

  # MERGE PEAKS
  rep1ReproducingPeaksFullOutputFilename:
    type: string
    default: "01v02.IDR.out.0102merged.01.full"
  rep2ReproducingPeaksFullOutputFilename:
    type: string
    default: "01v02.IDR.out.0102merged.02.full"

  # FINAL OUTPUTS
  mergedPeakBedFilename:
    type: string
    default: "01v02.IDR.out.0102merged.bed"
  mergedPeakCustomBedFilename:
    type: string
    default: "01v02.IDR.out.0102merged.custombed"




outputs:


  rep1clipReadnum:
    type: File
    outputSource: rep1_input_norm_and_entropy/clipReadnum
  rep1inputReadnum:
    type: File
    outputSource: rep1_input_norm_and_entropy/inputReadnum


  rep1inputnormedBedfull:
    type: File
    outputSource: rep1_input_norm_and_entropy/inputnormedBed
  rep1inputnormedBedfulll:
    type: File
    outputSource: rep1_input_norm_and_entropy/inputnormedBedfull


  rep1entropyFull:
    type: File
    outputSource: rep1_input_norm_and_entropy/entropyFull
  rep1entropyExcessreads:
    type: File
    outputSource: rep1_input_norm_and_entropy/entropyExcessreads
  rep1entropyBed:
    type: File
    outputSource: rep1_input_norm_and_entropy/entropyBed




  rep2clipReadnum:
    type: File
    outputSource: rep2_input_norm_and_entropy/clipReadnum
  rep2inputReadnum:
    type: File
    outputSource: rep2_input_norm_and_entropy/inputReadnum


  rep2inputnormedBedl:
    type: File
    outputSource: rep2_input_norm_and_entropy/inputnormedBed
  rep2inputnormedBedfull:
    type: File
    outputSource: rep2_input_norm_and_entropy/inputnormedBedfull


  rep2entropyFull:
    type: File
    outputSource: rep2_input_norm_and_entropy/entropyFull
  rep2entropyExcessreads:
    type: File
    outputSource: rep2_input_norm_and_entropy/entropyExcessreads
  rep2entropyBed:
    type: File
    outputSource: rep2_input_norm_and_entropy/entropyBed




  idrOutput:
    type: File
    outputSource: idr/output

  idrOutputBed:
    type: File
    outputSource: create_bed_from_idr/output



  idrOutputInputNormRep1:
    type: File
    outputSource: rep1_input_norm_using_idr_peaks/inputnormedBed
  idrOutputInputNormRep2:
    type: File
    outputSource: rep2_input_norm_using_idr_peaks/inputnormedBed



  idrOutputInputNormRep1Full:
    type: File
    outputSource: rep1_input_norm_using_idr_peaks/inputnormedBedfull
  idrOutputInputNormRep2Full:
    type: File
    outputSource: rep2_input_norm_using_idr_peaks/inputnormedBedfull


  rep1ReproducingPeaksFullOutput:
    type: File
    outputSource: get_reproducing_peaks/rep1FullOut
  rep2ReproducingPeaksFullOutput:
    type: File
    outputSource: get_reproducing_peaks/rep2FullOut


  mergedPeakBed:
    type: File
    outputSource: get_reproducing_peaks/bedOut
  mergedPeakCustomBed:
    type: File
    outputSource: get_reproducing_peaks/customBedOut


  reproducing_peaks_count:
     type: int
     outputSource: count_reproducing_peaks/linescount



steps:



  rep1_input_norm_and_entropy:
    run: wf_compressedentropy.cwl
    in:
      clipBamFile: rep1ClipBam
      inputBamFile: rep1InputBam
      clipBedFile: rep1PeaksBed
      outputprefix: outputprefixRep1
      inputnormsuffix: inputnormsuffixRep1

    out:
      - clipReadnum
      - inputReadnum

      - inputnormedBed
      - inputnormedBedfull

      - compressedBed
      - compressedBedfull

      - entropyFull
      - entropyExcessreads
      - entropyBed

  rep2_input_norm_and_entropy:
    run: wf_compressedentropy.cwl
    in:
      clipBamFile: rep2ClipBam
      inputBamFile: rep2InputBam
      clipBedFile: rep2PeaksBed
      outputprefix: outputprefixRep2
      inputnormsuffix: inputnormsuffixRep2

    out:
      - clipReadnum
      - inputReadnum

      - inputnormedBed
      - inputnormedBedfull

      - compressedBed
      - compressedBedfull

      - entropyFull
      - entropyExcessreads
      - entropyBed



  idr:
    run: idr.cwl
    in:
      samples: [rep1_input_norm_and_entropy/entropyBed, rep2_input_norm_and_entropy/entropyBed]
      inputFileType: idrInputFileType
      rank: idrRank
      peakMergeMethod: idrPeakMergeMethod
      plot: idrPlot

      outputFilename: idrOutputFilename

    out:
      - output



  create_bed_from_idr:
    run: parse_idr_peaks.cwl
    in:
      idrFile: idr/output
      entropyFile1: rep1_input_norm_and_entropy/entropyFull
      entropyFile2: rep2_input_norm_and_entropy/entropyFull

      outputFilename: idrOutputBedFilename
    out:
      - output



  rep1_input_norm_using_idr_peaks:
    run: overlap_peakfi_with_bam_PE.cwl
    in:
      clipBamFile: rep1ClipBam
      inputBamFile: rep1InputBam

      peakFile: create_bed_from_idr/output

      clipReadnum: rep1_input_norm_and_entropy/clipReadnum
      inputReadnum: rep1_input_norm_and_entropy/inputReadnum

      outputprefix: idrInputNormRep1BedFilename
      inputnormsuffix: inputnormsuffixRep1

    out:
      - inputnormedBed
      - inputnormedBedfull

  rep2_input_norm_using_idr_peaks:
    run: overlap_peakfi_with_bam_PE.cwl
    in:
      clipBamFile: rep2ClipBam
      inputBamFile: rep2InputBam

      peakFile: create_bed_from_idr/output

      clipReadnum: rep2_input_norm_and_entropy/clipReadnum
      inputReadnum: rep2_input_norm_and_entropy/inputReadnum

      outputprefix: idrInputNormRep2BedFilename
      inputnormsuffix: inputnormsuffixRep2


    out:
      - inputnormedBed
      - inputnormedBedfull




  get_reproducing_peaks:
    run: get_reproducing_peaks.cwl
    in:
      rep1FullIn: rep1_input_norm_using_idr_peaks/inputnormedBedfull
      rep2FullIn: rep2_input_norm_using_idr_peaks/inputnormedBedfull

      rep1Entropy: rep1_input_norm_and_entropy/entropyFull
      rep2Entropy: rep2_input_norm_and_entropy/entropyFull

      idr: idr/output

      rep1FullOutFilename: rep1ReproducingPeaksFullOutputFilename
      rep2FullOutFilename: rep2ReproducingPeaksFullOutputFilename
      bedOutFilename: mergedPeakBedFilename
      customBedOutFilename: mergedPeakCustomBedFilename

    out:
      - rep1FullOut
      - rep2FullOut
      - bedOut
      - customBedOut


  count_reproducing_peaks:
      run: linescount.cwl
      in:
        textfile: get_reproducing_peaks/bedOut
      out:
        - linescount
