#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
    #tmpdirMin: 4000
    #outdirMin: 4000


baseCommand: [barcodecollapsepe.py]
# baseCommand: [fix_ld_library_path, barcodecollapsepe.py]

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

inputs:

  input_barcodecollapsepe_bam:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
      prefix: -b
    label: ""
    doc: "input bam to barcode collapse. NOTE: no use for a bai index file!"

arguments: [
  "-o",
  $(inputs.input_barcodecollapsepe_bam.nameroot)Cp.bam,
  "-m",
  $(inputs.input_barcodecollapsepe_bam.nameroot)Cp.metrics
  ]

outputs:

  output_barcodecollapsepe_bam:
    type: File
    format: http://edamontology.org/format_2572
    outputBinding:
      glob: $(inputs.input_barcodecollapsepe_bam.nameroot)Cp.bam
    label: ""
    doc: "barcode collapseed mappings bam "

  output_barcodecollapsepe_metrics:
    type: File
    outputBinding:
      glob: $(inputs.input_barcodecollapsepe_bam.nameroot)Cp.metrics
    label: ""
    doc: "barcode collapse metrics"
