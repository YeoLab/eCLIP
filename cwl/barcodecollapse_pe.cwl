#!/usr/bin/env cwl-runner

### doc: "collapses eCLIP barcodes to remove PCR duplicates" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 32000
    # tmpdirMin: 4000
    # outdirMin: 4000

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
    # format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
      prefix: -b
    label: ""
    doc: "input bam to barcode collapse. NOTE: no use for a bai index file!"

arguments: [
  "-o",
  $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.bam,
  "-m",
  $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.metrics
  ]

outputs:

  output_barcodecollapsepe_bam:
    type: File
    # format: http://edamontology.org/format_2572
    outputBinding:
      glob: $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.bam
    label: ""
    doc: "barcode collapseed mappings bam "

  output_barcodecollapsepe_metrics:
    type: File
    outputBinding:
      glob: $(inputs.input_barcodecollapsepe_bam.nameroot).rmDup.metrics
    label: ""
    doc: "barcode collapse metrics"

doc: |
  This tool wraps barcodecollapsepe.py, a paired-end PCR duplicate removal script
  which reads in a .bam file where the first string left of : split of the read name is the barcode
  and merge reads mapped to the same position that have the same barcode.
  Assumes paired end reads are adjacent in output file (ie needs unsorted bams)
  Also assumes no multimappers in the bam file (otherwise behavior is undefined)
    Usage: python barcodecollapsepe.py --bam BAM --out_file OUT_FILE --metrics_file METRICS_FILE