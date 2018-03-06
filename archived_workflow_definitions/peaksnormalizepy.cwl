#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


# baseCommand: [peaksnormalizepy2]
baseCommand: [fix_ld_library_path, peaksnormalizepy2]


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

#requirements:
#
#  #- class: InlineJavascriptRequirement
#
# TODO not suported by Toi
# TODO can we get away without doing anything like this?
#  - class: InitialWorkDirRequirement
#    listing:
#      - $(inputs.in_ip_r2_bam)
#      - $(inputs.in_input_r2_bam)
#      - $(inputs.in_ip_peaks_bed)
#      - $(inputs.in_ip_r2_bai)
#      - $(inputs.in_input_r2_bai)

#  - class: CreateFileRequirement
#    fileDef:
#      - filename: $(inputs.in_ip_r2_bam.basename).COPY
#        fileContent: $(inputs.in_ip_r2_bam)

#  - class: CreateFileRequirement
#    fileDef:
#      - filename: $(inputs.in_ip_r2_bam.path.split('/').slice(-1)[0])
#        fileContent: $(inputs.in_ip_r2_bam)


arguments:

# locations

  - $(inputs.ipbed.location)
  - $(inputs.ipbam.location)
  - $(inputs.ipbai.location)

  - $(inputs.inbam.location)
  - $(inputs.inbai.location)

# basenames

  - $(inputs.ipbed.basename)
  - $(inputs.ipbam.basename)
  - $(inputs.ipbai.basename)

  - $(inputs.inbam.basename)
  - $(inputs.inbai.basename)

#

  - $(inputs.ipbed.nameroot)No.bed
  - $(inputs.ipbed.nameroot)No.full.bed


inputs:

  ipbed:
    type: File
    format: http://edamontology.org/format_3003
    #inputBinding:
    #  position: -1
    #  #valueFrom: $(inputs.ipbed.basename)

  ipbam:
    type: File
    format: http://edamontology.org/format_2572
    #inputBinding:
    #  position: -3
    #  #valueFrom: $(inputs.ipbam.basename)

  ipbai:
    type: File
    format: http://edamontology.org/format_3327
    #inputBinding:
    #  position: 1
    #  #valueFrom: $(inputs.ipbai.basename)

  inbam:
    type: File
    format: http://edamontology.org/format_2572
    #inputBinding:
    #  position: -2
    #  #valueFrom: $(inputs.inbam.basename)

  inbai:
    type: File
    format: http://edamontology.org/format_3327
    #inputBinding:
    #  position: 2
    #  #valueFrom: $(inputs.inbai.basename)

outputs:


  output_bed:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.ipbed.nameroot)No.bed

  output_bedfull:
    type: File
    format: http://edamontology.org/format_3003
    outputBinding:
      glob: $(inputs.ipbed.nameroot)No.full.bed


#  output_bed1:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N1.bed
#
#  output_bedfull1:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N1.full.bed
#
#
#  output_bed2:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N2.bed
#
#  output_bedfull2:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N2.full.bed
#
#
#  output_bed3:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N3.bed
#
#  output_bedfull3:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N3.full.bed
#
#
#  output_bed4:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N4.bed
#
#  output_bedfull4:
#    type: File
#    format: http://edamontology.org/format_3003
#    outputBinding:
#      glob: $(inputs.ipbed.nameroot)N4.full.bed
