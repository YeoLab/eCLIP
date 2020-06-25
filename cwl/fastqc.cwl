#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 8000
    tmpdirMin: 4000
    outdirMin: 4000

baseCommand: [fastqc, -t, "2", --extract, -k, "7", -j, "/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/jre/bin/java"]

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
