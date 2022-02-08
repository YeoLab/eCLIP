#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


baseCommand: [countaligned.py]
#baseCommand: [singularityexec, eclip.img, countaligned.py]

#$namespaces:
#  ex: http://example.com/

#hints:
#
#  - class: ex:PackageRequirement
#    packages:
#      - name: urllib3
#        package_manager: pip
#        version: "1.18"
#      - name: dxpy
#        package_manager: pip
#        version: 0.191.0
#
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  input_countaligned_sam:
    type: File
    inputBinding:
      position: 1
    label: ""
    doc: "input sam"


outputs:

  output_countaligned_chromcounts:
    type: File
    outputBinding:
      glob: "chromcounts.txt"
    label: ""
    doc: "chromosome counts"
