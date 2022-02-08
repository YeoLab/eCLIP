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
#  - class: ex:PackageRequirement
#    packages:
#      - name: bedtools
#      - name: samtools
#      - name: pysam
#        package_manager: pip
#        version: 0.8.3
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#      - "~/miniconda/bin/conda install argparse"
#      - ""


# baseCommand: [singularityexec, eclip.img, echo, bam_to_bigwigs.py]
# baseCommand: [singularityexec, eclip.img, touch]
# baseCommand: [singularityexec, eclip.img, ls, -l]


baseCommand: [fix_ld_library_path, bam_to_bigwigs.py]
# baseCommand: [bam_to_bigwigs.py]


arguments: [
  --bw_pos,
  $(inputs.bam.nameroot).posbw,
  --bw_neg,
  $(inputs.bam.nameroot).negbw
  ]

inputs:

  bam:
     type: File
     format: http://edamontology.org/format_2572
     inputBinding:
       position: 1
       prefix: --bam
     #secondaryFiles:
     #  - ".bai"

  bai:
    type: File
    format: http://edamontology.org/format_3327
    inputBinding:
      position: 2
      prefix: --bai

  chromsizes:
    type: File
    inputBinding:
      position: 3
      prefix: --genome

outputs:

  posbw:
    type: File
    format: http://edamontology.org/format_3006
    outputBinding:
      glob: $(inputs.bam.nameroot).posbw

  negbw:
    type: File
    format: http://edamontology.org/format_3006
    outputBinding:
      glob: $(inputs.bam.nameroot).negbw

  #posbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).posbg
  #negbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).negbg
  #noposbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.posbg
  #nonegbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.negbg
  #nonegtbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.negttbg
