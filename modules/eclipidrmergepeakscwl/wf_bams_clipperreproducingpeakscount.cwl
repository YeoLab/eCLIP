#!/usr/bin/env cwltool


cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement


inputs:

  bam_rep1:
    type: File
  bam_rep2:
    type: File

  #bam_input1:
  #  type: File
  bam_input2:
    type: File

  species:
    type: string


outputs:

  reproducing_peaks_count:
    type: int
    outputSource: merge_peaks/reproducing_peaks_count


steps:


  clipper_rep1:
    run: clipper.cwl
    in:
      bam: bam_rep1
      species: species
    out:
      - output_bed


  clipper_rep2:
    run: clipper.cwl
    in:
      bam: bam_rep2
      species: species
    out:
      - output_bed


  merge_peaks:

    run: wf_eclipidrmergepeaks.cwl

    in:
      rep1ClipBam: bam_rep1
      rep1InputBam: bam_input2
      rep1PeaksBed: clipper_rep1/output_bed

      rep2ClipBam: bam_rep2
      rep2InputBam: bam_input2
      rep2PeaksBed: clipper_rep1/output_bed


    out:
      - reproducing_peaks_count


