#!/usr/bin/env cwltool


### SELF-CONSISTENCY RATIO ###
### https://www.google.com/url?q=https%3A%2F%2Fwww.encodeproject.org%2Fdata-standards%2Fterms%2F&sa=D&sntz=1&usg=AFQjCNFI_BjgnFhlrkbG6ByfLRkg9XEtgw

cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement


inputs:

#  bam_rep1:
#    type: File
#  bam_rep2:
#    type: File
   bam_input1:
     type: File
   bam_input2:
     type: File

   rep1split1:
     type: File
   rep1split2:
     type: File
   rep2split1:
     type: File
   rep2split2:
     type: File

  species:
    type: string
    default: hg19

outputs:

#  bam_rep1_splits_reproducing_peaks_count:
#    type: File
#    outputSource: bam_rep1_splits_reproducingpeakscount/reproducing_peaks_count
#
#  bam_rep1_splits_reproducing_peaks_count:
#    type: File
#    outputSource: bam_rep2_splits_reproducingpeakscount/reproducing_peaks_count

  selfconssistency_ratio:
    type: float
    outputSource: max_over_min/ratio


steps:


#  bam_rep1_split:
#    run: bam_split.cwl
#    in: bam_rep1
#    out:
#      - split1
#      - split2

#  bam_rep2_split:
#    run: bam_split.cwl
#    in: bam_re2
#    out:
#      - split1
#      - split2


  bam_rep1_splits_clipperreproducingpeakscount:
    run: wf_bams_clipperreproducingpeakscount.cwl
    in:
      bam_rep1: rep1split1 # bam_rep1_split/split1
      bam_rep2: rep1split2 # bam_rep1_split/split2
      bam_input1: bam_input1
      bam_input2: bam_input2
      species: species
#      outputprefixRep1: outputprefixRep1
#      outputprefixRep2: outputprefixRep2
#      inputnormsuffixRep1: inputnormsuffixRep1
#      inputnormsuffixRep2: inputnormsuffixRep2
#      idrOutputFilename: idrOutputFilename
#      idrOutputBedFilename: idrOutputBedFilename
#      idrInputNormRep1BedFilename: idrInputNormRep1BedFilename
#      idrInputNormRep2BedFilename: idrInputNormRep2BedFilename
#      rep1ReproducingPeaksFullOutputFilename: rep1ReproducingPeaksFullOutputFilename
#      rep2ReproducingPeaksFullOutputFilename: rep2ReproducingPeaksFullOutputFilename
#      mergedPeakBedFilename: mergedPeakBedFilename
#      mergedPeakCustomBedFilename: mergedPeakCustomBedFilename

    out:
      - reproducing_peaks_count

  bam_rep2_splits_clipperreproducingpeakscount:
    run: wf_bams_clipperreproducingpeakscount.cwl
    in:
      bam_rep1: rep2split1 # bam_rep2_split/split1
      bam_rep2: rep2split2 # bam_rep2_split/split2
      bam_input1: bam_input1
      bam_input2: bam_input2
      species: species
#      outputprefixRep1: outputprefixRep1
#      outputprefixRep2: outputprefixRep2
#      inputnormsuffixRep1: inputnormsuffixRep1
#      inputnormsuffixRep2: inputnormsuffixRep2
#      idrOutputFilename: idrOutputFilename
#      idrOutputBedFilename: idrOutputBedFilename
#      idrInputNormRep1BedFilename: idrInputNormRep1BedFilename
#      idrInputNormRep2BedFilename: idrInputNormRep2BedFilename
#      rep1ReproducingPeaksFullOutputFilename: rep1ReproducingPeaksFullOutputFilename
#      rep2ReproducingPeaksFullOutputFilename: rep2ReproducingPeaksFullOutputFilename
#      mergedPeakBedFilename: mergedPeakBedFilename
#      mergedPeakCustomBedFilename: mergedPeakCustomBedFilename

    out:
      - reproducing_peaks_count


  max_over_min:
    run: max_over_min.cwl
    in:
      count1: bam_rep1_splits_clipperreproducingpeakscount/reproducing_peaks_count
      count2: bam_rep2_splits_clipperreproducingpeakscount/reproducing_peaks_count
    out:
      - ratio

