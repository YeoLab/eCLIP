#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: ResourceRequirement
    coresMin: 8
    ramMin: 8000
    #ramMin: 126000
    #tmpdirMin: 50000
    #outdirMin: 50000
    #tmpdirMin: 400000
    #outdirMin: 400000


#hints:
#  - class: ResourceRequirement
#    coresMin: 6
#    ramMin: 30000
#  - class: ex:SystemRequirement
#    "*":
#      # dnanexus instance with 8Gram/20Gdisk * 8 cores = 64G total
#      instanceType: mem3_ssd1_x16
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


baseCommand: [STAR2]


inputs:

  input_map_ref:
    type: File
    inputBinding:
      position: -3
      prefix: --genomeDir
    label: "Reference genome indexed for STAR."
    doc: "A file, in gzipped tar archive format, with the reference genome sequence already indexed with STAR_Generate_Genome_Index."

  input_map_fwd:
    type: File
    inputBinding:
      position: -2
      prefix: --readFilesIn
    label: "Forward reads."
    doc: "A file, or an array of files, in either gzipped or unzipped FASTQ format, with the reads to be mapped (or the left reads, for paired pairs)."

  input_map_rev:
    type: File
    inputBinding:
      position: -1
    label: "Reverse reads"
    doc: "(Optional?) A file (or an array of files?) in either gzipped or unzipped FASTQ format, with the right reads to be mapped (for paired reads). If input is an array of FASTQ files, the file order needs to match the order of left reads."



  # for hb27:
  # see: https://groups.google.com/forum/#!msg/rna-star/GuUxYI6RHJw/UkabviTUAQAJ
  # out_filter_multimap_nmax
  # --outMultimapperOrder Random --outSAMmultNmax 1 --runRNGseed 0

  # This default value has now been moved back to the inputs
  # default: "1"
  out_filter_multimap_nmax:
    type: string
    inputBinding:
      position: 1
      prefix: --outFilterMultimapNmax

  #input_map_threads:
  #  type: int
  #  default: 15
  #  inputBinding:
  #    position: 2
  #    prefix: --runThreadN
  #  label: ""
  #  doc: "input map threads"

  # TODO now handled in the STAR2 script
  #input_read_files_command:
  #  type: string--readFilesCommand, zcat,
  #  inputBinding:
  #    position: 3
  #    prefix: --readFilesIn
  #  default: -


# --outFilterMultimapNmax, "1",                           # moved back to the inputs

# --outStd, BAM_Unsorted, --readFilesCommand, zcat,
arguments: [
  #--outFileNamePrefix, $(inputs.input_map_rev.nameroot), # TODO now handles better in STAR2 script
  $(inputs.input_map_fwd.nameroot).,
  $(inputs.input_map_rev.nameroot).,

  --runThreadN, '7', --outSAMtype, BAM, Unsorted,
  #--runThreadN, '16', --outSAMtype, BAM, Unsorted,
  --outReadsUnmapped, Fastx,
  --alignEndsType, EndToEnd,
  --outSAMunmapped, Within,
  --outSAMattributes, All,
  --outFilterMultimapScoreRange, "1",
  --outFilterType, BySJout,
  --outFilterScoreMin, "10",
  --outSAMattrRGline, "ID:foo"
  ]

# last 3 lines added to support --outFilterMultimapNmax > 1
#  --outMultimapperOrder, Random,
#  --outSAMmultNmax, "1",
#  --runRNGseed, "0"

outputs:

  output_map_unmapped_fwd:
    type: File
    outputBinding:
      glob: "*U1.fq"

  output_map_unmapped_rev:
    type: File
    outputBinding:
      glob: "*U2.fq"

  output_map_mapped_to_genome:
    type: File
    format: http://edamontology.org/format_2572
    outputBinding:
      glob: "*Ma.bam"
    label: "Reads mapped to the genome."
    doc: "A BAM file with the mapping results."

  output_map_stats:
    type: File
    outputBinding:
      glob: "*Ma.metrics"
    label: "Log file containing mapping statistics."
    doc: "A gzipped text file with mapping statistics."

# TODO: this was sending STAR2 logging messages to a file
#stdout: stdoutfile


#  output_map_splicejunctions:
#    type: File
#    outputBinding:
#      glob: 1mapp.$(inputs.input_map_rev.nameroot).SJ.out.tab
#    label: ""
#    doc: "High confidence splice junctions.\nHigh confidence collapsed splice junctions in tab-delimited format."

#  output_map_mapped_to_transcriptome:
#    type: File
#    outputBinding:
#      glob: 1mapp$(inputs.input_map_rev.nameroot).Aligned.toTranscriptome.out.bam
#    label: "Reads mapped to the transcriptome"
#    doc: "A BAM file with the reads mapping to the pre-defined transcriptome regions."
