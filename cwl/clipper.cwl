#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 8
    #ramMin: 126000
    ramMin: 30000
    #tmpdirMin: 10000
    #outdirMin: 10000

#hints:
#  - class: ex:SystemRequirement
#    "*":
#      # dnanexus instance with 8Gram/20Gdisk * 8 cores = 64G total
#      instanceType: mem3_ssd1_x16
#  #- class: ex:PackageRequirement
#  #  packages:
#      #- name: libgfortran3
#      #- name: python-numpy
#      #- name: python-scipy
#      #- name: python-tk
#      #- name: python-tornado
#      #- name: python-matplotlib
#      #- name: python-pandas
#      #- name: python-requests
#      #- name: bedtools
#      #- name: samtools
#      #- name: python-htseq
#      #- name: Cython3                     #- name: Cython  ?
#      #  package_manager: pip
#      #  version: "0.24"
#      #- name: pysam
#      #  package_manager: pip
#      #  version: 0.8.3
#      #- name: pybedtools
#      #  package_manager: pip
#      #  version: 0.7.0
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#      - "# Install eclip"
#      - "###############"
#      - "~/miniconda/bin/conda install libgfortran"
#      - "~/miniconda/bin/conda install -c anaconda numpy=1.10 pandas=0.17 scipy=0.16"
#      - "~/miniconda/bin/conda install -c bioconda samtools=1.3.1 bcftools=1.3.1 bedtools=2.25.0"
#      - "~/miniconda/bin/conda install -c bcbio pybedtools=0.6.9 pysam=0.8.4pre0"
#      - "# Install clipper"
#      - "#################"
#      - "sudo ln -s /usr/lib/x86_64-linux-gnu/libgfortran.so.3 /usr/lib/x86_64-linux-gnu/libgfortran.so.1"
#      - "~/miniconda/bin/pip install ~/bin/tool/clipper"
#      - ""


# baseCommand: [clipper, --debug]
baseCommand: [clipper]
# baseCommand: [fix_ld_library_path, clipper]


# arguments: [
#   #--debug,
#   --outfile,
#   $(inputs.bam.nameroot)Cl.bed
# ]

inputs:

  species:
    type: string
    default: hg19
    inputBinding:
      position: 0
      prefix: --species
    doc: "species: one of ce10 ce11 dm3 hg19 GRCh38 mm9 mm10"

  bam:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 1
      prefix: --bam
    #secondaryFiles:
    #  - ".bai"

  # timeout can not be omitted, default value of None in clipper creates error
  timeout:
    type: string
    # 600 seconds, 10 minutes
    # default: "600"
    # 100 hours, > 4 days
    default: "3600000"
    inputBinding:
      position: 7
      prefix: --timeout

  maxgenes:
    type: string
    #default: "2100"
    default: "1000000"
    inputBinding:
      position: 8
      prefix: --maxgenes

  gene:
    type: string?
    inputBinding:
     position: 8
     prefix: --gene

  savepickle:
    type: boolean
    default: true
    inputBinding:
      position: 9
      prefix: --save-pickle

  outfile:
    type: string
    default: ""
    inputBinding:
      position: 10
      prefix: --outfile
      valueFrom: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + "Cl.bed";
          }
          else {
            return inputs.outfile;
          }
        }

outputs:
  output_tsv:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + "Cl.bed.tsv";
          }
          else {
            return inputs.outfile + ".tsv";
          }
        }
  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + "Cl.bed";
          }
          else {
            return inputs.outfile;
          }
        }
  output_pickle:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outfile == "") {
            return inputs.bam.nameroot + "Cl.bed.pickle";
          }
          else {
            return inputs.outfile + ".pickle";
          }
        }

      
