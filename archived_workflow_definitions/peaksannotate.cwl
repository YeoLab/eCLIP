#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


baseCommand: [peaksannotate.py]
#baseCommand: [peaksannotatepass.sh]


#$namespaces:
#  ex: http://example.com/

#hints:

  #- class: ex:PackageRequirement
  #  packages:
  #    - name: bedtools
  #    - name: samtools
  #    - name: pysam
  #      package_manager: pip
  #      version: 0.8.3

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#      - "# Install eclip"
#      - "###############"
#      - "~/miniconda/bin/conda install -c anaconda numpy=1.10 pandas=0.17 scipy=0.16"
#      - "~/miniconda/bin/conda install -c bioconda samtools=1.3.1 bcftools=1.3.1 bedtools=2.25.0"
#      - "#~/miniconda/bin/conda install cython-0.24.1"
#      - "~/miniconda/bin/conda install -c bcbio pybedtools=0.6.9 pysam=0.8.4pre0"
#      - ""


arguments: [ --output, $(inputs.input_bed.nameroot)An.bed ]


inputs:

  input_bed:
    type: File
    format: http://edamontology.org/format_3003
    inputBinding:
      prefix: --input

  annotateref:
    type: File
    inputBinding:
      prefix: --gtfd

  ### previous version of above input
  #gtfd_bed:
  #  type: File
  #  format: http://edamontology.org/format_3003
  #  default:
  #     class: File
  #     path: gencode.v19.annotation.gtf.db
  #     #path: /projects/ps-yeolab/software/eclip/eclip-0.1.5/repo/members/annotate/example/gencode.v19.annotation.gtf.db
  #  inputBinding:
  #    prefix: --gtfd

outputs:

  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.input_bed.nameroot)An.bed
