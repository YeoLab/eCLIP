#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000




###############################################################################
# example

# in old pipeline the metrics file start with a dataset identifier: here 204_01 fro rbfox2


#clip_analysis  \

#--metrics '204_01_metrics' \

#--AS_Structure       '/projects/ps-yeolab/genomes/hg19/hg19data4' \
#--genome_location    '/projects/ps-yeolab/genomes/hg19/chromosomes/all.fa' \
#--phastcons_location '/projects/ps-yeolab/genomes/hg19/hg19_phastcons.bw' \
#--gff_db             '/projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.annotation.gtf.db' \
#--regions_location   '/home/gpratt/cell_specific_annotations'

#-s hg19_HepG2  \
#--bam '/projects/ps-yeolab3/encode/analysis/encode_v12/271_01_HNRNPC.merged.r2.bam' \
#--clusters '/home/gpratt/projects/encode/analysis/peak_reanalysis_v14/203_01.basedon_203_01.peaks.l2inputnormnew.bed.compressed.bed.annotatedl2fc_3_pval_3.clipper.bed.clip_formatted.bed' \

#--nrand 3 \
#--runPhast \

###############################################################################


baseCommand: [fix_ld_library_path, clip_analysis]
#baseCommand: [clip_analysis]
#baseCommand: [echo, clip_analysis]


stdout: $(inputs.input_clipanalysis_bed.nameroot).metrics


arguments: [
  --AS_Structure,      /projects/ps-yeolab/genomes/hg19/hg19data4,
  --genome_location,    /projects/ps-yeolab/genomes/hg19/chromosomes/all.fa,
  --phastcons_location, /projects/ps-yeolab/genomes/hg19/hg19_phastcons.bw,
  --gff_db,             /projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.annotation.gtf.db,
  --regions_location,   /home/gpratt/cell_specific_annotations,

  --metrics,            $(inputs.input_clipanalysis_bed.nameroot).metrics
]


inputs:

  input_clipanalysis_k:
    type: string
    default: "7"
    inputBinding:
      position: 1
      prefix: --kmerlength
    doc: "k-mer length for k-mer and homer motif analysis"

  input_clipanalysis_nrand:
    type: string
    default: "3"
    inputBinding:
      position: 2
      prefix: --nrand
    doc: "number of times to randomly sample genome"


  input_clipanalysis_runPhast:
    type: boolean
    default: False
    inputBinding:
      position: 3
      prefix: --runPhast

  input_clipanalysis_species:
    type: string
    default: hg19
    inputBinding:
      position: 4
      prefix: -s
    doc: "species: one of ce10 ce11 dm3 hg19 GRCh38 mm9 mm10"

  input_clipanalysis_bam:
    type: File
    format: http://edamontology.org/format_2572
    inputBinding:
      position: 5
      prefix: --bam

  input_clipanalysis_bed:
    type: File
    format: http://edamontology.org/format_3003
    inputBinding:
      position: 6
      prefix: --clusters


outputs:

  #output_clipanalysis_bed:
  #  type: File
  #  format: http://edamontology.org/format_3003
  #  outputBinding:
  #    glob: $($(inputs.input_clipanalysis_bed.nameroot)Cl.bed

  output_clipanalysis_metrics:
    type: File
    outputBinding:
      glob: $(inputs.input_clipanalysis_bed.nameroot).metrics

  output_clipanalysis_qcfig:
    type: File
    outputBinding:
      glob: $(inputs.input_clipanalysis_bed.nameroot).*.qc_fig.svg

  output_clipanalysis_distfig:
    type: File
    outputBinding:
      glob: $(inputs.input_clipanalysis_bed.nameroot).*.DistFig.svg
