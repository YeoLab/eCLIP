#!/usr/bin/env cwltool

### Fastqc annoyingly does not allow customized output filenames, so we need to re-name each so they dont overlap each other. 

cwlVersion: v1.0
class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  reads:
    type: File

outputs:
  output_qc_report:
    type: File
    outputSource: step_rename_report/outfile
  output_qc_stats:
    type: File
    outputSource: step_rename_stats/outfile


steps:

###########################################################################
# Upstream
###########################################################################
  step_fastqc:
    run: fastqc.cwl
    in:
      reads: reads
    out: [
      output_qc_report,
      output_qc_stats
    ]

###########################################################################
# Downstream
###########################################################################
  step_rename_report:
    run: rename.cwl
    in:
      srcfile: step_fastqc/output_qc_report
      suffix: 
        default: ".html"
      newname:
        source: reads
        valueFrom: ${ return self.nameroot + ".fastqc_report"; }
    out: [
      outfile
    ]
  step_rename_stats:
    run: rename.cwl
    in:
      srcfile: step_fastqc/output_qc_stats
      suffix: 
        default: ".txt"
      newname:
        source: reads
        valueFrom: ${ return self.nameroot + ".fastqc_data"; }
    out: [
      outfile
    ]
    
doc: |
  This workflow takes in single-end reads, and performs the following steps in order:
  demux_se.cwl (does not actually demux for single end, but mirrors the paired-end processing protocol)
