#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

# baseCommand: [fixscores.py]
baseCommand: [fix_ld_library_path, fixscores.py]


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


#$namespaces:
#  ex: http://example.com/

#hints:
#
#  - class: ex:PackageRequirement
#    packages:
#      - name: bedtools
#      - name: samtools
#      - name: python-htseq
#      - name: pysam
#        package_manager: pip
#        version: 0.8.3
#      - name: pybedtools
#        package_manager: pip
#        version: 0.7.0

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


arguments: [
  --out_file,
  $(inputs.input_bed.nameroot)Fi.bed
]


inputs:

  input_bed:
    type: File
    format: http://edamontology.org/format_3003
    inputBinding:
      position: 1
      prefix: --bed
    label: ""
    doc: ""


outputs:

  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.input_bed.nameroot)Fi.bed
    label: ""
    doc: ""
