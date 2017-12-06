#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


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
#
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"



# NEED BED FILE TO BE SORTED
#---------------------------
# sKBTIA.CLIP1.---.r-.fqTrTrU-SoMaCoSoMeV2ClFi.bed is not case-sensitive sorted at line 4.
# Please use "sort -k1,1 -k2,2n" with LC_COLLATE=C,  or bedSort and try again.

# IMPLEMENTED THIS IN A SEPARATE CWL STEP
# LC_COLLATE=C sort -k1,1 -k2,2n file.bed > file.sorted.bed

baseCommand: [fix_ld_library_path, bedToBigBed, -type=bed6+4]



arguments: [$(inputs.input_bed.nameroot).bb]

inputs:

  input_bed:
    type: File
    format: http://edamontology.org/format_3003
    inputBinding:
      position: -2
    label: ""
    doc: ""

  input_chromsizes:
    type: File
    inputBinding:
      position: -1
    label: ""
    doc: ""

outputs:

  output_bigbed:
    type: File
    format: http://edamontology.org/format_3004
    outputBinding:
      glob: $(inputs.input_bed.nameroot).bb
    label: ""
    doc: ""
