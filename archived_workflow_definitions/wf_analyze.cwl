#!/usr/bin/env cwltool

cwlVersion: v1.0

class: Workflow



requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: InlineJavascriptRequirement



inputs:

  species:
    type: string
  peaks_bam:
    type: File
  peaks_bed:
    type: File
  l2fc:
    type: string
    #default: "3"
  pval:
    type: string
    #default: "3"

outputs:

  filteredpeaks_bed:
    type: File
    outputSource: clippeaksfilter/output_clippeaksfilter_bed

#  clipanalysis_metrics:
#    type: File
#    outputSource: clipanalysis/output_clipanalysis_metrics
#
#  output_clipanalysis_qcfig:
#    type: File
#    outputSource: clipanalysis/output_clipanalysis_qcfig
#
#  output_clipanalysis_distfig:
#    type: File
#    outputSource: clipanalysis/output_clipanalysis_distfig



steps:

  clippeaksfilter:
    run: clippeaksfilter.cwl
    in:
      input_clippeaksfilter_l2fc: l2fc
      input_clippeaksfilter_pval: pval
      input_clippeaksfilter_bed: peaks_bed
    out: [output_clippeaksfilter_bed]

#  clipanalysis:
#    run: clipanalysis.cwl
#    in:
#      input_clipanalysis_species: species
#      input_clipanalysis_bam: peaks_bam
#      input_clipanalysis_bed: clippeaksfilter/output_clippeaksfilter_bed
#    out: [output_clipanalysis_metrics, output_clipanalysis_qcfig, output_clipanalysis_distfig ]
