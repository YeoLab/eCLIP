#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


# FIXME
baseCommand: [fastqc, -t, "2", --extract, -k, "7",]

#baseCommand: [singularityexec, eclip.img, /projects/ps-yeolab/software/FastQC-0.11.3/fastqc, -t, "2", --extract, -k, "7",]

#$namespaces:
#  ex: http://example.com/

#hints:

#  - class: ex:PackageRequirement
#    packages:
#      - name: openjdk-7-jre-headless

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  output_postfix:
    type: string
    default: .
    inputBinding:
      position: 1
      prefix: -o
    label: ""
    doc: ""

  reads:
    type: File
    inputBinding:
      position: 1
    label: ""
    doc: ""

outputs:

  output_qc_report:
    type: File
    outputBinding:
      glob: "*/fastqc_report.html"

  output_qc_stats:
    type: File
    outputBinding:
      glob: "*/fastqc_data.txt"
