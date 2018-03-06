#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: InlineJavascriptRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  species:
    type: string

  annotateref:
    type: File

  pair:
    type:
      type: record
      fields:
        ip:
          type: string
        in:
          type: string

  name_s:
    type: string[]

  triplet_s:
    type:

      type: array
      items: Any

        #type: record
        #fields:
        #  dataset:
        #    type: string
        #  name:
        #    type: string
        #  bed:
        #    type: File
        #  bam:
        #    type: File
        #  bai:
        #    type: File

  l2fc:
    type: string
  pval:
    type: string

outputs:


  peaksnormalizedperl_bed:
    type: File
    outputSource: ABI_peaksnormalizeperl/output_bed
  peaksnormalizedperl_bedfull:
    type: File
    outputSource: ABI_peaksnormalizeperl/output_bedfull

  peaksnormalizedpy_bed:
    type: File
    outputSource: ABI_peaksnormalizepy/output_bed
  peaksnormalizedpy_bedfull:
    type: File
    outputSource: ABI_peaksnormalizepy/output_bedfull


#  peaksnormalizedpy1_bed:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bed1
#  peaksnormalizedpy1_bedfull:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bedfull1
#  peaksnormalizedpy2_bed:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bed2
#  peaksnormalizedpy2_bedfull:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bedfull2
#  peaksnormalizedpy3_bed:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bed3
#  peaksnormalizedpy3_bedfull:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bedfull3
#  peaksnormalizedpy4_bed:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bed4
#  peaksnormalizedpy4_bedfull:
#    type: File
#    outputSource: ABI_peaksnormalizepy/output_bedfull4


  peaksnormalizedperlcompressedperl_bed:
    type: File
    outputSource: ABI_peakscompressperl/output_bed
  peaksnormalizedpycompressedpy_bed:
    type: File
    outputSource: ABI_peakscompresspy/output_bed


#  peaksannotated_bed:
#    type: File
#    outputSource: ABI_peaksannotate/output_bed


  filteredpeaksperl_bed:
    type: File
    outputSource: ABI_analyseperl/filteredpeaks_bed
  filteredpeakspy_bed:
    type: File
    outputSource: ABI_analysepy/filteredpeaks_bed


  #clipanalysis_metrics:
  #  type: File
  #  outputSource: ABI_analyse/clipanalysis_metrics
  #output_clipanalysis_qcfig:
  #  type: File
  #  outputSource: ABI_analyse/output_clipanalysis_qcfig
  #output_clipanalysis_distfig:
  #  type: File
  #  outputSource: ABI_analyse/output_clipanalysis_distfig


steps:

###########################################################################
# Look up triplets
###########################################################################

  lookupindexpair:
    run: lookupindexpair.cwl
    in:
      pair: pair
      name_s: name_s
    out: [ipindex, inindex]

  lookup:
    run: lookuptripletpair.cwl
    in:
      ipindex: lookupindexpair/ipindex
      inindex: lookupindexpair/inindex
      triplet_s: triplet_s
    out: [ipbed, ipbam, ipbai, inbed, inbam, inbai]

###########################################################################
# Normalize
###########################################################################


  ABI_peaksnormalizeperl:
    run: peaksnormalizeperl.cwl
    in:

      ipbed: lookup/ipbed
      ipbam: lookup/ipbam
      ipbai: lookup/ipbai

      inbam: lookup/inbam
      inbai: lookup/inbai

    out: [
      output_bed, output_bedfull
      ]

  ABI_peaksnormalizepy:
    run: peaksnormalizepy.cwl
    in:

      ipbed: lookup/ipbed
      ipbam: lookup/ipbam
      ipbai: lookup/ipbai

      inbam: lookup/inbam
      inbai: lookup/inbai

    out: [
      output_bed, output_bedfull
      #, output_bed1, output_bedfull1, output_bed2, output_bedfull2, output_bed3, output_bedfull3, output_bed4, output_bedfull4
      ]



  ABI_peakscompressperl:
    run: peakscompressperl.cwl
    in:
      input_bed: ABI_peaksnormalizeperl/output_bed
    out: [
      output_bed
      ]

  ABI_peakscompresspy:
    run: peakscompresspy.cwl
    in:
      input_bed: ABI_peaksnormalizepy/output_bed
    out: [
      output_bed
      ]



#  ABI_peaksannotate:
#    run: peaksannotate.cwl
#    in:
#      annotateref: annotateref
#      input_bed: ABI_peaksnormalize/output_bed
#      #input_bed: ABI_peaksnormalizepy/output_bed
#      #input_bed: ABI_peakscollapse/output_bed
#      #input_bed: ABI_peakscompresspy/output_bed
#    out: [
#      output_bed
#      ]






###########################################################################
# Analyze
###########################################################################

  ABI_analyseperl:

    run: wf_analyze.cwl
    in:
      species: species
      peaks_bam: lookup/ipbam
      peaks_bed: ABI_peakscompressperl/output_bed
      #peaks_bed: ABI_peakscompresspy/output_bed
      #peaks_bed: ABI_peaksannotate/output_bed
      l2fc: l2fc
      pval: pval

    out: [
             filteredpeaks_bed
             #, clipanalysis_metrics, output_clipanalysis_qcfig, output_clipanalysis_distfig
         ]

  ABI_analysepy:

    run: wf_analyze.cwl
    in:
      species: species
      peaks_bam: lookup/ipbam
      peaks_bed: ABI_peakscompresspy/output_bed
      #peaks_bed: ABI_peakscompresspy/output_bed
      #peaks_bed: ABI_peaksannotate/output_bed
      l2fc: l2fc
      pval: pval

    out: [
             filteredpeaks_bed
             #, clipanalysis_metrics, output_clipanalysis_qcfig, output_clipanalysis_distfig
         ]



